`include "./src/struct_s.sv"

module flow_table(
    input   logic                   clk,
    input   logic                   rst,

    // Read channel 0
    input   fce_meta_t              ch0_meta,
    input   logic                   ch0_rden,
    output  fce_t                   ch0_q,
    output  logic                   ch0_rd_valid,
    output  logic [FT_SUBTABLE:0]   ch0_bit_map,
    output  logic                   ch0_rd_stall,

    // Write channel 1
    input   logic [2:0]             ch1_opcode,
    input   logic [FT_SUBTABLE:0]   ch1_bit_map,
    input   logic                   ch1_wren,
    input   fce_t                   ch1_data,
    output  logic                   ch1_insert_stall,

    // Read channel 2
    input   fce_meta_t              ch2_meta,
    input   logic                   ch2_rden,
    output  logic                   ch2_ready,
    output  fce_t                   ch2_q,
    output  logic                   ch2_rd_valid,

    // Write channel 3
    input   logic [2:0]             ch3_opcode,
    input   logic                   ch3_wren,
    output  logic                   ch3_ready,
    input   fce_t                   ch3_data,
    input   logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt
);

logic [FT_AWIDTH-1:0]   ft0_addr_a;
logic [FT_AWIDTH-1:0]   ft0_addr_b;
fce_t                   ft0_data_a;
fce_t                   ft0_data_b;
logic                   ft0_rden_a;
logic                   ft0_rden_b;
logic                   ft0_wren_a;
logic                   ft0_wren_b;
fce_t                   ft0_q_a;
fce_t                   ft0_q_b;
fce_t                   ft0_odata_a;
fce_t                   ft0_odata_b;
fce_t                   ft0_data_a_r1;
fce_t                   ft0_data_a_r2;
fce_t                   ft0_data_b_r1;
fce_t                   ft0_data_b_r2;
logic                   rdw0_a;
logic                   rdw0_a_r1;
logic                   rdw0_a_r2;
logic                   rdw0_b;
logic                   rdw0_b_r1;
logic                   rdw0_b_r2;
fce_t                   ft0_q_b_r;

logic [FT_AWIDTH-1:0]   ft1_addr_a;
logic [FT_AWIDTH-1:0]   ft1_addr_b;
fce_t                   ft1_data_a;
fce_t                   ft1_data_b;
logic                   ft1_rden_a;
logic                   ft1_rden_b;
logic                   ft1_wren_a;
logic                   ft1_wren_b;
fce_t                   ft1_q_a;
fce_t                   ft1_q_b;
fce_t                   ft1_odata_a;
fce_t                   ft1_odata_b;
fce_t                   ft1_data_a_r1;
fce_t                   ft1_data_a_r2;
fce_t                   ft1_data_b_r1;
fce_t                   ft1_data_b_r2;
logic                   rdw1_a;
logic                   rdw1_a_r1;
logic                   rdw1_a_r2;
logic                   rdw1_b;
logic                   rdw1_b_r1;
logic                   rdw1_b_r2;
fce_t                   ft1_q_b_r;

logic [FT_AWIDTH-1:0]   ft2_addr_a;
logic [FT_AWIDTH-1:0]   ft2_addr_b;
fce_t                   ft2_data_a;
fce_t                   ft2_data_b;
logic                   ft2_rden_a;
logic                   ft2_rden_b;
logic                   ft2_wren_a;
logic                   ft2_wren_b;
fce_t                   ft2_q_a;
fce_t                   ft2_q_b;
fce_t                   ft2_odata_a;
fce_t                   ft2_odata_b;
fce_t                   ft2_data_a_r1;
fce_t                   ft2_data_a_r2;
fce_t                   ft2_data_b_r1;
fce_t                   ft2_data_b_r2;
logic                   rdw2_a;
logic                   rdw2_a_r1;
logic                   rdw2_a_r2;
logic                   rdw2_b;
logic                   rdw2_b_r1;
logic                   rdw2_b_r2;
fce_t                   ft2_q_b_r;

logic [FT_AWIDTH-1:0]   ft3_addr_a;
logic [FT_AWIDTH-1:0]   ft3_addr_b;
fce_t                   ft3_data_a;
fce_t                   ft3_data_b;
logic                   ft3_rden_a;
logic                   ft3_rden_b;
logic                   ft3_wren_a;
logic                   ft3_wren_b;
fce_t                   ft3_q_a;
fce_t                   ft3_q_b;
fce_t                   ft3_odata_a;
fce_t                   ft3_odata_b;
fce_t                   ft3_data_a_r1;
fce_t                   ft3_data_a_r2;
fce_t                   ft3_data_b_r1;
fce_t                   ft3_data_b_r2;
logic                   rdw3_a;
logic                   rdw3_a_r1;
logic                   rdw3_a_r2;
logic                   rdw3_b;
logic                   rdw3_b_r1;
logic                   rdw3_b_r2;
fce_t                   ft3_q_b_r;

logic rd_valid_a;
logic rd_valid_a_r;
logic rd_valid_b;
logic rd_valid_b_r;
logic [FT_SUBTABLE:0] ft_hit;
logic [FT_SUBTABLE:0] ft_hit_b;
logic [FT_SUBTABLE-1:0] ft_empty;
logic [FT_SUBTABLE-1:0] ft_empty_r;

// Signal for para_Q
tuple_t      q_addr_a;
fce_t        q_data_a;
logic        q_rden_a;
logic        q_wren_a;
logic        q_rd_valid_a; // 2 cycle delay
logic        q_rd_hit_a;   // Hit in queue?
fce_t        q_q_a;
tuple_t      q_addr_b;
fce_t        q_data_b;
logic        q_rden_b;
logic        q_wren_b;
logic        q_rd_valid_b; // 2 cycle delay
logic        q_rd_hit_b;   // Hit in queue?
fce_t        q_q_b;
logic        q_op_en;
logic        q_op_id; // PQ_OP_FAST_{INSERT, DELETE}
fce_t        q_op_data;
logic        q_op_stall; // While high, keep op_en high
logic        q_deque_en;
fce_t        q_deque_data;
logic        q_deque_done; // Raised when deque completes
logic [7:0]  q_error;
logic        q_is_error_fatal;
logic        q_full;
logic        q_empty;
logic        q_debug;

logic        q_deque_en_r;
logic        q_deque_done_r;
logic        q_rd_valid_a_r;
logic        q_rd_hit_a_r1;
logic        q_rd_hit_a_r2;
fce_t        q_q_a_r;
logic        q_rd_valid_b_r;
logic        q_rd_hit_b_r1;
logic        q_rd_hit_b_r2;
fce_t        q_q_b_r;

fce_t        q_odata_a;
fce_t        q_odata_b;
fce_t        q_data_b_r1;
fce_t        q_data_b_r2;
fce_t        q_data_a_r1;
fce_t        q_data_a_r2;
logic        rdwq_a;
logic        rdwq_a_r1;
logic        rdwq_a_r2;
logic        rdwq_b;
logic        rdwq_b_r1;
logic        rdwq_b_r2;
logic        q_empty_r;
logic        q_rden_a_r1;

typedef enum {
    P_ARB,
    P_LOOKUP,
    P_FILL,
    P_EVIC,
    SLOW_UPDATE,
    SLOW_UPDATE_WAIT,
    SLOW_LOOKUP_WAIT,
    SLOW_LOOKUP
} place_t;
place_t p_state;

logic [3:0]  req;
logic [3:0]  grant;
tuple_t      lookup_tuple;
tuple_t      lookup_tuple_r1;
tuple_t      lookup_tuple_r2;
tuple_t      lookup_tuple_b;
tuple_t      lookup_tuple_b_r1;
tuple_t      lookup_tuple_b_r2;

logic        head_busy;
logic        slow_busy;
logic        slow_conflict;
logic        fast_busy;
logic        insert;
logic        evict;
fce_t        evict_data;
logic [1:0]  random;

logic [FT_SUBTABLE:0]   ch0_bit_map_int;
tuple_t                 ch0_tuple_r1;
tuple_t                 ch0_tuple_latch;
tuple_t                 ch0_tuple_latch_r;
tuple_t                 ch0_tuple_r3;
logic                   ch0_rden_r1;
logic                   ch0_rden_r2;
logic                   ch0_rden_r3;
fce_t                   ch1_data_r1;
fce_t                   ch1_data_r2;
logic [FT_SUBTABLE:0]   ch2_bit_map;
fce_t                   ch3_data_r;
logic [PKT_AWIDTH-1:0]  ch3_rel_pkt_cnt_r;

///////// Lookup operation /////////////////////////
assign ft0_rden_a = ch0_rden & !ch0_rd_stall;
assign ft1_rden_a = ch0_rden & !ch0_rd_stall;
assign ft2_rden_a = ch0_rden & !ch0_rd_stall;
assign ft3_rden_a = ch0_rden & !ch0_rd_stall;
assign q_rden_a   = ch0_rden & !ch0_rd_stall;

// ch1 and ch0 use the same BRAM port. wr has higher priority
assign ft0_addr_a   = ch1_wren ? ch1_data.addr0 : ch0_meta.addr0;
assign ft1_addr_a   = ch1_wren ? ch1_data.addr1 : ch0_meta.addr1;
assign ft2_addr_a   = ch1_wren ? ch1_data.addr2 : ch0_meta.addr2;
assign ft3_addr_a   = ch1_wren ? ch1_data.addr3 : ch0_meta.addr3;
assign q_addr_a     = ch1_wren ? ch1_data.tuple : ch0_meta.tuple;
assign lookup_tuple = ch0_meta.tuple;

// Use q_a results to check whether or not it is a hit. The
// rest of the fields maybe changed by other souce later.
assign ft_hit[0] = (lookup_tuple_r2 == ft0_q_a.tuple) & ft0_q_a.valid;
assign ft_hit[1] = (lookup_tuple_r2 == ft1_q_a.tuple) & ft1_q_a.valid;
assign ft_hit[2] = (lookup_tuple_r2 == ft2_q_a.tuple) & ft2_q_a.valid;
assign ft_hit[3] = (lookup_tuple_r2 == ft3_q_a.tuple) & ft3_q_a.valid;
assign ft_hit[4] = q_rd_hit_a;

// Two cycle rd delay
always @(posedge clk) begin
    if (rst) begin
        rd_valid_a_r <= 0;
        rd_valid_a   <= 0;
    end
    else begin
        rd_valid_a_r <= ft0_rden_a;
        rd_valid_a   <= rd_valid_a_r;
    end
    q_rden_a_r1 <= q_rden_a;

    rd_valid_b_r <= ft0_rden_b;
    rd_valid_b   <= rd_valid_b_r;

    lookup_tuple_r1 <= lookup_tuple;
    lookup_tuple_r2 <= lookup_tuple_r1;
    lookup_tuple_b_r1 <= lookup_tuple_b;
    lookup_tuple_b_r2 <= lookup_tuple_b_r1;

    q_deque_en_r <= q_deque_en;
    q_deque_done_r <= q_deque_done;
end

// Third cycle for timing optimization
always @(posedge clk) begin
    if (rst) begin
        ch0_rd_valid <= 0;
        ch0_bit_map <= 0;
    end
    else begin
        ch0_rd_valid <= rd_valid_a;
        ch0_bit_map <= ch0_bit_map_int;
    end
    case (ch0_bit_map_int)
        5'b0_0001: ch0_q <= ft0_odata_a;
        5'b0_0010: ch0_q <= ft1_odata_a;
        5'b0_0100: ch0_q <= ft2_odata_a;
        5'b0_1000: ch0_q <= ft3_odata_a;
        5'b1_0000: ch0_q <= q_odata_a;
        default: ch0_q <= 0;
    endcase
end
assign ch0_rd_stall = (rd_valid_a_r | rd_valid_a | ch0_rd_valid |
                       ch1_wren | (p_state == P_LOOKUP) | (p_state == P_FILL)
                       | q_deque_done_r | slow_conflict);

always @(posedge clk) begin
    if (!rst) begin
        assert(!(rdw0_a | rdw1_a | rdw2_a | rdw3_a | rdwq_a))
        else begin
            $error("Slow path write while fast path read at the same cycle");
            $finish;
        end
        assert(!(rdw0_b | rdw1_b | rdw2_b | rdw3_b | rdwq_b))
        else begin
            $error("Slow path read while fast path write at the same cycle");
            $finish;
        end
    end
end

// Decide the odata
always @(*) begin
    // Default value
    ft0_odata_a = ft0_q_a;
    ft1_odata_a = ft1_q_a;
    ft2_odata_a = ft2_q_a;
    ft3_odata_a = ft3_q_a;
    q_odata_a   = q_q_a;
    ch0_bit_map_int = ft_hit;
    if (rdw0_a_r2) begin
        ft0_odata_a = ft0_data_b_r2;
        ch0_bit_map_int = 5'b0_0001;
    end
    if (rdw1_a_r2) begin
        ft1_odata_a = ft1_data_b_r2;
        ch0_bit_map_int = 5'b0_0010;
    end
    if (rdw2_a_r2) begin
        ft2_odata_a = ft2_data_b_r2;
        ch0_bit_map_int = 5'b0_0100;
    end
    if (rdw3_a_r2) begin
        ft3_odata_a = ft3_data_b_r2;
        ch0_bit_map_int = 5'b0_1000;
    end
    if (rdwq_a_r2) begin
        q_odata_a = q_data_b_r2;
        ch0_bit_map_int = 5'b1_0000;
    end
end

///////// Forward new data for read-during-write. /////////////////////////
// Support it outside of BRAM as M20K does not support new data internally.
assign rdw0_a = ft0_rden_a & ft0_wren_b & (ft0_addr_a == ft0_addr_b);
assign rdw1_a = ft1_rden_a & ft1_wren_b & (ft1_addr_a == ft1_addr_b);
assign rdw2_a = ft2_rden_a & ft2_wren_b & (ft2_addr_a == ft2_addr_b);
assign rdw3_a = ft3_rden_a & ft3_wren_b & (ft3_addr_a == ft3_addr_b);
assign rdwq_a = q_rden_a   & q_wren_b   & (q_addr_a == q_addr_b);
assign rdw0_b = ft0_rden_b & ft0_wren_a & (ft0_addr_b == ft0_addr_a);
assign rdw1_b = ft1_rden_b & ft1_wren_a & (ft1_addr_b == ft1_addr_a);
assign rdw2_b = ft2_rden_b & ft2_wren_a & (ft2_addr_b == ft2_addr_a);
assign rdw3_b = ft3_rden_b & ft3_wren_a & (ft3_addr_b == ft3_addr_a);
assign rdwq_b = q_rden_b   & q_wren_a   & (q_addr_b == q_addr_a);

// Two cycles delay
always @(posedge clk) begin
    rdw0_a_r1 <= rdw0_a;
    rdw0_a_r2 <= rdw0_a_r1;
    rdw1_a_r1 <= rdw1_a;
    rdw1_a_r2 <= rdw1_a_r1;
    rdw2_a_r1 <= rdw2_a;
    rdw2_a_r2 <= rdw2_a_r1;
    rdw3_a_r1 <= rdw3_a;
    rdw3_a_r2 <= rdw3_a_r1;
    rdwq_a_r1 <= rdwq_a;
    rdwq_a_r2 <= rdwq_a_r1;
    rdw0_b_r1 <= rdw0_b;
    rdw0_b_r2 <= rdw0_b_r1;
    rdw1_b_r1 <= rdw1_b;
    rdw1_b_r2 <= rdw1_b_r1;
    rdw2_b_r1 <= rdw2_b;
    rdw2_b_r2 <= rdw2_b_r1;
    rdw3_b_r1 <= rdw3_b;
    rdw3_b_r2 <= rdw3_b_r1;
    rdwq_b_r1 <= rdwq_b;
    rdwq_b_r2 <= rdwq_b_r1;
    ft0_data_b_r1 <= ft0_data_b;
    ft0_data_b_r2 <= ft0_data_b_r1;
    ft1_data_b_r1 <= ft1_data_b;
    ft1_data_b_r2 <= ft1_data_b_r1;
    ft2_data_b_r1 <= ft2_data_b;
    ft2_data_b_r2 <= ft2_data_b_r1;
    ft3_data_b_r1 <= ft3_data_b;
    ft3_data_b_r2 <= ft3_data_b_r1;
    q_data_b_r1 <= q_data_b;
    q_data_b_r2 <= q_data_b_r1;
end

///////// Update operation /////////////////////////
// The read and write arbirates for addr. If both happen on the same cycle, delay read.
assign update   = ch1_wren & ((ch1_opcode == FT_UPDATE) || (ch1_opcode == FT_DELETE));
assign update_q = ch1_wren & (ch1_opcode == FT_UPDATE) & ch1_bit_map[4];
assign ft0_wren_a = update & ch1_bit_map[0];
assign ft1_wren_a = update & ch1_bit_map[1];
assign ft2_wren_a = update & ch1_bit_map[2];
assign ft3_wren_a = update & ch1_bit_map[3];
assign q_wren_a   = update_q;

assign ft0_data_a = ch1_data;
assign ft1_data_a = ch1_data;
assign ft2_data_a = ch1_data;
assign ft3_data_a = ch1_data;
assign q_data_a   = ch1_data;

///////// Insert/Delete operation /////////////////////////
assign insert     = ch1_wren & ch1_bit_map[4] & (ch1_opcode == FT_INSERT);
assign delete     = ch1_wren & ch1_bit_map[4] & (ch1_opcode == FT_DELETE);

// Evict is another form of inserting, no need to worry about full
assign q_op_en    = (insert & !q_full) | delete | evict;
assign q_op_id    = (insert|evict) ? PQ_OP_FAST_INSERT : PQ_OP_FAST_DELETE;
assign q_op_data  = evict ? evict_data : ch1_data;
assign ch1_insert_stall  = insert & q_full;

///////// Fill/Eviction operation /////////////////////////
// Dequeue the para Q and update the flow table.
assign ft_empty[0] = !ft0_q_b.valid;
assign ft_empty[1] = !ft1_q_b.valid;
assign ft_empty[2] = !ft2_q_b.valid;
assign ft_empty[3] = !ft3_q_b.valid;

///////// Arbiration for port_B /////////////////////////
// Only generate a request during the ARB state.
assign req[0] = (p_state == P_ARB) & !q_empty_r;
assign req[1] = (p_state == P_ARB) & (ch3_wren || ch2_rden);
assign req[2] = 0;
assign req[3] = 0;

assign ch3_ready = grant[1];
assign ch2_ready = grant[1];

assign ft_hit_b[0] = (lookup_tuple_b_r2 == ft0_q_b.tuple) & ft0_q_b.valid;
assign ft_hit_b[1] = (lookup_tuple_b_r2 == ft1_q_b.tuple) & ft1_q_b.valid;
assign ft_hit_b[2] = (lookup_tuple_b_r2 == ft2_q_b.tuple) & ft2_q_b.valid;
assign ft_hit_b[3] = (lookup_tuple_b_r2 == ft3_q_b.tuple) & ft3_q_b.valid;
assign ft_hit_b[4] = q_rd_hit_b;

always @(*) begin
    case (ch2_bit_map)
        5'b0_0001: ch2_q = ft0_odata_b;
        5'b0_0010: ch2_q = ft1_odata_b;
        5'b0_0100: ch2_q = ft2_odata_b;
        5'b0_1000: ch2_q = ft3_odata_b;
        5'b1_0000: ch2_q = q_odata_b;
        default: ch2_q = 0;
    endcase
end
always @(posedge clk) begin
    ft0_data_a_r1 <= ft0_data_a;
    ft0_data_a_r2 <= ft0_data_a_r1;
end
always @(*) begin
    // Default value
    ft0_odata_b = ft0_q_b;
    ft1_odata_b = ft1_q_b;
    ft2_odata_b = ft2_q_b;
    ft3_odata_b = ft3_q_b;
    q_odata_b   = q_q_b;
    ch2_rd_valid = 0;
    ch2_bit_map = ft_hit_b;

    if (p_state == SLOW_LOOKUP) begin
        ch2_rd_valid = rd_valid_b;
    end

    if (rdw0_b_r2) begin
        ft0_odata_b = ft0_data_a_r2;
        ch2_bit_map = 5'b0_0001;
    end
    if (rdw1_b_r2) begin
        ft1_odata_b = ft1_data_a_r2;
        ch2_bit_map = 5'b0_0010;
    end
    if (rdw2_b_r2) begin
        ft2_odata_b = ft2_data_a_r2;
        ch2_bit_map = 5'b0_0100;
    end
    if (rdw3_b_r2) begin
        ft3_odata_b = ft3_data_a_r2;
        ch2_bit_map = 5'b0_1000;
    end
    if (rdwq_b_r2) begin
        q_odata_b = q_data_a_r2;
        ch2_bit_map = 5'b1_0000;
    end
end

// The q_deque_data will show up one cycle later
always @(posedge clk) begin
    q_empty_r <= q_empty;
    ch0_tuple_r1 <= ch0_meta.tuple;

    // ch0_tuple_latch keeps the tuple value before next read
    if (ft0_rden_a) begin
        ch0_tuple_latch_r <= ch0_meta.tuple;
    end
end
assign ch0_tuple_latch = ft0_rden_a ? ch0_meta.tuple : ch0_tuple_latch_r;

// Random number used for eviction
always @(posedge clk) begin
    if (rst) begin
        random <= 0;
    end
    else begin
        random <= random + 1;
    end
end

assign head_busy = (q_rden_a & (ch0_meta.tuple == q_deque_data.tuple) |
                    q_rden_a_r1 & (ch0_tuple_r1 == q_deque_data.tuple));

// Start from the rden, until the update is done
assign fast_busy = ch0_rden | ch0_rd_stall;

// When slow path is updating the FT assign p_state == SLOW_UPDATE
assign slow_conflict = slow_busy & ch0_rden & (ch3_data_r.tuple == ch0_meta.tuple);

// One state machine that arbirates all the read/writes using port_b.
always @(posedge clk) begin
    if (rst) begin
        p_state <= P_ARB;
        ft0_rden_b <= 0;
        ft1_rden_b <= 0;
        ft2_rden_b <= 0;
        ft3_rden_b <= 0;
        ft0_wren_b <= 0;
        ft1_wren_b <= 0;
        ft2_wren_b <= 0;
        ft3_wren_b <= 0;
        q_rden_b   <= 0;
        q_wren_b   <= 0;
        q_deque_en <= 0;
        evict      <= 0;
        slow_busy  <= 0;
    end
    else begin
        case (p_state)
            P_ARB: begin
                evict <= 0;
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                ft0_wren_b <= 0;
                ft1_wren_b <= 0;
                ft2_wren_b <= 0;
                ft3_wren_b <= 0;
                q_rden_b   <= 0;
                q_wren_b   <= 0;
                q_deque_en <= 0;
                evict      <= 0;
                slow_busy  <= 0;
                case (grant)
                    // Para_Q fill operation
                    4'b0001: begin
                        p_state    <= P_LOOKUP;
                        ft0_rden_b <= 1;
                        ft1_rden_b <= 1;
                        ft2_rden_b <= 1;
                        ft3_rden_b <= 1;
                        ft0_addr_b <= q_deque_data.addr0;
                        ft1_addr_b <= q_deque_data.addr1;
                        ft2_addr_b <= q_deque_data.addr2;
                        ft3_addr_b <= q_deque_data.addr3;
                    end
                    // Slow path lookup and update
                    4'b0010: begin
                        // Read and Write won't happen on the same cycle
                        if (ch3_wren) begin
                            // Same entry is busy
                            if (fast_busy & (ch3_data.tuple == ch0_tuple_latch)) begin
                                p_state <= SLOW_UPDATE_WAIT;
                            end
                            else begin
                                slow_busy  <= 1;
                                p_state    <= SLOW_UPDATE;
                                ft0_rden_b <= 1;
                                ft1_rden_b <= 1;
                                ft2_rden_b <= 1;
                                ft3_rden_b <= 1;
                                q_rden_b   <= 1;
                            end
                            ft0_addr_b <= ch3_data.addr0;
                            ft1_addr_b <= ch3_data.addr1;
                            ft2_addr_b <= ch3_data.addr2;
                            ft3_addr_b <= ch3_data.addr3;
                            q_addr_b   <= ch3_data.tuple;
                            ch3_data_r <= ch3_data;
                            lookup_tuple_b <= ch3_data.tuple;
                            ch3_rel_pkt_cnt_r <= ch3_rel_pkt_cnt;
                        end
                        else begin
                            // Avoid rd/wr conflicts
                            if (ch0_rd_valid & (ch2_meta.tuple == ch0_tuple_latch)) begin
                                p_state <= SLOW_LOOKUP_WAIT;
                            end
                            else begin
                                p_state    <= SLOW_LOOKUP;
                                ft0_rden_b <= 1;
                                ft1_rden_b <= 1;
                                ft2_rden_b <= 1;
                                ft3_rden_b <= 1;
                                q_rden_b   <= 1;
                            end
                            ft0_addr_b <= ch2_meta.addr0;
                            ft1_addr_b <= ch2_meta.addr1;
                            ft2_addr_b <= ch2_meta.addr2;
                            ft3_addr_b <= ch2_meta.addr3;
                            q_addr_b   <= ch2_meta.tuple;
                            lookup_tuple_b <= ch2_meta.tuple;
                        end
                    end
                    default: p_state <= P_ARB;
                endcase
            end
            P_LOOKUP: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;

                ft0_q_b_r <= ft0_q_b;
                ft1_q_b_r <= ft1_q_b;
                ft2_q_b_r <= ft2_q_b;
                ft3_q_b_r <= ft3_q_b;

                if (rd_valid_b) begin
                    ft_empty_r <= ft_empty;
                    if (head_busy) begin
                        p_state <= P_ARB;
                    end
                    else begin
                        // All entries are full
                        if (ft_empty == 0) begin
                            p_state <= P_EVIC;
                            q_deque_en <= 1;
                        end
                        else begin
                            p_state <= P_FILL;
                            q_deque_en <= 1;
                        end
                    end
                end
            end
            P_FILL: begin
                ft0_data_b <= q_deque_data;
                ft1_data_b <= q_deque_data;
                ft2_data_b <= q_deque_data;
                ft3_data_b <= q_deque_data;
                q_deque_en <= 0;
                if (q_deque_done) begin
                    p_state <= P_ARB;

                    // Priority
                    if (ft_empty_r[0]) begin
                        ft0_wren_b <= 1;
                    end
                    else if (ft_empty_r[1]) begin
                        ft1_wren_b <= 1;
                    end
                    else if (ft_empty_r[2]) begin
                        ft2_wren_b <= 1;
                    end
                    else if (ft_empty_r[3]) begin
                        ft3_wren_b <= 1;
                    end
                end
            end
            P_EVIC: begin
                ft0_data_b <= q_deque_data;
                ft1_data_b <= q_deque_data;
                ft2_data_b <= q_deque_data;
                ft3_data_b <= q_deque_data;
                evict <= 0;

                // Deque and overwrite the data in subtable
                q_deque_en <= 0;
                if (q_deque_done) begin
                    p_state <= P_ARB;
                    $display("Evict!");
                    // The queue cannot be full during eviction,
                    // so don't need to check the full signal.
                    evict <= 1;
                    // Overwrite the data in the subtable,
                    // and select right data to insert Q.
                    case (random)
                        2'b00: begin
                            ft0_wren_b <= 1;
                            evict_data <= ft0_q_b_r;
                        end
                        2'b01: begin
                            ft1_wren_b <= 1;
                            evict_data <= ft1_q_b_r;
                        end
                        2'b10: begin
                            ft2_wren_b <= 1;
                            evict_data <= ft2_q_b_r;
                        end
                        2'b11: begin
                            ft3_wren_b <= 1;
                            evict_data <= ft3_q_b_r;
                        end
                    endcase
                end
            end
            SLOW_UPDATE_WAIT: begin
                if (!(fast_busy & (ch3_data.tuple == ch0_tuple_latch))) begin
                    p_state    <= SLOW_UPDATE;
                    ft0_rden_b <= 1;
                    ft1_rden_b <= 1;
                    ft2_rden_b <= 1;
                    ft3_rden_b <= 1;
                    q_rden_b   <= 1;
                    slow_busy  <= 1;
                end
            end
            SLOW_UPDATE: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                ft0_wren_b <= 0;
                ft1_wren_b <= 0;
                ft2_wren_b <= 0;
                ft3_wren_b <= 0;
                q_rden_b   <= 0;
                q_wren_b   <= 0;

                ft0_data_b <= ch3_data_r;
                ft1_data_b <= ch3_data_r;
                ft2_data_b <= ch3_data_r;
                ft3_data_b <= ch3_data_r;
                q_data_b   <= ch3_data_r;

                ft0_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft1_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft2_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                ft3_data_b.slow_cnt <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;
                q_data_b.slow_cnt   <= ch2_q.slow_cnt - ch3_rel_pkt_cnt_r;

                `ifdef DEBUG
                if (rd_valid_b & ch2_bit_map != 0) begin
                    $display("Slow_cnt current %d, release %d, updated %d",
                             (ch2_q.slow_cnt, ch3_rel_pkt_cnt_r),
                             (ch2_q.slow_cnt - ch3_rel_pkt_cnt_r));

                    assert(!(ch2_q.slow_cnt < ch3_rel_pkt_cnt_r))
                    else begin
                        $error("slow_cnt error");
                        $finish;
                    end
                end
                `endif

                // Update data in the flow table. Address is not changed.
                if (rd_valid_b) begin
                    case (ch2_bit_map)
                        5'b0_0001: ft0_wren_b <= 1;
                        5'b0_0010: ft1_wren_b <= 1;
                        5'b0_0100: ft2_wren_b <= 1;
                        5'b0_1000: ft3_wren_b <= 1;
                        5'b1_0000: q_wren_b   <= 1;
                    endcase
                    p_state <= P_ARB;
                end
            end
            SLOW_LOOKUP_WAIT: begin
                if (!(ch0_rd_valid & (lookup_tuple_b == ch0_tuple_latch))) begin
                    p_state    <= SLOW_LOOKUP;
                    ft0_rden_b <= 1;
                    ft1_rden_b <= 1;
                    ft2_rden_b <= 1;
                    ft3_rden_b <= 1;
                    q_rden_b   <= 1;
                end
            end
            SLOW_LOOKUP: begin
                ft0_rden_b <= 0;
                ft1_rden_b <= 0;
                ft2_rden_b <= 0;
                ft3_rden_b <= 0;
                q_rden_b   <= 0;
                // Address is not changed
                if (rd_valid_b) begin
                    p_state <= P_ARB;
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

// Miscellnaeous signals
assign q_debug = 0;

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_0 (
    .address_a  (ft0_addr_a),
    .address_b  (ft0_addr_b),
    .clock      (clk),
    .data_a     (ft0_data_a),
    .data_b     (ft0_data_b),
    .rden_a     (ft0_rden_a),
    .rden_b     (ft0_rden_b),
    .wren_a     (ft0_wren_a),
    .wren_b     (ft0_wren_b),
    .q_a        (ft0_q_a),
    .q_b        (ft0_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_1 (
    .address_a  (ft1_addr_a),
    .address_b  (ft1_addr_b),
    .clock      (clk),
    .data_a     (ft1_data_a),
    .data_b     (ft1_data_b),
    .rden_a     (ft1_rden_a),
    .rden_b     (ft1_rden_b),
    .wren_a     (ft1_wren_a),
    .wren_b     (ft1_wren_b),
    .q_a        (ft1_q_a),
    .q_b        (ft1_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_2 (
    .address_a  (ft2_addr_a),
    .address_b  (ft2_addr_b),
    .clock      (clk),
    .data_a     (ft2_data_a),
    .data_b     (ft2_data_b),
    .rden_a     (ft2_rden_a),
    .rden_b     (ft2_rden_b),
    .wren_a     (ft2_wren_a),
    .wren_b     (ft2_wren_b),
    .q_a        (ft2_q_a),
    .q_b        (ft2_q_b)
);

bram_true2port #(
    .AWIDTH(FT_AWIDTH),
    .DWIDTH(FT_DWIDTH),
    .DEPTH(FT_DEPTH)
)
ft_3 (
    .address_a  (ft3_addr_a),
    .address_b  (ft3_addr_b),
    .clock      (clk),
    .data_a     (ft3_data_a),
    .data_b     (ft3_data_b),
    .rden_a     (ft3_rden_a),
    .rden_b     (ft3_rden_b),
    .wren_a     (ft3_wren_a),
    .wren_b     (ft3_wren_b),
    .q_a        (ft3_q_a),
    .q_b        (ft3_q_b)
);

para_Q para_q_inst (
    .clk        (clk),
    .rst        (rst),
    // Port A
    .addr_a     (q_addr_a),
    .data_a     (q_data_a),
    .rden_a     (q_rden_a),
    .wren_a     (q_wren_a),
    .rd_valid_a (q_rd_valid_a), // 2 cycles delay
    .rd_hit_a   (q_rd_hit_a),   // Hit in queue?
    .q_a        (q_q_a),

    // Port B
    .addr_b     (q_addr_b),
    .data_b     (q_data_b),
    .rden_b     (q_rden_b),
    .wren_b     (q_wren_b),
    .rd_valid_b (q_rd_valid_b), // 2 cycles delay
    .rd_hit_b   (q_rd_hit_b),   // Hit in queue?
    .q_b        (q_q_b),

    // Insert/Delete operations
    .op_en      (q_op_en),
    .op_id      (q_op_id), // PQ_OP_FAST_{INSERT, DELETE}
    .op_data    (q_op_data),

    // Deque operation
    .deque_en   (q_deque_en),
    .deque_data (q_deque_data),
    .deque_done (q_deque_done), // Raised when deque completes

    // Error signals
    .error             (q_error),
    .is_error_fatal    (q_is_error_fatal),

    // Debug signals
    .full              (q_full),
    .empty             (q_empty),
    .debug             (q_debug)
);

rr_arbiter_4 port_b_arb (
    .clk   (clk),
    .rst   (rst),
    .req   (req),
    .grant (grant)
);

endmodule
