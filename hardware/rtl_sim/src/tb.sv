`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps
`include "./src/struct_s.sv"
module tb;

`ifndef PKT_FILE
`define PKT_FILE "./input_gen/output.pkt"
`define PKT_FILE_NB_LINES 2200
`endif

// duration for each bit = 20 * timescale = 20 * 1 ns  = 20ns
localparam period = 10;  
localparam period_rx = 2.56;  
localparam period_tx = 2.56;  
localparam period_user = 5;  
localparam period_user_high = 2.5;  
//localparam period_user_high = 5;  
localparam period_datamover = 5;  
localparam period_esram_ref = 10;  
localparam period_pcie = 4;  
localparam period_emif = 3;  
localparam data_width = 528;  
localparam lo = 0;  
localparam hi = `PKT_FILE_NB_LINES;  //filtered ack_128 pkts
localparam stop = (hi*2*1.25+10000);  
localparam nf_forward_threshold = 200;

logic  clk_status;
logic  clk_rxmac;
logic  clk_txmac;
logic  clk_user;
logic  clk_user_high;
logic  clk_datamover;
logic  clk_esram_ref;
logic  clk_pcie;
logic  clk_emif;


logic rst_datamover;

logic  rst;
logic  emif_reset_n;
logic [31:0] pkt_cnt;
logic [31:0] cnt;
logic [31:0] addr;
logic [data_width -1:0] arr[lo:hi];

//Ethner signals
logic  [511:0]  l8_rx_data;
logic  [5:0]    l8_rx_empty;
logic           l8_rx_valid;
logic           l8_rx_startofpacket;
logic           l8_rx_endofpacket;
logic           l8_rx_ready;

logic  [511:0]  stats_rx_data;
logic  [5:0]    stats_rx_empty;
logic           stats_rx_valid;
logic           stats_rx_startofpacket;
logic           stats_rx_endofpacket;
logic           stats_rx_ready;

logic  [511:0]  top_in_data;
logic  [5:0]    top_in_empty;
logic           top_in_valid;
logic           top_in_startofpacket;
logic           top_in_endofpacket;
logic  [511:0]  top_out_data;
logic  [5:0]    top_out_empty;
logic           top_out_valid;
logic           top_out_startofpacket;
logic           top_out_endofpacket;
logic           top_out_almost_full;

logic  [511:0]  reg_top_in_data;
logic  [5:0]    reg_top_in_empty;
logic           reg_top_in_valid;
logic           reg_top_in_startofpacket;
logic           reg_top_in_endofpacket;
logic  [511:0]  reg_top_out_data;
logic  [5:0]    reg_top_out_empty;
logic           reg_top_out_valid;
logic           reg_top_out_startofpacket;
logic           reg_top_out_endofpacket;
logic           reg_top_out_almost_full;

logic  [511:0]  l8_tx_data;
logic  [5:0]    l8_tx_empty;
logic           l8_tx_valid;
logic           l8_tx_startofpacket;
logic           l8_tx_endofpacket;
logic           l8_tx_ready;

logic           out_fifo0_in_csr_address;
logic           out_fifo0_in_csr_read;
logic           out_fifo0_in_csr_write;
logic [31:0]    out_fifo0_in_csr_readdata;
logic [31:0]    out_fifo0_in_csr_writedata;

//PCIE
logic           disable_pcie;
logic [513:0]   pcie_rb_wr_data;
logic [11:0]    pcie_rb_wr_addr;          
logic           pcie_rb_wr_en;  
logic [11:0]    pcie_rb_wr_base_addr;          
logic           pcie_rb_almost_full;          
logic           pcie_rb_update_valid;
logic [11:0]    pcie_rb_update_size;
logic [27:0]    pdumeta_cpu_data;
logic           pdumeta_cpu_valid;
logic [9:0]     pdumeta_cnt;

logic           reg_disable_pcie;
logic [513:0]   reg_pcie_rb_wr_data;
logic [11:0]    reg_pcie_rb_wr_addr;          
logic           reg_pcie_rb_wr_en;  
logic [11:0]    reg_pcie_rb_wr_base_addr;          
logic           reg_pcie_rb_almost_full;          
logic           reg_pcie_rb_update_valid;
logic [11:0]    reg_pcie_rb_update_size;
logic [27:0]    reg_pdumeta_cpu_data;
logic           reg_pdumeta_cpu_valid;
logic [9:0]     reg_pdumeta_cnt;
//DRAM signals
logic [547:0]   ddr_wr_req_data;
logic           ddr_wr_req_valid;
logic           ddr_wr_req_almost_full;
logic [33:0]    ddr_rd_req_data;
logic           ddr_rd_req_valid;
logic           ddr_rd_req_almost_full;
logic [511:0]   ddr_rd_resp_data;
logic           ddr_rd_resp_valid;
logic           ddr_rd_resp_almost_full;
logic           ddr_rd_resp_valid_int;

logic [547:0]   reg_ddr_wr_req_data;
logic           reg_ddr_wr_req_valid;
logic           reg_ddr_wr_req_almost_full;
logic [33:0]    reg_ddr_rd_req_data;
logic           reg_ddr_rd_req_valid;
logic           reg_ddr_rd_req_almost_full;
logic [511:0]   reg_ddr_rd_resp_data;
logic           reg_ddr_rd_resp_valid;
logic           reg_ddr_rd_resp_almost_full;

//eSRAM signals
logic esram_pll_lock; 
logic         esram_pkt_buf_wren;
`ifdef USE_BRAM
logic [14:0]  esram_pkt_buf_wraddress;
logic [14:0]  esram_pkt_buf_rdaddress;
logic [14:0]  reg_esram_pkt_buf_wraddress;
logic [14:0]  reg_esram_pkt_buf_rdaddress;
`else
logic [16:0]  esram_pkt_buf_wraddress;
logic [16:0]  esram_pkt_buf_rdaddress;
logic [16:0]  reg_esram_pkt_buf_wraddress;
logic [16:0]  reg_esram_pkt_buf_rdaddress;
`endif
logic [519:0] esram_pkt_buf_wrdata;
logic         esram_pkt_buf_rden;
logic         esram_pkt_buf_rd_valid;
logic [519:0] esram_pkt_buf_rddata;
logic         reg_esram_pkt_buf_wren;
logic [519:0] reg_esram_pkt_buf_wrdata;
logic         reg_esram_pkt_buf_rden;
logic         reg_esram_pkt_buf_rd_valid;
logic [519:0] reg_esram_pkt_buf_rddata;

