`timescale 1 ns/10 ps

module tb_ffs;

// Simulation parameters
localparam WIDTH = 16;
localparam PERIOD = 10;
localparam WIDTH_LOG = $clog2(WIDTH);

`ifndef TEST_CASE
    $error("FAIL: No test case specified");
`endif

/**
 * List of tests:
 * ---------------------
 * TEST_ZERO
 * TEST_LSB_SET
 * TEST_MSB_SET
 * TEST_ALL_SET
 * TEST_RANDOM_BITMAP
 */

// Global state
logic clk;
logic rst;
logic zero;
logic [WIDTH-1:0] x;
logic [WIDTH_LOG-1:0] msb;
logic [WIDTH_LOG-1:0] lsb;
logic [WIDTH-1:0] x_initval;

initial x = 0;
initial clk = 0;
initial rst = 1;
always #(PERIOD) clk = ~clk;

if (`TEST_CASE == "TEST_ZERO") begin
// Ensure zero is correctly asserted
assign x_initval = 16'b0;

always @(posedge clk) begin
    if (!rst) begin
        if (!zero) begin
            $display("FAIL %s: Zero was not asserted", `TEST_CASE);
            $finish;
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
end
end

else if (`TEST_CASE == "TEST_LSB_SET") begin
// Ensure output is correct when the LSB is set
assign x_initval = 16'b0000000000000001;

always @(posedge clk) begin
    if (!rst) begin
        if (zero) begin
            $display("FAIL %s: Zero incorrectly asserted", `TEST_CASE);
            $finish;
        end
        else if (lsb != 0 || msb != 0) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Incorrect output. Expected (lsb=0, msb=0) ",
                     "for x=%b, got (lsb=%0d, msb=%0d)", x, lsb, msb);
            $finish;
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
end
end

else if (`TEST_CASE == "TEST_MSB_SET") begin
// Ensure output is correct when the MSB is set
assign x_initval = 16'b1000000000000000;

always @(posedge clk) begin
    if (!rst) begin
        if (zero) begin
            $display("FAIL %s: Zero incorrectly asserted", `TEST_CASE);
            $finish;
        end
        else if (lsb != 15 || msb != 15) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Incorrect output. Expected (lsb=15, msb=15) ",
                     "for x=%b, got (lsb=%0d, msb=%0d)", x, lsb, msb);
            $finish;
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
end
end

else if (`TEST_CASE == "TEST_ALL_SET") begin
// Ensure output is correct when all bits are set
assign x_initval = 16'b1111111111111111;

always @(posedge clk) begin
    if (!rst) begin
        if (zero) begin
            $display("FAIL %s: Zero incorrectly asserted", `TEST_CASE);
            $finish;
        end
        else if (lsb != 0 || msb != 15) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Incorrect output. Expected (lsb=0, msb=15) ",
                     "for x=%b, got (lsb=%0d, msb=%0d)", x, lsb, msb);
            $finish;
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
end
end

else if (`TEST_CASE == "TEST_RANDOM_BITMAP") begin
// Ensure output is correct when random bits are set
assign x_initval = 16'b0011100010101010;

always @(posedge clk) begin
    if (!rst) begin
        if (zero) begin
            $display("FAIL %s: Zero incorrectly asserted", `TEST_CASE);
            $finish;
        end
        else if (lsb != 1 || msb != 13) begin
            $display("FAIL %s: ", `TEST_CASE,
                     "Incorrect output. Expected (lsb=1, msb=13) ",
                     "for x=%b, got (lsb=%0d, msb=%0d)", x, lsb, msb);
            $finish;
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
end
end

else begin
    $error("FAIL: Unknown test %s", `TEST_CASE);
end

// Value initialization logic
always @(posedge clk) begin
    if (rst) begin
        rst <= 0;
        x <= x_initval;
    end
end

// FFS instance
ffs #(
    .WIDTH_LOG(WIDTH_LOG)
)
ffs_instance (
    .x(x),
    .lsb(lsb),
    .msb(msb),
    .zero(zero)
);

endmodule
