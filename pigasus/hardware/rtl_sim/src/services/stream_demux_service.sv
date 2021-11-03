`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module stream_demux_service (
    input logic Clk, 
    input logic Rst_n,

    server.svr in,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr
);

    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta(); 
    channel_if#(.WIDTH(512)) blank[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta(); 

    client_epig_shim#(.DATA_BITS(512)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in),
        .rx(blank[0]),
        .tx(port[0])
    );

stream_demux my_sdm (
    // Clk & rst
    .clk(Clk),
    .rst(~Rst_n),

    // In 
    .in_data(port[0].data),
    .in_valid(port[0].valid),
    .in_sop(port[0].sop),
    .in_eop(port[0].eop),
    .in_empty(port[0].empty),
    .in_ready(port[0].ready),

    // out Pkt data
    .out_pkt_data(port[1].data),
    .out_pkt_valid(port[1].valid),
    .out_pkt_sop(port[1].sop),
    .out_pkt_eop(port[1].eop),
    .out_pkt_empty(port[1].empty),
    .out_pkt_ready(port[1].ready),
    .out_pkt_almost_full(port[1].almost_full),

    // Out Meta data
    .out_meta_data(port_meta.data),
    .out_meta_valid(port_meta.valid),
    .out_meta_ready(port_meta.ready),
    .out_meta_almost_full(port_meta.almost_full),

    // Out User data
    .out_usr_data(port[2].data),
    .out_usr_valid(port[2].valid),
    .out_usr_sop(port[2].sop),
    .out_usr_eop(port[2].eop),
    .out_usr_empty(port[2].empty),
    .out_usr_ready(port[2].ready),
    .out_usr_almost_full(port[2].almost_full)
);

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_pkt),
        .tx(blank[1]),
        .rx(port[1])
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_meta),
        .tx(blank_meta),
        .rx(port_meta)
    );
    server_epig_shim#(.DATA_BITS(512)) in_rule_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_usr),
        .tx(blank[2]),
        .rx(port[2])
    );

endmodule
