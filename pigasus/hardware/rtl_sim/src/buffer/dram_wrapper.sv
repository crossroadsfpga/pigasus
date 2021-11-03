`include "./src/struct_s.sv"

module dram_wrapper(
`ifdef BRAM_CHECKPKT_BUF
    input                   emif_reset_n,
    input                   emif_clk,
`else
    input                   CPU_RESETN,

    // EMIF interface
    input   logic           CLK_DDR4_COMP_P,
    output  logic           DDR4_COMP_CLK_P,
    output  logic           DDR4_COMP_CLK_N,
    output  logic [16:0]    DDR4_COMP_A,
    output  logic           DDR4_COMP_ACT_N,
    output  logic [1:0]     DDR4_COMP_BA,
    output  logic           DDR4_COMP_BG0,
    output  logic           DDR4_COMP_BG1,
    output  logic           DDR4_COMP_CKE,
    output  logic           DDR4_COMP_CS_N,
    output  logic           DDR4_COMP_ODT,
    output  logic           DDR4_COMP_RESET_N,
    output  logic           DDR4_COMP_PAR,
    input   logic           DDR4_COMP_ALERT_N,
    inout   logic [8:0]     DDR4_COMP_DQS_P,
    inout   logic [8:0]     DDR4_COMP_DQS_N,
    inout   logic [71:0]    DDR4_COMP_DQ,
    inout   logic [8:0]     DDR4_COMP_DBI_N,
    input   logic           DDR4_COMP_RZQ,
`endif
    input                   clk,
    input                   rst,
    // Write request
    input   ddr_wr_t        ddr_wr_req_data,
    input                   ddr_wr_req_valid,
    output  logic           ddr_wr_req_almost_full,

    // Read request
    input   ddr_rd_t        ddr_rd_req_data,
    input                   ddr_rd_req_valid,
    output  logic           ddr_rd_req_almost_full,

    // Read response
    output  logic [511:0]   ddr_rd_resp_data,
    output  logic           ddr_rd_resp_valid,
    input   logic           ddr_rd_resp_ready,

    // Status register bus
    input   logic           clk_status,
    input   logic [29:0]    status_addr,
    input   logic           status_read,
    input   logic           status_write,
    input   logic [31:0]    status_writedata,
    output  logic [31:0]    status_readdata,
    output  logic           status_readdata_valid
);

