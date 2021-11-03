`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module pdu_gen_client (
    input logic Clk, 
    input logic Rst_n,

    output  flit_lite_t             pcie_rb_wr_data,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_wr_addr,
    output  logic                   pcie_rb_wr_en,
    input   logic [PDU_AWIDTH-1:0]  pcie_rb_wr_base_addr,
    input   logic                   pcie_rb_almost_full,
    output  logic                   pcie_rb_update_valid,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_update_size,
    input   logic                   disable_pcie,

    server.svr in,
    server.svr in_match,
    server.svr in_meta,
    server.svr emptylist,
    server.clt out,
    server.clt out_meta 
);
    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH(512)) blank[3](); 
    channel_if#(.WIDTH(PDUID_WIDTH)) port_empty(); 
    channel_if#(.WIDTH(PDUID_WIDTH)) blank_empty(); 
    channel_if#(.WIDTH($bits(pdu_metadata_t))) port_pdu_meta(); 
    channel_if#(.WIDTH($bits(pdu_metadata_t))) blank_pdu_meta(); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta(); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta(); 

    client_epig_shim#(.DATA_BITS(512)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in),
        .rx(blank[0]),
        .tx(port[0])
    );
    client_epig_shim#(.DATA_BITS(PDUID_WIDTH)) empty_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(emptylist),
        .rx(blank_empty),
        .tx(port_empty)
    );
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_meta),
        .rx(blank_meta),
        .tx(port_meta)
    );
    client_epig_shim#(.DATA_BITS(512)) in_match_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_match),
        .rx(blank[1]),
        .tx(port[1])
    );

pdu_gen pdu_gen_inst(
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .in_sop                 (port[0].sop),
    .in_eop                 (port[0].eop),
    .in_data                (port[0].data),
    .in_empty               (port[0].empty),
    .in_valid               (port[0].valid),
    .in_ready               (port[0].ready),
    .in_match_sop           (port[1].sop),
    .in_match_eop           (port[1].eop),
    .in_match_data          (port[1].data),
    .in_match_empty         (port[1].empty),
    .in_match_valid         (port[1].valid),
    .in_match_ready         (port[1].ready),
    .in_meta_valid          (port_meta.valid),
    .in_meta_ready          (port_meta.ready),
    .in_meta_data           (port_meta.data),
    .pcie_rb_wr_data        (pcie_rb_wr_data),
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),
    .pcie_rb_wr_en          (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),
    .pcie_rb_almost_full    (pcie_rb_almost_full),
    .pcie_rb_update_valid   (internal_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdu_emptylist_out_data (port_empty.data),
    .pdu_emptylist_out_valid(port_empty.valid),
    .pdu_emptylist_out_ready(port_empty.ready),
    .pdu_gen_data           (port[2].data),
    .pdu_gen_sop            (port[2].sop),
    .pdu_gen_eop            (port[2].eop),
    .pdu_gen_empty          (port[2].empty),
    .pdu_gen_valid          (port[2].valid),
    .pdu_gen_ready          (port[2].ready),
    .pdu_gen_almost_full    (port[2].almost_full),
    .pdumeta_gen_data       (port_pdu_meta.data),
    .pdumeta_gen_valid      (port_pdu_meta.valid),
    .pdumeta_gen_ready      (port_pdu_meta.ready)
);

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out),
        .tx(blank[2]),
        .rx(port[2])
    );
    server_epig_shim#(.DATA_BITS($bits(pdu_metadata_t))) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_meta),
        .tx(blank_pdu_meta),
        .rx(port_pdu_meta)
    );

endmodule
