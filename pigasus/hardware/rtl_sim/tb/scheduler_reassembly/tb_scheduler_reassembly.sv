`timescale 1 ns/10 ps

`include "../../src/struct_s.sv"
`include "../../src/stats_reg.sv"

module tb_scheduler_reassembly;

`ifndef TEST_CASE
    $error("FAIL: No test case specified");
`else

`ifndef PKT_FILE
$error("FAIL: PKT_FILE not set");
`endif

`ifndef PKT_FILE_NB_LINES
$error("FAIL: PKT_FILE_NB_LINES not set");
`endif

// Input innocent rate (in Gbps)
`ifndef RATE_INNOCENT
$error("FAIL: RATE_INNOCENT not set");
`endif

// Input attack rate (in Gbps)
`ifndef RATE_ATTACK
$error("FAIL: RATE_ATTACK not set");
`endif

// Total input rate (in Gbps)
localparam RATE = (`RATE_INNOCENT + `RATE_ATTACK);

// The time at which we stop profiling is controlled by the
// STOP_DELAY parameter. For tests which perform throughput
// measurement, it's important to stop profiling as soon as
// the input trace is exhausted (i.e., no delay). For other
// tests, we're interested in making sure that the I/O byte
// counts match, in which case we need to run the tests for
// longer to account for processing latency; for the latter
// set of tests, we default to a reasonable delay value.
localparam STOP_DELAY = (
    (`TEST_CASE == "TEST_WSJF_ACA_MITIGATION") ?
    1 : // Min delay for throughput measurement
    20000 // Default delay
);

/**
 * List of tests:
 * ---------------------
 * TEST_FCFS_BASIC_INORDER
 * TEST_FCFS_BASIC_OOO
 * TEST_WSJF_BASIC_INORDER
 * TEST_WSJF_BASIC_OOO
 * TEST_WSJF_ACA_MITIGATION
 */