`ifdef BRAM_CHECKPKT_BUF
logic                   rden_r1;
`else
logic                   rden_r1;
logic                   emif_reset_n;
logic                   emif_clk;
`endif
logic                   emif_waitrequest_n;
logic                   emif_read;
logic                   emif_write;
logic [26:0]            emif_address;
logic [511:0]           emif_readdata;
logic [511:0]           emif_writedata;
logic [6:0]             emif_burstcount;
logic [63:0]            emif_byteenable;
logic                   emif_readdatavalid;

ddr_wr_t                int_wr_req_data;
logic                   int_wr_req_valid;
logic                   int_wr_req_ready;
logic [31:0]            ddr_wr_req_csr_readdata;

ddr_rd_t                int_rd_req_data;
logic                   int_rd_req_valid;
logic                   int_rd_req_ready;
logic [31:0]            ddr_rd_req_csr_readdata;

ddr_req_t               int_req_data;
logic                   int_req_valid;
logic                   int_req_ready;
ddr_req_t               ddr_req_data;
logic                   ddr_req_valid;
logic                   ddr_req_ready;
logic                   ddr_req_almost_full;
logic [31:0]            ddr_req_csr_readdata;

logic [511:0]           int_rd_resp_data;
logic                   int_rd_resp_valid;
logic [511:0]           int_rd_resp_data_r;
logic                   int_rd_resp_valid_r;
logic                   int_rd_resp_ready;
logic [31:0]            int_rd_resp_csr_readdata;
logic                   int_rd_resp_almost_full;
logic                   int_rd_resp_almost_full_r1;
logic                   ddr_rd_resp_almost_full;

logic [1:0]             arb_req;
logic [1:0]             arb_grant;
logic [1:0]             arb_sop;
logic [1:0]             arb_eop;

logic [31:0]            emif_rd_cnt;
logic [31:0]            emif_wr_cnt;
logic [31:0]            emif_resp_cnt;
logic [31:0]            emif_max_resp;
logic [31:0]            emif_rd_cnt_r1;
logic [31:0]            emif_wr_cnt_r1;
logic [31:0]            emif_resp_cnt_r1;
logic [31:0]            emif_max_resp_r1;
logic [31:0]            emif_rd_cnt_status;
logic [31:0]            emif_wr_cnt_status;
logic [31:0]            emif_resp_cnt_status;
logic [31:0]            emif_max_resp_status;

// JTAG signals
logic [29:0]            status_addr_r;
logic                   status_read_r;
logic                   status_write_r;
logic [31:0]            status_writedata_r;
logic [STAT_AWIDTH-1:0] status_addr_sel_r;

// JTAG
always @(posedge clk_status) begin
    status_addr_r       <= status_addr;
    status_addr_sel_r   <= status_addr[29:30-STAT_AWIDTH];

    status_read_r       <= status_read;
    status_write_r      <= status_write;
    status_writedata_r  <= status_writedata;

    status_readdata_valid <= 0;

    if (status_addr_sel_r == DRAM & status_read_r) begin
        case (status_addr_r[3:0])
            4'd0: status_readdata <= emif_wr_cnt_status;
            4'd1: status_readdata <= emif_rd_cnt_status;
            4'd2: status_readdata <= emif_resp_cnt_status;
            4'd3: status_readdata <= emif_max_resp_status;
            default: status_readdata <= 32'h123456768;
        endcase

        status_readdata_valid <= 1;
    end
end
// Clock crossing
always @(posedge clk_status) begin
    emif_wr_cnt_r1 <= emif_wr_cnt;
    emif_wr_cnt_status <= emif_wr_cnt_r1;
    emif_rd_cnt_r1 <= emif_rd_cnt;
    emif_rd_cnt_status <= emif_rd_cnt_r1;
    emif_resp_cnt_r1 <= emif_resp_cnt;
    emif_resp_cnt_status <= emif_resp_cnt_r1;
    emif_max_resp_r1 <= emif_max_resp;
    emif_max_resp_status <= emif_max_resp_r1;
end
always @(posedge clk) begin
    int_rd_resp_almost_full_r1 <= int_rd_resp_almost_full;
    ddr_rd_resp_almost_full <= int_rd_resp_almost_full_r1;
end

// Arbitration logic
// bit 0 is wr req; bit 1 is rd req
assign arb_req[0] = int_wr_req_valid & !ddr_req_almost_full;
assign arb_req[1] = int_rd_req_valid & !ddr_req_almost_full & !ddr_rd_resp_almost_full;
assign arb_sop[0] = int_wr_req_valid ? int_wr_req_data.sop : 0;
assign arb_sop[1] = int_rd_req_valid ? int_rd_req_data.sop : 0;
assign arb_eop[0] = int_wr_req_valid ? int_wr_req_data.eop : 0;
assign arb_eop[1] = int_rd_req_valid ? int_rd_req_data.eop : 0;

assign int_wr_req_ready = arb_grant[0];
assign int_rd_req_ready = arb_grant[1];

// Read & write path
always @(posedge clk) begin
    if (rst) begin
        ddr_req_valid <= 0;
    end
    else begin
        ddr_req_valid <= 0;
        ddr_req_data.wr <= 0;
        ddr_req_data.addr <= 0;
        case (arb_grant)
            // Wr is selected
            2'b01: begin
                ddr_req_valid <= 1;
                ddr_req_data.wr <= 1;
                ddr_req_data.addr <= int_wr_req_data.addr;
            end
            // Rd is selected
            2'b10: begin
                ddr_req_valid <= 1;
                ddr_req_data.wr <= 0;
                ddr_req_data.addr <= int_rd_req_data.addr;
            end
        endcase
    end
    ddr_req_data.data <= int_wr_req_data.data;
end

// DDR request
assign int_req_ready    = emif_waitrequest_n; // 0 means not ready
assign emif_byteenable  = {64{1'b1}};
assign emif_burstcount  = 1; // Always burst size 1
assign emif_write       = int_req_data.wr & int_req_valid;
assign emif_read        = !int_req_data.wr & int_req_valid;
assign emif_address     = int_req_data.addr;
assign emif_writedata   = int_req_data.data;

always @(posedge emif_clk) begin
    if (!emif_reset_n) begin
        emif_rd_cnt <= 0;
        emif_wr_cnt <= 0;
    end
    else begin
        if (int_req_valid & int_req_ready) begin
            if (!int_req_data.wr) begin
                emif_rd_cnt <= emif_rd_cnt + 1;
            end
            else begin
                emif_wr_cnt <= emif_wr_cnt + 1;
            end
        end
    end
end

// Response path
always @(posedge emif_clk) begin
    if (!emif_reset_n) begin
        int_rd_resp_valid <= 1'b0;
        int_rd_resp_valid_r <= 1'b0;
        emif_resp_cnt <= 0;
        emif_max_resp <= 0;
    end
    else begin
        int_rd_resp_valid <= emif_readdatavalid;
        int_rd_resp_valid_r <= int_rd_resp_valid;
        if (int_rd_resp_valid_r & int_rd_resp_ready) begin
            emif_resp_cnt <= emif_resp_cnt + 1;
        end
        if (emif_max_resp < int_rd_resp_csr_readdata) begin
            emif_max_resp <= int_rd_resp_csr_readdata;
        end
    end
    int_rd_resp_data <= emif_readdata;
    int_rd_resp_data_r <= int_rd_resp_data;
end

`ifdef BRAM_CHECKPKT_BUF
// Fixed read latency 2 cycles
always @(posedge emif_clk) begin
    if (!emif_reset_n) begin
        rden_r1 <= 0;
        emif_readdatavalid <= 0;
    end
    else begin
        rden_r1 <= emif_read;
        emif_readdatavalid <= rden_r1;
    end
