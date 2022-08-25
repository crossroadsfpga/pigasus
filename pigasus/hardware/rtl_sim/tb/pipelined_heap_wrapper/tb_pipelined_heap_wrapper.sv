`timescale 1 ns/10 ps

import heap_ops_pkg::*;

module tb_pipelined_heap_wrapper;

// Simulation parameters
localparam PERIOD = 10;
localparam HEAP_BITMAP_WIDTH = 32;
localparam HEAP_MAX_NUM_ENTRIES = 128;
localparam HEAP_ENTRY_VALUE_WIDTH = 64;
localparam HEAP_NUM_PRIORITIES = (HEAP_BITMAP_WIDTH ** 2);
localparam HEAP_ENTRY_AWIDTH = ($clog2(HEAP_MAX_NUM_ENTRIES));
localparam HEAP_PRIORITY_AWIDTH = ($clog2(HEAP_NUM_PRIORITIES));

localparam HEAP_INIT_CYCLES = (
    (HEAP_MAX_NUM_ENTRIES > HEAP_NUM_PRIORITIES) ?
    HEAP_MAX_NUM_ENTRIES : HEAP_NUM_PRIORITIES);

localparam HEAP_MIN_NUM_PRIORITIES_AND_ENTRIES = (
    (HEAP_MAX_NUM_ENTRIES < HEAP_NUM_PRIORITIES) ?
    HEAP_MAX_NUM_ENTRIES : HEAP_NUM_PRIORITIES);

localparam MAX_HEAP_INIT_CYCLES = (HEAP_INIT_CYCLES << 1);

// Local typedefs
typedef logic [HEAP_PRIORITY_AWIDTH-1:0] heap_priority_t;
typedef logic [HEAP_ENTRY_VALUE_WIDTH-1:0] heap_entry_value_t;

/**
 * List of tests:
 * ---------------------
 * TEST_DEQUE_PRIMARY_BASIC
 * TEST_DEQUE_PRIMARY_APPROX_HEAP
 * TEST_DEQUE_SECONDARY_BASIC
 * TEST_DEQUE_SECONDARY_REISSUE
 */

// Global state
logic clk;
logic rst;
logic init_done;
logic [31:0] counter;
logic [31:0] test_timer;

initial clk = 0;
initial rst = 1;
initial counter = 0;
initial init_done = 0;
initial test_timer = 0;
always #(PERIOD) clk = ~clk;

// Heap wrapper signals
logic in_enque_en;
logic in_enque_ready;
logic out_deque_primary_en;
logic out_deque_primary_ready;
heap_entry_value_t in_enque_value;
heap_priority_t in_enque_priority;
heap_entry_value_t out_deque_primary_value;
heap_priority_t out_deque_primary_priority;
logic in_deque_secondary_req_en;
logic in_deque_secondary_req_ready;
logic out_deque_secondary_en;
logic out_deque_secondary_ready;
heap_entry_value_t out_deque_secondary_value;
heap_priority_t out_deque_secondary_priority;
logic [HEAP_ENTRY_AWIDTH:0] heap_size;
logic heap_ready;

`ifndef TEST_CASE
    $error("FAIL: No test case specified");
