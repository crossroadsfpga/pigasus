`include "./src/struct_s.sv"
module stats #(
    parameter STATS_REG = STATS_0_REG
   )(
    input   logic                       arst,

    input   logic                       clk_tx,
    input   logic                       tx_ready,
    input  logic                        tx_valid,
    input  logic   [511:0]              tx_data,
    input  logic                        tx_sop,
    input  logic                        tx_eop,
    input  logic   [5:0]                tx_empty,
    output logic   [511:0]              o_tx_data,

    input   logic                       clk_rx,
    input   logic                       rx_sop,
    input   logic                       rx_eop,
    input   logic   [5:0]               rx_empty,
    input   logic   [511:0]             rx_data,
    input   logic                       rx_valid,
    input   logic                       rx_ready,

    output   logic                      o_rx_sop,
    output   logic                      o_rx_eop,
    output   logic   [5:0]              o_rx_empty,
    output   logic   [511:0]            o_rx_data,
    output   logic                      o_rx_valid,
    // status register bus
    input   logic                       clk_status,
    input   logic   [29:0]              status_addr,
    input   logic                       status_read,
    input   logic                       status_write,
    input   logic   [31:0]              status_writedata,
    output  logic   [31:0]              status_readdata,
    output  logic                       status_readdata_valid
);

    localparam TRACKER_AWIDTH = 9;
    localparam TRACKER_DWIDTH = 32;
    localparam TRACKER_DEPTH = 512;


    logic [STAT_AWIDTH-1:0]     status_addr_sel_r = 0;
    logic [7:0]     status_addr_r = 0;

    logic           status_read_r = 0;
    logic           status_write_r = 0;
    logic [31:0]    status_writedata_r = 0;
    logic [31:0]    scratch = 0;

    logic [31:0] reg_ctrl;
    logic [3:0] delay_cnt;
    logic clear;
    logic rst_sync_0;
    logic rst_sync_1;
    logic rst_sync_2;

    //RX
    //logic rx_rst_sync_0;
    //logic rx_rst_sync_1;
    //logic rx_rst_sync_2;

    logic [31:0] rx_reg_ctrl_0;
    logic [31:0] rx_reg_ctrl_1;
    logic [31:0] rx_reg_ctrl_rx;

    logic [31:0] rx_stats;
    logic [31:0] rx_stats_0;
    logic [31:0] rx_stats_1;
    logic [31:0] rx_stats_rx;

    logic [31:0] rx_max_flit;
    logic [31:0] rx_max_flit_0;
    logic [31:0] rx_max_flit_1;
    logic [31:0] rx_max_flit_rx;

    logic [31:0] rx_cycle;
    logic [31:0] rx_cycle_0;
    logic [31:0] rx_cycle_1;
    logic [31:0] rx_cycle_rx;

    logic [31:0] rx_flit;
    logic [31:0] rx_flit_0;
    logic [31:0] rx_flit_1;
    logic [31:0] rx_flit_rx;

    logic [31:0] rx_pkt;
    logic [31:0] rx_pkt_0;
    logic [31:0] rx_pkt_1;
    logic [31:0] rx_pkt_rx;

    logic [31:0] rx_byte;
    logic [31:0] rx_byte_0;
    logic [31:0] rx_byte_1;
    logic [31:0] rx_byte_rx;

    logic [31:0] rx_max_pkt;
    logic [31:0] rx_max_pkt_0;
    logic [31:0] rx_max_pkt_1;
    logic [31:0] rx_max_pkt_rx;

    logic [31:0] rx_warmup_pkt;
    logic [31:0] rx_warmup_pkt_0;
    logic [31:0] rx_warmup_pkt_1;
    logic [31:0] rx_warmup_pkt_rx;

    logic rx_clear;
    logic rx_busy;

    logic [31:0] rx_pkt_cnt;
    logic [31:0] rx_pkt_cnt_0;
    logic [31:0] rx_pkt_cnt_1;
    logic [31:0] rx_pkt_cnt_status;
    logic [31:0] o_rx_pkt_cnt;
    logic [31:0] o_rx_pkt_cnt_0;
    logic [31:0] o_rx_pkt_cnt_1;
    logic [31:0] o_rx_pkt_cnt_status;
    logic [31:0] rx_nf_pkt_cnt;
    logic [31:0] rx_nf_pkt_cnt_0;
    logic [31:0] rx_nf_pkt_cnt_1;
    logic [31:0] rx_nf_pkt_cnt_status;

    //TX
    //logic tx_rst_sync_0;
    //logic tx_rst_sync_1;
    //logic tx_rst_sync_2;

    logic [31:0] tx_reg_ctrl_0;
    logic [31:0] tx_reg_ctrl_1;
    logic [31:0] tx_reg_ctrl_tx;

    logic [31:0] tx_stats;
    logic [31:0] tx_stats_0;
    logic [31:0] tx_stats_1;
    logic [31:0] tx_stats_tx;

    logic [31:0] tx_max_flit;
    logic [31:0] tx_max_flit_0;
    logic [31:0] tx_max_flit_1;
    logic [31:0] tx_max_flit_tx;

    logic [31:0] tx_cycle;
    logic [31:0] tx_cycle_0;
    logic [31:0] tx_cycle_1;
    logic [31:0] tx_cycle_tx;

    logic [31:0] tx_flit;
    logic [31:0] tx_flit_0;
    logic [31:0] tx_flit_1;
    logic [31:0] tx_flit_tx;

    logic [31:0] tx_pkt;
    logic [31:0] tx_pkt_0;
    logic [31:0] tx_pkt_1;
    logic [31:0] tx_pkt_tx;

    logic [31:0] tx_byte;
    logic [31:0] tx_byte_0;
    logic [31:0] tx_byte_1;
    logic [31:0] tx_byte_tx;

    logic [31:0] rx_latency;
    logic [31:0] rx_latency_0;
    logic [31:0] rx_latency_1;
    logic [31:0] rx_latency_rx;

    logic [31:0] tx_max_pkt;
    logic [31:0] tx_max_pkt_0;
    logic [31:0] tx_max_pkt_1;
    logic [31:0] tx_max_pkt_tx;

    logic [31:0] tx_warmup_pkt;
    logic [31:0] tx_warmup_pkt_0;
    logic [31:0] tx_warmup_pkt_1;
    logic [31:0] tx_warmup_pkt_tx;

    logic tx_clear;
    logic tx_busy;
    
    logic [31:0] tx_pkt_cnt;

    logic [31:0] pktID;
    logic [31:0] timestamp;
    logic [31:0] timestamp_1;
    logic [31:0] timestamp_2;
    logic [31:0] timestamp_rx;
    logic [31:0] curr_time;
    logic [31:0] latency;
    logic latency_valid;
    logic [31:0] latency_r;
    logic latency_valid_r;

    logic           rx_sop_r;
    logic           rx_eop_r;
    logic   [5:0]   rx_empty_r;
    logic   [511:0] rx_data_r;
    logic           rx_valid_r;
    logic           rx_sop_r1;
    logic           rx_eop_r1;
    logic   [5:0]   rx_empty_r1;
    logic   [511:0] rx_data_r1;
    logic           rx_valid_r1;
    logic           stop_forwarding;
    logic [47:0] src_mac;
    logic [47:0] src_mac_filter;

    logic           tx_ready_r;
    logic           tx_sop_r;
    logic           tx_eop_r;
    logic   [5:0]   tx_empty_r;
    logic   [511:0] tx_data_r;
    logic           tx_valid_r;


    typedef enum{
        WRITE,
        CLEAR,
        FETCH
    } state_t;
    state_t state;

    logic rx_fetch;
    logic [3:0] rx_scale;

    logic fetch_rd;
    logic fetch_rd_1;
    logic fetch_rd_2;
    logic rx_fetch_rd;
    logic fetch_rd_valid;
    logic fetch_rd_valid_1;
    logic fetch_rd_valid_2;
    logic rx_fetch_rd_valid;

    logic [9:0] fetch_rd_addr;
    logic [9:0] fetch_rd_addr_r;
    logic [9:0] fetch_rd_addr_1;
    logic [9:0] fetch_rd_addr_2;
    logic [9:0] rx_fetch_rd_addr;
    logic [31:0] fetch_rd_data;
    logic [31:0] fetch_rd_data_1;
    logic [31:0] fetch_rd_data_2;
    logic [31:0] rx_fetch_rd_data;

    logic rd;
    logic rd_1;
    logic rd_2;
    logic rd_3;
    logic rd_4;
    logic rd_5;
    logic wr;
    logic [9:0] rd_addr;
    logic [9:0] rd_addr_1;
    logic [9:0] rd_addr_2;
    logic [9:0] rd_addr_3;
    logic [9:0] rd_addr_4;
    logic [9:0] rd_addr_5;
    logic [9:0] wr_addr;
    logic [31:0] rd_data;
    logic [31:0] wr_data;
    logic [31:0] wr_data_1;
    logic [31:0] wr_data_2;
    logic [31:0] wr_data_3;

    logic rd_valid;
    logic rd_valid_1;
    logic rd_valid_2;
    logic rd_valid_3;

    logic [TRACKER_DWIDTH-1:0] tx_tracker_wdata;    
    logic [TRACKER_AWIDTH-1:0] tx_tracker_rdaddr;      
    logic tx_tracker_rden;     
    logic [TRACKER_AWIDTH-1:0] tx_tracker_wraddr;   
    logic tx_tracker_wren;
    logic [TRACKER_DWIDTH-1:0] tx_tracker_rdata;
    logic [TRACKER_AWIDTH-1:0] tx_tracker_rdaddr_r;      
    logic tx_tracker_rden_r;     
    logic tx_tracker_rd_valid;     


    assign clear = reg_ctrl[0];
    assign rx_clear = rx_reg_ctrl_rx[0];

    //always @(posedge clk_status)begin
    //    rst_sync_0 <= arst;
    //    rst_sync_1 <= rst_sync_0;
    //    rst_sync_2 <= rst_sync_1;
    //end

    //RX sync
    always @(posedge clk_rx)begin
        //rx_rst_sync_0 <= arst;
        //rx_rst_sync_1 <= rx_rst_sync_0;
        //rx_rst_sync_2 <= rx_rst_sync_1;

        rx_reg_ctrl_0  <= reg_ctrl;
        rx_reg_ctrl_1  <= rx_reg_ctrl_0;
        rx_reg_ctrl_rx <= rx_reg_ctrl_1;

        rx_max_flit_0  <= rx_max_flit;
        rx_max_flit_1  <= rx_max_flit_0;
        rx_max_flit_rx <= rx_max_flit_1;

        rx_max_pkt_0  <= rx_max_pkt;
        rx_max_pkt_1  <= rx_max_pkt_0;
        rx_max_pkt_rx <= rx_max_pkt_1;

        rx_warmup_pkt_0  <= rx_warmup_pkt;
        rx_warmup_pkt_1  <= rx_warmup_pkt_0;
        rx_warmup_pkt_rx <= rx_warmup_pkt_1;

        rx_latency_0  <= rx_latency;
        rx_latency_1  <= rx_latency_0;
        rx_latency_rx <= rx_latency_1;
    end
    assign rx_scale = rx_latency_rx[5:1];
    assign rx_fetch = rx_latency_rx[0];


    always @(posedge clk_status)begin
        rx_stats_0 <= rx_stats_rx;
        rx_stats_1 <= rx_stats_0;
        rx_stats   <= rx_stats_1;

        rx_cycle_0 <= rx_cycle_rx;
        rx_cycle_1 <= rx_cycle_0;
        rx_cycle   <= rx_cycle_1;

        rx_flit_0  <= rx_flit_rx;
        rx_flit_1  <= rx_flit_0;
        rx_flit    <= rx_flit_1;

        rx_pkt_0  <= rx_pkt_rx;
        rx_pkt_1  <= rx_pkt_0;
        rx_pkt    <= rx_pkt_1;

        rx_byte_0  <= rx_byte_rx;
        rx_byte_1  <= rx_byte_0;
        rx_byte    <= rx_byte_1;

        rx_pkt_cnt_0 <= rx_pkt_cnt;
        rx_pkt_cnt_1 <= rx_pkt_cnt_0;
        rx_pkt_cnt_status <= rx_pkt_cnt_1;

        o_rx_pkt_cnt_0 <= o_rx_pkt_cnt;
        o_rx_pkt_cnt_1 <= o_rx_pkt_cnt_0;
        o_rx_pkt_cnt_status <= o_rx_pkt_cnt_1;

        rx_nf_pkt_cnt_0 <= rx_nf_pkt_cnt;
        rx_nf_pkt_cnt_1 <= rx_nf_pkt_cnt_0;
        rx_nf_pkt_cnt_status <= rx_nf_pkt_cnt_1;
    end

    assign tx_clear = tx_reg_ctrl_tx[0];

    //TX sync
    always @(posedge clk_tx)begin
        //tx_rst_sync_0 <= arst;
        //tx_rst_sync_1 <= tx_rst_sync_0;
        //tx_rst_sync_2 <= tx_rst_sync_1;

        tx_reg_ctrl_0  <= reg_ctrl;
        tx_reg_ctrl_1  <= tx_reg_ctrl_0;
        tx_reg_ctrl_tx <= tx_reg_ctrl_1;

        tx_max_flit_0  <= tx_max_flit;
        tx_max_flit_1  <= tx_max_flit_0;
        tx_max_flit_tx <= tx_max_flit_1;


        tx_max_pkt_0  <= tx_max_pkt;
        tx_max_pkt_1  <= tx_max_pkt_0;
        tx_max_pkt_tx <= tx_max_pkt_1;

        tx_warmup_pkt_0  <= tx_warmup_pkt;
        tx_warmup_pkt_1  <= tx_warmup_pkt_0;
        tx_warmup_pkt_tx <= tx_warmup_pkt_1;
    end

    always @(posedge clk_status)begin
        tx_stats_0 <= tx_stats_tx;
        tx_stats_1 <= tx_stats_0;
        tx_stats   <= tx_stats_1;

        tx_cycle_0 <= tx_cycle_tx;
        tx_cycle_1 <= tx_cycle_0;
        tx_cycle   <= tx_cycle_1;

        tx_flit_0  <= tx_flit_tx;
        tx_flit_1  <= tx_flit_0;
        tx_flit    <= tx_flit_1;

        tx_pkt_0  <= tx_pkt_tx;
        tx_pkt_1  <= tx_pkt_0;
        tx_pkt    <= tx_pkt_1;

        tx_byte_0  <= tx_byte_tx;
        tx_byte_1  <= tx_byte_0;
        tx_byte    <= tx_byte_1;
    end


    ///////////////////////////
    //Read and Write registers
    //////////////////////////
    always @(posedge clk_status) begin
        status_addr_r           <= status_addr[7:0];
        status_addr_sel_r       <= status_addr[29:30-STAT_AWIDTH];

        status_read_r           <= status_read;
        status_write_r          <= status_write;
        status_writedata_r      <= status_writedata;
        status_readdata_valid   <= 1'b0;
        status_readdata         <= status_readdata;

        //fetch_rd <= status_read_r & (status_addr_sel_r == LATENCY_HIST);
        //fetch_rd_addr_r         <= status_addr[9:0];

        //tx_tracker_rden <= status_read_r & (status_addr_sel_r == TX_TRACK);
        //tx_tracker_rdaddr_r         <= status_addr[TRACKER_AWIDTH-1:0];

        if (status_read_r) begin
            if (status_addr_sel_r == STATS_REG) begin
                status_readdata_valid <= 1'b1;
                case (status_addr_r)
                    8'd0  : status_readdata <= scratch;
                    8'd1  : status_readdata <= reg_ctrl;
                    8'd2  : status_readdata <= rx_stats;
                    8'd3  : status_readdata <= rx_max_flit;//Max flits
                    8'd4  : status_readdata <= rx_cycle;
                    8'd5  : status_readdata <= rx_flit;//flit recieved
                    8'd6  : status_readdata <= rx_pkt;//flit recieved
                    8'd7  : status_readdata <= rx_byte;//flit recieved
                    8'd9  : status_readdata <= rx_max_pkt;
                    8'd10 : status_readdata <= rx_warmup_pkt;
                    8'd11 : status_readdata <= rx_pkt_cnt_status;
                    8'd12 : status_readdata <= o_rx_pkt_cnt_status;
                    8'd13 : status_readdata <= rx_nf_pkt_cnt_status;

                    8'd22  : status_readdata <= tx_stats;
                    8'd23  : status_readdata <= tx_max_flit;//Max flits
                    8'd24  : status_readdata <= tx_cycle;
                    8'd25  : status_readdata <= tx_flit;//flit recieved
                    8'd26  : status_readdata <= tx_pkt;//flit recieved
                    8'd27  : status_readdata <= tx_byte;//flit recieved
                    8'd28  : status_readdata <= rx_latency;
                    8'd29  : status_readdata <= tx_max_pkt;
                    8'd30  : status_readdata <= tx_warmup_pkt;

                    default : status_readdata <= 32'h123;
                endcase
            //read latency
            //end else if (status_addr_sel_r == LATENCY_HIST) begin
            //    fetch_rd_addr <= fetch_rd_addr_r;
            //end else if (status_addr_sel_r == TX_TRACK) begin
            //    tx_tracker_rdaddr <= tx_tracker_rdaddr_r;
            end
        end

        if (fetch_rd_valid)begin
            status_readdata <= fetch_rd_data;
            status_readdata_valid <= 1;
        //end else if (tx_tracker_rd_valid) begin
        //    status_readdata <= tx_tracker_rdata;
        //    status_readdata_valid <= 1;
        end

        if (status_write_r) begin
            if (status_addr_sel_r == STATS_REG) begin
                case (status_addr_r)
                    8'd0  : scratch <= status_writedata_r;
                    8'd1  : reg_ctrl <= status_writedata_r;

                    8'd3  : rx_max_flit <= status_writedata_r;
                    8'd9  : rx_max_pkt <= status_writedata_r;
                    8'd10 : rx_warmup_pkt <= status_writedata_r;

                    8'd23  : tx_max_flit <= status_writedata_r;
                    8'd28  : rx_latency  <= status_writedata_r;
                    8'd29  : tx_max_pkt  <= status_writedata_r;
                    8'd30  : tx_warmup_pkt  <= status_writedata_r;

                endcase
            end
        end

        if (clear) begin
            scratch <= 0;
            rx_max_flit <= 0;
            tx_max_flit <= 0;
            rx_max_pkt <= 0;
            tx_max_pkt <= 0;
            rx_warmup_pkt <= 0;
            tx_warmup_pkt <= 0;
        end
    end

    ///////////////////////////
    //rx related registers
    //////////////////////////
    
    always @(posedge clk_rx)begin
        if(rx_clear | arst)begin
            rx_stats_rx <= 0;
            rx_cycle_rx <= 0;
            rx_flit_rx <= 0;
            rx_busy <= 0;
            rx_pkt_rx <= 0;
            rx_byte_rx <= 0;
            rx_pkt_cnt <= 0;
        end else begin
            //done
            if ((rx_pkt_cnt > rx_warmup_pkt_rx) & (rx_pkt_cnt <= rx_max_pkt_rx))begin
                rx_busy <= 1'b1;
                if(rx_valid_r)begin
                    //rx_byte_rx <= rx_byte_rx + 8'd64 - rx_empty;
                    rx_flit_rx <= rx_flit_rx + 1'b1;
                    if(rx_eop_r)begin
                        rx_pkt_rx <= rx_pkt_rx + 1'b1;
                    end
                end
            end else begin
                rx_busy <= 1'b0;
            end

            if ((rx_pkt_cnt == rx_max_pkt_rx) & (rx_max_pkt_rx != 0))begin
                rx_stats_rx <= 32'b1;
            end

            if(rx_busy)begin
                rx_cycle_rx <= rx_cycle_rx + 1'b1;
            end

            if(rx_valid_r & rx_eop_r)begin
                rx_pkt_cnt <= rx_pkt_cnt + 1'b1;
            end

        end


        if(o_rx_valid & o_rx_eop)begin
            o_rx_pkt_cnt <= o_rx_pkt_cnt + 1'b1;
        end

        if(rx_valid & rx_eop) begin
            rx_nf_pkt_cnt <= rx_nf_pkt_cnt + 1'b1;
        end
    end

    always @(posedge clk_rx)begin
        if(rx_clear | arst)begin
            rx_valid_r1 <= 0;
            rx_sop_r1 <= 0;
            rx_eop_r1 <= 0;
            rx_empty_r1 <= 0;
            o_rx_valid <= 0;
            o_rx_sop <= 0;
            o_rx_eop <= 0;
            o_rx_empty <= 0;
        end else begin
            rx_valid_r1 <= rx_valid_r;
            rx_sop_r1 <= rx_sop_r;
            rx_eop_r1 <= rx_eop_r;
            rx_empty_r1 <= rx_empty_r;
            o_rx_valid <= rx_valid_r1;
            o_rx_sop <= rx_sop_r1;
            o_rx_eop <= rx_eop_r1;
            o_rx_empty <= rx_empty_r1;
        end 

        //if(rx_sop_r)begin
        //    //o_rx_data <= {rx_data[511:480],timestamp,rx_data[447:0]};
        //    //o_rx_data <= {32'b0,timestamp,rx_data[447:0]};
        //    rx_data_r1 <= {rx_pkt_cnt,timestamp,rx_data_r[447:0]};
        //end else begin
        //    rx_data_r1 <= rx_data_r;
        //end
        rx_data_r1 <= rx_data_r;

        o_rx_data <= rx_data_r1;
    end

    //Filter out src_mac  
    assign src_mac = rx_data[463:416];
    assign src_mac_filter = 48'hb8599f0b3bd8; 

    always @(posedge clk_rx)begin
        if(rx_clear | arst)begin
            rx_valid_r <= 0;
            rx_sop_r <= 0;
            rx_eop_r <= 0;
            rx_empty_r <= 0;
        end else begin
            if (rx_valid)begin
                if(rx_sop) begin
                    if (src_mac==src_mac_filter)begin
                        rx_valid_r <= 1'b0;
                        if(rx_eop)begin
                            stop_forwarding <= 1'b0;
                        end else begin
                            stop_forwarding <= 1'b1;
                        end
                    end else begin
                        stop_forwarding <= 1'b0;
                        rx_valid_r <= 1'b1;
                    end

                //body
                end else begin
                    if (rx_eop)begin
                        stop_forwarding <= 1'b0;
                    end
                    rx_valid_r <= !stop_forwarding;
                end
            end else begin
                rx_valid_r <= 1'b0;
            end
            rx_sop_r <= rx_sop;
            rx_eop_r <= rx_eop;
            rx_empty_r <= rx_empty;
        end
        rx_data_r <= rx_data;
    end

    ///////////////////////////
    //tx related registers
    //////////////////////////

    always @(posedge clk_tx)begin
        tx_valid_r <= tx_valid;
        tx_sop_r <= tx_sop;
        tx_eop_r <= tx_eop;
        tx_empty_r <= tx_empty;
        tx_ready_r <= tx_ready;
        tx_data_r <= tx_data;
    end


    always @(posedge clk_tx)begin
        if(tx_clear | arst)begin
            tx_stats_tx <= 0;
            tx_cycle_tx <= 0;
            tx_flit_tx <= 0;
            tx_busy <= 0;
            tx_pkt_tx <= 0;
            tx_byte_tx <= 0;
            tx_pkt_cnt <= 0;
        end else begin
            //done
            if ((tx_pkt_cnt > tx_warmup_pkt_tx) & (tx_pkt_cnt <= tx_max_pkt_tx))begin
                tx_busy <= 1'b1;
                if(tx_valid_r & tx_ready_r)begin
                    //tx_byte_tx <= tx_byte_tx + 8'd64 - tx_empty;
                    tx_flit_tx <= tx_flit_tx + 1'b1;
                    if(tx_eop_r)begin
                        tx_pkt_tx <= tx_pkt_tx + 1'b1;
                    end
                end
            end else begin
                tx_busy <= 1'b0;
            end

            if ((tx_pkt_cnt == tx_max_pkt_tx) & (tx_max_pkt_tx != 0))begin
                tx_stats_tx <= 32'b1;
            end

            if(tx_busy)begin
                tx_cycle_tx <= tx_cycle_tx + 1'b1;
            end

            if(tx_valid_r & tx_eop_r & tx_ready_r)begin
                tx_pkt_cnt <= tx_pkt_cnt + 1'b1;
            end
        end
    end

/*
    ///////////////////////////
    //tx tracker
    //////////////////////////
    //tracker first 512 tx pkts. 
    always @(posedge clk_tx)begin
        if(tx_clear | arst)begin
            tx_tracker_wren <= 1'b0;
            tx_tracker_wraddr <= 0;
        end else begin
            tx_tracker_wren <= 1'b0;
            if (tx_tracker_wraddr != {TRACKER_AWIDTH{1'b1}})begin
                if(tx_valid_r & tx_sop_r & tx_ready_r)begin
                    tx_tracker_wren <= 1'b1;
                end
                if(tx_tracker_wren)begin
                    tx_tracker_wraddr <= tx_tracker_wraddr + 1'b1;
                end
            end
        end

        tx_tracker_wdata <= tx_data_r[511:512-TRACKER_DWIDTH];
    end

    always @(posedge clk_status)begin
        tx_tracker_rden_r <= tx_tracker_rden;
        tx_tracker_rd_valid <= tx_tracker_rden_r;
    end

    ///////////////////////////
    //Latency
    //////////////////////////
    always @(posedge clk_rx)begin
        fetch_rd_1 <= fetch_rd;   
        fetch_rd_2 <= fetch_rd_1;   
        rx_fetch_rd <= fetch_rd_2;   
        fetch_rd_addr_1 <= fetch_rd_addr;   
        fetch_rd_addr_2 <= fetch_rd_addr_1;   
        rx_fetch_rd_addr <= fetch_rd_addr_2;   
    end

    always @(posedge clk_status)begin
        fetch_rd_data_1 <= rx_fetch_rd_data;   
        fetch_rd_data_2 <= fetch_rd_data_1;   
        fetch_rd_data <= fetch_rd_data_2;   
        fetch_rd_valid_1 <= rx_fetch_rd_valid;   
        fetch_rd_valid_2 <= fetch_rd_valid_1;   
        fetch_rd_valid <= fetch_rd_valid_2;   
    end


    always @(posedge clk_tx)begin
        if(arst)begin
            timestamp <= 0;
        end else begin
            timestamp <= timestamp + 1;
        end
    end
    assign o_tx_data = (tx_valid & tx_ready & tx_sop) ? 
        {tx_data[511:480],timestamp,tx_data[447:0]} : tx_data;


    assign curr_time = rx_data_r[479:448];
    always @(posedge clk_rx)begin
        latency_valid <= 0;
        latency <= 0;
        if(rx_valid_r & rx_sop_r)begin
            latency <= timestamp_rx + 3 - curr_time;
            latency_valid <= 1;
        end

        if((latency >> rx_scale)>32'h3ff)begin
            latency_r <= 32'h3ff;
        end else begin
            latency_r <= latency >> rx_scale;
        end
        latency_valid_r <= latency_valid;
    end

    //manage hist
    always @(posedge clk_rx)begin
        if(arst)begin
            wr_data <= 0;
            wr <= 0;
            rd <= 0;
            rd_addr <= 0;
        end else begin
            case(state)
                WRITE:begin
                    //if ((tx_pkt_tx < tx_max_pkt_tx) & (tx_pkt_cnt>=tx_warmup_pkt_tx))begin
                    wr <= 0;
                    rd_addr <= latency_r;
                    rd <= latency_valid_r;

                    rd_1 <= rd;
                    rd_2 <= rd_1;
                    rd_3 <= rd_2;
                    rd_4 <= rd_3;
                    rd_5 <= rd_4;

                    //two cycle delay
                    rd_valid <= rd;
                    rd_valid_1 <= rd_valid;

                    rd_addr_1 <= rd_addr;
                    rd_addr_2 <= rd_addr_1;
                    rd_addr_3 <= rd_addr_2;
                    rd_addr_4 <= rd_addr_3;
                    rd_addr_5 <= rd_addr_4;

                    wr_addr <= rd_addr_2;

                    wr_data_1 <= wr_data;
                    wr_data_2 <= wr_data_1;
                    wr_data_3 <= wr_data_2;
                    if (rd_valid_1)begin
                        if(rd_data != 32'hffffffff) begin
                            if (rd_addr_3 == rd_addr_2) begin
                                wr_data <= wr_data + 1;
                            end else if (rd_addr_4 == rd_addr_2) begin
                                wr_data <= wr_data_1 + 1;
                            end else if (rd_addr_5 == rd_addr_2) begin
                                wr_data <= wr_data_2 + 1;
                            end else begin 
                                wr_data <= rd_data + 1;
                            end
                        end
                        wr <= 1;
                    end
                    if (rx_clear) begin
                        state <= CLEAR;
                        wr_addr <= 0;
                    end else if (rx_fetch)begin
                        state <= FETCH;
                    end
                end
                CLEAR:begin
                    wr <= 1;
                    wr_data <= 0;
                    wr_addr <= wr_addr + 1;
                    if (!rx_clear)begin
                        state <= WRITE;
                    end
                end
                FETCH:begin
                    rd <= rx_fetch_rd;
                    rd_valid_2 <= rd;
                    rd_valid_3 <= rd_valid_2;
                    rx_fetch_rd_valid <= rd_valid_3;
                    rd_addr <= rx_fetch_rd_addr;
                    rx_fetch_rd_data <= rd_data;
                    if (!rx_fetch)begin
                        state <= WRITE;
                    end
                end
                default: state <= WRITE;
            endcase
        end
    end

    bram_core #(
        .BEWIDTH(4),
        .AWIDTH(10),
        .DWIDTH(32),
        .DEPTH(1024)
    )
    latency_hist (
        .address     (rd_addr),    
        .clken       (1'b1),      
        .chipselect  (rd), 
        .write       (1'b0),      
        .readdata    (rd_data),   
        .writedata   (0),  
        .byteenable  ({4{1'b1}}), 
        .address2    (wr_addr), 
        .chipselect2 (wr),  
        .clken2      (1'b1),                                                 
        .write2      (wr),                                                 
        .readdata2   (),     
        .writedata2  (wr_data),                                                 
        .byteenable2 ({4{1'b1}}),                                                 
        .clk         (clk_rx),                             
        .reset       (arst),                   
        .reset_req   (arst)                
    );

    dc_fifo_reg_core  timestamp_sync (
        .wrclock               (clk_tx),               //   input,   width = 1,    clk_in.clk
        .wrreset_n             (!arst),             //   input,   width = 1,  reset_in.reset_n
        .rdclock               (clk_rx),               //   input,   width = 1,   clk_out.clk
        .rdreset_n             (!arst),             //   input,   width = 1, reset_out.reset_n
        .avalonst_sink_valid   (1'b1),   //   input,   width = 1,        in.valid
        .avalonst_sink_data    (timestamp),    //   input,  width = 32,          .data
        .avalonst_source_valid (), //  output,   width = 1,       out.valid
        .avalonst_source_data  (timestamp_rx)   //  output,  width = 32,          .data
    );
*/
/*
    bram_dc_simple2port #(
        .AWIDTH(TRACKER_AWIDTH),
        .DWIDTH(TRACKER_DWIDTH),
        .DEPTH(TRACKER_DEPTH)
    )

    tx_pkt_tracker (
        .data       (tx_tracker_wdata),    
        .rdaddress  (tx_tracker_rdaddr),      
        .rdclock    (clk_status), 
        .rden       (tx_tracker_rden),      
        .wraddress  (tx_tracker_wraddr),   
        .wrclock    (clk_tx),  
        .wren       (tx_tracker_wren), 
        .q          (tx_tracker_rdata)
    );
*/

endmodule
