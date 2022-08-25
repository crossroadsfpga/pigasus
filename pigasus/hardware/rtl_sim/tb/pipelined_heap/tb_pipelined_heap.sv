`timescale 1 ns/10 ps

import heap_ops_pkg::*;

module tb_pipelined_heap;

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
 * TEST_BASIC_ENQUE
 * TEST_BASIC_DEQUE_MIN
 * TEST_BASIC_DEQUE_MAX
 * TEST_HEAP_PROPERTY
 * TEST_CAPACITY_LIMITS
 * TEST_PIPELINING_ENQUE
 * TEST_PIPELINING_MIXED
 * TEST_DEQUE_COLLISIONS
 * TEST_RESET
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

// Heap signals
logic heap_ready;
logic heap_in_en;
logic heap_out_valid;
heap_op_t heap_in_op_type;
heap_op_t heap_out_op_type;
heap_entry_value_t heap_in_value;
heap_priority_t heap_in_priority;
heap_entry_value_t heap_out_value;
heap_priority_t heap_out_priority;
logic [2:0] heap_num_ops_enque;
logic [2:0] heap_num_ops_deque_min;
logic [2:0] heap_num_ops_deque_max;
logic [HEAP_ENTRY_AWIDTH:0] heap_size;

`ifndef TEST_CASE
    $error("FAIL: No test case specified");
`else
if (`TEST_CASE == "TEST_BASIC_ENQUE") begin
// Test a single enque operation
always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_value <= 23;
            heap_in_priority <= 1023;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (heap_out_valid) begin
            if ((heap_out_op_type == HEAP_OP_ENQUE) &&
                (heap_out_priority == 1023) &&
                (heap_out_value == 23)) begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
            else begin
                $display("FAIL %s: Expected ", `TEST_CASE,
                         "(op: HEAP_OP_ENQUE, value: 23, priority: 1023), got ",
                         "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                $finish;
            end
        end
        else if (counter >= 10) begin
            $display("FAIL %s: Test timed out", `TEST_CASE);
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_BASIC_DEQUE_MIN") begin
// Test a single deque-min operation
always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_value <= 42;
            heap_in_priority <= 397;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 10) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if ((counter > 10) && heap_out_valid) begin
            if ((heap_out_op_type == HEAP_OP_DEQUE_MIN) &&
                (heap_out_priority == 397) &&
                (heap_out_value == 42)) begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
            else begin
                $display("FAIL %s: Expected ", `TEST_CASE,
                         "(op: HEAP_OP_DEQUE_MIN, value: 42, priority: 397), got ",
                         "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                $finish;
            end
        end
        else if (counter >= 20) begin
            $display("FAIL %s: Test timed out", `TEST_CASE);
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_BASIC_DEQUE_MAX") begin
// Test a single deque-max operation
always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_value <= 13455345;
            heap_in_priority <= 7;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 10) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MAX;
        end
        else if ((counter > 10) && heap_out_valid) begin
            if ((heap_out_op_type == HEAP_OP_DEQUE_MAX) &&
                (heap_out_priority == 7) &&
                (heap_out_value == 13455345)) begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
            else begin
                $display("FAIL %s: Expected ", `TEST_CASE,
                         "(op: HEAP_OP_DEQUE_MAX, value: 13455345, priority: 7), got ",
                         "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                $finish;
            end
        end
        else if (counter >= 20) begin
            $display("FAIL %s: Test timed out", `TEST_CASE);
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_HEAP_PROPERTY") begin
// Ensures that the heap property is maintained
logic deque_min_done;
logic deque_max_done;

initial begin
    deque_min_done = 0;
    deque_max_done = 0;
end

