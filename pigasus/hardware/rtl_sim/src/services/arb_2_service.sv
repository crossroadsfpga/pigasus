`include "active_msg.vh"
`include "channel_if.vh"

module arb_2_service#(
    parameter DWIDTH=8,
    parameter DEPTH=1024
   ) (
    input logic Clk, 
    input logic Rst_n,

    server.svr in0,
    server.svr in1,
    server.clt out
);

    channel_if#(.WIDTH(DWIDTH)) port[3](); 
    channel_if#(.WIDTH(DWIDTH)) blank[3](); 

    client_epig_shim#(.DATA_BITS(DWIDTH)) in0_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in0),
        .rx(blank[0]),
        .tx(port[0])
    );

    client_epig_shim#(.DATA_BITS(DWIDTH)) in1_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in1),
        .rx(blank[1]),
        .tx(port[1])
    );

arb_2_wrapper #(
    .DWIDTH(DWIDTH),
    .DEPTH(DEPTH)
)
arb_forward(
    .clk        (Clk),
    .rst        (~Rst_n),
    .clk_out    (Clk),
    .rst_out    (~Rst_n),
    .in_data_0  (port[0].data),
    .in_valid_0 (port[0].valid),
    .in_ready_0 (port[0].ready),
    .in_data_1  (port[1].data),
    .in_valid_1 (port[1].valid),
    .in_ready_1 (port[1].ready),
    .out_data   (port[2].data),
    .out_valid  (port[2].valid),
    .out_ready  (port[2].ready)
);

    server_epig_shim#(.DATA_BITS(DWIDTH)) out_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out),
        .tx(blank[2]),
        .rx(port[2])
    );

endmodule
