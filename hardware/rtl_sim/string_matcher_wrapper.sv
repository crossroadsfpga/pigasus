`include "./struct_s.sv"
`timescale 1 ps / 1 ps

module string_matcher_wrapper (
    input   logic           front_clk,
    input   logic           back_clk,
    input   logic           rst,
    input   logic           clk_datamover,
    input   logic           rst_datamover,
    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic           reg_in_almost_full,
    input   logic           in_meta_valid,
    input   metadata_t      in_meta_data,
    output  logic           reg_out_meta_valid,
    output  metadata_t      reg_out_meta_data,
    output  logic           reg_out_match_valid,
    output  logic [127:0]   reg_out_match_data,
    output  logic           reg_out_match_last,
    input   logic           out_match_almost_full,

    // status register bus
    input   logic           clk_status,
    input   logic   [29:0]  status_addr,
    input   logic           status_read,
    input   logic           status_write,
    input   logic   [31:0]  status_writedata,
    output  logic   [31:0]  status_readdata,
    output  logic           status_readdata_valid
);

logic           front_rst;
logic           back_rst;

logic           out_meta_valid;
metadata_t      out_meta_data;
logic           out_match_valid;
logic [127:0]   out_match_data;
logic           out_match_last;
logic           in_almost_full;

logic           reg_in_sop;
logic           reg_in_eop;
logic [511:0]   reg_in_data;
logic [5:0]     reg_in_empty;
logic           reg_in_valid;
logic           reg_in_meta_valid;
metadata_t      reg_in_meta_data;
logic           reg_out_match_almost_full;

logic           clk_conv_valid;
logic [511:0]   clk_conv_data;
logic           clk_conv_almost_full;
logic           clk_conv_ready;
logic           clk_conv_sop;
logic           clk_conv_eop;
logic [5:0]     clk_conv_empty;
logic           clk_conv_in_csr_address;
logic           clk_conv_in_csr_read;
logic           clk_conv_in_csr_write;
logic [31:0]    clk_conv_in_csr_readdata;
logic [31:0]    clk_conv_in_csr_writedata;

logic           sm_in_valid;
metadata_t      sm_in_data;
logic           sm_in_ready;

logic           data_adapter_valid;
logic [255:0]   data_adapter_data;
logic           data_adapter_ready;
logic           data_adapter_sop;
logic           data_adapter_eop;
logic [4:0]     data_adapter_empty;

logic           data_shift_valid;
logic [255:0]   data_shift_data;
logic           data_shift_ready;
logic           data_shift_sop;
logic           data_shift_eop;
logic [4:0]     data_shift_empty;

logic           data_shift_valid_r1;
logic [255:0]   data_shift_data_r1;
logic           data_shift_ready_r1;
logic           data_shift_sop_r1;
logic           data_shift_eop_r1;
logic [4:0]     data_shift_empty_r1;

logic           data_shift_valid_r2;
logic [255:0]   data_shift_data_r2;
logic           data_shift_ready_r2;
logic           data_shift_sop_r2;
logic           data_shift_eop_r2;
logic [4:0]     data_shift_empty_r2;

logic           string_matcher_valid;
logic [511:0]   string_matcher_data;
logic           string_matcher_ready;
logic           string_matcher_in_meta_valid;
logic           string_matcher_meta_valid;
metadata_t      string_matcher_meta_data;
logic           string_matcher_meta_ready;

logic           ruleID_inst_valid;
logic [31:0]    status_readdata_sm;
logic           status_readdata_valid_sm;
logic [31:0]    status_readdata_ruleID;
logic           status_readdata_valid_ruleID;

logic           not_almost_full;
logic           gap;
logic           data_adapter_deq;

assign front_rst = rst;
assign back_rst  = rst;

