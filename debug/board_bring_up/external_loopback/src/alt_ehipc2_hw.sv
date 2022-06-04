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

module alt_ehipc2_hw (
    input clk50,
    input cpu_resetn,

    //port 0
    input  logic       i_clk_ref_0,
    input  logic [3:0] i_rx_serial_0,
    output logic [3:0] o_tx_serial_0,

    //port 1
    input  logic       i_clk_ref_1,
    input  logic [3:0] i_rx_serial_1,
    output logic [3:0] o_tx_serial_1
);
    localparam DEVICE_FAMILY = "Stratix 10";
    localparam WORDS = 8;
    localparam WIDTH = 64;
    localparam SOP_ON_LANE0 = 1'b1;
    localparam SIM_NO_TEMP_SENSE = 1'b0;

    //Slicing JTAG memory space
    localparam STAT_AWIDTH = 5;
    localparam ETH_0_REG   = 5'b00_000;
    localparam ETH_1_REG   = 5'b00_001;
    localparam PC_0_REG    = 5'b00_010;
    localparam PC_1_REG    = 5'b00_011;

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
    logic         eth_0_cs;
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

    logic [15:0]  pc_0_addr;
    logic [31:0]  pc_0_readdata;
    logic         pc_0_cs;
    logic         pc_0_read;
    logic         pc_0_write;
    logic         pc_0_readdata_valid;
    logic         pc_0_waitrequest;
    logic [31:0]  pc_0_writedata;

    //port 1 jtag 
    logic         select_waitrequest1; 
    logic [15:0]  eth_1_addr;
    logic [31:0]  eth_1_readdata;
    logic         eth_1_cs;
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

    logic [15:0]  pc_1_addr;
    logic [31:0]  pc_1_readdata;
    logic         pc_1_cs;
    logic         pc_1_read;
    logic         pc_1_write;
    logic         pc_1_readdata_valid;
    logic         pc_1_waitrequest;
    logic [31:0]  pc_1_writedata;
    //User jtag
    logic [29:0]  s_addr;
    logic         s_read;
    logic         s_write;
    logic [31:0]  s_writedata;
    logic         custom;
    logic         select_eth_0;
    logic         select_eth_1;
    logic         select_eth_0_r;
    logic         select_eth_1_r;
    logic         select_pc_0;
    logic         select_pc_1;
    logic         select_pc_0_r;
    logic         select_pc_1_r;

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


    /////////////////////////
    // logic
    /////////////////////////
    assign clk_status = clk100;
    // ARST conditional upon ninit_done from S10 IP reset. Ninit_done is active low. ninit_done=0 => s10 is good to go	  
    assign arst = ~user_mode_sync | ~cpu_resetn | ~iopll_locked | ninit_done;

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
            select_eth_0_r <= 0;
            select_eth_1_r <= 0;
            select_pc_0_r <= 0;
            select_pc_1_r <= 0;
        end
        else if( !select_waitrequest || !select_waitrequest1 || status_read || status_write ) begin
            status_read_r      <= status_read;
            status_write_r     <= status_write;
            status_writedata_r <= status_writedata;
            status_addr_r      <= status_addr;
            select_eth_0_r     <= select_eth_0;
            select_eth_1_r     <= select_eth_1;
            select_pc_0_r      <= select_pc_0;
            select_pc_1_r      <= select_pc_1;
        end
    end
     
    //Eth Port 0
    assign select_waitrequest = !select_eth_0_r ? 1'b1 : 
                                ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) ? xcvr_0_waitrequest[0] :
                                ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) ? xcvr_0_waitrequest[1] :
                                ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) ? xcvr_0_waitrequest[2] :
                                ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) ? xcvr_0_waitrequest[3] :
                                ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) ? eth_0_waitrequest :
                                1'b0;
       
    //Reconfig Decoding XCVR 0      
    assign xcvr_0_cs[0]             = ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) && select_eth_0_r;
    assign xcvr_0_read[0]           = status_read_r && xcvr_0_cs[0];
    assign xcvr_0_write[0]          = status_write_r && xcvr_0_cs[0];
    assign xcvr_0_address[10:0]     = (xcvr_0_read[0] || xcvr_0_write[0]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[0] = xcvr_0_read[0] && !xcvr_0_waitrequest[0];
    //Reconfig Decoding XCVR 1      
    assign xcvr_0_cs[1]             = ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) && select_eth_0_r;
    assign xcvr_0_read[1]           = status_read_r && xcvr_0_cs[1];
    assign xcvr_0_write[1]          = status_write_r && xcvr_0_cs[1];
    assign xcvr_0_address[21:11]    = (xcvr_0_read[1] || xcvr_0_write[1]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[1] = xcvr_0_read[1]  && !xcvr_0_waitrequest[1];
    //Reconfig Decoding XCVR 2     
    assign xcvr_0_cs[2]             = ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) && select_eth_0_r;
    assign xcvr_0_read[2]           = status_read_r && xcvr_0_cs[2];
    assign xcvr_0_write[2]          = status_write_r && xcvr_0_cs[2];
    assign xcvr_0_address[32:22]    = (xcvr_0_read[2] || xcvr_0_write[2]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[2] = xcvr_0_read[2]  && !xcvr_0_waitrequest[2];
    //Reconfig Decoding XCVR 3     
    assign xcvr_0_cs[3]             = ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) && select_eth_0_r;
    assign xcvr_0_read[3]           = status_read_r && xcvr_0_cs[3];
    assign xcvr_0_write[3]          = status_write_r && xcvr_0_cs[3];
    assign xcvr_0_address[43:33]    = (xcvr_0_read[3] ||xcvr_0_write[3]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_0_readdata_valid[3] = xcvr_0_read[3] && !xcvr_0_waitrequest[3];

    //Reconfig Decoding Eth       
    assign eth_0_cs                 = ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) && select_eth_0_r;
    assign eth_0_read               = status_read_r && eth_0_cs;
    assign eth_0_write              = status_write_r && eth_0_cs;
    assign eth_0_addr               = (eth_0_read|| eth_0_write) ? status_addr_r[15:0] : 16'b0; 
    assign eth_0_writedata          = status_writedata_r;
    assign xcvr_0_writedata         = {4{status_writedata_r}};

    //Eth Port 1
    assign select_waitrequest1 = !select_eth_1_r ? 1'b1 : 
                                ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) ? xcvr_1_waitrequest[0] :
                                ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) ? xcvr_1_waitrequest[1] :
                                ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) ? xcvr_1_waitrequest[2] :
                                ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) ? xcvr_1_waitrequest[3] :
                                ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) ? eth_1_waitrequest :
                                1'b0;
       
    //Reconfig Decoding XCVR 0      
    assign xcvr_1_cs[0]             = ((status_addr_r >= 20'h10000) && (status_addr_r <= 20'h10FFF)) && select_eth_1_r;
    assign xcvr_1_read[0]           = status_read_r && xcvr_1_cs[0];
    assign xcvr_1_write[0]          = status_write_r && xcvr_1_cs[0];
    assign xcvr_1_address[10:0]     = (xcvr_1_read[0] || xcvr_1_write[0]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_1_readdata_valid[0] = xcvr_1_read[0] && !xcvr_1_waitrequest[0];
    //Reconfig Decoding XCVR 1      
    assign xcvr_1_cs[1]             = ((status_addr_r >= 20'h11000) && (status_addr_r <= 20'h11FFF)) && select_eth_1_r;
    assign xcvr_1_read[1]           = status_read_r && xcvr_1_cs[1];
    assign xcvr_1_write[1]          = status_write_r && xcvr_1_cs[1];
    assign xcvr_1_address[21:11]    = (xcvr_1_read[1] || xcvr_1_write[1]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_1_readdata_valid[1] = xcvr_1_read[1]  && !xcvr_1_waitrequest[1];
    //Reconfig Decoding XCVR 2     
    assign xcvr_1_cs[2]             = ((status_addr_r >= 20'h12000) && (status_addr_r <= 20'h12FFF)) && select_eth_1_r;
    assign xcvr_1_read[2]           = status_read_r && xcvr_1_cs[2];
    assign xcvr_1_write[2]          = status_write_r && xcvr_1_cs[2];
    assign xcvr_1_address[32:22]    = (xcvr_1_read[2] || xcvr_1_write[2]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_1_readdata_valid[2] = xcvr_1_read[2]  && !xcvr_1_waitrequest[2];
    //Reconfig Decoding XCVR 3     
    assign xcvr_1_cs[3]             = ((status_addr_r >= 20'h13000) && (status_addr_r <= 20'h13FFF)) && select_eth_1_r;
    assign xcvr_1_read[3]           = status_read_r && xcvr_1_cs[3];
    assign xcvr_1_write[3]          = status_write_r && xcvr_1_cs[3];
    assign xcvr_1_address[43:33]    = (xcvr_1_read[3] ||xcvr_1_write[3]) ? status_addr_r[10:0] : 11'b0; 
    assign xcvr_1_readdata_valid[3] = xcvr_1_read[3] && !xcvr_1_waitrequest[3];

    //Reconfig Decoding Eth       
    assign eth_1_cs                 = ((status_addr_r >= 20'h00000) && (status_addr_r <= 20'h00FFF)) && select_eth_1_r;
    assign eth_1_read               = status_read_r && eth_1_cs;
    assign eth_1_write              = status_write_r && eth_1_cs;
    assign eth_1_addr               = (eth_1_read|| eth_1_write) ? status_addr_r[15:0] : 16'b0; 
    assign eth_1_writedata          = status_writedata_r;
    assign xcvr_1_writedata         = {4{status_writedata_r}};
   

    //assign my_stats
    assign s_addr = av_addr[31:2];
    assign s_read = status_read;
    assign s_write = status_write;
    assign s_writedata = status_writedata;
    assign custom = av_addr[31];
    assign select_eth_0 = av_addr[31:32-STAT_AWIDTH] == ETH_0_REG;
    assign select_eth_1 = av_addr[31:32-STAT_AWIDTH] == ETH_1_REG;
    assign select_pc_0  = av_addr[31:32-STAT_AWIDTH] == PC_0_REG;
    assign select_pc_1  = av_addr[31:32-STAT_AWIDTH] == PC_1_REG;

    assign pc_0_cs                 = select_pc_0_r;
    assign pc_0_read               = status_read_r && pc_0_cs;
    assign pc_0_write              = status_write_r && pc_0_cs;
    assign pc_0_addr               = (pc_0_read|| pc_0_write) ? status_addr_r[15:0] : 16'b0; 
    assign pc_0_writedata          = status_writedata_r;

    assign pc_1_cs                 = select_pc_1_r;
    assign pc_1_read               = status_read_r && pc_1_cs;
    assign pc_1_write              = status_write_r && pc_1_cs;
    assign pc_1_addr               = (pc_1_read|| pc_1_write) ? status_addr_r[15:0] : 16'b0; 
    assign pc_1_writedata          = status_writedata_r;
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
        .NUM_CLIENTS            (4),
        .TIMEOUT                (11)
    ) arc (
        .clk                    (clk_status),
        .arst                   (arst),
        .host_read              (status_read),
        .host_readdata          (status_readdata),
        .host_readdata_valid    (status_readdata_valid),
        .host_waitrequest       (status_waitrequest),
        .client_readdata_valid  ({eth_0_readdata_valid, 
                                  pc_0_readdata_valid, 
                                  eth_1_readdata_valid, 
                                  pc_1_readdata_valid}),
        .client_readdata        ({eth_0_readdata, 
                                  pc_0_readdata, 
                                  eth_1_readdata, 
                                  pc_1_readdata})
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

    /////////////////////////
    // Port 0 packet gen
    /////////////////////////
    alt_e100s10_packet_client pc_0 (
        .i_arst                     (arst),
        // TX to Ethernet
        .i_clk_tx                   (clk_tx_0),
        .i_tx_ready                 (tx_0_ready),
        .o_tx_valid                 (tx_0_valid),
        .o_tx_data                  (tx_0_data),
        .o_tx_sop                   (tx_0_startofpacket),
        .o_tx_eop                   (tx_0_endofpacket),
        .o_tx_empty                 (tx_0_empty),
        // RX from Ethernet
        .i_clk_rx                   (clk_rx_0),
        .i_rx_sop                   (rx_0_startofpacket),
        .i_rx_eop                   (rx_0_endofpacket),
        .i_rx_empty                 (rx_0_empty),
        .i_rx_data                  (rx_0_data),
        .i_rx_valid                 (rx_0_valid),
        // status register bus
        .i_clk_status               (clk_status),
        .i_status_addr              (pc_0_addr),
        .i_status_read              (pc_0_read),
        .i_status_write             (pc_0_write),
        .i_status_writedata         (pc_0_writedata),
        .o_status_readdata          (pc_0_readdata),
        .o_status_readdata_valid    (pc_0_readdata_valid)
    );

    /////////////////////////
    // Port 1 ATX PLL, lane0 and lane1
    /////////////////////////
    atx_pll_e50g_master atx_m_1 (
        .pll_refclk0        (i_clk_ref_1),
        .tx_serial_clk_gxt  (tx_serial_clk_23_1),
        .gxt_output_to_blw_atx (atx12_cascade_1),  
        .pll_locked         (tx_pll_locked_23_1),
        .pll_cal_busy       ()
    );

    /////////////////////////
    // Port 1 ATX PLL, lane2 and lane3, cascade with previous PLL
    /////////////////////////
    atx_pll_e50g_slave atx_s_1  (
        .gxt_input_from_abv_atx(atx12_cascade_1),  
        .pll_refclk0        (i_clk_ref_1),
        .tx_serial_clk_gxt  (tx_serial_clk_01_1),
        .pll_locked         (tx_pll_locked_01_1),
        .pll_cal_busy       ()
    );


    /////////////////////////
    // Port 1 Ethernet Core, hard IP
    /////////////////////////
    ex_100G av_top_1 (
           .i_stats_snapshot                  (i_stats_snapshot_1),
           .o_cdr_lock                        (o_cdr_lock_1),
           .i_eth_reconfig_addr               (eth_1_addr),
           .i_eth_reconfig_read               (eth_1_read),
           .i_eth_reconfig_write              (eth_1_write),
           .o_eth_reconfig_readdata           (eth_1_readdata),
           .o_eth_reconfig_readdata_valid     (eth_1_readdata_valid),
           .i_eth_reconfig_writedata          (eth_1_writedata),
           .o_eth_reconfig_waitrequest        (eth_1_waitrequest),
           .o_tx_lanes_stable                 (o_tx_lanes_stable_1),
           .o_rx_pcs_ready                    (rx_1_pcs_ready),
           .o_ehip_ready                      (o_ehip_ready_1),
           .o_rx_block_lock                   (rx_1_block_lock),
           .o_rx_am_lock                      (rx_1_am_lock),
           .o_rx_hi_ber                       (rx_1_hi_ber),
           .o_local_fault_status              (o_local_fault_status_1),
           .o_remote_fault_status             (o_remote_fault_status_1),
           .i_clk_ref                         (i_clk_ref_1),
           .i_clk_tx                          (clk_tx_1),
           .i_clk_rx                          (clk_rx_1),
           .o_clk_pll_div64                   (o_clk_pll_div64_1),
           .o_clk_pll_div66                   (o_clk_pll_div66_1),
           .o_clk_rec_div64                   (o_clk_rec_div64_1),
           .o_clk_rec_div66                   (o_clk_rec_div66_1),
           .i_csr_rst_n                       (~arst),
           .i_tx_rst_n                        (1'b1),
           .i_rx_rst_n                        (1'b1),
           .o_tx_serial                       (o_tx_serial_1),
           .i_rx_serial                       (i_rx_serial_1),
           .i_reconfig_clk                    (clk_status),
           .i_reconfig_reset                  (arst),
           .i_xcvr_reconfig_address           (xcvr_1_address),
           .i_xcvr_reconfig_read              (xcvr_1_read),
           .i_xcvr_reconfig_write             (xcvr_1_write),
           .o_xcvr_reconfig_readdata          (xcvr_1_readdata),
           .i_xcvr_reconfig_writedata         (xcvr_1_writedata),
           .o_xcvr_reconfig_waitrequest       (xcvr_1_waitrequest),
           .o_tx_ready                        (tx_1_ready),
           .o_rx_valid                        (rx_1_valid),
           .i_tx_valid                        (tx_1_valid),
           .i_tx_data                         (tx_1_data),
           .o_rx_data                         (rx_1_data),
           .i_tx_error                        (1'b0),
           .i_tx_startofpacket                (tx_1_startofpacket),
           .i_tx_endofpacket                  (tx_1_endofpacket),
           .i_tx_empty                        (tx_1_empty),
           .i_tx_skip_crc                     (1'b0),
           .o_rx_startofpacket                (rx_1_startofpacket),
           .o_rx_endofpacket                  (rx_1_endofpacket),
           .o_rx_empty                        (rx_1_empty),
           .o_rx_error                        (rx_1_error),
           .o_rxstatus_data                   (o_rxstatus_data_1),
           .o_rxstatus_valid                  (o_rxstatus_valid_1),
           .i_tx_pfc                          (8'b0),
           .o_rx_pfc                          (rx_1_pfc),
           .i_tx_pause                        (1'b0),
           .o_rx_pause                        (rx_1_pause),
           .i_tx_serial_clk                   (tx_serial_clk_1),
           .i_tx_pll_locked                   (tx_pll_locked_1)
    );

    /////////////////////////
    // Port 1 packet gen
    /////////////////////////
    alt_e100s10_packet_client pc_1 (
        .i_arst                     (arst),
        // TX to Ethernet
        .i_clk_tx                   (clk_tx_1),
        .i_tx_ready                 (tx_1_ready),
        .o_tx_valid                 (tx_1_valid),
        .o_tx_data                  (tx_1_data),
        .o_tx_sop                   (tx_1_startofpacket),
        .o_tx_eop                   (tx_1_endofpacket),
        .o_tx_empty                 (tx_1_empty),
        // RX from Ethernet
        .i_clk_rx                   (clk_rx_1),
        .i_rx_sop                   (rx_1_startofpacket),
        .i_rx_eop                   (rx_1_endofpacket),
        .i_rx_empty                 (rx_1_empty),
        .i_rx_data                  (rx_1_data),
        .i_rx_valid                 (rx_1_valid),
        // status register bus
        .i_clk_status               (clk_status),
        .i_status_addr              (pc_1_addr),
        .i_status_read              (pc_1_read),
        .i_status_write             (pc_1_write),
        .i_status_writedata         (pc_1_writedata),
        .o_status_readdata          (pc_1_readdata),
        .o_status_readdata_valid    (pc_1_readdata_valid)
    );

endmodule

