import heap_ops_pkg::*;
// `define DEBUG

/**
 * Implements a wrapper for pipelined_heap.
 *
 * Since the pipelined heap itself offers a rather simplistic inter-
 * face, this module augments it with some additional functionality.
 * In particular, the wrapper:
 *
 * 1. Allows multiple operations (enque, deque-min, or deque-max) to
 *    be performed every cycle. This is implemented by maintaining a
 *    small input FIFO for enque ops, and two small output FIFOs for
 *    deque ops (one for deque-PRIMARY, another for deque-SECONDARY).
 *    Performing an operation involves simply enqueing into/dequeing
 *    from the appropriate FIFO.
 *
 * 2. Reduces the common-case latency of deque-PRIMARY ops. The module
 *    opportunistically (i.e., automatically) issues deque-PRIMARY ops
 *    whenever possible, storing the result in the corresponding out-
 *    FIFO. This allows the result to be accessed in 1 cycle (instead
 *    of 5 cycles, the end-to-end latency cost of the heap pipeline).
 *    Note that deque-SECONDARY ops are not performed automatically,
 *    but can be issued through the request/response interface.
 *
 * 3. Ensures that ops are not "lost". Any failed deque-* operations
 *    (due to, e.g., two back-to-back deques landing on a priority
 *    bucket with just one heap entry) are automatically re-issued.
 *
 * TODO(natre): rst is implemented for the pipelined heap, but not
 * for the wrapper itself. Fix this (OK for now since global reset
 * is not implemented anywhere yet).
 */
module pipelined_heap_wrapper #(
    parameter HEAP_BITMAP_WIDTH,
    parameter HEAP_MAX_NUM_ENTRIES,
    parameter HEAP_ENTRY_VALUE_WIDTH,
    parameter HEAP_OP_DEQUE_PRIMARY_TYPE,
    localparam HEAP_NUM_PRIORITIES = (HEAP_BITMAP_WIDTH ** 2),
    localparam HEAP_ENTRY_AWIDTH = ($clog2(HEAP_MAX_NUM_ENTRIES)),
    localparam HEAP_PRIORITY_AWIDTH = ($clog2(HEAP_NUM_PRIORITIES))
) (
    // General inputs
    input  logic                                clk,
    input  logic                                rst,

    // Enque
    input  logic                                in_enque_en,
    output logic                                in_enque_ready,
    input  logic [HEAP_ENTRY_VALUE_WIDTH-1:0]   in_enque_value,
    input  logic [HEAP_PRIORITY_AWIDTH-1:0]     in_enque_priority,

    // Deque-PRIMARY
    input  logic                                out_deque_primary_en,
    output logic                                out_deque_primary_ready,
    output logic [HEAP_ENTRY_VALUE_WIDTH-1:0]   out_deque_primary_value,
    output logic [HEAP_PRIORITY_AWIDTH-1:0]     out_deque_primary_priority,

    // Deque-SECONDARY (request)
    input  logic                                in_deque_secondary_req_en,
    output logic                                in_deque_secondary_req_ready,
    // Deque-SECONDARY (response)
    input  logic                                out_deque_secondary_en,
    output logic                                out_deque_secondary_ready,
    output logic [HEAP_ENTRY_VALUE_WIDTH-1:0]   out_deque_secondary_value,
    output logic [HEAP_PRIORITY_AWIDTH-1:0]     out_deque_secondary_priority,

    // Feedback
    output logic [HEAP_ENTRY_AWIDTH:0]          heap_size,
    output logic                                heap_ready
);

/**
 * Local/derived parameters.
 */
localparam DEQUE_FIFO_DEPTH = 4;
localparam ENQUE_FIFO_DEPTH = 64;
localparam DEQUE_FIFO_LOG_DEPTH = $clog2(DEQUE_FIFO_DEPTH);
localparam ENQUE_FIFO_LOG_DEPTH = $clog2(ENQUE_FIFO_DEPTH);
localparam FIFO_WIDTH = (HEAP_ENTRY_VALUE_WIDTH + HEAP_PRIORITY_AWIDTH);

localparam IS_PRIMARY_TYPE_MIN = (
    HEAP_OP_DEQUE_PRIMARY_TYPE == HEAP_OP_DEQUE_MIN);

localparam HEAP_OP_DEQUE_SECONDARY_TYPE = (
    IS_PRIMARY_TYPE_MIN ? HEAP_OP_DEQUE_MAX :
                          HEAP_OP_DEQUE_MIN);

localparam IS_SECONDARY_TYPE_MIN = (
    HEAP_OP_DEQUE_SECONDARY_TYPE == HEAP_OP_DEQUE_MIN);

