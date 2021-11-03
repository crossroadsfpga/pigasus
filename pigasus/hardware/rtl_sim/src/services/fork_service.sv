`include "active_msg.vh"
`include "channel_if.vh"

module fork_service (
    input logic Clk, 
    input logic Rst_n,
    output logic [31:0]     stats_in_pkt,
    output logic [31:0]     stats_out_pkt0,
    output logic [31:0]     stats_out_pkt1,
    output logic [31:0]     stats_in_pkt_s,
    output logic [31:0]     stats_out_pkt0_s,
    output logic [31:0]     stats_out_pkt1_s,

    server.svr in,
    server.clt out0,
    server.clt out1
);

    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH(512)) blank[3](); 

    client_epig_shim#(.DATA_BITS(512)) in_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in),
        .rx(blank[0]),
        .tx(port[0])
    );

    fork_2 sm_fork (
        .clk                   (Clk),
        .rst                   (Rst_n),
        .in_pkt_data           (port[0].data),
        .in_pkt_valid          (port[0].valid),
        .in_pkt_ready          (port[0].ready),
        .in_pkt_sop            (port[0].sop),
        .in_pkt_eop            (port[0].eop),
        .in_pkt_empty          (port[0].empty),
        .in_pkt_almost_full    (port[0].almost_full),
        .in_pkt_channel        (port[0].channel),
        .out_pkt_0_data        (port[1].data),
        .out_pkt_0_valid       (port[1].valid),
        .out_pkt_0_ready       (port[1].ready),
        .out_pkt_0_sop         (port[1].sop),
        .out_pkt_0_eop         (port[1].eop),
        .out_pkt_0_empty       (port[1].empty),
        .out_pkt_0_almost_full (port[1].almost_full),
        .out_pkt_1_data        (port[2].data),
        .out_pkt_1_valid       (port[2].valid),
        .out_pkt_1_ready       (port[2].ready),
        .out_pkt_1_sop         (port[2].sop),
        .out_pkt_1_eop         (port[2].eop),
        .out_pkt_1_empty       (port[2].empty),
        .out_pkt_1_almost_full (port[2].almost_full)
    );

    server_epig_shim#(.DATA_BITS(512)) out0_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out0),
        .tx(blank[1]),
        .rx(port[1])
    );

    server_epig_shim#(.DATA_BITS(512)) out1_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out1),
        .tx(blank[2]),
        .rx(port[2])
    );

    stats_cnt in_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[0].valid),
        .ready      (port[0].ready),
        .eop        (port[0].eop),
        .sop        (port[0].sop),
        .stats_pkt  (stats_in_pkt),
        .stats_pkt_sop  (stats_in_pkt_s)
    );
    stats_cnt out_pkt0_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[1].valid),
        .ready      (port[1].ready),
        .eop        (port[1].eop),
        .sop        (port[1].sop),
        .stats_pkt  (stats_out_pkt0),
        .stats_pkt_sop  (stats_out_pkt0_s)
    );
    stats_cnt out_pkt1_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[2].valid),
        .ready      (port[2].ready),
        .eop        (port[2].eop),
        .sop        (port[2].sop),
        .stats_pkt  (stats_out_pkt1),
        .stats_pkt_sop  (stats_out_pkt1_s)
    );

endmodule
