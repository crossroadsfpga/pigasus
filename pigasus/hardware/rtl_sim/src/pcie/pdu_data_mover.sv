`include "./src/struct_s.sv"

module pdu_data_mover (
    input  logic                    clk,
    input  logic                    rst,

    // Output to PDU_gen
    output logic [PDUID_WIDTH-1:0]  pdu_emptylist_out_data,
    output logic                    pdu_emptylist_out_valid,
    input  logic                    pdu_emptylist_out_ready,

    // Input from PDU_gen
    input   pdu_metadata_t           pdumeta_gen_data,
    input   logic                    pdumeta_gen_valid,
    output  logic                    pdumeta_gen_ready,
    input   logic [511:0]            pdu_gen_data,
    input   logic                    pdu_gen_sop,
    input   logic                    pdu_gen_eop,
    input   logic [5:0]              pdu_gen_empty,
    input   logic                    pdu_gen_valid,
    output  logic                    pdu_gen_ready,
    output  logic                    pdu_gen_almost_full,

    // Input from CPU, action include pdu_id + action
    input   pdu_metadata_t           pdumeta_cpu_data,
    input   logic                    pdumeta_cpu_valid,
    output  logic                    pdumeta_cpu_ready,

    // Output to nocheck fifo
    output  logic [511:0]            nocheck_data,
    output  logic                    nocheck_sop,
    output  logic                    nocheck_eop,
    output  logic                    nocheck_valid,
    output  logic [5:0]              nocheck_empty,
    input   logic                    nocheck_ready,
    input   logic                    nocheck_almost_full,

    // Output to nomatch fifo
    output  logic [511:0]            nomatch_data,
    output  logic                    nomatch_sop,
    output  logic                    nomatch_eop,
    output  logic                    nomatch_valid,
    output  logic [5:0]              nomatch_empty,
    input   logic                    nomatch_ready,
    input   logic                    nomatch_almost_full,

    // DRAM
    output  ddr_wr_t                 ddr_wr_req_data,
    output  logic                    ddr_wr_req_valid,
    input   logic                    ddr_wr_req_almost_full,
    output  ddr_rd_t                 ddr_rd_req_data,
    output  logic                    ddr_rd_req_valid,
    input   logic                    ddr_rd_req_almost_full,
    input   logic [511:0]            ddr_rd_resp_data,
    input   logic                    ddr_rd_resp_valid,
    output  logic                    ddr_rd_resp_ready
);

pdu_metadata_t           pdumeta_int_data;
logic                    pdumeta_int_valid;
logic                    pdumeta_int_ready;
logic [511:0]            pdu_int_data;
logic                    pdu_int_sop;
logic                    pdu_int_eop;
logic [5:0]              pdu_int_empty;
logic                    pdu_int_valid;
logic                    pdu_int_ready;
logic [31:0]             pdu_gen_csr_readdata;

logic [PDUID_WIDTH-1:0]  pdu_id;
logic [ACTION_WIDTH-1:0] action;
logic [4:0]              flits;
logic [10:0]             pdu_size;
logic [4:0]              flits_cnt;

logic first_ready;
logic middle_ready;

logic [PDUID_WIDTH-1:0]  pdu_emptylist_in_data;
logic                    pdu_emptylist_in_valid;
logic                    pdu_emptylist_in_ready;

logic ready_to_move;

flit_meta_t resp_gen_data;
logic       resp_gen_valid;
logic       resp_gen_ready;
flit_meta_t resp_int_data;
logic       resp_int_valid;
logic       resp_int_ready;
logic       resp_almost_full;
logic [31:0] resp_csr_readdata;

typedef enum {
    INIT,
    IDLE,
    FIRST,
    MIDDLE
} state_t;
state_t state;

typedef enum
{
    FW_IDLE,
    NO_CHECK,
    CHECK
} fw_state_t;
fw_state_t fw_state;

// Forwarding logic. Use the pdumeta_int info to decide where to forward
// data in pdu_int. If the ACTION is NOCHECK, forward it to NOCHECK_FIFO;
// else forward to check-pkt buffer in DRAM.

assign pdu_int_ready = (fw_state == NO_CHECK) | (fw_state == CHECK);
always @(posedge clk) begin
    if (rst) begin
        nocheck_valid <= 0;
        fw_state <= FW_IDLE;
        ddr_wr_req_valid <= 0;
        pdumeta_int_ready <= 0;
    end
    else begin
        case (fw_state)
            FW_IDLE: begin
                // Clear
                nocheck_valid <= 0;
                ddr_wr_req_valid <= 0;
                pdumeta_int_ready <= 0;

                if (pdumeta_int_valid & !pdumeta_int_ready) begin
                    if ((pdumeta_int_data.action == ACTION_NOCHECK) &
                        !nocheck_almost_full) begin
                        fw_state <= NO_CHECK;
                    end
                    else if ((pdumeta_int_data.action == ACTION_CHECK) &
                             !ddr_wr_req_almost_full) begin
                        fw_state <= CHECK;
                    end
                end
            end
            NO_CHECK: begin
                nocheck_valid <= pdu_int_valid;
                nocheck_sop   <= pdu_int_sop;
                nocheck_eop   <= pdu_int_eop;
                nocheck_empty <= pdu_int_empty;
                nocheck_data  <= pdu_int_data;
                if (pdu_int_eop & pdu_int_valid) begin
                    pdumeta_int_ready <= 1;
                    fw_state <= FW_IDLE;
                end
            end
            CHECK: begin
                ddr_wr_req_data.data  <= pdu_int_data;
                ddr_wr_req_valid <= pdu_int_valid;
                ddr_wr_req_data.sop  <= 0;
                ddr_wr_req_data.eop  <= 0;

                if (pdu_int_valid) begin
                    if (pdu_int_sop) begin
                        ddr_wr_req_data.addr <= pdumeta_int_data.pdu_id << 5;
                        ddr_wr_req_data.sop <= 1;
                    end
                    else begin
                        ddr_wr_req_data.addr <= ddr_wr_req_data.addr + 1'b1;
                    end
                    if (pdu_int_eop) begin
                        ddr_wr_req_data.eop <= 1;
                        pdumeta_int_ready <= 1;
                        fw_state <= FW_IDLE;
                    end
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

`ifdef NO_C2F
assign ddr_rd_req_valid = 0;
assign ddr_rd_resp_ready = 1;
assign pdu_emptylist_out_data = 0;
assign pdu_emptylist_out_valid = 1;
assign pdumeta_cpu_ready = 1;
assign nomatch_valid = 0;

