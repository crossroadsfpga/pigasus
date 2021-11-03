`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module string_matcher_client (
    input logic Clk, 
    input logic Rst_n,
    input logic Clk_front, 
    input logic Rst_front_n,
    input logic Clk_back, 
    input logic Rst_back_n,

    //stats
    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,

    output logic [31:0]     sm_bypass_af,
    output logic [31:0]     sm_cdc_af,

    server.svr in_pkt,
    server.svr in_meta,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr
);
    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 
    channel_if#(.WIDTH(512)) blank[3](); 
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

    string_matcher_wrapper sm_inst(
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .front_clk              (Clk_front),
        .front_rst              (~Rst_front_n),
        .back_clk               (Clk_back),
        .back_rst               (~Rst_back_n),
        //.in_pkt_hdr             (dm_check_pkt_hdr),
        .in_pkt_sop             (port[0].sop),
        .in_pkt_eop             (port[0].eop),
        .in_pkt_data            (port[0].data),
        .in_pkt_empty           (port[0].empty),
        .in_pkt_valid           (port[0].valid),
        .in_pkt_ready           (port[0].ready),
        .in_pkt_almost_full     (),
        .in_meta_valid          (port_meta[0].valid),
        .in_meta_data           (port_meta[0].data),
        .in_meta_ready          (port_meta[0].ready),
        .in_meta_almost_full    (),
        //no usr input
        .in_usr_sop             (1'b0),
        .in_usr_eop             (1'b0),
        .in_usr_data            (512'b0),
        .in_usr_empty           (6'b0),
        .in_usr_valid           (1'b0),
        .in_usr_ready           (),
        .out_pkt_sop            (port[1].sop),
        .out_pkt_eop            (port[1].eop),
        .out_pkt_data           (port[1].data),
        .out_pkt_empty          (port[1].empty),
        .out_pkt_valid          (port[1].valid),
        .out_pkt_ready          (port[1].ready),
        .out_pkt_almost_full    (port[1].almost_full),
        .out_pkt_channel        (port[1].channel),
        .out_meta_valid         (port_meta[1].valid),
        .out_meta_data          (port_meta[1].data),
        .out_meta_ready         (port_meta[1].ready),
        .out_meta_almost_full   (1'b0),
        .out_meta_channel       (),
        .out_usr_sop            (port[2].sop),
        .out_usr_eop            (port[2].eop),
        .out_usr_data           (port[2].data),
        .out_usr_empty          (port[2].empty),
        .out_usr_valid          (port[2].valid),
        .out_usr_ready          (port[2].ready),
        .out_usr_almost_full    (port[2].almost_full),
        .out_usr_channel        (),
        .sm_bypass_af           (sm_bypass_af),
        .sm_cdc_af              (sm_cdc_af)
    );

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk_back),
        .SoftReset(~Rst_back_n),
        .fl2clt(out_pkt),
        .tx(blank[1]),
        .rx(port[1])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk_back),
        .SoftReset(~Rst_back_n),
        .fl2clt(out_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );
    server_epig_shim#(.DATA_BITS(512)) in_rule_ss
    (
        .clk(Clk_back),
        .SoftReset(~Rst_back_n),
        .fl2clt(out_usr),
        .tx(blank[2]),
        .rx(port[2])
    );
    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (port_meta[1].valid),
        .ready      (port_meta[1].ready),
        .stats_flit (stats_out_meta)
    );
    stats_cnt out_pkt_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (port[1].valid),
        .ready      (port[1].ready),
        .eop        (port[1].eop),
        .sop        (port[1].sop),
        .stats_pkt  (stats_out_pkt)
    );
    stats_cnt_rule out_rule_inst(
        .Clk        (Clk_back),
        .Rst_n      (Rst_back_n),
        .valid      (port[2].valid),
        .ready      (port[2].ready),
        .data       (port[2].data),
        .eop        (port[2].eop),
        .sop        (port[2].sop),
        .stats_rule (stats_out_rule)
    );

endmodule