//JTAG
logic [29:0] s_addr;
logic s_read;
logic s_write;
logic [31:0] s_writedata;
logic [31:0] s_readdata;
logic s_readdata_valid;
logic [15:0] s_cnt;
logic [31:0] top_readdata;
logic top_readdata_valid;
logic [31:0] dram_readdata;
logic dram_readdata_valid;

logic [3:0] tx_cnt;
logic [3:0] rx_cnt;

logic [31:0] pktID;
logic [31:0] ft_pkt;

logic [3:0] rate_cnt;
pdu_metadata_t          sim_pdumeta_cpu_data;
logic                   sim_pdumeta_cpu_valid;
logic                   sim_pdumeta_cpu_ready;

typedef enum{
    PDUMETA_IDLE,
    PDUMETA_WAIT
} pdumeta_state_t;

pdumeta_state_t pdumeta_state;

logic [7:0]             pdumeta_wait_cnt;

typedef enum{
    READ,
    WAIT
} state_t;

state_t read_state;

typedef enum{
    DISABLE_PCIE,
    WRITE_CTRL,
    ENABLE_PCIE,
    IDLE,
    IN_PKT,
    OUT_PKT,
    IN_EMPTYLIST_PKT,
    OUT_EMPTYLIST_PKT,
    IN_FT_PKT,
    OUT_FT_PKT,
    IN_DATAMOVER_PKT,
    OUT_DATAMOVER_PKT,
    FT_FLOW_INSERT,
    FT_FLOW_DEQ,
    FT_LOOKUP_PKT,
    FT_CONC_FLOW,
    FT_CURRENT_FLOW,
    PKT_CNT_FIN,
    PKT_CNT_ACK,
    PKT_CNT_INSERT_OOO,
    PKT_CNT_FORWARD,
    PKT_CNT_DROP,
    PKT_CNT_CHECK,
    PKT_CNT_OOO,
    PKT_CNT_FORWARD_OOO,
    PKT_CNT_DONE,
    IN_SM_IN,
    OUT_SM_IN,
    IN_SM_OUT,
    OUT_SM_OUT,
    OUT_CHECK_FIFO,
    IN_CHECK_MUX,
    WRITE_FT_CTRL,
    READ_FT_FIRST,
    READ_FT,
    READ_RULEID,
    READ_TEST1,
    READ_TEST2,
    DMA_PKT,
    RULE_CNT,
    MAX_RULE_FIFO,
    MAX_SM_OUT_META,
    MAX_SM_INDATA,
    MAX_PARSER_FIFO,
    MAX_CHECK_PKT_FIFO,
    NO_CHECK_PKT_CNT,
    NO_MATCH_PKT_CNT,
    MATCH_PKT_CNT,
    MAX_PDUMETA_CNT,
    PG_RULE_CNT,
    PG_META_CNT,
    PG_NO_PG_RULE_CNT,
    PG_INT_RULE_CNT,
    MAX_PG_RULE_FIFO,
    AF_NONPAYLOAD_PKT,
    AF_CHECK_PKT,
    AF_SM,
    NF_NO_CHECK_PKT,
    NF_NO_CHECK_1_PKT,
    NF_MAX_RAW_PKT_FIFO,
    NF_MAX_PKT_FIFO,
    NF_MAX_PCIE,
    NF_MAX_RULE_FIFO,
    DRAM_WR_CNT,
    DRAM_RD_CNT,
    DRAM_RESP_CNT
} c_state_t;

c_state_t conf_state;

initial clk_rxmac = 0;
initial clk_txmac = 1;
initial clk_user = 0;
initial clk_user_high = 0;
initial clk_datamover = 0;
initial clk_esram_ref = 0;
initial clk_pcie = 0;
initial clk_datamover = 0;

initial clk_status = 0;
initial l8_tx_ready = 0;
initial tx_cnt = 0;
initial rx_cnt = 0;

initial rst = 1;
initial cnt = 0;
initial rate_cnt = 0;
always #(period) clk_status = ~clk_status;
always #(period_rx) clk_rxmac = ~clk_rxmac;
always #(period_tx) clk_txmac = ~clk_txmac;
always #(period_user) clk_user = ~clk_user;
always #(period_user_high) clk_user_high = ~clk_user_high;
always #(period_esram_ref) clk_esram_ref = ~clk_esram_ref;
always #(period_datamover) clk_datamover = ~clk_datamover;
always #(period_pcie) clk_pcie = ~clk_pcie;

`ifdef BRAM_CHECKPKT_BUF
assign clk_emif = clk_pcie;
assign emif_reset_n = !rst;
`else
initial clk_emif = 0;
always #(period_emif) clk_emif = ~clk_emif;
initial 
begin    
    emif_reset_n = 0;
    #20  emif_reset_n = 1;
end

