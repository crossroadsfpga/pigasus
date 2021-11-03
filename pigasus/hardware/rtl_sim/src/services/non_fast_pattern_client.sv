`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module non_fast_pattern_client (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_high, 
    input logic Rst_high_n,

    //stats
    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output  logic [31:0]    max_raw_pkt_fifo,
    output  logic [31:0]    max_pkt_fifo,
    output  logic [31:0]    max_rule_fifo,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr
);
    channel_if#(.WIDTH(512)) port[4](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 
    channel_if#(.WIDTH(512)) blank[4](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[2](); 

    client_epig_shim#(.DATA_BITS(512)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_pkt),
        .rx(blank[0]),
        .tx(port[0])
    );
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_meta),
        .rx(blank_meta[0]),
        .tx(port_meta[0])
    );
    client_epig_shim#(.DATA_BITS(512)) in_rule_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_usr),
        .rx(blank[1]),
        .tx(port[1])
    );

    non_fast_pattern_wrapper non_fast_pattern_inst(
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .clk_high               (Clk_high),
        .rst_high               (~Rst_high_n),
        .in_pkt_sop             (port[0].sop),
        .in_pkt_eop             (port[0].eop),
        .in_pkt_data            (port[0].data),
        .in_pkt_empty           (port[0].empty),
        .in_pkt_valid           (port[0].valid),
        .in_pkt_ready           (port[0].ready),
        .in_pkt_almost_full     (),
        .in_meta_valid          (port_meta[0].valid),
        .in_meta_ready          (port_meta[0].ready),
        .in_meta_data           (port_meta[0].data),
        .in_meta_almost_full    (),
        .in_usr_sop             (port[1].sop),
        .in_usr_eop             (port[1].eop),
        .in_usr_data            (port[1].data),
        .in_usr_empty           (port[1].empty),
        .in_usr_valid           (port[1].valid),
        .in_usr_ready           (port[1].ready),
        .out_pkt_data           (port[2].data),
        .out_pkt_sop            (port[2].sop),
        .out_pkt_eop            (port[2].eop),
        .out_pkt_empty          (port[2].empty),
        .out_pkt_valid          (port[2].valid),
        .out_pkt_ready          (port[2].ready),
        .out_pkt_almost_full    (port[2].almost_full),
        .out_pkt_channel        (port[2].channel),
        .out_meta_data          (port_meta[1].data),
        .out_meta_valid         (port_meta[1].valid),
        .out_meta_ready         (port_meta[1].ready),
        .out_meta_almost_full   (port_meta[1].almost_full),
        .out_meta_channel       (),
        .out_usr_data           (port[3].data),
        .out_usr_sop            (port[3].sop),
        .out_usr_eop            (port[3].eop),
        .out_usr_empty          (port[3].empty),
        .out_usr_valid          (port[3].valid),
        .out_usr_ready          (port[3].ready),
        .out_usr_almost_full    (port[3].almost_full),
        .out_usr_channel        (),
        .max_raw_pkt_fifo       (max_raw_pkt_fifo),
        .max_pkt_fifo           (max_pkt_fifo),
        .max_rule_fifo          (max_rule_fifo)
    );

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_pkt),
        .tx(blank[2]),
        .rx(port[2])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );
    server_epig_shim#(.DATA_BITS(512)) in_rule_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_usr),
        .tx(blank[3]),
        .rx(port[3])
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port_meta[1].valid),
        .ready      (port_meta[1].ready),
        .stats_flit (stats_out_meta)
    );
    stats_cnt out_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[2].valid),
        .ready      (port[2].ready),
        .eop        (port[2].eop),
        .sop        (port[2].sop),
        .stats_pkt  (stats_out_pkt)
    );
    stats_cnt_rule out_rule_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[3].valid),
        .ready      (port[3].ready),
        .data       (port[3].data),
        .eop        (port[3].eop),
        .sop        (port[3].sop),
        .stats_rule (stats_out_rule)
    );

endmodule