localparam period = 10;
localparam period_rx = 2.56;
localparam period_tx = 2.56;
localparam period_user = 5;
localparam period_user_high = 2.5;
localparam period_esram_ref = 10;
localparam period_pcie = 4;
localparam period_emif = 3;
localparam data_width = 528;
localparam lo = 0;
localparam hi = `PKT_FILE_NB_LINES;
localparam nf_forward_threshold = 200;

logic                       clk_status;
logic                       clk_rxmac;
logic                       clk_txmac;
logic                       clk_user;
logic                       clk_user_high;
logic                       clk_esram_ref;
logic                       clk_pcie;
logic                       clk_emif;

logic                       rst;
logic                       emif_reset_n;
logic [31:0]                cnt;
logic [31:0]                addr;
logic [data_width-1:0]      arr[lo:hi];

// Ethernet signals
logic  [511:0]              l8_rx_data;
logic  [5:0]                l8_rx_empty;
logic                       l8_rx_valid;
logic                       l8_rx_startofpacket;
logic                       l8_rx_endofpacket;

logic  [511:0]              stats_rx_data;
logic  [5:0]                stats_rx_empty;
logic                       stats_rx_valid;
logic                       stats_rx_startofpacket;
logic                       stats_rx_endofpacket;
logic                       stats_rx_ready;

logic  [511:0]              top_in_data;
logic  [5:0]                top_in_empty;
logic                       top_in_valid;
logic                       top_in_startofpacket;
logic                       top_in_endofpacket;
logic  [511:0]              top_out_data;
logic  [5:0]                top_out_empty;
logic                       top_out_valid;
logic                       top_out_ready;
logic                       top_out_startofpacket;
logic                       top_out_endofpacket;

logic  [511:0]              l8_tx_data;
logic  [5:0]                l8_tx_empty;
logic                       l8_tx_valid;
logic                       l8_tx_startofpacket;
logic                       l8_tx_endofpacket;
logic                       l8_tx_ready;

// PCIE
logic                       disable_pcie;
logic [513:0]               pcie_rb_wr_data;
logic [11:0]                pcie_rb_wr_addr;
logic                       pcie_rb_wr_en;
logic [11:0]                pcie_rb_wr_base_addr;
logic                       pcie_rb_almost_full;
logic                       pcie_rb_update_valid;
logic [11:0]                pcie_rb_update_size;
logic [27:0]                pdumeta_cpu_data;
logic                       pdumeta_cpu_valid;
logic [9:0]                 pdumeta_cnt;

// DRAM signals
logic [547:0]               ddr_wr_req_data;
logic                       ddr_wr_req_valid;
logic                       ddr_wr_req_almost_full;
logic [33:0]                ddr_rd_req_data;
logic                       ddr_rd_req_valid;
logic                       ddr_rd_req_almost_full;
logic [511:0]               ddr_rd_resp_data;
logic                       ddr_rd_resp_valid;
logic                       ddr_rd_resp_almost_full;
logic                       ddr_rd_resp_valid_int;

// eSRAM signals
logic                       esram_pll_lock;
logic                       esram_pkt_buf_wren;
logic [PKTBUF_AWIDTH-1:0]   pkt_buf_wraddress;
logic [PKTBUF_AWIDTH-1:0]   pkt_buf_rdaddress;
logic [519:0]               pkt_buf_wrdata;
logic                       pkt_buf_rden;
logic                       pkt_buf_rd_valid;
logic [519:0]               pkt_buf_rddata;

// JTAG
logic [29:0]                s_addr;
logic                       s_read;
logic                       s_write;
logic [31:0]                s_writedata;
logic [31:0]                s_readdata;
logic                       s_readdata_valid;
logic [31:0]                top_readdata;
logic                       top_readdata_valid;
logic [31:0]                dram_readdata;
logic                       dram_readdata_valid;

logic                       stop;
logic [31:0]                stop_cnt;

logic [3:0]                 tx_cnt;
logic [15:0]                reg_cnt;
logic [15:0]                reg_recv_cnt;

// We send a burst of packets in a window, and
// set the rate by limiting the window size.
logic [7:0]                 rate_cnt;

// Simulated PDU metadata
logic                       sim_pdumeta_cpu_valid;
pdu_metadata_t              sim_pdumeta_cpu_data;
logic [7:0]                 pdumeta_wait_cnt;

// Reassembly profiling
logic                       done_profiling;
logic [63:0]                time_in_num_cycles_end;
logic [63:0]                time_out_num_cycles_end;
logic [63:0]                time_in_num_cycles_start;
logic [63:0]                time_out_num_cycles_start;
logic [63:0]                total_in_reassembler_bytes;
logic [63:0]                total_out_reassembler_bytes;

typedef enum {
    PDUMETA_IDLE,
    PDUMETA_WAIT
} pdumeta_state_t;
pdumeta_state_t pdumeta_state;

typedef enum {
    DISABLE_PCIE,
    WRITE_CTRL,
    ENABLE_PCIE,
    IDLE,
    READ_TOP_REG,
    DONE
} c_state_t;
c_state_t conf_state;

initial clk_rxmac                   = 0;
initial clk_txmac                   = 1;
initial clk_user                    = 0;
initial clk_user_high               = 0;
initial clk_esram_ref               = 0;
initial clk_pcie                    = 0;
initial clk_status                  = 0;
initial l8_tx_ready                 = 0;
initial tx_cnt                      = 0;
initial rst                         = 1;
initial cnt                         = 0;
initial rate_cnt                    = 0;
initial stop                        = 0;
initial stop_cnt                    = 0;

initial done_profiling              = 0;
initial time_in_num_cycles_end      = 0;
initial time_in_num_cycles_start    = 0;
initial time_out_num_cycles_start   = 0;
initial total_in_reassembler_bytes  = 0;
initial total_out_reassembler_bytes = 0;

always #(period) clk_status = ~clk_status;
always #(period_rx) clk_rxmac = ~clk_rxmac;
always #(period_tx) clk_txmac = ~clk_txmac;
always #(period_user) clk_user = ~clk_user;
always #(period_pcie) clk_pcie = ~clk_pcie;
always #(period_user_high) clk_user_high = ~clk_user_high;
always #(period_esram_ref) clk_esram_ref = ~clk_esram_ref;

`ifdef BRAM_CHECKPKT_BUF
assign clk_emif = clk_pcie;
assign emif_reset_n = !rst;
`else
initial clk_emif = 0;
always #(period_emif) clk_emif = ~clk_emif;
initial
begin
    emif_reset_n = 0;
    #20 emif_reset_n = 1;
end
`endif

