`include "active_msg.vh"
`include "channel_if.vh"

module ethernet_mux_service (
    input logic Clk, 
    input logic Rst_n,

    output reg              out_valid,
    input                   out_ready,
    output reg    [511: 0]  out_data,
    output reg              out_startofpacket,
    output reg              out_endofpacket,
    output reg    [5 : 0]   out_empty,

    server.svr in0,
    server.svr in1,
    server.svr in2,
    server.svr in3,
    server.svr in4
);
  server#(.DATA_BITS(512)) mux();
  server#(.DATA_BITS(512)) out();

  assign out_valid = out.txP.tx;
  assign out_data = out.txP.tx_msg.data;
  assign out_startofpacket = out.txP.tx_msg.head.arg3[0];
  assign out_endofpacket = out.txP.tx_msg.head.arg3[1];
  assign out_empty = out.txP.tx_msg.head.arg3[7:2];
  assign out.txFull = ~out_ready;

  pkt_mux_service_3 mux_hi (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in0(in0),
    .in1(in1),
    .in2(in2),
    .out(mux)
  );

  pkt_mux_service_3 mux_lo (
    .Clk(Clk), 
    .Rst_n(Rst_n),

    .in0(mux),
    .in1(in3),
    .in2(in4),
    .out(out)
  );

endmodule

module pkt_mux_service (
    input logic Clk, 
    input logic Rst_n,

    server.svr in0,
    server.svr in1,
    server.clt out
);

    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH(512)) blank[3](); 

    client_epig_shim#(.DATA_BITS(512)) in0_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in0),
        .rx(blank[0]),
        .tx(port[0])
    );

    client_epig_shim#(.DATA_BITS(512)) in1_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in1),
        .rx(blank[1]),
        .tx(port[1])
    );

st_multiplexer_pkt multiplexer_nf (
    .clk               (Clk),
    .reset_n           (Rst_n),
    .out_data          (port[2].data),
    .out_valid         (port[2].valid),
    .out_ready         (port[2].ready),
    .out_startofpacket (port[2].sop),
    .out_endofpacket   (port[2].eop),
    .out_empty         (port[2].empty),
    .out_channel       (),
    .in0_data          (port[0].data),
    .in0_valid         (port[0].valid),
    .in0_ready         (port[0].ready),
    .in0_startofpacket (port[0].sop),
    .in0_endofpacket   (port[0].eop),
    .in0_empty         (port[0].empty),
    .in1_data          (port[1].data),
    .in1_valid         (port[1].valid),
    .in1_ready         (port[1].ready),
    .in1_startofpacket (port[1].sop),
    .in1_endofpacket   (port[1].eop),
    .in1_empty         (port[1].empty)
);

    server_epig_shim#(.DATA_BITS(512)) out_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out),
        .tx(blank[2]),
        .rx(port[2])
    );

endmodule

module pkt_mux_service_3 (
    input logic Clk, 
    input logic Rst_n,

    server.svr in0,
    server.svr in1,
    server.svr in2,
    server.clt out
);

    channel_if#(.WIDTH(512)) port[4](); 
    channel_if#(.WIDTH(512)) blank[4](); 

    client_epig_shim#(.DATA_BITS(512)) in0_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in0),
        .rx(blank[0]),
        .tx(port[0])
    );

    client_epig_shim#(.DATA_BITS(512)) in1_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in1),
        .rx(blank[1]),
        .tx(port[1])
    );

    client_epig_shim#(.DATA_BITS(512)) in2_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in2),
        .rx(blank[2]),
        .tx(port[2])
    );

st_multiplexer_pkt_3 multiplexer_pkt1 (
    .clk               (Clk),
    .reset_n           (Rst_n),
    .out_data          (port[3].data),
    .out_valid         (port[3].valid),
    .out_ready         (port[3].ready),
    .out_startofpacket (port[3].sop),
    .out_endofpacket   (port[3].eop),
    .out_empty         (port[3].empty),
    .out_channel       (),
    .in0_data          (port[0].data),
    .in0_valid         (port[0].valid),
    .in0_ready         (port[0].ready),
    .in0_startofpacket (port[0].sop),
    .in0_endofpacket   (port[0].eop),
    .in0_empty         (port[0].empty),
    .in1_data          (port[1].data),
    .in1_valid         (port[1].valid),
    .in1_ready         (port[1].ready),
    .in1_startofpacket (port[1].sop),
    .in1_endofpacket   (port[1].eop),
    .in1_empty         (port[1].empty),
    .in2_data          (port[2].data),
    .in2_valid         (port[2].valid),
    .in2_ready         (port[2].ready),
    .in2_startofpacket (port[2].sop),
    .in2_endofpacket   (port[2].eop),
    .in2_empty         (port[2].empty)
);

    server_epig_shim#(.DATA_BITS(512)) out_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out),
        .tx(blank[3]),
        .rx(port[3])
    );

endmodule
