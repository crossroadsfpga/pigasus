`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

module top (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,
    input   logic         clk_high,
    input   logic         clk_datamover,
    input   logic         rst_datamover,
    input   logic         clk_pcie,
    input   logic         rst_pcie,

    // Ethernet In & out
    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [511:0]   in_data,
    input   logic [5:0]     in_empty,
    input   logic           in_valid,
    output  logic [511:0]   reg_out_data,
    output  logic           reg_out_valid,
    output  logic           reg_out_sop,
    output  logic           reg_out_eop,
    output  logic [5:0]     reg_out_empty,
    input   logic           out_almost_full,

    // PCIe
    output  logic [513:0]   reg_pcie_rb_wr_data,        // Width: flit_lite_t
    output  logic [11:0]    reg_pcie_rb_wr_addr,        // Width: [PDU_AWIDTH-1:0]
    output  logic           reg_pcie_rb_wr_en,
    input   logic [11:0]    pcie_rb_wr_base_addr,       // Width: [PDU_AWIDTH-1:0]
    input   logic           pcie_rb_almost_full,
    output  logic           reg_pcie_rb_update_valid,
    output  logic [11:0]    reg_pcie_rb_update_size,    // Width: [PDU_AWIDTH-1:0]
    input   logic           disable_pcie,
    input   logic [27:0]    pdumeta_cpu_data,           // Width: pdu_metadata_t
    input   logic           pdumeta_cpu_valid,
    output  logic [9:0]     reg_pdumeta_cnt,

    // DRAM
    output  logic [540:0]   reg_ddr_wr_req_data,
    output  logic           reg_ddr_wr_req_valid,
    input   logic           ddr_wr_req_almost_full,
    output  logic [28:0]    reg_ddr_rd_req_data,
    output  logic           reg_ddr_rd_req_valid,
    input   logic           ddr_rd_req_almost_full,
    input   logic [511:0]   ddr_rd_resp_data,
    input   logic           ddr_rd_resp_valid,
    output  logic           reg_ddr_rd_resp_almost_full,

    // eSRAM
    output  logic           reg_esram_pkt_buf_wren,
 `ifdef USE_BRAM
    output  logic [14:0]    reg_esram_pkt_buf_wraddress,
    output  logic [14:0]    reg_esram_pkt_buf_rdaddress,
 `else
    output  logic [16:0]    reg_esram_pkt_buf_wraddress,
    output  logic [16:0]    reg_esram_pkt_buf_rdaddress,
 `endif
    output  logic [519:0]   reg_esram_pkt_buf_wrdata,
    output  logic           reg_esram_pkt_buf_rden,
    input   logic           esram_pkt_buf_rd_valid,
    input   logic [519:0]   esram_pkt_buf_rddata,

    // JTAG
    input   logic           clk_status,
    input   logic   [29:0]  status_addr,
    input   logic           status_read,
    input   logic           status_write,
    input   logic   [31:0]  status_writedata,
    output  logic   [31:0]  status_readdata,
    output  logic           status_readdata_valid
);

logic rst_high;
logic clk_rule;
logic rst_rule;

// Counters
logic [31:0]    in_pkt_cnt_status;
logic [31:0]    out_pkt_cnt_status;
logic [31:0]    out_pkt_cnt_incomp_status;
logic [31:0]    out_pkt_cnt_parser_status;
logic [31:0]    in_pkt_cnt_ft_status;
logic [31:0]    out_pkt_cnt_ft_status;
logic [31:0]    in_pkt_cnt_datamover_status;
logic [31:0]    out_pkt_cnt_datamover_status;
logic [31:0]    in_pkt_cnt_emptylist_status;
logic [31:0]    out_pkt_cnt_emptylist_status;
logic [31:0]    pkt_forward_status;
logic [31:0]    pkt_drop_status;
logic [31:0]    pkt_check_status;
logic [31:0]    pkt_ooo_status;
logic [31:0]    pkt_forward_ooo_status;
logic [31:0]    pkt_done_status;
logic [31:0]    in_sm_in_pkt_status;
logic [31:0]    in_sm_out_pkt_status;
logic [31:0]    out_sm_in_pkt_status;
logic [31:0]    out_sm_out_pkt_status;
logic [31:0]    out_check_fifo_pkt_status;
logic [31:0]    in_check_mux_pkt_status;
logic [31:0]    string_match_out_status;
logic [31:0]    string_match_in_pkt_status;
logic [31:0]    string_match_in_flit_status;
logic [31:0]    dma_pkt_status;
logic [31:0]    rule_cnt_status;
logic [31:0]    max_rule_fifo_status;
logic [31:0]    max_sm_out_meta_status;
logic [31:0]    max_sm_indata_status;
logic [31:0]    max_parser_fifo_status;
logic [31:0]    max_check_pkt_fifo_status;
logic [31:0]    no_check_pkt_status;
logic [31:0]    no_match_pkt_status;
logic [31:0]    match_pkt_status;
logic [31:0]    max_pdumeta_cnt_status;
logic [31:0]    pg_rule_cnt_status;
logic [31:0]    pg_meta_cnt_status;
logic [31:0]    pg_no_pg_rule_cnt_status;
logic [31:0]    pg_int_rule_cnt_status;
logic [31:0]    max_pg_rule_fifo_status;
logic [31:0]    af_nonpayload_pkt_status;
logic [31:0]    af_check_pkt_status;
logic [31:0]    af_sm_status;
logic [31:0]    max_nocheckpkt_fifo_status;
logic [31:0]    max_nonpayload_fifo_status;
logic [31:0]    current_nocheckpkt_fifo_status;
logic [31:0]    no_check_pkt_sop_status;
logic [31:0]    pkt_done_sop_status;
logic [31:0]    nonpayload_pkt_status;
logic [31:0]    nonpayload_pkt_sop_status;
logic [31:0]    data_mover_check_pkt_error_status;
logic [31:0]    nf_no_check_pkt_status;
logic [31:0]    nf_no_check_1_pkt_status;
logic [31:0]    nf_max_raw_pkt_fifo_status;
logic [31:0]    nf_max_pkt_fifo_status;
logic [31:0]    nf_max_pcie_status;
logic [31:0]    nf_max_rule_fifo_status;
logic [31:0]    ctrl_status;

// Register I/O
logic  [511:0]  out_data;
logic  [5:0]    out_empty;
logic           out_valid;
logic           out_valid_int;
logic           out_sop;
logic           out_eop;

logic  [511:0]  reg_in_data;
logic  [5:0]    reg_in_empty;
logic           reg_in_valid;
logic           reg_in_sop;
logic           reg_in_eop;
logic           reg_out_almost_full;

logic [513:0]   pcie_rb_wr_data;
logic [11:0]    pcie_rb_wr_addr;
logic           pcie_rb_wr_en;
logic           pcie_rb_update_valid;
logic [11:0]    pcie_rb_update_size;
logic [9:0]     pdumeta_cnt;

logic [11:0]    reg_pcie_rb_wr_base_addr;
logic           reg_pcie_rb_almost_full;
logic           reg_disable_pcie;
logic [27:0]    reg_pdumeta_cpu_data;
logic           reg_pdumeta_cpu_valid;

logic [547:0]   ddr_wr_req_data;
logic           ddr_wr_req_valid;
logic [33:0]    ddr_rd_req_data;
logic           ddr_rd_req_valid;
logic           ddr_rd_resp_almost_full;
logic [31:0]    ddr_rd_resp_csr_readdata;

logic           reg_ddr_wr_req_almost_full;
logic           reg_ddr_rd_req_almost_full;
logic [511:0]   reg_ddr_rd_resp_data;
logic           reg_ddr_rd_resp_valid;