end
assign emif_waitrequest_n = 1'b1;

bram_1port #(
    .AWIDTH(9),
    .DWIDTH(512),
    .DEPTH(512)
)
dram_sim (
    .address (emif_address[8:0]),
    .clock   (emif_clk),
    .data    (emif_writedata),
    .rden    (emif_read),
    .wren    (emif_write),
    .q       (emif_readdata)
);
`else
//----------------------------------------------------------------------------------------------------------
// DDR4 example design
//----------------------------------------------------------------------------------------------------------
ed_synth ddr4 (
    .ddr_ref_clk_clk                          (CLK_DDR4_COMP_P),                // ddr_ref_clk.clk
    .emif_s10_0_oct_oct_rzqin                 (DDR4_COMP_RZQ),                  // .oct_rzqin
    .emif_s10_0_mem_mem_ck                    (DDR4_COMP_CLK_P),                // .mem_ck
    .emif_s10_0_mem_mem_ck_n                  (DDR4_COMP_CLK_N),                // .mem_ck_n
    .emif_s10_0_mem_mem_a                     (DDR4_COMP_A),                    // .mem_a
    .emif_s10_0_mem_mem_act_n                 (DDR4_COMP_ACT_N),                // .mem_act_n
    .emif_s10_0_mem_mem_ba                    (DDR4_COMP_BA),                   // .mem_ba
    .emif_s10_0_mem_mem_bg                    ({DDR4_COMP_BG1, DDR4_COMP_BG0}), // .mem_bg
    .emif_s10_0_mem_mem_cke                   (DDR4_COMP_CKE),                  // .mem_cke
    .emif_s10_0_mem_mem_cs_n                  (DDR4_COMP_CS_N),                 // .mem_cs_n
    .emif_s10_0_mem_mem_odt                   (DDR4_COMP_ODT),                  // .mem_odt
    .emif_s10_0_mem_mem_reset_n               (DDR4_COMP_RESET_N),              // .mem_reset_n
    .emif_s10_0_mem_mem_par                   (DDR4_COMP_PAR),                  // .mem_par
    .emif_s10_0_mem_mem_alert_n               (DDR4_COMP_ALERT_N),              // .mem_alert_n
    .emif_s10_0_mem_mem_dqs                   (DDR4_COMP_DQS_P),                // .mem_dqs
    .emif_s10_0_mem_mem_dqs_n                 (DDR4_COMP_DQS_N),                // .mem_dqs_n
    .emif_s10_0_mem_mem_dq                    (DDR4_COMP_DQ),                   // .mem_dq
    .emif_s10_0_mem_mem_dbi_n                 (DDR4_COMP_DBI_N),                // .mem_dbi_n
    .emif_s10_0_emif_usr_reset_n_reset_n      (emif_reset_n),                   // .reset_n
    .emif_s10_0_emif_usr_clk_clk              (emif_clk),                       // .clk
    .emif_s10_0_ctrl_amm_0_waitrequest_n      (emif_waitrequest_n),             // .waitrequest_n
    .emif_s10_0_ctrl_amm_0_read               (emif_read),                      // .read
    .emif_s10_0_ctrl_amm_0_write              (emif_write),                     // .write
    .emif_s10_0_ctrl_amm_0_address            (emif_address),                   // .address
    .emif_s10_0_ctrl_amm_0_readdata           (emif_readdata),                  // .readdata
    .emif_s10_0_ctrl_amm_0_writedata          (emif_writedata),                 // .writedata
    .emif_s10_0_ctrl_amm_0_burstcount         (emif_burstcount),                // .burstcount
    .emif_s10_0_ctrl_amm_0_byteenable         (emif_byteenable),                // .byteenable
    .emif_s10_0_ctrl_amm_0_readdatavalid      (emif_readdatavalid),             // .readdatavalid
    .local_reset_req                          (CPU_RESETN),                     // .local_reset_req
    .local_reset_done                         ()                                // .local_reset_done
);
`endif

