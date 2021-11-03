// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



`timescale 1 ps / 1 ps
`define USE_BRAM
//`define DISABLE_PCIE
`define DISABLE_DRAM
`define BRAM_CHECKPKT_BUF

`include "./src/struct_s.sv"
module alt_ehipc2_hw (
 
    input clk50,
    input in_clk100,
`ifndef USE_BRAM
    input clk_esram_ref,
`endif

    input cpu_resetn,

    //port 0
    input  logic       i_clk_ref_0,
    input  logic [3:0] i_rx_serial_0,
    output logic [3:0] o_tx_serial_0,

`ifndef BRAM_CHECKPKT_BUF
    //DRAM
    input  logic        CLK_DDR4_COMP_P,      
    output logic        DDR4_COMP_CLK_P,      
    output logic        DDR4_COMP_CLK_N,      
    output logic [16:0] DDR4_COMP_A,          
    output logic        DDR4_COMP_ACT_N,      
    output logic [1:0]  DDR4_COMP_BA,         
    output logic        DDR4_COMP_BG0,        
    output logic        DDR4_COMP_BG1,        
    output logic        DDR4_COMP_CKE,        
    output logic        DDR4_COMP_CS_N,       
    output logic        DDR4_COMP_ODT,        
    output logic        DDR4_COMP_RESET_N,    
    output logic        DDR4_COMP_PAR,        
    input  logic        DDR4_COMP_ALERT_N,    
    inout  logic [8:0]  DDR4_COMP_DQS_P,      
    inout  logic [8:0]  DDR4_COMP_DQS_N,      
    inout  logic [71:0] DDR4_COMP_DQ,         
    inout  logic [8:0]  DDR4_COMP_DBI_N,      
    input  logic        DDR4_COMP_RZQ,
