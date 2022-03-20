`include "./src/struct_s.sv"
// `define DEBUG

module flow_reassembly(
    // General inputs
    input   logic                   clk,
    input   logic                   rst,
    // Heap input
    output  logic                   heap_out_deque_min_en,
    input   logic                   heap_out_deque_min_ready,
    input   ooo_flow_id_t           heap_out_deque_min_ooo_flow_id,
    input   heap_priority_t         heap_out_deque_min_priority,
    // Scheduler read channel
    output  logic                   scheduler_rdch_rden,
    output  ooo_flow_id_t           scheduler_rdch_ooo_flow_id,
    input   logic                   scheduler_rdch_ready,
    input   logic                   scheduler_rdch_rd_valid,
    input   logic                   scheduler_rdch_rd_ooo_flow_invalid,
    input   metadata_t              scheduler_rdch_meta,
    input   ooo_flow_fc_entry_t     scheduler_rdch_fce,
    // Scheduler write channel
    output  logic                   scheduler_wrch_wren,
    input   logic                   scheduler_wrch_ready,
    output  logic                   scheduler_wrch_is_delete,
    output  ooo_flow_fc_entry_t     scheduler_wrch_update_fce,
    output  logic [PKT_AWIDTH-1:0]  scheduler_wrch_rel_pkt_cnt,
    // GC request
    output  logic                   gc_req_state_idle,
    output  logic                   gc_req_fifo_rdreq,
    input   logic                   gc_req_fifo_empty,
    input   reassembly_gc_req_t     gc_req_fifo_q,
    output  logic [31:0]            gc_fl_fill_level,
    // GC response
    input   logic                   gc_rsp_fifo_full,
    output  reassembly_gc_meta_t    gc_rsp_fifo_data,
    output  logic                   gc_rsp_fifo_wrreq,
    // Reorder FIFO
    output  metadata_t              reorder_meta,
    output  logic                   reorder_valid,
    input   logic                   reorder_ready,
    input   logic                   reorder_almost_full,
    // Debug
    output  logic                   reassembly_state_idle
);

typedef enum {
    IDLE,
    GET_FCE,
    COMPARE,
    WAIT_WR_READY
} state_t;
state_t state;

typedef enum logic [2:0] {
    GC_FSM_STATE_IDLE,
    GC_FSM_STATE_RD,
    GC_FSM_STATE_RD_WAIT,
    GC_FSM_STATE_RELEASE,
    GC_FSM_STATE_DONE
} gc_fsm_state_t;
gc_fsm_state_t gc_fsm_state;

logic [31:0]    next_seq;
logic [7:0]     cycle;

// Signals for linked-list
logic                   ll_start;
logic                   ll_done;
logic                   ll_discard;
logic                   ll_is_newlist;
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
ooo_flow_fc_entry_t     fce_data_r;
metadata_t              meta_data_r;
logic                   done;

// GC logic
logic                   ll_gc_ready;
logic                   ll_gc_start;
logic [LL_AWIDTH-1:0]   ll_gc_pointer;
entry_t                 ll_gc_entry;
logic                   ll_gc_done;

reassembly_gc_req_t     gc_req;
entry_t                 ll_gc_entry_r;
logic                   reorder_enque_busy;

// Debug
logic [LL_AWIDTH-1:0] gc_cur_ll_release_cnt_r;

assign reassembly_state_idle = (state == IDLE);
assign gc_req_state_idle = (gc_fsm_state == GC_FSM_STATE_IDLE);

