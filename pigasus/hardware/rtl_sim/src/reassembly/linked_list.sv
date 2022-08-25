`include "./src/struct_s.sv"
// `define DEBUG

module linked_list(
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   start,
    output  logic                   done,
    output  logic                   discard,
    input   logic                   is_newlist,
    input   logic [LL_AWIDTH-1:0]   pointer,
    input   logic [PKT_AWIDTH-1:0]  pktID,
    input   logic [4:0]             flits,
    input   logic [31:0]            seq,
    input   logic [15:0]            len,
    input   logic [55:0]            last_7_bytes,
    output  logic [LL_AWIDTH-1:0]   update_p,
    output  logic                   update_p_valid,
    input   logic                   load_head,
    output  entry_t                 head_out,
    output  logic                   head_out_valid,
    input   logic                   store_head,
    input   entry_t                 head_in,
    input   logic [LL_AWIDTH-1:0]   head_wr_addr,
    input   logic                   load_empty_pointer,
    output  logic [LL_AWIDTH-1:0]   empty_pointer,
    output  logic                   empty_pointer_valid,
    // Garbage collection
    output  logic                   gc_ready,
    input   logic                   gc_start,
    input   logic [LL_AWIDTH-1:0]   gc_pointer,
    output  entry_t                 gc_entry,
    output  logic                   gc_done,
    output  logic [31:0]            gc_fl_fill_level
);

typedef enum {
    INIT,
    IDLE,
    READ,
    READ_VALID,
    COMPARE
} state_t;
state_t state;

entry_t entry;
entry_t prev_entry;
entry_t empty_entry;

entry_t                 ll_wr_data;
entry_t                 ll_rd_data;
logic [LL_AWIDTH-1:0]   ll_wr_addr;
logic [LL_AWIDTH-1:0]   ll_rd_addr;
logic                   ll_rd;
logic                   ll_rd_valid;
logic                   ll_rd_r1;
logic                   ll_wr;

logic [LL_AWIDTH-1:0]   addr;
logic [LL_AWIDTH-1:0]   prev_addr;
logic [31:0]            start_p;
logic [31:0]            end_p;
logic                   first;
logic [LL_AWIDTH-1:0]   next_empty;

logic                   init_start;
logic                   init_done;
logic [LL_AWIDTH-1:0]   init_addr;

logic [7:0]             cycle;

logic                   emptylist_in_ready;
logic                   emptylist_in_valid;
logic [LL_AWIDTH-1:0]   emptylist_in_data;
logic                   emptylist_out_ready;
logic                   emptylist_out_valid;
logic [LL_AWIDTH-1:0]   emptylist_out_data;
logic                   emptylist_enque_busy;

assign empty_entry = 0;

// Port A
logic [LL_AWIDTH-1:0] ll_addr;
assign ll_addr = ll_wr ? ll_wr_addr : ll_rd_addr;

// Port B
entry_t                 gc_rd_data;
logic [LL_AWIDTH-1:0]   gc_rd_addr;
logic                   gc_rd;
logic                   gc_rd_valid;
logic                   gc_rd_r1;

// GC logic
assign emptylist_enque_busy = ((state == INIT) ||
                               ((state == IDLE) && store_head));

assign gc_ready = (!emptylist_enque_busy && emptylist_in_ready);
assign gc_entry = gc_rd_data;
assign gc_done = gc_rd_valid;