`else
assign pdumeta_cpu_ready = ((state == IDLE) | first_ready | middle_ready) & !nomatch_almost_full;
assign first_ready = (state == FIRST) & ((action == ACTION_MATCH) | (flits == 1));
assign middle_ready = (state == MIDDLE) & (flits_cnt == (flits - 1));

// Capture the meta_data
always @(posedge clk) begin
    if (rst) begin
        flits <= 0;
        pdu_id <= 0;
        action <= 0;
        pdu_size <= 0;
    end
    else begin
        if (pdumeta_cpu_valid & pdumeta_cpu_ready) begin
            flits  <= pdumeta_cpu_data.flits;
            pdu_id <= pdumeta_cpu_data.pdu_id;
            action <= pdumeta_cpu_data.action;
            pdu_size <= pdumeta_cpu_data.pdu_size;
        end
    end
end

assign ready_to_move = (pdumeta_cpu_valid & !nomatch_almost_full &
                        !ddr_rd_req_almost_full & !resp_almost_full);
// Read Logic
always @(posedge clk) begin
    if (rst) begin
        flits_cnt <= 0;
        state <= INIT;
        pdu_emptylist_in_data <= 0;
        pdu_emptylist_in_valid <= 0;
        ddr_rd_req_valid <= 0;
        ddr_rd_req_data <= 0;
        resp_gen_valid <= 0;
    end
    else begin
        case(state)
            // Init the emptylist
            INIT: begin
                pdu_emptylist_in_valid <= 1'b1;
                if (pdu_emptylist_in_valid & pdu_emptylist_in_ready) begin
                    pdu_emptylist_in_data <= pdu_emptylist_in_data + 1'b1;
                    if (pdu_emptylist_in_data == {PDUID_WIDTH{1'b1}}) begin
                        pdu_emptylist_in_valid <= 1'b0;
                        state <= IDLE;
                        $display("Finish PDU emptylist init");
                    end
                end
            end
            IDLE: begin
                // Clear
                flits_cnt <= 0;
                resp_gen_valid <= 0;
                ddr_rd_req_valid <= 0;
                pdu_emptylist_in_valid <= 1'b0;

                if (ready_to_move) begin
                    state <= FIRST;
                end
            end
            FIRST: begin
                pdu_emptylist_in_valid <= 0;
                if (action == ACTION_MATCH) begin
                    ddr_rd_req_valid <= 0;
                    resp_gen_valid <= 0;
                    pdu_emptylist_in_valid <= 1'b1;
                    pdu_emptylist_in_data <= pdu_id;

                    if (ready_to_move) begin
                        state <= FIRST;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    ddr_rd_req_valid <= 1;
                    ddr_rd_req_data.sop <= 1;
                    ddr_rd_req_data.addr <= (pdu_id << 5);

                    resp_gen_valid <= 1;
                    resp_gen_data.sop <= 1;

                    // Last flit
                    if (flits == 1) begin
                        pdu_emptylist_in_valid <= 1'b1;
                        pdu_emptylist_in_data <= pdu_id;

                        resp_gen_data.eop <= 1;
                        ddr_rd_req_data.eop  <= 1;
                        resp_gen_data.empty <= (flits << 5) - pdu_size;

                        if (ready_to_move) begin
                            state <= FIRST;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    else begin
                        flits_cnt <= flits_cnt + 1;
                        ddr_rd_req_data.eop <= 0;
                        resp_gen_data.empty <= 0;
                        resp_gen_data.eop <= 0;
                        state <= MIDDLE;
                    end
                end
            end
            MIDDLE: begin
                pdu_emptylist_in_valid <= 1'b0;
                ddr_rd_req_valid <= 1;
                ddr_rd_req_data.addr <= ddr_rd_req_data.addr + 1;
                ddr_rd_req_data.sop  <= 0;
                resp_gen_valid <= 1;
                resp_gen_data.sop <= 0;

                // Last flit
                if (flits_cnt == (flits - 1)) begin
                    flits_cnt <= 0;
                    resp_gen_data.eop <= 1;
                    ddr_rd_req_data.eop  <= 1;
                    resp_gen_data.empty <= (flits << 5) - pdu_size;

                    pdu_emptylist_in_valid <= 1'b1;
                    pdu_emptylist_in_data <= pdu_id;

                    if (ready_to_move) begin
                        state <= FIRST;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    resp_gen_data.eop <= 0;
                    resp_gen_data.empty <= 0;
                    ddr_rd_req_data.eop <= 0;
                    flits_cnt <= flits_cnt + 1;
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

// Response Path
assign ddr_rd_resp_ready = ddr_rd_resp_valid & resp_int_valid & !nomatch_almost_full;
assign resp_int_ready    = ddr_rd_resp_valid & resp_int_valid & !nomatch_almost_full;

always @(posedge clk) begin
    if (rst) begin
        nomatch_valid <= 0;
    end
    else begin
        if (ddr_rd_resp_ready) begin
            nomatch_valid <= 1;
            nomatch_sop   <= resp_int_data.sop;
            nomatch_eop   <= resp_int_data.eop;
            nomatch_empty <= resp_int_data.empty;
        end
        else begin
            nomatch_valid <= 0;
        end
    end
    // No reset for the wide data signal
    nomatch_data <= ddr_rd_resp_data;
end
`endif

