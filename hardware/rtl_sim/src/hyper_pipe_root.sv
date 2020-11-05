`timescale 1 ps / 1 ps
`define USE_BRAM

module hyper_pipe_root (
    // Clk & rst
    input  logic                    clk,
    input  logic                    rst,
    input  logic                    clk_datamover,
    input  logic                    rst_datamover,
    input  logic                    clk_pcie,
    input  logic                    rst_pcie,

    // Ethernet In & out
    input  logic                    in_sop,
    input  logic                    in_eop,
    input  logic [511:0]            in_data,
    input  logic [5:0]              in_empty,
    input  logic                    in_valid,
    input  logic [511:0]            out_data,
    input  logic                    out_valid,
    input  logic                    out_sop,
    input  logic                    out_eop,
    input  logic [5:0]              out_empty,
    input  logic                    out_almost_full,

    // PCIE
    input  logic [513:0]            pcie_rb_wr_data,        // Width: flit_lite_t
    input  logic [11:0]             pcie_rb_wr_addr,        // Width: [PDU_AWIDTH-1:0]
    input  logic                    pcie_rb_wr_en,
    input  logic [11:0]             pcie_rb_wr_base_addr,   // Width: [PDU_AWIDTH-1:0]
    input  logic                    pcie_rb_almost_full,
    input  logic                    pcie_rb_update_valid,
    input  logic [11:0]             pcie_rb_update_size,    // Width: [PDU_AWIDTH-1:0]
    input  logic                    disable_pcie,
    input  logic [27:0]             pdumeta_cpu_data,       // Width: pdu_metadata_t
    input  logic                    pdumeta_cpu_valid,
    input  logic [9:0]              pdumeta_cnt,

    // DRAM
    input  logic [540:0]            ddr_wr_req_data,
    input  logic                    ddr_wr_req_valid,
    input  logic                    ddr_wr_req_almost_full,
    input  logic [28:0]             ddr_rd_req_data,
    input  logic                    ddr_rd_req_valid,
    input  logic                    ddr_rd_req_almost_full,
    input  logic [511:0]            ddr_rd_resp_data,
    input  logic                    ddr_rd_resp_valid,
    input  logic                    ddr_rd_resp_almost_full,

    // eSRAM
    input  logic                    esram_pkt_buf_wren,
 `ifdef USE_BRAM
    input  logic [14:0]             esram_pkt_buf_wraddress,
    input  logic [14:0]             esram_pkt_buf_rdaddress,
 `else
    input  logic [16:0]             esram_pkt_buf_wraddress,
    input  logic [16:0]             esram_pkt_buf_rdaddress,
 `endif
    input  logic [519:0]            esram_pkt_buf_wrdata,
    input  logic                    esram_pkt_buf_rden,
    input  logic                    esram_pkt_buf_rd_valid,
    input  logic [519:0]            esram_pkt_buf_rddata,

    output  logic                   reg_in_sop,
    output  logic                   reg_in_eop,
    output  logic [511:0]           reg_in_data,
    output  logic [5:0]             reg_in_empty,
    output  logic                   reg_in_valid,
    output  logic [511:0]           reg_out_data,
    output  logic                   reg_out_valid,
    output  logic                   reg_out_sop,
    output  logic                   reg_out_eop,
    output  logic [5:0]             reg_out_empty,
    output  logic                   reg_out_almost_full,
    output  logic [513:0]           reg_pcie_rb_wr_data,        // Width: flit_lite_t
    output  logic [11:0]            reg_pcie_rb_wr_addr,        // Width: [PDU_AWIDTH-1:0]
    output  logic                   reg_pcie_rb_wr_en,
    output  logic [11:0]            reg_pcie_rb_wr_base_addr,   // Width: [PDU_AWIDTH-1:0]
    output  logic                   reg_pcie_rb_almost_full,
    output  logic                   reg_pcie_rb_update_valid,
    output  logic [11:0]            reg_pcie_rb_update_size,    // Width: [PDU_AWIDTH-1:0]
    output  logic                   reg_disable_pcie,
    output  logic [27:0]            reg_pdumeta_cpu_data,       // Width: pdu_metadata_t
    output  logic                   reg_pdumeta_cpu_valid,
    output  logic [9:0]             reg_pdumeta_cnt,
    output  logic [540:0]           reg_ddr_wr_req_data,
    output  logic                   reg_ddr_wr_req_valid,
    output  logic                   reg_ddr_wr_req_almost_full,
    output  logic [28:0]            reg_ddr_rd_req_data,
    output  logic                   reg_ddr_rd_req_valid,
    output  logic                   reg_ddr_rd_req_almost_full,
    output  logic [511:0]           reg_ddr_rd_resp_data,
    output  logic                   reg_ddr_rd_resp_valid,
    output  logic                   reg_ddr_rd_resp_almost_full,
    output  logic                   reg_esram_pkt_buf_wren,
 `ifdef USE_BRAM
    output  logic [14:0]            reg_esram_pkt_buf_wraddress,
    output  logic [14:0]            reg_esram_pkt_buf_rdaddress,
 `else
    output  logic [16:0]            reg_esram_pkt_buf_wraddress,
    output  logic [16:0]            reg_esram_pkt_buf_rdaddress,
 `endif
    output  logic [519:0]           reg_esram_pkt_buf_wrdata,
    output  logic                   reg_esram_pkt_buf_rden,
    output  logic                   reg_esram_pkt_buf_rd_valid,
    output  logic [519:0]           reg_esram_pkt_buf_rddata
);