`endif

    //PCIe
    input  logic       refclk_clk,         
    input  logic       pcie_rstn_pin_perst,
    input  logic       xcvr_rx_in0,        
    input  logic       xcvr_rx_in1,        
    input  logic       xcvr_rx_in2,        
    input  logic       xcvr_rx_in3,        
    input  logic       xcvr_rx_in4,        
    input  logic       xcvr_rx_in5,        
    input  logic       xcvr_rx_in6,        
    input  logic       xcvr_rx_in7,        
    input  logic       xcvr_rx_in8,        
    input  logic       xcvr_rx_in9,        
    input  logic       xcvr_rx_in10,       
    input  logic       xcvr_rx_in11,       
    input  logic       xcvr_rx_in12,       
    input  logic       xcvr_rx_in13,       
    input  logic       xcvr_rx_in14,       
    input  logic       xcvr_rx_in15,       
    output logic       xcvr_tx_out0,       
    output logic       xcvr_tx_out1,       
    output logic       xcvr_tx_out2,       
    output logic       xcvr_tx_out3,       
    output logic       xcvr_tx_out4,       
    output logic       xcvr_tx_out5,       
    output logic       xcvr_tx_out6,       
    output logic       xcvr_tx_out7,       
    output logic       xcvr_tx_out8,       
    output logic       xcvr_tx_out9,       
    output logic       xcvr_tx_out10,      
    output logic       xcvr_tx_out11,      
    output logic       xcvr_tx_out12,      
    output logic       xcvr_tx_out13,      
    output logic       xcvr_tx_out14,      
    output logic       xcvr_tx_out15      

);

    /////////////////////////
    // signals
    /////////////////////////
    //clk, rst
    logic         user_mode_sync;
    logic         arst;
    logic         iopll_locked;
    logic         clk100;
    logic         ninit_done;
    logic         clk_status;

    logic         arst_r1;
    logic         arst_r2;
    logic         user_rst;
    logic         arst_fast_r1;
    logic         arst_fast_r2;
    logic         user_rst_fast;
 
    //Jtag signals
    logic [31:0]  av_addr;
    logic [3:0]   byteenable;
    logic [19:0]  status_addr;
    logic         status_read;
    logic         status_write;
    logic [31:0]  status_writedata;
    logic [31:0]  status_writedata;
    logic [31:0]  status_readdata;
    logic         status_readdata_valid;
    logic         status_waitrequest;

    logic         status_read_r;
    logic         status_write_r;
    logic [31:0]  status_writedata_r;
    logic [19:0]  status_addr_r;

    //port 0 jtag 
    logic         select_waitrequest; 
    logic [15:0]  eth_0_addr;
    logic [31:0]  eth_0_readdata;
    logic         eth_0_read;
    logic         eth_0_write;
    logic         eth_0_readdata_valid;
    logic         eth_0_waitrequest;
    logic [31:0]  eth_0_writedata;
    logic [127:0] xcvr_0_writedata;
    logic [3:0]   xcvr_0_readdata_valid;
    logic [3:0]   xcvr_0_cs;
    logic [3:0]   xcvr_0_read;
    logic [3:0]   xcvr_0_write;
    logic [43:0]  xcvr_0_address;
    logic [3:0]   xcvr_0_waitrequest;
    logic [127:0] xcvr_0_readdata;


    //port 1 jtag 
    logic         select_waitrequest1; 
    logic [15:0]  eth_1_addr;
    logic [31:0]  eth_1_readdata;
    logic         eth_1_read;
    logic         eth_1_write;
    logic         eth_1_readdata_valid;
    logic         eth_1_waitrequest;
    logic [31:0]  eth_1_writedata;
    logic [127:0] xcvr_1_writedata;
    logic [3:0]   xcvr_1_readdata_valid;
    logic [3:0]   xcvr_1_cs;
    logic [3:0]   xcvr_1_read;
    logic [3:0]   xcvr_1_write;
    logic [43:0]  xcvr_1_address;
    logic [3:0]   xcvr_1_waitrequest;
    logic [127:0] xcvr_1_readdata;

    //User jtag
    logic [29:0]  s_addr;
    logic         s_read;
    logic         s_write;
    logic [31:0]  s_writedata;
    logic [31:0]  s_0_readdata;
    logic [31:0]  s_1_readdata;
    logic         s_0_readdata_valid;
    logic         s_1_readdata_valid;
    logic         custom;
    logic         select_eth_0;
    logic         select_eth_1;

    //port 0 data signals
    logic         tx_serial_clk_01_0;
    logic         tx_serial_clk_23_0;
    logic [1:0]   tx_serial_clk_0;
    logic         tx_pll_locked_01_0;
    logic         tx_pll_locked_23_0;
    logic [1:0]   tx_pll_locked_0;
    logic         atx12_cascade_0;
    logic         o_clk_pll_div64_0;
    logic         clk_tx_0;  
    logic         clk_rx_0;  
    logic [511:0] tx_0_data;
    logic   [5:0] tx_0_empty;
    logic         tx_0_endofpacket;
    logic         tx_0_ready;
    logic         tx_0_startofpacket;
    logic         tx_0_valid;
    logic [511:0] rx_0_data;
    logic   [5:0] rx_0_empty;
    logic         rx_0_endofpacket;
    logic         rx_0_startofpacket;
    logic         rx_0_valid;
    logic   [5:0] rx_0_error;
    logic   [7:0] rx_0_pfc;
    logic         i_stats_snapshot_0;
    logic  [39:0] o_rxstatus_data_0;
    logic         o_rxstatus_valid_0;
    logic         o_cdr_lock_0;

    //port 1 data signals
    logic         tx_serial_clk_01_1;
    logic         tx_serial_clk_23_1;
    logic [1:0]   tx_serial_clk_1;
    logic         tx_pll_locked_01_1;
    logic         tx_pll_locked_23_1;
    logic [1:0]   tx_pll_locked_1;
    logic         atx12_cascade_1;
    logic         o_clk_pll_div64_1;
    logic         clk_tx_1;  
    logic         clk_rx_1;  
    logic [511:0] tx_1_data;
    logic   [5:0] tx_1_empty;
    logic         tx_1_endofpacket;
    logic         tx_1_ready;
    logic         tx_1_startofpacket;
    logic         tx_1_valid;
    logic [511:0] rx_1_data;
    logic   [5:0] rx_1_empty;
    logic         rx_1_endofpacket;
    logic         rx_1_startofpacket;
    logic         rx_1_valid;
    logic   [5:0] rx_1_error;
    logic   [7:0] rx_1_pfc;

    logic         i_stats_snapshot_1;
    logic  [39:0] o_rxstatus_data_1;
    logic         o_rxstatus_valid_1;
    logic         o_cdr_lock_0;


    //My stats signals
    logic [511:0] stats_0_rx_data;
    logic   [5:0] stats_0_rx_empty;
    logic         stats_0_rx_endofpacket;
    logic         stats_0_rx_startofpacket;
    logic         stats_0_rx_valid;
    logic         stats_0_rx_ready;
    logic [511:0] stats_1_rx_data;
    logic   [5:0] stats_1_rx_empty;
    logic         stats_1_rx_endofpacket;
    logic         stats_1_rx_startofpacket;
    logic         stats_1_rx_valid;
    logic         stats_1_rx_ready;


    //user logic signals
    logic            user_clk;
    logic            user_pll_locked;
    logic            user_clk_fast; 
    logic            user_pll_fast_locked;
    logic    [511:0] user_in_data;
    logic      [5:0] user_in_empty;
    logic            user_in_endofpacket;
    logic            user_in_startofpacket;
    logic            user_in_valid;
    logic            user_in_ready;
    logic    [511:0] user_out_data;
    logic      [5:0] user_out_empty;
    logic            user_out_endofpacket;
    logic            user_out_startofpacket;
    logic            user_out_valid;
    logic            user_out_ready;
    logic            user_out_almost_full;
    logic            user_out_valid_int;
    logic            user_out_fifo_valid_int;
    logic    [511:0] user_out_fifo_data;
    logic      [5:0] user_out_fifo_empty;
    logic            user_out_fifo_endofpacket;
    logic            user_out_fifo_startofpacket;
    logic            user_out_fifo_valid;
    logic            user_out_fifo_ready;
    logic            user_out_fifo_almost_full;
    logic    [511:0] partition_out_data;
    logic      [5:0] partition_out_empty;
    logic            partition_out_endofpacket;
    logic            partition_out_startofpacket;
    logic            partition_out_valid;
    logic            partition_out_ready;
    logic            partition_out_almost_full;
    logic            partition_out_valid_int;

    logic    [511:0] fc_0_in_data;
    logic      [5:0] fc_0_in_empty;
    logic            fc_0_in_endofpacket;
    logic            fc_0_in_startofpacket;
    logic            fc_0_in_valid;
    logic            fc_0_in_ready;
    logic    [511:0] fc_0_out_data;
    logic      [5:0] fc_0_out_empty;
    logic            fc_0_out_endofpacket;
    logic            fc_0_out_startofpacket;
    logic            fc_0_out_valid;
    logic            fc_0_out_ready;
    logic    [511:0] fc_0_out_fifo_data;
    logic      [5:0] fc_0_out_fifo_empty;
    logic            fc_0_out_fifo_endofpacket;
    logic            fc_0_out_fifo_startofpacket;
    logic            fc_0_out_fifo_valid;
    logic            fc_0_out_fifo_ready;
    logic            fc_0_out_fifo_almost_full;
    logic            fc_0_out_fifo_valid_int;

    logic    [511:0] fc_1_in_data;
    logic      [5:0] fc_1_in_empty;
    logic            fc_1_in_endofpacket;
    logic            fc_1_in_startofpacket;
    logic            fc_1_in_valid;
    logic            fc_1_in_ready;
    logic    [511:0] fc_1_out_data;
    logic      [5:0] fc_1_out_empty;
    logic            fc_1_out_endofpacket;
    logic            fc_1_out_startofpacket;
    logic            fc_1_out_valid;
    logic            fc_1_out_ready;
    logic    [511:0] fc_1_out_fifo_data;
    logic      [5:0] fc_1_out_fifo_empty;
    logic            fc_1_out_fifo_endofpacket;
    logic            fc_1_out_fifo_startofpacket;
    logic            fc_1_out_fifo_valid;
    logic            fc_1_out_fifo_ready;
    logic            fc_1_out_fifo_almost_full;
    logic            fc_1_out_fifo_valid_int;

    logic    [511:0] return_data;
    logic      [5:0] return_empty;
    logic            return_endofpacket;
    logic            return_startofpacket;
    logic            return_valid;
    logic            return_ready;
    logic            return_almost_full;
    logic            return_valid_int;

    logic            user_readdata_valid;
    logic [31:0]     user_readdata;
    logic            fc_0_readdata_valid;
    logic [31:0]     fc_0_readdata;
    logic            fc_1_readdata_valid;
    logic [31:0]     fc_1_readdata;

    //eSRAM signals
    logic            clk_datamover;
    logic            rst_datamover;
    logic            pkt_buf_wren;
`ifdef USE_BRAM
    logic [14:0]     pkt_buf_rdaddress;
    logic [14:0]     pkt_buf_wraddress;
