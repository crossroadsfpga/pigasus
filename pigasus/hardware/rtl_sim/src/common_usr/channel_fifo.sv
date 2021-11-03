`timescale 1 ps / 1 ps
`include "./src/struct_s.sv"
module channel_fifo #(
    parameter DUAL_CLOCK = 0,
    parameter FULL_LEVEL = 450,
    parameter FIFO_DEPTH = 512
)(
    input   logic           in_clk,
    input   logic           in_rst,
    input   logic           out_clk,
    input   logic           out_rst,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,
    output  logic           in_pkt_almost_full,

    // In Meta data
    input   logic           in_meta_valid,
    input   metadata_t      in_meta_data,
    output  logic           in_meta_ready,
    output  logic           in_meta_almost_full,

    // In User data
    input   logic           in_usr_sop,
    input   logic           in_usr_eop,
    input   logic [511:0]   in_usr_data,
    input   logic [5:0]     in_usr_empty,
    input   logic           in_usr_valid,
    output  logic           in_usr_ready,
    output  logic           in_usr_almost_full,

    // Out Pkt data
    output  logic [511:0]   out_pkt_data,
    output  logic           out_pkt_valid,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready,
    input   logic           out_pkt_almost_full,
    output  logic [1:0]     out_pkt_channel,

    // Out Meta data
    output  metadata_t      out_meta_data,
    output  logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,
    output  logic [1:0]     out_meta_channel,

    // Out User data
    output  logic [511:0]   out_usr_data,
    output  logic           out_usr_valid,
    output  logic           out_usr_sop,
    output  logic           out_usr_eop,
    output  logic [5:0]     out_usr_empty,
    input   logic           out_usr_ready,
    input   logic           out_usr_almost_full,
    output  logic [1:0]     out_usr_channel,
    output  logic [31:0]    in_pkt_fill_level
);

logic [31:0] in_pkt_csr_readdata;
logic [31:0] in_meta_csr_readdata;
logic [31:0] in_usr_csr_readdata;

assign in_pkt_fill_level = in_pkt_csr_readdata;

unified_pkt_fifo  #(
    .FIFO_NAME        ("[channel] pkt_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (DUAL_CLOCK),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (FIFO_DEPTH)
) pkt_fifo (
    .in_clk            (in_clk),
    .in_reset          (in_rst),
    .out_clk           (out_clk),
    .out_reset         (out_rst),
    .in_data           (in_pkt_data),
    .in_valid          (in_pkt_valid),
    .in_ready          (in_pkt_ready),
    .in_startofpacket  (in_pkt_sop),
    .in_endofpacket    (in_pkt_eop),
    .in_empty          (in_pkt_empty),
    .out_data          (out_pkt_data),
    .out_valid         (out_pkt_valid),
    .out_ready         (out_pkt_ready),
    .out_startofpacket (out_pkt_sop),
    .out_endofpacket   (out_pkt_eop),
    .out_empty         (out_pkt_empty),
    .fill_level        (in_pkt_csr_readdata),
    .almost_full       (in_pkt_almost_full),
    .overflow          ()
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[channel] usr_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (DUAL_CLOCK),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (FIFO_DEPTH)
) usr_fifo (
    .in_clk            (in_clk),
    .in_reset          (in_rst),
    .out_clk           (out_clk),
    .out_reset         (out_rst),
    .in_data           (in_usr_data),
    .in_valid          (in_usr_valid),
    .in_ready          (in_usr_ready),
    .in_startofpacket  (in_usr_sop),
    .in_endofpacket    (in_usr_eop),
    .in_empty          (in_usr_empty),
    .out_data          (out_usr_data),
    .out_valid         (out_usr_valid),
    .out_ready         (out_usr_ready),
    .out_startofpacket (out_usr_sop),
    .out_endofpacket   (out_usr_eop),
    .out_empty         (out_usr_empty),
    .fill_level        (in_usr_csr_readdata),
    .almost_full       (in_usr_almost_full),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[channel] meta_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (DUAL_CLOCK),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (FIFO_DEPTH)
) meta_fifo (
    .in_clk            (in_clk),
    .in_reset          (in_rst),
    .out_clk           (out_clk),
    .out_reset         (out_rst),
    .in_data           (in_meta_data),
    .in_valid          (in_meta_valid),
    .in_ready          (in_meta_ready),
    .out_data          (out_meta_data),
    .out_valid         (out_meta_valid),
    .out_ready         (out_meta_ready),
    .fill_level        (in_meta_csr_readdata),
    .almost_full       (in_meta_almost_full),
    .overflow          ()
);
endmodule
