`include "./src/struct_s.sv"
module data_mover (
    input   logic                       clk,
    input   logic                       rst,
    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_address,
    output  logic                       pkt_buffer_read,
    input   logic                       pkt_buffer_readvalid,
    input   flit_t                      pkt_buffer_readdata,
    output  logic [PKT_AWIDTH-1:0]      emptylist_in_data,
    output  logic                       emptylist_in_valid,
    input   logic                       emptylist_in_ready,
    output  logic                       pkt_sop,
    output  logic                       pkt_eop,
    output  logic                       pkt_valid,
    output  logic [511:0]               pkt_data,
    output  logic [5:0]                 pkt_empty,
    input   logic                       pkt_ready,
    input   logic                       pkt_almost_full,
    output  logic                       check_pkt_sop,
    output  logic                       check_pkt_eop,
    output  logic                       check_pkt_valid,
    output  logic [511:0]               check_pkt_data,
    output  logic [5:0]                 check_pkt_empty,
    input   logic                       check_pkt_ready,
    input   logic                       check_pkt_almost_full,
    //output  logic [8:0]                 check_pkt_hdr,
    output  logic                       check_meta_valid,
    output  metadata_t                  check_meta_data,
    input   logic                       check_meta_ready,
    input   logic                       meta_valid,
    input   metadata_t                  meta_data,
    output  logic                       meta_ready
);

`ifdef USE_BRAM
//localparam NUM_PIPES = (2+2+2+1);
//Remove the hyper pipeline
localparam NUM_PIPES = (2+1);
`else
// On-chip memory read latency is 12 cycles for eSRAM
localparam NUM_PIPES = (2+2+12+1);
`endif

logic [PKT_AWIDTH-1:0] pkt_id;
logic [4:0] flits;

logic [4:0] flits_cnt;
logic [2:0] pkt_flags;
logic [2:0] pkt_flags_r;
logic [8:0] pkt_hdr;
logic [8:0] pkt_hdr_r;

logic first_ready;
logic middle_ready;
logic almost_full;

logic [15:0] statable_cnt;

typedef enum {
    WAIT_STATABLE,
    INIT,
    IDLE,
    FIRST,
    MIDDLE
} state_t;
state_t state;

assign meta_ready = ((state == IDLE) | first_ready | middle_ready) & !almost_full;
assign first_ready = (state == FIRST) & ((pkt_flags == PKT_DROP) | (flits == 1));
assign middle_ready = (state == MIDDLE) & (flits_cnt == (flits - 1));
assign almost_full = pkt_almost_full | check_pkt_almost_full;

// Quick and Dirty tweak for PDU flag
always @(posedge clk) begin
    if (rst) begin
        check_meta_valid <= 0;
    end
    else begin
        check_meta_valid <= 0;
        if (meta_valid & meta_ready & ((meta_data.pkt_flags == PKT_CHECK) |
                                       (meta_data.pkt_flags == PKT_OOO))) begin
            check_meta_valid <= 1;
        end
    end
    check_meta_data <= meta_data;
    check_meta_data.pdu_flag <= PDU_LAST;
end

// Capture the meta_data
always @(posedge clk) begin
    if (rst) begin
        flits <= 0;
        pkt_id <= 0;
        pkt_hdr <= 0;
        pkt_flags <= 0;
    end
    else begin
        if (meta_valid & meta_ready) begin
            flits <= meta_data.flits;
            pkt_id <= meta_data.pktID;
            pkt_hdr <= meta_data.hdr_len;
            pkt_flags <= meta_data.pkt_flags;
        end
    end
end

// DEBUG
always @(posedge clk) begin
    if (!emptylist_in_ready & emptylist_in_valid) begin
        $display("PKT emptylist is full!");
        $finish;
    end
    `ifdef DEBUG
    if (meta_valid & meta_ready) begin
        $display("pkt:%d,length:%d,flag:%d", meta_data.pktID,
                 meta_data.len, meta_data.pkt_flags);
    end
    `endif
end

