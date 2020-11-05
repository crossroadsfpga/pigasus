`include "./src/struct_s.sv"
//`define DEBUG
module flow_reassembly(
    input   logic                   clk,
    input   logic                   rst,
    input   metadata_t              meta_data,
    input   logic                   meta_valid,
    output  logic                   meta_ready,
    input   fce_t                   fce_data,
    input   logic                   fce_valid,
    output  logic                   fce_ready,
    // Read channel 2
    output  fce_meta_t              ch2_meta,
    output  logic                   ch2_rden,
    input   logic                   ch2_ready,
    input   fce_t                   ch2_q,
    input   logic                   ch2_rd_valid,
    // Write channel 3
    output  logic [2:0]             ch3_opcode,
    output  logic                   ch3_wren,
    input   logic                   ch3_ready,
    output  fce_t                   ch3_data,
    output  logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt,

    output  metadata_t              reorder_meta,
    output  logic                   reorder_valid,
    input   logic                   reorder_ready,
    input   logic                   reorder_almost_full
);

typedef enum {
    IDLE,
    GET_FCE,
    COMPARE,
    WAIT_WR_READY
} state_t;
state_t state;

logic [31:0]    next_seq;
logic [7:0]     cycle;

// Signals for linked-list
logic                   ll_start;
logic                   ll_done;
logic                   ll_discard;
logic [LL_AWIDTH-1:0]   ll_pointer;
logic [PKT_AWIDTH-1:0]  ll_pkt_id;
logic [4:0]             ll_flits;
logic [31:0]            ll_seq;
logic [15:0]            ll_len;
logic [55:0]            ll_last_7_bytes;
logic [LL_AWIDTH-1:0]   ll_update_p;
logic                   ll_update_p_valid;
logic                   ll_load_head;
entry_t                 ll_head_out;
logic                   ll_head_out_valid;
logic                   ll_store_head;
entry_t                 ll_head_in;
logic [LL_AWIDTH-1:0]   ll_head_wr_addr;
logic                   ll_load_empty_pointer;
logic [LL_AWIDTH-1:0]   ll_empty_pointer;
logic                   ll_empty_pointer_valid;

logic [31:0]            start_p;
logic [31:0]            end_p;
logic [55:0]            last_7_bytes;

//internal state
fce_t                   fce_data_r;
metadata_t              meta_data_r;
logic                   done;
logic                   ch3_wr_temp;

/* Pesudocode:
 * if entry.seq == seq
 *     if (first_node match)
 *         push first_node pktID to fetching engine
 *         update entry.pointer
 *         remove the first_node from linked_list
 *     update entry.seq
 * else
 *     if no empty_pointer
 *         load empty_pointer
 *         update entry.pointer
 *     insert new node to linked-list
 */
