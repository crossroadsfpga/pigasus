import heap_ops_pkg::*;
// `define DEBUG

/**
 * Implements a min+max heap using a two-level Hierarchical
 * Find First Set (HFFS) Queue. The heap is fully pipelined,
 * capable of performing one operation (enque, deque-min, or
 * deque-max) every cycle.
 *
 * The heap structure (for HEAP_BITMAP_WIDTH=2) is as follows:
 *
 *                       L1 Bitmap: 1 0
 *                          ________| |________
 *                         |                   |
 *                        ---                 ---
 *            L2 Bitmaps: 1 0                 0 0
 *                        |
 *                   ------------
 *  Priority bucket: (Head, Tail)
 *                ______|    |_______
 *               |                   |
 * Heap Entries: A -> B -> C -> D -> E
 *
 * Free List: (Head, Tail)
 *             __|     |__
 *            |           |
 *            F -> ... -> Z
 *
 * A "1" in any bitmap indicates a non-empty priority bucket in the
 * corresponding subtree rooted at that node. In order to find the
 * min (or max) heap entry, we recursively follow the leftmost (or
 * rightmost) set bit in each bitmap starting from the root.
 *
 * ------------------------------------------------------------------
 *                             Glossary
 * ------------------------------------------------------------------
 * L1 bitmap is the root-level bitmap, where each bit corresponds
 *    to a unique L2 bitmap. The heap contains a single L1 bitmap
 *    and HEAP_BITMAP_WIDTH number of L2 bitmaps.
 *
 * L2 bitmaps are the leaf-level bitmaps, where each bit maps to
 *    a unique priority bucket. In all, the heap can represent
 *    HEAP_BITMAP_WIDTH^2 number of unique integer priorities.
 *
 * Priority Buckets (PBs) represent unique priorities. Each PB stores
 *    a 2-tuple of (head, tail) pointers (to heap entries); these are
 *    in turn used to implement a singly-linked list. If the priority
 *    bucket is empty, both pointers are invalid.
 *
 * Heap Entries (HEs) serve two purposes: they hold the value of the
 *    corresponding object, and they store a pointer to another heap
 *    entry. When an object is enqueued into the heap, it is first
 *    allocated a heap entry (from the Free List), which is then
 *    inserted into the corresponding priority bucket.
 *
 * Free List (FL) implements a singly-linked list of pointers to
 *    unused HEs which can be allocated to new objects.
 *
 * ------------------------------------------------------------------
 *                             Semantics
 * ------------------------------------------------------------------
 * Both enque and deque-* operations are implemented using a 5-stage
 * pipeline with the following steps:
 *
 * Stage 0: Register inputs
 * Stage 1: Compute the index of the L2 bitmap which this operation
 *          maps to (for enque, this is the given priority divided
 *          by HEAP_BITMAP_WIDTH; for deque-*, this is computed by
 *          performing FFS/FLS on the L1 bitmap), and issue a read
 *          for corresponding L2 bitmap.
 *
 * Stage 2: Compute the index of the PB which this operation maps to
 *          (for enque, this is just the given priority; for deque-*,
 *          this is computed by performing FFS/FLS on the L2 bitmap),
 *          and issue a read for the corresponding priority bucket.
 *
 * Stage 3: For enque, read the free list head pointer (i.e. allocate
 *          a new heap entry). For deque, read the PB's head pointer.
 *
 * Stage 4: Commit changes. For enque, updates: (a) the FL to commit
 *          the "pop" in the previous stage, (b) the allocated heap
 *          entry with the object data and next pointer, (c) the PB,
 *          if required, and (d) the {L1, L2} bitmaps, if required.
 *          The process is similar for deque-*, except it involves
 *          a "push" to the FL, and no HEs need to be updated. All
 *          output op signals are registered.
 *
 * Note that there may be data hazards in the pipeline (e.g., an L2
 * bitmap that is being read in Stage 2 may be concurrently updated
 * in Stage 4). As such, the heap implements write forwarding logic
 * across pipeline stages to ensure stall-free operation.
 *
 * Notes:
 * 1. Operations that would result in invalid state (e.g., enques into
 *    a full heap, or deques from an empty heap) are ignored. As such,
 *    it is the overlying module's responsibility to ensure these
 *    situations don't arise.
 *
 * 2. Once rst is pulsed, existing ops in the pipeline are discarded.
 *    Must also wait until "ready" is re-asserted to issue a new op.
 */
