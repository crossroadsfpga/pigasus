`include "./src/struct_s.sv"
//`define DEBUG
module flow_table_wrapper(
    input   logic           clk,
    input   logic           rst,
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    output  logic           in_meta_ready,
    output  metadata_t      out_meta_data,
    output  logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,
    output  metadata_t      forward_meta_data,
    output  logic           forward_meta_valid,
    input   logic           forward_meta_ready,
    output  metadata_t      reorder_meta_data,
    output  logic           reorder_meta_valid,
    input   logic           reorder_meta_ready,
    input   logic           reorder_meta_almost_full
);

tuple_t         h0_tuple_in;
logic           h0_tuple_in_valid;
logic [31:0]    h0_initval;
logic [31:0]    h0_hashed;
logic           h0_hashed_valid;

tuple_t         h1_tuple_in;
logic           h1_tuple_in_valid;
logic [31:0]    h1_initval;
logic [31:0]    h1_hashed;
logic           h1_hashed_valid;

tuple_t         h2_tuple_in;
logic           h2_tuple_in_valid;
logic [31:0]    h2_initval;
logic [31:0]    h2_hashed;
logic           h2_hashed_valid;

tuple_t         h3_tuple_in;
logic           h3_tuple_in_valid;
logic [31:0]    h3_initval;
logic [31:0]    h3_hashed;
logic           h3_hashed_valid;

// Read channel 0
fce_meta_t              ch0_meta;
logic                   ch0_rden;
fce_t                   ch0_q;
logic                   ch0_rd_valid;
logic [FT_SUBTABLE:0]   ch0_bit_map;
logic                   ch0_rd_stall;

// Write channel 1
logic [2:0]             ch1_opcode;
logic [FT_SUBTABLE:0]   ch1_bit_map;
logic                   ch1_wren;
fce_t                   ch1_data;
logic                   ch1_insert_stall;

// Read channel 2
fce_meta_t              ch2_meta;
logic                   ch2_rden;
logic                   ch2_ready;
fce_t                   ch2_q;
logic                   ch2_rd_valid;

// Write channel 3
logic [2:0]             ch3_opcode;
logic                   ch3_wren;
logic                   ch3_ready;
fce_t                   ch3_data;
logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt;

fce_meta_t              ch0_meta_r1;
fce_meta_t              ch0_meta_r2;
fce_meta_t              ch0_meta_r3;

metadata_t m0;
metadata_t m1;
metadata_t m2;
metadata_t m3;
metadata_t m4;
metadata_t m5;
metadata_t m6;
metadata_t m7;
metadata_t m8;
metadata_t m9;
metadata_t m10;

metadata_t meta_r;

// Signal for forwarding
logic f_pkt; // Not-forward pkt;
logic ack_pkt; // Not-forward pkt;
logic udp_pkt; // Not-forward pkt;

logic stall;

// Slow path
metadata_t      ooo_meta_data;
logic           ooo_meta_valid;
logic           ooo_meta_ready;
metadata_t      r_meta_data;
logic           r_meta_valid;
logic           r_meta_ready;
fce_t           ooo_fce_data;
logic           ooo_fce_valid;
logic           ooo_fce_ready;
fce_t           r_fce_data;
logic           r_fce_valid;
logic           r_fce_ready;
logic [31:0]    meta_csr_readdata;
logic [31:0]    ooo_csr_readdata;
logic           ooo_almost_full;