/**
 * Local typedefs.
 */
typedef logic [HEAP_PRIORITY_AWIDTH-1:0] heap_priority_t;
typedef logic [HEAP_ENTRY_VALUE_WIDTH-1:0] heap_entry_value_t;

typedef enum logic [1:0] {
    DEQUE_SECONDARY_REQ_STATE_IDLE,
    DEQUE_SECONDARY_REQ_STATE_INIT,
    DEQUE_SECONDARY_REQ_STATE_WAIT
} deque_secondary_req_state_t;

/**
 * Housekeeping.
 */
// Enque in-FIFO
logic enque_fifo_full;
logic enque_fifo_empty;
logic enque_fifo_rdreq;
logic enque_fifo_wrreq;
heap_entry_value_t enque_fifo_q_value;
heap_priority_t enque_fifo_q_priority;

// Deque-PRIMARY out-FIFO
logic deque_primary_fifo_empty;
logic deque_primary_fifo_rdreq;
logic deque_primary_fifo_wrreq;
heap_entry_value_t deque_primary_fifo_data_value;
heap_priority_t deque_primary_fifo_data_priority;

// Deque-SECONDARY out-FIFO
logic deque_secondary_fifo_full;
logic deque_secondary_fifo_empty;
logic deque_secondary_fifo_rdreq;
logic deque_secondary_fifo_wrreq;
heap_entry_value_t deque_secondary_fifo_data_value;
heap_priority_t deque_secondary_fifo_data_priority;

// Pipelined heap
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

// Miscellaneous
logic [2:0] heap_num_ops_deque_primary;
logic [2:0] heap_num_ops_deque_secondary;

// Deque-SECONDARY FSM state
deque_secondary_req_state_t deque_secondary_req_state;
deque_secondary_req_state_t deque_secondary_req_state_next;

// Miscellaneous
logic [HEAP_ENTRY_AWIDTH:0] heap_size_plus_enques;

// Enque in-FIFO logic
assign in_enque_ready = !enque_fifo_full;
assign enque_fifo_wrreq = in_enque_ready & in_enque_en;

// Deque-PRIMARY out-FIFO logic
assign deque_primary_fifo_data_value = heap_out_value;
assign out_deque_primary_ready = !deque_primary_fifo_empty;
assign deque_primary_fifo_data_priority = heap_out_priority;
assign deque_primary_fifo_rdreq = (out_deque_primary_ready &
                                   out_deque_primary_en);

assign deque_primary_fifo_wrreq = (heap_out_valid & (heap_out_op_type ==
                                                     HEAP_OP_DEQUE_PRIMARY_TYPE));
// Deque-SECONDARY out-FIFO logic
assign deque_secondary_fifo_data_value = heap_out_value;
assign deque_secondary_fifo_data_priority = heap_out_priority;
assign out_deque_secondary_ready = !deque_secondary_fifo_empty;
assign deque_secondary_fifo_rdreq = (out_deque_secondary_en &
                                     out_deque_secondary_ready);

assign deque_secondary_fifo_wrreq = (heap_out_valid & (heap_out_op_type ==
                                                       HEAP_OP_DEQUE_SECONDARY_TYPE));
// Miscellaneous
assign heap_num_ops_deque_primary = (
    IS_PRIMARY_TYPE_MIN ? heap_num_ops_deque_min :
                          heap_num_ops_deque_max);

assign heap_num_ops_deque_secondary = (
    IS_SECONDARY_TYPE_MIN ? heap_num_ops_deque_min :
                            heap_num_ops_deque_max);

initial begin
    deque_secondary_req_state = DEQUE_SECONDARY_REQ_STATE_IDLE;
end