`else
    logic [16:0]     pkt_buf_rdaddress;
    logic [16:0]     pkt_buf_wraddress;
`endif
    logic [519:0]    pkt_buf_wrdata;
    logic            pkt_buf_rden;
    logic            pkt_buf_rd_valid;
    logic [519:0]    pkt_buf_rddata;

    //PCIe signal
    logic            pcie_clk;
    logic            pcie_reset_n;
    logic            pcie_reset_n_r1;
    logic            pcie_reset_n_r2;
    logic [513:0]    pcie_rb_wr_data;
    logic [11:0]     pcie_rb_wr_addr;          
    logic            pcie_rb_wr_en;  
    logic [11:0]     pcie_rb_wr_base_addr;          
    logic            pcie_rb_almost_full;          
    logic            pcie_rb_update_valid;
    logic [11:0]     pcie_rb_update_size;
    logic            disable_pcie;
    logic [27:0]     pdumeta_cpu_data;
    logic            pdumeta_cpu_valid;
    logic [9:0]      pdumeta_cnt;


    logic [29:0]     pcie_status_addr;
    logic            pcie_status_read;
    logic            pcie_status_write;
    logic [31:0]     pcie_status_writedata;
    logic [31:0]     pcie_status_readdata;
    logic            pcie_status_readdata_valid;
    logic            pcie_rstn_npor;

    //DRAM signals
    logic [540:0]    ddr_wr_req_data;
    logic            ddr_wr_req_valid;
    logic            ddr_wr_req_ready;
    logic            ddr_wr_req_almost_full;
    logic [28:0]     ddr_rd_req_data;
    logic            ddr_rd_req_valid;
    logic            ddr_rd_req_ready;
    logic            ddr_rd_req_almost_full;
    logic [511:0]    ddr_rd_resp_data;
    logic            ddr_rd_resp_valid;
    logic            ddr_rd_resp_almost_full;
    logic            ddr_rd_resp_valid_int;
    logic [31:0]     dram_readdata;
    logic            dram_readdata_valid;


    /////////////////////////
    // logic
    /////////////////////////
    assign clk_status = clk100;
    // ARST conditional upon ninit_done from S10 IP reset. Ninit_done is active low. ninit_done=0 => s10 is good to go	  
    assign arst = ~user_mode_sync | ~cpu_resetn | ~iopll_locked | ninit_done | ~user_pll_locked;

    //eht 0 clk & pll
    assign clk_tx_0 = o_clk_pll_div64_0;  
    assign clk_rx_0 = o_clk_pll_div64_0;  
    assign tx_serial_clk_0 = {tx_serial_clk_23_0,tx_serial_clk_01_0};
    assign tx_pll_locked_0[0] = tx_pll_locked_23_0;
    assign tx_pll_locked_0[1] = tx_pll_locked_23_0; 
    assign i_stats_snapshot_0 = 1'b0;

    //eht 1 clk & pll
    assign clk_tx_1 = o_clk_pll_div64_1;  
    assign clk_rx_1 = o_clk_pll_div64_1;  
    assign tx_serial_clk_1 = {tx_serial_clk_23_1,tx_serial_clk_01_1};
    assign tx_pll_locked_1[0] = tx_pll_locked_23_1;
    assign tx_pll_locked_1[1] = tx_pll_locked_23_1; 
    assign i_stats_snapshot_1 = 1'b0;

    /////////////////////////
    // Jtag memory space slicing
    /////////////////////////
    //stop assigning when the responder is busy
    assign status_addr = av_addr[21:2];
    always @(posedge clk_status) begin
        if (arst) begin
            status_read_r <= 0;
            status_write_r <= 0;
            status_writedata_r <= 32'b0;
            status_addr_r <= 20'b0;//20 bit now
        end
        else if( !select_waitrequest || !select_waitrequest1 || status_read || status_write ) begin
            status_read_r      <= status_read;
            status_write_r     <= status_write;
            status_writedata_r <= status_writedata;
            status_addr_r      <= status_addr;
        end
    end
     
    //Eth Port 0
    assign select_waitrequest = !select_eth_0 ? 1'b1 : 
                                ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) ? xcvr_0_waitrequest[0] :
                                ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) ? xcvr_0_waitrequest[1] :
                                ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) ? xcvr_0_waitrequest[2] :
                                ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) ? xcvr_0_waitrequest[3] :
                                ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) ? eth_0_waitrequest :
                                1'b0;
       
    //Reconfig Decoding XCVR 0      
    assign xcvr_0_cs[0]             = ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) && select_eth_0;
    assign xcvr_0_read[0]           = status_read_r && xcvr_0_cs[0];
    assign xcvr_0_write[0]          = status_write_r && xcvr_0_cs[0];
    assign xcvr_0_address[10:0]     = (xcvr_0_read[0] || xcvr_0_write[0]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[0] = xcvr_0_read[0] && !xcvr_0_waitrequest[0];
    //Reconfig Decoding XCVR 1      
    assign xcvr_0_cs[1]             = ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) && select_eth_0;
    assign xcvr_0_read[1]           = status_read_r && xcvr_0_cs[1];
    assign xcvr_0_write[1]          = status_write_r && xcvr_0_cs[1];
    assign xcvr_0_address[21:11]    = (xcvr_0_read[1] || xcvr_0_write[1]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[1] = xcvr_0_read[1]  && !xcvr_0_waitrequest[1];
    //Reconfig Decoding XCVR 2     
    assign xcvr_0_cs[2]             = ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) && select_eth_0;
    assign xcvr_0_read[2]           = status_read_r && xcvr_0_cs[2];
    assign xcvr_0_write[2]          = status_write_r && xcvr_0_cs[2];
    assign xcvr_0_address[32:22]    = (xcvr_0_read[2] || xcvr_0_write[2]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[2] = xcvr_0_read[2]  && !xcvr_0_waitrequest[2];
    //Reconfig Decoding XCVR 3     
    assign xcvr_0_cs[3]             = ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) && select_eth_0;
    assign xcvr_0_read[3]           = status_read_r && xcvr_0_cs[3];
    assign xcvr_0_write[3]          = status_write_r && xcvr_0_cs[3];
    assign xcvr_0_address[43:33]    = (xcvr_0_read[3] ||xcvr_0_write[3]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[3] = xcvr_0_read[3] && !xcvr_0_waitrequest[3];

    //Reconfig Decoding Eth       
    assign eth_0_cs                 = ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) && select_eth_0;
    assign eth_0_read               = status_read_r && eth_0_cs;
    assign eth_0_write              = status_write_r && eth_0_cs;
    assign eth_0_addr               = (eth_0_read|| eth_0_write) ? status_addr_r[15:0] : 16'b0; 
    assign eth_0_writedata          = status_writedata_r;
    assign xcvr_0_writedata         = {4{status_writedata_r}};

    //assign my_stats
    assign s_addr = av_addr[31:2];
    assign s_read = status_read;
    assign s_write = status_write;
    assign s_writedata = status_writedata;
    assign custom = av_addr[31];
    assign select_eth_0 = av_addr[31:32-STAT_AWIDTH] == ETH_0_REG;
    assign select_eth_1 = av_addr[31:32-STAT_AWIDTH] == ETH_1_REG;

    always@(posedge user_clk)begin
        arst_r1 <= arst;       
        arst_r2 <= arst_r1;
        user_rst <= arst_r2;
    end
    always@(posedge user_clk_fast)begin
        arst_fast_r1 <= arst;       
        arst_fast_r2 <= arst_fast_r1;
        user_rst_fast <= arst_fast_r2;
    end
    always@(posedge pcie_clk)begin
        pcie_reset_n_r1 <= pcie_reset_n;
        pcie_reset_n_r2 <= pcie_reset_n_r1;
    end


    /////////////////////////
    // dev_clr sync-reset
    /////////////////////////

    alt_aeuex_user_mode_det dev_clr( .ref_clk(clk100), .user_mode_sync(user_mode_sync));

    //Instantiate S10 IP reset:
    reset_ip reset (
        .ninit_done (ninit_done)
    );

    /////////////////////////
    // status clk PLL
    /////////////////////////
    alt_ehipc2_sys_pll u0 (
        .rst        (~cpu_resetn),  // reset.reset
        .refclk     (clk50),        // refclk.clk
        .locked     (iopll_locked), // locked.export
        .outclk_0   (clk100)        // outclk0.clk
    );

    /////////////////////////
    // JTAG
    /////////////////////////
    alt_ehipc2_jtag_avalon jtag_master (
        .clk_clk                (clk_status),
        .clk_reset_reset        (arst),
        .master_address         (av_addr),
        .master_readdata        (status_readdata),
        .master_read            (status_read),
        .master_write           (status_write),
        .master_writedata       (status_writedata),
        .master_waitrequest     (status_waitrequest),
        .master_readdatavalid   (status_readdata_valid),
        .master_byteenable      (byteenable),
        .master_reset_reset     ()
    );

    /////////////////////////
    // Arbiter for multiple JTAG client
    /////////////////////////
    alt_aeuex_avalon_mm_read_combine #(
        .NUM_CLIENTS            (7),
        .TIMEOUT                (11)
    ) arc (
        .clk                    (clk_status),
        .arst                   (arst),
        .host_read              (status_read),
        .host_readdata          (status_readdata),
        .host_readdata_valid    (status_readdata_valid),
        .host_waitrequest       (status_waitrequest),
        .client_readdata_valid  ({eth_0_readdata_valid, 
                                  s_0_readdata_valid, 
                                  user_readdata_valid,
                                  fc_0_readdata_valid,
                                  fc_1_readdata_valid,
                                  pcie_status_readdata_valid,
                                  dram_readdata_valid}),
        .client_readdata        ({eth_0_readdata, 
                                  s_0_readdata, 
                                  user_readdata,
                                  fc_0_readdata,
                                  fc_1_readdata,
                                  pcie_status_readdata,
                                  dram_readdata})
    );

    /////////////////////////
    // Port 0 ATX PLL, lane0 and lane1
    /////////////////////////
    atx_pll_e50g_master atx_m_0 (
        .pll_refclk0        (i_clk_ref_0),
        .tx_serial_clk_gxt  (tx_serial_clk_23_0),
        .gxt_output_to_blw_atx (atx12_cascade_0),  
        .pll_locked         (tx_pll_locked_23_0),
        .pll_cal_busy       ()
    );

    /////////////////////////
    // Port 0 ATX PLL, lane2 and lane3, cascade with previous PLL
    /////////////////////////
    atx_pll_e50g_slave atx_s_0  (
        .gxt_input_from_abv_atx(atx12_cascade_0),  
        .pll_refclk0        (i_clk_ref_0),
        .tx_serial_clk_gxt  (tx_serial_clk_01_0),
        .pll_locked         (tx_pll_locked_01_0),
        .pll_cal_busy       ()
    );


    /////////////////////////
    // Port 0 Ethernet Core, hard IP
    /////////////////////////
    ex_100G av_top_0 (
           .i_stats_snapshot                  (i_stats_snapshot_0),
           .o_cdr_lock                        (o_cdr_lock_0),
           .i_eth_reconfig_addr               (eth_0_addr),
           .i_eth_reconfig_read               (eth_0_read),
           .i_eth_reconfig_write              (eth_0_write),
           .o_eth_reconfig_readdata           (eth_0_readdata),
           .o_eth_reconfig_readdata_valid     (eth_0_readdata_valid),
           .i_eth_reconfig_writedata          (eth_0_writedata),
           .o_eth_reconfig_waitrequest        (eth_0_waitrequest),
           .o_tx_lanes_stable                 (o_tx_lanes_stable_0),
           .o_rx_pcs_ready                    (rx_0_pcs_ready),
           .o_ehip_ready                      (o_ehip_ready_0),
           .o_rx_block_lock                   (rx_0_block_lock),
           .o_rx_am_lock                      (rx_0_am_lock),
           .o_rx_hi_ber                       (rx_0_hi_ber),
           .o_local_fault_status              (o_local_fault_status_0),
           .o_remote_fault_status             (o_remote_fault_status_0),
           .i_clk_ref                         (i_clk_ref_0),
           .i_clk_tx                          (clk_tx_0),
           .i_clk_rx                          (clk_rx_0),
           .o_clk_pll_div64                   (o_clk_pll_div64_0),
           .o_clk_pll_div66                   (o_clk_pll_div66_0),
           .o_clk_rec_div64                   (o_clk_rec_div64_0),
           .o_clk_rec_div66                   (o_clk_rec_div66_0),
           .i_csr_rst_n                       (~arst),
           .i_tx_rst_n                        (1'b1),
           .i_rx_rst_n                        (1'b1),
           .o_tx_serial                       (o_tx_serial_0),
           .i_rx_serial                       (i_rx_serial_0),
           .i_reconfig_clk                    (clk_status),
           .i_reconfig_reset                  (arst),
           .i_xcvr_reconfig_address           (xcvr_0_address),
           .i_xcvr_reconfig_read              (xcvr_0_read),
           .i_xcvr_reconfig_write             (xcvr_0_write),
           .o_xcvr_reconfig_readdata          (xcvr_0_readdata),
           .i_xcvr_reconfig_writedata         (xcvr_0_writedata),
           .o_xcvr_reconfig_waitrequest       (xcvr_0_waitrequest),
           .o_tx_ready                        (tx_0_ready),
           .o_rx_valid                        (rx_0_valid),
           .i_tx_valid                        (tx_0_valid),
           .i_tx_data                         (tx_0_data),
           .o_rx_data                         (rx_0_data),
           .i_tx_error                        (1'b0),
           .i_tx_startofpacket                (tx_0_startofpacket),
           .i_tx_endofpacket                  (tx_0_endofpacket),
           .i_tx_empty                        (tx_0_empty),
           .i_tx_skip_crc                     (1'b0),
           .o_rx_startofpacket                (rx_0_startofpacket),
           .o_rx_endofpacket                  (rx_0_endofpacket),
           .o_rx_empty                        (rx_0_empty),
           .o_rx_error                        (rx_0_error),
           .o_rxstatus_data                   (o_rxstatus_data_0),
           .o_rxstatus_valid                  (o_rxstatus_valid_0),
           .i_tx_pfc                          (8'b0),
           .o_rx_pfc                          (rx_0_pfc),
           .i_tx_pause                        (1'b0),
           .o_rx_pause                        (rx_0_pause),
           .i_tx_serial_clk                   (tx_serial_clk_0),
           .i_tx_pll_locked                   (tx_pll_locked_0)
    );


/////////// User modules /////////////////
    /////////////////////////
    // User clck, user_clk is 200 MHz, user_clk_fast is 400MHz
    /////////////////////////
    user_pll user_pll_inst (
        .rst      (~cpu_resetn),      //   input,  width = 1,   reset.reset
        .refclk   (in_clk100),   //   input,  width = 1,  refclk.clk
        .locked   (user_pll_locked),   //  output,  width = 1,  locked.export
        .outclk_0 (user_clk),  //  output,  width = 1, outclk0.clk
        .outclk_1 (user_clk_fast)  //  output,  width = 1, outclk0.clk
    );

    /////////////////////////
    // Port 0 stats
    /////////////////////////
    stats stats_0(
        .arst(arst),
    
        .clk_tx  (clk_tx_0),
        .tx_ready(tx_0_ready),
        .tx_valid(tx_0_valid),
        .tx_data (tx_0_data),
        .tx_sop  (tx_0_startofpacket),
        .tx_eop  (tx_0_endofpacket),
        .tx_empty(tx_0_empty),
    
        .clk_rx  (clk_rx_0),
        .rx_sop  (rx_0_startofpacket),
        .rx_eop  (rx_0_endofpacket),
        .rx_empty(rx_0_empty),
        .rx_data (rx_0_data),
        .rx_valid(rx_0_valid),

        .o_rx_sop  (stats_0_rx_startofpacket),
        .o_rx_eop  (stats_0_rx_endofpacket),
        .o_rx_empty(stats_0_rx_empty),
        .o_rx_data (stats_0_rx_data),
        .o_rx_valid(stats_0_rx_valid),

        .clk_status           (clk_status),
        .status_addr          (s_addr),
        .status_read          (s_read),
        .status_write         (s_write),
        .status_writedata     (s_writedata),
        .status_readdata      (s_0_readdata),
        .status_readdata_valid(s_0_readdata_valid)
    );

    //Port 0 RX
    dc_fifo_wrapper port0_input_fifo (
        .in_clk            (clk_rx_0),    
        .in_reset_n        (!arst),      
        .out_clk           (user_clk),    
        .out_reset_n       (!arst),      
        .in_data           (stats_0_rx_data),           
        .in_valid          (stats_0_rx_valid),          
        .in_ready          (stats_0_rx_ready),           
        .in_startofpacket  (stats_0_rx_startofpacket),  
        .in_endofpacket    (stats_0_rx_endofpacket),
        .in_empty          (stats_0_rx_empty), 
        .out_data          (user_in_data),          
        .out_valid         (user_in_valid),         
        //.out_ready         (user_in_ready),         
        .out_ready         (1'b1),         
        .out_startofpacket (user_in_startofpacket), 
        .out_endofpacket   (user_in_endofpacket),   
        .out_empty         (user_in_empty)          
    );


    top top_inst (
        //clk & rst
        .clk                          (user_clk),            
        .rst                          (user_rst),       
        .clk_high                     (user_clk_fast),            
        .rst_high                     (user_rst_fast),
        .clk_pcie                     (pcie_clk),            
        .rst_pcie                     (!pcie_reset_n_r2),       
        //Ethernet in & out data      
        .in_data                      (user_in_data),           
        .in_valid                     (user_in_valid),          
        .in_sop                       (user_in_startofpacket),  
        .in_eop                       (user_in_endofpacket),
        .in_empty                     (user_in_empty),  
        //.in_ready                     (user_in_ready),
        .out_data                     (user_out_data),          
        .out_valid                    (user_out_valid),         
        .out_sop                      (user_out_startofpacket), 
        .out_eop                      (user_out_endofpacket),   
        .out_empty                    (user_out_empty), 
        .out_ready                    (user_out_ready),
        //eSRAM/BRAM
        .pkt_buf_wren                 (pkt_buf_wren),
        .pkt_buf_wraddress            (pkt_buf_wraddress),
        .pkt_buf_wrdata               (pkt_buf_wrdata),
        .pkt_buf_rden                 (pkt_buf_rden),
        .pkt_buf_rdaddress            (pkt_buf_rdaddress),
        .pkt_buf_rd_valid             (pkt_buf_rd_valid),
        .pkt_buf_rddata               (pkt_buf_rddata),
        //PCIe    
        .pcie_rb_wr_data              (pcie_rb_wr_data),           
        .pcie_rb_wr_addr              (pcie_rb_wr_addr),          
        .pcie_rb_wr_en                (pcie_rb_wr_en),  
        .pcie_rb_wr_base_addr         (pcie_rb_wr_base_addr),  
        .pcie_rb_almost_full          (pcie_rb_almost_full),          
        .pcie_rb_update_valid         (pcie_rb_update_valid),
        .pcie_rb_update_size          (pcie_rb_update_size),
        .disable_pcie                 (disable_pcie),
        .pdumeta_cpu_data             (pdumeta_cpu_data),
        .pdumeta_cpu_valid            (pdumeta_cpu_valid),
        .pdumeta_cnt                  (pdumeta_cnt),
        //DRAM
        .ddr_wr_req_data              (ddr_wr_req_data),
        .ddr_wr_req_valid             (ddr_wr_req_valid),
        .ddr_wr_req_almost_full       (ddr_wr_req_almost_full),
        .ddr_rd_req_data              (ddr_rd_req_data),
        .ddr_rd_req_valid             (ddr_rd_req_valid),
        .ddr_rd_req_almost_full       (ddr_rd_req_almost_full),
        .ddr_rd_resp_data             (ddr_rd_resp_data),
        .ddr_rd_resp_valid            (ddr_rd_resp_valid),
        .ddr_rd_resp_almost_full      (ddr_rd_resp_almost_full),
        //JTAG
        .clk_status                   (clk_status),
        .status_addr                  (s_addr),
        .status_read                  (s_read),
        .status_write                 (s_write),
        .status_writedata             (s_writedata),
        .status_readdata              (user_readdata),
        .status_readdata_valid        (user_readdata_valid)
    );

    //Port 0 TX
    dc_fifo_wrapper_infill port0_output_fifo (
        .in_clk            (user_clk),    
        .in_reset_n        (!arst),      
        .out_clk           (user_clk),    
        .out_reset_n       (!arst),      
        .in_csr_address    (0),
        .in_csr_read       (1),
        .in_csr_write      (0),
        .in_csr_readdata   (),
        .in_csr_writedata  (0),
        .in_data           (user_out_data),           
        .in_valid          (user_out_valid),          
        .in_ready          (user_out_ready), 
        .in_startofpacket  (user_out_startofpacket),  
        .in_endofpacket    (user_out_endofpacket),
        .in_empty          (user_out_empty), 
        .out_data          (fc_0_out_fifo_data),          
        .out_valid         (fc_0_out_fifo_valid),         
        .out_ready         (fc_0_out_fifo_ready),         
        .out_startofpacket (fc_0_out_fifo_startofpacket), 
        .out_endofpacket   (fc_0_out_fifo_endofpacket),   
        .out_empty         (fc_0_out_fifo_empty)          
    );


    pc_loopback port0_pc_loopback (
        .arst               (arst),
        .clk_rx             (user_clk),
        .clk_tx             (clk_tx_0),
        .rx_valid           (fc_0_out_fifo_valid),
        .rx_sop             (fc_0_out_fifo_startofpacket),
        .rx_eop             (fc_0_out_fifo_endofpacket),
        .rx_empty           (fc_0_out_fifo_empty),
        .rx_data            (fc_0_out_fifo_data),
        .rx_ready           (fc_0_out_fifo_ready),
        .tx_valid           (tx_0_valid),
        .tx_sop             (tx_0_startofpacket),
        .tx_eop             (tx_0_endofpacket),
        .tx_empty           (tx_0_empty),
        .tx_data            (tx_0_data),
        .tx_ready           (tx_0_ready)
    );

`ifdef USE_BRAM
    //assign clk_datamover = user_clk;
     esram_wrapper esram_pkt_buffer(
    .clk_esram_ref  (1'b0), //100 MHz
    .esram_pll_lock (esram_pll_lock), 
    .clk_esram      (user_clk), //200 MHz
    .wren           (pkt_buf_wren),
    .wraddress      (pkt_buf_wraddress),
    .wrdata         (pkt_buf_wrdata),
    .rden           (pkt_buf_rden),
    .rdaddress      (pkt_buf_rdaddress),
    .rd_valid       (pkt_buf_rd_valid),
    .rddata         (pkt_buf_rddata)
);
`else
esram_wrapper esram_pkt_buffer(
    .clk_esram_ref  (clk_esram_ref), //100 MHz
    .esram_pll_lock (esram_pll_lock), 
    .clk_esram      (clk_datamover), //200 MHz
    .wren           (pkt_buf_wren),
    .wraddress      (pkt_buf_wraddress),
    .wrdata         (pkt_buf_wrdata),
    .rden           (pkt_buf_rden),
    .rdaddress      (pkt_buf_rdaddress),
    .rd_valid       (pkt_buf_rd_valid),
    .rddata         (pkt_buf_rddata)
);
`endif

`ifdef DISABLE_PCIE    
    assign disable_pcie = 1'b1;
    assign pcie_rb_almost_full = 1'b0;
    assign pcie_rb_wr_base_addr = 0;
    assign pdumeta_cpu_valid = 1'b0;
    assign pcie_clk = user_clk;
    assign pcie_reset_n = !arst;
    assign pcie_status_readdata_valid = 0;
`else
    pcie_top pcie (
        .refclk_clk             (refclk_clk),                              //         refclk.clk
        .pcie_rstn_npor         (cpu_resetn),                          //      pcie_rstn.npor
        .pcie_rstn_pin_perst    (pcie_rstn_pin_perst),                     //               .pin_perst
        .xcvr_rx_in0            (xcvr_rx_in0),                             //           xcvr.rx_in0
        .xcvr_rx_in1            (xcvr_rx_in1),                             //               .rx_in1
        .xcvr_rx_in2            (xcvr_rx_in2),                             //               .rx_in2
        .xcvr_rx_in3            (xcvr_rx_in3),                             //               .rx_in3
        .xcvr_rx_in4            (xcvr_rx_in4),                             //               .rx_in4
        .xcvr_rx_in5            (xcvr_rx_in5),                             //               .rx_in5
        .xcvr_rx_in6            (xcvr_rx_in6),                             //               .rx_in6
        .xcvr_rx_in7            (xcvr_rx_in7),                             //               .rx_in7
        .xcvr_rx_in8            (xcvr_rx_in8),                             //               .rx_in8
        .xcvr_rx_in9            (xcvr_rx_in9),                             //               .rx_in9
        .xcvr_rx_in10           (xcvr_rx_in10),                            //               .rx_in10
        .xcvr_rx_in11           (xcvr_rx_in11),                            //               .rx_in11
        .xcvr_rx_in12           (xcvr_rx_in12),                            //               .rx_in12
        .xcvr_rx_in13           (xcvr_rx_in13),                            //               .rx_in13
        .xcvr_rx_in14           (xcvr_rx_in14),                            //               .rx_in14
        .xcvr_rx_in15           (xcvr_rx_in15),                            //               .rx_in15
        .xcvr_tx_out0           (xcvr_tx_out0),                            //               .tx_out0
        .xcvr_tx_out1           (xcvr_tx_out1),                            //               .tx_out1
        .xcvr_tx_out2           (xcvr_tx_out2),                            //               .tx_out2
        .xcvr_tx_out3           (xcvr_tx_out3),                            //               .tx_out3
        .xcvr_tx_out4           (xcvr_tx_out4),                            //               .tx_out4
        .xcvr_tx_out5           (xcvr_tx_out5),                            //               .tx_out5
        .xcvr_tx_out6           (xcvr_tx_out6),                            //               .tx_out6
        .xcvr_tx_out7           (xcvr_tx_out7),                            //               .tx_out7
        .xcvr_tx_out8           (xcvr_tx_out8),                            //               .tx_out8
        .xcvr_tx_out9           (xcvr_tx_out9),                            //               .tx_out9
        .xcvr_tx_out10          (xcvr_tx_out10),                           //               .tx_out10
        .xcvr_tx_out11          (xcvr_tx_out11),                           //               .tx_out11
        .xcvr_tx_out12          (xcvr_tx_out12),                           //               .tx_out12
        .xcvr_tx_out13          (xcvr_tx_out13),                           //               .tx_out13
        .xcvr_tx_out14          (xcvr_tx_out14),                           //               .tx_out14
        .xcvr_tx_out15          (xcvr_tx_out15),                           //               .tx_out15
        .pcie_clk               (pcie_clk),
        .pcie_reset_n           (pcie_reset_n),
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
        .clk_status             (clk_status),
        .status_addr            (s_addr),
        .status_read            (s_read),
        .status_write           (s_write),
        .status_writedata       (s_writedata),
        .status_readdata        (pcie_status_readdata),
        .status_readdata_valid  (pcie_status_readdata_valid)
    );
`endif

`ifdef DISABLE_DRAM
assign ddr_wr_req_almost_full = 0;
assign ddr_rd_req_almost_full = 0;
assign ddr_rd_resp_valid = 0;
assign dram_readdata_valid = 0;
`else
dram_wrapper dram_inst(

`ifdef BRAM_CHECKPKT_BUF
    .emif_reset_n           (pcie_reset_n_r2),
    .emif_clk               (pcie_clk),
`else
    .CPU_RESETN             (!arst), // Reset, 
    .CLK_DDR4_COMP_P        (CLK_DDR4_COMP_P),
    .DDR4_COMP_CLK_P        (DDR4_COMP_CLK_P),
    .DDR4_COMP_CLK_N        (DDR4_COMP_CLK_N),
    .DDR4_COMP_A            (DDR4_COMP_A),
    .DDR4_COMP_ACT_N        (DDR4_COMP_ACT_N),
    .DDR4_COMP_BA           (DDR4_COMP_BA),
    .DDR4_COMP_BG0          (DDR4_COMP_BG0),
    .DDR4_COMP_BG1          (DDR4_COMP_BG1),
    .DDR4_COMP_CKE          (DDR4_COMP_CKE),
    .DDR4_COMP_CS_N         (DDR4_COMP_CS_N),
    .DDR4_COMP_ODT          (DDR4_COMP_ODT),
    .DDR4_COMP_RESET_N      (DDR4_COMP_RESET_N),
    .DDR4_COMP_PAR          (DDR4_COMP_PAR),
    .DDR4_COMP_ALERT_N      (DDR4_COMP_ALERT_N),
    .DDR4_COMP_DQS_P        (DDR4_COMP_DQS_P),
    .DDR4_COMP_DQS_N        (DDR4_COMP_DQS_N),
    .DDR4_COMP_DQ           (DDR4_COMP_DQ),
    .DDR4_COMP_DBI_N        (DDR4_COMP_DBI_N),
    .DDR4_COMP_RZQ          (DDR4_COMP_RZQ),
`endif
    .clk                    (pcie_clk),
    .rst                    (!pcie_reset_n_r2),
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_valid),
    .ddr_rd_resp_ready      (!ddr_rd_resp_almost_full),
    //JTAG
    .clk_status        (clk_status),
    .status_addr       (s_addr),
    .status_read       (s_read),
    .status_write      (s_write),
    .status_writedata  (s_writedata),
    .status_readdata   (dram_readdata),
    .status_readdata_valid  (dram_readdata_valid)
);
`endif

endmodule

