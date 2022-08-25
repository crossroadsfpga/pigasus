`include "./src/struct_s.sv"

import heap_ops_pkg::*;

/**
 * Implements a bounded WSJF queue using a pipelined heap.
 */
module bounded_wsjf_queue(
    // General inputs
    input  logic            clk,
    input  logic            rst,

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

// Instantiate the min-heap
pipelined_heap_wrapper #(
    .HEAP_BITMAP_WIDTH(HEAP_BITMAP_WIDTH),
    .HEAP_MAX_NUM_ENTRIES(HEAP_MAX_NUM_ENTRIES),
    .HEAP_ENTRY_VALUE_WIDTH(OOO_FLOW_ID_AWIDTH),
    .HEAP_OP_DEQUE_PRIMARY_TYPE(HEAP_OP_DEQUE_MIN)
) heap_wrapper (
    // General inputs
    .clk(clk),
    .rst(rst),
    // Enque
    .in_enque_en(in_enque_en),
    .in_enque_ready(in_enque_ready),
    .in_enque_value(in_enque_ooo_flow_id),
    .in_enque_priority(in_enque_priority),
    // Deque-PRIMARY
    .out_deque_primary_en(out_deque_min_en),
    .out_deque_primary_ready(out_deque_min_ready),
    .out_deque_primary_value(out_deque_min_ooo_flow_id),
    .out_deque_primary_priority(out_deque_min_priority),
    // Deque-SECONDARY (request)
    .in_deque_secondary_req_en(in_deque_max_req_en),
    .in_deque_secondary_req_ready(in_deque_max_req_ready),
    // Deque-SECONDARY (response)
    .out_deque_secondary_en(out_deque_max_en),
    .out_deque_secondary_ready(out_deque_max_ready),
    .out_deque_secondary_value(out_deque_max_ooo_flow_id),
    .out_deque_secondary_priority(out_deque_max_priority),
    // Feedback
    .heap_size(queue_size),
    .heap_ready(queue_ready)
);

endmodule