module pipelined_heap #(
    parameter HEAP_BITMAP_WIDTH,
    parameter HEAP_MAX_NUM_ENTRIES,
    parameter HEAP_ENTRY_VALUE_WIDTH,
    localparam HEAP_NUM_PRIORITIES = (HEAP_BITMAP_WIDTH ** 2),
    localparam HEAP_ENTRY_AWIDTH = ($clog2(HEAP_MAX_NUM_ENTRIES)),
    localparam HEAP_PRIORITY_AWIDTH = ($clog2(HEAP_NUM_PRIORITIES))
) (
    // General I/O
    input  logic                                clk,
    input  logic                                rst,
    output logic                                ready,

    // Operation input
    input  logic                                in_en,
    input  heap_op_t                            in_op_type,
    input  logic [HEAP_ENTRY_VALUE_WIDTH-1:0]   in_he_value,
    input  logic [HEAP_PRIORITY_AWIDTH-1:0]     in_he_priority,

    // Operation output
    output logic                                out_valid,
    output heap_op_t                            out_op_type,
    output logic [HEAP_ENTRY_VALUE_WIDTH-1:0]   out_he_value,
    output logic [HEAP_PRIORITY_AWIDTH-1:0]     out_he_priority,

    // Feedback signals
    output logic [HEAP_ENTRY_AWIDTH:0]          size,
    output logic [2:0]                          num_ops_enque,
    output logic [2:0]                          num_ops_deque_min,
    output logic [2:0]                          num_ops_deque_max
);

integer i;

/**
 * Derived parameters.
 */