logic           esram_pkt_buf_wren;
`ifdef USE_BRAM
logic [14:0]    esram_pkt_buf_wraddress;
logic [14:0]    esram_pkt_buf_rdaddress;
`else
logic [16:0]    esram_pkt_buf_wraddress;
logic [16:0]    esram_pkt_buf_rdaddress;
`endif
logic [519:0]   esram_pkt_buf_wrdata;
logic           esram_pkt_buf_rden;
logic           reg_esram_pkt_buf_rd_valid;
logic [519:0]   reg_esram_pkt_buf_rddata;
// End of Register I/O

logic internal_rb_update_valid;

logic          input_comp_eth_valid;
logic  [511:0] input_comp_eth_data;
logic          input_comp_eth_ready;
logic          input_comp_eth_sop;
logic          input_comp_eth_eop;
logic  [5:0]   input_comp_eth_empty;

logic          input_comp_metadata_valid;
metadata_t     input_comp_metadata_data;
logic          input_comp_metadata_ready;
logic          input_comp_pkt_valid;
logic  [511:0] input_comp_pkt_data;
logic          input_comp_pkt_ready;
logic          input_comp_pkt_sop;
logic          input_comp_pkt_eop;
logic  [5:0]   input_comp_pkt_empty;

logic          input_comp_metadata_out_valid;
metadata_t     input_comp_metadata_out_data;
logic          input_comp_metadata_out_ready;
logic          input_comp_pkt_out_valid;
logic  [511:0] input_comp_pkt_out_data;
logic          input_comp_pkt_out_ready;
logic          input_comp_pkt_out_sop;
logic          input_comp_pkt_out_eop;
logic  [5:0]   input_comp_pkt_out_empty;

logic [PKT_AWIDTH-1:0]   emptylist_in_data;
logic                    emptylist_in_valid;
logic                    emptylist_in_ready;

logic [PKT_AWIDTH-1:0]   emptylist_out_data;
logic                    emptylist_out_valid;
logic                    emptylist_out_ready;

logic [31:0]   parser_out_meta_csr_readdata;
logic          parser_out_meta_valid;
metadata_t     parser_out_meta_data;
logic          parser_out_meta_ready;

logic          parser_out_fifo_out_valid;
metadata_t     parser_out_fifo_out_data;
logic          parser_out_fifo_out_ready;

logic          ftw_out_meta_valid;
metadata_t     ftw_out_meta_data;
logic          ftw_out_meta_ready;
logic          ftw_out_meta_almost_full;
logic          ftw_reorder_meta_valid;
metadata_t     ftw_reorder_meta_data;
logic          ftw_reorder_meta_ready;
logic          ftw_reorder_meta_almost_full;
logic          ftw_forward_meta_valid;
metadata_t     ftw_forward_meta_data;
logic          ftw_forward_meta_ready;
logic          ftw_nonforward_meta_valid;
metadata_t     ftw_nonforward_meta_data;
logic          ftw_nonforward_meta_ready;

logic          data_mover_in_meta_valid;
metadata_t     data_mover_in_meta_data;
logic          data_mover_in_meta_ready;

logic          data_mover_pkt_valid;
logic  [511:0] data_mover_pkt_data;
logic          data_mover_pkt_ready;
logic          data_mover_pkt_almost_full;
logic          data_mover_pkt_sop;
logic          data_mover_pkt_eop;
logic  [5:0]   data_mover_pkt_empty;
logic          data_mover_check_pkt_valid;
logic  [511:0] data_mover_check_pkt_data;
logic          data_mover_check_pkt_ready;
logic          data_mover_check_pkt_sop;
logic          data_mover_check_pkt_eop;
logic  [5:0]   data_mover_check_pkt_empty;
logic          data_mover_check_pkt_almost_full;
logic  [8:0]   data_mover_check_pkt_hdr;
logic          data_mover_check_meta_valid;
metadata_t     data_mover_check_meta_data;
logic          data_mover_check_meta_ready;
logic          reg_data_mover_check_meta_valid;
metadata_t     reg_data_mover_check_meta_data;
logic          reg_data_mover_check_meta_ready;
logic          check_pkt_almost_full;
logic          sm_in_almost_full;
logic          reg_sm_in_almost_full;

logic [PKTBUF_AWIDTH-1:0]   data_mover_pkt_buffer_address;
logic                       data_mover_pkt_buffer_read;
logic                       data_mover_pkt_buffer_readvalid;
flit_t                      data_mover_pkt_buffer_readdata;

logic          fifo_pkt_0_out_valid;
logic  [511:0] fifo_pkt_0_out_data;
logic          fifo_pkt_0_out_ready;
logic          fifo_pkt_0_out_sop;
logic          fifo_pkt_0_out_eop;
logic  [5:0]   fifo_pkt_0_out_empty;

logic          data_align_out_valid;
logic  [511:0] data_align_out_data;
logic          data_align_out_ready;
logic          data_align_out_sop;
logic          data_align_out_eop;
logic  [5:0]   data_align_out_empty;

logic          reg_data_align_out_valid;
logic  [511:0] reg_data_align_out_data;
logic          reg_data_align_out_ready;
logic          reg_data_align_out_sop;
logic          reg_data_align_out_eop;
logic  [5:0]   reg_data_align_out_empty;

logic          sm_out_valid;
metadata_t     sm_out_data;
logic          sm_out_ready;

logic          string_matcher_meta_valid;
metadata_t     string_matcher_meta_data;
logic          string_matcher_meta_ready;
logic [31:0]   sm_out_meta_csr_readdata;
logic          reg_string_matcher_meta_valid;
metadata_t     reg_string_matcher_meta_data;

logic          string_matcher_rule_valid;
logic [127:0]  string_matcher_rule_data;
logic          string_matcher_rule_ready;
logic          string_matcher_rule_almost_full;
logic          string_matcher_rule_last;
logic          reg_string_matcher_rule_valid;
logic [127:0]  reg_string_matcher_rule_data;
logic          reg_string_matcher_rule_ready;
logic          reg_string_matcher_rule_almost_full;
logic          reg_string_matcher_rule_last;
logic          rule_sop;
logic          rule_eop;
logic  [5:0]   rule_empty;
logic          rule_valid;
logic [127:0]  rule_data;
logic          rule_ready;
logic          rule_in_csr_address;
logic          rule_in_csr_read;
logic          rule_in_csr_write;
logic [31:0]   rule_in_csr_readdata;
logic [31:0]   rule_in_csr_writedata;

logic          check_pkt_in_csr_address;
logic          check_pkt_in_csr_read;
logic          check_pkt_in_csr_write;
logic [31:0]   check_pkt_in_csr_readdata;
logic [31:0]   check_pkt_in_csr_writedata;

logic          output_pkt_in_csr_address;
logic          output_pkt_in_csr_read;
logic          output_pkt_in_csr_write;
logic [31:0]   output_pkt_in_csr_readdata;
logic [31:0]   output_pkt_in_csr_writedata;

logic          check_pkt_fifo_real_valid;
logic          check_pkt_fifo_real_ready;
logic          check_pkt_fifo_valid;
logic  [511:0] check_pkt_fifo_data;
logic          check_pkt_fifo_ready;
logic          check_pkt_fifo_sop;
logic          check_pkt_fifo_eop;
logic  [5:0]   check_pkt_fifo_empty;

logic          output_pkt_fifo_valid;
logic  [511:0] output_pkt_fifo_data;
logic          output_pkt_fifo_ready;
logic          output_pkt_fifo_sop;
logic          output_pkt_fifo_eop;
logic  [5:0]   output_pkt_fifo_empty;

// Port group
logic          pg_rule_sop;
logic          pg_rule_eop;
logic  [5:0]   pg_rule_empty;
logic          pg_rule_valid;
//logic [511:0]  pg_rule_data;
logic [127:0]  pg_rule_data;
logic          pg_rule_ready;
logic          pg_rule_fifo_sop;
logic          pg_rule_fifo_eop;
logic  [5:0]   pg_rule_fifo_empty;
logic          pg_rule_fifo_valid;
//logic [511:0]  pg_rule_fifo_data;
logic [127:0]  pg_rule_fifo_data;
logic          pg_rule_fifo_ready;
logic [31:0]   pg_rule_csr_readdata;
logic          pg_rule_almost_full;
metadata_t     pg_meta_data;
logic          pg_meta_valid;
logic          pg_meta_ready;
metadata_t     pg_meta_fifo_data;
logic          pg_meta_fifo_valid;
logic          pg_meta_fifo_ready;

// Non Fast Pattern
logic          nf_out_sop;
logic          nf_out_eop;
logic  [5:0]   nf_out_empty;
logic          nf_out_valid;
logic [511:0]  nf_out_data;
logic          nf_out_ready;
logic          nf_out_fifo_sop;
logic          nf_out_fifo_eop;
logic  [5:0]   nf_out_fifo_empty;
logic          nf_out_fifo_valid;
logic [511:0]  nf_out_fifo_data;
logic          nf_out_fifo_ready;
logic [31:0]   nf_out_csr_readdata;
logic          nf_out_almost_full;
logic          nf_no_check_sop;
logic          nf_no_check_eop;
logic  [5:0]   nf_no_check_empty;
logic          nf_no_check_valid;
logic [511:0]  nf_no_check_data;
logic          nf_no_check_ready;
logic          nf_no_check_fifo_sop;
logic          nf_no_check_fifo_eop;
logic  [5:0]   nf_no_check_fifo_empty;
logic          nf_no_check_fifo_valid;
logic [511:0]  nf_no_check_fifo_data;
logic          nf_no_check_fifo_ready;
logic [31:0]   nf_no_check_csr_readdata;
logic          nf_no_check_almost_full;
logic          nf_no_check_1_sop;
logic          nf_no_check_1_eop;
logic  [5:0]   nf_no_check_1_empty;
logic          nf_no_check_1_valid;
logic [511:0]  nf_no_check_1_data;
logic          nf_no_check_1_ready;
logic          nf_no_check_1_fifo_sop;
logic          nf_no_check_1_fifo_eop;
logic  [5:0]   nf_no_check_1_fifo_empty;
logic          nf_no_check_1_fifo_valid;
logic [511:0]  nf_no_check_1_fifo_data;
logic          nf_no_check_1_fifo_ready;
logic [31:0]   nf_no_check_1_csr_readdata;
logic          nf_no_check_1_almost_full;
logic          nf_rule_sop;
logic          nf_rule_eop;
logic  [3:0]   nf_rule_empty;
logic          nf_rule_valid;
logic [127:0]  nf_rule_data;
logic          nf_rule_ready;
logic          nf_rule_fifo_sop;
logic          nf_rule_fifo_eop;
logic  [3:0]   nf_rule_fifo_empty;
logic          nf_rule_fifo_valid;
logic [127:0]  nf_rule_fifo_data;
logic          nf_rule_fifo_ready;
logic [31:0]   nf_rule_csr_readdata;
logic          nf_rule_almost_full;
metadata_t     nf_meta_data;
logic          nf_meta_valid;
logic          nf_meta_ready;
metadata_t     nf_meta_fifo_data;
logic          nf_meta_fifo_valid;
logic          nf_meta_fifo_ready;
logic          rule_packer_sop;
logic          rule_packer_eop;
logic  [5:0]   rule_packer_empty;
logic          rule_packer_valid;
logic [511:0]  rule_packer_data;
logic          rule_packer_ready;
logic [15:0]   nf_forward_th;
// Signals for pdu data mover
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
pdu_metadata_t pdumeta_cpu_out_data;
logic          pdumeta_cpu_out_valid;
logic          pdumeta_cpu_out_ready;
logic          pdumeta_cpu_ready;
logic [31:0]   pdumeta_cpu_csr_readdata;

logic [511:0]  ddr_rd_resp_out_data;
logic          ddr_rd_resp_out_valid;
logic          ddr_rd_resp_out_ready;
logic          ddr_rd_resp_ready;

logic [PDUID_WIDTH-1:0] pdu_emptylist_out_data;
logic                   pdu_emptylist_out_valid;
logic                   pdu_emptylist_out_ready;
logic [511:0]           nomatch_data;
logic                   nomatch_sop;
logic                   nomatch_eop;
logic                   nomatch_valid;
logic [5:0]             nomatch_empty;
logic                   nomatch_ready;
logic                   nomatch_almost_full;
logic [511:0]           nomatch_out_data;
logic                   nomatch_out_sop;
logic                   nomatch_out_eop;
logic                   nomatch_out_valid;
logic [5:0]             nomatch_out_empty;
logic                   nomatch_out_ready;
logic                   nomatch_in_csr_address;
logic                   nomatch_in_csr_read;
logic                   nomatch_in_csr_write;
logic [31:0]            nomatch_in_csr_readdata;
logic [31:0]            nomatch_in_csr_writedata;
logic [511:0]           nocheck_data;
logic                   nocheck_sop;
logic                   nocheck_eop;
logic                   nocheck_valid;
logic [5:0]             nocheck_empty;
logic                   nocheck_ready;
logic                   nocheck_almost_full;
logic [511:0]           nocheck_out_data;
logic                   nocheck_out_sop;
logic                   nocheck_out_eop;
logic                   nocheck_out_valid;
logic [5:0]             nocheck_out_empty;
logic                   nocheck_out_ready;
logic                   nocheck_in_csr_address;
logic                   nocheck_in_csr_read;
logic                   nocheck_in_csr_write;
logic [31:0]            nocheck_in_csr_readdata;
logic [31:0]            nocheck_in_csr_writedata;

logic [511:0]           merge_nocheck_data;
logic                   merge_nocheck_sop;
logic                   merge_nocheck_eop;
logic                   merge_nocheck_valid;
logic [5:0]             merge_nocheck_empty;
logic                   merge_nocheck_ready;
logic [511:0]           merge_nocheck_out_data;
logic                   merge_nocheck_out_sop;
logic                   merge_nocheck_out_eop;
logic                   merge_nocheck_out_valid;
logic [5:0]             merge_nocheck_out_empty;
logic                   merge_nocheck_out_ready;

logic [7:0]             status_addr_r;
logic [STAT_AWIDTH-1:0] status_addr_sel_r;
logic                   status_write_r;
logic                   status_read_r;
logic [31:0]            status_writedata_r;

logic          status_readdata_valid_ft;
logic [31:0]   status_readdata_ft;
logic          status_readdata_valid_top;
logic [31:0]   status_readdata_top;
logic          status_readdata_valid_ruleID;
logic [31:0]   status_readdata_ruleID;


logic [31:0] in_pkt_cnt;
logic [31:0] in_pkt_cnt_r1;
logic [31:0] in_pkt_cnt_r2;
logic [31:0] out_pkt_cnt;
logic [31:0] out_pkt_cnt_r1;
logic [31:0] out_pkt_cnt_r2;
logic [31:0] out_pkt_cnt_incomp;
logic [31:0] out_pkt_cnt_incomp_r1;
logic [31:0] out_pkt_cnt_incomp_r2;
logic [31:0] out_pkt_cnt_parser;
logic [31:0] out_pkt_cnt_parser_r1;
logic [31:0] out_pkt_cnt_parser_r2;
logic [31:0] in_pkt_cnt_ft;
logic [31:0] in_pkt_cnt_ft_r1;
logic [31:0] in_pkt_cnt_ft_r2;
logic [31:0] out_pkt_cnt_ft;
logic [31:0] out_pkt_cnt_ft_r1;
logic [31:0] out_pkt_cnt_ft_r2;
logic [31:0] in_pkt_cnt_datamover;
logic [31:0] in_pkt_cnt_datamover_r1;
logic [31:0] in_pkt_cnt_datamover_r2;
logic [31:0] out_pkt_cnt_datamover;
logic [31:0] out_pkt_cnt_datamover_r1;
logic [31:0] out_pkt_cnt_datamover_r2;
logic [31:0] in_pkt_cnt_emptylist;
logic [31:0] in_pkt_cnt_emptylist_r1;
logic [31:0] in_pkt_cnt_emptylist_r2;
logic [31:0] out_pkt_cnt_emptylist;
logic [31:0] out_pkt_cnt_emptylist_r1;
logic [31:0] out_pkt_cnt_emptylist_r2;

logic [31:0] pkt_forward;
logic [31:0] pkt_forward_r1;
logic [31:0] pkt_forward_r2;

logic [31:0] pkt_drop;
logic [31:0] pkt_drop_r1;
logic [31:0] pkt_drop_r2;

logic [31:0] pkt_check;
logic [31:0] pkt_check_r1;
logic [31:0] pkt_check_r2;

logic [31:0] pkt_ooo;
logic [31:0] pkt_ooo_r1;
logic [31:0] pkt_ooo_r2;

logic [31:0] pkt_forward_ooo;
logic [31:0] pkt_forward_ooo_r1;
logic [31:0] pkt_forward_ooo_r2;

logic [31:0] pkt_done;
logic [31:0] pkt_done_r1;
logic [31:0] pkt_done_r2;

logic [31:0] in_sm_in_pkt;
logic [31:0] in_sm_in_pkt_r1;
logic [31:0] in_sm_in_pkt_r2;

logic [31:0] in_sm_out_pkt;
logic [31:0] in_sm_out_pkt_r1;
logic [31:0] in_sm_out_pkt_r2;

logic [31:0] out_sm_in_pkt;
logic [31:0] out_sm_in_pkt_r1;
logic [31:0] out_sm_in_pkt_r2;

logic [31:0] out_sm_out_pkt;
logic [31:0] out_sm_out_pkt_r1;
logic [31:0] out_sm_out_pkt_r2;

logic [31:0] out_check_fifo_pkt;
logic [31:0] out_check_fifo_pkt_r1;
logic [31:0] out_check_fifo_pkt_r2;

logic [31:0] in_check_mux_pkt;
logic [31:0] in_check_mux_pkt_r1;
logic [31:0] in_check_mux_pkt_r2;

logic [31:0] string_match_out;
logic [31:0] string_match_out_r1;
logic [31:0] string_match_out_r2;
logic [31:0] string_match_in_pkt;
logic [31:0] string_match_in_pkt_r1;
logic [31:0] string_match_in_pkt_r2;
logic [31:0] string_match_in_flit;
logic [31:0] string_match_in_flit_r1;
logic [31:0] string_match_in_flit_r2;

logic [31:0] dma_pkt;
logic [31:0] dma_pkt_r1;
logic [31:0] dma_pkt_r2;
logic [31:0] rule_cnt;
logic [31:0] rule_cnt_r1;
logic [31:0] rule_cnt_r2;

logic [31:0] max_rule_fifo;
logic [31:0] max_rule_fifo_r1;
logic [31:0] max_rule_fifo_r2;
logic [31:0] max_sm_out_meta;
logic [31:0] max_sm_out_meta_r1;
logic [31:0] max_sm_out_meta_r2;
logic [31:0] max_sm_indata;
logic [31:0] max_sm_indata_r1;
logic [31:0] max_sm_indata_r2;
logic [31:0] max_parser_fifo;
logic [31:0] max_parser_fifo_r1;
logic [31:0] max_parser_fifo_r2;
logic [31:0] max_check_pkt_fifo;
logic [31:0] max_check_pkt_fifo_r1;
logic [31:0] max_check_pkt_fifo_r2;
logic [31:0] no_check_pkt;
logic [31:0] no_check_pkt_r1;
logic [31:0] no_check_pkt_r2;
logic [31:0] no_match_pkt;
logic [31:0] no_match_pkt_r1;
logic [31:0] no_match_pkt_r2;
logic [31:0] match_pkt;
logic [31:0] match_pkt_r1;
logic [31:0] match_pkt_r2;
logic [31:0] max_pdumeta_cnt;
logic [31:0] max_pdumeta_cnt_r1;
logic [31:0] max_pdumeta_cnt_r2;
logic [31:0] pg_rule_cnt;
logic [31:0] pg_rule_cnt_r1;
logic [31:0] pg_rule_cnt_r2;
logic [31:0] pg_meta_cnt;
logic [31:0] pg_meta_cnt_r1;
logic [31:0] pg_meta_cnt_r2;
logic [31:0] pg_no_pg_rule_cnt;
logic [31:0] pg_no_pg_rule_cnt_r1;
logic [31:0] pg_no_pg_rule_cnt_r2;
logic [31:0] pg_int_rule_cnt;
logic [31:0] pg_int_rule_cnt_r1;
logic [31:0] pg_int_rule_cnt_r2;
logic [31:0] max_pg_rule_fifo;
logic [31:0] max_pg_rule_fifo_r1;
logic [31:0] max_pg_rule_fifo_r2;
logic [31:0] af_nonpayload_pkt;
logic [31:0] af_nonpayload_pkt_r1;
logic [31:0] af_nonpayload_pkt_r2;
logic [31:0] af_check_pkt;
logic [31:0] af_check_pkt_r1;
logic [31:0] af_check_pkt_r2;
logic [31:0] af_sm;
logic [31:0] af_sm_r1;
logic [31:0] af_sm_r2;
logic [31:0] max_nocheckpkt_fifo;
logic [31:0] max_nocheckpkt_fifo_r1;
logic [31:0] max_nocheckpkt_fifo_r2;
logic [31:0] max_nonpayload_fifo;
logic [31:0] max_nonpayload_fifo_r1;
logic [31:0] max_nonpayload_fifo_r2;
logic [31:0] current_nocheckpkt_fifo;
logic [31:0] current_nocheckpkt_fifo_r1;
logic [31:0] current_nocheckpkt_fifo_r2;
logic [31:0] no_check_pkt_sop;
logic [31:0] no_check_pkt_sop_r1;
logic [31:0] no_check_pkt_sop_r2;
logic [31:0] pkt_done_sop;
logic [31:0] pkt_done_sop_r1;
logic [31:0] pkt_done_sop_r2;
logic [31:0] nonpayload_pkt;
logic [31:0] nonpayload_pkt_r1;
logic [31:0] nonpayload_pkt_r2;
logic [31:0] nonpayload_pkt_sop;
logic [31:0] nonpayload_pkt_sop_r1;
logic [31:0] nonpayload_pkt_sop_r2;

logic [31:0] data_mover_check_pkt_error;
logic [31:0] data_mover_check_pkt_error_r1;
logic [31:0] data_mover_check_pkt_error_r2;
logic [31:0] nf_no_check_pkt;
logic [31:0] nf_no_check_pkt_r1;
logic [31:0] nf_no_check_pkt_r2;
logic [31:0] nf_no_check_1_pkt;
logic [31:0] nf_no_check_1_pkt_r1;
logic [31:0] nf_no_check_1_pkt_r2;
logic [31:0] nf_max_raw_pkt_fifo;
logic [31:0] nf_max_raw_pkt_fifo_r1;
logic [31:0] nf_max_raw_pkt_fifo_r2;
logic [31:0] nf_max_pkt_fifo;
logic [31:0] nf_max_pkt_fifo_r1;
logic [31:0] nf_max_pkt_fifo_r2;
logic [31:0] nf_max_pcie;
logic [31:0] nf_max_pcie_r1;
logic [31:0] nf_max_pcie_r2;
logic [31:0] nf_max_rule_fifo;
logic [31:0] nf_max_rule_fifo_r1;
logic [31:0] nf_max_rule_fifo_r2;

assign clk_rule = clk;
assign rst_rule = rst;
assign rst_high = rst;

//////////////////////////////
// Read and Write registers //
//////////////////////////////
always @ (posedge clk) begin
    if (rst) begin
        in_pkt_cnt_ft <= 0;
        out_pkt_cnt_ft <= 0;
        out_pkt_cnt <= 0;
    end
    else begin
        if (parser_out_fifo_out_valid & parser_out_fifo_out_ready) begin
            in_pkt_cnt_ft <= in_pkt_cnt_ft + 1;
        end
        if (ftw_nonforward_meta_valid & ftw_nonforward_meta_ready) begin
            if (ftw_forward_meta_valid & ftw_forward_meta_ready) begin
                out_pkt_cnt_ft <= out_pkt_cnt_ft + 2;
            end
            else begin
                out_pkt_cnt_ft <= out_pkt_cnt_ft + 1;
            end
        end
        else begin
            if (ftw_forward_meta_valid & ftw_forward_meta_ready) begin
                out_pkt_cnt_ft <= out_pkt_cnt_ft + 1;
            end
        end

        if (out_valid & !reg_out_almost_full & out_eop) begin
            out_pkt_cnt <= out_pkt_cnt + 1;
        end

    end
end

// Datamover clock domain
always @(posedge clk_datamover) begin
    if (rst_datamover) begin
        in_pkt_cnt              <= 0;
        out_pkt_cnt_incomp      <= 0;
        out_pkt_cnt_parser      <= 0;
        max_parser_fifo         <= 0;
        in_pkt_cnt_emptylist    <= 0;
        out_pkt_cnt_emptylist   <= 0;
        in_pkt_cnt_datamover    <= 0;
        out_pkt_cnt_datamover   <= 0;
        pkt_forward             <= 0;
        pkt_drop                <= 0;
        pkt_check               <= 0;
        pkt_ooo                 <= 0;
        pkt_forward_ooo         <= 0;
        pkt_done                <= 0;
        pkt_done_sop            <= 0;
        in_sm_in_pkt            <= 0;
        max_sm_indata           <= 0;
        max_check_pkt_fifo      <= 0;
        af_nonpayload_pkt       <= 0;
        af_check_pkt            <= 0;
        af_sm                   <= 0;
        max_nonpayload_fifo     <= 0;
        nonpayload_pkt          <= 0;
        nonpayload_pkt_sop      <= 0;
    end
    else begin
        if (input_comp_eth_valid & input_comp_eth_eop) begin
            in_pkt_cnt <= in_pkt_cnt + 1;
            if (in_pkt_cnt[5:0] == 6'b00_0000) begin
                $display("PKT %d", in_pkt_cnt);
            end
        end

        if (input_comp_metadata_valid & input_comp_metadata_ready) begin
            out_pkt_cnt_incomp <= out_pkt_cnt_incomp + 1;
        end

        if (parser_out_meta_valid & parser_out_meta_ready) begin
            out_pkt_cnt_parser <= out_pkt_cnt_parser + 1;
        end

        if (max_parser_fifo < parser_out_meta_csr_readdata) begin
            max_parser_fifo <= parser_out_meta_csr_readdata;
        end

        if (data_mover_in_meta_ready & data_mover_in_meta_valid) begin
            in_pkt_cnt_datamover <= in_pkt_cnt_datamover + 1;
        end
        if (emptylist_in_valid & emptylist_in_ready) begin
            in_pkt_cnt_emptylist <= in_pkt_cnt_emptylist + 1;
        end
        if (emptylist_out_valid & emptylist_out_ready) begin
            out_pkt_cnt_emptylist <= out_pkt_cnt_emptylist + 1;
        end

        if ((data_mover_check_pkt_valid & data_mover_check_pkt_eop & data_mover_check_pkt_ready)
            | (data_mover_pkt_valid & data_mover_pkt_eop & data_mover_pkt_ready)) begin
            out_pkt_cnt_datamover <= out_pkt_cnt_datamover + 1;
        end

        if (data_mover_in_meta_ready & data_mover_in_meta_valid) begin
            case (data_mover_in_meta_data.pkt_flags)
                PKT_FORWARD:        pkt_forward <= pkt_forward + 1;
                PKT_DROP:           pkt_drop    <= pkt_drop + 1;
                PKT_CHECK: begin
                    pkt_check   <= pkt_check + 1;
                end
                PKT_OOO:            pkt_ooo <= pkt_ooo + 1;
                PKT_FORWARD_OOO:    pkt_forward_ooo <= pkt_forward_ooo + 1;
            endcase
        end
        if (data_mover_check_pkt_valid & data_mover_check_pkt_ready & data_mover_check_pkt_eop) begin
            pkt_done <= pkt_done + 1;
        end
        if (data_mover_check_pkt_valid & data_mover_check_pkt_ready & data_mover_check_pkt_sop) begin
            pkt_done_sop <= pkt_done_sop + 1;
        end

        if (reg_data_mover_check_meta_valid) begin
            in_sm_in_pkt <= in_sm_in_pkt + 1;
        end

        if (max_check_pkt_fifo < check_pkt_in_csr_readdata) begin
            max_check_pkt_fifo <= check_pkt_in_csr_readdata;
        end

        if (data_mover_pkt_almost_full) begin
            af_nonpayload_pkt <= af_nonpayload_pkt + 1;
        end

        if (data_mover_check_pkt_almost_full) begin
            af_check_pkt <= af_check_pkt + 1;
        end

        if (sm_in_almost_full) begin
            af_sm <= af_sm + 1;
        end

        if (max_nonpayload_fifo < output_pkt_in_csr_readdata) begin
            max_nonpayload_fifo <= output_pkt_in_csr_readdata;
        end

        if (data_mover_pkt_valid & data_mover_pkt_eop & data_mover_pkt_ready) begin
            nonpayload_pkt <= nonpayload_pkt + 1;
        end

        if (data_mover_pkt_valid & data_mover_pkt_sop & data_mover_pkt_ready) begin
            nonpayload_pkt_sop <= nonpayload_pkt_sop + 1;
        end


    end
end
// sm clock domain
always @(posedge clk_high) begin
    if (rst_high) begin
        in_sm_out_pkt <= 0;
        out_sm_in_pkt <= 0;
        max_sm_out_meta <= 0;
    end
    else begin
        if (reg_string_matcher_meta_valid) begin
            in_sm_out_pkt <= in_sm_out_pkt + 1;
        end

        if (max_sm_out_meta < sm_out_meta_csr_readdata) begin
            max_sm_out_meta <= sm_out_meta_csr_readdata;
        end
    end
end
// Rule clock domain
always @(posedge clk_rule) begin
    if (rst_rule) begin
        max_rule_fifo <= 0;
    end
    else begin
        if (max_rule_fifo < rule_in_csr_readdata) begin
            max_rule_fifo <= rule_in_csr_readdata;
        end
    end
end
// PCIe clock domain
always @(posedge clk_pcie) begin
    if (rst_pcie) begin
        dma_pkt             <= 0;
        rule_cnt            <= 0;
        out_sm_out_pkt      <= 0;
        out_check_fifo_pkt  <= 0;
        no_check_pkt        <= 0;
        no_match_pkt        <= 0;
        match_pkt           <= 0;
        max_pdumeta_cnt     <= 0;
        pg_rule_cnt         <= 0;
        pg_meta_cnt         <= 0;
        max_pg_rule_fifo    <= 0;
        max_nocheckpkt_fifo <= 0;
        no_check_pkt_sop    <= 0;
        nf_no_check_pkt     <= 0;
        nf_no_check_1_pkt   <= 0;
        nf_max_pcie         <= 0;
    end
    else begin
        if (internal_rb_update_valid) begin
            dma_pkt <= dma_pkt + 1;
        end
        if (rule_valid & rule_ready & !rule_eop) begin
            rule_cnt <= rule_cnt + 1;
        end
        if (sm_out_valid & sm_out_ready) begin
            out_sm_out_pkt <= out_sm_out_pkt + 1;
        end
        if (check_pkt_fifo_valid & check_pkt_fifo_ready & check_pkt_fifo_eop) begin
            out_check_fifo_pkt <= out_check_fifo_pkt + 1;
        end
        if (nocheck_valid & nocheck_ready & nocheck_eop) begin
            no_check_pkt <= no_check_pkt + 1;
        end
        if (pdumeta_cpu_out_valid & pdumeta_cpu_out_ready & (pdumeta_cpu_out_data.action == ACTION_NOMATCH)) begin
            no_match_pkt <= no_match_pkt + 1;
        end
        if (pdumeta_cpu_out_valid & pdumeta_cpu_out_ready & (pdumeta_cpu_out_data.action == ACTION_MATCH)) begin
            match_pkt <= match_pkt + 1;
        end
        if (max_pdumeta_cnt < pdumeta_cpu_csr_readdata) begin
            max_pdumeta_cnt <= pdumeta_cpu_csr_readdata;
        end

        if (pg_rule_valid & pg_rule_ready & !pg_rule_eop) begin
            pg_rule_cnt <= pg_rule_cnt + 1;
        end

        if (pg_meta_valid & pg_meta_ready) begin
            pg_meta_cnt <= pg_meta_cnt + 1;
        end

        if (max_pg_rule_fifo < pg_rule_csr_readdata) begin
            max_pg_rule_fifo <= pg_rule_csr_readdata;
        end

        if (max_nocheckpkt_fifo < nocheck_in_csr_readdata) begin
            max_nocheckpkt_fifo <= nocheck_in_csr_readdata;
        end

        current_nocheckpkt_fifo <= nocheck_in_csr_readdata;
        if (nocheck_valid & nocheck_ready & nocheck_sop) begin
            no_check_pkt_sop <= no_check_pkt_sop + 1;
        end

        if (nf_no_check_valid & nf_no_check_ready & nf_no_check_eop) begin
            nf_no_check_pkt <= nf_no_check_pkt + 1;
        end

        if (nf_no_check_1_valid & nf_no_check_1_ready & nf_no_check_1_eop) begin
            nf_no_check_1_pkt <= nf_no_check_1_pkt + 1;
        end
        if (nf_max_pcie < nf_out_csr_readdata)begin
            nf_max_pcie <= nf_out_csr_readdata;
        end
    end
end

// Sync
always @(posedge clk_status) begin
    in_pkt_cnt_r1                   <= in_pkt_cnt;
    in_pkt_cnt_r2                   <= in_pkt_cnt_r1;
    in_pkt_cnt_status               <= in_pkt_cnt_r2;
    out_pkt_cnt_incomp_r1           <= out_pkt_cnt_incomp;
    out_pkt_cnt_incomp_r2           <= out_pkt_cnt_incomp_r1;
    out_pkt_cnt_incomp_status       <= out_pkt_cnt_incomp_r2;
    out_pkt_cnt_parser_r1           <= out_pkt_cnt_parser;
    out_pkt_cnt_parser_r2           <= out_pkt_cnt_parser_r1;
    out_pkt_cnt_parser_status       <= out_pkt_cnt_parser_r2;
    in_pkt_cnt_ft_r1                <= in_pkt_cnt_ft;
    in_pkt_cnt_ft_r2                <= in_pkt_cnt_ft_r1;
    in_pkt_cnt_ft_status            <= in_pkt_cnt_ft_r2;
    out_pkt_cnt_ft_r1               <= out_pkt_cnt_ft;
    out_pkt_cnt_ft_r2               <= out_pkt_cnt_ft_r1;
    out_pkt_cnt_ft_status           <= out_pkt_cnt_ft_r2;
    in_pkt_cnt_datamover_r1         <= in_pkt_cnt_datamover;
    in_pkt_cnt_datamover_r2         <= in_pkt_cnt_datamover_r1;
    in_pkt_cnt_datamover_status     <= in_pkt_cnt_datamover_r2;
    out_pkt_cnt_datamover_r1        <= out_pkt_cnt_datamover;
    out_pkt_cnt_datamover_r2        <= out_pkt_cnt_datamover_r1;
    out_pkt_cnt_datamover_status    <= out_pkt_cnt_datamover_r2;
    out_pkt_cnt_r1                  <= out_pkt_cnt;
    out_pkt_cnt_r2                  <= out_pkt_cnt_r1;
    out_pkt_cnt_status              <= out_pkt_cnt_r2;
    in_pkt_cnt_emptylist_r1         <= in_pkt_cnt_emptylist;
    in_pkt_cnt_emptylist_r2         <= in_pkt_cnt_emptylist_r1;
    in_pkt_cnt_emptylist_status     <= in_pkt_cnt_emptylist_r2;
    out_pkt_cnt_emptylist_r1        <= out_pkt_cnt_emptylist;
    out_pkt_cnt_emptylist_r2        <= out_pkt_cnt_emptylist_r1;
    out_pkt_cnt_emptylist_status    <= out_pkt_cnt_emptylist_r2;
    pkt_forward_r1                  <= pkt_forward;
    pkt_forward_r2                  <= pkt_forward_r1;
    pkt_forward_status              <= pkt_forward_r2;
    pkt_drop_r1                     <= pkt_drop;
    pkt_drop_r2                     <= pkt_drop_r1;
    pkt_drop_status                 <= pkt_drop_r2;
    pkt_check_r1                    <= pkt_check;
    pkt_check_r2                    <= pkt_check_r1;
    pkt_check_status                <= pkt_check_r2;
    pkt_ooo_r1                      <= pkt_ooo;
    pkt_ooo_r2                      <= pkt_ooo_r1;
    pkt_ooo_status                  <= pkt_ooo_r2;
    pkt_forward_ooo_r1              <= pkt_forward_ooo;
    pkt_forward_ooo_r2              <= pkt_forward_ooo_r1;
    pkt_forward_ooo_status          <= pkt_forward_ooo_r2;
    pkt_done_r1                     <= pkt_done;
    pkt_done_r2                     <= pkt_done_r1;
    pkt_done_status                 <= pkt_done_r2;
    in_sm_in_pkt_r1                 <= in_sm_in_pkt;
    in_sm_in_pkt_r2                 <= in_sm_in_pkt_r1;
    in_sm_in_pkt_status             <= in_sm_in_pkt_r2;
    in_sm_out_pkt_r1                <= in_sm_out_pkt;
    in_sm_out_pkt_r2                <= in_sm_out_pkt_r1;
    in_sm_out_pkt_status            <= in_sm_out_pkt_r2;
    out_sm_in_pkt_r1                <= out_sm_in_pkt;
    out_sm_in_pkt_r2                <= out_sm_in_pkt_r1;
    out_sm_in_pkt_status            <= out_sm_in_pkt_r2;
    out_sm_out_pkt_r1               <= out_sm_out_pkt;
    out_sm_out_pkt_r2               <= out_sm_out_pkt_r1;
    out_sm_out_pkt_status           <= out_sm_out_pkt_r2;
    out_check_fifo_pkt_r1           <= out_check_fifo_pkt;
    out_check_fifo_pkt_r2           <= out_check_fifo_pkt_r1;
    out_check_fifo_pkt_status       <= out_check_fifo_pkt_r2;
    in_check_mux_pkt_r1             <= in_check_mux_pkt;
    in_check_mux_pkt_r2             <= in_check_mux_pkt_r1;
    in_check_mux_pkt_status         <= in_check_mux_pkt_r2;
    string_match_out_r1             <= string_match_out;
    string_match_out_r2             <= string_match_out_r1;
    string_match_out_status         <= string_match_out_r2;
    string_match_in_pkt_r1          <= string_match_in_pkt;
    string_match_in_pkt_r2          <= string_match_in_pkt_r1;
    string_match_in_pkt_status      <= string_match_in_pkt_r2;
    string_match_in_flit_r1         <= string_match_in_flit;
    string_match_in_flit_r2         <= string_match_in_flit_r1;
    string_match_in_flit_status     <= string_match_in_flit_r2;
    dma_pkt_r1                      <= dma_pkt;
    dma_pkt_r2                      <= dma_pkt_r1;
    dma_pkt_status                  <= dma_pkt_r2;
    rule_cnt_r1                     <= rule_cnt;
    rule_cnt_r2                     <= rule_cnt_r1;
    rule_cnt_status                 <= rule_cnt_r2;
    max_rule_fifo_r1                <= max_rule_fifo;
    max_rule_fifo_r2                <= max_rule_fifo_r1;
    max_rule_fifo_status            <= max_rule_fifo_r2;
    max_sm_out_meta_r1              <= max_sm_out_meta;
    max_sm_out_meta_r2              <= max_sm_out_meta_r1;
    max_sm_out_meta_status          <= max_sm_out_meta_r2;
    max_sm_indata_r1                <= max_sm_indata;
    max_sm_indata_r2                <= max_sm_indata_r1;
    max_sm_indata_status            <= max_sm_indata_r2;
    max_parser_fifo_r1              <= max_parser_fifo;
    max_parser_fifo_r2              <= max_parser_fifo_r1;
    max_parser_fifo_status          <= max_parser_fifo_r2;
    max_check_pkt_fifo_r1           <= max_check_pkt_fifo;
    max_check_pkt_fifo_r2           <= max_check_pkt_fifo_r1;
    max_check_pkt_fifo_status       <= max_check_pkt_fifo_r2;
    no_check_pkt_r1                 <= no_check_pkt;
    no_check_pkt_r2                 <= no_check_pkt_r1;
    no_check_pkt_status             <= no_check_pkt_r2;
    no_match_pkt_r1                 <= no_match_pkt;
    no_match_pkt_r2                 <= no_match_pkt_r1;
    no_match_pkt_status             <= no_match_pkt_r2;
    match_pkt_r1                    <= match_pkt;
    match_pkt_r2                    <= match_pkt_r1;
    match_pkt_status                <= match_pkt_r2;
    max_pdumeta_cnt_r1              <= max_pdumeta_cnt;
    max_pdumeta_cnt_r2              <= max_pdumeta_cnt_r1;
    max_pdumeta_cnt_status          <= max_pdumeta_cnt_r2;
    pg_rule_cnt_r1                  <= pg_rule_cnt;
    pg_rule_cnt_r2                  <= pg_rule_cnt_r1;
    pg_rule_cnt_status              <= pg_rule_cnt_r2;
    pg_meta_cnt_r1                  <= pg_meta_cnt;
    pg_meta_cnt_r2                  <= pg_meta_cnt_r1;
    pg_meta_cnt_status              <= pg_meta_cnt_r2;
    pg_no_pg_rule_cnt_r1            <= pg_no_pg_rule_cnt;
    pg_no_pg_rule_cnt_r2            <= pg_no_pg_rule_cnt_r1;
    pg_no_pg_rule_cnt_status        <= pg_no_pg_rule_cnt_r2;
    pg_int_rule_cnt_r1              <= pg_int_rule_cnt;
    pg_int_rule_cnt_r2              <= pg_int_rule_cnt_r1;
    pg_int_rule_cnt_status          <= pg_int_rule_cnt_r2;
    max_pg_rule_fifo_r1             <= max_pg_rule_fifo;
    max_pg_rule_fifo_r2             <= max_pg_rule_fifo_r1;
    max_pg_rule_fifo_status         <= max_pg_rule_fifo_r2;
    af_nonpayload_pkt_r1            <= af_nonpayload_pkt;
    af_nonpayload_pkt_r2            <= af_nonpayload_pkt_r1;
    af_nonpayload_pkt_status        <= af_nonpayload_pkt_r2;
    af_check_pkt_r1                 <= af_check_pkt;
    af_check_pkt_r2                 <= af_check_pkt_r1;
    af_check_pkt_status             <= af_check_pkt_r2;
    af_sm_r1                        <= af_sm;
    af_sm_r2                        <= af_sm_r1;
    af_sm_status                    <= af_sm_r2;
    max_nocheckpkt_fifo_r1          <= max_nocheckpkt_fifo;
    max_nocheckpkt_fifo_r2          <= max_nocheckpkt_fifo_r1;
    max_nocheckpkt_fifo_status      <= max_nocheckpkt_fifo_r2;
    max_nonpayload_fifo_r1          <= max_nonpayload_fifo;
    max_nonpayload_fifo_r2          <= max_nonpayload_fifo_r1;
    max_nonpayload_fifo_status      <= max_nonpayload_fifo_r2;
    current_nocheckpkt_fifo_r1      <= current_nocheckpkt_fifo;
    current_nocheckpkt_fifo_r2      <= current_nocheckpkt_fifo_r1;
    current_nocheckpkt_fifo_status  <= current_nocheckpkt_fifo_r2;
    no_check_pkt_sop_r1             <= no_check_pkt_sop;
    no_check_pkt_sop_r2             <= no_check_pkt_sop_r1;
    no_check_pkt_sop_status         <= no_check_pkt_sop_r2;
    pkt_done_sop_r1                 <= pkt_done_sop;
    pkt_done_sop_r2                 <= pkt_done_sop_r1;
    pkt_done_sop_status             <= pkt_done_sop_r2;
    nonpayload_pkt_r1               <= nonpayload_pkt;
    nonpayload_pkt_r2               <= nonpayload_pkt_r1;
    nonpayload_pkt_status           <= nonpayload_pkt_r2;
    nonpayload_pkt_sop_r1           <= nonpayload_pkt_sop;
    nonpayload_pkt_sop_r2           <= nonpayload_pkt_sop_r1;
    nonpayload_pkt_sop_status       <= nonpayload_pkt_sop_r2;
    data_mover_check_pkt_error_r1           <= data_mover_check_pkt_error;
    data_mover_check_pkt_error_r2           <= data_mover_check_pkt_error_r1;
    data_mover_check_pkt_error_status       <= data_mover_check_pkt_error_r2;
    nf_no_check_pkt_r1              <= nf_no_check_pkt;
    nf_no_check_pkt_r2              <= nf_no_check_pkt_r1;
    nf_no_check_pkt_status          <= nf_no_check_pkt_r2;
    nf_no_check_1_pkt_r1            <= nf_no_check_1_pkt;
    nf_no_check_1_pkt_r2            <= nf_no_check_1_pkt_r1;
    nf_no_check_1_pkt_status        <= nf_no_check_1_pkt_r2;
    nf_max_raw_pkt_fifo_r1          <= nf_max_raw_pkt_fifo;
    nf_max_raw_pkt_fifo_r2          <= nf_max_raw_pkt_fifo_r1;
    nf_max_raw_pkt_fifo_status      <= nf_max_raw_pkt_fifo_r2;
    nf_max_pkt_fifo_r1              <= nf_max_pkt_fifo;
    nf_max_pkt_fifo_r2              <= nf_max_pkt_fifo_r1;
    nf_max_pkt_fifo_status          <= nf_max_pkt_fifo_r2;
    nf_max_pcie_r1                  <= nf_max_pcie;
    nf_max_pcie_r2                  <= nf_max_pcie_r1;
    nf_max_pcie_status              <= nf_max_pcie_r2;
    nf_max_rule_fifo_r1             <= nf_max_rule_fifo;
    nf_max_rule_fifo_r2             <= nf_max_rule_fifo_r1;
    nf_max_rule_fifo_status         <= nf_max_rule_fifo_r2;
end
//registers
always @(posedge clk_status) begin
    status_addr_r           <= status_addr[7:0];
    status_addr_sel_r       <= status_addr[29:30-STAT_AWIDTH];

    status_read_r           <= status_read;
    status_write_r          <= status_write;
    status_writedata_r      <= status_writedata;
    status_readdata_valid_top <= 1'b0;

    if (status_read_r) begin
        if (status_addr_sel_r == TOP_REG) begin
            status_readdata_valid_top <= 1'b1;
            case (status_addr_r)
                8'd0  : status_readdata_top <= in_pkt_cnt_status;
                8'd1  : status_readdata_top <= out_pkt_cnt_incomp_status;
                8'd2  : status_readdata_top <= out_pkt_cnt_parser_status;
                8'd3  : status_readdata_top <= in_pkt_cnt_ft_status;
                8'd4  : status_readdata_top <= out_pkt_cnt_ft_status;
                8'd5  : status_readdata_top <= in_pkt_cnt_datamover_status;
                8'd6  : status_readdata_top <= out_pkt_cnt_status;
                8'd7  : status_readdata_top <= out_pkt_cnt_datamover_status;
                8'd8  : status_readdata_top <= in_pkt_cnt_emptylist_status;
                8'd9  : status_readdata_top <= out_pkt_cnt_emptylist_status;
                8'd10  : status_readdata_top <= pkt_forward_status;
                8'd11  : status_readdata_top <= pkt_drop_status;
                8'd12  : status_readdata_top <= pkt_check_status;
                8'd13  : status_readdata_top <= pkt_ooo_status;
                8'd14  : status_readdata_top <= pkt_forward_ooo_status;
                8'd15  : status_readdata_top <= pkt_done_status;
                8'd16  : status_readdata_top <= in_sm_in_pkt_status;
                8'd17  : status_readdata_top <= out_sm_in_pkt_status;
                8'd18  : status_readdata_top <= in_sm_out_pkt_status;
                8'd19  : status_readdata_top <= out_sm_out_pkt_status;
                8'd20  : status_readdata_top <= out_check_fifo_pkt_status;
                8'd21  : status_readdata_top <= in_check_mux_pkt_status;
                8'd22  : status_readdata_top <= dma_pkt_status;
                8'd23  : status_readdata_top <= rule_cnt_status;
                8'd24  : status_readdata_top <= max_rule_fifo_status;
                8'd25  : status_readdata_top <= max_sm_out_meta_status;
                8'd26  : status_readdata_top <= max_sm_indata_status;
                8'd27  : status_readdata_top <= max_parser_fifo_status;
                8'd28  : status_readdata_top <= max_check_pkt_fifo_status;
                8'd29  : status_readdata_top <= no_check_pkt_status;
                8'd30  : status_readdata_top <= no_match_pkt_status;
                8'd31  : status_readdata_top <= match_pkt_status;
                8'd32  : status_readdata_top <= max_pdumeta_cnt_status;
                8'd33  : status_readdata_top <= pg_rule_cnt_status;
                8'd34  : status_readdata_top <= pg_meta_cnt_status;
                8'd35  : status_readdata_top <= pg_no_pg_rule_cnt_status;
                8'd36  : status_readdata_top <= pg_int_rule_cnt_status;
                8'd37  : status_readdata_top <= max_pg_rule_fifo_status;
                8'd38  : status_readdata_top <= af_nonpayload_pkt_status;
                8'd39  : status_readdata_top <= af_check_pkt_status;
                8'd40  : status_readdata_top <= af_sm_status;
                8'd41  : status_readdata_top <= max_nocheckpkt_fifo_status;
                8'd42  : status_readdata_top <= max_nonpayload_fifo_status;
                8'd43  : status_readdata_top <= current_nocheckpkt_fifo_status;
                8'd44  : status_readdata_top <= no_check_pkt_sop_status;
                8'd45  : status_readdata_top <= pkt_done_sop_status;
                8'd46  : status_readdata_top <= nonpayload_pkt_status;
                8'd47  : status_readdata_top <= nonpayload_pkt_sop_status;
                8'd48  : status_readdata_top <= data_mover_check_pkt_error_status;
                8'd49  : status_readdata_top <= nf_no_check_pkt_status;
                8'd50  : status_readdata_top <= nf_no_check_1_pkt_status;
                8'd51  : status_readdata_top <= nf_max_raw_pkt_fifo_status;
                8'd52  : status_readdata_top <= nf_max_pkt_fifo_status;
                8'd53  : status_readdata_top <= nf_max_pcie_status;
                8'd54  : status_readdata_top <= nf_max_rule_fifo_status;
                8'd55  : status_readdata_top <= ctrl_status;

                default : status_readdata_top <= 32'h345;
            endcase
        end
    end

    if (status_addr_sel_r == TOP_REG & status_write_r) begin
        case (status_addr_r)
            8'd55: begin
                ctrl_status   <= status_writedata_r;
            end
            default: ctrl_status <= 32'b0;
        endcase
    end
end

assign nf_forward_th = ctrl_status[15:0];

// Top has higher priority.
always @(posedge clk_status) begin
    if (status_readdata_valid_top) begin
        status_readdata_valid <= 1'b1;
        status_readdata <= status_readdata_top;
    end
    else if (status_readdata_valid_ft) begin
        status_readdata_valid <= 1'b1;
        status_readdata <= status_readdata_ft;
    end
    else if (status_readdata_valid_ruleID) begin
        status_readdata_valid <= 1'b1;
        status_readdata <= status_readdata_ruleID;
    end
    else begin
        status_readdata_valid <= 1'b0;
    end
end
// Stats End

assign input_comp_eth_data  = reg_in_data;
assign input_comp_eth_valid = reg_in_valid;
assign input_comp_eth_sop   = reg_in_sop;
assign input_comp_eth_eop   = reg_in_eop;
assign input_comp_eth_empty = reg_in_empty;
// No rx back pressure at the input. The difference between
// in_pkt_cnt and out_pkt_incomp is the dropped pkts.

assign pcie_rb_update_valid = reg_disable_pcie ? 1'b0 : internal_rb_update_valid;
assign out_valid_int = out_valid & !reg_out_almost_full;

// PDU meta occupancy cnt
assign pdumeta_cnt = pdumeta_cpu_csr_readdata[9:0];

//////////////////// Debug //////////////////////////////////
always @(posedge clk) begin

    if (!rst) begin
        assert(!(ftw_out_meta_valid & !ftw_out_meta_ready))
        else begin
            $error("Write to full datamover_data_fifo");
            $finish;
        end

        assert(!(ftw_forward_meta_valid & !ftw_forward_meta_ready))
        else begin
            $error("Write to full datamover_ack_fifo");
            $finish;
        end
    end
end

//////////////////// Instantiation //////////////////////////////////
hyper_pipe_root reg_io_inst (
    //clk & rst
    .clk                    (clk),
    .rst                    (rst),
    .clk_datamover          (clk_datamover),
    .rst_datamover          (rst_datamover),
    .clk_pcie               (clk_pcie),
    .rst_pcie               (rst_pcie),
    //Ethernet in & out data
    .in_data                (in_data),
    .in_valid               (in_valid),
    .in_sop                 (in_sop),
    .in_eop                 (in_eop),
    .in_empty               (in_empty),
    .out_data               (out_data),
    .out_valid              (out_valid_int),
    .out_almost_full        (out_almost_full),
    .out_sop                (out_sop),
    .out_eop                (out_eop),
    .out_empty              (out_empty),
    //PCIe
    .pcie_rb_wr_data        (pcie_rb_wr_data),
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),
    .pcie_rb_wr_en          (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),
    .pcie_rb_almost_full    (pcie_rb_almost_full),
    .pcie_rb_update_valid   (pcie_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdumeta_cpu_data       (pdumeta_cpu_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_valid),
    .pdumeta_cnt            (pdumeta_cnt),
    //DRAM
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_valid),
    .ddr_rd_resp_almost_full(ddr_rd_resp_almost_full),
    //eSRAM
    .esram_pkt_buf_wren     (esram_pkt_buf_wren),
    .esram_pkt_buf_wraddress(esram_pkt_buf_wraddress),
    .esram_pkt_buf_wrdata   (esram_pkt_buf_wrdata),
    .esram_pkt_buf_rden     (esram_pkt_buf_rden),
    .esram_pkt_buf_rdaddress(esram_pkt_buf_rdaddress),
    .esram_pkt_buf_rd_valid (esram_pkt_buf_rd_valid),
    .esram_pkt_buf_rddata   (esram_pkt_buf_rddata),
    //output
    .reg_in_data                (reg_in_data),
    .reg_in_valid               (reg_in_valid),
    .reg_in_sop                 (reg_in_sop),
    .reg_in_eop                 (reg_in_eop),
    .reg_in_empty               (reg_in_empty),
    .reg_out_data               (reg_out_data),
    .reg_out_valid              (reg_out_valid),
    .reg_out_almost_full        (reg_out_almost_full),
    .reg_out_sop                (reg_out_sop),
    .reg_out_eop                (reg_out_eop),
    .reg_out_empty              (reg_out_empty),
    .reg_pcie_rb_wr_data        (reg_pcie_rb_wr_data),
    .reg_pcie_rb_wr_addr        (reg_pcie_rb_wr_addr),
    .reg_pcie_rb_wr_en          (reg_pcie_rb_wr_en),
    .reg_pcie_rb_wr_base_addr   (reg_pcie_rb_wr_base_addr),
    .reg_pcie_rb_almost_full    (reg_pcie_rb_almost_full),
    .reg_pcie_rb_update_valid   (reg_pcie_rb_update_valid),
    .reg_pcie_rb_update_size    (reg_pcie_rb_update_size),
    .reg_disable_pcie           (reg_disable_pcie),
    .reg_pdumeta_cpu_data       (reg_pdumeta_cpu_data),
    .reg_pdumeta_cpu_valid      (reg_pdumeta_cpu_valid),
    .reg_pdumeta_cnt            (reg_pdumeta_cnt),
    .reg_ddr_wr_req_data        (reg_ddr_wr_req_data),
    .reg_ddr_wr_req_valid       (reg_ddr_wr_req_valid),
    .reg_ddr_wr_req_almost_full (reg_ddr_wr_req_almost_full),
    .reg_ddr_rd_req_data        (reg_ddr_rd_req_data),
    .reg_ddr_rd_req_valid       (reg_ddr_rd_req_valid),
    .reg_ddr_rd_req_almost_full (reg_ddr_rd_req_almost_full),
    .reg_ddr_rd_resp_data       (reg_ddr_rd_resp_data),
    .reg_ddr_rd_resp_valid      (reg_ddr_rd_resp_valid),
    .reg_ddr_rd_resp_almost_full(reg_ddr_rd_resp_almost_full),
    .reg_esram_pkt_buf_wren     (reg_esram_pkt_buf_wren),
    .reg_esram_pkt_buf_wraddress(reg_esram_pkt_buf_wraddress),
    .reg_esram_pkt_buf_wrdata   (reg_esram_pkt_buf_wrdata),
    .reg_esram_pkt_buf_rden     (reg_esram_pkt_buf_rden),
    .reg_esram_pkt_buf_rdaddress(reg_esram_pkt_buf_rdaddress),
    .reg_esram_pkt_buf_rd_valid (reg_esram_pkt_buf_rd_valid),
    .reg_esram_pkt_buf_rddata   (reg_esram_pkt_buf_rddata)
);

input_comp input_comp_0 (
    .clk                    (clk_datamover),
    .rst                    (rst_datamover),
    .eth_sop                (input_comp_eth_sop),
    .eth_eop                (input_comp_eth_eop),
    .eth_data               (input_comp_eth_data),
    .eth_empty              (input_comp_eth_empty),
    .eth_valid              (input_comp_eth_valid),
    .pkt_buffer_address     (esram_pkt_buf_wraddress),
    .pkt_buffer_write       (esram_pkt_buf_wren),
    .pkt_buffer_writedata   (esram_pkt_buf_wrdata),
    .emptylist_out_data     (emptylist_out_data),
    .emptylist_out_valid    (emptylist_out_valid),
    .emptylist_out_ready    (emptylist_out_ready),
    .pkt_sop                (input_comp_pkt_sop),
    .pkt_eop                (input_comp_pkt_eop),
    .pkt_valid              (input_comp_pkt_valid),
    .pkt_data               (input_comp_pkt_data),
    .pkt_empty              (input_comp_pkt_empty),
    .pkt_ready              (input_comp_pkt_ready),
    .meta_valid             (input_comp_metadata_valid),
    .meta_data              (input_comp_metadata_data),
    .meta_ready             (input_comp_metadata_ready)
);

parser parser_0 (
    .clk            (clk_datamover),
    .rst            (rst_datamover),
    .in_pkt_data    (input_comp_pkt_data),
    .in_pkt_valid   (input_comp_pkt_valid),
    .in_pkt_ready   (input_comp_pkt_ready),
    .in_pkt_sop     (input_comp_pkt_sop),
    .in_pkt_eop     (input_comp_pkt_eop),
    .in_pkt_empty   (input_comp_pkt_empty),
    .out_pkt_data   (),
    .out_pkt_valid  (),
    .out_pkt_ready  (),
    .out_pkt_sop    (),
    .out_pkt_eop    (),
    .out_pkt_empty  (),
    .in_meta_data   (input_comp_metadata_data),
    .in_meta_valid  (input_comp_metadata_valid),
    .in_meta_ready  (input_comp_metadata_ready),
    .out_meta_data  (parser_out_meta_data),
    .out_meta_valid (parser_out_meta_valid),
    .out_meta_ready (parser_out_meta_ready)
);

//fifo big enough
dc_fifo_wrapper_infill  #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(PKT_NUM),
    .USE_PACKETS(0)
)
parser_out_fifo (
    .in_clk            (clk_datamover),
    .in_reset_n        (!rst_datamover),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_csr_address    (0),
    .in_csr_read       (1'b1),
    .in_csr_write      (1'b0),
    .in_csr_readdata   (parser_out_meta_csr_readdata),
    .in_csr_writedata  (32'b0),
    .in_data           (parser_out_meta_data),
    .in_valid          (parser_out_meta_valid),
    .in_ready          (parser_out_meta_ready),
    .in_startofpacket  (1'b0),
    .in_endofpacket    (1'b0),
    .in_empty          (6'b0),
    .out_data          (parser_out_fifo_out_data),
    .out_valid         (parser_out_fifo_out_valid),
    .out_ready         (parser_out_fifo_out_ready),
    .out_startofpacket (),
    .out_endofpacket   (),
    .out_empty         ()
);

flow_table_wrapper ftw_0 (
    .clk                       (clk),
    .rst                       (rst),
    .in_meta_data              (parser_out_fifo_out_data),
    .in_meta_valid             (parser_out_fifo_out_valid),
    .in_meta_ready             (parser_out_fifo_out_ready),
    .out_meta_data             (ftw_out_meta_data),
    .out_meta_valid            (ftw_out_meta_valid),
    .out_meta_ready            (ftw_out_meta_ready),
    .out_meta_almost_full      (ftw_out_meta_almost_full),
    .forward_meta_data         (ftw_forward_meta_data),
    .forward_meta_valid        (ftw_forward_meta_valid),
    .forward_meta_ready        (ftw_forward_meta_ready),
    .reorder_meta_data         (ftw_reorder_meta_data),
    .reorder_meta_valid        (ftw_reorder_meta_valid),
    .reorder_meta_ready        (ftw_reorder_meta_ready),
    .reorder_meta_almost_full  (ftw_reorder_meta_almost_full),
    .clk_status                (clk_status),
    .status_addr               (status_addr),
    .status_read               (status_read),
    .status_write              (status_write),
    .status_writedata          (status_writedata),
    .status_readdata           (status_readdata_ft),
    .status_readdata_valid     (status_readdata_valid_ft)
);

arb_2_wrapper_infill #(
    .DWIDTH(META_WIDTH),
    .DEPTH(512),
    .FULL_LEVEL(480)
)
arb_inorder_ooo(
    .clk              (clk),
    .rst              (rst),
    .clk_out          (clk),
    .rst_out          (rst),
    .in_data_0        (ftw_out_meta_data),
    .in_valid_0       (ftw_out_meta_valid),
    .in_ready_0       (ftw_out_meta_ready),
    .in_almost_full_0 (ftw_out_meta_almost_full),
    .in_data_1        (ftw_reorder_meta_data),
    .in_valid_1       (ftw_reorder_meta_valid),
    .in_ready_1       (ftw_reorder_meta_ready),
    .in_almost_full_1 (ftw_reorder_meta_almost_full),
    .out_data         (ftw_nonforward_meta_data),
    .out_valid        (ftw_nonforward_meta_valid),
    .out_ready        (ftw_nonforward_meta_ready)
);

arb_2_wrapper #(
    .DWIDTH(META_WIDTH),
    .DEPTH(512)
)
arb_forward(
    .clk        (clk),
    .rst        (rst),
    .clk_out    (clk_datamover),
    .rst_out    (rst_datamover),
    .in_data_0  (ftw_nonforward_meta_data),
    .in_valid_0 (ftw_nonforward_meta_valid),
    .in_ready_0 (ftw_nonforward_meta_ready),
    .in_data_1  (ftw_forward_meta_data),
    .in_valid_1 (ftw_forward_meta_valid),
    .in_ready_1 (ftw_forward_meta_ready),
    .out_data   (data_mover_in_meta_data),
    .out_valid  (data_mover_in_meta_valid),
    .out_ready  (data_mover_in_meta_ready)
);

data_mover data_mover_0 (
    .clk                    (clk_datamover),
    .rst                    (rst_datamover),
    .pkt_buffer_address     (esram_pkt_buf_rdaddress),
    .pkt_buffer_read        (esram_pkt_buf_rden),
    .pkt_buffer_readvalid   (reg_esram_pkt_buf_rd_valid),
    .pkt_buffer_readdata    (reg_esram_pkt_buf_rddata),
    .emptylist_in_data      (emptylist_in_data),
    .emptylist_in_valid     (emptylist_in_valid),
    .emptylist_in_ready     (emptylist_in_ready),
    .pkt_sop                (data_mover_pkt_sop),
    .pkt_eop                (data_mover_pkt_eop),
    .pkt_valid              (data_mover_pkt_valid),
    .pkt_data               (data_mover_pkt_data),
    .pkt_empty              (data_mover_pkt_empty),
    .pkt_ready              (data_mover_pkt_ready),
    .pkt_almost_full        (data_mover_pkt_almost_full),
    .check_pkt_sop          (data_mover_check_pkt_sop),
    .check_pkt_eop          (data_mover_check_pkt_eop),
    .check_pkt_valid        (data_mover_check_pkt_valid),
    .check_pkt_data         (data_mover_check_pkt_data),
    .check_pkt_empty        (data_mover_check_pkt_empty),
    .check_pkt_ready        (data_mover_check_pkt_ready),
    .check_pkt_almost_full  (data_mover_check_pkt_almost_full),
    .check_pkt_hdr          (data_mover_check_pkt_hdr),
    .check_meta_valid       (data_mover_check_meta_valid),
    .check_meta_data        (data_mover_check_meta_data),
    .check_meta_ready       (data_mover_check_meta_ready),
    .meta_valid             (data_mover_in_meta_valid),
    .meta_data              (data_mover_in_meta_data),
    .meta_ready             (data_mover_in_meta_ready)
);
//////////////////// PORT_GROUP //////////////////////////////////
port_group port_group_inst(
    .clk                    (clk_pcie),
    .rst                    (rst_pcie),
    .in_match_sop           (rule_sop),
    .in_match_eop           (rule_eop),
    .in_match_data          (rule_data),
    .in_match_empty         (rule_empty),
    .in_match_valid         (rule_valid),
    .in_match_ready         (rule_ready),
    .in_meta_valid          (sm_out_valid),
    .in_meta_data           (sm_out_data),
    .in_meta_ready          (sm_out_ready),
    .out_match_sop          (pg_rule_sop),
    .out_match_eop          (pg_rule_eop),
    .out_match_data         (pg_rule_data),
    .out_match_empty        (pg_rule_empty),
    .out_match_valid        (pg_rule_valid),
    .out_match_ready        (pg_rule_ready),
    .out_match_almost_full  (pg_rule_almost_full),
    .out_meta_valid         (pg_meta_valid),
    .out_meta_data          (pg_meta_data),
    .out_meta_ready         (pg_meta_ready),
    .no_pg_rule_cnt         (pg_no_pg_rule_cnt),
    .pg_rule_cnt            (pg_int_rule_cnt)
);

fifo_pkt_wrapper_infill #(
    //.SYMBOLS_PER_BEAT(64),
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
pg_rule_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (pg_rule_csr_readdata),
    .csr_writedata     (0),
    .in_data           (pg_rule_data),
    .in_valid          (pg_rule_valid),
    .in_ready          (pg_rule_ready), // Use almost full
    .in_startofpacket  (pg_rule_sop),
    .in_endofpacket    (pg_rule_eop),
    .in_empty          (pg_rule_empty),
    .out_data          (pg_rule_fifo_data),
    .out_valid         (pg_rule_fifo_valid),
    .out_ready         (pg_rule_fifo_ready),
    .out_startofpacket (pg_rule_fifo_sop),
    .out_endofpacket   (pg_rule_fifo_eop),
    .out_empty         (pg_rule_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_pg_rule_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (pg_rule_csr_readdata),
    .csr_writedata  (),
    .almost_full    (pg_rule_almost_full)
);

fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
pg_meta_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .in_data           (pg_meta_data),
    .in_valid          (pg_meta_valid),
    .in_ready          (pg_meta_ready), // Use almost full
    .out_data          (pg_meta_fifo_data),
    .out_valid         (pg_meta_fifo_valid),
    .out_ready         (pg_meta_fifo_ready)
);

////////////////////// Non Fast Pattern //////////////////////////////////
non_fast_pattern non_fast_pattern_inst(
    .clk                    (clk_pcie),
    .rst                    (rst_pcie),
    .clk_high               (clk_high),
    .rst_high               (rst),
    .in_sop                 (check_pkt_fifo_sop),
    .in_eop                 (check_pkt_fifo_eop),
    .in_data                (check_pkt_fifo_data),
    .in_empty               (check_pkt_fifo_empty),
    .in_valid               (check_pkt_fifo_valid),
    .in_ready               (check_pkt_fifo_ready),
    .in_rule_sop            (pg_rule_fifo_sop),
    .in_rule_eop            (pg_rule_fifo_eop),
    .in_rule_data           (pg_rule_fifo_data),
    .in_rule_empty          (pg_rule_fifo_empty),
    .in_rule_valid          (pg_rule_fifo_valid),
    .in_rule_ready          (pg_rule_fifo_ready),
    .in_meta_valid          (pg_meta_fifo_valid),
    .in_meta_ready          (pg_meta_fifo_ready),
    .in_meta_data           (pg_meta_fifo_data),
    .out_data               (nf_out_data),
    .out_sop                (nf_out_sop),
    .out_eop                (nf_out_eop),
    .out_empty              (nf_out_empty),
    .out_valid              (nf_out_valid),
    .out_ready              (nf_out_ready),
    .out_almost_full        (nf_out_almost_full),
    .no_check_data          (nf_no_check_data),
    .no_check_sop           (nf_no_check_sop),
    .no_check_eop           (nf_no_check_eop),
    .no_check_empty         (nf_no_check_empty),
    .no_check_valid         (nf_no_check_valid),
    .no_check_ready         (nf_no_check_ready),
    .no_check_almost_full   (nf_no_check_almost_full),
    .no_check_1_data        (nf_no_check_1_data),
    .no_check_1_sop         (nf_no_check_1_sop),
    .no_check_1_eop         (nf_no_check_1_eop),
    .no_check_1_empty       (nf_no_check_1_empty),
    .no_check_1_valid       (nf_no_check_1_valid),
    .no_check_1_ready       (nf_no_check_1_ready),
    .no_check_1_almost_full (nf_no_check_1_almost_full),
    .out_rule_data          (nf_rule_data),
    .out_rule_sop           (nf_rule_sop),
    .out_rule_eop           (nf_rule_eop),
    .out_rule_empty         (nf_rule_empty),
    .out_rule_valid         (nf_rule_valid),
    .out_rule_ready         (nf_rule_ready),
    .out_rule_almost_full   (nf_rule_almost_full),
    .out_meta_data          (nf_meta_data),
    .out_meta_valid         (nf_meta_valid),
    .out_meta_ready         (nf_meta_ready),
    .max_raw_pkt_fifo       (nf_max_raw_pkt_fifo),
    .max_pkt_fifo           (nf_max_pkt_fifo),
    .max_rule_fifo          (nf_max_rule_fifo),
    .forward_th             (nf_forward_th)
);

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
nf_pkt_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (nf_out_csr_readdata),
    .csr_writedata     (0),
    .in_data           (nf_out_data),
    .in_valid          (nf_out_valid),
    .in_ready          (nf_out_ready), // Use almost full
    .in_startofpacket  (nf_out_sop),
    .in_endofpacket    (nf_out_eop),
    .in_empty          (nf_out_empty),
    .out_data          (nf_out_fifo_data),
    .out_valid         (nf_out_fifo_valid),
    .out_ready         (nf_out_fifo_ready),
    .out_startofpacket (nf_out_fifo_sop),
    .out_endofpacket   (nf_out_fifo_eop),
    .out_empty         (nf_out_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_nf_pkt_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (nf_out_csr_readdata),
    .csr_writedata  (),
    .almost_full    (nf_out_almost_full)
);

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
nf_no_check_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (nf_no_check_csr_readdata),
    .csr_writedata     (0),
    .in_data           (nf_no_check_data),
    .in_valid          (nf_no_check_valid),
    .in_ready          (nf_no_check_ready), // Use almost full
    .in_startofpacket  (nf_no_check_sop),
    .in_endofpacket    (nf_no_check_eop),
    .in_empty          (nf_no_check_empty),
    .out_data          (nf_no_check_fifo_data),
    .out_valid         (nf_no_check_fifo_valid),
    .out_ready         (nf_no_check_fifo_ready),
    .out_startofpacket (nf_no_check_fifo_sop),
    .out_endofpacket   (nf_no_check_fifo_eop),
    .out_empty         (nf_no_check_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_nf_no_check_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (nf_no_check_csr_readdata),
    .csr_writedata  (),
    .almost_full    (nf_no_check_almost_full)
);

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
nf_no_check_1_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (nf_no_check_1_csr_readdata),
    .csr_writedata     (0),
    .in_data           (nf_no_check_1_data),
    .in_valid          (nf_no_check_1_valid),
    .in_ready          (nf_no_check_1_ready), // Use almost full
    .in_startofpacket  (nf_no_check_1_sop),
    .in_endofpacket    (nf_no_check_1_eop),
    .in_empty          (nf_no_check_1_empty),
    .out_data          (nf_no_check_1_fifo_data),
    .out_valid         (nf_no_check_1_fifo_valid),
    .out_ready         (nf_no_check_1_fifo_ready),
    .out_startofpacket (nf_no_check_1_fifo_sop),
    .out_endofpacket   (nf_no_check_1_fifo_eop),
    .out_empty         (nf_no_check_1_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_nf_no_check_1_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (nf_no_check_1_csr_readdata),
    .csr_writedata  (),
    .almost_full    (nf_no_check_1_almost_full)
);


fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
nf_rule_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (nf_rule_csr_readdata),
    .csr_writedata     (0),
    .in_data           (nf_rule_data),
    .in_valid          (nf_rule_valid),
    .in_ready          (nf_rule_ready), // Use almost full
    .in_startofpacket  (nf_rule_sop),
    .in_endofpacket    (nf_rule_eop),
    .in_empty          (nf_rule_empty),
    .out_data          (nf_rule_fifo_data),
    .out_valid         (nf_rule_fifo_valid),
    .out_ready         (nf_rule_fifo_ready),
    .out_startofpacket (nf_rule_fifo_sop),
    .out_endofpacket   (nf_rule_fifo_eop),
    .out_empty         (nf_rule_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_nf_rule_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (nf_rule_csr_readdata),
    .csr_writedata  (),
    .almost_full    (nf_rule_almost_full)
);


rule_packer_128_512 rule_packer_inst(
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .in_rule_data   (nf_rule_fifo_data),
    .in_rule_valid  (nf_rule_fifo_valid),
    .in_rule_ready  (nf_rule_fifo_ready), // Use almost full
    .in_rule_sop    (nf_rule_fifo_sop),
    .in_rule_eop    (nf_rule_fifo_eop),
    .in_rule_empty  (nf_rule_fifo_empty),
    .out_rule_data  (rule_packer_data),
    .out_rule_valid (rule_packer_valid),
    .out_rule_ready (rule_packer_ready),
    .out_rule_sop   (rule_packer_sop),
    .out_rule_eop   (rule_packer_eop),
    .out_rule_empty (rule_packer_empty)
);

fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
nf_meta_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .in_data           (nf_meta_data),
    .in_valid          (nf_meta_valid),
    .in_ready          (nf_meta_ready), // Use almost full
    .out_data          (nf_meta_fifo_data),
    .out_valid         (nf_meta_fifo_valid),
    .out_ready         (nf_meta_fifo_ready)
);

//////////////////// Datamover To PDU_GEN //////////////////////////////////
pdu_gen pdu_gen_inst(
    .clk                    (clk_pcie),
    .rst                    (rst_pcie),
    .in_sop                 (nf_out_fifo_sop),
    .in_eop                 (nf_out_fifo_eop),
    .in_data                (nf_out_fifo_data),
    .in_empty               (nf_out_fifo_empty),
    .in_valid               (nf_out_fifo_valid),
    .in_ready               (nf_out_fifo_ready),
    .in_match_sop           (rule_packer_sop),
    .in_match_eop           (rule_packer_eop),
    .in_match_data          (rule_packer_data),
    .in_match_empty         (rule_packer_empty),
    .in_match_valid         (rule_packer_valid),
    .in_match_ready         (rule_packer_ready),
    .in_meta_valid          (nf_meta_fifo_valid),
    .in_meta_ready          (nf_meta_fifo_ready),
    .in_meta_data           (nf_meta_fifo_data),
    .pcie_rb_wr_data        (pcie_rb_wr_data),
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),
    .pcie_rb_wr_en          (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr   (reg_pcie_rb_wr_base_addr),
    .pcie_rb_almost_full    (reg_pcie_rb_almost_full),
    .pcie_rb_update_valid   (internal_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (reg_disable_pcie),
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
fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(PDU_META_WIDTH),
    .FIFO_DEPTH(512)
) pdumeta_cpu_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (pdumeta_cpu_csr_readdata),
    .csr_writedata     (0),
    .in_data           (reg_pdumeta_cpu_data),
    .in_valid          (reg_pdumeta_cpu_valid),
    .in_ready          (pdumeta_cpu_ready),
    .out_data          (pdumeta_cpu_out_data),
    .out_valid         (pdumeta_cpu_out_valid),
    .out_ready         (pdumeta_cpu_out_ready)
);

fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(512),
    .FIFO_DEPTH(512)
) ddr_resp_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (ddr_rd_resp_csr_readdata),
    .csr_writedata     (0),
    .in_data           (reg_ddr_rd_resp_data),
    .in_valid          (reg_ddr_rd_resp_valid),
    .in_ready          (ddr_rd_resp_ready),
    .out_data          (ddr_rd_resp_out_data),
    .out_valid         (ddr_rd_resp_out_valid),
    .out_ready         (ddr_rd_resp_out_ready)
);

dc_back_pressure #(
    .FULL_LEVEL(490)
)
bp_resp_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (ddr_rd_resp_csr_readdata),
    .csr_writedata  (),
    .almost_full    (ddr_rd_resp_almost_full)
);

pdu_data_mover pdu_data_mover_inst (
    .clk                    (clk_pcie),
    .rst                    (rst_pcie),
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
    .pdumeta_cpu_data       (pdumeta_cpu_out_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_out_valid),
    .pdumeta_cpu_ready      (pdumeta_cpu_out_ready),
    .nocheck_data           (nocheck_data),
    .nocheck_sop            (nocheck_sop),
    .nocheck_eop            (nocheck_eop),
    .nocheck_valid          (nocheck_valid),
    .nocheck_empty          (nocheck_empty),
    .nocheck_ready          (),                     // Not using ready signal,
    .nocheck_almost_full    (nocheck_almost_full),  // Use almost_full signal
    .nomatch_data           (nomatch_data),
    .nomatch_sop            (nomatch_sop),
    .nomatch_eop            (nomatch_eop),
    .nomatch_valid          (nomatch_valid),
    .nomatch_empty          (nomatch_empty),
    .nomatch_ready          (),                     // Not using ready signal,
    .nomatch_almost_full    (nomatch_almost_full),  // Use almost_full signal
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (reg_ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (reg_ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_out_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_out_valid),
    .ddr_rd_resp_ready      (ddr_rd_resp_out_ready)
);
//////////////////// Datamover To string matcher //////////////////////////////////


data_align data_align_inst (
    .clk            (clk_datamover),
    .rst            (rst_datamover),
    .in_pkt_hdr     (data_mover_check_pkt_hdr),
    .in_pkt_sop     (data_mover_check_pkt_sop),
    .in_pkt_eop     (data_mover_check_pkt_eop),
    .in_pkt_valid   (data_mover_check_pkt_valid),
    .in_pkt_data    (data_mover_check_pkt_data),
    .in_pkt_empty   (data_mover_check_pkt_empty),
    .in_pkt_ready   (),                             // Fully pipelined
    .out_pkt_sop    (data_align_out_sop),
    .out_pkt_eop    (data_align_out_eop),
    .out_pkt_valid  (data_align_out_valid),
    .out_pkt_data   (data_align_out_data),
    .out_pkt_empty  (data_align_out_empty),
    .out_pkt_ready  (1'b1)                          // Do not need the ready signal
);

hyper_pipe_sm reg_sm_io (
    .front_clk                  (clk_high),
    .front_rst                  (rst_high),
    .back_clk                   (clk_rule),
    .back_rst                   (rst_rule),
    .clk_datamover              (clk_datamover),
    .rst_datamover              (rst_datamover),
    .in_sop                     (data_align_out_sop),
    .in_eop                     (data_align_out_eop),
    .in_data                    (data_align_out_data),
    .in_valid                   (data_align_out_valid),
    .in_empty                   (data_align_out_empty),
    .in_almost_full             (sm_in_almost_full),
    .in_meta_valid              (data_mover_check_meta_valid),
    .in_meta_data               (data_mover_check_meta_data),
    .out_meta_valid             (string_matcher_meta_valid),
    .out_meta_data              (string_matcher_meta_data),
    .out_match_valid            (string_matcher_rule_valid),
    .out_match_data             (string_matcher_rule_data),
    .out_match_last             (string_matcher_rule_last),
    .out_match_almost_full      (string_matcher_rule_almost_full),
    .reg_in_sop                 (reg_data_align_out_sop),
    .reg_in_eop                 (reg_data_align_out_eop),
    .reg_in_data                (reg_data_align_out_data),
    .reg_in_valid               (reg_data_align_out_valid),
    .reg_in_empty               (reg_data_align_out_empty),
    .reg_in_almost_full         (reg_sm_in_almost_full),
    .reg_in_meta_valid          (reg_data_mover_check_meta_valid),
    .reg_in_meta_data           (reg_data_mover_check_meta_data),
    .reg_out_meta_valid         (reg_string_matcher_meta_valid),
    .reg_out_meta_data          (reg_string_matcher_meta_data),
    .reg_out_match_valid        (reg_string_matcher_rule_valid),
    .reg_out_match_data         (reg_string_matcher_rule_data),
    .reg_out_match_last         (reg_string_matcher_rule_last),
    .reg_out_match_almost_full  (reg_string_matcher_rule_almost_full)
);


string_matcher_wrapper sm_inst(
    .front_clk              (clk_high),
    .back_clk               (clk_rule),
    .rst                    (rst),
    .clk_datamover          (clk_datamover),
    .rst_datamover          (rst_datamover),
    .in_sop                 (reg_data_align_out_sop),
    .in_eop                 (reg_data_align_out_eop),
    .in_data                (reg_data_align_out_data),
    .in_empty               (reg_data_align_out_empty),
    .in_valid               (reg_data_align_out_valid),
    .reg_in_almost_full     (sm_in_almost_full),
    .in_meta_valid          (reg_data_mover_check_meta_valid),
    .in_meta_data           (reg_data_mover_check_meta_data),
    .reg_out_meta_valid     (string_matcher_meta_valid),
    .reg_out_meta_data      (string_matcher_meta_data),
    .reg_out_match_valid    (string_matcher_rule_valid),
    .reg_out_match_data     (string_matcher_rule_data),
    .reg_out_match_last     (string_matcher_rule_last),
    .out_match_almost_full  (reg_string_matcher_rule_almost_full),
    .clk_status             (clk_status),
    .status_addr            (status_addr),
    .status_read            (status_read),
    .status_write           (status_write),
    .status_writedata       (status_writedata),
    .status_readdata        (status_readdata_ruleID),
    .status_readdata_valid  (status_readdata_valid_ruleID)
);
dc_fifo_wrapper_infill  #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
sm_out_meta (
    .in_clk            (clk_high),
    .in_reset_n        (!rst_high),
    .out_clk           (clk_pcie),
    .out_reset_n       (!rst_pcie),
    .in_csr_address    (0),
    .in_csr_read       (1'b1),
    .in_csr_write      (1'b0),
    .in_csr_readdata   (sm_out_meta_csr_readdata),
    .in_csr_writedata  (32'b0),
    .in_data           (reg_string_matcher_meta_data),
    .in_valid          (reg_string_matcher_meta_valid),
    .in_ready          (), // Never full
    .in_startofpacket  (1'b0),
    .in_endofpacket    (1'b0),
    .in_empty          (6'b0),
    .out_data          (sm_out_data),
    .out_valid         (sm_out_valid),
    .out_ready         (sm_out_ready),
    .out_startofpacket (),
    .out_endofpacket   (),
    .out_empty         ()
);

dc_fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
rule_fifo (
    .in_clk            (clk_rule),
    .in_reset_n        (!rst_rule),
    .out_clk           (clk_pcie),
    .out_reset_n       (!rst_pcie),
    .in_csr_address    (rule_in_csr_address),
    .in_csr_read       (rule_in_csr_read),
    .in_csr_write      (rule_in_csr_write),
    .in_csr_readdata   (rule_in_csr_readdata),
    .in_csr_writedata  (rule_in_csr_writedata),
    .in_data           (reg_string_matcher_rule_data),
    .in_valid          (reg_string_matcher_rule_valid),
    .in_ready          (), // Use almost full
    .in_startofpacket  (1'b0),
    .in_endofpacket    (reg_string_matcher_rule_last),
    .in_empty          (4'b0),
    .out_data          (rule_data),
    .out_valid         (rule_valid),
    .out_ready         (rule_ready),
    .out_startofpacket (),
    .out_endofpacket   (rule_eop),
    .out_empty         ()
);

dc_back_pressure #(
    .FULL_LEVEL(500)
)
dc_bp_rule_fifo (
    .clk            (clk_rule),
    .rst            (rst_rule),
    .csr_address    (rule_in_csr_address),
    .csr_read       (rule_in_csr_read),
    .csr_write      (rule_in_csr_write),
    .csr_readdata   (rule_in_csr_readdata),
    .csr_writedata  (rule_in_csr_writedata),
    .almost_full    (string_matcher_rule_almost_full)
);

//////////////////// To Check FIFO //////////////////////////////////


dc_fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
check_pkt_fifo (
    .in_clk            (clk_datamover),
    .in_reset_n        (!rst_datamover),
    .out_clk           (clk_pcie),
    .out_reset_n       (!rst_pcie),
    .in_csr_address    (check_pkt_in_csr_address),
    .in_csr_read       (check_pkt_in_csr_read),
    .in_csr_write      (check_pkt_in_csr_write),
    .in_csr_readdata   (check_pkt_in_csr_readdata),
    .in_csr_writedata  (check_pkt_in_csr_writedata),
    .in_data           (data_mover_check_pkt_data),
    .in_valid          (data_mover_check_pkt_valid),
    .in_ready          (data_mover_check_pkt_ready),
    .in_startofpacket  (data_mover_check_pkt_sop),
    .in_endofpacket    (data_mover_check_pkt_eop),
    .in_empty          (data_mover_check_pkt_empty),
    .out_data          (check_pkt_fifo_data),
    .out_valid         (check_pkt_fifo_valid),
    //.out_ready         (check_pkt_fifo_real_ready),
    .out_ready         (check_pkt_fifo_ready),
    .out_startofpacket (check_pkt_fifo_sop),
    .out_endofpacket   (check_pkt_fifo_eop),
    .out_empty         (check_pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(430)
)
dc_bp_check_pkt_fifo (
    .clk            (clk_datamover),
    .rst            (rst_datamover),
    .csr_address    (check_pkt_in_csr_address),
    .csr_read       (check_pkt_in_csr_read),
    .csr_write      (check_pkt_in_csr_write),
    .csr_readdata   (check_pkt_in_csr_readdata),
    .csr_writedata  (check_pkt_in_csr_writedata),
    .almost_full    (check_pkt_almost_full)
);
assign data_mover_check_pkt_almost_full = check_pkt_almost_full | reg_sm_in_almost_full;
//////////////////// To NOCHECK FIFO //////////////////////////////////
fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
nocheck_pkt_fifo (
    .clk               (clk_pcie),
    .reset             (rst_pcie),
    .csr_address       (nocheck_in_csr_address),
    .csr_read          (nocheck_in_csr_read),
    .csr_write         (nocheck_in_csr_write),
    .csr_readdata      (nocheck_in_csr_readdata),
    .csr_writedata     (nocheck_in_csr_writedata),
    .in_data           (nocheck_data),
    .in_valid          (nocheck_valid),
    .in_ready          (nocheck_ready),
    .in_startofpacket  (nocheck_sop),
    .in_endofpacket    (nocheck_eop),
    .in_empty          (nocheck_empty),
    .out_data          (nocheck_out_data),
    .out_valid         (nocheck_out_valid),
    .out_ready         (nocheck_out_ready),
    .out_startofpacket (nocheck_out_sop),
    .out_endofpacket   (nocheck_out_eop),
    .out_empty         (nocheck_out_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(470)
)
dc_bp_nocheck_pkt_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (nocheck_in_csr_address),
    .csr_read       (nocheck_in_csr_read),
    .csr_write      (nocheck_in_csr_write),
    .csr_readdata   (nocheck_in_csr_readdata),
    .csr_writedata  (nocheck_in_csr_writedata),
    .almost_full    (nocheck_almost_full)
);

//////////////////// MUX for three FIFOs //////////////////////////////////

st_multiplexer_pkt_3 multiplexer_nocheck (
    .clk               (clk_pcie),
    .reset_n           (!rst_pcie),
    .out_data          (merge_nocheck_data),
    .out_valid         (merge_nocheck_valid),
    .out_ready         (merge_nocheck_ready),
    .out_startofpacket (merge_nocheck_sop),
    .out_endofpacket   (merge_nocheck_eop),
    .out_empty         (merge_nocheck_empty),
    .out_channel       (),
    .in0_data          (nocheck_out_data),
    .in0_valid         (nocheck_out_valid),
    .in0_ready         (nocheck_out_ready),
    .in0_startofpacket (nocheck_out_sop),
    .in0_endofpacket   (nocheck_out_eop),
    .in0_empty         (nocheck_out_empty),
    .in1_data          (nf_no_check_fifo_data),
    .in1_valid         (nf_no_check_fifo_valid),
    .in1_ready         (nf_no_check_fifo_ready),
    .in1_startofpacket (nf_no_check_fifo_sop),
    .in1_endofpacket   (nf_no_check_fifo_eop),
    .in1_empty         (nf_no_check_fifo_empty),
    .in2_data          (nf_no_check_1_fifo_data),
    .in2_valid         (nf_no_check_1_fifo_valid),
    .in2_ready         (nf_no_check_1_fifo_ready),
    .in2_startofpacket (nf_no_check_1_fifo_sop),
    .in2_endofpacket   (nf_no_check_1_fifo_eop),
    .in2_empty         (nf_no_check_1_fifo_empty)
);


//////////////////// To MERGE_NOCHECK FIFO //////////////////////////////////
dc_fifo_wrapper merge_nocheck_pkt_fifo (
    .in_clk            (clk_pcie),
    .in_reset_n        (!rst_pcie),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_data           (merge_nocheck_data),
    .in_valid          (merge_nocheck_valid),
    .in_ready          (merge_nocheck_ready),
    .in_startofpacket  (merge_nocheck_sop),
    .in_endofpacket    (merge_nocheck_eop),
    .in_empty          (merge_nocheck_empty),
    .out_data          (merge_nocheck_out_data),
    .out_valid         (merge_nocheck_out_valid),
    .out_ready         (merge_nocheck_out_ready),
    .out_startofpacket (merge_nocheck_out_sop),
    .out_endofpacket   (merge_nocheck_out_eop),
    .out_empty         (merge_nocheck_out_empty)
);

//////////////////// To NOMATCH FIFO //////////////////////////////////
dc_fifo_wrapper_infill nomatch_pkt_fifo (
    .in_clk            (clk_pcie),
    .in_reset_n        (!rst_pcie),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_csr_address    (nomatch_in_csr_address),
    .in_csr_read       (nomatch_in_csr_read),
    .in_csr_write      (nomatch_in_csr_write),
    .in_csr_readdata   (nomatch_in_csr_readdata),
    .in_csr_writedata  (nomatch_in_csr_writedata),
    .in_data           (nomatch_data),
    .in_valid          (nomatch_valid),
    .in_ready          (nomatch_ready),
    .in_startofpacket  (nomatch_sop),
    .in_endofpacket    (nomatch_eop),
    .in_empty          (nomatch_empty),
    .out_data          (nomatch_out_data),
    .out_valid         (nomatch_out_valid),
    .out_ready         (nomatch_out_ready),
    .out_startofpacket (nomatch_out_sop),
    .out_endofpacket   (nomatch_out_eop),
    .out_empty         (nomatch_out_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(480)
)
dc_bp_nomatch_pkt_fifo (
    .clk            (clk_pcie),
    .rst            (rst_pcie),
    .csr_address    (nomatch_in_csr_address),
    .csr_read       (nomatch_in_csr_read),
    .csr_write      (nomatch_in_csr_write),
    .csr_readdata   (nomatch_in_csr_readdata),
    .csr_writedata  (nomatch_in_csr_writedata),
    .almost_full    (nomatch_almost_full)
);
//////////////////// To OUTPUT FIFO //////////////////////////////////
dc_fifo_wrapper_infill output_pkt_fifo (
    .in_clk            (clk_datamover),
    .in_reset_n        (!rst_datamover),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_csr_address    (output_pkt_in_csr_address),
    .in_csr_read       (output_pkt_in_csr_read),
    .in_csr_write      (output_pkt_in_csr_write),
    .in_csr_readdata   (output_pkt_in_csr_readdata),
    .in_csr_writedata  (output_pkt_in_csr_writedata),
    .in_data           (data_mover_pkt_data),
    .in_valid          (data_mover_pkt_valid),
    .in_ready          (data_mover_pkt_ready),
    .in_startofpacket  (data_mover_pkt_sop),
    .in_endofpacket    (data_mover_pkt_eop),
    .in_empty          (data_mover_pkt_empty),
    .out_data          (output_pkt_fifo_data),
    .out_valid         (output_pkt_fifo_valid),
    .out_ready         (output_pkt_fifo_ready),
    .out_startofpacket (output_pkt_fifo_sop),
    .out_endofpacket   (output_pkt_fifo_eop),
    .out_empty         (output_pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(480)
)
dc_bp_output_pkt_fifo (
    .clk            (clk_datamover),
    .rst            (rst_datamover),
    .csr_address    (output_pkt_in_csr_address),
    .csr_read       (output_pkt_in_csr_read),
    .csr_write      (output_pkt_in_csr_write),
    .csr_readdata   (output_pkt_in_csr_readdata),
    .csr_writedata  (output_pkt_in_csr_writedata),
    .almost_full    (data_mover_pkt_almost_full)
);


//////////////////// MUX for three FIFOs //////////////////////////////////

st_multiplexer_pkt_3 multiplexer_pkt (
    .clk               (clk),
    .reset_n           (!rst),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (!reg_out_almost_full),
    .out_startofpacket (out_sop),
    .out_endofpacket   (out_eop),
    .out_empty         (out_empty),
    .out_channel       (),
    .in0_data          (merge_nocheck_out_data),
    .in0_valid         (merge_nocheck_out_valid),
    .in0_ready         (merge_nocheck_out_ready),
    .in0_startofpacket (merge_nocheck_out_sop),
    .in0_endofpacket   (merge_nocheck_out_eop),
    .in0_empty         (merge_nocheck_out_empty),
    .in1_data          (output_pkt_fifo_data),
    .in1_valid         (output_pkt_fifo_valid),
    .in1_ready         (output_pkt_fifo_ready),
    .in1_startofpacket (output_pkt_fifo_sop),
    .in1_endofpacket   (output_pkt_fifo_eop),
    .in1_empty         (output_pkt_fifo_empty),
    .in2_data          (nomatch_out_data),
    .in2_valid         (nomatch_out_valid),
    .in2_ready         (nomatch_out_ready),
    .in2_startofpacket (nomatch_out_sop),
    .in2_endofpacket   (nomatch_out_eop),
    .in2_empty         (nomatch_out_empty)
);

//////////////////// PKT BUFFER and It's Emptylist //////////////////////////////////
dc_fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(PKT_AWIDTH),
    .FIFO_DEPTH(PKT_NUM),
    .USE_PACKETS(0)
)
pktbuf_emptylist (
    .in_clk                 (clk_datamover),
    .in_reset_n             (!rst_datamover),
    .out_clk                (clk_datamover),
    .out_reset_n            (!rst_datamover),
    .in_data                (emptylist_in_data),
    .in_valid               (emptylist_in_valid),
    .in_ready               (emptylist_in_ready),
    .in_startofpacket       (1'b0),
    .in_endofpacket         (1'b0),
    .in_empty               (6'b0),
    .out_data               (emptylist_out_data),
    .out_valid              (emptylist_out_valid),
    .out_ready              (emptylist_out_ready),
    .out_startofpacket      (),
    .out_endofpacket        (),
    .out_empty              ()
);

//////////////////// PKT checker //////////////////////////////////
pkt_checker dm_checkpkt_checker(
    .clk                    (clk_datamover),
    .rst                    (rst_datamover),
    .in_sop                 (data_mover_check_pkt_sop),
    .in_eop                 (data_mover_check_pkt_eop),
    .in_valid               (data_mover_check_pkt_valid),
    .in_ready               (data_mover_check_pkt_ready),
    .error                  (data_mover_check_pkt_error)
);

endmodule