// Intermediate and output logic
always @(*) begin
    ll_gc_start = 0;
    reorder_enque_busy = 0;

    if (!rst) begin
        // reorder_enque_busy
        case (state)
            COMPARE: begin
                if (meta_data_r.seq == fce_data_r.seq) begin
                    if ((cycle == 8'd0) ||
                        ((cycle == 8'd2) && (next_seq == end_p))) begin
                        reorder_enque_busy = 1;
                    end
                end
                else if (meta_data_r.seq > fce_data_r.seq) begin
                    if (cycle == 8'd3 && ll_done && ll_discard) begin
                        reorder_enque_busy = 1;
                    end
                end
                else begin
                    reorder_enque_busy = 1;
                end
            end
            default: begin
                reorder_enque_busy = 0;
            end
        endcase
        // ll_gc_start
        case (gc_fsm_state)
            GC_FSM_STATE_RD: begin
                if (ll_gc_ready) begin
                    ll_gc_start = 1;
                end
            end
            default: begin
                ll_gc_start = 0;
            end
        endcase
    end
end

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
        ll_is_newlist <= 0;
        ll_start <= 0;

        scheduler_rdch_rden <= 0;
        heap_out_deque_min_en <= 0;
        scheduler_rdch_ooo_flow_id <= 0;

        scheduler_wrch_wren <= 0;
        scheduler_wrch_is_delete <= 0;
        scheduler_wrch_update_fce <= 0;
        scheduler_wrch_rel_pkt_cnt <= 0;

        reorder_meta <= 0;
        reorder_valid <= 0;

        gc_req <= 0;
        ll_gc_pointer <= 0;
        ll_gc_entry_r <= 0;

        gc_rsp_fifo_data <= 0;
        gc_rsp_fifo_wrreq <= 0;
        gc_req_fifo_rdreq <= 0;
        gc_fsm_state <= GC_FSM_STATE_IDLE;
    end
    else begin
        reorder_valid <= 0;
        case (state)
            IDLE: begin
                // Initialize states
                cycle <= 0;
                done <= 0;
                ll_start <= 0;
                ll_load_head <= 0;
                ll_store_head <= 0;
                ll_is_newlist <= 0;

                // Default values
                scheduler_rdch_rden <= 0;
                heap_out_deque_min_en <= 0;
                scheduler_rdch_ooo_flow_id <= 0;

                scheduler_wrch_wren <= 0;
                scheduler_wrch_is_delete <= 0;
                scheduler_wrch_update_fce <= 0;
                scheduler_wrch_rel_pkt_cnt <= 0;

                reorder_valid <= 0;
                reorder_meta <= 0;

                if (heap_out_deque_min_ready & !reorder_almost_full) begin
                    state <= GET_FCE;

                    scheduler_rdch_rden <= 1;
                    heap_out_deque_min_en <= 1;
                    scheduler_rdch_ooo_flow_id <= (
                        heap_out_deque_min_ooo_flow_id);
                end
            end
            // Wait until rdch data is ready
            GET_FCE: begin
                heap_out_deque_min_en <= 0;

                // Read is success
                if (scheduler_rdch_ready) begin
                    scheduler_rdch_rden <= 0;
                end
                if (scheduler_rdch_rd_valid) begin
                    if (scheduler_rdch_rd_ooo_flow_invalid) begin
                        state <= IDLE;
                        `ifdef DEBUG
                        $display("[FR] Got OOO flow ID %0d from heap, flow invalid",
                                 scheduler_rdch_ooo_flow_id);
                        `endif
                    end
                    else begin
                        state <= COMPARE;

                        `ifdef DEBUG
                        $display("[FR] Got OOO flow ID %0d from heap with LL size %0d, starting processing",
                                 scheduler_rdch_ooo_flow_id, scheduler_rdch_fce.ll_size);
                        `endif

                        fce_data_r <= scheduler_rdch_fce;
                        meta_data_r <= scheduler_rdch_meta;
                        start_p <= scheduler_rdch_meta.seq;
                        end_p <= (scheduler_rdch_meta.seq +
                                  scheduler_rdch_meta.len);

                        // Default value is the fce with latest seq
                        scheduler_wrch_update_fce <= scheduler_rdch_fce;
                    end
                end
            end
            COMPARE: begin
                reorder_valid <= 0;
                scheduler_wrch_wren <= 0;
                scheduler_wrch_is_delete <= 0;

                // Seq is expected, check whether or not it fills the hole
                if (meta_data_r.seq == fce_data_r.seq) begin
                    // Update entry.seq
                    case (cycle)
                        8'd0: begin
                            `ifdef DEBUG
                            $display("[FR] Match seq: pkt %0d, seq %x, length %0d, expected_seq %x",
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
                                scheduler_wrch_wren <= 1;
                                scheduler_wrch_update_fce.seq <= end_p;
                                scheduler_wrch_update_fce.pointer <= 0;
                                scheduler_wrch_update_fce.ll_valid <= 0;
                                // Store current pkt's last_7_bytes
                                scheduler_wrch_update_fce.last_7_bytes <= meta_data_r.last_7_bytes;
                                // Release current pkt
                                scheduler_wrch_rel_pkt_cnt <= 1;

                                // Delete the fce
                                if (meta_data_r.tcp_flags[TCP_FIN] |
                                    meta_data_r.tcp_flags[TCP_RST]) begin
                                    `ifdef DEBUG
                                    $display("[FR] FIN/RST : pkt %0d, seq %x, length %0d, expect %x",
                                             meta_data_r.pktID, meta_data_r.seq, meta_data_r.len,
                                             fce_data_r.seq);
                                    `endif

                                    scheduler_wrch_is_delete <= 1;
                                    reorder_meta.pkt_flags <= PKT_FORWARD;
                                end
                            end
                            else begin
                                cycle <= 1;
                                ll_load_head <= 1;
                                ll_pointer <= fce_data_r.pointer;
                                last_7_bytes <= meta_data_r.last_7_bytes;
                                scheduler_wrch_rel_pkt_cnt <= 1; // Release packet count
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
                                $display("[FR] Reordered: pkt %0d, seq %x, length %0d",
                                         ll_head_out.pktID, ll_head_out.seq, ll_head_out.len);
                                `endif
                                reorder_valid <= 1;
                                reorder_meta.pkt_flags <= PKT_OOO;
                                reorder_meta.pktID <= ll_head_out.pktID;
                                reorder_meta.flits <= ll_head_out.flits;
                                // Release packet count
                                scheduler_wrch_rel_pkt_cnt <= scheduler_wrch_rel_pkt_cnt + 1;
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
                                    scheduler_wrch_wren <= 1;
                                    scheduler_wrch_update_fce.pointer <= 0;
                                    scheduler_wrch_update_fce.ll_valid <= 0;
                                    // Store current pkt's last 7 bytes
                                    scheduler_wrch_update_fce.last_7_bytes <= ll_head_out.last_7_bytes;
                                    scheduler_wrch_update_fce.seq <= ll_head_out.seq + ll_head_out.len;

                                    // Delete the fce
                                    if (meta_data_r.tcp_flags[TCP_FIN] |
                                        meta_data_r.tcp_flags[TCP_RST]) begin
                                        `ifdef DEBUG
                                        $display("[FR] FIN/RST : pkt %0d, seq %x, length %0d, expect %x",
                                                 meta_data_r.pktID, meta_data_r.seq,
                                                 meta_data_r.len, fce_data_r.seq);
                                        `endif

                                        scheduler_wrch_is_delete <= 1;
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
                                scheduler_wrch_wren <= 1;
                                scheduler_wrch_update_fce.seq <= end_p;
                                scheduler_wrch_update_fce.pointer <= ll_pointer;
                                //Store current pkt's last_7_bytes
                                scheduler_wrch_update_fce.last_7_bytes <= last_7_bytes;

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
                    scheduler_wrch_rel_pkt_cnt <= 0;
                    case (cycle)
                        // Check if the pointer is valid or not
                        8'd0: begin
                            // Invalid pointer, load a valid pointer from linked-list
                            `ifdef DEBUG
                            $display("[FR] OOO pkts: pkt %0d, seq %x, length %0d",
                                     meta_data_r.pktID, meta_data_r.seq, meta_data_r.len);
                            `endif
                            if (fce_data_r.ll_valid == 0) begin
                                ll_load_empty_pointer <= 1;
                                ll_is_newlist <= 1;
                                cycle <= 1;
                            end
                            // Otherwise directly start an insert
                            else begin
                                cycle <= 2;
                                ll_is_newlist <= 0;
                                ll_pointer <= fce_data_r.pointer;
                            end
                        end
                        // Get the valid pointer from linked-list
                        8'd1: begin
                            ll_load_empty_pointer <= 0;
                            if (ll_empty_pointer_valid) begin
                                // Set the ll_valid
                                scheduler_wrch_update_fce.pointer <= ll_empty_pointer;
                                scheduler_wrch_update_fce.ll_valid <= 1'b1;
                                ll_pointer <= ll_empty_pointer;

                                cycle <= 2;
                            end
                        end
                        // Start an insert
                        8'd2: begin
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
                            scheduler_wrch_wren <= 0;

                            // "ll_update_p_valid" is raised at the same cycle with "ll_done"
                            if (ll_update_p_valid) begin
                                scheduler_wrch_update_fce.pointer <= ll_update_p;
                            end
                            if (ll_done) begin
                                cycle <= 0;
                                done <= 1;

                                // Always write-back updates
                                scheduler_wrch_wren <= 1;
                                state <= WAIT_WR_READY;

                                if (ll_discard) begin
                                    `ifdef DEBUG
                                    $display("[FR] discard pkts: pkt %0d, seq %x, length %0d",
                                             meta_data_r.pktID, meta_data_r.seq, meta_data_r.len);
                                    `endif
                                    reorder_valid <= 1;
                                    reorder_meta <= meta_data_r;
                                    scheduler_wrch_rel_pkt_cnt <= 1;
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
                    done <= 1;
                    state <= WAIT_WR_READY;
                    scheduler_wrch_wren <= 1;
                    scheduler_wrch_rel_pkt_cnt <= 1;

                    reorder_valid <= 1;
                    reorder_meta <= meta_data_r;
                    reorder_meta.pkt_flags <= PKT_DROP;

                    `ifdef DEBUG
                    $display("[FR] Overlap pkts, pkt %0d, seq %x, length %0d",
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
                scheduler_rdch_rden <= 0;
                reorder_meta <= meta_data_r;

                // Keep wren and the data until it is accepted
                if (scheduler_wrch_ready) begin
                    scheduler_wrch_wren <= 0;
                    state <= IDLE;
                end
            end
            default: state <= IDLE;
        endcase

        /**
         * Garbage-collection (GC) FSM.
         */
        gc_req_fifo_rdreq <= 0;
        gc_rsp_fifo_wrreq <= 0;
        case (gc_fsm_state)
            GC_FSM_STATE_IDLE: begin
                gc_req <= 0;
                ll_gc_pointer <= 0;
                ll_gc_entry_r <= 0;
                gc_cur_ll_release_cnt_r <= 0;
                gc_fsm_state <= GC_FSM_STATE_IDLE;

                if (!gc_req_fifo_empty &&
                    !reorder_almost_full) begin
                    gc_req_fifo_rdreq <= 1;
                    gc_req <= gc_req_fifo_q;

                    if (gc_req_fifo_q.ll_valid) begin
                        gc_fsm_state <= GC_FSM_STATE_RD;
                        ll_gc_pointer <= gc_req_fifo_q.pointer;

                        `ifdef DEBUG
                        $display("[FR, GC] Started dropping OOO flow ID %0d, valid LL",
                                 gc_req_fifo_q.meta.ooo_flow_id);
                        `endif
                    end
                    else begin
                        gc_fsm_state <= GC_FSM_STATE_DONE;
                        `ifdef DEBUG
                        $display("[FR, GC] Dropping OOO flow ID %0d, invalid LL",
                                 gc_req_fifo_q.meta.ooo_flow_id);
                        `endif
                    end
                end
            end
            GC_FSM_STATE_RD: begin
                gc_fsm_state <= GC_FSM_STATE_RD;

                if (ll_gc_ready) begin
                    gc_fsm_state <= GC_FSM_STATE_RD_WAIT;
                end
            end
            GC_FSM_STATE_RD_WAIT: begin
                gc_fsm_state <= GC_FSM_STATE_RD_WAIT;
                if (ll_gc_done) begin
                    ll_gc_entry_r <= ll_gc_entry;
                    gc_fsm_state <= GC_FSM_STATE_RELEASE;
                end
            end
            GC_FSM_STATE_RELEASE: begin
                gc_fsm_state <= GC_FSM_STATE_RELEASE;
                if (!reorder_enque_busy) begin
                    reorder_valid <= 1;
                    reorder_meta.pkt_flags <= PKT_DROP;
                    reorder_meta.seq <= ll_gc_entry_r.seq;
                    reorder_meta.len <= ll_gc_entry_r.len;
                    reorder_meta.pktID <= ll_gc_entry_r.pktID;
                    reorder_meta.flits <= ll_gc_entry_r.flits;
                    reorder_meta.last_7_bytes <= ll_gc_entry_r.last_7_bytes;
                    gc_cur_ll_release_cnt_r <= (gc_cur_ll_release_cnt_r + 1);

                    if (!ll_gc_entry_r.last) begin
                        gc_fsm_state <= GC_FSM_STATE_RD;
                        ll_gc_pointer <= ll_gc_entry_r.next;
                    end
                    else begin
                        gc_fsm_state <= GC_FSM_STATE_DONE;
                    end
                end
            end
            GC_FSM_STATE_DONE: begin
                gc_fsm_state <= GC_FSM_STATE_DONE;
                if (!gc_rsp_fifo_full) begin
                    gc_rsp_fifo_wrreq <= 1;
                    gc_rsp_fifo_data <= gc_req.meta;
                    gc_fsm_state <= GC_FSM_STATE_IDLE;

                    `ifdef DEBUG
                    $display("[FR, GC] Done dropping OOO flow ID %0d with %0d LL packets",
                             gc_req.meta.ooo_flow_id, gc_cur_ll_release_cnt_r);
                    `endif
                end
            end
            default: begin
                gc_fsm_state <= GC_FSM_STATE_IDLE;
            end
        endcase
    end
end

linked_list ll_inst(
    .clk                (clk),
    .rst                (rst),
    .start              (ll_start),
    .done               (ll_done),
    .discard            (ll_discard),
    .is_newlist         (ll_is_newlist),
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
    .empty_pointer_valid(ll_empty_pointer_valid),
    .gc_ready           (ll_gc_ready),
    .gc_start           (ll_gc_start),
    .gc_pointer         (ll_gc_pointer),
    .gc_entry           (ll_gc_entry),
    .gc_done            (ll_gc_done),
    .gc_fl_fill_level   (gc_fl_fill_level)
);

endmodule
