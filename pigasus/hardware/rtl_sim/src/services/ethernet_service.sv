`include "active_msg.vh"
`include "channel_if.vh"

module ethernet_service (
    input logic Clk, 
    input logic Rst_n,

    output  logic           out_valid,
    input   logic           out_ready,
    output  logic [511: 0]  out_data,
    output  logic           out_sop,
    output  logic           out_eop,
    output  logic [5 : 0]   out_empty,
    input   logic           out_almost_full,

    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic           in_ready,

    server.clt in,
    server.svr out
);

  assign out_valid = out.txP.tx;
  assign out_data = out.txP.tx_msg.data;
  assign out_sop = out.txP.tx_msg.head.arg3[0];
  assign out_eop = out.txP.tx_msg.head.arg3[1];
  assign out_empty = out.txP.tx_msg.head.arg3[7:2];
  assign out.txFull = ~out_ready;
  assign out.txAlmostFull = out_almost_full;

  always_comb begin
         in.txP.tx_msg.head = '0;
         in.txP.tx_msg.head.arg3 = {32'd0}|{in_empty,in_eop,in_sop};
  end
  assign in.txP.tx_msg.data = in_data; 
  assign in.txP.tx = in_valid; 
  assign in_ready  = ~in.txFull;

endmodule