localparam NUM_BITMAPS_L1           = 1;
localparam NUM_BITMAPS_L2           = (HEAP_BITMAP_WIDTH);
localparam L2_BITMAP_IDX_MASK       = (HEAP_BITMAP_WIDTH - 1);
localparam HEAP_ENTRY_PTR_T_WIDTH   = (HEAP_ENTRY_AWIDTH + 1);
localparam FREE_LIST_ENTRY_T_WIDTH  = (HEAP_ENTRY_PTR_T_WIDTH);
localparam HEAP_LOG_BITMAP_WIDTH    = ($clog2(HEAP_BITMAP_WIDTH));
localparam LIST_T_WIDTH             = (HEAP_ENTRY_PTR_T_WIDTH * 2);
localparam INVALID_PTR              = {HEAP_ENTRY_PTR_T_WIDTH{1'b1}};
localparam HEAP_ENTRY_T_WIDTH       = (HEAP_ENTRY_VALUE_WIDTH + HEAP_ENTRY_PTR_T_WIDTH);

/**
 * Local typedefs.
 */
typedef logic [HEAP_BITMAP_WIDTH-1:0] bitmap_t;
typedef logic [HEAP_PRIORITY_AWIDTH-1:0] heap_priority_t;
typedef logic [HEAP_ENTRY_PTR_T_WIDTH-1:0] heap_entry_ptr_t;
typedef logic [HEAP_ENTRY_VALUE_WIDTH-1:0] heap_entry_value_t;
typedef struct packed { heap_entry_ptr_t next; } free_list_entry_t;
typedef struct packed { heap_entry_ptr_t head; heap_entry_ptr_t tail; } list_t;
typedef struct packed { heap_entry_value_t value; heap_entry_ptr_t next; } heap_entry_t;

typedef enum logic [1:0] {
    FSM_STATE_IDLE,
    FSM_STATE_INIT,
    FSM_STATE_READY
} fsm_state_t;

// Heap state
list_t free_list; // Free list
bitmap_t l1_bitmap; // L1 bitmap
bitmap_t l2_bitmaps[NUM_BITMAPS_L2-1:0]; // L2 bitmaps

// Free list
logic fl_rden;
logic fl_wren;
logic fl_rdwr_conflict;
logic [FREE_LIST_ENTRY_T_WIDTH-1:0] fl_q;
logic [HEAP_ENTRY_AWIDTH-1:0] fl_rdaddress;
logic [HEAP_ENTRY_AWIDTH-1:0] fl_wraddress;
logic [FREE_LIST_ENTRY_T_WIDTH-1:0] fl_data;
logic [HEAP_ENTRY_AWIDTH-1:0] fl_wraddress_counter_r;

// Heap entries
logic he_rden;
logic he_wren;
logic he_rdwr_conflict;
logic [HEAP_ENTRY_T_WIDTH-1:0] he_q;
logic [HEAP_ENTRY_T_WIDTH-1:0] he_data;
logic [HEAP_ENTRY_AWIDTH-1:0] he_rdaddress;
logic [HEAP_ENTRY_AWIDTH-1:0] he_wraddress;

// Priority buckets
logic pb_rden;
logic pb_wren;
logic pb_rdwr_conflict;
logic [LIST_T_WIDTH-1:0] pb_q;
logic [LIST_T_WIDTH-1:0] pb_data;
logic [HEAP_PRIORITY_AWIDTH-1:0] pb_rdaddress;
logic [HEAP_PRIORITY_AWIDTH-1:0] pb_wraddress;
logic [HEAP_PRIORITY_AWIDTH-1:0] pb_wraddress_counter_r;

/**
 * Housekeeping.
 */
// Common pipeline metadata
logic                               reg_en_q[4:0];
heap_op_t                           reg_op_type_q[4:0];
logic                               reg_is_enque_q[4:0];
heap_priority_t                     reg_priority_q[4:0];
heap_entry_value_t                  reg_he_value_q[4:0];
bitmap_t                            reg_l2_bitmap_q[4:0];
logic                               reg_is_deque_min_q[4:0];
logic                               reg_is_deque_max_q[4:0];
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   reg_l1_bitmap_idx_q[4:0];
logic [HEAP_BITMAP_WIDTH-1:0]       reg_l2_bitmap_mask_q[4:0];
logic [HEAP_BITMAP_WIDTH-1:0]       reg_l1_bitmap_mask_q[4:0];

// Stage 0 metadata
bitmap_t                            reg_l1_bitmap_q0 = 0;

// Stage 1 metadata
logic                               en_q1;
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   l1_bitmap_idx_q1;

// Stage 2 metadata
logic                               reg_pb_rdwr_conflict_q2 = 0;
logic                               en_q2;
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   l2_bitmap_idx_q2;

// Stage 3 metadata
logic                               reg_he_rdwr_conflict_q3 = 0;
logic                               reg_fl_rdwr_conflict_q3 = 0;
list_t                              reg_pb_q3 = 0;
logic                               en_q3;
logic                               is_enque_q3;
logic                               pb_empty_q3;
logic                               fl_empty_q3;

// Stage 4 metadata
free_list_entry_t                   reg_fl_data_q4 = 0;
heap_entry_t                        reg_he_data_q4 = 0;
list_t                              reg_pb_data_q4 = 0;
logic                               en_q4;
logic                               pb_empty_q4;
heap_entry_value_t                  he_value_q4;
bitmap_t                            l2_bitmap_data_q4;

// Init signals
fsm_state_t                         state = FSM_STATE_IDLE;
logic                               pb_init_done_r = 0;
logic                               fl_init_done_r = 0;
logic                               pb_init_done;
logic                               fl_init_done;
fsm_state_t                         state_next;

// Intermediate signals
bitmap_t                            int_l1_bitmap;
list_t                              int_free_list;
free_list_entry_t                   int_fl_q;
free_list_entry_t                   int_fl_data;
heap_entry_t                        int_he_q;
heap_entry_t                        int_he_data;
list_t                              int_pb_q;
list_t                              int_pb_data;
logic [HEAP_ENTRY_AWIDTH:0]         int_size;

// Miscellaneous signals
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   ffs_l1_inst_msb;
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   ffs_l1_inst_lsb;
logic                               ffs_l1_inst_zero;
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   ffs_l2_inst_msb;
logic [HEAP_LOG_BITMAP_WIDTH-1:0]   ffs_l2_inst_lsb;
logic                               ffs_l2_inst_zero;

assign fl_data = int_fl_data;
assign he_data = int_he_data;
assign pb_data = int_pb_data;
assign pb_empty_q4 = (reg_pb_q3.head == reg_pb_q3.tail);

// Output assignments
assign out_valid = reg_en_q[4];
assign out_op_type = reg_op_type_q[4];
assign out_he_value = reg_he_value_q[4];
assign out_he_priority = reg_priority_q[4];
assign ready = !rst & (state == FSM_STATE_READY);

initial begin
    // Initialize the free list
    free_list.head = 0;
    free_list.tail = (HEAP_MAX_NUM_ENTRIES - 1);

    // Initialize the bitmaps
    l1_bitmap = 0;
    for (i = 0; i < NUM_BITMAPS_L2; i = i + 1) begin
        l2_bitmaps[i] = 0;
    end

    // Initialize pipeline stages
    for (i = 0; i <= 4; i = i + 1) begin
        reg_en_q[i] = 0;
        reg_op_type_q[i] = HEAP_OP_ENQUE;
        reg_is_enque_q[i] = 0;
        reg_priority_q[i] = 0;
        reg_he_value_q[i] = 0;
        reg_l2_bitmap_q[i] = 0;
        reg_is_deque_min_q[i] = 0;
        reg_is_deque_max_q[i] = 0;
        reg_l1_bitmap_idx_q[i] = 0;
        reg_l2_bitmap_mask_q[i] = 0;
        reg_l1_bitmap_mask_q[i] = 0;
    end

    // Initialize outputs
    size = 0;
end

always @(*) begin
    num_ops_enque = 0;
    num_ops_deque_min = 0;
    num_ops_deque_max = 0;

    // Compute the outstanding op counts. The final
    // (output) pipeline stage is excluded since it
    // represents an already-committed operation.
    for (i = 0; i <= 3; i = i + 1) begin
        num_ops_enque = (
            num_ops_enque +
            (reg_en_q[i] & reg_is_enque_q[i]));

        num_ops_deque_min = (
            num_ops_deque_min +
            (reg_en_q[i] & reg_is_deque_min_q[i]));

        num_ops_deque_max = (
            num_ops_deque_max +
            (reg_en_q[i] & reg_is_deque_max_q[i]));
    end
end

always @(*) begin
    en_q1 = 0;
    l1_bitmap_idx_q1 = 0;
    en_q2 = 0;
    l2_bitmap_idx_q2 = 0;
    en_q3 = 0;
    is_enque_q3 = 0;
    pb_empty_q3 = 0;
    fl_empty_q3 = 0;
    en_q4 = 0;
    he_value_q4 = 0;
    l2_bitmap_data_q4 = reg_l2_bitmap_q[3];

    int_l1_bitmap = l1_bitmap;
    int_free_list = free_list;
    int_fl_q = fl_q;
    int_he_q = he_q;
    int_pb_q = pb_q;
    int_fl_data = 0;
    int_he_data = 0;
    int_pb_data = reg_pb_q3;
    int_size = size;

    fl_rden = 0;
    fl_wren = 0;
    fl_rdaddress = 0;
    fl_wraddress = 0;
    fl_rdwr_conflict = 0;

    pb_rden = 0;
    pb_wren = 0;
    pb_rdaddress = 0;
    pb_wraddress = 0;
    pb_rdwr_conflict = 0;

    he_rden = 0;
    he_wren = 0;
    he_rdaddress = 0;
    he_wraddress = 0;
    he_rdwr_conflict = 0;

    state_next = state;
    fl_init_done = fl_init_done_r;
    pb_init_done = pb_init_done_r;

    // Initialization state
    if (state == FSM_STATE_INIT) begin
        if (!fl_init_done_r) begin
            fl_wren = 1;
            fl_wraddress = fl_wraddress_counter_r;
            int_fl_data.next = fl_wraddress_counter_r + 1;

            fl_init_done = (fl_wraddress_counter_r ==
                            (HEAP_MAX_NUM_ENTRIES - 1));
        end
        if (!pb_init_done_r) begin
            pb_wren = 1;
            int_pb_data.head = INVALID_PTR;
            int_pb_data.tail = INVALID_PTR;
            pb_wraddress = pb_wraddress_counter_r;

            pb_init_done = (pb_wraddress_counter_r ==
                            (HEAP_NUM_PRIORITIES - 1));
        end
        // Done initializing both the free list and
        // priority buckets. Proceed to ready state.
        if (fl_init_done & pb_init_done) begin
            state_next = FSM_STATE_READY;
        end
    end
    else begin
        /**
         * Stage 4: Perform writes: update the L1, L2 bitmaps, the
         * priority bucket, the free list and free list entry, and
         * the heap entry.
         */
        if (reg_en_q[3]) begin
            en_q4 = 1;
            // The heap entry was updated on the last cycle
            if (reg_en_q[4] && reg_he_rdwr_conflict_q3) begin
                int_he_q = reg_he_data_q4;
            end
            // The free list entry was updated on the last cycle
            if (reg_en_q[4] && reg_fl_rdwr_conflict_q3) begin
                int_fl_q = reg_fl_data_q4;
            end

            // Perform enque
            if (reg_is_enque_q[3]) begin
                // Compute updated bitmaps
                l2_bitmap_data_q4 = (reg_l2_bitmap_q[3] | reg_l2_bitmap_mask_q[3]);
                int_l1_bitmap = (l1_bitmap | reg_l1_bitmap_mask_q[3]);

                // Update the heap entry
                he_wren = 1;
                he_wraddress = free_list.head[HEAP_ENTRY_AWIDTH-1:0];
                int_he_data.next = reg_pb_q3.head;
                int_he_data.value = reg_he_value_q[3];

                // Update the free list (head and tail)
                if (free_list.head == free_list.tail) begin
                    int_free_list.head = INVALID_PTR;
                    int_free_list.tail = INVALID_PTR;
                end
                else begin
                    // Update head, tail is unchanged
                    int_free_list.head = int_fl_q.next;
                end

                // Update the priority bucket
                pb_wren = 1;
                pb_wraddress = reg_priority_q[3];
                if (reg_pb_q3.head == INVALID_PTR) begin
                    int_pb_data.tail = he_wraddress;
                end
                int_pb_data.head = he_wraddress;

                // Update the value
                he_value_q4 = reg_he_value_q[3];

                // Update the heap size
                int_size = size + 1'b1;
            end
            // Perform deque
            else begin
                // Update the priority bucket
                pb_wren = 1;
                pb_wraddress = reg_priority_q[3];
                if (reg_pb_q3.head == reg_pb_q3.tail) begin
                    int_pb_data.head = INVALID_PTR;
                    int_pb_data.tail = INVALID_PTR;
                end
                else begin
                    // Update head, tail is unchanged
                    int_pb_data.head = int_he_q.next;
                end

                // Update the free list
                int_free_list.tail = reg_pb_q3.head;
                if (free_list.head == INVALID_PTR) begin
                    int_free_list.head = reg_pb_q3.head;
                end
                else begin
                    // Update tail free list entry
                    fl_wren = 1;
                    int_fl_data.next = reg_pb_q3.head;
                    fl_wraddress = free_list.tail[HEAP_ENTRY_AWIDTH-1:0];
                end

                // Update the value
                he_value_q4 = int_he_q.value;

                // Compute updated bitmaps
                if (pb_empty_q4) begin
                    l2_bitmap_data_q4 = (reg_l2_bitmap_q[3] &
                                         ~reg_l2_bitmap_mask_q[3]);

                    if (l2_bitmap_data_q4 == 0) begin
                        int_l1_bitmap = (l1_bitmap &
                                         ~reg_l1_bitmap_mask_q[3]);
                    end
                end

                // Update the heap size
                int_size = size - 1'b1;
            end
        end

        /**
         * Stage 3: Read the free list and the corresponding heap entry.
         */
        if (reg_en_q[2]) begin
            // The target priority bucket is being updated on this cycle
            if (en_q4 && (reg_priority_q[3] == reg_priority_q[2])) begin
                int_pb_q = int_pb_data;
            end
            // The PB was updated on the last cycle (and thus never read)
            else if (reg_en_q[4] && reg_pb_rdwr_conflict_q2) begin
                int_pb_q = reg_pb_data_q4;
            end
            // Fallthrough: default to pb_q

            pb_empty_q3 = (int_pb_q.head == INVALID_PTR);
            fl_empty_q3 = (int_free_list.head == INVALID_PTR);

            // Disable pipeline stage op if:
            // 1. Enqueing and the free list is empty, OR
            // 2. Dequeing and the priority bucket is empty
            en_q3 = !((reg_is_enque_q[2] && fl_empty_q3) ||
                      (!reg_is_enque_q[2] && pb_empty_q3));

            // Dequeing, read the heap entry
            if (en_q3 && !reg_is_enque_q[2]) begin
                he_rden = 1;
                he_rdaddress = int_pb_q.head[HEAP_ENTRY_AWIDTH-1:0];
                if (he_wren && (he_wraddress == he_rdaddress)) begin
                    he_rden = 0; // Disable reads during writes
                    he_rdwr_conflict = 1;
                end
            end
            // Enqueing, read the free list entry
            if (en_q3 && reg_is_enque_q[2]) begin
                fl_rden = 1;
                fl_rdaddress = int_free_list.head[HEAP_ENTRY_AWIDTH-1:0];
                if (fl_wren && (fl_wraddress == fl_rdaddress)) begin
                    fl_rden = 0; // Disable reads during writes
                    fl_rdwr_conflict = 1;
                end
            end
        end

        /**
         * Stage 2: Compute L2 bitmap index and read the
         * corresponding priority bucket (head and tail).
         */
        if (reg_en_q[1]) begin
            if (reg_is_enque_q[1]) begin
                en_q2 = 1;
                pb_rden = 1;
                pb_rdaddress = reg_priority_q[1];
                l2_bitmap_idx_q2 = (reg_priority_q[1] & L2_BITMAP_IDX_MASK);
            end
            else if (!ffs_l2_inst_zero) begin
                en_q2 = 1;
                pb_rden = 1;
                l2_bitmap_idx_q2 = (
                    (reg_op_type_q[1] == HEAP_OP_DEQUE_MAX) ?
                        ffs_l2_inst_msb : ffs_l2_inst_lsb
                );
                pb_rdaddress = (l2_bitmap_idx_q2 +
                                (reg_l1_bitmap_idx_q[1] << HEAP_LOG_BITMAP_WIDTH));
            end
            // Disable priority bucket reads during conflicting writes
            if (en_q4 && (reg_priority_q[3] == pb_rdaddress)) begin
                pb_rdwr_conflict = 1;
                pb_rden = 0;
            end
        end

        /**
         * Stage 1: Compute L1 bitmap index
         * and read corresponding L2 bitmap.
         */
        if (reg_en_q[0]) begin
            if (reg_is_enque_q[0]) begin
                en_q1 = 1;
                l1_bitmap_idx_q1 = (
                    reg_priority_q[0] >> HEAP_LOG_BITMAP_WIDTH);
            end
            else if (!ffs_l1_inst_zero) begin
                en_q1 = 1;
                l1_bitmap_idx_q1 = (
                    (reg_op_type_q[0] == HEAP_OP_DEQUE_MAX) ?
                        ffs_l1_inst_msb : ffs_l1_inst_lsb
                );
            end
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        // Reset free list
        free_list.head <= 0;
        free_list.tail <= (HEAP_MAX_NUM_ENTRIES - 1);

        // Reset bitmaps
        l1_bitmap = 0;
        for (i = 0; i < NUM_BITMAPS_L2; i = i + 1) begin
            l2_bitmaps[i] <= 0;
        end

        // Reset pipeline stages
        for (i = 0; i <= 4; i = i + 1) begin
            reg_en_q[i] <= 0;
        end

        // Reset init signals
        fl_init_done_r <= 0;
        pb_init_done_r <= 0;
        fl_wraddress_counter_r <= 0;
        pb_wraddress_counter_r <= 0;

        // Reset FSM state and size
        state <= FSM_STATE_INIT;
        size <= 0;
    end
    else begin
        /**
         * Stage 4: Perform writes: update the L1, L2 bitmaps, the
         * priority bucket, the free list and free list entry, and
         * the heap entry.
         */
        reg_en_q[4] <= en_q4;
        reg_he_value_q[4] <= he_value_q4;
        reg_op_type_q[4] <= reg_op_type_q[3];
        reg_is_enque_q[4] <= reg_is_enque_q[3];
        reg_priority_q[4] <= reg_priority_q[3];
        reg_is_deque_min_q[4] <= reg_is_deque_min_q[3];
        reg_is_deque_max_q[4] <= reg_is_deque_max_q[3];

        reg_pb_data_q4 <= int_pb_data;
        reg_he_data_q4 <= int_he_data;
        reg_fl_data_q4 <= int_fl_data;
        reg_l2_bitmap_q[4] <= l2_bitmap_data_q4;
        reg_l1_bitmap_idx_q[4] <= reg_l1_bitmap_idx_q[3];
        reg_l2_bitmap_mask_q[4] <= reg_l2_bitmap_mask_q[3];
        reg_l1_bitmap_mask_q[4] <= reg_l1_bitmap_mask_q[3];

        // Update the heap size, free list and bitmaps
        size <= int_size;
        free_list <= int_free_list;
        l1_bitmap <= int_l1_bitmap;
        if (en_q4) begin
            l2_bitmaps[reg_l1_bitmap_idx_q[3]] <= l2_bitmap_data_q4;
        end

        `ifdef DEBUG
        if (reg_en_q[3] && !reg_is_enque_q[3] && en_q4) begin
            $display(
                "[PH] Deque is updating (L1_idx, priority) = (%0d, %0d)",
                reg_l1_bitmap_idx_q[3], reg_priority_q[3],
                " from %b to %b, pb contents %b",
                reg_l2_bitmap_q[3], l2_bitmap_data_q4, int_pb_data);
        end
        `endif

        /**
         * Stage 3: Read the free list and corresponding heap entry.
         */
        reg_en_q[3] <= en_q3;
        reg_op_type_q[3] <= reg_op_type_q[2];
        reg_is_enque_q[3] <= reg_is_enque_q[2];
        reg_priority_q[3] <= reg_priority_q[2];
        reg_he_value_q[3] <= reg_he_value_q[2];
        reg_is_deque_min_q[3] <= reg_is_deque_min_q[2];
        reg_is_deque_max_q[3] <= reg_is_deque_max_q[2];

        reg_pb_q3 <= int_pb_q;
        reg_he_rdwr_conflict_q3 <= he_rdwr_conflict;
        reg_fl_rdwr_conflict_q3 <= fl_rdwr_conflict;
        reg_l1_bitmap_idx_q[3] <= reg_l1_bitmap_idx_q[2];
        reg_l2_bitmap_mask_q[3] <= reg_l2_bitmap_mask_q[2];
        reg_l1_bitmap_mask_q[3] <= reg_l1_bitmap_mask_q[2];

        reg_l2_bitmap_q[3] <= (
            (en_q4 && (reg_l1_bitmap_idx_q[3] == reg_l1_bitmap_idx_q[2])) ?
                l2_bitmap_data_q4 : reg_l2_bitmap_q[2]);

        `ifdef DEBUG
        if (reg_en_q[2] && !en_q3) begin
            if (reg_is_deque_min_q[2]) begin
                $display("[PH] Deque-min rejected at Stage 2->3, priority %0d,",
                         reg_priority_q[2], " pb contents %b", int_pb_q);
            end
            else if (reg_is_deque_max_q[2]) begin
                $display("[PH] Deque-max rejected at Stage 2->3, priority %0d,",
                         reg_priority_q[2], " pb contents %b", int_pb_q);
            end
            else begin
                $display("[PH] Enque rejected at Stage 2->3, value %0d",
                         reg_he_value_q[2]);
            end
        end
        `endif

        /**
         * Stage 2: Compute L2 bitmap index and read the
         * corresponding priority bucket (head and tail).
         */
        reg_en_q[2] <= en_q2;
        reg_priority_q[2] <= pb_rdaddress;
        reg_op_type_q[2] <= reg_op_type_q[1];
        reg_is_enque_q[2] <= reg_is_enque_q[1];
        reg_he_value_q[2] <= reg_he_value_q[1];
        reg_is_deque_min_q[2] <= reg_is_deque_min_q[1];
        reg_is_deque_max_q[2] <= reg_is_deque_max_q[1];

        reg_pb_rdwr_conflict_q2 <= pb_rdwr_conflict;
        reg_l1_bitmap_idx_q[2] <= reg_l1_bitmap_idx_q[1];
        reg_l2_bitmap_mask_q[2] <= (1 << l2_bitmap_idx_q2);
        reg_l1_bitmap_mask_q[2] <= reg_l1_bitmap_mask_q[1];

        reg_l2_bitmap_q[2] <= (
            (en_q4 && (reg_l1_bitmap_idx_q[3] == reg_l1_bitmap_idx_q[1])) ?
                l2_bitmap_data_q4 : reg_l2_bitmap_q[1]);

        `ifdef DEBUG
        if (reg_en_q[1] && !en_q2) begin
            if (reg_is_deque_min_q[1]) begin
                $display("[PH] Deque-min rejected at Stage 1->2");
            end
            else if (reg_is_deque_max_q[1]) begin
                $display("[PH] Deque-max rejected at Stage 1->2");
            end
        end
        `endif

        /**
         * Stage 1: Compute L1 bitmap index
         * and read corresponding L2 bitmap.
         */
        reg_en_q[1] <= en_q1;
        reg_op_type_q[1] <= reg_op_type_q[0];
        reg_is_enque_q[1] <= reg_is_enque_q[0];
        reg_priority_q[1] <= reg_priority_q[0];
        reg_he_value_q[1] <= reg_he_value_q[0];
        reg_is_deque_min_q[1] <= reg_is_deque_min_q[0];
        reg_is_deque_max_q[1] <= reg_is_deque_max_q[0];

        reg_l1_bitmap_idx_q[1] <= l1_bitmap_idx_q1;
        reg_l1_bitmap_mask_q[1] <= (1 << l1_bitmap_idx_q1);

        reg_l2_bitmap_mask_q[1] <= 0;
        reg_l2_bitmap_q[1] <= (
            (en_q4 && (reg_l1_bitmap_idx_q[3] == l1_bitmap_idx_q1)) ?
                l2_bitmap_data_q4 : l2_bitmaps[l1_bitmap_idx_q1]);

        `ifdef DEBUG
        if (reg_en_q[0] && reg_is_deque_min_q[0] && !en_q1) begin
            $display("[PH] Deque-min rejected at Stage 0->1");
        end
        else if (reg_en_q[0] && reg_is_deque_max_q[0] && !en_q1) begin
            $display("[PH] Deque-max rejected at Stage 0->1");
        end
        `endif

        /**
         * Stage 0: Register inputs.
         */
        reg_en_q[0] <= (ready & in_en);
        reg_op_type_q[0] <= in_op_type;
        reg_he_value_q[0] <= in_he_value;
        reg_priority_q[0] <= in_he_priority;
        reg_is_enque_q[0] <= (in_op_type == HEAP_OP_ENQUE);
        reg_is_deque_min_q[0] <= (in_op_type == HEAP_OP_DEQUE_MIN);
        reg_is_deque_max_q[0] <= (in_op_type == HEAP_OP_DEQUE_MAX);

        reg_l2_bitmap_q[0] <= 0;
        reg_l1_bitmap_idx_q[0] <= 0;
        reg_l2_bitmap_mask_q[0] <= 0;
        reg_l1_bitmap_mask_q[0] <= 0;
        reg_l1_bitmap_q0 <= int_l1_bitmap;

        `ifdef DEBUG
        if (in_en) begin
            if (in_op_type == HEAP_OP_ENQUE) begin
                $display("[PH] Inserting value %0d with priority %0d",
                         in_he_value, in_he_priority);
            end
            else if (in_op_type == HEAP_OP_DEQUE_MIN) begin
                $display("[PH] Dequeing-min, heap size is: %0d, ",
                         size, "L1 bitmap is: %b", int_l1_bitmap);
            end
            else begin
                $display("[PH] Dequeing-max, heap size is: %0d, ",
                         size, "L1 bitmap is: %b", int_l1_bitmap);
            end
        end
        `endif

        // Register init signals
        fl_init_done_r <= fl_init_done;
        pb_init_done_r <= pb_init_done;
        fl_wraddress_counter_r <= fl_wraddress + 1;
        pb_wraddress_counter_r <= pb_wraddress + 1;

        `ifdef DEBUG
        if ((state == FSM_STATE_INIT) &&
            (state_next == FSM_STATE_READY)) begin
            $display("[PH] Heap initialization complete");
        end
        `endif

        // Update FSM state
        state <= state_next;
    end
end

// Free-list entries
bram_simple2port #(
    .DWIDTH(FREE_LIST_ENTRY_T_WIDTH),
    .AWIDTH(HEAP_ENTRY_AWIDTH),
    .DEPTH(HEAP_MAX_NUM_ENTRIES),
    .IS_OUTDATA_REG(0)
)
free_list_entries (
    .clock(clk),
    .data(fl_data),
    .rden(fl_rden),
    .wren(fl_wren),
    .rdaddress(fl_rdaddress),
    .wraddress(fl_wraddress),
    .q(fl_q)
);

// Heap entries
bram_simple2port #(
    .DWIDTH(HEAP_ENTRY_T_WIDTH),
    .AWIDTH(HEAP_ENTRY_AWIDTH),
    .DEPTH(HEAP_MAX_NUM_ENTRIES),
    .IS_OUTDATA_REG(0)
)
heap_entries (
    .clock(clk),
    .data(he_data),
    .rden(he_rden),
    .wren(he_wren),
    .rdaddress(he_rdaddress),
    .wraddress(he_wraddress),
    .q(he_q)
);

// Priority buckets
bram_simple2port #(
    .DWIDTH(LIST_T_WIDTH),
    .AWIDTH(HEAP_PRIORITY_AWIDTH),
    .DEPTH(HEAP_NUM_PRIORITIES),
    .IS_OUTDATA_REG(0)
)
priority_buckets (
    .clock(clk),
    .data(pb_data),
    .rden(pb_rden),
    .wren(pb_wren),
    .rdaddress(pb_rdaddress),
    .wraddress(pb_wraddress),
    .q(pb_q)
);

// L1 FFS
ffs #(
    .WIDTH_LOG(HEAP_LOG_BITMAP_WIDTH)
)
ffs_l1_inst (
    .x(reg_l1_bitmap_q0),
    .msb(ffs_l1_inst_msb),
    .lsb(ffs_l1_inst_lsb),
    .zero(ffs_l1_inst_zero)
);

// L2 FFS
ffs #(
    .WIDTH_LOG(HEAP_LOG_BITMAP_WIDTH)
)
ffs_l2_inst (
    .x(reg_l2_bitmap_q[1]),
    .msb(ffs_l2_inst_msb),
    .lsb(ffs_l2_inst_lsb),
    .zero(ffs_l2_inst_zero)
);

endmodule