`else
if (`TEST_CASE == "TEST_DEQUE_PRIMARY_BASIC") begin
// Test a basic deque-PRIMARY operation
always @(posedge clk) begin
    rst <= 0;
    in_enque_en <= 0;
    in_enque_value <= 0;
    in_enque_priority <= 0;
    out_deque_primary_en <= 0;
    test_timer <= test_timer + 1;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            in_enque_en <= 1;
            in_enque_value <= 23;
            in_enque_priority <= 1023;

            if (!in_enque_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is empty, but in_enque_ready is not asserted");
                $finish;
            end

            if (out_deque_primary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is empty, but out_deque_primary_ready is asserted");
                $finish;
            end
        end
        else if (counter == 20) begin
            out_deque_primary_en <= 1;
            if (out_deque_primary_ready) begin
                if ((out_deque_primary_value != 23) ||
                    (out_deque_primary_priority != 1023)) begin
                    $display("FAIL %s: Expected ", `TEST_CASE,
                             "(value: 23, priority: 1023), got (%0d, %0d)",
                             out_deque_primary_value, out_deque_primary_priority);
                    $finish;
                end
            end
            else begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is not empty, but out_deque_primary_ready is not asserted");
                $finish;
            end
        end
        else if (counter == 22) begin
            if (out_deque_primary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap became empty, but out_deque_primary_ready is still asserted");
                $finish;
            end
            else begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_DEQUE_PRIMARY_APPROX_HEAP") begin
// Ensures that the heap property is approximately satisfied.
// This is enforced by checking that the third deque-PRIMARY
// element corresponds to the top heap entry.
always @(posedge clk) begin
    rst <= 0;
    in_enque_en <= 0;
    in_enque_value <= 0;
    in_enque_priority <= 0;
    out_deque_primary_en <= 0;
    test_timer <= test_timer + 1;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter < 32) begin
            in_enque_en <= 1;
            in_enque_value <= counter;
            in_enque_priority <= (31 - counter);
        end
        else if (counter == 50 || counter == 55) begin
            if (!out_deque_primary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is not empty, but out_deque_primary_ready is not asserted");
                $finish;
            end
            out_deque_primary_en <= 1;
        end
        else if (counter == 65) begin
            if (!out_deque_primary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is not empty, but out_deque_primary_ready is not asserted");
                $finish;
            end
            if ((out_deque_primary_priority == 0) && (out_deque_primary_value == 31)) begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
            else begin
                $display("FAIL %s: ", `TEST_CASE, "Approximate heap property not satisfied");
                $finish;
            end
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_DEQUE_SECONDARY_BASIC") begin
// Test a basic deque-SECONDARY operation
always @(posedge clk) begin
    rst <= 0;
    in_enque_en <= 0;
    in_enque_value <= 0;
    in_enque_priority <= 0;
    out_deque_primary_en <= 0;
    out_deque_secondary_en <= 0;
    test_timer <= test_timer + 1;
    in_deque_secondary_req_en <= 0;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter < 32) begin
            in_enque_en <= 1;
            in_enque_value <= counter;
            in_enque_priority <= counter;
        end
        else if (counter == 50 || counter == 55) begin
            if (!out_deque_primary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is not empty, but out_deque_primary_ready is not asserted");
                $finish;
            end
            out_deque_primary_en <= 1;
        end
        else if (counter == 65) begin
            if (out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was not issued, but out-FIFO has entries");
                $finish;
            end
            else if (!in_deque_secondary_req_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap has >2 entries, but in_deque_secondary_req_ready is not asserted");
                $finish;
            end
            in_deque_secondary_req_en <= 1;
        end
        else if (counter == 75) begin
            if (!out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was issued, but out-FIFO is empty");
                $finish;
            end
            else if ((out_deque_secondary_priority != 31) ||
                     (out_deque_secondary_value != 31)) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY does not satisfy heap property");
                $finish;
            end
            out_deque_secondary_en <= 1;
        end
        else if (counter == 77) begin
            if (out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was not re-issued, but out-FIFO has entries");
                $finish;
            end
            else begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_DEQUE_SECONDARY_REISSUE") begin
// Ensures that failed deque-SECONDARY ops are reissued
always @(posedge clk) begin
    rst <= 0;
    in_enque_en <= 0;
    in_enque_value <= 0;
    in_enque_priority <= 0;
    out_deque_primary_en <= 0;
    out_deque_secondary_en <= 0;
    test_timer <= test_timer + 1;
    in_deque_secondary_req_en <= 0;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter < 2) begin
            in_enque_en <= 1;
            in_enque_value <= counter;
            in_enque_priority <= counter;
        end
        else if (counter == 14) begin
            if (out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was not issued, but out-FIFO has entries");
                $finish;
            end
            else if (!in_deque_secondary_req_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap has >2 entries, but in_deque_secondary_req_ready is not asserted");
                $finish;
            end
            in_deque_secondary_req_en <= 1;
        end
        else if (counter == 20) begin
            if (out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap became empty, but out_deque_secondary_ready is still asserted");
                $finish;
            end
            else if (in_deque_secondary_req_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was previously issued, but in_ready was re-asserted");
                $finish;
            end
            in_enque_en <= 1;
            in_enque_value <= counter;
            in_enque_priority <= counter;
        end
        else if (counter == 35) begin
            if (!out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap has entries, but deque-SECONDARY was not correctly re-issued");
                $finish;
            end
            else if ((out_deque_secondary_priority != 20) ||
                     (out_deque_secondary_value != 20)) begin
                $display("FAIL %s: Expected ", `TEST_CASE,
                         "(value: 20, priority: 20), got (%0d, %0d)",
                         out_deque_secondary_value, out_deque_secondary_priority);
                $finish;
            end
            out_deque_secondary_en <= 1;
        end
        else if (counter == 37) begin
            if (in_deque_secondary_req_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Heap is empty, but in_deque_secondary_req_ready is still asserted");
                $finish;
            end
            else if (out_deque_secondary_ready) begin
                $display("FAIL %s: ", `TEST_CASE,
                         "Deque-SECONDARY was not re-issued, but out-FIFO has entries");
                $finish;
            end
            else begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else begin
    $error("FAIL: Unknown test %s", `TEST_CASE);
end
`endif

// Heap wrapper instance
pipelined_heap_wrapper #(
    .HEAP_BITMAP_WIDTH(HEAP_BITMAP_WIDTH),
    .HEAP_MAX_NUM_ENTRIES(HEAP_MAX_NUM_ENTRIES),
    .HEAP_ENTRY_VALUE_WIDTH(HEAP_ENTRY_VALUE_WIDTH),
    .HEAP_OP_DEQUE_PRIMARY_TYPE(HEAP_OP_DEQUE_MIN)
) heap_wrapper (
    // General inputs
    .clk(clk),
    .rst(rst),
    // Enque
    .in_enque_en(in_enque_en),
    .in_enque_ready(in_enque_ready),
    .in_enque_value(in_enque_value),
    .in_enque_priority(in_enque_priority),
    // Deque-PRIMARY
    .out_deque_primary_en(out_deque_primary_en),
    .out_deque_primary_ready(out_deque_primary_ready),
    .out_deque_primary_value(out_deque_primary_value),
    .out_deque_primary_priority(out_deque_primary_priority),
    // Deque-SECONDARY (request)
    .in_deque_secondary_req_en(in_deque_secondary_req_en),
    .in_deque_secondary_req_ready(in_deque_secondary_req_ready),
    // Deque-SECONDARY (response)
    .out_deque_secondary_en(out_deque_secondary_en),
    .out_deque_secondary_ready(out_deque_secondary_ready),
    .out_deque_secondary_value(out_deque_secondary_value),
    .out_deque_secondary_priority(out_deque_secondary_priority),
    // Feedback
    .heap_size(heap_size),
    .heap_ready(heap_ready)
);

endmodule