// Assume no repeat, no overlapping, no merging
always @ (posedge clk) begin
    if (rst) begin
        state               <= INIT;
        done                <= 0;
        entry               <= empty_entry;
        prev_entry          <= empty_entry;
        head_out_valid      <= 0;
        update_p_valid      <= 0;
        init_start          <= 0;
        addr                <= 0;
        prev_addr           <= 0;
        start_p             <= 0;
        end_p               <= 0;
        cycle               <= 0;
        ll_wr               <= 0;
        ll_rd               <= 0;
        discard             <= 1'b0;

        gc_rd_addr          <= 0;
        gc_rd               <= 0;

        emptylist_in_data   <= 0;
        emptylist_in_valid  <= 0;
        emptylist_out_ready <= 0;
    end
    else begin
        emptylist_out_ready <= 1'b0;
        assert(!(!emptylist_out_valid & emptylist_out_ready))
        else begin
            $error("Request from empty LL_emptylsit");
            $finish;
        end
        assert(!(!emptylist_in_ready & emptylist_in_valid))
        else begin
            $error("Insert to full LL_emptylsit");
            $finish;
        end
        assert (!(ll_wr && ll_rd))
        else begin
            $error("Cannot perform simultaneous LL read/write");
            $finish;
        end
        assert (!((ll_wr || ll_rd) && gc_rd && (ll_addr == gc_rd_addr)))
        else begin
            $error("LL and GC accesses should never collide");
            $finish;
        end

        emptylist_in_valid <= 1'b0;
        case (state)
            INIT: begin
                emptylist_in_valid <= 1'b1;
                if (emptylist_in_valid & emptylist_in_ready) begin
                    emptylist_in_data <= emptylist_in_data + 1'b1;
                    if (emptylist_in_data == {LL_AWIDTH{1'b1}}) begin
                        state <= IDLE;
                        emptylist_in_valid <= 1'b0;
                        $display("[LL] Finish LL emptylist init");
                    end
                end
            end
            IDLE: begin
                // Initialize states
                cycle <= 0;
                done <= 0;
                entry <= empty_entry;
                prev_entry <= empty_entry;
                update_p_valid <= 0;
                first <= 1;
                prev_addr <= 0;
                discard <= 0;

                if (start) begin
                    state <= READ;
                    addr <= pointer;
                    start_p <= seq;
                    end_p <= seq + len - 1;
                end

                // Check the head node seq number
                if(load_head)begin
                    ll_rd <= 1;
                    ll_rd_addr <= pointer;
                end
                else begin
                    ll_rd <= 0;
                end

                ll_wr <= 0;
                if (store_head) begin
                    emptylist_in_valid <= 1'b1;
                    emptylist_in_data <= head_wr_addr;
                end

                if (ll_rd_valid) begin
                    head_out_valid <= 1;
                    head_out <= ll_rd_data;
                end
                else begin
                    head_out_valid <= 0;
                end

                if (load_empty_pointer) begin
                    empty_pointer <= emptylist_out_data;
                    emptylist_out_ready <= 1'b1;
                    empty_pointer_valid <= 1;
                end
                else begin
                    empty_pointer_valid <= 0;
                end
            end
            READ: begin
                ll_wr <= 0;
                ll_rd <= 1;
                ll_rd_addr <= addr;
                state <= READ_VALID;
            end
            READ_VALID: begin
                ll_rd <= 0;
                if (ll_rd_valid) begin
                    entry <= ll_rd_data;
                    state <= COMPARE;
                end
            end
            COMPARE: begin
                if (is_newlist) begin
                    `ifdef DEBUG
                    $display("[LL] Insert to empty list");
                    `endif

                    ll_wr <= 1;
                    ll_wr_addr <= addr;
                    ll_wr_data <= '{1, seq, len, 0, pktID,
                                    flits, 1, last_7_bytes};

                    done <= 1;
                    state <= IDLE;
                end
                else if (entry.valid) begin
                    // Check whether the new node should be
                    // inserted in front of the current one.
                    if (end_p < entry.seq) begin
                        // Insert in front of the first node of the list
                        if (first) begin
                            `ifdef DEBUG
                            $display("[LL] Insert in front \n");
                            `endif

                            //list_table[next_empty] <= '{1,seq,len,addr,pktID,0};
                            ll_wr <= 1;
                            ll_wr_addr <= emptylist_out_data;
                            ll_wr_data <= '{1, seq, len, addr, pktID, flits, 0, last_7_bytes};

                            update_p_valid <= 1;
                            update_p <= emptylist_out_data;

                            emptylist_out_ready <= 1'b1;
                            state <= IDLE;
                            done <= 1;
                        end
                        // Insert in between of two nodes
                        else begin
                            case (cycle)
                                // Update prev node, read the data from the table
                                8'd0: begin
                                    ll_wr <= 0;
                                    ll_rd <= 1;
                                    ll_rd_addr <= prev_addr;

                                    cycle <= cycle + 1;
                                end
                                8'd1: begin
                                    ll_rd <= 0;
                                    if (ll_rd_valid) begin
                                        prev_entry <= ll_rd_data;
                                        cycle <= cycle + 1;
                                    end
                                end
                                // Update prev node
                                8'd2: begin
                                    ll_wr <= 1;
                                    ll_wr_addr <= prev_addr;
                                    ll_wr_data <= '{prev_entry.valid, prev_entry.seq,
                                                    prev_entry.len, emptylist_out_data,
                                                    prev_entry.pktID, prev_entry.flits,
                                                    prev_entry.last, prev_entry.last_7_bytes};

                                    cycle <= cycle + 1;
                                end
                                // Insert new node
                                8'd3: begin
                                    `ifdef DEBUG
                                    $display("[LL] Insert in between\n");
                                    `endif

                                    ll_wr <= 1;
                                    ll_wr_addr <= emptylist_out_data;
                                    ll_wr_data <= '{1, seq, len, addr, pktID,
                                                    flits, 0, last_7_bytes};

                                    emptylist_out_ready <= 1'b1;
                                    state <= IDLE;
                                    cycle <= 0;
                                    done <= 1;
                                end
                                default: cycle <= 0;
                            endcase
                       end
                    end
                    // Check whether the new node should be
                    // inserted after the current node.
                    else if (start_p > (entry.seq + entry.len - 1)) begin

                        // If this is the last node, insert
                        // it after the current last tail.
                        if (entry.last) begin
                             case (cycle)
                                // Update the current node
                                8'd0: begin
                                    ll_wr <= 1;
                                    ll_wr_addr <= addr;
                                    ll_wr_data <= '{entry.valid, entry.seq, entry.len,
                                                    emptylist_out_data, entry.pktID,
                                                    entry.flits, 0, entry.last_7_bytes};

                                    cycle <= cycle + 1;
                                end
                                // Insert new node to the end of the list
                                8'd1: begin
                                    `ifdef DEBUG
                                    $display("[LL] Insert in the end \n");
                                    `endif

                                    ll_wr <= 1;
                                    ll_wr_addr <= emptylist_out_data;
                                    ll_wr_data <= '{1'b1, seq, len, 0, pktID,
                                                    flits, 1'b1, last_7_bytes};

                                    emptylist_out_ready <= 1'b1;
                                    state <= IDLE;
                                    cycle <= 0;
                                    done <= 1;
                                end
                                default: cycle <= 0;
                            endcase
                        end
                        // Pass the check of current node, check the next one
                        else begin
                            `ifdef DEBUG
                            $display("[LL] Pass this\n");
                            `endif

                            addr <= entry.next;
                            prev_addr <= addr;
                            state <= READ;
                            first <= 0;
                        end
                    end
                    else begin
                        `ifdef DEBUG
                        $display("[LL] Overlap with node in LL");
                        `endif

                        done <= 1;
                        state <= IDLE;
                        discard <= 1'b1;
                    end
                end
                else begin
                    $display("[LL] Error: LL is not empty, but entry is invalid");
                    $finish;
                end
            end
            default: begin
                $display("[LL] Error state!");
                $finish;
            end
        endcase

        /**
         * Garbage-collection (GC) logic.
         */
        gc_rd <= 0;
        gc_rd_addr <= 0;
        if (gc_start && gc_ready) begin
            gc_rd_addr <= gc_pointer;
            gc_rd <= 1;

            emptylist_in_data <= gc_pointer;
            emptylist_in_valid <= 1'b1;
        end
    end
