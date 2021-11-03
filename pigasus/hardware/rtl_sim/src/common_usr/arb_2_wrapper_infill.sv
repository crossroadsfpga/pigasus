module arb_2_wrapper_infill #(
    parameter DWIDTH = 8,
    parameter DEPTH = 1024,
    parameter FULL_LEVEL = 1000,
    parameter AWIDTH = ($clog2(DEPTH))
) (
    input   logic               clk,
    input   logic               rst,
    input   logic               clk_out,
    input   logic               rst_out,
    // Input 0
    input   logic [DWIDTH-1:0]  in_data_0,
    input   logic               in_valid_0,
    output  logic               in_ready_0,
    output  logic               in_almost_full_0,
    // Input 1
    input   logic [DWIDTH-1:0]  in_data_1,
    input   logic               in_valid_1,
    output  logic               in_ready_1,
    output  logic               in_almost_full_1,
    // Output
    output  logic [DWIDTH-1:0]  out_data,
    output  logic               out_valid,
    input   logic               out_ready
);

logic [DWIDTH-1:0]  fifo_0_data;
logic               fifo_0_valid;
logic               fifo_0_ready;
logic               fifo_0_valid_arb;
logic               fifo_0_ready_arb;
logic [DWIDTH-1:0]  fifo_1_data;
logic               fifo_1_valid;
logic               fifo_1_ready;
logic [DWIDTH-1:0]  outfifo_data;
logic               outfifo_valid;
logic               outfifo_ready;

logic [31:0]        fifo_0_cnt;
logic [31:0]        fifo_1_cnt;
logic [31:0]        outfifo_cnt;
logic [31:0]        fifo_0_csr_readdata;
logic [31:0]        fifo_1_csr_readdata;

logic               in_csr_address;
logic               in_csr_read;
logic               in_csr_write;
logic [31:0]        in_csr_readdata;
logic [31:0]        in_csr_writedata;

assign in_csr_address = 0;
assign in_csr_read = 1;
assign in_csr_write = 0;
assign in_csr_writedata = 0;

// FIFO 1 always has higher priority than FIFO 0
assign fifo_0_valid_arb = fifo_1_valid ? 0 : fifo_0_valid;
assign fifo_0_ready = fifo_1_valid ? 0 : fifo_0_ready_arb;

st_multiplexer #(
    .DWIDTH(DWIDTH)
)
multiplexer(
    .out_channel       (),
    .out_valid         (outfifo_valid),
    .out_ready         (outfifo_ready),
    .out_data          (outfifo_data),
    .in0_valid         (fifo_0_valid_arb),
    .in0_ready         (fifo_0_ready_arb),
    .in0_data          (fifo_0_data),
    .in1_valid         (fifo_1_valid),
    .in1_ready         (fifo_1_ready),
    .in1_data          (fifo_1_data),
    .clk               (clk),
    .reset_n           (!rst)
);

unified_fifo  #(
    .FIFO_NAME        ("[arb_2_wrapper_infill] in_fifo_0"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DWIDTH),
    .FIFO_DEPTH       (DEPTH)
)
in_fifo_0 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (in_data_0),
    .in_valid          (in_valid_0),
    .in_ready          (in_ready_0),
    .out_data          (fifo_0_data),
    .out_valid         (fifo_0_valid),
    .out_ready         (fifo_0_ready),
    .fill_level        (),
    .almost_full       (in_almost_full_0),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[arb_2_wrapper_infill] in_fifo_1"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DWIDTH),
    .FIFO_DEPTH       (DEPTH)
)
in_fifo_1 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (in_data_1),
    .in_valid          (in_valid_1),
    .in_ready          (in_ready_1),
    .out_data          (fifo_1_data),
    .out_valid         (fifo_1_valid),
    .out_ready         (fifo_1_ready),
    .fill_level        (),
    .almost_full       (in_almost_full_1),
    .overflow          ()
);

unified_fifo  #(
    .FIFO_NAME        ("[arb_2_wrapper_infill] out_fifo_0"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (DWIDTH),
    .FIFO_DEPTH       (DEPTH)
)
out_fifo_0 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (clk_out),//not used
    .out_reset         (rst_out),
    .in_data           (outfifo_data),
    .in_valid          (outfifo_valid),
    .in_ready          (outfifo_ready),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (out_ready),
    .fill_level        (),
    .almost_full       (),
    .overflow          ()
);

endmodule