always @(*) begin
    heap_in_en = 0;
    heap_in_value = 0;
    heap_in_priority = 0;
    enque_fifo_rdreq = 0;
    heap_in_op_type = HEAP_OP_ENQUE;
    in_deque_secondary_req_ready = 0;
    heap_size_plus_enques = (heap_size + heap_num_ops_enque);
    deque_secondary_req_state_next = deque_secondary_req_state;

    // Deque-SECONDARY FSM
    case (deque_secondary_req_state)
        // Idle state: Raise request-ready if the deque-SECONDARY
        // output FIFO is empty. If request-enable is high, go to
        // the init state.
        DEQUE_SECONDARY_REQ_STATE_IDLE: begin
            in_deque_secondary_req_ready = ((heap_size != 0) &&
                                            !out_deque_secondary_ready);

            if (in_deque_secondary_req_ready & in_deque_secondary_req_en) begin
                deque_secondary_req_state_next = DEQUE_SECONDARY_REQ_STATE_INIT;
            end
        end
        // Init state: Insert a deque-SECONDARY operation into the
        // heap pipeline. Once the op is successful (it appears on
        // the pipeline output register), proceed to wait.
        DEQUE_SECONDARY_REQ_STATE_INIT: begin
            // Wait for the op to appear on the output
            if (deque_secondary_fifo_wrreq) begin
                deque_secondary_req_state_next = (
                    DEQUE_SECONDARY_REQ_STATE_WAIT);
            end
            // If the number of deque-SECONDARY ops in the pipeline
            // is 0 (i.e. either because we just entered this state,
            // or a prior op has been discarded), schedule a new op.
            else if ((heap_num_ops_deque_secondary == 0) &&
                     (heap_size != 0) && heap_ready) begin
                heap_in_en = 1;
                heap_in_op_type = HEAP_OP_DEQUE_SECONDARY_TYPE;
            end
        end
        // Wait state: The deque-SECONDARY op completed successfully.
        // Wait for the dequed entry to appear in the out FIFO, then
        // proceed to the idle state.
        DEQUE_SECONDARY_REQ_STATE_WAIT: begin
            if (out_deque_secondary_ready) begin
                deque_secondary_req_state_next = (
                    DEQUE_SECONDARY_REQ_STATE_IDLE);
            end
        end
    endcase

    // Performs arbitration for the pipelined heap
    // interface. In decreasing order of priority:
    //
    // 1. Deque-SECONDARY operations done manually
    //    (i.e. using the request interface above).
    //
    // 2. Deque-PRIMARY operations are issued if the
    //    underlying heap has at least one entry,
    //    the output FIFO is empty, and no deque-
    //    PRIMARY operations are outstanding.
    //
    // 3. Enque operations are issued if the input
    //    FIFO has at least one entry and the size
    //    of the underlying heap (including outst-
    //    anding enque operations) is LT the hard
    //    heap limit.
    if (heap_ready && !heap_in_en) begin
        if (heap_size != 0 && deque_primary_fifo_empty &&
            (heap_num_ops_deque_primary == 0) &&
            !deque_primary_fifo_wrreq) begin
            heap_in_en = 1;
            heap_in_op_type = HEAP_OP_DEQUE_PRIMARY_TYPE;
        end
        else if (!enque_fifo_empty &&
                 (heap_size_plus_enques <
                  HEAP_MAX_NUM_ENTRIES)) begin
            heap_in_en = 1;
            enque_fifo_rdreq = 1;
            heap_in_op_type = HEAP_OP_ENQUE;
            heap_in_value = enque_fifo_q_value;
            heap_in_priority = enque_fifo_q_priority;
        end
    end
end

always @(posedge clk) begin
    deque_secondary_req_state <= (
        deque_secondary_req_state_next);

    `ifdef DEBUG
    if (enque_fifo_wrreq) begin
        $display("[PHW] Inserting value %0d into in-FIFO",
                 in_enque_value);
    end
    `endif
end


// Enque in-FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(FIFO_WIDTH),
    .DEPTH(ENQUE_FIFO_DEPTH)
)
enque_fifo (
    .clock(clk),
    .data({in_enque_value, in_enque_priority}),
    .rdreq(enque_fifo_rdreq),
    .wrreq(enque_fifo_wrreq),
    .empty(enque_fifo_empty),
    .full(enque_fifo_full),
    .q({enque_fifo_q_value, enque_fifo_q_priority}),
    .usedw() // Unused
);

// Deque-PRIMARY out-FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(FIFO_WIDTH),
    .DEPTH(DEQUE_FIFO_DEPTH)
)
deque_primary_fifo (
    .clock(clk),
    .data({deque_primary_fifo_data_value, deque_primary_fifo_data_priority}),
    .rdreq(deque_primary_fifo_rdreq),
    .wrreq(deque_primary_fifo_wrreq),
    .empty(deque_primary_fifo_empty),
    .full(), // Unused
    .q({out_deque_primary_value, out_deque_primary_priority}),
    .usedw() // Unused
);

// Deque-SECONDARY out-FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(FIFO_WIDTH),
    .DEPTH(DEQUE_FIFO_DEPTH)
)
deque_secondary_fifo (
    .clock(clk),
    .data({deque_secondary_fifo_data_value, deque_secondary_fifo_data_priority}),
    .rdreq(deque_secondary_fifo_rdreq),
    .wrreq(deque_secondary_fifo_wrreq),
    .empty(deque_secondary_fifo_empty),
    .full(deque_secondary_fifo_full),
    .q({out_deque_secondary_value, out_deque_secondary_priority}),
    .usedw() // Unused
);

// Pipelined heap
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