end

// On-chip RAM read latency is two cycle
always @(posedge clk) begin
    ll_rd_r1 <= ll_rd;
    ll_rd_valid <= ll_rd_r1;

    gc_rd_r1 <= gc_rd;
    gc_rd_valid <= gc_rd_r1;
end

bram_true2port #(
    .AWIDTH(LL_AWIDTH),
    .DWIDTH(LL_DWIDTH),
    .DEPTH(LL_DEPTH)
)
linked_list_mem (
    .address_a(ll_addr),
    .address_b(gc_rd_addr),
    .clock(clk),
    .data_a(ll_wr_data),
    .data_b({LL_DWIDTH{1'b0}}), // GC writes disabled
    .rden_a(ll_rd),
    .rden_b(gc_rd),
    .wren_a(ll_wr),
    .wren_b(1'b0), // GC writes disabled
    .q_a(ll_rd_data),
    .q_b(gc_rd_data)
);

unified_fifo  #(
    .FIFO_NAME        ("[linked_list] l1_emptylist_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),//does not matter
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (LL_AWIDTH),
    .FIFO_DEPTH       (LL_DEPTH)
)
ll_emptylist (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (emptylist_in_data),
    .in_valid          (emptylist_in_valid),
    .in_ready          (emptylist_in_ready),
    .out_data          (emptylist_out_data),
    .out_valid         (emptylist_out_valid),
    .out_ready         (emptylist_out_ready),
    .fill_level        (gc_fl_fill_level),
    .almost_full       (),//not used
    .overflow          ()
);
endmodule