always @(posedge front_clk) begin
    data_shift_data_r1    <= data_shift_data;
    data_shift_data_r2    <= data_shift_data_r1;
    data_shift_valid_r1   <= data_shift_valid;
    data_shift_valid_r2   <= data_shift_valid_r1;
    data_shift_sop_r1     <= data_shift_sop;
    data_shift_sop_r2     <= data_shift_sop_r1;
    data_shift_eop_r1     <= data_shift_eop;
    data_shift_eop_r2     <= data_shift_eop_r1;
    data_shift_empty_r1   <= data_shift_empty;
    data_shift_empty_r2   <= data_shift_empty_r1;

    data_adapter_ready    <= not_almost_full & !gap;
end
assign gap = (data_adapter_eop & data_adapter_valid & data_adapter_ready);

assign ruleID_inst_valid = out_match_valid & !out_match_last;
assign string_matcher_in_meta_valid = sm_in_valid & sm_in_ready;
assign data_adapter_deq = data_adapter_valid & data_adapter_ready;

// Simply forward the meta data
always @(posedge clk_status) begin
    if (status_readdata_valid_sm) begin
        status_readdata_valid <= 1'b1;
        status_readdata <= status_readdata_sm;
    end
    else if (status_readdata_valid_ruleID) begin
        status_readdata_valid <= 1'b1;
        status_readdata <= status_readdata_ruleID;
    end
    else begin
        status_readdata_valid <= 1'b0;
    end
end

hyper_pipe_sm reg_io_inst (
    .front_clk                  (front_clk),
    .front_rst                  (front_rst),
    .back_clk                   (back_clk),
    .back_rst                   (back_rst),
    .clk_datamover              (clk_datamover),
    .rst_datamover              (rst_datamover),
    .in_sop                     (in_sop),
    .in_eop                     (in_eop),
    .in_data                    (in_data),
    .in_valid                   (in_valid),
    .in_empty                   (in_empty),
    .in_almost_full             (in_almost_full),
    .in_meta_valid              (in_meta_valid),
    .in_meta_data               (in_meta_data),
    .out_meta_valid             (out_meta_valid),
    .out_meta_data              (out_meta_data),
    .out_match_valid            (out_match_valid),
    .out_match_data             (out_match_data),
    .out_match_last             (out_match_last),
    .out_match_almost_full      (out_match_almost_full),
    .reg_in_sop                 (reg_in_sop),
    .reg_in_eop                 (reg_in_eop),
    .reg_in_data                (reg_in_data),
    .reg_in_valid               (reg_in_valid),
    .reg_in_empty               (reg_in_empty),
    .reg_in_almost_full         (reg_in_almost_full),
    .reg_in_meta_valid          (reg_in_meta_valid),
    .reg_in_meta_data           (reg_in_meta_data),
    .reg_out_meta_valid         (reg_out_meta_valid),
    .reg_out_meta_data          (reg_out_meta_data),
    .reg_out_match_valid        (reg_out_match_valid),
    .reg_out_match_data         (reg_out_match_data),
    .reg_out_match_last         (reg_out_match_last),
    .reg_out_match_almost_full  (reg_out_match_almost_full)
);