localparam NUM_PIPES = 1;
`ifdef USE_BRAM
localparam ESRAM_AWIDTH = 15;
`else
localparam ESRAM_AWIDTH = 17;
`endif

// Eth in
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_sop (
    .clk(clk_datamover),
    .din(in_sop),
    .dout(reg_in_sop)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_eop (
    .clk(clk_datamover),
    .din(in_eop),
    .dout(reg_in_eop)
);
hyper_pipe #(
    .WIDTH (512),
    .NUM_PIPES(NUM_PIPES)
) hp_in_data (
    .clk(clk_datamover),
    .din(in_data),
    .dout(reg_in_data)
);
hyper_pipe #(
    .WIDTH (6),
    .NUM_PIPES(NUM_PIPES)
) hp_in_empty (
    .clk(clk_datamover),
    .din(in_empty),
    .dout(reg_in_empty)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_in_valid (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din(in_valid),
    .dout(reg_in_valid)
);

// Eth out
hyper_pipe #(
    .WIDTH (512),
    .NUM_PIPES(NUM_PIPES)
) hp_out_data (
    .clk(clk),
    .din(out_data),
    .dout(reg_out_data)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_valid (
    .clk(clk),
    .rst(rst),
    .din(out_valid),
    .dout(reg_out_valid)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_sop (
    .clk(clk),
    .din(out_sop),
    .dout(reg_out_sop)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_eop (
    .clk(clk),
    .din(out_eop),
    .dout(reg_out_eop)
);
hyper_pipe #(
    .WIDTH (6),
    .NUM_PIPES(NUM_PIPES)
) hp_out_empty (
    .clk(clk),
    .din(out_empty),
    .dout(reg_out_empty)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_out_almost_full (
    .clk(clk),
    .rst(rst),
    .din(out_almost_full),
    .dout(reg_out_almost_full)
);

// PCIe
hyper_pipe #(
    .WIDTH (514),
    .NUM_PIPES(NUM_PIPES)
) hp_pcie_rb_wr_data (
    .clk(clk_pcie),
    .din(pcie_rb_wr_data),
    .dout(reg_pcie_rb_wr_data)
);
hyper_pipe #(
    .WIDTH (12),
    .NUM_PIPES(NUM_PIPES)
) hp_pcie_rb_wr_addr (
    .clk(clk_pcie),
    .din     (pcie_rb_wr_addr),
    .dout(reg_pcie_rb_wr_addr)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_pcie_rb_wr_en (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (pcie_rb_wr_en),
    .dout(reg_pcie_rb_wr_en)
);
hyper_pipe #(
    .WIDTH (12),
    .NUM_PIPES(0)
) hp_pcie_rb_wr_base_addr (
    .clk(clk_pcie),
    .din     (pcie_rb_wr_base_addr),
    .dout(reg_pcie_rb_wr_base_addr)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_pcie_rb_almost_full (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (pcie_rb_almost_full),
    .dout(reg_pcie_rb_almost_full)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(0)
) hp_pcie_rb_update_valid (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (pcie_rb_update_valid),
    .dout(reg_pcie_rb_update_valid)
);
hyper_pipe #(
    .WIDTH (12),
    .NUM_PIPES(0)
) hp_pcie_rb_update_size (
    .clk(clk_pcie),
    .din     (pcie_rb_update_size),
    .dout(reg_pcie_rb_update_size)
);
hyper_pipe #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_disable_pcie (
    .clk(clk_pcie),
    .din     (disable_pcie),
    .dout(reg_disable_pcie)
);
hyper_pipe #(
    .WIDTH (28),
    .NUM_PIPES(NUM_PIPES)
) hp_pdumeta_cpu_data (
    .clk(clk_pcie),
    .din     (pdumeta_cpu_data),
    .dout(reg_pdumeta_cpu_data)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_pdumeta_cpu_valid (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (pdumeta_cpu_valid),
    .dout(reg_pdumeta_cpu_valid)
);
hyper_pipe #(
    .WIDTH (10),
    .NUM_PIPES(NUM_PIPES)
) hp_pdumeta_cnt (
    .clk(clk_pcie),
    .din     (pdumeta_cnt),
    .dout(reg_pdumeta_cnt)
);

// DRAM
hyper_pipe #(
    .WIDTH (541),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_wr_req_data (
    .clk(clk_pcie),
    .din     (ddr_wr_req_data),
    .dout(reg_ddr_wr_req_data)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_wr_req_valid (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_wr_req_valid),
    .dout(reg_ddr_wr_req_valid)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_wr_req_almost_full (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_wr_req_almost_full),
    .dout(reg_ddr_wr_req_almost_full)
);
hyper_pipe #(
    .WIDTH (29),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_req_data (
    .clk(clk_pcie),
    .din     (ddr_rd_req_data),
    .dout(reg_ddr_rd_req_data)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_req_valid (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_rd_req_valid),
    .dout(reg_ddr_rd_req_valid)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_req_almost_full (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_rd_req_almost_full),
    .dout(reg_ddr_rd_req_almost_full)
);
hyper_pipe #(
    .WIDTH (512),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_resp_data (
    .clk(clk_pcie),
    .din     (ddr_rd_resp_data),
    .dout(reg_ddr_rd_resp_data)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_resp_valid (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_rd_resp_valid),
    .dout(reg_ddr_rd_resp_valid)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_ddr_rd_resp_almost_full (
    .clk(clk_pcie),
    .rst(rst_pcie),
    .din     (ddr_rd_resp_almost_full),
    .dout(reg_ddr_rd_resp_almost_full)
);

// eSRAM
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_wren (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din     (esram_pkt_buf_wren),
    .dout(reg_esram_pkt_buf_wren)
);
hyper_pipe #(
    .WIDTH (ESRAM_AWIDTH),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_wraddress (
    .clk(clk_datamover),
    .din     (esram_pkt_buf_wraddress),
    .dout(reg_esram_pkt_buf_wraddress)
);
hyper_pipe #(
    .WIDTH (520),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_wrdata (
    .clk(clk_datamover),
    .din     (esram_pkt_buf_wrdata),
    .dout(reg_esram_pkt_buf_wrdata)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_rden (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din     (esram_pkt_buf_rden),
    .dout(reg_esram_pkt_buf_rden)
);
hyper_pipe #(
    .WIDTH (ESRAM_AWIDTH),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_rdaddress (
    .clk(clk_datamover),
    .din     (esram_pkt_buf_rdaddress),
    .dout(reg_esram_pkt_buf_rdaddress)
);
hyper_pipe_rst #(
    .WIDTH (1),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_rd_valid (
    .clk(clk_datamover),
    .rst(rst_datamover),
    .din     (esram_pkt_buf_rd_valid),
    .dout(reg_esram_pkt_buf_rd_valid)
);
hyper_pipe #(
    .WIDTH (520),
    .NUM_PIPES(NUM_PIPES)
) hp_esram_pkt_buf_rddata (
    .clk(clk_datamover),
    .din     (esram_pkt_buf_rddata),
    .dout(reg_esram_pkt_buf_rddata)
);

endmodule