///////// Forward pkts /////////////////////////
// Packets which are either ACK (0 length) OR
// UDP can be forwarded without touching the HT.
always @(*) begin
    ack_pkt             = (in_meta_data.tcp_flags == (1'b1 << TCP_FACK)) & (in_meta_data.len == 0);
    udp_pkt             = (in_meta_data.prot == PROT_UDP);
    f_pkt               = ack_pkt | udp_pkt;
    forward_meta_valid  = in_meta_valid & f_pkt;
    forward_meta_data   = in_meta_data;

    forward_meta_data.pkt_flags = PKT_FORWARD;
    if (udp_pkt) begin
        forward_meta_data.pkt_flags = PKT_CHECK;
    end
end

// Back-pressure logic:
// - If f_pkt, short circuit input with forward
// - Else, input is ready when neither the inorder/OOO
//   queue are almost full and when there is no stall.
assign in_meta_ready = f_pkt ? forward_meta_ready :
                       ((!out_meta_almost_full & !ooo_almost_full) & !stall);

// Lookup
assign ch0_rden = h0_hashed_valid;
assign ch0_meta.addr0 = h0_hashed;
assign ch0_meta.addr1 = h1_hashed;
assign ch0_meta.addr2 = h2_hashed;
assign ch0_meta.addr3 = h3_hashed;
assign ch0_meta.tuple = m7.tuple;
assign ch0_meta.opcode = 0; // NOP

// Two cycle delay
always @(posedge clk) begin
    ch0_meta_r1 <= ch0_meta;
    ch0_meta_r2 <= ch0_meta_r1;
    ch0_meta_r3 <= ch0_meta_r2;
end

always @(posedge clk) begin
    if (rst) begin
        ch1_opcode      <= 0;
        ch1_bit_map     <= 0;
        ch1_wren        <= 0;
        ch1_data        <= 0;
        out_meta_valid  <= 0;
        ooo_meta_valid  <= 0;
        ooo_fce_valid   <= 0;
    end
    // Stall the pipeline if inserting to full para_q
    else if (!ch1_insert_stall) begin
        // Default value
        ch1_wren <= 0;
        ch1_bit_map <= ch0_bit_map;
        ch1_data <= ch0_q;

        out_meta_valid <= 0;
        out_meta_data <= m10;
        if (m10.len != 0) begin
            out_meta_data.pkt_flags <= PKT_CHECK;
        end
        else begin
            out_meta_data.pkt_flags <= PKT_FORWARD;
        end

        ooo_meta_valid <= 0;
        ooo_meta_data <= m10;
        ooo_meta_data.pkt_flags <= PKT_CHECK;

        ooo_fce_valid <= 0;
        ooo_fce_data <= ch0_q;
        if (ch0_rd_valid) begin
            // Hit, update or push to slow path
            // Check in string matcher if it has payload.
            if (ch0_bit_map != 0) begin
                ch1_data.valid <= 1;
                ch1_opcode <= FT_UPDATE;
                // Inorder and no LL_node, forward the pkt
                if (m10.seq == ch0_q.seq) begin
                    `ifdef DEBUG
                    $display("Inorder : pkt %d, seq %x, length %d, expect %x, slow_cnt %d",
                             m10.pktID, m10.seq, m10.len, ch0_q.seq, ch0_q.slow_cnt);
                    `endif

                    ch1_wren <= 1;
                    // Slow Path has packets, update cnt
                    if (ch0_q.slow_cnt > 0) begin
                        `ifdef DEBUG
                        $display("Check LL");
                        `endif

                        ch1_data.slow_cnt <= ch0_q.slow_cnt + 1;
                        out_meta_valid <= 0;
                        ooo_meta_valid <= 1;
                        ooo_fce_valid <= 1;
                    end
                    // Inorder packets, with no OOO node in
                    // the LL. Update seq. Most common case.
                    else begin
                        ch1_data.seq   <= m10.seq + m10.len;
                        out_meta_valid <= 1;
                        // Delete the fce, forward the pkt
                        if (m10.tcp_flags[TCP_FIN] | m10.tcp_flags[TCP_RST]) begin
                            `ifdef DEBUG
                            $display("FIN/RST : pkt %d, seq %x, length %d, expect %x",
                                     m10.pktID, m10.seq, m10.len, ch0_q.seq);
                            `endif

                            ch1_data.valid <= 0;
                            ch1_opcode <= FT_DELETE;
                        end
                    end
                end
                // If incoming seq is bigger than expected, push to slow path
                else if (m10.seq > ch0_q.seq) begin
                    `ifdef DEBUG
                    $display("OOO : pkt %d, seq %x, length %d, expect %x, slow_cnt %d",
                             m10.pktID, m10.seq, m10.len, ch0_q.seq, ch0_q.slow_cnt);
                    `endif

                    // Update the slow_cnt
                    ch1_wren <= 1;
                    // Keep the old seq number, only update the slow_cnt
                    ch1_data.slow_cnt <= ch0_q.slow_cnt + 1;
                    ch1_data.seq <= ch0_q.seq;
                    ooo_meta_valid <= 1;
                    ooo_fce_valid <= 1;
                end
                // The incoming seq is smaller than expected (overlapping bytes).
                // Current policy drops these packet, without changing the FCE.
                else begin
                    out_meta_valid <= 1;
                    out_meta_data.pkt_flags <= PKT_DROP;

                    `ifdef DEBUG
                    $display("Overlap : pkt %d, seq %x, length %d, expect %x",
                             m10.pktID, m10.seq, m10.len, ch0_q.seq);
                    `endif
                end
            end
            // Miss, insert
            else begin
                // Insert to para_q, which is bit[4]
                ch1_opcode          <= FT_INSERT;
                ch1_bit_map         <= 5'b1_0000;
                ch1_data.valid      <= 1;
                ch1_data.tuple      <= m10.tuple;
                ch1_data.pointer    <= 0;
                ch1_data.ll_valid   <= 0;
                ch1_data.slow_cnt   <= 0;
                ch1_data.addr0      <= ch0_meta_r3.addr0;
                ch1_data.addr1      <= ch0_meta_r3.addr1;
                ch1_data.addr2      <= ch0_meta_r3.addr2;
                ch1_data.addr3      <= ch0_meta_r3.addr3;

                // SYN's expected seq is special
                if (m10.tcp_flags[TCP_SYN]) begin
                    ch1_data.seq <= m10.seq + 1;
                    ch1_data.last_7_bytes <= {56{1'b1}};
                end
                else begin
                    ch1_data.seq <= m10.seq + m10.len;
                    ch1_data.last_7_bytes <= m10.last_7_bytes;
                end

                // Insert only when necessary
                if (m10.tcp_flags[TCP_FIN] | m10.tcp_flags[TCP_RST]) begin
                    ch1_wren <= 0;
                end
                else begin
                    ch1_wren <= 1;
                end
                `ifdef DEBUG
                $display("Insert : pkt %d, seq %x, length %d, expect %x, slow_cnt %d",
                   m10.pktID, m10.seq, m10.len, ch0_q.seq, ch0_q.slow_cnt);
                `endif

                out_meta_valid <= 1;
            end
        end
    end
end

assign stall = ch0_rd_stall | ch1_insert_stall;

always @(posedge clk) begin
    // Match up with the hashtable delay. The
    // stall signal also stalls this pipeline.
    if (!stall) begin
        m0 <= in_meta_data;
        m1 <= m0;
        m2 <= m1;
        m3 <= m2;
        m4 <= m3;
        m5 <= m4;
        m6 <= m5;
        m7 <= m6;
    end
    // Match up the three cycle read delay (no stall)
    m8 <= m7;
    m9 <= m8;
    m10 <= m9;
end

assign h0_tuple_in = in_meta_data.tuple;
assign h1_tuple_in = in_meta_data.tuple;
assign h2_tuple_in = in_meta_data.tuple;
assign h3_tuple_in = in_meta_data.tuple;

assign h0_initval = 32'd0;
assign h1_initval = 32'd1;
assign h2_initval = 32'd2;
assign h3_initval = 32'd3;

// Only accept when the pkt is dequed and the pkt is not f_pkt
assign h0_tuple_in_valid = in_meta_valid & in_meta_ready & !f_pkt;
assign h1_tuple_in_valid = in_meta_valid & in_meta_ready & !f_pkt;
assign h2_tuple_in_valid = in_meta_valid & in_meta_ready & !f_pkt;
assign h3_tuple_in_valid = in_meta_valid & in_meta_ready & !f_pkt;

// Stall when: (a) a fast rd/wr happens on the
// same cycle, or (b) inserting to full para_Q.
assign h0_stall = stall;
assign h1_stall = stall;
assign h2_stall = stall;
assign h3_stall = stall;

hash_func hash0 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h0_stall),
    .tuple_in       (h0_tuple_in),
    .initval        (h0_initval),
    .tuple_in_valid (h0_tuple_in_valid),
    .hashed         (h0_hashed),
    .hashed_valid   (h0_hashed_valid)
);
hash_func hash1 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h1_stall),
    .tuple_in       (h1_tuple_in),
    .initval        (h1_initval),
    .tuple_in_valid (h1_tuple_in_valid),
    .hashed         (h1_hashed),
    .hashed_valid   (h1_hashed_valid)
);
hash_func hash2 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h2_stall),
    .tuple_in       (h2_tuple_in),
    .initval        (h2_initval),
    .tuple_in_valid (h2_tuple_in_valid),
    .hashed         (h2_hashed),
    .hashed_valid   (h2_hashed_valid)
);
hash_func hash3 (
    .clk            (clk),
    .rst            (rst),
    .stall          (h3_stall),
    .tuple_in       (h3_tuple_in),
    .initval        (h3_initval),
    .tuple_in_valid (h3_tuple_in_valid),
    .hashed         (h3_hashed),
    .hashed_valid   (h3_hashed_valid)
);