`endif
//
//read raw data
initial
    begin : init_block
        integer i;          // temporary for generate reset value
        for (i = lo; i <= hi; i = i + 1) begin
            arr[i] = {((data_width + 1)/2){2'b0}} ;//initial it as all zero(zzp 06.30.2015)
        end
        $readmemh(`PKT_FILE, arr, lo, hi);//read data from rom
    end // initial begin

assign l8_rx_startofpacket = arr[addr][524];
assign l8_rx_endofpacket = arr[addr][520];
assign l8_rx_empty = arr[addr][519:512];
//assign l8_rx_data = l8_rx_startofpacket ? {pktID,arr[addr][479:0]}:arr[addr][511:0];
assign l8_rx_data = arr[addr][511:0];
//assign l8_tx_ready = 1'b1;
assign rst_datamover = rst | !esram_pll_lock;

always @(posedge clk_rxmac)
begin
    if (rst) begin
        pktID <= 0;
    end else if(l8_rx_startofpacket & l8_rx_valid)begin
        pktID <= pktID + 1;
    end
end

always @(posedge clk_txmac)
begin
    if (tx_cnt < 4'd10)begin
        tx_cnt <= tx_cnt + 1'b1;
    end else begin
        tx_cnt <= 0;
        l8_tx_ready <= ~ l8_tx_ready;
    end
end

//always @(posedge clk_ex)
always @(posedge clk_rxmac)
begin
    //$display("-----CYCLE %d-----", cnt);
    cnt <= cnt + 1;
    if(rate_cnt == 9)begin
        rate_cnt <= 0;
    end else begin
        rate_cnt <= rate_cnt + 1;
    end
    if (cnt == 1) begin
        rst <= 1;
        addr <= 0;
        l8_rx_valid <= 0;
        //output_V_READY <= 1;
    end else if (cnt == 35) begin
        rst <= 0;
    //Make sure the stats reset is done.
    end else if (cnt == 7000) begin
        l8_rx_valid <= 1;
    end else if (cnt >=7001 ) begin

        //if(rate_cnt < 8)begin
            if (cnt[1])begin
            //if (cnt[2:0]==0)begin
            //if (cnt %2)begin
                if(addr<hi-1)begin
                    addr <= addr + 1;
                    l8_rx_valid <= 1;
                end else begin
                    l8_rx_valid <= 0;
                end
            end else begin
                l8_rx_valid <=0;
            end
        //end else begin
        //    l8_rx_valid <= 0;
        //end
    end

    //$display("arr 0x%x", arr[addr]);
    if (cnt == stop) begin
        $display("STOP READING!");
        //$display("Done!");
        //$finish;
    end
end

//FAKE pdumeta_cpu
always @(posedge clk_pcie)begin
    if(rst)begin
        sim_pdumeta_cpu_valid <= 0;
        sim_pdumeta_cpu_data <= 0;
        pdumeta_wait_cnt <= 0;
        pdumeta_state <= PDUMETA_IDLE;
    end else begin
        case(pdumeta_state)
            PDUMETA_IDLE:begin
                sim_pdumeta_cpu_valid <= 0;
                pdumeta_wait_cnt <= 0;
                if(reg_ddr_wr_req_valid)begin
                    pdumeta_state <= PDUMETA_WAIT;
                    sim_pdumeta_cpu_data.pdu_id <= reg_ddr_wr_req_data[538:512] >> 5; //addr
                    sim_pdumeta_cpu_data.action <= ACTION_NOMATCH;
                    //sim_pdumeta_cpu_data.action <= ACTION_MATCH;
                    sim_pdumeta_cpu_data.flits <= 24;
                    sim_pdumeta_cpu_data.pdu_size <= 1496;
                end
            end
            PDUMETA_WAIT:begin
                pdumeta_wait_cnt <= pdumeta_wait_cnt + 1;
                if(pdumeta_wait_cnt == 25)begin
                    pdumeta_state <= PDUMETA_IDLE;
                    sim_pdumeta_cpu_valid <= 1;
                end
            end   
        endcase
    end
end


//Configure
//Read and display pkt/flow cnts
always @(posedge clk_status) begin
    if(rst)begin
        s_addr <= 0;
        s_read <= 0;
        s_write <= 0;
        s_writedata <= 0;
        s_cnt <= 0;
        //conf_state <= DISABLE_PCIE;
        conf_state <= ENABLE_PCIE;
        //conf_state <= IDLE;
    end else begin
        case(conf_state)
            DISABLE_PCIE:begin
                conf_state <= WRITE_CTRL;
                s_write <= 1;
                s_addr <= 30'h2A00_000F;
                s_writedata <= 1;
            end
            ENABLE_PCIE:begin
                conf_state <= WRITE_CTRL;
                s_write <= 1;
                s_addr <= 30'h2A00_000F;
                s_writedata <= 0;
            end
            WRITE_CTRL:begin
                conf_state <= IDLE;
                s_write <= 1;
                s_addr <= 30'h2200_0037;
                //write non-fast-pattern forward threshold
                s_writedata <= nf_forward_threshold;
            end
            IDLE:begin
                s_write <= 0;
                if(cnt>=stop)begin
                    conf_state <= IN_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0000;
                end
            end
            IN_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_PKT:\t%d",top_readdata);
                    conf_state <= OUT_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0006;
                end
            end
            OUT_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_PKT:\t%d",top_readdata);
                    conf_state <= IN_EMPTYLIST_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0008;
                end
            end
            IN_EMPTYLIST_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_EMPTYLIST_PKT:\t%d",top_readdata);
                    conf_state <= OUT_EMPTYLIST_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0009;
                end
            end
            OUT_EMPTYLIST_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_EMPTYLIST_PKT:\t%d",top_readdata);
                    conf_state <= IN_FT_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0003;
                end
            end
            IN_FT_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_FT_PKT:\t%d",top_readdata);
                    conf_state <= OUT_FT_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0004;
                end
            end
            OUT_FT_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_FT_PKT:\t%d",top_readdata);
                    conf_state <= IN_DATAMOVER_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0005;
                end
            end
            IN_DATAMOVER_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_DATAMOVER_PKT:\t%d",top_readdata);
                    conf_state <= OUT_DATAMOVER_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0007;
                end
            end
            OUT_DATAMOVER_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_DATAMOVER_PKT:\t%d",top_readdata);
                    //conf_state <= FT_FLOW_INSERT;
                    //s_read <= 1;
                    //s_addr <= 30'h2400_0003;
                    conf_state <= PKT_CNT_FORWARD;
                    s_read <= 1;
                    s_addr <= 30'h2200_000a;
                end
            end
            FT_FLOW_INSERT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("FT_FLOW_INSERT:\t%d",top_readdata);
                    conf_state <= FT_FLOW_DEQ;
                    s_read <= 1;
                    s_addr <= 30'h2400_0004;
                end
            end
            FT_FLOW_DEQ:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("FT_FLOW_DEQ:\t%d",top_readdata);
                    conf_state <= FT_LOOKUP_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2400_0005;
                end
            end
            FT_LOOKUP_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("FT_LOOKUP_PKT:\t%d",top_readdata);
                    conf_state <= FT_CONC_FLOW;
                    s_read <= 1;
                    s_addr <= 30'h2400_0006;
                end
            end
            FT_CONC_FLOW:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("FT_CONC_FLOW:\t%d",top_readdata);
                    conf_state <= FT_CURRENT_FLOW;
                    s_read <= 1;
                    s_addr <= 30'h2400_0007;
                end
            end
            FT_CURRENT_FLOW:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("FT_CURRENT_FLOW:\t%d",top_readdata);
                    conf_state <= PKT_CNT_FIN;
                    s_read <= 1;
                    s_addr <= 30'h2400_0008;
                end
            end
            PKT_CNT_FIN:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_FIN:\t%d",top_readdata);
                    conf_state <= PKT_CNT_ACK;
                    s_read <= 1;
                    s_addr <= 30'h2400_0009;
                end
            end
            PKT_CNT_ACK:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_ACK:\t%d",top_readdata);
                    conf_state <= PKT_CNT_INSERT_OOO;
                    s_read <= 1;
                    s_addr <= 30'h2400_000a;
                end
            end
            PKT_CNT_INSERT_OOO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_INSERT_OOO:\t%d",top_readdata);
                    conf_state <= PKT_CNT_FORWARD;
                    s_read <= 1;
                    s_addr <= 30'h2200_000a;
                end
            end
            PKT_CNT_FORWARD:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_FORWARD:\t%d",top_readdata);
                    conf_state <= PKT_CNT_DROP;
                    s_read <= 1;
                    s_addr <= 30'h2200_000b;
                end
            end
            PKT_CNT_DROP:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_DROP:\t%d",top_readdata);
                    conf_state <= PKT_CNT_CHECK;
                    s_read <= 1;
                    s_addr <= 30'h2200_000c;
                end
            end
            PKT_CNT_CHECK:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_CHECK:\t%d",top_readdata);
                    conf_state <= PKT_CNT_OOO;
                    s_read <= 1;
                    s_addr <= 30'h2200_000d;

                end
            end
            PKT_CNT_OOO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_OOO:\t%d",top_readdata);
                    conf_state <= PKT_CNT_FORWARD_OOO;
                    s_read <= 1;
                    s_addr <= 30'h2200_000e;
                end
            end
            PKT_CNT_FORWARD_OOO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_FORWARD_OOO:\t%d",top_readdata);
                    conf_state <= PKT_CNT_DONE;
                    s_read <= 1;
                    s_addr <= 30'h2200_000f;
                end
            end
            PKT_CNT_DONE:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PKT_CNT_DONE:\t%d",top_readdata);
                    conf_state <= IN_SM_IN;
                    s_read <= 1;
                    s_addr <= 30'h2200_0010;
                end
            end
            IN_SM_IN:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_SM_IN:\t%d",top_readdata);
                    conf_state <= OUT_SM_IN;
                    s_read <= 1;
                    s_addr <= 30'h2200_0011;
                end
            end
            OUT_SM_IN:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_SM_IN:\t%d",top_readdata);
                    conf_state <= IN_SM_OUT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0012;
                end
            end
            IN_SM_OUT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_SM_OUT:\t%d",top_readdata);
                    conf_state <= OUT_SM_OUT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0013;
                end
            end
            OUT_SM_OUT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_SM_OUT:\t%d",top_readdata);
                    conf_state <= DMA_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0016;
                end
            end
            DMA_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("DMA_PKT:\t%d",top_readdata);
                    conf_state <= RULE_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0017;
                end
            end
            RULE_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("RULE_CNT:\t%d",top_readdata);
                    conf_state <= MAX_RULE_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_0018;
                end
            end
            MAX_RULE_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_RULE_FIFO:\t%d",top_readdata);
                    conf_state <= MAX_SM_OUT_META;
                    s_read <= 1;
                    s_addr <= 30'h2200_0019;
                end
            end
            MAX_SM_OUT_META:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_SM_OUT_META:\t%d",top_readdata);
                    conf_state <= MAX_SM_INDATA;
                    s_read <= 1;
                    s_addr <= 30'h2200_001a;
                end
            end
            MAX_SM_INDATA:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_SM_INDATA:\t%d",top_readdata);
                    conf_state <= MAX_PARSER_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_001b;
                end
            end
            MAX_PARSER_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_PARSER_FIFO:\t%d",top_readdata);
                    conf_state <= MAX_CHECK_PKT_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_001c;
                end
            end
            MAX_CHECK_PKT_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_CHECK_PKT_FIFO:\t%d",top_readdata);
                    conf_state <= NO_CHECK_PKT_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_001d;
                    //conf_state <= READ_RULEID;
                    //s_read <= 1;
                    //s_addr <= 30'h2600_0000;
                    //$display("done!");
                    //$finish;
                end
            end
            NO_CHECK_PKT_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NO_CHECK_PKT_CNT:\t%d",top_readdata);
                    conf_state <= NO_MATCH_PKT_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_001e;
                end
            end
            NO_MATCH_PKT_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NO_MATCH_PKT_CNT:\t%d",top_readdata);
                    conf_state <= MATCH_PKT_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_001f;
                end
            end
            MATCH_PKT_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MATCH_PKT_CNT:\t%d",top_readdata);
                    conf_state <= MAX_PDUMETA_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0020;
                    //$display("done!");
                    //$finish;
                end
            end
            MAX_PDUMETA_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_PDUMETA_CNT:\t%d",top_readdata);
                    conf_state <= PG_RULE_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0021;
                end
            end
            PG_RULE_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PG_RULE_CNT:\t%d",top_readdata);
                    conf_state <= PG_META_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0022;
                end
            end
            PG_META_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PG_META_CNT:\t%d",top_readdata);
                    conf_state <= PG_NO_PG_RULE_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0023;
                end
            end
            PG_NO_PG_RULE_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PG_NO_PG_RULE_CNT:\t%d",top_readdata);
                    conf_state <= PG_INT_RULE_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0024;
                end
            end
            PG_INT_RULE_CNT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("PG_INT_RULE_CNT:\t%d",top_readdata);
                    conf_state <= MAX_PG_RULE_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_0025;
                end
            end
            MAX_PG_RULE_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("MAX_PG_RULE_FIFO:\t%d",top_readdata);
                    conf_state <= AF_NONPAYLOAD_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0026;
                end
            end
            AF_NONPAYLOAD_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("AF_NONPAYLOAD_PKT:\t%d",top_readdata);
                    conf_state <= AF_CHECK_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0027;
                end
            end
            AF_CHECK_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("AF_CHECK_PKT:\t%d",top_readdata);
                    conf_state <= AF_SM;
                    s_read <= 1;
                    s_addr <= 30'h2200_0028;
                end
            end
            AF_SM:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("AF_SM:\t%d",top_readdata);
                    conf_state <= NF_NO_CHECK_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0031;
                end
            end
            NF_NO_CHECK_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_NO_CHECK_PKT:\t%d",top_readdata);
                    conf_state <= NF_NO_CHECK_1_PKT;
                    s_read <= 1;
                    s_addr <= 30'h2200_0032;
                end
            end
            NF_NO_CHECK_1_PKT:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_NO_CHECK_1_PKT:\t%d",top_readdata);
                    conf_state <= NF_MAX_RAW_PKT_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_0033;
                end
            end
            NF_MAX_RAW_PKT_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_MAX_RAW_PKT_FIFO:\t%d",top_readdata);
                    conf_state <= NF_MAX_PKT_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_0034;
                end
            end
            NF_MAX_PKT_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_MAX_PKT_FIFO:\t%d",top_readdata);
                    conf_state <= NF_MAX_PCIE;
                    s_read <= 1;
                    s_addr <= 30'h2200_0035;
                end
            end
            NF_MAX_PCIE:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_MAX_PCIE:\t%d",top_readdata);
                    conf_state <= NF_MAX_RULE_FIFO;
                    s_read <= 1;
                    s_addr <= 30'h2200_0036;
                end
            end
            NF_MAX_RULE_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("NF_MAX_RULE_FIFO:\t%d",top_readdata);
                    conf_state <= DRAM_WR_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2C00_0000;
                end
            end
            DRAM_WR_CNT:begin
                s_read <= 0;
                if(dram_readdata_valid)begin
                    $display("DRAM_WR_CNT:\t%d",dram_readdata);
                    conf_state <= DRAM_RD_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2C00_0001;
                end
            end
            DRAM_RD_CNT:begin
                s_read <= 0;
                if(dram_readdata_valid)begin
                    $display("DRAM_RD_CNT:\t%d",dram_readdata);
                    conf_state <= DRAM_RESP_CNT;
                    s_read <= 1;
                    s_addr <= 30'h2C00_0002;
                end
            end
            DRAM_RESP_CNT:begin
                s_read <= 0;
                if(dram_readdata_valid)begin
                    $display("DRAM_RESP_CNT:\t%d",dram_readdata);
                    //conf_state <= DRAM_WR_CNT;
                    //s_read <= 1;
                    //s_addr <= 30'h2600_0000;
                    $display("done!");
                    $finish;
                end
            end

            OUT_CHECK_FIFO:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("OUT_CHECK_FIFO:\t%d",top_readdata);
                    conf_state <= IN_CHECK_MUX;
                    $display("done!");
                    $finish;
                    s_read <= 0;
                end
            end
            IN_CHECK_MUX:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("IN_CHECK_MUX:\t%d",top_readdata);
                    $display("done!");
                    $finish;
                end
            end
            READ_TEST1:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("READ_TEST1:\t%d",top_readdata);
                    conf_state <= READ_TEST2;
                    s_read <= 1;
                    s_addr <= 30'h2E00_0005;
                end
            end
            READ_TEST2:begin
                s_read <= 0;
                if(top_readdata_valid)begin
                    $display("READ_TEST2:\t%d",top_readdata);
                    $display("done!");
                    $finish;
                end
            end
            WRITE_FT_CTRL:begin
                s_write <= 1;
                s_addr <= 30'h2400_0000;
                s_writedata <= 32'b1;
                conf_state <= READ_FT_FIRST;
            end
            READ_FT_FIRST:begin
                s_write <= 0;
                s_addr <= 30'h3800_0000;
                conf_state <= READ_FT;
                ft_pkt <= 0;
            end
            READ_FT:begin
                case(read_state)
                    READ:begin
                        s_read <= 1;
                        read_state <= WAIT;
                    end
                    WAIT:begin
                        s_read <= 0;

                        if(top_readdata_valid)begin
                            if(top_readdata != 0)begin
                                $display("Addr: %d, data: %d",s_addr[12:0],top_readdata);
                                ft_pkt <= ft_pkt + top_readdata;
                            end
                            if(s_addr == 30'h3800_1000)begin
                                $display("ft_pkt: %d", ft_pkt);
                                $finish;
                            end else begin
                                read_state <= READ;
                                s_addr <= s_addr + 1'b1;
                            end
                        end
                    end
                endcase        
            end
            //initial address = 2600_0000
            READ_RULEID:begin
                case(read_state)
                    READ:begin
                        s_read <= 1;
                        read_state <= WAIT;
                    end
                    WAIT:begin
                        s_read <= 0;

                        if(top_readdata_valid)begin
                            if(top_readdata != 0)begin
                                $display("Addr: %d, data_high: %d, data_low: %d",
                                    s_addr[12:0],top_readdata[31:16], top_readdata[15:0]);
                            end
                            if(s_addr == 30'h2600_1000)begin
                                $finish;
                            end else begin
                                read_state <= READ;
                                s_addr <= s_addr + 1'b1;
                            end
                        end
                    end
                endcase        
            end
        endcase
    end
end

assign ddr_rd_resp_valid_int = ddr_rd_resp_valid & !reg_ddr_rd_resp_almost_full;

dc_fifo_wrapper input_fifo (
    .in_clk            (clk_rxmac),    
    .in_reset_n        (!rst),      
    .out_clk           (clk_datamover),    
    .out_reset_n       (!rst),      
    .in_data           (stats_rx_data),           
    .in_valid          (stats_rx_valid),          
    .in_ready          (stats_rx_ready),           
    .in_startofpacket  (stats_rx_startofpacket),  
    .in_endofpacket    (stats_rx_endofpacket),
    .in_empty          (stats_rx_empty), 
    .out_data          (top_in_data),          
    .out_valid         (top_in_valid),         
    .out_ready         (1'b1),         
    .out_startofpacket (top_in_startofpacket), 
    .out_endofpacket   (top_in_endofpacket),   
    .out_empty         (top_in_empty)          
);


top top_inst (
    //clk & rst
    .clk                          (clk_user),            
    .rst                          (rst),       
    .clk_high                     (clk_user_high),            
    .clk_datamover                (clk_datamover),            
    .rst_datamover                (rst_datamover),       
    .clk_pcie                     (clk_pcie),            
    .rst_pcie                     (rst),       
    //Ethernet in & out data      
    .in_data                      (reg_top_in_data),           
    .in_valid                     (reg_top_in_valid),          
    .in_sop                       (reg_top_in_startofpacket),  
    .in_eop                       (reg_top_in_endofpacket),
    .in_empty                     (reg_top_in_empty),  
    .reg_out_data                 (top_out_data),          
    .reg_out_valid                (top_out_valid),         
    .out_almost_full              (reg_top_out_almost_full),         
    .reg_out_sop                  (top_out_startofpacket), 
    .reg_out_eop                  (top_out_endofpacket),   
    .reg_out_empty                (top_out_empty), 
    //PCIe    
    .reg_pcie_rb_wr_data          (pcie_rb_wr_data),           
    .reg_pcie_rb_wr_addr          (pcie_rb_wr_addr),          
    .reg_pcie_rb_wr_en            (pcie_rb_wr_en),  
    .pcie_rb_wr_base_addr         (reg_pcie_rb_wr_base_addr),  
    .pcie_rb_almost_full          (reg_pcie_rb_almost_full),          
    .reg_pcie_rb_update_valid     (pcie_rb_update_valid),
    .reg_pcie_rb_update_size      (pcie_rb_update_size),
    .disable_pcie                 (reg_disable_pcie),
    .pdumeta_cpu_data             (reg_pdumeta_cpu_data),
    .pdumeta_cpu_valid            (reg_pdumeta_cpu_valid),
    .reg_pdumeta_cnt              (pdumeta_cnt),
    //DRAM
    .reg_ddr_wr_req_data          (ddr_wr_req_data),
    .reg_ddr_wr_req_valid         (ddr_wr_req_valid),
    .ddr_wr_req_almost_full       (reg_ddr_wr_req_almost_full),
    .reg_ddr_rd_req_data          (ddr_rd_req_data),
    .reg_ddr_rd_req_valid         (ddr_rd_req_valid),
    .ddr_rd_req_almost_full       (reg_ddr_rd_req_almost_full),
    .ddr_rd_resp_data             (reg_ddr_rd_resp_data),
    .ddr_rd_resp_valid            (reg_ddr_rd_resp_valid),
    .reg_ddr_rd_resp_almost_full  (ddr_rd_resp_almost_full),
    //eSRAM
    .reg_esram_pkt_buf_wren       (esram_pkt_buf_wren),
    .reg_esram_pkt_buf_wraddress  (esram_pkt_buf_wraddress),
    .reg_esram_pkt_buf_wrdata     (esram_pkt_buf_wrdata),
    .reg_esram_pkt_buf_rden       (esram_pkt_buf_rden),
    .reg_esram_pkt_buf_rdaddress  (esram_pkt_buf_rdaddress),
    .esram_pkt_buf_rd_valid       (reg_esram_pkt_buf_rd_valid),
    .esram_pkt_buf_rddata         (reg_esram_pkt_buf_rddata),
    //JTAG
    .clk_status                   (clk_status),
    .status_addr                  (s_addr),
    .status_read                  (s_read),
    .status_write                 (s_write),
    .status_writedata             (s_writedata),
    .status_readdata              (top_readdata),
    .status_readdata_valid        (top_readdata_valid)
);

hyper_pipe_root reg_io_inst (
    //clk & rst
    .clk                    (clk_user),            
    .rst                    (rst),
    .clk_datamover          (clk_datamover),            
    .rst_datamover          (rst_datamover),
    .clk_pcie               (clk_pcie),            
    .rst_pcie               (rst),            
    //Ethernet in & out data
    .in_data                (top_in_data),           
    .in_valid               (top_in_valid),          
    .in_sop                 (top_in_startofpacket),  
    .in_eop                 (top_in_endofpacket),
    .in_empty               (top_in_empty),  
    .out_data               (top_out_data),          
    .out_valid              (top_out_valid),         
    .out_almost_full        (top_out_almost_full),         
    .out_sop                (top_out_startofpacket), 
    .out_eop                (top_out_endofpacket),   
    .out_empty              (top_out_empty), 
    //PCIe    
    .pcie_rb_wr_data        (pcie_rb_wr_data),           
    .pcie_rb_wr_addr        (pcie_rb_wr_addr),          
    .pcie_rb_wr_en          (pcie_rb_wr_en),  
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),  
    .pcie_rb_almost_full    (pcie_rb_almost_full),          
    .pcie_rb_update_valid   (pcie_rb_update_valid),
    .pcie_rb_update_size    (pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
`ifdef SIM
    .pdumeta_cpu_data       (sim_pdumeta_cpu_data),
    .pdumeta_cpu_valid      (sim_pdumeta_cpu_valid),
`else 
    .pdumeta_cpu_data       (pdumeta_cpu_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_valid),
`endif
    .pdumeta_cnt            (pdumeta_cnt),
    //DRAM
    .ddr_wr_req_data        (ddr_wr_req_data),
    .ddr_wr_req_valid       (ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (ddr_rd_req_data),
    .ddr_rd_req_valid       (ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_valid_int),
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
    .reg_in_data                (reg_top_in_data),           
    .reg_in_valid               (reg_top_in_valid),          
    .reg_in_sop                 (reg_top_in_startofpacket),  
    .reg_in_eop                 (reg_top_in_endofpacket),
    .reg_in_empty               (reg_top_in_empty),  
    .reg_out_data               (reg_top_out_data),          
    .reg_out_valid              (reg_top_out_valid),         
    .reg_out_almost_full        (reg_top_out_almost_full),         
    .reg_out_sop                (reg_top_out_startofpacket), 
    .reg_out_eop                (reg_top_out_endofpacket),   
    .reg_out_empty              (reg_top_out_empty), 
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


dc_fifo_wrapper_infill out_fifo0 (
    .in_clk            (clk_user),    
    .in_reset_n        (!rst),      
    .out_clk           (clk_txmac),    
    .out_reset_n       (!rst),      
    .in_csr_address    (out_fifo0_in_csr_address),
    .in_csr_read       (out_fifo0_in_csr_read),
    .in_csr_write      (out_fifo0_in_csr_write),
    .in_csr_readdata   (out_fifo0_in_csr_readdata),
    .in_csr_writedata  (out_fifo0_in_csr_writedata),
    .in_data           (reg_top_out_data),           
    .in_valid          (reg_top_out_valid),          
    .in_ready          (),           
    .in_startofpacket  (reg_top_out_startofpacket),  
    .in_endofpacket    (reg_top_out_endofpacket),
    .in_empty          (reg_top_out_empty), 
    .out_data          (l8_tx_data),          
    .out_valid         (l8_tx_valid),         
    .out_ready         (l8_tx_ready),         
    .out_startofpacket (l8_tx_startofpacket), 
    .out_endofpacket   (l8_tx_endofpacket),   
    .out_empty         (l8_tx_empty)          
);

dc_back_pressure #(
    .FULL_LEVEL(490)
)
dc_bp_out_fifo0 (
    .clk            (clk_user),
    .rst            (rst),
    .csr_address    (out_fifo0_in_csr_address),
    .csr_read       (out_fifo0_in_csr_read),
    .csr_write      (out_fifo0_in_csr_write),
    .csr_readdata   (out_fifo0_in_csr_readdata),
    .csr_writedata  (out_fifo0_in_csr_writedata),
    .almost_full    (top_out_almost_full)
);

stats stats(
    .arst(rst),

    .clk_tx(clk_txmac),
    .tx_ready(l8_tx_ready),
    .tx_valid(l8_tx_valid),
    .tx_data(l8_tx_data),
    .tx_sop(l8_tx_startofpacket),
    .tx_eop(l8_tx_endofpacket),
    .tx_empty(l8_tx_empty),

    .clk_rx(clk_rxmac),
    .rx_sop(l8_rx_startofpacket),
    .rx_eop(l8_rx_endofpacket),
    .rx_empty(l8_rx_empty),
    .rx_data(l8_rx_data),
    .rx_valid(l8_rx_valid),

    .rx_ready(stats_rx_ready),
    .o_rx_sop(stats_rx_startofpacket),
    .o_rx_eop(stats_rx_endofpacket),
    .o_rx_empty(stats_rx_empty),
    .o_rx_data(stats_rx_data),
    .o_rx_valid(stats_rx_valid),

    .clk_status(clk_status),
    .status_addr(s_addr),
    .status_read(s_read),
    .status_write(s_write),
    .status_writedata(s_writedata),
    .status_readdata(s_readdata),
    .status_readdata_valid(s_readdata_valid)
);

pcie_top pcie (
    .refclk_clk             (1'b0),                              //         refclk.clk
    .pcie_rstn_npor         (1'b1),                          //      pcie_rstn.npor
    .pcie_rstn_pin_perst    (1'b0),                     //               .pin_perst
    .xcvr_rx_in0            (1'b0),                             //           xcvr.rx_in0
    .xcvr_rx_in1            (1'b0),                             //               .rx_in1
    .xcvr_rx_in2            (1'b0),                             //               .rx_in2
    .xcvr_rx_in3            (1'b0),                             //               .rx_in3
    .xcvr_rx_in4            (1'b0),                             //               .rx_in4
    .xcvr_rx_in5            (1'b0),                             //               .rx_in5
    .xcvr_rx_in6            (1'b0),                             //               .rx_in6
    .xcvr_rx_in7            (1'b0),                             //               .rx_in7
    .xcvr_rx_in8            (1'b0),                             //               .rx_in8
    .xcvr_rx_in9            (1'b0),                             //               .rx_in9
    .xcvr_rx_in10           (1'b0),                            //               .rx_in10
    .xcvr_rx_in11           (1'b0),                            //               .rx_in11
    .xcvr_rx_in12           (1'b0),                            //               .rx_in12
    .xcvr_rx_in13           (1'b0),                            //               .rx_in13
    .xcvr_rx_in14           (1'b0),                            //               .rx_in14
    .xcvr_rx_in15           (1'b0),                            //               .rx_in15
    .xcvr_tx_out0           (),                            //               .tx_out0
    .xcvr_tx_out1           (),                            //               .tx_out1
    .xcvr_tx_out2           (),                            //               .tx_out2
    .xcvr_tx_out3           (),                            //               .tx_out3
    .xcvr_tx_out4           (),                            //               .tx_out4
    .xcvr_tx_out5           (),                            //               .tx_out5
    .xcvr_tx_out6           (),                            //               .tx_out6
    .xcvr_tx_out7           (),                            //               .tx_out7
    .xcvr_tx_out8           (),                            //               .tx_out8
    .xcvr_tx_out9           (),                            //               .tx_out9
    .xcvr_tx_out10          (),                           //               .tx_out10
    .xcvr_tx_out11          (),                           //               .tx_out11
    .xcvr_tx_out12          (),                           //               .tx_out12
    .xcvr_tx_out13          (),                           //               .tx_out13
    .xcvr_tx_out14          (),                           //               .tx_out14
    .xcvr_tx_out15          (),                           //               .tx_out15
    .pcie_clk               (clk_pcie),
    .pcie_reset_n           (!rst),
    .pcie_rb_wr_data        (reg_pcie_rb_wr_data),           
    .pcie_rb_wr_addr        (reg_pcie_rb_wr_addr),          
    .pcie_rb_wr_en          (reg_pcie_rb_wr_en),  
    .pcie_rb_wr_base_addr   (pcie_rb_wr_base_addr),  
    .pcie_rb_almost_full    (pcie_rb_almost_full),          
    .pcie_rb_update_valid   (reg_pcie_rb_update_valid),
    .pcie_rb_update_size    (reg_pcie_rb_update_size),
    .disable_pcie           (disable_pcie),
    .pdumeta_cpu_data       (pdumeta_cpu_data),
    .pdumeta_cpu_valid      (pdumeta_cpu_valid),
    .pdumeta_cnt            (reg_pdumeta_cnt),
    .clk_status             (clk_status),
    .status_addr            (s_addr),
    .status_read            (s_read),
    .status_write           (s_write),
    .status_writedata       (s_writedata),
    .status_readdata        (pcie_readdata),
    .status_readdata_valid  (pcie_readdata_valid)
);

dram_wrapper dram_check_pkt_buffer(
    .emif_reset_n           (emif_reset_n),
    .emif_clk               (clk_emif),
    .clk                    (clk_pcie),
    .rst                    (rst),
    .ddr_wr_req_data        (reg_ddr_wr_req_data),
    .ddr_wr_req_valid       (reg_ddr_wr_req_valid),
    .ddr_wr_req_almost_full (ddr_wr_req_almost_full),
    .ddr_rd_req_data        (reg_ddr_rd_req_data),
    .ddr_rd_req_valid       (reg_ddr_rd_req_valid),
    .ddr_rd_req_almost_full (ddr_rd_req_almost_full),
    .ddr_rd_resp_data       (ddr_rd_resp_data),
    .ddr_rd_resp_valid      (ddr_rd_resp_valid),
    .ddr_rd_resp_ready      (!reg_ddr_rd_resp_almost_full),
    //JTAG
    .clk_status                   (clk_status),
    .status_addr                  (s_addr),
    .status_read                  (s_read),
    .status_write                 (s_write),
    .status_writedata             (s_writedata),
    .status_readdata              (dram_readdata),
    .status_readdata_valid        (dram_readdata_valid)
);

esram_wrapper esram_pkt_buffer(
    .clk_esram_ref  (clk_esram_ref), //100 MHz
    .esram_pll_lock (esram_pll_lock), 
    .clk_esram      (clk_datamover), //200 MHz
    .wren           (reg_esram_pkt_buf_wren),
    .wraddress      (reg_esram_pkt_buf_wraddress),
    .wrdata         (reg_esram_pkt_buf_wrdata),
    .rden           (reg_esram_pkt_buf_rden),
    .rdaddress      (reg_esram_pkt_buf_rdaddress),
    .rd_valid       (esram_pkt_buf_rd_valid),
    .rddata         (esram_pkt_buf_rddata)
);

endmodule
