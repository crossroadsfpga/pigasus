`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module parser_client (
    input   logic                       Clk,
    input   logic                       Rst_n,
    output  logic [31:0]                stats_out_meta,
 
    server.svr in_meta,
    server.svr in_pkt,
    server.clt out_meta
);
    channel_if#(.WIDTH(512)) port(); 
    channel_if#(.WIDTH(512)) blank(); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[2](); 


    client_epig_shim#(.DATA_BITS(512)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_pkt),
        .rx(blank),
        .tx(port)
    );
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_meta),
        .rx(blank_meta[0]),
        .tx(port_meta[0])
    );

    parser parser_inst (
        .clk            (Clk),
        .rst            (~Rst_n),
        .in_pkt_data    (port.data),
        .in_pkt_valid   (port.valid),
        .in_pkt_ready   (port.ready),
        .in_pkt_sop     (port.sop),
        .in_pkt_eop     (port.eop),
        .in_pkt_empty   (port.empty),
        .out_pkt_data   (),
        .out_pkt_valid  (),
        .out_pkt_ready  (),
        .out_pkt_sop    (),
        .out_pkt_eop    (),
        .out_pkt_empty  (),
        .in_meta_data   (port_meta[0].data),
        .in_meta_valid  (port_meta[0].valid),
        .in_meta_ready  (port_meta[0].ready),
        .out_meta_data  (port_meta[1].data),
        .out_meta_valid (port_meta[1].valid),
        .out_meta_ready (port_meta[1].ready)
    );

    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port_meta[1].valid),
        .ready      (port_meta[1].ready),
        .stats_flit (stats_out_meta)
    );

endmodule