// Read packet data from ROM
initial begin : init_block
    integer i;
    for (i = lo; i <= hi; i = i + 1) begin
        arr[i] = {((data_width + 1) / 2){2'b0}};
    end
    $readmemh(`PKT_FILE, arr, lo, hi);
end

assign l8_rx_startofpacket = arr[addr][524];
assign l8_rx_endofpacket = arr[addr][520];
assign l8_rx_empty = arr[addr][519:512];
assign l8_rx_data = arr[addr][511:0];

always @(posedge clk_txmac)
begin
    if (tx_cnt < 4'd10) begin
        tx_cnt <= tx_cnt + 1'b1;
    end
    else begin
        tx_cnt <= 0;
        l8_tx_ready <= ~l8_tx_ready;
    end
end

always @(posedge clk_rxmac) begin
    cnt <= cnt + 1;
    if (cnt == 1) begin
        rst <= 1;
        addr <= 0;
        rate_cnt <= 0;
        l8_rx_valid <= 0;
    end
    else if (cnt == 35) begin
        rst <= 0;
    end
    // Give sufficient time for reset
    else if (cnt == 20000) begin
        l8_rx_valid <= 1;
    end
    else if (cnt >= 20001) begin
        if (rate_cnt < 100 * (RATE * period_rx / (64 * 8))) begin
            if (addr < hi) begin
                addr <= addr + 1;
                l8_rx_valid <= 1;
            end
            else if (!stop && stop_cnt == 0) begin
                l8_rx_valid <= 0;
                stop_cnt <= STOP_DELAY;
            end
        end
        else begin
            l8_rx_valid <= 0;
        end

        // Wrap-around rate counter
        if (rate_cnt == 99) begin
            rate_cnt <= 0;
        end
        else begin
            rate_cnt <= rate_cnt + 1;
        end
    end

    if (stop_cnt != 0) begin
        stop_cnt <= stop_cnt - 1;
        if (stop_cnt == 1) begin
            stop <= 1;
            $display("STOP READING!");
        end
    end
end

// Reassembly throughput profiling
always @(posedge clk_rxmac) begin
    if (rst) begin
        time_in_num_cycles_end <= 0;
        time_in_num_cycles_start <= 0;
    end
    else if (l8_rx_valid & l8_rx_endofpacket) begin
        if (time_in_num_cycles_start == 0) begin
            time_in_num_cycles_start <= cnt;
        end
        time_in_num_cycles_end <= cnt;
    end
end
always @(posedge clk_txmac) begin
    if (rst) begin
        time_out_num_cycles_start <= 0;
    end
    else if (l8_tx_valid & l8_tx_endofpacket) begin
        if (time_out_num_cycles_start == 0) begin
            time_out_num_cycles_start <= cnt;
        end
    end
end

// FAKE pdumeta_cpu
always @(posedge clk_pcie) begin
    if (rst) begin
        pdumeta_wait_cnt <= 0;
        sim_pdumeta_cpu_data <= 0;
        sim_pdumeta_cpu_valid <= 0;
        pdumeta_state <= PDUMETA_IDLE;
    end
    else begin
        case (pdumeta_state)
            PDUMETA_IDLE: begin
                pdumeta_wait_cnt <= 0;
                sim_pdumeta_cpu_valid <= 0;
                if (ddr_wr_req_valid) begin
                    pdumeta_state <= PDUMETA_WAIT;
                    sim_pdumeta_cpu_data.pdu_id <= ddr_wr_req_data[538:512] >> 5; // Addr
                    sim_pdumeta_cpu_data.action <= ACTION_NOMATCH;
                    sim_pdumeta_cpu_data.flits <= 24;
                    sim_pdumeta_cpu_data.pdu_size <= 1496;
                end
            end
            PDUMETA_WAIT: begin
                pdumeta_wait_cnt <= pdumeta_wait_cnt + 1;
                if (pdumeta_wait_cnt == 25) begin
                    sim_pdumeta_cpu_valid <= 1;
                    pdumeta_state <= PDUMETA_IDLE;
                end
            end
        endcase
    end
end

// Read and display pkt/flow cnts
always @(posedge clk_status) begin
    if (rst) begin
        s_addr <= 0;
        s_read <= 0;
        reg_cnt <= 0;
        s_write <= 0;
        s_writedata <= 0;
        reg_recv_cnt <= 0;
        conf_state <= ENABLE_PCIE;

        done_profiling <= 0;
        total_in_reassembler_bytes <= 0;
        total_out_reassembler_bytes <= 0;
    end
    else begin
        case (conf_state)
            DISABLE_PCIE: begin
                conf_state <= WRITE_CTRL;
                s_write <= 1;
                s_addr <= 30'h2A00_000F;
                s_writedata <= 1;
            end
            ENABLE_PCIE: begin
                conf_state <= WRITE_CTRL;
                s_write <= 1;
                s_addr <= 30'h2A00_000F;
                s_writedata <= 0;
            end
            WRITE_CTRL: begin
                conf_state <= IDLE;
                s_write <= 1;
                s_addr <= 30'h2200_0037;
                // Write non-fast-pattern forward threshold
                s_writedata <= nf_forward_threshold;
            end
            IDLE: begin
                s_write <= 0;
                if (stop) begin
                    conf_state <= READ_TOP_REG;
                end
            end
            READ_TOP_REG: begin
                if (reg_cnt < NUM_REG) begin
                    s_read <= 1;
                    s_addr <= {TOP_REG, 25'b0} + reg_cnt;
                    reg_cnt <= reg_cnt + 1;
                end
                else begin
                    s_read <= 0;
                end

                if (reg_recv_cnt >= NUM_REG) begin
                    reg_cnt <= 0;
                    reg_recv_cnt <= 0;
                    conf_state <= DONE;
                    $display("------------");
                end
                else if (top_readdata_valid) begin
                    reg_recv_cnt <= reg_recv_cnt + 1;
                    case (reg_recv_cnt)
                        REG_PARSER_OUT_BYTES_L  : total_in_reassembler_bytes[31:0] <= top_readdata;
                        REG_PARSER_OUT_BYTES_H  : total_in_reassembler_bytes[63:32] <= top_readdata;
                        REG_DM_OUT_BYTES_L      : total_out_reassembler_bytes[31:0] <= top_readdata;
                        REG_DM_OUT_BYTES_H      : total_out_reassembler_bytes[63:32] <= top_readdata;
                        default                 : ;
                    endcase
                end
            end
            DONE: begin
                done_profiling <= 1;
            end
        endcase
    end
end

if ((`TEST_CASE == "TEST_FCFS_BASIC_INORDER") ||
    (`TEST_CASE == "TEST_FCFS_BASIC_OOO")) begin
// TEST_FCFS_BASIC_INORDER: Test FCFS scheduling with in-order flows
// TEST_FCFS_BASIC_OOO: Test FCFS scheduling with innocent OOO flows
if (SCHEDULER_REASSEMBLY_POLICY != "FCFS") begin
    $error("FAIL %s: Incorrect scheduling policy %s (expected FCFS)",
           `TEST_CASE, SCHEDULER_REASSEMBLY_POLICY);
end

always @(posedge clk_status) begin
    if (done_profiling) begin
        if (total_in_reassembler_bytes == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Reassembler input byte count is 0");
        end
        else if (time_out_num_cycles_start == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Valid was never asserted on Ethernet TX");
        end
        else if (total_out_reassembler_bytes != total_in_reassembler_bytes) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Reassembler I/O byte count does not match");
        end
        else begin
            $display("PASS %s", `TEST_CASE);
        end
        $finish;
    end
end
end

else if ((`TEST_CASE == "TEST_WSJF_BASIC_INORDER") ||
         (`TEST_CASE == "TEST_WSJF_BASIC_OOO")) begin
// TEST_WSJF_BASIC_INORDER: Test WSJF scheduling with in-order flows
// TEST_WSJF_BASIC_OOO: Test WSJF scheduling with innocent OOO flows
if (SCHEDULER_REASSEMBLY_POLICY != "WSJF") begin
    $error("FAIL %s: Incorrect scheduling policy %s (expected WSJF)",
           `TEST_CASE, SCHEDULER_REASSEMBLY_POLICY);
end

always @(posedge clk_status) begin
    if (done_profiling) begin
        if (total_in_reassembler_bytes == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Reassembler input byte count is 0");
        end
        else if (time_out_num_cycles_start == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Valid was never asserted on Ethernet TX");
        end
        else if (total_out_reassembler_bytes != total_in_reassembler_bytes) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Reassembler I/O byte count does not match");
        end
        else begin
            $display("PASS %s", `TEST_CASE);
        end
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_WSJF_ACA_MITIGATION") begin
// Test WSJF scheduling with adversarial OOO flows. The parameters
// (e.g., expected goodput) might need some tuning, but in general,
// we expect WSJF (the scheduling policy underlying SurgeProtector)
// to keep the goodput relatively constant even under attack.
if (SCHEDULER_REASSEMBLY_POLICY != "WSJF") begin
    $error("FAIL %s: Incorrect scheduling policy %s (expected WSJF)",
           `TEST_CASE, SCHEDULER_REASSEMBLY_POLICY);
end

// Note: Since we have no way of differentiating between innocent and
// adversarial traffic (without breaking abstraction or exposing some
// internal state, both of which are hacky), we don't try and measure
// goodput at all. Instead, we use the _total_ bandwidth as proxy for
// goodput, and simply ensure that the delta between the input/output
// bandwidths is not too large.
logic [63:0] total_output_bandwidth_mbps;
logic [63:0] total_input_bandwidth_mbps;
logic [63:0] max_bandwidth_drop_mbps;
logic [63:0] bandwidth_drop_mbps;
logic is_bandwith_drop_pos;

// Tolerate a bandwidth drop of (2 * RATE_ATTACK) on the output,
// corresponding to a goodput drop of at most RATE_ATTACK Gbps.
assign max_bandwidth_drop_mbps = (1000 * (2 * `RATE_ATTACK));
assign time_out_num_cycles_end = cnt;

always @(*) begin
    total_output_bandwidth_mbps = 0;
    total_input_bandwidth_mbps = 0;
    is_bandwith_drop_pos = 0;
    bandwidth_drop_mbps = 0;

    if (done_profiling &&
        (time_in_num_cycles_start != time_in_num_cycles_end) &&
        (time_out_num_cycles_start != time_out_num_cycles_end)) begin
        total_input_bandwidth_mbps = (
            (1000 * (total_in_reassembler_bytes * 8)) /
            ((time_in_num_cycles_end - time_in_num_cycles_start) * period_rx)
        );
        total_output_bandwidth_mbps = (
            (1000 * (total_out_reassembler_bytes * 8)) /
            ((time_out_num_cycles_end - time_out_num_cycles_start) * period_tx)
        );
        is_bandwith_drop_pos = (total_input_bandwidth_mbps >=
                                total_output_bandwidth_mbps);

        if (is_bandwith_drop_pos) begin
            bandwidth_drop_mbps = (total_input_bandwidth_mbps -
                                   total_output_bandwidth_mbps);
        end
    end
end

always @(posedge clk_status) begin
    if (done_profiling) begin
        $display("Input bandwidth: %0d Mbps, output bandwidth: %0d Mbps",
                 total_input_bandwidth_mbps, total_output_bandwidth_mbps);

        if (total_in_reassembler_bytes == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Reassembler input byte count is 0");
        end
        else if (time_out_num_cycles_start == 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Valid was never asserted on Ethernet TX");
        end
        else if (is_bandwith_drop_pos) begin
            // Ensure that bandwith drop is in an acceptable range
            if (bandwidth_drop_mbps >= max_bandwidth_drop_mbps) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Loss in goodput (%0d Mbps) exceeds ", bandwidth_drop_mbps,
                         "maximum allowable value under WSJF (%0d Mbps)", max_bandwidth_drop_mbps);
            end
            else begin
                $display("PASS %s", `TEST_CASE);
            end
        end
        else begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Loss in goodput should be a positive quantity");
        end
        $finish;
    end
end
end

else begin
    $error("FAIL: Unknown test %s", `TEST_CASE);
end
`endif

assign ddr_rd_resp_valid_int = ddr_rd_resp_valid & !ddr_rd_resp_almost_full;
stats stats(
    .arst                       (rst),

    .clk_tx                     (clk_txmac),
    .tx_ready                   (l8_tx_ready),
    .tx_valid                   (l8_tx_valid),
    .tx_data                    (l8_tx_data),
    .tx_sop                     (l8_tx_startofpacket),
    .tx_eop                     (l8_tx_endofpacket),
    .tx_empty                   (l8_tx_empty),

    .clk_rx                     (clk_rxmac),
    .rx_sop                     (l8_rx_startofpacket),
    .rx_eop                     (l8_rx_endofpacket),
    .rx_empty                   (l8_rx_empty),
    .rx_data                    (l8_rx_data),
    .rx_valid                   (l8_rx_valid),

    .rx_ready                   (stats_rx_ready),
    .o_rx_sop                   (stats_rx_startofpacket),
    .o_rx_eop                   (stats_rx_endofpacket),
    .o_rx_empty                 (stats_rx_empty),
    .o_rx_data                  (stats_rx_data),
    .o_rx_valid                 (stats_rx_valid),

    .clk_status                 (clk_status),
    .status_addr                (s_addr),
    .status_read                (s_read),
    .status_write               (s_write),
    .status_writedata           (s_writedata),
    .status_readdata            (s_readdata),
    .status_readdata_valid      (s_readdata_valid)
);

dc_fifo_wrapper input_fifo (
    .in_clk                     (clk_rxmac),
    .in_reset_n                 (!rst),
    .out_clk                    (clk_user),
    .out_reset_n                (!rst),
    .in_data                    (stats_rx_data),
    .in_valid                   (stats_rx_valid),
    .in_ready                   (stats_rx_ready),
    .in_startofpacket           (stats_rx_startofpacket),
    .in_endofpacket             (stats_rx_endofpacket),
    .in_empty                   (stats_rx_empty),
    .out_data                   (top_in_data),
    .out_valid                  (top_in_valid),
    .out_ready                  (1'b1),
    .out_startofpacket          (top_in_startofpacket),
    .out_endofpacket            (top_in_endofpacket),
    .out_empty                  (top_in_empty)
);


top partition_1 (
    // Clk & rst
    .clk                        (clk_user),
    .rst                        (rst),
    .clk_high                   (clk_user_high),
    .rst_high                   (rst),
    .clk_pcie                   (clk_pcie),
    .rst_pcie                   (rst),
    // Ethernet in & out data
    .in_data                    (top_in_data),
    .in_valid                   (top_in_valid),
    .in_sop                     (top_in_startofpacket),
    .in_eop                     (top_in_endofpacket),
    .in_empty                   (top_in_empty),
    .out_data                   (top_out_data),
    .out_valid                  (top_out_valid),
    .out_sop                    (top_out_startofpacket),
    .out_eop                    (top_out_endofpacket),
    .out_empty                  (top_out_empty),
    .out_ready                  (top_out_ready),
    // eSRAM/BRAM
    .pkt_buf_wren               (pkt_buf_wren),
    .pkt_buf_wraddress          (pkt_buf_wraddress),
    .pkt_buf_wrdata             (pkt_buf_wrdata),
    .pkt_buf_rden               (pkt_buf_rden),
    .pkt_buf_rdaddress          (pkt_buf_rdaddress),
    .pkt_buf_rd_valid           (pkt_buf_rd_valid),
    .pkt_buf_rddata             (pkt_buf_rddata),
    // PCIe
    .pcie_rb_wr_data            (pcie_rb_wr_data),
    .pcie_rb_wr_addr            (pcie_rb_wr_addr),
    .pcie_rb_wr_en              (pcie_rb_wr_en),
    .pcie_rb_wr_base_addr       (pcie_rb_wr_base_addr),
    .pcie_rb_almost_full        (pcie_rb_almost_full),
    .pcie_rb_update_valid       (pcie_rb_update_valid),
    .pcie_rb_update_size        (pcie_rb_update_size),
    .disable_pcie               (1'b0),
`ifdef SIM
    .pdumeta_cpu_data           (sim_pdumeta_cpu_data),
    .pdumeta_cpu_valid          (sim_pdumeta_cpu_valid),
`else
    .pdumeta_cpu_data           (pdumeta_cpu_data),
    .pdumeta_cpu_valid          (pdumeta_cpu_valid),
`endif
    .pdumeta_cnt                (pdumeta_cnt),
    // DRAM
    .ddr_wr_req_data            (ddr_wr_req_data),
    .ddr_wr_req_valid           (ddr_wr_req_valid),
    .ddr_wr_req_almost_full     (ddr_wr_req_almost_full),
    .ddr_rd_req_data            (ddr_rd_req_data),
    .ddr_rd_req_valid           (ddr_rd_req_valid),
    .ddr_rd_req_almost_full     (ddr_rd_req_almost_full),
    .ddr_rd_resp_data           (ddr_rd_resp_data),
    .ddr_rd_resp_valid          (ddr_rd_resp_valid),
    .ddr_rd_resp_almost_full    (ddr_rd_resp_almost_full),
    // JTAG
    .clk_status                 (clk_status),
    .status_addr                (s_addr),
    .status_read                (s_read),
    .status_write               (s_write),
    .status_writedata           (s_writedata),
    .status_readdata            (top_readdata),
    .status_readdata_valid      (top_readdata_valid)
);

dc_fifo_wrapper_infill out_fifo0 (
    .in_clk                     (clk_user),
    .in_reset_n                 (!rst),
    .out_clk                    (clk_txmac),
    .out_reset_n                (!rst),
    .in_csr_address             (0),
    .in_csr_read                (1'b1),
    .in_csr_write               (1'b0),
    .in_csr_readdata            (),
    .in_csr_writedata           (),
    .in_data                    (top_out_data),
    .in_valid                   (top_out_valid),
    .in_ready                   (top_out_ready),
    .in_startofpacket           (top_out_startofpacket),
    .in_endofpacket             (top_out_endofpacket),
    .in_empty                   (top_out_empty),
    .out_data                   (l8_tx_data),
    .out_valid                  (l8_tx_valid),
    .out_ready                  (l8_tx_ready),
    .out_startofpacket          (l8_tx_startofpacket),
    .out_endofpacket            (l8_tx_endofpacket),
    .out_empty                  (l8_tx_empty)
);

pcie_top pcie (
    .refclk_clk             (1'b0),                 // .refclk.clk
    .pcie_rstn_npor         (1'b1),                 // .pcie_rstn.npor
    .pcie_rstn_pin_perst    (1'b0),                 // .pin_perst
    .xcvr_rx_in0            (1'b0),                 // .xcvr.rx_in0
    .xcvr_rx_in1            (1'b0),                 // .rx_in1
    .xcvr_rx_in2            (1'b0),                 // .rx_in2
    .xcvr_rx_in3            (1'b0),                 // .rx_in3
    .xcvr_rx_in4            (1'b0),                 // .rx_in4
    .xcvr_rx_in5            (1'b0),                 // .rx_in5
    .xcvr_rx_in6            (1'b0),                 // .rx_in6
    .xcvr_rx_in7            (1'b0),                 // .rx_in7
    .xcvr_rx_in8            (1'b0),                 // .rx_in8
    .xcvr_rx_in9            (1'b0),                 // .rx_in9
    .xcvr_rx_in10           (1'b0),                 // .rx_in10
    .xcvr_rx_in11           (1'b0),                 // .rx_in11
    .xcvr_rx_in12           (1'b0),                 // .rx_in12
    .xcvr_rx_in13           (1'b0),                 // .rx_in13
    .xcvr_rx_in14           (1'b0),                 // .rx_in14
    .xcvr_rx_in15           (1'b0),                 // .rx_in15
    .xcvr_tx_out0           (),                     // .tx_out0
    .xcvr_tx_out1           (),                     // .tx_out1
    .xcvr_tx_out2           (),                     // .tx_out2
    .xcvr_tx_out3           (),                     // .tx_out3
    .xcvr_tx_out4           (),                     // .tx_out4
    .xcvr_tx_out5           (),                     // .tx_out5
    .xcvr_tx_out6           (),                     // .tx_out6
    .xcvr_tx_out7           (),                     // .tx_out7
    .xcvr_tx_out8           (),                     // .tx_out8
    .xcvr_tx_out9           (),                     // .tx_out9
    .xcvr_tx_out10          (),                     // .tx_out10
    .xcvr_tx_out11          (),                     // .tx_out11
    .xcvr_tx_out12          (),                     // .tx_out12
    .xcvr_tx_out13          (),                     // .tx_out13
    .xcvr_tx_out14          (),                     // .tx_out14
    .xcvr_tx_out15          (),                     // .tx_out15
    .pcie_clk               (clk_pcie),
    .pcie_reset_n           (!rst),
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
    .status_readdata        (pcie_readdata),
    .status_readdata_valid  (pcie_readdata_valid)
);

dram_wrapper dram_check_pkt_buffer(
    .emif_reset_n           (emif_reset_n),
    .emif_clk               (clk_emif),
    .clk                    (clk_pcie),
    .rst                    (rst),
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
    .clk_status             (clk_status),
    .status_addr            (s_addr),
    .status_read            (s_read),
    .status_write           (s_write),
    .status_writedata       (s_writedata),
    .status_readdata        (dram_readdata),
    .status_readdata_valid  (dram_readdata_valid)
);

esram_wrapper esram_pkt_buffer(
    .clk_esram_ref  (clk_esram_ref), //100 MHz
    .esram_pll_lock (esram_pll_lock),
    .clk_esram      (clk_user), // 200 MHz
    .wren           (pkt_buf_wren),
    .wraddress      (pkt_buf_wraddress),
    .wrdata         (pkt_buf_wrdata),
    .rden           (pkt_buf_rden),
    .rdaddress      (pkt_buf_rdaddress),
    .rd_valid       (pkt_buf_rd_valid),
    .rddata         (pkt_buf_rddata)
);

endmodule