// Read Logic
always @(posedge clk) begin
    if (rst) begin
        flits_cnt <= 0;
        state <= WAIT_STATABLE;
        emptylist_in_data <= 0;
        emptylist_in_valid <= 0;
        statable_cnt <= 0;
        pkt_buffer_read <= 0;
    end
    else begin
        case (state)
            WAIT_STATABLE: begin
                statable_cnt <= statable_cnt + 1;
                if (statable_cnt == 50) begin
                    state <= INIT;
                    emptylist_in_valid <= 1'b1;
                end
            end
            // Init the emptylist
            INIT: begin
                if (emptylist_in_valid & emptylist_in_ready) begin
                    emptylist_in_data <= emptylist_in_data + 1'b1;
                    if (emptylist_in_data == (PKT_NUM - 1)) begin
                        emptylist_in_valid <= 1'b0;
                        state <= IDLE;
                        $display("Finish PKT emptylist init");
                    end
                end
            end
            IDLE: begin
                // Clear
                pkt_buffer_address <= 0;
                pkt_buffer_read <= 0;
                flits_cnt <= 0;
                emptylist_in_valid <= 1'b0;
                if (meta_valid & !almost_full) begin
                    state <= FIRST;
                end
            end
            FIRST: begin
                emptylist_in_valid <= 0;
                if (pkt_flags == PKT_DROP) begin
                    pkt_buffer_read <= 0;
                    emptylist_in_valid <= 1'b1;
                    emptylist_in_data <= pkt_id;
                    if (meta_valid & !almost_full) begin
                        state <= FIRST;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    pkt_buffer_read <= 1;
                    pkt_buffer_address <= (pkt_id << 5);

                    // Last flit
                    if (flits == 1) begin
                        emptylist_in_valid <= 1'b1;
                        emptylist_in_data <= pkt_id;

                        if (meta_valid & !almost_full) begin
                            state <= FIRST;
                        end
                        else begin
                            state <= IDLE;
                        end
                    end
                    else begin
                        state <= MIDDLE;
                        flits_cnt <= flits_cnt + 1;
                    end
                end
            end
            MIDDLE: begin
                emptylist_in_valid <= 1'b0;

                // Last flit
                if (flits_cnt == (flits - 1)) begin
                    pkt_buffer_address <= pkt_buffer_address + 1;
                    flits_cnt <= 0;

                    emptylist_in_valid <= 1'b1;
                    emptylist_in_data <= pkt_id;

                    // Wait
                    if (meta_valid & !almost_full) begin
                        state <= FIRST;
                    end
                    else begin
                        state <= IDLE;
                    end
                end
                else begin
                    pkt_buffer_read <= 1;
                    pkt_buffer_address <= pkt_buffer_address + 1;
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

// Write logic. No backpressure yet.
always @(posedge clk) begin
    if (rst) begin
        check_pkt_valid <= 0;
        pkt_valid <= 0;
    end
    else begin
        pkt_data <= pkt_buffer_readdata.data;
        pkt_sop <= 0;
        pkt_eop <= 0;
        pkt_empty <= 0;
        pkt_valid <= 0;

        check_pkt_data <= pkt_buffer_readdata.data;
        check_pkt_sop <= 0;
        check_pkt_eop <= 0;
        check_pkt_empty <= 0;
        check_pkt_valid <= 0;
        //check_pkt_hdr <= 0;

        if (pkt_buffer_readvalid) begin
            // Send check_pkt to data_fifo
            if ((pkt_flags_r == PKT_OOO) | (pkt_flags_r == PKT_CHECK)) begin
                //check_pkt_hdr <= pkt_hdr_r;
                check_pkt_sop <= pkt_buffer_readdata.sop;
                check_pkt_eop <= pkt_buffer_readdata.eop;
                check_pkt_valid <= 1;
                check_pkt_empty <= pkt_buffer_readdata.empty;
            end
            else begin
                pkt_sop <= pkt_buffer_readdata.sop;
                pkt_eop <= pkt_buffer_readdata.eop;
                pkt_valid <= 1;
                pkt_empty <= pkt_buffer_readdata.empty;
            end
        end
    end
end

hyper_pipe #(
    .WIDTH (3),
    .NUM_PIPES(NUM_PIPES)
) hp_flags (
    .clk(clk),
    .din(pkt_flags),
    .dout(pkt_flags_r)
);

hyper_pipe #(
    .WIDTH (9),
    .NUM_PIPES(NUM_PIPES)
) hp_hdr (
    .clk(clk),
    .din(pkt_hdr),
    .dout(pkt_hdr_r)
);

endmodule