always @ (posedge clk) begin
    if (rst) begin
        state <= IDLE;
        done <= 0;

        cycle <= 0;
        ll_load_head <= 0;
        ll_store_head <= 0;
        ll_start <= 0;

        meta_ready <= 0;
        fce_ready <= 0;
        ch3_wren <= 0;
        ch3_wr_temp <= 0;
        ch2_rden <= 0;
        reorder_meta <= 0;
        reorder_valid <= 0;
        ch3_opcode <= FT_UPDATE;
        ch3_rel_pkt_cnt <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                // Initialize states
                cycle <= 0;
                done <= 0;
                ll_start <= 0;
                ll_load_head <= 0;
                ll_store_head <= 0;

                // Default values
                reorder_valid <= 0;
                reorder_meta <= meta_data;
                ch3_wren <= 0;
                ch3_wr_temp <= 0;
                ch2_rden <= 0;
                ch3_opcode <= FT_UPDATE;
                ch3_rel_pkt_cnt <= 0;

                if (meta_valid & fce_valid & !reorder_almost_full) begin
                    state <= GET_FCE;

                    meta_data_r <= meta_data;
                    meta_ready <= 1;
                    fce_ready <= 1;
                    start_p <= meta_data.seq;
                    end_p <= meta_data.seq + meta_data.len;

                    ch2_rden <= 1;
                    ch2_meta.addr0 <= fce_data.addr0;
                    ch2_meta.addr1 <= fce_data.addr1;
                    ch2_meta.addr2 <= fce_data.addr2;
                    ch2_meta.addr3 <= fce_data.addr3;
                    ch2_meta.tuple <= fce_data.tuple;
                    ch2_meta.opcode <= 0;
                end
            end
            // Wait until ch2 data is ready
            GET_FCE: begin
                meta_ready <= 0;
                fce_ready <= 0;
                // Read is success
                if (ch2_ready) begin
                    ch2_rden <= 0;
                end
                if (ch2_rd_valid) begin
                    fce_data_r <= ch2_q;
                    state <= COMPARE;

                    // Default value is the fce with latest
                    // seq (the slow_cnt may not be latest).
                    ch3_data <= ch2_q;
                end
            end
            COMPARE: begin
                reorder_valid <= 0;
                ch3_wren <= 0;
                ch3_opcode <= FT_UPDATE;

                // Seq is expected, check whether or not it fills the hole
                if (meta_data_r.seq == fce_data_r.seq) begin
                    // Update entry.seq
                    case (cycle)
                        8'd0: begin
                            `ifdef DEBUG
                            $display("[FR] Match seq: pkt %d, seq %x, length %d, expected_seq %x",
                                     meta_data_r.pktID, meta_data_r.seq, meta_data_r.len,
                                     fce_data_r.seq);
                            `endif
                            // Output as long as it is inorder packet
                            reorder_meta <= meta_data_r;
                            reorder_valid <= 1;
                            // It it possible that the packet is actually in
                            // order. This can happen due to stale state.
                            if (!fce_data_r.ll_valid) begin
                                state <= WAIT_WR_READY;
                                ch3_wren <= 1;
                                ch3_data.seq <= end_p;
                                ch3_data.pointer <= 0;
                                ch3_data.ll_valid <= 0;
                                // Store current pkt's last_7_bytes
                                ch3_data.last_7_bytes <= meta_data_r.last_7_bytes;
                                // Release current pkt
                                ch3_rel_pkt_cnt <= 1;

                                // Delete the fce
                                if (meta_data_r.tcp_flags[TCP_FIN] |
                                    meta_data_r.tcp_flags[TCP_RST]) begin
                                    $display("FIN/RST : pkt %d, seq %x, length %d, expect %x",
                                             meta_data_r.pktID, meta_data_r.seq, meta_data_r.len,
                                             fce_data_r.seq);

                                    ch3_data.valid <= 0;
                                    ch3_opcode <= FT_DELETE;
                                    reorder_meta.pkt_flags <= PKT_FORWARD;
                                end
                            end
                            else begin
                                cycle <= 1;
                                ll_load_head <= 1;
                                ll_pointer <= fce_data_r.pointer;
                                last_7_bytes <= meta_data_r.last_7_bytes;
                                ch3_rel_pkt_cnt <= 1; // Release packet count
                            end
                        end
                        8'd1: begin
                            ll_load_head <= 0;
                            ll_store_head <= 0;
                            if (ll_head_out_valid) begin
                                next_seq <= ll_head_out.seq;
                                cycle <= 2;
                            end
                        end
                        // Now the next pkt is in the LL
                        8'd2: begin
                            if (next_seq == end_p) begin
                                `ifdef DEBUG
                                $display("[FR] Reordered: pkt %d, seq %x, length %d",
                                         ll_head_out.pktID, ll_head_out.seq, ll_head_out.len);
                                `endif
                                reorder_valid <= 1;
                                reorder_meta.pkt_flags <= PKT_OOO;
                                reorder_meta.pktID <= ll_head_out.pktID;
                                reorder_meta.flits <= ll_head_out.flits;
                                // Release packet count
                                ch3_rel_pkt_cnt <= ch3_rel_pkt_cnt + 1;
                                // Previous pkt's last_7_bytes
                                reorder_meta.last_7_bytes <= last_7_bytes;
                                last_7_bytes <= ll_head_out.last_7_bytes;

                                // Clear head
                                ll_head_in <= 0;
                                ll_store_head <= 1;
                                ll_head_wr_addr <= ll_pointer;

                                // Fetch all the LL nodes
                                if (ll_head_out.last) begin
                                    cycle <= 0;
                                    state <= WAIT_WR_READY;

                                    // Set ll_valid to 1'b0 after fetch the last node
                                    ch3_wren <= 1;
                                    ch3_data.pointer <= 0;
                                    ch3_data.ll_valid <= 0;
                                    // Store current pkt's last 7 bytes
                                    ch3_data.last_7_bytes <= ll_head_out.last_7_bytes;
                                    ch3_data.seq <= ll_head_out.seq + ll_head_out.len;

                                    // Delete the fce
                                    if (meta_data_r.tcp_flags[TCP_FIN] |
                                        meta_data_r.tcp_flags[TCP_RST]) begin
                                        $display("FIN/RST : pkt %d, seq %x, length %d, expect %x",
                                                 meta_data_r.pktID, meta_data_r.seq,
                                                 meta_data_r.len, fce_data_r.seq);

                                        ch3_data.valid <= 0;
                                        ch3_opcode <= FT_DELETE;
                                        reorder_meta.pkt_flags <= PKT_FORWARD;
                                    end

                                    done <= 1;
                                end
                                // Keep searching
                                else begin
                                    // It is possible to fetch a bunch of packets out
                                    if (reorder_almost_full) begin
                                        cycle <= 3;
                                    end
                                    else begin
                                        cycle <= 1;
                                        ll_load_head <= 1;
                                        ll_pointer <= ll_head_out.next;
                                        end_p <= ll_head_out.seq + ll_head_out.len;
                                    end
                                end
                            end
                            // Just update the seq number and
                            // ll_pointer, have LL node left.
                            else begin
                                ch3_wren <= 1;
                                ch3_data.seq <= end_p;
                                ch3_data.pointer <= ll_pointer;
                                //Store current pkt's last_7_bytes
                                ch3_data.last_7_bytes <= last_7_bytes;

                                cycle <= 0;
                                state <= WAIT_WR_READY;
                                done <= 1;
                            end
                        end
                        8'd3: begin
                            if (!reorder_almost_full) begin
                                cycle <= 1;
                                ll_load_head <= 1;
                                ll_pointer <= ll_head_out.next;
                                end_p <= ll_head_out.seq + ll_head_out.len;
                            end
                        end
                        default: cycle <= 0;
                    endcase
                end
                // OOO pkts show up
                else if (meta_data_r.seq > fce_data_r.seq) begin
                    // Won't release any pkt
                    ch3_rel_pkt_cnt <= 0;
                    case (cycle)
                        // Check if the pointer is valid or not
                        8'd0: begin
                            // Invalid pointer, load a valid pointer from linked-list
                            `ifdef DEBUG
                            $display("[FR] OOO pkts: pkt %d, seq %x, length %d",
                                     meta_data_r.pktID, meta_data_r.seq, meta_data_r.len);
                            `endif
                            if (fce_data_r.ll_valid == 0) begin
                                ll_load_empty_pointer <= 1;
                                cycle <= 1;
                            end
                            // Otherwise directly start an insert
                            else begin
                                cycle <= 2;
                                ll_pointer <= fce_data_r.pointer;
                            end
                        end
                        // Get the valid pointer from linked-list
                        8'd1: begin
                            ll_load_empty_pointer <= 0;
                            if (ll_empty_pointer_valid) begin
                                // Set the ll_valid
                                ch3_data.pointer <= ll_empty_pointer;
                                ch3_data.ll_valid <= 1'b1;
                                ch3_wr_temp <= 1;
                                ll_pointer <= ll_empty_pointer;

                                cycle <= 2;
                            end
                        end
                        // Start an insert
                        8'd2: begin
                            ch3_wren <= 0;
                            ll_last_7_bytes <= meta_data_r.last_7_bytes;
                            ll_pkt_id       <= meta_data_r.pktID;
                            ll_flits        <= meta_data_r.flits;
                            ll_seq          <= meta_data_r.seq;
                            ll_len          <= meta_data_r.len;
                            ll_start <= 1;
                            cycle <= 3;
                        end
                        8'd3: begin
                            ll_start <= 0;
                            ch3_wren <= 0;

                            // "ll_update_p_valid" is raised at the same cycle with "ll_done"
                            if (ll_update_p_valid) begin
                                ch3_data.pointer <= ll_update_p;
                            end
                            if (ll_done) begin
                                cycle <= 0;
                                done <= 1;

                                if (ch3_wr_temp | ll_update_p_valid) begin
                                    ch3_wren <= 1;
                                    ch3_wr_temp <= 0;
                                    state <= WAIT_WR_READY;
                                end
                                else begin
                                    state <= IDLE;
                                end
                                if (ll_discard) begin
                                    `ifdef DEBUG
                                    $display("[FR] discard pkts: pkt %d, seq %x, length %d",
                                             meta_data_r.pktID, meta_data_r.seq, meta_data_r.len);
                                    `endif
                                    reorder_valid <= 1;
                                    reorder_meta <= meta_data_r;
                                    reorder_meta.pkt_flags <= PKT_DROP;
                                end
                            end
                        end
                        default: cycle <= 0;
                    endcase
                end
                // Packet with overlapping sequence range.
                // Simply drop it without changing the FT.
                else begin
                    state <= IDLE;
                    done <= 1;
                    ch3_wren <= 1;
                    ch3_rel_pkt_cnt <= 1;
                    reorder_valid <= 1;
                    reorder_meta <= meta_data_r;
                    reorder_meta.pkt_flags <= PKT_DROP;
                    `ifdef DEBUG
                    $display("[FR] Overlap pkts, pkt %d, seq %x, length %d",
                             meta_data_r.pktID, meta_data_r.seq, meta_data_r.len);
                    `endif
                end
            end
            WAIT_WR_READY: begin
                cycle <= 0;
                done <= 0;
                ll_start <= 0;
                ll_load_head <= 0;
                ll_store_head <= 0;
                reorder_valid <= 0;
                reorder_meta <= meta_data;
                ch3_wr_temp <= 0;
                ch2_rden <= 0;

                // Keep the ch3_wr and ch3_data, until it is accepted
                if (ch3_ready) begin
                    ch3_wren <= 0;
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase
    end
end

linked_list ll_inst(
    .clk                (clk),
    .rst                (rst),
    .start              (ll_start),
    .done               (ll_done),
    .discard            (ll_discard),
    .pointer            (ll_pointer),
    .pktID              (ll_pkt_id),
    .flits              (ll_flits),
    .seq                (ll_seq),
    .len                (ll_len),
    .last_7_bytes       (ll_last_7_bytes),
    .update_p           (ll_update_p),
    .update_p_valid     (ll_update_p_valid),
    .load_head          (ll_load_head),
    .head_out           (ll_head_out),
    .head_out_valid     (ll_head_out_valid),
    .store_head         (ll_store_head),
    .head_in            (ll_head_in),
    .head_wr_addr       (ll_head_wr_addr),
    .load_empty_pointer (ll_load_empty_pointer),
    .empty_pointer      (ll_empty_pointer),
    .empty_pointer_valid(ll_empty_pointer_valid)
);

endmodule
