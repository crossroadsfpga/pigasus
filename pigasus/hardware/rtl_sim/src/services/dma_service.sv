`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module dma_service (
    input logic Clk, 
    input logic Rst_n,

    // PCIe
    output  flit_lite_t             pcie_rb_wr_data,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_wr_addr,
    output  logic                   pcie_rb_wr_en,
    input   logic [PDU_AWIDTH-1:0]  pcie_rb_wr_base_addr,
    input   logic                   pcie_rb_almost_full,
    output  logic                   pcie_rb_update_valid,
    output  logic [PDU_AWIDTH-1:0]  pcie_rb_update_size,
    input   logic                   disable_pcie,
    input   logic [PDU_META_WIDTH-1:0] pdumeta_cpu_data,        
    input   logic                   pdumeta_cpu_valid,
    input   logic                   pdumeta_cpu_ready,
    output  logic [31:0]            pdumeta_cpu_csr_readdata,

    // DRAM
    output  ddr_wr_t                ddr_wr_req_data,
    output  logic                   ddr_wr_req_valid,
    input   logic                   ddr_wr_req_almost_full,
    output  ddr_rd_t                ddr_rd_req_data,
    output  logic                   ddr_rd_req_valid,
    input   logic                   ddr_rd_req_almost_full,
    input   logic [511:0]           ddr_rd_resp_data,
    input   logic                   ddr_rd_resp_valid,
    output  logic                   ddr_rd_resp_almost_full,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt nomatch_pkt
);

    logic [511:0]  pdu_gen_data;
    logic          pdu_gen_sop;
    logic          pdu_gen_eop;
    logic [5:0]    pdu_gen_empty;
    logic          pdu_gen_valid;
    logic          pdu_gen_ready;
    logic          pdu_gen_almost_full;
    pdu_metadata_t pdumeta_gen_data;
    logic          pdumeta_gen_valid;
    logic          pdumeta_gen_ready;
    logic [PDUID_WIDTH-1:0] pdu_emptylist_out_data;
    logic                   pdu_emptylist_out_valid;
    logic                   pdu_emptylist_out_ready;
    
    pdu_metadata_t pdumeta_cpu_fifo_data;
    logic          pdumeta_cpu_fifo_valid;
    logic          pdumeta_cpu_fifo_ready;
    
    logic [511:0]  ddr_rd_resp_fifo_data;
    logic          ddr_rd_resp_fifo_valid;
    logic          ddr_rd_resp_fifo_ready;
    logic [31:0]   ddr_rd_resp_csr_readdata;

    channel_if#(.WIDTH(512)) port[3](); 
    channel_if#(.WIDTH(512)) blank[3](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta(); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta(); 

    client_epig_shim#(.DATA_BITS(512)) in_pkt_c
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_pkt),
        .rx(blank[0]),
        .tx(port[0])
    );
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_meta_c
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_meta),
        .rx(blank_meta),
        .tx(port_meta)
    );
    client_epig_shim#(.DATA_BITS(512)) in_usr_c
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_usr),
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
    .pcie_rb_update_valid   (pcie_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdu_emptylist_out_data (pdu_emptylist_out_data),
    .pdu_emptylist_out_valid(pdu_emptylist_out_valid),
    .pdu_emptylist_out_ready(pdu_emptylist_out_ready),
    .pdu_gen_data           (pdu_gen_data),
    .pdu_gen_sop            (pdu_gen_sop),
    .pdu_gen_eop            (pdu_gen_eop),
    .pdu_gen_empty          (pdu_gen_empty),
    .pdu_gen_valid          (pdu_gen_valid),
    .pdu_gen_ready          (pdu_gen_ready),
    .pdu_gen_almost_full    (pdu_gen_almost_full),
    .pdumeta_gen_data       (pdumeta_gen_data),
    .pdumeta_gen_valid      (pdumeta_gen_valid),
    .pdumeta_gen_ready      (pdumeta_gen_ready)
);
//////////////////// PDU DATAMOVER //////////////////////////////////
unified_fifo  #(
    .FIFO_NAME        ("[top] pdumeta_cpu_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (PDU_META_WIDTH),
    .FIFO_DEPTH       (512)
) pdumeta_cpu_fifo (
    .in_clk            (Clk),
    .in_reset          (~Rst_n),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (pdumeta_cpu_data),
    .in_valid          (pdumeta_cpu_valid),
    .in_ready          (pdumeta_cpu_ready),
    .out_data          (pdumeta_cpu_fifo_data),
    .out_valid         (pdumeta_cpu_fifo_valid),
    .out_ready         (pdumeta_cpu_fifo_ready),
    .fill_level        (pdumeta_cpu_csr_readdata),
    .almost_full       (),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[top] ddr_resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (512),
    .FIFO_DEPTH       (512)
) ddr_resp_fifo (
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
    .fill_level        (ddr_rd_resp_csr_readdata),
    .almost_full       (ddr_rd_resp_almost_full),
    .overflow          ()
);

pdu_data_mover pdu_data_mover_inst (
    .clk                    (Clk),
    .rst                    (~Rst_n),
    .pdu_emptylist_out_data (pdu_emptylist_out_data),
    .pdu_emptylist_out_valid(pdu_emptylist_out_valid),
    .pdu_emptylist_out_ready(pdu_emptylist_out_ready),
    .pdumeta_gen_data       (pdumeta_gen_data),
    .pdumeta_gen_valid      (pdumeta_gen_valid),
    .pdumeta_gen_ready      (pdumeta_gen_ready),
    .pdu_gen_data           (pdu_gen_data),
    .pdu_gen_sop            (pdu_gen_sop),
    .pdu_gen_eop            (pdu_gen_eop),
    .pdu_gen_empty          (pdu_gen_empty),
    .pdu_gen_valid          (pdu_gen_valid),
    .pdu_gen_ready          (pdu_gen_ready),
    .pdu_gen_almost_full    (pdu_gen_almost_full),
    .pdumeta_cpu_data       (pdumeta_cpu_fifo_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_fifo_valid),
    .pdumeta_cpu_ready      (pdumeta_cpu_fifo_ready),
    .nocheck_data           (),
    .nocheck_sop            (),
    .nocheck_eop            (),
    .nocheck_valid          (),
    .nocheck_empty          (),
    .nocheck_ready          (),                     // Not using ready signal,
    .nocheck_almost_full    (1'b0),  // Use almost_full signal
    .nomatch_data           (port[2].data),
    .nomatch_sop            (port[2].sop),
    .nomatch_eop            (port[2].eop),
    .nomatch_valid          (port[2].valid),
    .nomatch_empty          (port[2].empty),
    .nomatch_ready          (),                     // Not using ready signal,
    .nomatch_almost_full    (port[2].almost_full),  // Use almost_full signal
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
        .tx(blank[2]),
        .rx(port[2])
    );

endmodule