///// Input wr req /////
unified_fifo  #(
    .FIFO_NAME        ("[dram_wrapper] ddr_wr_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DDR_WR_WIDTH),
    .FIFO_DEPTH       (512)
) ddr_wr_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (ddr_wr_req_data),
    .in_valid          (ddr_wr_req_valid),
    .in_ready          (),
    .out_data          (int_wr_req_data),
    .out_valid         (int_wr_req_valid),
    .out_ready         (int_wr_req_ready),
    .fill_level        (ddr_wr_req_csr_readdata),
    .almost_full       (ddr_wr_req_almost_full),
    .overflow          ()
);

///// input rd req /////
unified_fifo  #(
    .FIFO_NAME        ("[dram_wrapper] ddr_rd_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DDR_RD_WIDTH),
    .FIFO_DEPTH       (512)
) ddr_rd_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (ddr_rd_req_data),
    .in_valid          (ddr_rd_req_valid),
    .in_ready          (),
    .out_data          (int_rd_req_data),
    .out_valid         (int_rd_req_valid),
    .out_ready         (int_rd_req_ready),
    .fill_level        (ddr_rd_req_csr_readdata),
    .almost_full       (ddr_rd_req_almost_full),
    .overflow          ()
);

//// input ddr req//////
unified_fifo  #(
    .FIFO_NAME        ("[dram_wrapper] ddr_req_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (1),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DDR_REQ_WIDTH),
    .FIFO_DEPTH       (512)
) ddr_req_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (emif_clk),//not used
    .out_reset         (!emif_reset_n),
    .in_data           (ddr_req_data),
    .in_valid          (ddr_req_valid),
    .in_ready          (),
    .out_data          (int_req_data),
    .out_valid         (int_req_valid),
    .out_ready         (int_req_ready),
    .fill_level        (ddr_req_csr_readdata),
    .almost_full       (ddr_req_almost_full),
    .overflow          ()
);

//// output rd resp//////
unified_fifo  #(
    .FIFO_NAME        ("[dram_wrapper] ddr_rd_resp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (1),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (512),
    .FIFO_DEPTH       (512)
) ddr_rd_resp_fifo (
    .in_clk            (emif_clk),
    .in_reset          (emif_rst),
    .out_clk           (clk),//not used
    .out_reset         (rst),
    .in_data           (int_rd_resp_data_r),
    .in_valid          (int_rd_resp_valid_r),
    .in_ready          (int_rd_resp_ready),
    .out_data          (ddr_rd_resp_data),
    .out_valid         (ddr_rd_resp_valid),
    .out_ready         (ddr_rd_resp_ready),
    .fill_level        (int_rd_resp_csr_readdata),
    .almost_full       (int_rd_resp_almost_full),
    .overflow          ()
);

rr_arbiter_pkt #(
    .DWIDTH(2)
)
arb_inst (
    .clk                (clk),
    .rst                (rst),
    .req                (arb_req),
    .grant              (arb_grant),
    .sop                (arb_sop),
    .eop                (arb_eop)
);

endmodule