dc_fifo_wrapper_infill clk_conv_fifo (
    .in_clk            (clk_datamover),
    .in_reset_n        (!rst_datamover),
    .out_clk           (front_clk),
    .out_reset_n       (!front_rst),
    .in_csr_address    (clk_conv_in_csr_address),
    .in_csr_read       (clk_conv_in_csr_read),
    .in_csr_write      (clk_conv_in_csr_write),
    .in_csr_readdata   (clk_conv_in_csr_readdata),
    .in_csr_writedata  (clk_conv_in_csr_writedata),
    .in_data           (reg_in_data),
    .in_valid          (reg_in_valid),
    .in_ready          (),
    .in_startofpacket  (reg_in_sop),
    .in_endofpacket    (reg_in_eop),
    .in_empty          (reg_in_empty),
    .out_data          (clk_conv_data),
    .out_valid         (clk_conv_valid),
    .out_ready         (clk_conv_ready),
    .out_startofpacket (clk_conv_sop),
    .out_endofpacket   (clk_conv_eop),
    .out_empty         (clk_conv_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(480)
)
dc_bp_clk_conv_fifo (
    .clk            (clk_datamover),
    .rst            (rst_datamover),
    .csr_address    (clk_conv_in_csr_address),
    .csr_read       (clk_conv_in_csr_read),
    .csr_write      (clk_conv_in_csr_write),
    .csr_readdata   (clk_conv_in_csr_readdata),
    .csr_writedata  (clk_conv_in_csr_writedata),
    .almost_full    (in_almost_full)
);

dc_fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
sm_in_meta (
    .in_clk                 (clk_datamover),
    .in_reset_n             (!rst_datamover),
    .out_clk                (front_clk),
    .out_reset_n            (!front_rst),
    .in_data                (reg_in_meta_data),
    .in_valid               (reg_in_meta_valid),
    .in_ready               (), //never full
    .in_startofpacket       (1'b0),
    .in_endofpacket         (1'b0),
    .in_empty               (6'b0),
    .out_data               (sm_in_data),
    .out_valid              (sm_in_valid),
    .out_ready              (sm_in_ready),
    .out_startofpacket      (),
    .out_endofpacket        (),
    .out_empty              ()
);

data_adapter data_adapter_inst (
    .clk                    (front_clk),
    .reset_n                (!front_rst),
    .in_data                (clk_conv_data),
    .in_valid               (clk_conv_valid),
    .in_ready               (clk_conv_ready),
    .in_startofpacket       (clk_conv_sop),
    .in_endofpacket         (clk_conv_eop),
    .in_empty               (clk_conv_empty),
    .out_data               (data_adapter_data),
    .out_valid              (data_adapter_valid),
    .out_ready              (data_adapter_ready),
    .out_startofpacket      (data_adapter_sop),
    .out_endofpacket        (data_adapter_eop),
    .out_empty              (data_adapter_empty)
);

data_shift data_shift_inst (
    .clk                    (front_clk),
    .rst                    (front_rst),
    .in_pkt_sop             (data_adapter_sop),
    .in_pkt_eop             (data_adapter_eop),
    .in_pkt_valid           (data_adapter_deq),
    .in_pkt_data            (data_adapter_data),
    .in_pkt_empty           (data_adapter_empty),
    .in_pkt_ready           (),
    .in_meta_data           (sm_in_data),
    .in_meta_valid          (sm_in_valid),
    .in_meta_ready          (sm_in_ready),
    .out_pkt_sop            (data_shift_sop),
    .out_pkt_eop            (data_shift_eop),
    .out_pkt_valid          (data_shift_valid),
    .out_pkt_data           (data_shift_data),
    .out_pkt_empty          (data_shift_empty),
    .out_pkt_ready          (1'b1)
);

string_matcher string_matcher_inst (
    .front_clk          (front_clk),
    .front_rst          (front_rst),
    .back_clk           (back_clk),
    .back_rst           (back_rst),
    .in_data            (data_shift_data_r2),
    .in_valid           (data_shift_valid_r2),
    .in_sop             (data_shift_sop_r2),
    .in_eop             (data_shift_eop_r2),
    .in_empty           (data_shift_empty_r2),
    .in_ready           (not_almost_full),
    .in_meta_data       (sm_in_data),
    .in_meta_valid      (string_matcher_in_meta_valid),
    .in_meta_ready      (),
    .out_data           (out_match_data),
    .out_valid          (out_match_valid),
    .out_almost_full    (reg_out_match_almost_full),
    .out_last           (out_match_last),
    .out_meta_data      (out_meta_data),
    .out_meta_valid     (out_meta_valid),
    .out_meta_ready     (1'b1), // Never full
    .clk_status         (clk_status),
    .status_addr        (status_addr),
    .status_read        (status_read),
    .status_write       (status_write),
    .status_writedata   (status_writedata),
    .status_readdata    (status_readdata_sm),
    .status_readdata_valid (status_readdata_valid_sm)
);

assign status_readdata_ruleID = 0;
assign status_readdata_valid_ruleID = 0;

endmodule
