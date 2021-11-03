`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module stream_mux_service (
    input logic Clk, 
    input logic Rst_n,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt out
);

    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta(); 
    channel_if#(.WIDTH(512)) blank[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta(); 

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
        .rx(blank_meta),
        .tx(port_meta)
    );
    client_epig_shim#(.DATA_BITS(512)) in_rule_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_usr),
        .rx(blank[1]),
        .tx(port[1])
    );

stream_mux my_sm (
    // Clk & rst
    .clk(Clk),
    .rst(~Rst_n),

    // In Pkt data
    .in_pkt_data(port[0].data),
    .in_pkt_valid(port[0].valid),
    .in_pkt_sop(port[0].sop),
    .in_pkt_eop(port[0].eop),
    .in_pkt_empty(port[0].empty),
    .in_pkt_ready(port[0].ready),

    // In Meta data
    .in_meta_data(port_meta.data),
    .in_meta_valid(port_meta.valid),
    .in_meta_ready(port_meta.ready),

    // In User data
    .in_usr_data(port[1].data),
    .in_usr_valid(port[1].valid),
    .in_usr_sop(port[1].sop),
    .in_usr_eop(port[1].eop),
    .in_usr_empty(port[1].empty),
    .in_usr_ready(port[1].ready),

    // Out 
    .out_data(port[2].data),
    .out_valid(port[2].valid),
    .out_sop(port[2].sop),
    .out_eop(port[2].eop),
    .out_empty(port[2].empty),
    .out_ready(port[2].ready),
    .out_almost_full(port[2].almost_full)
);

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out),
        .tx(blank[2]),
        .rx(port[2])
    );

endmodule
