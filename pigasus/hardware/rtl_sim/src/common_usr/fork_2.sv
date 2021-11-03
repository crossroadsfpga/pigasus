`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps
//fork traffic to two destinations based on input channel
module fork_2 (
    // Clk & rst
    input   logic           clk,
    input   logic           rst,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,
    output  logic           in_pkt_almost_full,
    input   logic [1:0]     in_pkt_channel,

    // Out Pkt data
    output  logic [511:0]   out_pkt_0_data,
    output  logic           out_pkt_0_valid,
    output  logic           out_pkt_0_sop,
    output  logic           out_pkt_0_eop,
    output  logic [5:0]     out_pkt_0_empty,
    input   logic           out_pkt_0_ready,
    input   logic           out_pkt_0_almost_full,

    output  logic [511:0]   out_pkt_1_data,
    output  logic           out_pkt_1_valid,
    output  logic           out_pkt_1_sop,
    output  logic           out_pkt_1_eop,
    output  logic [5:0]     out_pkt_1_empty,
    input   logic           out_pkt_1_ready,
    input   logic           out_pkt_1_almost_full
);

//assign in_pkt_almost_full = (in_pkt_channel==0) ? out_pkt_0_almost_full : out_pkt_1_almost_full;
//assign in_pkt_ready = (in_pkt_channel==0) ? out_pkt_0_ready : out_pkt_1_ready;
//Above logic may lead to no backpressure. Just use the AND of both channel.
//Either way will have head-of-line blocking. It will not make a big
//difference to separe them
assign in_pkt_almost_full = out_pkt_0_almost_full | out_pkt_1_almost_full;
assign in_pkt_ready = out_pkt_0_ready & out_pkt_1_ready;

assign out_pkt_0_data  = in_pkt_data;
assign out_pkt_0_sop   = in_pkt_sop;
assign out_pkt_0_eop   = in_pkt_eop;
assign out_pkt_0_empty = in_pkt_empty;
assign out_pkt_0_valid = in_pkt_valid & (in_pkt_channel==0);

assign out_pkt_1_data  = in_pkt_data;
assign out_pkt_1_sop   = in_pkt_sop;
assign out_pkt_1_eop   = in_pkt_eop;
assign out_pkt_1_empty = in_pkt_empty;
assign out_pkt_1_valid = in_pkt_valid & (in_pkt_channel==1);

endmodule
