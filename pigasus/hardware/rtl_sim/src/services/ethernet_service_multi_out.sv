`include "active_msg.vh"
`include "channel_if.vh"

module ethernet_service_multi_out (
    input logic Clk, 
    input logic Rst_n,

    output reg              out_valid,
    input                   out_ready,
    output reg    [511: 0]  out_data,
    output reg              out_sop,
    output reg              out_eop,
    output reg    [5 : 0]   out_empty,
    input                   out_almostfull,

    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic           in_ready,

    server.clt in,
    server.svr out0,
    server.svr out1,
    server.svr out2,
    server.svr out3,
    server.svr out4
);
    server#(.DATA_BITS(512)) mux();
    server#(.DATA_BITS(512)) out();
    
    assign out_valid = out.txP.tx;
    assign out_data = out.txP.tx_msg.data;
    assign out_sop = out.txP.tx_msg.head.arg3[0];
    assign out_eop = out.txP.tx_msg.head.arg3[1];
    assign out_empty = out.txP.tx_msg.head.arg3[7:2];
    assign out.txFull = ~out_ready;
    assign out.txAlmostFull = out_almostfull;
    
    always_comb begin
        in.txP.tx_msg.head = '0;
        in.txP.tx_msg.head.arg3 = {32'd0}|{in_empty,in_eop,in_sop};
    end
    assign in.txP.tx_msg.data = in_data; 
    assign in.txP.tx = in_valid; 
    assign in_ready  = ~in.txFull;
    
    pkt_mux_service_3 mux_hi (
      .Clk(Clk), 
      .Rst_n(Rst_n),
    
      .in0(out0),
      .in1(out1),
      .in2(out2),
      .out(mux)
    );
    
    pkt_mux_service_3 mux_lo (
      .Clk(Clk), 
      .Rst_n(Rst_n),
    
      .in0(mux),
      .in1(out3),
      .in2(out4),
      .out(out)
    );

endmodule
