`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module channel_fifo_service #(
    parameter DUAL_CLOCK = 0
   ) (
    input logic Clk_i, 
    input logic Rst_n_i,
    input logic Clk_o, 
    input logic Rst_n_o,

    output logic [31:0] stats_in_pkt,
    output logic [31:0] stats_in_pkt_sop,
    output logic [31:0] stats_in_meta,
    output logic [31:0] stats_in_rule,
    output logic [31:0] in_pkt_fill_level,

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
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .svr2fl(in_pkt),
        .rx(blank[0]),
        .tx(port[0])
    );
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_cs
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .svr2fl(in_meta),
        .rx(blank_meta[0]),
        .tx(port_meta[0])
    );
    client_epig_shim#(.DATA_BITS(512)) in_rule_cs
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .svr2fl(in_usr),
        .rx(blank[1]),
        .tx(port[1])
    );

channel_fifo#(
    .DUAL_CLOCK(DUAL_CLOCK)
   ) FIFO(
    .in_clk                 (Clk_i),
    .in_rst                 (~Rst_n_i),
    .out_clk                 (Clk_o),
    .out_rst                 (~Rst_n_o),
    .in_pkt_sop             (port[0].sop),
    .in_pkt_eop             (port[0].eop),
    .in_pkt_data            (port[0].data),
    .in_pkt_empty           (port[0].empty),
    .in_pkt_valid           (port[0].valid),
    .in_pkt_ready           (port[0].ready),
    .in_pkt_almost_full     (port[0].almost_full),
    .in_meta_valid          (port_meta[0].valid),
    .in_meta_data           (port_meta[0].data),
    .in_meta_ready          (port_meta[0].ready),
    .in_meta_almost_full    (port_meta[0].almost_full),
    .in_usr_sop             (port[1].sop),
    .in_usr_eop             (port[1].eop),
    .in_usr_data            (port[1].data),
    .in_usr_empty           (port[1].empty),
    .in_usr_valid           (port[1].valid),
    .in_usr_ready           (port[1].ready),
    .in_usr_almost_full     (port[1].almost_full),
    .out_pkt_sop            (port[2].sop),
    .out_pkt_eop            (port[2].eop),
    .out_pkt_data           (port[2].data),
    .out_pkt_empty          (port[2].empty),
    .out_pkt_valid          (port[2].valid),
    .out_pkt_ready          (port[2].ready),
    .out_pkt_almost_full    (port[2].almost_full),
    .out_pkt_channel        (port[2].channel),
    .out_meta_valid         (port_meta[1].valid),
    .out_meta_data          (port_meta[1].data),
    .out_meta_ready         (port_meta[1].ready),
    .out_meta_almost_full   (port_meta[1].almost_full),
    .out_meta_channel       (port_meta[1].channel),
    .out_usr_sop            (port[3].sop),
    .out_usr_eop            (port[3].eop),
    .out_usr_data           (port[3].data),
    .out_usr_empty          (port[3].empty),
    .out_usr_valid          (port[3].valid),
    .out_usr_ready          (port[3].ready),
    .out_usr_almost_full    (port[3].almost_full),
    .out_usr_channel        (port[3].channel),
    .in_pkt_fill_level      (in_pkt_fill_level)
);

generate
if (DUAL_CLOCK==1) begin
    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk_o),
        .SoftReset(~Rst_n_o),
        .fl2clt(out_pkt),
        .tx(blank[2]),
        .rx(port[2])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk_o),
        .SoftReset(~Rst_n_o),
        .fl2clt(out_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );
    server_epig_shim#(.DATA_BITS(512)) in_rule_ss
    (
        .clk(Clk_o),
        .SoftReset(~Rst_n_o),
        .fl2clt(out_usr),
        .tx(blank[3]),
        .rx(port[3])
    );
end else begin
    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .fl2clt(out_pkt),
        .tx(blank[2]),
        .rx(port[2])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .fl2clt(out_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );
    server_epig_shim#(.DATA_BITS(512)) in_rule_ss
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .fl2clt(out_usr),
        .tx(blank[3]),
        .rx(port[3])
    );

end
endgenerate

    stats_cnt in_meta_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (port_meta[0].valid),
        .ready      (port_meta[0].ready),
        .stats_flit (stats_in_meta)
    );

    stats_cnt in_pkt_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (port[0].valid),
        .ready      (port[0].ready),
        .eop        (port[0].eop),
        .sop        (port[0].sop),
        .stats_pkt  (stats_in_pkt),
        .stats_pkt_sop  (stats_in_pkt_sop)
    );

    stats_cnt_rule in_rule_inst(
        .Clk        (Clk_i),
        .Rst_n      (Rst_n_i),
        .valid      (port[1].valid),
        .ready      (port[1].ready),
        .data       (port[1].data),
        .eop        (port[1].eop),
        .sop        (port[1].sop),
        .stats_rule (stats_in_rule)
    );

endmodule