always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_value <= 1;
            heap_in_priority <= 667;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 1) begin
            heap_in_en <= 1;
            heap_in_value <= 2;
            heap_in_priority <= 653;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 2) begin
            heap_in_en <= 1;
            heap_in_value <= 3;
            heap_in_priority <= 471;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 3) begin
            heap_in_en <= 1;
            heap_in_value <= 4;
            heap_in_priority <= 1023;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter < 10) begin
            // NOOP
        end
        else if (counter == 10) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if (counter < 20) begin
            if (heap_out_valid) begin
                if ((heap_out_op_type == HEAP_OP_DEQUE_MIN) &&
                    (heap_out_priority == 471) &&
                    (heap_out_value == 3)) begin
                    deque_min_done <= 1;
                end
                else begin
                    $display("FAIL %s: Expected ", `TEST_CASE,
                             "(op: HEAP_OP_DEQUE_MIN, value: 3, priority: 471), got ",
                             "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                    $finish;
                end
            end
        end
        else if (counter == 20) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MAX;
        end
        else if (counter < 30) begin
            if (heap_out_valid) begin
                if ((heap_out_op_type == HEAP_OP_DEQUE_MAX) &&
                    (heap_out_priority == 1023) &&
                    (heap_out_value == 4)) begin
                    deque_max_done <= 1;
                end
                else begin
                    $display("FAIL %s: Expected ", `TEST_CASE,
                             "(op: HEAP_OP_DEQUE_MAX, value: 4, priority: 1023), got ",
                             "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                    $finish;
                end
            end
        end
        else begin
            if (deque_min_done & deque_max_done) begin
                $display("PASS %s", `TEST_CASE);
            end
            else begin
                $display("FAIL %s: Test timed out", `TEST_CASE);
            end
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_CAPACITY_LIMITS") begin
// Test heap capacity limits (i.e. enqueing into
// a full heap or dequeing from an empty heap).
always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if (counter <= 10) begin
            if (heap_out_valid) begin
                $display("FAIL %s: Deque'd empty heap", `TEST_CASE);
                $finish;
            end
        end
        else if (counter <= (20 + HEAP_MAX_NUM_ENTRIES)) begin
            if (counter < (11 + HEAP_MAX_NUM_ENTRIES)) begin
                heap_in_en <= 1;
                heap_in_value <= counter;
                heap_in_priority <= (counter << 1);
                heap_in_op_type <= HEAP_OP_ENQUE;
            end
        end
        else if (counter < (50 + HEAP_MAX_NUM_ENTRIES)) begin
            heap_in_en <= 1;
            heap_in_value <= counter;
            heap_in_priority <= (counter << 1);
            heap_in_op_type <= HEAP_OP_ENQUE;

            if (heap_out_valid) begin
                $display("FAIL %s: Enque'd into a full heap", `TEST_CASE);
                $finish;
            end
        end
        else begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_PIPELINING_ENQUE") begin
// Make sure enque pipelining works as expected
logic [31:0] first_enque_done_count;
logic first_enque_done;

initial begin
    first_enque_done = 0;
    first_enque_done_count = 0;
end

always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter <= 15) begin
            heap_in_en <= 1;
            heap_in_value <= counter;
            heap_in_priority <= counter;
            heap_in_op_type <= HEAP_OP_ENQUE;

            if (heap_out_valid) begin
                if (!first_enque_done) begin
                    first_enque_done <= 1;
                    first_enque_done_count <= counter;

                    if ((heap_out_priority != 0) || (heap_out_value != 0)) begin
                        $display("FAIL %s: Unexpected output value", `TEST_CASE);
                        $finish;
                    end
                end
                else begin
                    if ((heap_out_priority != (counter - first_enque_done_count) ||
                        (heap_out_value != (counter - first_enque_done_count)))) begin
                        $display("FAIL %s: Unexpected output value", `TEST_CASE);
                        $finish;
                    end
                end
            end
        end
        else begin
            if (first_enque_done) begin
                $display("PASS %s", `TEST_CASE);
                $finish;
            end
            else begin
                $display("FAIL %s: No enques completed", `TEST_CASE);
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