flow_table flow_table_inst (
    .clk          (clk),
    .rst          (rst),
    .ch0_meta     (ch0_meta),
    .ch0_rden     (ch0_rden),
    .ch0_q        (ch0_q),
    .ch0_rd_valid (ch0_rd_valid),
    .ch0_bit_map  (ch0_bit_map),
    .ch0_rd_stall (ch0_rd_stall),
    .ch1_opcode   (ch1_opcode),
    .ch1_bit_map  (ch1_bit_map),
    .ch1_wren     (ch1_wren),
    .ch1_data     (ch1_data),
    .ch1_insert_stall (ch1_insert_stall),
    .ch2_meta     (ch2_meta),
    .ch2_rden     (ch2_rden),
    .ch2_ready    (ch2_ready),
    .ch2_q        (ch2_q),
    .ch2_rd_valid (ch2_rd_valid),
    .ch3_opcode   (ch3_opcode),
    .ch3_wren     (ch3_wren),
    .ch3_ready    (ch3_ready),
    .ch3_data     (ch3_data),
    .ch3_rel_pkt_cnt     (ch3_rel_pkt_cnt)
);

unified_fifo  #(
    .FIFO_NAME        ("[flow_table_wrapper] ooo_meta_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (480),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (META_WIDTH),
    .FIFO_DEPTH       (512)
) ooo_meta_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (ooo_meta_data),
    .in_valid          (ooo_meta_valid),
    .in_ready          (ooo_meta_ready),
    .out_data          (r_meta_data),
    .out_valid         (r_meta_valid),
    .out_ready         (r_meta_ready),
    .fill_level        (),
    .almost_full       (),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[flow_table_wrapper] ooo_fce_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (480),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (FT_DWIDTH),
    .FIFO_DEPTH       (512)
) ooo_fce_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (ooo_fce_data),
    .in_valid          (ooo_fce_valid),
    .in_ready          (ooo_fce_ready),
    .out_data          (r_fce_data),
    .out_valid         (r_fce_valid),
    .out_ready         (r_fce_ready),
    .fill_level        (ooo_csr_readdata),
    .almost_full       (ooo_almost_full),
    .overflow          ()
);

flow_reassembly flow_reassembly_inst (
    .clk               (clk),
    .rst               (rst),
    .meta_data         (r_meta_data),
    .meta_valid        (r_meta_valid),
    .meta_ready        (r_meta_ready),
    .fce_data          (r_fce_data),
    .fce_valid         (r_fce_valid),
    .fce_ready         (r_fce_ready),
    .ch2_meta          (ch2_meta),
    .ch2_rden          (ch2_rden),
    .ch2_ready         (ch2_ready),
    .ch2_q             (ch2_q),
    .ch2_rd_valid      (ch2_rd_valid),
    .ch3_opcode        (ch3_opcode),
    .ch3_wren          (ch3_wren),
    .ch3_ready         (ch3_ready),
    .ch3_data          (ch3_data),
    .ch3_rel_pkt_cnt   (ch3_rel_pkt_cnt),
    .reorder_meta      (reorder_meta_data),
    .reorder_valid     (reorder_meta_valid),
    .reorder_ready     (reorder_meta_ready),
    .reorder_almost_full  (reorder_meta_almost_full)
);

endmodule
