`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module pdu_data_mover_service (
    input logic Clk, 
    input logic Rst_n,

    // DRAM
    output  ddr_wr_t                 ddr_wr_req_data,
    output  logic                    ddr_wr_req_valid,
    input   logic                    ddr_wr_req_almost_full,
    output  ddr_rd_t                 ddr_rd_req_data,
    output  logic                    ddr_rd_req_valid,
    input   logic                    ddr_rd_req_almost_full,
    input   logic [511:0]            ddr_rd_resp_data,
    input   logic                    ddr_rd_resp_valid,
    output  logic                    ddr_rd_resp_almost_full,

    server.svr pdu_meta_cpu,
    server.svr pdu_meta,
    server.svr pdu_pkt,
    server.clt emptylist,
    server.clt nomatch_pkt
);

unified_fifo  #(
    .FIFO_NAME        ("[top] ddr_resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (512),
    .FIFO_DEPTH       (512)) 
 ddr_resp_fifo (
    .in_clk            (Clk),
    .in_reset          (~Rst_n),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (ddr_rd_resp_data),
    .in_valid          (ddr_rd_resp_valid),
    .in_ready          (ddr_rd_resp_ready),
    .out_data          (ddr_rd_resp_out_data),
    .out_valid         (ddr_rd_resp_out_valid),
    .out_ready         (ddr_rd_resp_out_ready),
    .fill_level        (),
    .almost_full       (ddr_rd_resp_almost_full),
    .overflow          ()
);

    channel_if#(.WIDTH(512)) port[2](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 
    channel_if#(.WIDTH(512)) blank[2](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[2](); 
    channel_if#(.WIDTH(PDUID_WIDTH)) port_el(); 
    channel_if#(.WIDTH(PDUID_WIDTH)) blank_el(); 

    client_epig_shim#(.DATA_BITS(512)) in_pkt_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(pdu_pkt),
        .rx(blank[0]),
        .tx(port[0])
    );
    client_epig_shim#(.DATA_BITS($bits(pdu_metadata_t))) in_meta_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(pdu_meta),
        .rx(blank_meta[0]),
        .tx(port_meta[0])
    );
    client_epig_shim#(.DATA_BITS($bits(pdu_metadata_t))) in_meta_cpu_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(pdu_meta_cpu),
        .rx(blank_meta[1]),
        .tx(port_meta[1])
    );

pdu_data_mover pdu_data_mover_inst (
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .pdu_emptylist_out_data (port_el.data),
    .pdu_emptylist_out_valid(port_el.valid),
    .pdu_emptylist_out_ready(port_el.ready),
    .pdumeta_gen_data       (port_meta[0].data),
    .pdumeta_gen_valid      (port_meta[0].valid),
    .pdumeta_gen_ready      (port_meta[0].ready),
    .pdu_gen_data           (port[0].data),
    .pdu_gen_sop            (port[0].sop),
    .pdu_gen_eop            (port[0].eop),
    .pdu_gen_empty          (port[0].empty),
    .pdu_gen_valid          (port[0].valid),
    .pdu_gen_ready          (port[0].ready),
    .pdu_gen_almost_full    (port[0].almost_full),
    .pdumeta_cpu_data       (port_meta[1].data),
    .pdumeta_cpu_valid      (port_meta[1].valid),
    .pdumeta_cpu_ready      (port_meta[1].ready),
    .nocheck_data           (),
    .nocheck_sop            (),
    .nocheck_eop            (),
    .nocheck_valid          (),
    .nocheck_empty          (),
    .nocheck_ready          (),                     // Not using ready signal,
    .nocheck_almost_full    (1'b0),  // Use almost_full signal
    .nomatch_data           (port[1].data),
    .nomatch_sop            (port[1].sop),
    .nomatch_eop            (port[1].eop),
    .nomatch_valid          (port[1].valid),
    .nomatch_empty          (port[1].empty),
    .nomatch_ready          (),                     // Not using ready signal,
    .nomatch_almost_full    (port[1].almost_full),  // Use almost_full signal
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_out_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_out_valid),
    .ddr_rd_resp_ready      (ddr_rd_resp_out_ready)
);

    server_epig_shim#(.DATA_BITS(512)) in_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(nomatch_pkt),
        .tx(blank[1]),
        .rx(port[1])
    );
    server_epig_shim#(.DATA_BITS(PDUID_WIDTH)) in_meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(emptylist),
        .tx(blank_el),
        .rx(port_el)
    );

endmodule