else if (`TEST_CASE == "TEST_PIPELINING_MIXED") begin
// Make sure mixed pipelining works as expected. Note:
// This exercises relatively fine heap implementation
// details, so consider disabling if too flaky.
logic deque_done[1:0];

initial begin
    deque_done[0] = 0;
    deque_done[1] = 0;
end

always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter == 0) begin
            heap_in_en <= 1;
            heap_in_value <= 23;
            heap_in_priority <= 521;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        // A deque issued PIPELINE_DEPTH cycles after enque should
        // pick up the enque op. TODO(natre): Don't hardcode this.
        else if (counter == 4) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if (counter == 5) begin
            heap_in_en <= 1;
            heap_in_value <= 5218;
            heap_in_priority <= 74;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 6) begin
            heap_in_en <= 1;
            heap_in_value <= 2849;
            heap_in_priority <= 1023;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter == 10) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MAX;
        end

        if (heap_out_valid) begin
            if (heap_out_op_type == HEAP_OP_DEQUE_MIN) begin
                if ((heap_out_priority == 521) &&
                    (heap_out_value == 23)) begin
                    deque_done[0] <= 1;
                end
                else begin
                    $display("FAIL %s: Expected ", `TEST_CASE,
                             "(op: HEAP_OP_DEQUE_MIN, value: 23, priority: 521), got ",
                             "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                    $finish;
                end
            end
            else if (heap_out_op_type == HEAP_OP_DEQUE_MAX) begin
                if ((heap_out_priority == 1023) &&
                    (heap_out_value == 2849)) begin
                    deque_done[1] <= 1;
                end
                else begin
                    $display("FAIL %s: Expected ", `TEST_CASE,
                             "(op: HEAP_OP_DEQUE_MAX, value: 2849, priority: 1023), got ",
                             "(%s, %0d, %0d)", heap_out_op_type.name, heap_out_value, heap_out_priority);
                    $finish;
                end
            end
        end

        if (deque_done[0] & deque_done[1]) begin
            $display("PASS %s", `TEST_CASE);
            $finish;
        end
        else if (counter > 20) begin
            $display("FAIL %s: Test timed out", `TEST_CASE);
            $finish;
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_DEQUE_COLLISIONS") begin
// Make sure back-to-back deques landing at the same
// priority bucket are correctly handled (implicitly
// tests the heap's write forwarding logic).
logic [31:0] last_deque_counter;
logic [5:0] num_deques_done;

initial begin
    num_deques_done = 0;
    last_deque_counter = 0;
end

always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (init_done) begin
        counter <= counter + 1;
        if (counter <= 7) begin
            heap_in_en <= 1;
            heap_in_value <= counter + 5;
            heap_in_priority <= 123;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter < 15) begin
            // NOOP
        end
        else if (counter <= 22) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if (counter >= 50) begin
            if (num_deques_done == 0) begin
                $display("FAIL %s: Test timed out", `TEST_CASE);
            end
            else if (num_deques_done != 8) begin
                $display("FAIL %s: Expected 8 deque completions, saw %0d",
                         `TEST_CASE, num_deques_done);
            end
            else begin
                $display("PASS %s", `TEST_CASE);
            end
            $finish;
        end

        if (heap_out_valid && (heap_out_op_type == HEAP_OP_DEQUE_MIN)) begin
            num_deques_done <= num_deques_done + 1;
            last_deque_counter <= counter;

            if (num_deques_done != 0) begin
                if ((counter != last_deque_counter + 1) || (heap_out_priority != 123)) begin
                    $display("FAIL %s: Colliding deques were not pipelined", `TEST_CASE);
                    $finish;
                end
            end
        end
    end
    else if (test_timer > MAX_HEAP_INIT_CYCLES) begin
        $display("FAIL %s: Heap init timed out", `TEST_CASE);
        $finish;
    end
end
end

else if (`TEST_CASE == "TEST_RESET") begin
// Make sure rst works as expected
logic [31:0] num_enques_done;
logic second_init_done;
logic deque_done;
logic rst_issued;

initial begin
    rst_issued = 0;
    deque_done = 0;
    num_enques_done = 0;
    second_init_done = 0;
end

always @(posedge clk) begin
    rst <= 0;
    heap_in_en <= 0;
    heap_in_value <= 0;
    heap_in_priority <= 0;
    test_timer <= test_timer + 1;
    heap_in_op_type <= HEAP_OP_ENQUE;
    init_done <= init_done | heap_ready;

    if (second_init_done) begin
        counter <= counter + 1;
        if (counter < HEAP_MAX_NUM_ENTRIES) begin
            heap_in_en <= 1;
            heap_in_value <= 42;
            heap_in_priority <= counter;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter < (HEAP_MAX_NUM_ENTRIES + 10)) begin
            // NOOP
        end
        else if (counter == (HEAP_MAX_NUM_ENTRIES + 10)) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MAX;
        end
        else if (counter > (HEAP_MAX_NUM_ENTRIES + 20)) begin
            if ((num_enques_done == HEAP_MAX_NUM_ENTRIES) && deque_done) begin
                $display("PASS %s", `TEST_CASE);
            end
            else if (!deque_done) begin
                $display("FAIL %s: Expected 1 deque post reset, saw none", `TEST_CASE);
            end
            else begin
                $display("FAIL %s: Expected %0d enques post reset, only saw %0d",
                         `TEST_CASE, HEAP_MAX_NUM_ENTRIES, num_enques_done);
            end
            $finish;
        end

        if (heap_out_valid) begin
            if (heap_out_op_type == HEAP_OP_ENQUE) begin
                if (heap_out_value == 42) begin
                    num_enques_done <= num_enques_done + 1;
                end
                else begin
                    $display("FAIL %s: Unexpected output value", `TEST_CASE);
                    $finish;
                end
            end
            else if (heap_out_op_type == HEAP_OP_DEQUE_MAX) begin
                if ((heap_out_priority == (HEAP_MIN_NUM_PRIORITIES_AND_ENTRIES - 1)) &&
                    (heap_out_value == 42)) begin
                    deque_done <= 1;
                end
                else begin
                    $display("FAIL %s: Deque-max post reset does not satisfy heap property",
                             `TEST_CASE);
                    $finish;
                end
            end
            else begin
            end
        end
    end
    else if (rst_issued & heap_ready) begin
        if (heap_size != 0) begin
            $display("FAIL %s: Heap size is non-zero post reset", `TEST_CASE);
        end
        counter <= 0;
        second_init_done <= 1;
    end
    else if (init_done) begin
        counter <= counter + 1;
        if (counter <= 7) begin
            heap_in_en <= 1;
            heap_in_value <= counter + 5;
            heap_in_priority <= 123;
            heap_in_op_type <= HEAP_OP_ENQUE;
        end
        else if (counter < 15) begin
            // NOOP
        end
        else if (counter <= 18) begin
            heap_in_en <= 1;
            heap_in_op_type <= HEAP_OP_DEQUE_MIN;
        end
        else if (counter == 19) begin
            rst <= 1;
            rst_issued <= 1;
        end
        else if (counter > (MAX_HEAP_INIT_CYCLES << 2)) begin
            $display("FAIL %s: Heap rst timed out", `TEST_CASE);
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

// Heap instance
pipelined_heap #(
    .HEAP_BITMAP_WIDTH(HEAP_BITMAP_WIDTH),
    .HEAP_MAX_NUM_ENTRIES(HEAP_MAX_NUM_ENTRIES),
    .HEAP_ENTRY_VALUE_WIDTH(HEAP_ENTRY_VALUE_WIDTH)
)
heap (
    .clk(clk),
    .rst(rst),
    .ready(heap_ready),
    .in_en(heap_in_en),
    .in_op_type(heap_in_op_type),
    .in_he_value(heap_in_value),
    .in_he_priority(heap_in_priority),
    .out_valid(heap_out_valid),
    .out_op_type(heap_out_op_type),
    .out_he_value(heap_out_value),
    .out_he_priority(heap_out_priority),
    .size(heap_size),
    .num_ops_enque(heap_num_ops_enque),
    .num_ops_deque_min(heap_num_ops_deque_min),
    .num_ops_deque_max(heap_num_ops_deque_max)
);

endmodule
