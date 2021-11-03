`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module input_comp_client (
    input   logic                       Clk,
    input   logic                       Rst_n,
    output  logic [31:0]                stats_out_meta,

    input   logic                       eth_sop,
    input   logic                       eth_eop,
    input   logic [511:0]               eth_data,
    input   logic [5:0]                 eth_empty,
    input   logic                       eth_valid,
    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_address,
    output  logic                       pkt_buffer_write,
    output  flit_t                      pkt_buffer_writedata,
    
    server.svr emptylist,
    server.clt pkt,
    server.clt meta
);

    channel_if#(.WIDTH(PKT_AWIDTH)) port_empty(); 
    channel_if#(.WIDTH(PKT_AWIDTH)) blank_empty(); 
    channel_if#(.WIDTH(512)) port(); 
    channel_if#(.WIDTH(512)) blank(); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta(); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta(); 

    client_epig_shim#(.DATA_BITS(PKT_AWIDTH)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(emptylist),
        .rx(blank_empty),
        .tx(port_empty)
    );

    input_comp input_comp_inst (
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .eth_sop                (eth_sop),
        .eth_eop                (eth_eop),
        .eth_data               (eth_data),
        .eth_empty              (eth_empty),
        .eth_valid              (eth_valid),
        .pkt_buffer_address     (pkt_buffer_address),
        .pkt_buffer_write       (pkt_buffer_write),
        .pkt_buffer_writedata   (pkt_buffer_writedata),
        .emptylist_out_data     (port_empty.data),
        .emptylist_out_valid    (port_empty.valid),
        .emptylist_out_ready    (port_empty.ready),
        .pkt_sop                (port.sop),
        .pkt_eop                (port.eop),
        .pkt_valid              (port.valid),
        .pkt_data               (port.data),
        .pkt_empty              (port.empty),
        .pkt_ready              (port.ready),
        .meta_valid             (port_meta.valid),
        .meta_data              (port_meta.data),
        .meta_ready             (port_meta.ready)
    );

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(pkt),
        .tx(blank),
        .rx(port)
    );
    server_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(meta),
        .tx(blank_meta),
        .rx(port_meta)
    );

    //stats
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port_meta.valid),
        .ready      (port_meta.ready),
        .stats_flit (stats_out_meta)
    );


endmodule