// Input meta data fifo
unified_fifo  #(
    .FIFO_NAME        ("[pdu_data_mover] pdumeta_gen_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (PDU_META_WIDTH),
    .FIFO_DEPTH       (512)
) pdumeta_gen_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (pdumeta_gen_data),
    .in_valid          (pdumeta_gen_valid),
    .in_ready          (pdumeta_gen_ready),
    .out_data          (pdumeta_int_data),
    .out_valid         (pdumeta_int_valid),
    .out_ready         (pdumeta_int_ready),
    .fill_level        (),
    .almost_full       (),//not used
    .overflow          ()
);

// Input data fifo
unified_pkt_fifo  #(
    .FIFO_NAME        ("[pdu_data_mover] pdu_gen_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (950),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (1024)
) pdu_gen_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (pdu_gen_data),
    .in_valid          (pdu_gen_valid),
    .in_ready          (pdu_gen_ready),
    .in_startofpacket  (pdu_gen_sop),
    .in_endofpacket    (pdu_gen_eop),
    .in_empty          (pdu_gen_empty),
    .out_data          (pdu_int_data),
    .out_valid         (pdu_int_valid),
    .out_ready         (pdu_int_ready),
    .out_startofpacket (pdu_int_sop),
    .out_endofpacket   (pdu_int_eop),
    .out_empty         (pdu_int_empty),
    .fill_level        (pdu_gen_csr_readdata),
    .almost_full       (pdu_gen_almost_full),
    .overflow          ()
);


`ifndef NO_C2F
// Response fifo
unified_fifo  #(
    .FIFO_NAME        ("[pdu_data_mover] resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (950),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (1024)
) resp_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (resp_gen_data),
    .in_valid          (resp_gen_valid),
    .in_ready          (resp_gen_ready),
    .out_data          (resp_int_data),
    .out_valid         (resp_int_valid),
    .out_ready         (resp_int_ready),
    .fill_level        (resp_csr_readdata),
    .almost_full       (resp_almost_full),
    .overflow          ()
);


//////////////////// PDU BUFFER Emptylist //////////////////////////////////
unified_fifo  #(
    .FIFO_NAME        ("[pdu_data_mover] pdubuf_emptylist_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (950),//does not matter
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (PDUID_WIDTH),
    .FIFO_DEPTH       (PDU_NUM)
) pdubuf_emptylist (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (pdu_emptylist_in_data),
    .in_valid          (pdu_emptylist_in_valid),
    .in_ready          (pdu_emptylist_in_ready),
    .out_data          (pdu_emptylist_out_data),
    .out_valid         (pdu_emptylist_out_valid),
    .out_ready         (pdu_emptylist_out_ready),
    .fill_level        (),
    .almost_full       (),
    .overflow          ()
);

`endif

endmodule
