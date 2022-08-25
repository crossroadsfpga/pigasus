`include "./src/struct_s.sv"

/**
 * Implements a bounded FCFS queue using a simple FIFO.
 */
module bounded_fcfs_queue(
    // General inputs
    input  logic            clk,
    input  logic            rst, // TODO(natre): Impl.

    // Enque
    input  logic            in_enque_en,
    input  ooo_flow_id_t    in_enque_ooo_flow_id,
    input  heap_priority_t  in_enque_priority,
    output logic            in_enque_ready,

    // Deque-min
    input  logic            out_deque_min_en,
    output ooo_flow_id_t    out_deque_min_ooo_flow_id,
    output heap_priority_t  out_deque_min_priority,
    output logic            out_deque_min_ready,

    // Deque-max (request)
    input  logic            in_deque_max_req_en,
    output logic            in_deque_max_req_ready,
    // Deque-max (output)
    input  logic            out_deque_max_en,
    output ooo_flow_id_t    out_deque_max_ooo_flow_id,
    output heap_priority_t  out_deque_max_priority,
    output logic            out_deque_max_ready,

    // Feedback
    output heap_size_t      queue_size,
    output logic            queue_ready
);

/**
 * Local parameters.
 */
localparam FIFO_WIDTH = (OOO_FLOW_ID_AWIDTH + HEAP_PRIORITY_AWIDTH);

/**
 * Housekeeping.
 */
// FCFS queue
logic fcfs_queue_full;
logic fcfs_queue_rdreq;
logic fcfs_queue_wrreq;
logic fcfs_queue_empty;
heap_priority_t fcfs_queue_q_priority;
ooo_flow_id_t fcfs_queue_q_ooo_flow_id;

// Deque requests
logic deque_max_req_done;
logic deque_min_req_done;
logic deque_max_req_en_latch;

// Miscellaneous logic
assign queue_ready = 1'b1;

// Enque logic
assign in_enque_ready = !fcfs_queue_full;
assign fcfs_queue_wrreq = in_enque_en & in_enque_ready;

// Deque-max logic
assign in_deque_max_req_ready = (!out_deque_max_ready &
                                 !deque_max_req_en_latch);
initial begin
    out_deque_max_ready = 0;
    out_deque_max_priority = 0;
    deque_max_req_en_latch = 0;
    out_deque_max_ooo_flow_id = 0;

    out_deque_min_ready = 0;
    out_deque_min_priority = 0;
    out_deque_min_ooo_flow_id = 0;
end

// Deque-max logic
always @(posedge clk) begin
    // A deque-max entry is already available on the output.
    // Deassert ready, preparing to accept the next request.
    if (out_deque_max_en & out_deque_max_ready) begin
        out_deque_max_ready <= 0;
    end
    // A deque-max was performed on this cycle. Raise
    // ready and register the output data. Also reset
    // the request latch, indicating that no requests
    // are outstanding.
    else if (deque_max_req_done) begin
        out_deque_max_ready <= 1;
        deque_max_req_en_latch <= 0;
        out_deque_max_priority <= fcfs_queue_q_priority;
        out_deque_max_ooo_flow_id <= fcfs_queue_q_ooo_flow_id;
    end
    // Deque-max was requested on this cycle, update the latch
    else if (in_deque_max_req_en & in_deque_max_req_ready) begin
        deque_max_req_en_latch <= 1;
    end

    // Consume the deque-min entry on the output
    if (out_deque_min_en & out_deque_min_ready) begin
        out_deque_min_ready <= 0;
    end
    // A deque-min just completed on this cycle.
    // Raise ready and register the output data.
    else if (deque_min_req_done) begin
        out_deque_min_ready <= 1;
        out_deque_min_priority <= fcfs_queue_q_priority;
        out_deque_min_ooo_flow_id <= fcfs_queue_q_ooo_flow_id;
    end
end

// Deque arbitration
always @(*) begin
    fcfs_queue_rdreq = 0;
    deque_min_req_done = 0;
    deque_max_req_done = 0;

    if (!fcfs_queue_empty) begin
        // If required, perform deque-max
        if (deque_max_req_en_latch) begin
            deque_max_req_done = 1;
            fcfs_queue_rdreq = 1;
        end
        // No deque-min entry is currently available on the
        // output, (opportunistically) perform a deque-min.
        else if (!out_deque_min_ready) begin
            deque_min_req_done = 1;
            fcfs_queue_rdreq = 1;
        end
    end
end

// FCFS queue
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(FIFO_WIDTH),
    .DEPTH(MAX_NUM_OOO_FLOWS)
)
fcfs_queue (
    .clock(clk),
    .data({in_enque_ooo_flow_id, in_enque_priority}),
    .rdreq(fcfs_queue_rdreq),
    .wrreq(fcfs_queue_wrreq),
    .empty(fcfs_queue_empty),
    .full(fcfs_queue_full),
    .q({fcfs_queue_q_ooo_flow_id, fcfs_queue_q_priority}),
    .usedw(queue_size)
);

endmodule
