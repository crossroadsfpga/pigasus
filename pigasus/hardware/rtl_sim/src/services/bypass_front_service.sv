`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module bypass_front_service (
    input logic Clk, 
    input logic Rst_n,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr,
    server.clt bypass_pkt,
    server.clt bypass_meta,
    server.clt bypass_usr
);
    channel_if#(.WIDTH(512)) port[6](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[3](); 
    channel_if#(.WIDTH(512)) blank[6](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[3](); 

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

bypass_nf_front bypass_nf_front_inst(
    .clk                    (Clk),
    .rst                    (~Rst_n),
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
    .in_usr_almost_full     (),
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
    .bypass_pkt_data           (port[4].data),
    .bypass_pkt_sop            (port[4].sop),
    .bypass_pkt_eop            (port[4].eop),
    .bypass_pkt_empty          (port[4].empty),
    .bypass_pkt_valid          (port[4].valid),
    .bypass_pkt_ready          (port[4].ready),
    .bypass_pkt_almost_full    (port[4].almost_full),
    .bypass_pkt_channel        (),
    .bypass_meta_data          (port_meta[2].data),
    .bypass_meta_valid         (port_meta[2].valid),
    .bypass_meta_ready         (port_meta[2].ready),
    .bypass_meta_almost_full   (port_meta[2].almost_full),
    .bypass_meta_channel       (),
    .bypass_usr_data           (port[5].data),
    .bypass_usr_sop            (port[5].sop),
    .bypass_usr_eop            (port[5].eop),
    .bypass_usr_empty          (port[5].empty),
    .bypass_usr_valid          (port[5].valid),
    .bypass_usr_ready          (port[5].ready),
    .bypass_usr_almost_full    (port[5].almost_full),
    .bypass_usr_channel        ()
);

    server_epig_shim#(.DATA_BITS(512)) bp_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_pkt),
        .tx(blank[4]),
        .rx(port[4])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) bp_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_meta),
        .tx(blank_meta[2]),
        .rx(port_meta[2])
    );
    server_epig_shim#(.DATA_BITS(512)) bp_rule_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_usr),
        .tx(blank[5]),
        .rx(port[5])
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

endmodule

module bypass_front_service_round_robin (
    input logic Clk, 
    input logic Rst_n,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr,
    server.clt bypass_pkt,
    server.clt bypass_meta,
    server.clt bypass_usr
);
    channel_if#(.WIDTH(512)) port[6](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[3](); 
    channel_if#(.WIDTH(512)) blank[6](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[3](); 

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

bypass_nf_front_rr bypass_nf_front_inst(
    .clk                    (Clk),
    .rst                    (~Rst_n),
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
    .in_usr_almost_full     (),
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
    .bypass_pkt_data           (port[4].data),
    .bypass_pkt_sop            (port[4].sop),
    .bypass_pkt_eop            (port[4].eop),
    .bypass_pkt_empty          (port[4].empty),
    .bypass_pkt_valid          (port[4].valid),
    .bypass_pkt_ready          (port[4].ready),
    .bypass_pkt_almost_full    (port[4].almost_full),
    .bypass_pkt_channel        (),
    .bypass_meta_data          (port_meta[2].data),
    .bypass_meta_valid         (port_meta[2].valid),
    .bypass_meta_ready         (port_meta[2].ready),
    .bypass_meta_almost_full   (port_meta[2].almost_full),
    .bypass_meta_channel       (),
    .bypass_usr_data           (port[5].data),
    .bypass_usr_sop            (port[5].sop),
    .bypass_usr_eop            (port[5].eop),
    .bypass_usr_empty          (port[5].empty),
    .bypass_usr_valid          (port[5].valid),
    .bypass_usr_ready          (port[5].ready),
    .bypass_usr_almost_full    (port[5].almost_full),
    .bypass_usr_channel        ()
);

    server_epig_shim#(.DATA_BITS(512)) bp_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_pkt),
        .tx(blank[4]),
        .rx(port[4])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) bp_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_meta),
        .tx(blank_meta[2]),
        .rx(port_meta[2])
    );
    server_epig_shim#(.DATA_BITS(512)) bp_rule_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(bypass_usr),
        .tx(blank[5]),
        .rx(port[5])
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

endmodule
