`include "./src/struct_s.sv"
// `define DEBUG

/**
 * Implements a scheduler for the flow reassembly module, with three key
 * responsibilities:
 *
 * 1. Maintaining TCP flow state for out-of-order (OOO) flows. Each OOO
 *    flow is assigned an OOO Flow ID in {0, ..., MAX_NUM_OOO_FLOWS-1},
 *    which is stored as part of the flow's context in the primary flow
 *    table. In turn, this serves as a pointer into the scheduler's OOO
 *    flow table (implemented using a simple hash-table in BRAM), where
 *    the complete TCP flow state (e.g., next expected sequence number,
 *    pointer to the reassembly linked list, etc.) resides. To allocate
 *    an OOO flow context, the primary FT issues a "token" containing
 *    the relevant flow metadata and a valid OOO flow ID.
 *
 * 2. Deciding which OOO flow should be served next by the reassembler.
 *    As part of the flow state, the scheduler maintains "flow queues":
 *    ordered, per-flow lists of packets that are yet to be serviced by
 *    the reassembler module. When a new packet arrives, it is inserted
 *    at the *tail* of the corresponding flow queue. The scheduler also
 *    maintains a global data-structure -- hereafter referred to as the
 *    scheduling queue -- to decide which flow to seve next. In making
 *    this decision, the scheduler pops the next "active" flow (an OOO
 *    flow that has >= 1 packet in its flow queue and isn't marked for
 *    garbage-collection) from the scheduling queue, deques the head
 *    element from its flow queue, and forwards this packet to the re-
 *    assembler. Updates from the reassembler (i.e. changes in the TCP
 *    flow state) are subsequently written back to the OOO flow table.
 *
 * 3. Flow garbage-collection (GC). Lastly, the scheduler is responsible
 *    for managing memory corresponding to: (a) the flow queues, and (b)
 *    the OOO linked lists in the reassembler. When the available memory
 *    in either module falls below some pre-determined watermark levels,
 *    the scheduler first marks a certain flow for GC (deactivating it),
 *    then issues a request to GC FSMs in the scheduler and reassembler.
 *    Note that any incoming packets corresponding to a marked flow are
 *    dropped by the scheduler. When the GC operations in both modules
 *    complete, the scheduler drops the flow by deallocating its context
 *    in the primary flow table.
 */
module scheduler_reassembly(
    // General inputs
    input   logic                   clk,
    input   logic                   rst,
    // Input FIFO
    input   metadata_t              in_meta_data,
    input   logic                   in_meta_valid,
    output  logic                   in_meta_ready,
    input   fce_t                   in_fce_data,
    input   logic                   in_fce_valid,
    output  logic                   in_fce_ready,
    // Incoming FT tokens
    input   scheduler_token_t       in_token_data,
    input   logic                   in_token_valid,
    output  logic                   in_token_ready,
    // Outgoing FT updates
    output  logic                   ft_update_fifo_empty,
    input   logic                   ft_update_fifo_rdreq,
    output  ft_update_t             ft_update_fifo_q,
    // Output FIFO (Scheduler)
    output  metadata_t              out_sched_fifo_meta,
    output  logic                   out_sched_fifo_valid,
    input   logic                   out_sched_fifo_ready,
    input   logic                   out_sched_fifo_almost_full,
    // Output FIFO (Reassembly)
    output  metadata_t              out_reassembly_fifo_meta,
    output  logic                   out_reassembly_fifo_valid,
    input   logic                   out_reassembly_fifo_ready,
    input   logic                   out_reassembly_fifo_almost_full
);

integer i;

/**
 * Local parameters.
 */
// Free lists
localparam OOO_FLOW_FL_LOW_WATERMARK    = 32;
localparam REASSEMBLY_FL_LOW_WATERMARK  = 32;
// Miscellaneous
localparam REASSEMBLY_GC_FIFO_DEPTH     = 4;
localparam FT_UPDATE_FIFO_DEPTH         = 16;
localparam HEAP_PRIORITY_PADDED_AWIDTH  = (HEAP_PRIORITY_AWIDTH + 3);
localparam PRIORITY_SCALING_FACTOR      = (HEAP_NUM_PRIORITIES / 128);
localparam LOG_PRIORITY_SCALING_FACTOR  = ($clog2(PRIORITY_SCALING_FACTOR));
localparam OOO_FLOW_LL_INVALID_PTR      = {OOO_FLOW_LL_ENTRY_PTR_T_WIDTH{1'b1}};

/**
 * Local typedefs.
 */
typedef logic [HEAP_PRIORITY_PADDED_AWIDTH-1:0] heap_priority_padded_t;

// Free list initialization FSM
typedef enum logic [1:0] {
    FL_FSM_STATE_IDLE,
    FL_FSM_STATE_INIT,
    FL_FSM_STATE_INIT_DONE
} ooo_flow_ll_fl_fsm_state_t;

// Flow table service FSM
typedef enum logic [2:0] {
    FT_SERVICE_FSM_STATE_IDLE,
    FT_SERVICE_FSM_STATE_DATA_RD,
    FT_SERVICE_FSM_STATE_DATA_WR,
    FT_SERVICE_FSM_STATE_DATA_INSERT_HEAP,
    FT_SERVICE_FSM_STATE_CTRL_RD,
    FT_SERVICE_FSM_STATE_CTRL_WR
} ft_service_fsm_state_t;

// Reassembly service FSM
typedef enum logic [2:0] {
    REASSEMBLY_SERVICE_FSM_STATE_IDLE,
    REASSEMBLY_SERVICE_FSM_STATE_FC_RD,
    REASSEMBLY_SERVICE_FSM_STATE_LL_RD,
    REASSEMBLY_SERVICE_FSM_STATE_RD_DONE,
    REASSEMBLY_SERVICE_FSM_STATE_FC_WR,
    REASSEMBLY_SERVICE_FSM_STATE_INSERT_HEAP
} reassembly_service_fsm_state_t;

// Garbage-collection FSM
typedef enum logic [2:0] {
    GC_FSM_STATE_IDLE,
    GC_FSM_STATE_FC_RD,
    GC_FSM_STATE_INIT_REASSEMBLY_GC,
    GC_FSM_STATE_LL_RD,
    GC_FSM_STATE_LL_RD_DONE
} gc_fsm_state_t;

// Garbage-collection response FSM
typedef enum logic {
    GC_RESPONSE_FSM_STATE_IDLE,
    GC_RESPONSE_FSM_STATE_UPDATE_FT
} gc_response_fsm_state_t;

/**
 * Submodule logic.
 */
// Free list
logic fl_rdreq;
logic fl_wrreq;
logic fl_empty;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] fl_q;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] fl_data;

// Flow table update FIFO
logic ft_update_fifo_full;
logic ft_update_fifo_wrreq;
ft_update_t ft_update_fifo_data;

// OOO flow context table
logic fc_rden_a;
logic fc_rden_b;
logic fc_wren_a;
logic fc_wren_b;
ooo_flow_fc_entry_t fc_q_a;
ooo_flow_fc_entry_t fc_q_b;
ooo_flow_fc_entry_t fc_data_a;
ooo_flow_fc_entry_t fc_data_b;
logic [OOO_FLOW_ID_AWIDTH-1:0] fc_address_a;
logic [OOO_FLOW_ID_AWIDTH-1:0] fc_address_b;

// Linked-list (value) entries
logic lle_meta_rden_b;
logic lle_meta_wren_a;
metadata_t lle_meta_q_a;
metadata_t lle_meta_q_b;
metadata_t lle_meta_data_a;
metadata_t lle_meta_data_b;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] lle_meta_address_a;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] lle_meta_address_b;

// Linked-list (next pointer) entries
logic lle_nextptr_rden_b;
logic lle_nextptr_wren_a;
ooo_flow_ll_entry_ptr_t lle_nextptr_q_a;
ooo_flow_ll_entry_ptr_t lle_nextptr_q_b;
ooo_flow_ll_entry_ptr_t lle_nextptr_data_a;
ooo_flow_ll_entry_ptr_t lle_nextptr_data_b;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] lle_nextptr_address_a;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] lle_nextptr_address_b;

/**
 * Flow reassembly.
 */
// Read channel
logic reassembly_rdch_rden;
logic reassembly_rdch_ready;
logic reassembly_rdch_rd_valid;
metadata_t reassembly_rdch_meta;
ooo_flow_fc_entry_t reassembly_rdch_fce;
ooo_flow_id_t reassembly_rdch_ooo_flow_id;
logic reassembly_rdch_rd_ooo_flow_invalid;
// Write channel
logic reassembly_wrch_wren;
logic reassembly_wrch_ready;
logic reassembly_wrch_is_delete;
ooo_flow_fc_entry_t reassembly_wrch_update_fce;
logic [PKT_AWIDTH-1:0] reassembly_wrch_rel_pkt_cnt;
// Debug
logic reassembly_state_idle;

// Reassembly service queue
logic heap_in_enque_en;
logic heap_in_enque_ready;
heap_priority_t heap_in_enque_priority;
ooo_flow_id_t heap_in_enque_ooo_flow_id;
heap_priority_padded_t heap_in_enque_priority_padded;
logic heap_out_deque_min_en;
logic heap_out_deque_min_ready;
heap_priority_t heap_out_deque_min_priority;
ooo_flow_id_t heap_out_deque_min_ooo_flow_id;
logic heap_in_deque_max_req_en;
logic heap_in_deque_max_req_ready;
logic heap_out_deque_max_en;
logic heap_out_deque_max_ready;
heap_priority_t heap_out_deque_max_priority;
ooo_flow_id_t heap_out_deque_max_ooo_flow_id;

/**
 * Housekeeping.
 */
// Scheduler output FIFO
logic out_sched_fifo_valid_int;
metadata_t out_sched_fifo_meta_int;

// Garbage-collection flow state
logic gc_state[MAX_NUM_OOO_FLOWS-1:0];
logic gc_rden[1:0];
logic gc_wren[1:0];
logic gc_rd_q[1:0];
logic gc_wr_data[1:0];
logic [OOO_FLOW_ID_AWIDTH-1:0] gc_rd_address[1:0];
logic [OOO_FLOW_ID_AWIDTH-1:0] gc_wr_address[1:0];

// Heap priority computation
logic exponent_pos;
logic [2:0] exponent;
logic [4:0] num_flits;
logic [2:0] log2_num_flits;

// Free list management
ooo_flow_ll_fl_fsm_state_t fl_fsm_state;
ooo_flow_ll_fl_fsm_state_t fl_fsm_state_next;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] fl_data_init;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] fl_data_init_next;

// FT service FSM
logic ft_service_fsm_ooo_flow_valid;
ft_service_fsm_state_t ft_service_fsm_state;
ft_service_fsm_state_t ft_service_fsm_state_next;

// Reassembly service FSM
metadata_t reassembly_service_fsm_lle_meta_q;
logic reassembly_service_fsm_fc_data_latch_en;
logic reassembly_service_fsm_ooo_flow_ll_empty;
ooo_flow_fc_entry_t reassembly_service_fsm_fc_q;
reassembly_service_fsm_state_t reassembly_service_fsm_state;
ooo_flow_ll_entry_ptr_t reassembly_service_fsm_lle_nextptr_q;
reassembly_service_fsm_state_t reassembly_service_fsm_state_next;
logic [OOO_FLOW_ID_AWIDTH-1:0] reassembly_service_fsm_fc_address;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] reassembly_service_fsm_lle_address;

metadata_t reassembly_service_fsm_lle_meta_q_r;
ooo_flow_fc_entry_t reassembly_service_fsm_fc_q_r;
ooo_flow_fc_entry_t reassembly_service_fsm_fc_data_r;
ooo_flow_ll_entry_ptr_t reassembly_service_fsm_lle_nextptr_q_r;
logic [OOO_FLOW_ID_AWIDTH-1:0] reassembly_service_fsm_fc_address_r;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] reassembly_service_fsm_lle_address_r;

// Garbage-collection FSM
logic gc_lle_rden;
metadata_t gc_lle_meta_q;
ooo_flow_fc_entry_t gc_fc_q;
gc_fsm_state_t gc_fsm_state;
logic gc_ooo_flow_id_valid;
ooo_flow_id_t gc_ooo_flow_id;
logic gc_inc_ooo_flow_fl_size;
logic gc_dec_ooo_flow_fl_size;
gc_fsm_state_t gc_fsm_state_next;
logic [31:0] gc_reassembly_fl_size;
ooo_flow_ll_entry_ptr_t gc_lle_nextptr_q;
ooo_flow_ll_entry_ptr_t gc_lle_currptr_q;
logic [OOO_FLOW_LL_ENTRY_AWIDTH:0] gc_ooo_flow_fl_size_r;

logic gc_lle_rden_r;
metadata_t gc_lle_meta_q_r;
logic gc_ooo_flow_id_valid_r;
ooo_flow_fc_entry_t gc_fc_q_r;
ooo_flow_id_t gc_ooo_flow_id_r;
ooo_flow_ll_entry_ptr_t gc_lle_nextptr_q_r;
ooo_flow_ll_entry_ptr_t gc_lle_currptr_q_r;

// Garbage-collection response FSM
reassembly_gc_meta_t gc_response_meta;
gc_response_fsm_state_t gc_response_fsm_state;
gc_response_fsm_state_t gc_response_fsm_state_next;

reassembly_gc_meta_t gc_response_meta_r;

// Scheduler->Reassembly GC request FIFO
logic reassembly_gc_req_fifo_full;
logic reassembly_gc_req_fifo_rdreq;
logic reassembly_gc_req_fifo_wrreq;
logic reassembly_gc_req_fifo_empty;
logic reassembly_gc_req_state_idle;
reassembly_gc_req_t reassembly_gc_req_fifo_q;
reassembly_gc_req_t reassembly_gc_req_fifo_data;

// Reassembly->Scheduler GC response FIFO
logic reassembly_gc_rsp_fifo_full;
logic reassembly_gc_rsp_fifo_rdreq;
logic reassembly_gc_rsp_fifo_wrreq;
logic reassembly_gc_rsp_fifo_empty;
reassembly_gc_meta_t reassembly_gc_rsp_fifo_q;
reassembly_gc_meta_t reassembly_gc_rsp_fifo_data;

// Miscellaneous signals
logic fc_rden_b_r;
fce_t in_fce_data_r1;
fce_t in_fce_data_r2;
heap_size_t heap_size;
logic lle_nextptr_rden_b_r;
metadata_t in_meta_data_r1;
metadata_t in_meta_data_r2;
ooo_flow_fc_entry_t fc_q_a_r;
ooo_flow_fc_entry_t fc_data_a_r;
scheduler_token_t in_token_data_r;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] fl_q_r;
ooo_flow_ll_entry_ptr_t lle_nextptr_data_a_r;

// Debug
logic gc_inc_cur_ll_release_cnt;
logic gc_reset_cur_ll_release_cnt;
logic [OOO_FLOW_LL_ENTRY_AWIDTH-1:0] gc_cur_ll_release_cnt_r;

initial begin
    fl_q_r = 0;
    fc_q_a_r = 0;
    fc_data_a_r = 0;
    fc_rden_b_r = 0;
    lle_nextptr_data_a_r = 0;
    lle_nextptr_rden_b_r = 0;

    in_fce_data_r1 = 0;
    in_fce_data_r2 = 0;
    in_meta_data_r1 = 0;
    in_meta_data_r2 = 0;
    in_token_data_r = 0;

    reassembly_service_fsm_fc_q_r = 0;
    reassembly_service_fsm_fc_data_r = 0;
    reassembly_service_fsm_lle_meta_q_r = 0;
    reassembly_service_fsm_fc_address_r = 0;
    reassembly_service_fsm_lle_address_r = 0;
    reassembly_service_fsm_lle_nextptr_q_r = 0;

    gc_fc_q_r = 0;
    gc_lle_rden_r = 0;
    gc_lle_meta_q_r = 0;
    gc_ooo_flow_id_r = 0;
    gc_lle_nextptr_q_r = 0;
    gc_lle_currptr_q_r = 0;
    gc_ooo_flow_fl_size_r = 0;
    gc_ooo_flow_id_valid_r = 0;

    gc_response_meta_r = 0;

    for (i = 0; i < MAX_NUM_OOO_FLOWS; i = i + 1) begin
        gc_state[i] = 0;
    end

    gc_cur_ll_release_cnt_r = 0;

    fl_data_init = 0;
    fl_fsm_state = FL_FSM_STATE_IDLE;
    gc_fsm_state = GC_FSM_STATE_IDLE;
    ft_service_fsm_state = FT_SERVICE_FSM_STATE_IDLE;
    gc_response_fsm_state = GC_RESPONSE_FSM_STATE_IDLE;
    reassembly_service_fsm_state = REASSEMBLY_SERVICE_FSM_STATE_IDLE;
end

// Heap priority, P, computed as follows:
// P = (ll_size / num_flits) * PRIORITY_SCALING_FACTOR
// P = ll_size * (PRIORITY_SCALING_FACTOR / num_flits)
// P = ll_size * 2^(log2(PRIORITY_SCALING_FACTOR / num_flits))
// P = ll_size * 2^(LOG_PRIORITY_SCALING_FACTOR - log2(num_flits))
// Then, P ~ ll_size << (LOG_PRIORITY_SCALING_FACTOR - log2(num_flits))
assign log2_num_flits = (num_flits <= 1)  ? 0 :
                        (num_flits == 2)  ? 1 :
                        (num_flits <= 5)  ? 2 :
                        (num_flits <= 11) ? 3 :
                        (num_flits <= 22) ? 4 : 5;

assign exponent_pos = (LOG_PRIORITY_SCALING_FACTOR >= log2_num_flits);
assign exponent = (exponent_pos ? (LOG_PRIORITY_SCALING_FACTOR - log2_num_flits) :
                                  (log2_num_flits - LOG_PRIORITY_SCALING_FACTOR));
// Reassembler logic
assign reassembly_rdch_fce = reassembly_service_fsm_fc_q;
assign reassembly_rdch_meta = reassembly_service_fsm_lle_meta_q;

// Dual-port GC register file
always @(posedge clk) begin
    if (rst) begin
        gc_rd_q[0] <= 1'b0;
        gc_rd_q[1] <= 1'b0;
    end
    else begin
        // Write logic
        for (i = 0; i < 2; i = i + 1) begin
            if (gc_wren[i]) begin
                gc_state[gc_wr_address[i]] <= gc_wr_data[i];
            end
        end
        // Read logic (with write forwarding)
        for (i = 0; i < 2; i = i + 1) begin
            if (gc_rden[i]) begin
                if (gc_wren[1] && (gc_rd_address[i] == gc_wr_address[1])) begin
                    gc_rd_q[i] <= gc_wr_data[1];
                end
                else if (gc_wren[0] && (gc_rd_address[i] == gc_wr_address[0])) begin
                    gc_rd_q[i] <= gc_wr_data[0];
                end
                else begin
                    gc_rd_q[i] <= gc_state[gc_rd_address[i]];
                end
            end
        end
    end
end

always @(*) begin
    ft_service_fsm_state_next = ft_service_fsm_state;
    ft_service_fsm_ooo_flow_valid = fc_q_a.valid && !gc_rd_q[0];

    reassembly_service_fsm_state_next = (
        reassembly_service_fsm_state);

    reassembly_service_fsm_fc_data_latch_en = 0;
    reassembly_service_fsm_ooo_flow_ll_empty = 0;
    reassembly_service_fsm_fc_q = reassembly_service_fsm_fc_q_r;
    reassembly_service_fsm_lle_meta_q = reassembly_service_fsm_lle_meta_q_r;
    reassembly_service_fsm_fc_address = reassembly_service_fsm_fc_address_r;
    reassembly_service_fsm_lle_address = reassembly_service_fsm_lle_address_r;
    reassembly_service_fsm_lle_nextptr_q = reassembly_service_fsm_lle_nextptr_q_r;

    in_fce_ready = 0;
    in_meta_ready = 0;
    in_token_ready = 0;

    out_sched_fifo_meta_int = 0;
    out_sched_fifo_valid_int = 0;

    num_flits = 1;
    heap_in_enque_en = 0;
    heap_out_deque_max_en = 0;
    heap_in_enque_priority = 0;
    heap_in_deque_max_req_en = 0;
    heap_in_enque_ooo_flow_id = 0;
    heap_in_enque_priority_padded = 0;

    gc_rden[0] = 0;
    gc_rden[1] = 0;
    gc_wren[0] = 0;
    gc_wren[1] = 0;
    gc_wr_data[0] = 0;
    gc_wr_data[1] = 0;
    gc_rd_address[0] = 0;
    gc_rd_address[1] = 0;
    gc_wr_address[0] = 0;
    gc_wr_address[1] = 0;

    fc_rden_a = 0;
    fc_rden_b = 0;
    fc_wren_a = 0;
    fc_wren_b = 0;
    fc_data_a = 0;
    fc_data_b = 0;
    fc_address_a = 0;
    fc_address_b = 0;

    fl_data = 0;
    fl_rdreq = 0;
    fl_wrreq = 0;

    fl_data_init_next = 0;
    fl_fsm_state_next = fl_fsm_state;

    ft_update_fifo_data = 0;
    ft_update_fifo_wrreq = 0;

    lle_meta_wren_a = 0;
    lle_meta_data_a = 0;
    lle_meta_address_a = 0;
    lle_nextptr_wren_a = 0;
    lle_nextptr_data_a = 0;
    lle_nextptr_address_a = 0;

    lle_meta_rden_b = 0;
    lle_meta_data_b = 0;
    lle_meta_address_b = 0;
    lle_nextptr_rden_b = 0;
    lle_nextptr_data_b = 0;
    lle_nextptr_address_b = 0;

    reassembly_wrch_ready = 0;
    reassembly_rdch_ready = 0;
    reassembly_rdch_rd_valid = 0;
    reassembly_rdch_rd_ooo_flow_invalid = 0;

    reassembly_gc_req_fifo_data = 0;
    reassembly_gc_req_fifo_wrreq = 0;
    reassembly_gc_rsp_fifo_rdreq = 0;

    gc_lle_rden = 0;
    gc_fc_q = gc_fc_q_r;
    gc_inc_ooo_flow_fl_size = 0;
    gc_dec_ooo_flow_fl_size = 0;
    gc_lle_meta_q = gc_lle_meta_q_r;
    gc_fsm_state_next = gc_fsm_state;
    gc_ooo_flow_id = gc_ooo_flow_id_r;
    gc_lle_nextptr_q = gc_lle_nextptr_q_r;
    gc_lle_currptr_q = gc_lle_currptr_q_r;
    gc_ooo_flow_id_valid = gc_ooo_flow_id_valid_r;

    gc_response_meta = gc_response_meta_r;
    gc_response_fsm_state_next = gc_response_fsm_state;

    gc_inc_cur_ll_release_cnt = 0;
    gc_reset_cur_ll_release_cnt = 0;

    /**
     * Free-list initialization FSM.
     */
    case (fl_fsm_state)
        // Idle state: Wait for rst to fall,
        // then proceed to the init state.
        FL_FSM_STATE_IDLE: begin
            fl_fsm_state_next = FL_FSM_STATE_INIT;
        end
        // Insert into the free-list FIFO
        FL_FSM_STATE_INIT: begin
            fl_wrreq = 1;
            fl_data = fl_data_init;
            gc_inc_ooo_flow_fl_size = 1;

            if (fl_data_init ==
                {OOO_FLOW_LL_ENTRY_AWIDTH{1'b1}}) begin
                fl_fsm_state_next = FL_FSM_STATE_INIT_DONE;
            end
            else begin
                fl_fsm_state_next = FL_FSM_STATE_INIT;
                fl_data_init_next = fl_data_init + 1;
            end
        end
        // Initialization complete
        FL_FSM_STATE_INIT_DONE: begin
            fl_fsm_state_next = FL_FSM_STATE_INIT_DONE;
        end
    endcase

    /**
     * FT Service FSM.
     */
    case (ft_service_fsm_state)
        // Idle state.
        FT_SERVICE_FSM_STATE_IDLE: begin
            // High priority: If the token channel (from FT)
            // is not empty, perform the scheduler operation.
            // Since this is not predicated on any resource
            // availability (free LL entries, etc.), it can
            // always proceed without stalling.
            if (in_token_valid) begin
                ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_CTRL_RD;
            end
            // Low priority: If the input (metadata and FCE)
            // FIFOs contain valid entries, the LL free-list
            // is not empty, and the scheduler's output FIFO
            // is not full, proceed to read state.
            else if (in_meta_valid && in_fce_valid &&
                     !fl_empty && !out_sched_fifo_almost_full) begin
                ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_DATA_RD;
            end
        end
        // (Data) read state: Read the entry in the context
        // table corresponding to the given flow ID, deque
        // both input FIFOs, and finally allocate a new LL
        // node from the free-list. Also update its data.
        FT_SERVICE_FSM_STATE_DATA_RD: begin
            // Proceed to write
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_DATA_WR;

            // Initiate FC read
            fc_rden_a = 1;
            fc_address_a = in_fce_data.ooo_flow_id;

            // Read the GC register file
            gc_rden[0] = 1;
            gc_rd_address[0] = in_fce_data.ooo_flow_id;

            // Update the LL node
            lle_meta_wren_a = 1;
            lle_nextptr_wren_a = 1;
            lle_meta_address_a = fl_q;
            lle_nextptr_address_a = fl_q;
            lle_meta_data_a = in_meta_data;
            lle_nextptr_data_a = OOO_FLOW_LL_INVALID_PTR;

            // Deque input FIFOs
            in_fce_ready = 1;
            in_meta_ready = 1;
        end
        // (Data) write state: Update the tail LL entry
        // to point to the newly-allocated LL node, and
        // update the tail (and head, if required) ptrs.
        FT_SERVICE_FSM_STATE_DATA_WR: begin
            // Return to idle
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_IDLE;

            // If the corresponding OOO flow is valid and
            // is not marked for GC, commit the update.
            if (ft_service_fsm_ooo_flow_valid) begin
                // Write back the FC
                fc_wren_a = 1;
                fc_data_a = fc_q_a;
                fc_address_a = in_fce_data_r1.ooo_flow_id;

                // The flow's LL is empty, update the head pointer. Also
                // implies that the flow ID is not currently in the heap;
                // As such, proceed to the heap insertion state.
                if (fc_q_a.ooo_flow_ll.head == OOO_FLOW_LL_INVALID_PTR) begin
                    fc_data_a.ooo_flow_ll.head = fl_q_r;

                    // Move to the heap insertion state
                    ft_service_fsm_state_next = (
                        FT_SERVICE_FSM_STATE_DATA_INSERT_HEAP);
                end
                // Else, update the tail LL entry's next pointer
                else begin
                    lle_nextptr_wren_a = 1;
                    lle_nextptr_data_a = fl_q_r;
                    lle_nextptr_address_a = fc_q_a.ooo_flow_ll.tail;
                end
                // Update the tail pointer
                fc_data_a.ooo_flow_ll.tail = fl_q_r;

                // If this is the first out-of-order packet for
                // this flow (indicated by a slow count of 0),
                // update the sequence number and FT address.
                if (in_fce_data_r1.slow_cnt == 0) begin
                    fc_data_a.seq = in_fce_data_r1.seq;
                    fc_data_a.addr0 = in_fce_data_r1.addr0;
                    fc_data_a.addr1 = in_fce_data_r1.addr1;
                    fc_data_a.addr2 = in_fce_data_r1.addr2;
                    fc_data_a.addr3 = in_fce_data_r1.addr3;
                end

                // Deque the free-list FIFO
                fl_rdreq = 1;
                gc_dec_ooo_flow_fl_size = 1;
            end
            // Else, either the OOO flow ID received from the FTW is
            // invalid, the packet corresponds to stale state, or
            // the flow has been marked for GC. Drop the packet.
            else begin
                out_sched_fifo_valid_int = 1;
                out_sched_fifo_meta_int = in_meta_data_r1;
                out_sched_fifo_meta_int.pkt_flags = PKT_DROP;
            end
        end
        // (Data) heap insertion state: Insert the
        // newly-allocated flow ID into the heap.
        FT_SERVICE_FSM_STATE_DATA_INSERT_HEAP: begin
            // Return to idle
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_IDLE;

            // TODO(natre): Assuming that the heap is guaranteed
            // to be ready. This is currently true (since it can
            // hold exactly MAX_NUM_OOO_FLOWS entries); however,
            // this should ideally handle enque stalls.
            heap_in_enque_en = 1;
            num_flits = in_meta_data_r2.flits;
            heap_in_enque_ooo_flow_id = in_fce_data_r2.ooo_flow_id;

            if (fc_q_a_r.ll_size == 0) begin
                heap_in_enque_priority = (
                    exponent_pos ? (1 << exponent) :
                                   (1 >> exponent));
            end
            else begin
                heap_in_enque_priority_padded = (
                    exponent_pos ? (fc_q_a_r.ll_size << exponent) :
                                   (fc_q_a_r.ll_size >> exponent));

                heap_in_enque_priority = (
                    heap_in_enque_priority_padded[
                        HEAP_PRIORITY_PADDED_AWIDTH-1:
                        HEAP_PRIORITY_AWIDTH] != 0) ?
                    {HEAP_PRIORITY_AWIDTH{1'b1}} :
                    heap_in_enque_priority_padded;
            end
        end
        // (Ctrl) read state: Read the entry in the
        // context table corresponding to the given
        // OOO flow ID and deque the token channel.
        FT_SERVICE_FSM_STATE_CTRL_RD: begin
            // Proceed to write
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_CTRL_WR;

            // Initiate FC read
            fc_rden_a = 1;
            fc_address_a = in_token_data.ooo_flow_id;

            // Read the GC register file
            gc_rden[0] = 1;
            gc_rd_address[0] = in_token_data.ooo_flow_id;

            // Deque the token channel
            in_token_ready = 1;
        end
        // (Ctrl) write state: Update the flow
        // context table and GC register file.
        FT_SERVICE_FSM_STATE_CTRL_WR: begin
            // Return to idle
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_IDLE;

            // Write back the FC
            fc_wren_a = 1;
            fc_data_a = 0;
            fc_address_a = in_token_data_r.ooo_flow_id;

            // Write back the GC entry
            gc_wren[0] = 1;
            gc_wr_data[0] = 0;
            gc_wr_address[0] = in_token_data_r.ooo_flow_id;

            // Allocate the flow context
            fc_data_a.valid = 1;
            fc_data_a.tuple = in_token_data_r.tuple;
            fc_data_a.ooo_flow_ll.head = OOO_FLOW_LL_INVALID_PTR;
            fc_data_a.ooo_flow_ll.tail = OOO_FLOW_LL_INVALID_PTR;
        end
        default: begin
            ft_service_fsm_state_next = FT_SERVICE_FSM_STATE_IDLE;
        end
    endcase

    /**
     * Flow Reassembly service FSM.
     */
    case (reassembly_service_fsm_state)
        // Idle state. If enable for flow reassembly's read/write
        // channels is raised, proceed to the corresponding state.
        REASSEMBLY_SERVICE_FSM_STATE_IDLE: begin
            if (reassembly_rdch_rden) begin
                reassembly_service_fsm_state_next = (
                    REASSEMBLY_SERVICE_FSM_STATE_FC_RD);
            end
            else if (reassembly_wrch_wren &&
                     !ft_update_fifo_full) begin
                reassembly_service_fsm_state_next = (
                    REASSEMBLY_SERVICE_FSM_STATE_FC_WR);
            end
        end
        // FC read state. Read the entry in the context table
        // corresponding to the given flow ID (using port B).
        // If there is already a write in progress for the
        // same flow ID on port A, forward the write.
        REASSEMBLY_SERVICE_FSM_STATE_FC_RD: begin
            // Read the GC register file
            gc_rden[1] = 1;
            gc_rd_address[1] = reassembly_rdch_ooo_flow_id;

            // FC read address
            fc_address_b = reassembly_rdch_ooo_flow_id;
            reassembly_service_fsm_fc_address = (
                reassembly_rdch_ooo_flow_id);

            // If there isn't a contending write happening
            // on this cycle, raise rden. Else, we simply
            // use the forwarded write.
            if (!(fc_wren_a && (fc_address_a ==
                  reassembly_rdch_ooo_flow_id))) begin
                fc_rden_b = 1;
            end

            // Acknowledge the reassembler's read channel
            // request, and proceed to the LL read state.
            reassembly_rdch_ready = 1;
            reassembly_service_fsm_state_next = (
                REASSEMBLY_SERVICE_FSM_STATE_LL_RD);
        end
        // LL read state. Read the LL entry corresponding to the
        // flow's head pointer. If the flow is either: invalid,
        // marked for GC, or has an invalid head pointer (error
        // state), skip this lookup and return to idle.
        REASSEMBLY_SERVICE_FSM_STATE_LL_RD: begin
            reassembly_service_fsm_fc_q = (
                fc_rden_b_r ? fc_q_b : fc_data_a_r);

            // The flow state is invalid. Raise read invalid
            // (indicating to the reassembler that it should
            // discard the current flow ID and draw another
            // from the heap), and return to idle.
            if (!reassembly_service_fsm_fc_q.valid || gc_rd_q[1] ||
                (reassembly_service_fsm_fc_q.ooo_flow_ll.head ==
                 OOO_FLOW_LL_INVALID_PTR)) begin
                reassembly_rdch_rd_valid = 1;
                reassembly_rdch_rd_ooo_flow_invalid = 1;

                reassembly_service_fsm_state_next = (
                    REASSEMBLY_SERVICE_FSM_STATE_IDLE);
            end
            // Read the LL entry on port B. If there is an
            // ongoing write to the corresponding LL entry
            // (via port A), forward the write data.
            else begin
                // Read the LL entry. Note that there should
                // never be a contending write for the meta-
                // data entry, so we read it unconditionally.
                reassembly_service_fsm_lle_address = (
                    reassembly_service_fsm_fc_q.ooo_flow_ll.head);

                lle_meta_rden_b = 1;
                lle_meta_address_b = reassembly_service_fsm_lle_address;
                lle_nextptr_address_b = reassembly_service_fsm_lle_address;

                if (!(lle_nextptr_wren_a && (lle_nextptr_address_a ==
                      reassembly_service_fsm_lle_address))) begin
                    // Read the LL entry
                    lle_nextptr_rden_b = 1;
                end
                // Proceed to the read done state
                reassembly_service_fsm_state_next = (
                    REASSEMBLY_SERVICE_FSM_STATE_RD_DONE);
            end
        end
        // Read done state. Respond to the reassembler with the
        // read FCE and packet metadata. After this point, any
        // writes to the previously-read FT context and/or LLE
        // are forwarded to the respective registers.
        REASSEMBLY_SERVICE_FSM_STATE_RD_DONE: begin
            reassembly_service_fsm_lle_meta_q = lle_meta_q_b;
            reassembly_service_fsm_lle_nextptr_q = (
                lle_nextptr_rden_b_r ? lle_nextptr_q_b :
                                       lle_nextptr_data_a_r);
            // Indicate read completion
            reassembly_rdch_rd_valid = 1;

            // Return to idle
            reassembly_service_fsm_state_next = (
                REASSEMBLY_SERVICE_FSM_STATE_IDLE);
        end
        // FC write state. Update the latched tuple with the
        // reassembler's wr channel data, and commit it back
        // to the context table.
        REASSEMBLY_SERVICE_FSM_STATE_FC_WR: begin
            reassembly_service_fsm_state_next = (
                REASSEMBLY_SERVICE_FSM_STATE_FC_WR);

            // Prepare the updated context
            fc_data_b = reassembly_service_fsm_fc_q_r;
            fc_data_b.seq = reassembly_wrch_update_fce.seq;
            fc_data_b.pointer = reassembly_wrch_update_fce.pointer;
            fc_data_b.ll_valid = reassembly_wrch_update_fce.ll_valid;
            fc_data_b.last_7_bytes = reassembly_wrch_update_fce.last_7_bytes;

            // The flow LL becomes empty (previously had a single entry)
            if (reassembly_service_fsm_fc_q_r.ooo_flow_ll.head ==
                reassembly_service_fsm_fc_q_r.ooo_flow_ll.tail) begin
                reassembly_service_fsm_ooo_flow_ll_empty = 1;
                fc_data_b.ooo_flow_ll.head = OOO_FLOW_LL_INVALID_PTR;
                fc_data_b.ooo_flow_ll.tail = OOO_FLOW_LL_INVALID_PTR;
            end
            // Else, move the head pointer
            else begin
                fc_data_b.ooo_flow_ll.head = (
                    reassembly_service_fsm_lle_nextptr_q_r);
            end

            // Compute the new LL size
            fc_data_b.ll_size = (
                // LL size including this packet
                (reassembly_service_fsm_fc_q_r.ll_size + 1)
                - reassembly_wrch_rel_pkt_cnt // Released packet count
            );

            // Latch the FC data
            reassembly_service_fsm_fc_data_latch_en = 1;

            // Set the write address
            fc_address_b = reassembly_service_fsm_fc_address_r;

            // (Preemptively) set the FT update data
            ft_update_fifo_data.seq = reassembly_wrch_update_fce.seq;
            ft_update_fifo_data.is_delete = reassembly_wrch_is_delete;
            ft_update_fifo_data.rel_pkt_cnt = reassembly_wrch_rel_pkt_cnt;
            ft_update_fifo_data.tuple = reassembly_service_fsm_fc_q_r.tuple;
            ft_update_fifo_data.addr0 = reassembly_service_fsm_fc_q_r.addr0;
            ft_update_fifo_data.addr1 = reassembly_service_fsm_fc_q_r.addr1;
            ft_update_fifo_data.addr2 = reassembly_service_fsm_fc_q_r.addr2;
            ft_update_fifo_data.addr3 = reassembly_service_fsm_fc_q_r.addr3;

            // If there is an ongoing read or write for the same flow context
            // on this cycle (via port A), remain in this state and defer the
            // write; otherwise, commit the data. If required (i.e., non-zero
            // packets are released), push an update to the FT. Also reinsert
            // the flow ID back into the heap if required.
            if (!((fc_rden_a | fc_wren_a) && (
                  fc_address_a == fc_address_b))) begin
                // Perform the FT update
                fc_wren_b = 1;

                // Release the LLE back to the free-list
                fl_wrreq = 1;
                gc_inc_ooo_flow_fl_size = 1;
                fl_data = reassembly_service_fsm_lle_address_r;

                // Insert into the FT update FIFO if required
                if (reassembly_wrch_rel_pkt_cnt != 0 ||
                    reassembly_wrch_is_delete) begin
                    ft_update_fifo_wrreq = 1;
                end

                // If the flow's LL is not empty and is not marked for
                // deletion, also re-insert the flow ID into the heap.
                if (!(reassembly_service_fsm_ooo_flow_ll_empty ||
                      reassembly_wrch_is_delete)) begin
                    reassembly_service_fsm_state_next = (
                        REASSEMBLY_SERVICE_FSM_STATE_INSERT_HEAP);
                end
                // Else, return to idle
                else begin
                    // Indicate completion, return to idle
                    reassembly_wrch_ready = 1;
                    reassembly_service_fsm_state_next = (
                        REASSEMBLY_SERVICE_FSM_STATE_IDLE);
                end
            end
        end
        // Heap insertion state. Re-insert the latched
        // flow ID into the heap and return to idle.
        REASSEMBLY_SERVICE_FSM_STATE_INSERT_HEAP: begin
            reassembly_service_fsm_state_next = (
                REASSEMBLY_SERVICE_FSM_STATE_INSERT_HEAP);

            if (heap_in_enque_ready && !heap_in_enque_en) begin
                heap_in_enque_en = 1;
                heap_in_enque_ooo_flow_id = reassembly_rdch_ooo_flow_id;

                num_flits = reassembly_service_fsm_lle_meta_q_r.flits;
                heap_in_enque_priority_padded = (
                    exponent_pos ?
                    (reassembly_service_fsm_fc_data_r.ll_size << exponent) :
                    (reassembly_service_fsm_fc_data_r.ll_size >> exponent));

                heap_in_enque_priority = (
                    heap_in_enque_priority_padded[
                        HEAP_PRIORITY_PADDED_AWIDTH-1:
                        HEAP_PRIORITY_AWIDTH] != 0) ?
                    {HEAP_PRIORITY_AWIDTH{1'b1}} :
                    heap_in_enque_priority_padded;

                // Indicate completion, return to idle
                reassembly_wrch_ready = 1;
                reassembly_service_fsm_state_next = (
                    REASSEMBLY_SERVICE_FSM_STATE_IDLE);
            end
        end
        // Invalid state, return to idle
        default: begin
            reassembly_service_fsm_state_next = (
                REASSEMBLY_SERVICE_FSM_STATE_IDLE);
        end
    endcase

    /**
     * Garbage-collection (GC) FSM.
     */
    case (gc_fsm_state)
        // Idle state. If either: a) the heap's deque-max output
        // FIFO contains at least one entry, or b) the flow LL/
        // reassembly free list sizes fall below their watermark
        // levels, start garbage collection.
        GC_FSM_STATE_IDLE: begin
            gc_fsm_state_next = GC_FSM_STATE_IDLE;

            gc_ooo_flow_id_valid = 0;
            gc_reset_cur_ll_release_cnt = 1;
            if (!reassembly_gc_req_fifo_full) begin
                // The deque-max output FIFO has an entry.
                // Deque it, and commence the GC process.
                if (heap_out_deque_max_ready) begin
                    heap_out_deque_max_en = 1;
                    gc_fsm_state_next = GC_FSM_STATE_FC_RD;

                    gc_ooo_flow_id_valid = 1;
                    gc_ooo_flow_id = heap_out_deque_max_ooo_flow_id;
                end
                // Else, if the free lists corresponding to either
                // flow or reassembly LL entries fall below their
                // watermark levels, issue a heap deque-max op
                // and continue waiting in this state.
                else if (
                    (fl_fsm_state == FL_FSM_STATE_INIT_DONE) &&
                    (heap_size != 0) && heap_in_deque_max_req_ready &&
                    ((gc_ooo_flow_fl_size_r <= OOO_FLOW_FL_LOW_WATERMARK) ||
                     ((gc_reassembly_fl_size <= REASSEMBLY_FL_LOW_WATERMARK) &&
                      reassembly_gc_req_state_idle))) begin
                    heap_in_deque_max_req_en = 1;
                end
            end
        end
        // FC read state. Mark the flow for GC and
        // read the corresponding flow context.
        GC_FSM_STATE_FC_RD: begin
            gc_fsm_state_next = GC_FSM_STATE_FC_RD;

            // Update the GC register file
            gc_wren[1] = 1;
            gc_wr_data[1] = 1;
            gc_wr_address[1] = gc_ooo_flow_id_r;

            // Perform a context table read using port B, deferring to
            // the reassembly service FSM if required. The only source
            // of write contention is the FT service FSM's accesses on
            // port A to the same address.
            if (!(fc_wren_a && (fc_address_a == gc_ooo_flow_id_r)) &&
                (reassembly_service_fsm_state !=
                 REASSEMBLY_SERVICE_FSM_STATE_FC_RD) &&
                (reassembly_service_fsm_state !=
                 REASSEMBLY_SERVICE_FSM_STATE_FC_WR)) begin

                fc_rden_b = 1;
                fc_address_b = gc_ooo_flow_id_r;
                gc_fsm_state_next = GC_FSM_STATE_INIT_REASSEMBLY_GC;
            end
        end
        // Init Reassembly GC state. Create and
        // send a GC request to the reassembler.
        GC_FSM_STATE_INIT_REASSEMBLY_GC: begin
            // Latch the FC read context
            gc_fc_q = fc_q_b;

            // Send a GC request
            reassembly_gc_req_fifo_wrreq = 1;
            reassembly_gc_req_fifo_data.pointer = gc_fc_q.pointer;
            reassembly_gc_req_fifo_data.ll_valid = gc_fc_q.ll_valid;
            reassembly_gc_req_fifo_data.meta.ooo_flow_id = gc_ooo_flow_id_r;

            reassembly_gc_req_fifo_data.meta.tuple = gc_fc_q.tuple;
            reassembly_gc_req_fifo_data.meta.addr0 = gc_fc_q.addr0;
            reassembly_gc_req_fifo_data.meta.addr1 = gc_fc_q.addr1;
            reassembly_gc_req_fifo_data.meta.addr2 = gc_fc_q.addr2;
            reassembly_gc_req_fifo_data.meta.addr3 = gc_fc_q.addr3;

            // The OOO flow's head LL entry is invalid. Error state, should
            // not reach here (for the current design, a OOO flow without a
            // pending packet in the flow queue should not have an entry
            // in the heap).
            if (gc_fc_q.ooo_flow_ll.head == OOO_FLOW_LL_INVALID_PTR) begin
                `ifdef DEBUG
                $error("[SC, GC] GC'd flow %0d has invalid head",
                       gc_ooo_flow_id_r);
                $finish;
                `endif
                gc_fsm_state_next = GC_FSM_STATE_IDLE;
            end
            else begin
                // Else, latch currptr and proceed to LL read
                gc_lle_currptr_q = gc_fc_q.ooo_flow_ll.head;
                gc_fsm_state_next = GC_FSM_STATE_LL_RD;
            end
        end
        // LL read state. Read this flow's head LL entry.
        GC_FSM_STATE_LL_RD: begin
            gc_fsm_state_next = GC_FSM_STATE_LL_RD;

            if (!(lle_nextptr_wren_a && (lle_nextptr_address_a ==
                                         gc_lle_currptr_q_r)) &&
                (reassembly_service_fsm_state !=
                 REASSEMBLY_SERVICE_FSM_STATE_LL_RD)) begin
                // Read the LLE
                gc_lle_rden = 1;
                lle_meta_rden_b = 1;
                lle_nextptr_rden_b = 1;
                lle_meta_address_b = gc_lle_currptr_q_r;
                lle_nextptr_address_b = gc_lle_currptr_q_r;

                // Proceed to read done
                gc_fsm_state_next = GC_FSM_STATE_LL_RD_DONE;
            end
        end
        // LL read done state. Release the packet metadata (enque
        // into the scheduler's output FIFO), add the current LLE
        // to the free-list, and proceed to the next LLE.
        GC_FSM_STATE_LL_RD_DONE: begin
            gc_fsm_state_next = GC_FSM_STATE_LL_RD_DONE;

            // If the corresponding read completed on this
            // cycle, latch the next pointer and metadata.
            if (gc_lle_rden_r) begin
                gc_lle_meta_q = lle_meta_q_b;
                gc_lle_nextptr_q = lle_nextptr_q_b;
            end
            if (!out_sched_fifo_almost_full &&
                !out_sched_fifo_valid_int && !fl_wrreq) begin
                gc_inc_cur_ll_release_cnt = 1;

                // Release the current LLE
                fl_wrreq = 1;
                gc_inc_ooo_flow_fl_size = 1;
                fl_data = gc_lle_currptr_q_r;

                // Release the packet metadata
                out_sched_fifo_valid_int = 1;
                out_sched_fifo_meta_int = gc_lle_meta_q;
                out_sched_fifo_meta_int.pkt_flags = PKT_DROP;

                // If the next pointer is valid, update (latch) the
                // current pointer and proceed to the next LL entry.
                if (gc_lle_nextptr_q != OOO_FLOW_LL_INVALID_PTR) begin
                    gc_lle_currptr_q = gc_lle_nextptr_q;
                    gc_fsm_state_next = GC_FSM_STATE_LL_RD;
                end
                // Else, return to idle
                else begin
                    gc_fsm_state_next = GC_FSM_STATE_IDLE;
                end
            end
        end
        // Invalid state, return to idle
        default: begin
            gc_fsm_state_next = GC_FSM_STATE_IDLE;
        end
    endcase

    /**
     * Garbage-collection (GC) Response FSM.
     */
    case (gc_response_fsm_state)
        // Idle state. Wait until the Reassembly->
        // Scheduler GC response FIFO is non-empty.
        GC_RESPONSE_FSM_STATE_IDLE: begin
            gc_response_fsm_state_next = (
                GC_RESPONSE_FSM_STATE_IDLE);

            // If the response FIFO has an entry, and it's not the
            // flow that's currently being served by the GC FSM,
            // move to the update FT state.
            if (!reassembly_gc_rsp_fifo_empty &&
                !(gc_ooo_flow_id_valid && (gc_ooo_flow_id ==
                  reassembly_gc_rsp_fifo_q.ooo_flow_id))) begin
                // Latch the response metadata and deque the FIFO
                gc_response_meta = reassembly_gc_rsp_fifo_q;
                reassembly_gc_rsp_fifo_rdreq = 1;

                gc_response_fsm_state_next = (
                    GC_RESPONSE_FSM_STATE_UPDATE_FT);
            end
        end
        // Update FT state. If the FT update FIFO
        // is not busy, insert a delete operation
        // corresponding to this OOO flow.
        GC_RESPONSE_FSM_STATE_UPDATE_FT: begin
            gc_response_fsm_state_next = (
                GC_RESPONSE_FSM_STATE_UPDATE_FT);

            if (reassembly_service_fsm_state !=
                REASSEMBLY_SERVICE_FSM_STATE_FC_WR) begin
                // Set the update data
                ft_update_fifo_wrreq = 1;
                ft_update_fifo_data.is_delete = 1;
                ft_update_fifo_data.rel_pkt_cnt = 0;
                ft_update_fifo_data.tuple = gc_response_meta_r.tuple;
                ft_update_fifo_data.addr0 = gc_response_meta_r.addr0;
                ft_update_fifo_data.addr1 = gc_response_meta_r.addr1;
                ft_update_fifo_data.addr2 = gc_response_meta_r.addr2;
                ft_update_fifo_data.addr3 = gc_response_meta_r.addr3;

                // Return to idle
                gc_response_fsm_state_next = (
                    GC_RESPONSE_FSM_STATE_IDLE);
            end
        end
        // Invalid state, return to idle
        default: begin
            gc_response_fsm_state_next = (
                GC_RESPONSE_FSM_STATE_IDLE);
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        fl_q_r <= 0;
        fc_q_a_r <= 0;
        fc_data_a_r <= 0;
        fc_rden_b_r <= 0;
        in_fce_data_r1 <= 0;
        in_meta_data_r1 <= 0;
        in_token_data_r <= 0;
        lle_nextptr_rden_b_r <= 0;
        lle_nextptr_data_a_r <= 0;

        reassembly_service_fsm_fc_q_r <= 0;
        reassembly_service_fsm_fc_data_r = 0;
        reassembly_service_fsm_lle_meta_q_r <= 0;
        reassembly_service_fsm_fc_address_r <= 0;
        reassembly_service_fsm_lle_address_r <= 0;
        reassembly_service_fsm_lle_nextptr_q_r <= 0;

        gc_fc_q_r <= 0;
        gc_lle_rden_r <= 0;
        gc_lle_meta_q_r <= 0;
        gc_ooo_flow_id_r <= 0;
        gc_lle_nextptr_q_r <= 0;
        gc_lle_currptr_q_r <= 0;
        gc_ooo_flow_fl_size_r <= 0;
        gc_ooo_flow_id_valid_r <= 0;

        gc_response_meta_r <= 0;

        gc_fsm_state <= GC_FSM_STATE_IDLE;
        ft_service_fsm_state <= FT_SERVICE_FSM_STATE_IDLE;
        gc_response_fsm_state <= GC_RESPONSE_FSM_STATE_IDLE;
        reassembly_service_fsm_state <= REASSEMBLY_SERVICE_FSM_STATE_IDLE;

        // Scheduler output FIFO
        out_sched_fifo_meta <= 0;
        out_sched_fifo_valid <= 0;

        // Free-list initialization
        fl_data_init <= 0;
        fl_fsm_state <= FL_FSM_STATE_IDLE;

        // Debug signals
        gc_cur_ll_release_cnt_r <= 0;
    end
    else begin
        fl_q_r <= fl_q;
        fc_q_a_r <= fc_q_a;
        in_fce_data_r1 <= in_fce_data;
        in_fce_data_r2 <= in_fce_data_r1;

        fc_data_a_r <= fc_data_a;
        fc_rden_b_r <= fc_rden_b;
        lle_nextptr_rden_b_r <= lle_nextptr_rden_b;
        lle_nextptr_data_a_r <= lle_nextptr_data_a;

        gc_fc_q_r <= gc_fc_q;
        gc_lle_rden_r <= gc_lle_rden;
        gc_lle_meta_q_r <= gc_lle_meta_q;
        gc_ooo_flow_id_r <= gc_ooo_flow_id;
        gc_lle_nextptr_q_r <= gc_lle_nextptr_q;
        gc_lle_currptr_q_r <= gc_lle_currptr_q;
        gc_ooo_flow_id_valid_r <= gc_ooo_flow_id_valid;
        gc_ooo_flow_fl_size_r <= ((gc_ooo_flow_fl_size_r +
                                   gc_inc_ooo_flow_fl_size) -
                                   gc_dec_ooo_flow_fl_size);

        gc_response_meta_r <= gc_response_meta;

        /**
         * Reassembly latches, forwarding logic.
         */
         reassembly_service_fsm_lle_meta_q_r <= (
             reassembly_service_fsm_lle_meta_q);

        reassembly_service_fsm_fc_address_r <= (
            reassembly_service_fsm_fc_address);

        reassembly_service_fsm_lle_address_r <= (
            reassembly_service_fsm_lle_address);

        // If there's a colliding write to the latched reassembly
        // FC address on any cycle, register the portA write data.
        if (fc_wren_a && (fc_address_a ==
            reassembly_service_fsm_fc_address)) begin
            reassembly_service_fsm_fc_q_r <= fc_data_a;
        end
        // Else, keep the latched value
        else begin
            reassembly_service_fsm_fc_q_r <= (
                reassembly_service_fsm_fc_q);
        end

        // If there's a colliding write to the latched reassembly
        // LLE address on a cycle, register the portA write data.
        if (lle_nextptr_wren_a && (lle_nextptr_address_a ==
                reassembly_service_fsm_lle_address)) begin
            reassembly_service_fsm_lle_nextptr_q_r <= (
                lle_nextptr_data_a);
        end
        // Else, keep the latched value
        else begin
            reassembly_service_fsm_lle_nextptr_q_r <= (
                reassembly_service_fsm_lle_nextptr_q);
        end

        // Register the FCE data
        if (reassembly_service_fsm_fc_data_latch_en) begin
            reassembly_service_fsm_fc_data_r <= fc_data_b;
        end

        in_meta_data_r1 <= in_meta_data;
        in_meta_data_r2 <= in_meta_data_r1;

        in_token_data_r <= in_token_data;
        gc_fsm_state <= gc_fsm_state_next;
        ft_service_fsm_state <= ft_service_fsm_state_next;
        gc_response_fsm_state <= gc_response_fsm_state_next;
        reassembly_service_fsm_state <= reassembly_service_fsm_state_next;

        // Scheduler output FIFO
        out_sched_fifo_meta <= out_sched_fifo_meta_int;
        out_sched_fifo_valid <= out_sched_fifo_valid_int;

        // Free-list initialization
        fl_fsm_state <= fl_fsm_state_next;
        fl_data_init <= fl_data_init_next;

        // Debug signals
        if (gc_reset_cur_ll_release_cnt) begin
            gc_cur_ll_release_cnt_r <= 0;
        end
        else if (gc_inc_cur_ll_release_cnt) begin
            gc_cur_ll_release_cnt_r <= gc_cur_ll_release_cnt_r + 1;

            if (gc_fsm_state_next == GC_FSM_STATE_IDLE) begin
                `ifdef DEBUG
                $display("[SC, GC] Dropped OOO flow ID %0d with %0d LL packets",
                         gc_ooo_flow_id, (gc_cur_ll_release_cnt_r + 1));
                `endif
            end
        end

        if ((ft_service_fsm_state == FT_SERVICE_FSM_STATE_DATA_WR) &&
            ft_service_fsm_ooo_flow_valid && (in_fce_data_r1.slow_cnt != 0)) begin
                // Sanity check: The OOO flow state should be consistent
                // with the corresponding flow context in the primary FT.
                assert(fc_q_a.tuple == in_fce_data_r1.tuple)
                else begin
                    $error("[SC] OOO flow state is inconsistent with FT");
                    $finish;
                end
        end
    end
    // DEBUG
    `ifdef DEBUG
    if (heap_in_enque_en) begin
        $display("[SC] Inserting OOO flow ID %0d into the heap with priority %0d",
                 heap_in_enque_ooo_flow_id, heap_in_enque_priority);
    end
    if ((gc_fsm_state == GC_FSM_STATE_IDLE) && gc_ooo_flow_id_valid) begin
        $display("[SC, GC] Started dropping OOO flow ID %0d", gc_ooo_flow_id);
    end
    if (reassembly_state_idle && heap_size != 0) begin
        $display("[SC] Performance warning: Heap has entries but reassembly is idle!");
    end
    `endif
end

/**
 * Module instantiations.
 */
// Free-list entries FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(OOO_FLOW_LL_ENTRY_AWIDTH),
    .DEPTH(OOO_FLOW_LL_MAX_NUM_ENTRIES)
)
ooo_flow_ll_fl_fifo (
    .clock(clk),
    .data(fl_data),
    .rdreq(fl_rdreq),
    .wrreq(fl_wrreq),
    .empty(fl_empty),
    .full(), // Unused
    .q(fl_q),
    .usedw() // Unused
);

// FT update FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(FT_UPDATE_T_WIDTH),
    .DEPTH(FT_UPDATE_FIFO_DEPTH)
)
ft_update_fifo (
    .clock(clk),
    .data(ft_update_fifo_data),
    .rdreq(ft_update_fifo_rdreq),
    .wrreq(ft_update_fifo_wrreq),
    .empty(ft_update_fifo_empty),
    .full(ft_update_fifo_full),
    .q(ft_update_fifo_q),
    .usedw() // Unused
);

// Reassembly GC request FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(REASSEMBLY_GC_REQ_T_WIDTH),
    .DEPTH(REASSEMBLY_GC_FIFO_DEPTH)
)
reassembly_gc_req_fifo (
    .clock(clk),
    .data(reassembly_gc_req_fifo_data),
    .rdreq(reassembly_gc_req_fifo_rdreq),
    .wrreq(reassembly_gc_req_fifo_wrreq),
    .empty(reassembly_gc_req_fifo_empty),
    .full(reassembly_gc_req_fifo_full),
    .q(reassembly_gc_req_fifo_q),
    .usedw() // Unused
);

// Reassembly GC response FIFO
sc_fifo #(
    .IS_SHOWAHEAD(1),
    .IS_OUTDATA_REG(0),
    .DWIDTH(REASSEMBLY_GC_META_T_WIDTH),
    .DEPTH(REASSEMBLY_GC_FIFO_DEPTH)
)
reassembly_gc_response_fifo (
    .clock(clk),
    .data(reassembly_gc_rsp_fifo_data),
    .rdreq(reassembly_gc_rsp_fifo_rdreq),
    .wrreq(reassembly_gc_rsp_fifo_wrreq),
    .empty(reassembly_gc_rsp_fifo_empty),
    .full(reassembly_gc_rsp_fifo_full),
    .q(reassembly_gc_rsp_fifo_q),
    .usedw() // Unused
);

// OOO flow context table
bram_true2port #(
    .DWIDTH(OOO_FLOW_FC_ENTRY_T_WIDTH),
    .AWIDTH(OOO_FLOW_ID_AWIDTH),
    .DEPTH(MAX_NUM_OOO_FLOWS),
    .IS_OUTDATA_REG(0)
)
ooo_flow_context_table (
    .clock(clk),
    .address_a(fc_address_a),
    .address_b(fc_address_b),
    .data_a(fc_data_a),
    .data_b(fc_data_b),
    .rden_a(fc_rden_a),
    .rden_b(fc_rden_b),
    .wren_a(fc_wren_a),
    .wren_b(fc_wren_b),
    .q_a(fc_q_a),
    .q_b(fc_q_b)
);

// Linked-list entries (value)
bram_true2port #(
    .DWIDTH(META_WIDTH),
    .AWIDTH(OOO_FLOW_LL_ENTRY_AWIDTH),
    .DEPTH(OOO_FLOW_LL_MAX_NUM_ENTRIES),
    .IS_OUTDATA_REG(0)
)
ooo_flow_ll_entries_meta (
    .clock(clk),
    .address_a(lle_meta_address_a),
    .address_b(lle_meta_address_b),
    .data_a(lle_meta_data_a),
    .data_b(lle_meta_data_b),
    .rden_a(1'b0), // Unused
    .rden_b(lle_meta_rden_b),
    .wren_a(lle_meta_wren_a),
    .wren_b(1'b0), // Unused
    .q_a(lle_meta_q_a),
    .q_b(lle_meta_q_b)
);

// Linked-list entries (next pointer)
bram_true2port #(
    .DWIDTH(OOO_FLOW_LL_ENTRY_PTR_T_WIDTH),
    .AWIDTH(OOO_FLOW_LL_ENTRY_AWIDTH),
    .DEPTH(OOO_FLOW_LL_MAX_NUM_ENTRIES),
    .IS_OUTDATA_REG(0)
)
ooo_flow_ll_entries_nextptr (
    .clock(clk),
    .address_a(lle_nextptr_address_a),
    .address_b(lle_nextptr_address_b),
    .data_a(lle_nextptr_data_a),
    .data_b(lle_nextptr_data_b),
    .rden_a(1'b0), // Unused
    .rden_b(lle_nextptr_rden_b),
    .wren_a(lle_nextptr_wren_a),
    .wren_b(1'b0), // Unused
    .q_a(lle_nextptr_q_a),
    .q_b(lle_nextptr_q_b)
);

// Bounded queue
if (SCHEDULER_REASSEMBLY_POLICY == "WSJF") begin
bounded_wsjf_queue wsjf_queue (
    // General inputs
    .clk(clk),
    .rst(rst),
    .in_enque_en(heap_in_enque_en),
    .in_enque_ooo_flow_id(heap_in_enque_ooo_flow_id),
    .in_enque_priority(heap_in_enque_priority),
    .in_enque_ready(heap_in_enque_ready),
    .out_deque_min_en(heap_out_deque_min_en),
    .out_deque_min_ready(heap_out_deque_min_ready),
    .out_deque_min_ooo_flow_id(heap_out_deque_min_ooo_flow_id),
    .out_deque_min_priority(heap_out_deque_min_priority),
    .in_deque_max_req_en(heap_in_deque_max_req_en),
    .in_deque_max_req_ready(heap_in_deque_max_req_ready),
    .out_deque_max_en(heap_out_deque_max_en),
    .out_deque_max_ready(heap_out_deque_max_ready),
    .out_deque_max_ooo_flow_id(heap_out_deque_max_ooo_flow_id),
    .out_deque_max_priority(heap_out_deque_max_priority),
    .queue_ready(), // Unused
    .queue_size(heap_size)
);
end
else if (SCHEDULER_REASSEMBLY_POLICY == "FCFS") begin
bounded_fcfs_queue fcfs_queue (
    // General inputs
    .clk(clk),
    .rst(rst),
    .in_enque_en(heap_in_enque_en),
    .in_enque_ooo_flow_id(heap_in_enque_ooo_flow_id),
    .in_enque_priority(heap_in_enque_priority),
    .in_enque_ready(heap_in_enque_ready),
    .out_deque_min_en(heap_out_deque_min_en),
    .out_deque_min_ready(heap_out_deque_min_ready),
    .out_deque_min_ooo_flow_id(heap_out_deque_min_ooo_flow_id),
    .out_deque_min_priority(heap_out_deque_min_priority),
    .in_deque_max_req_en(heap_in_deque_max_req_en),
    .in_deque_max_req_ready(heap_in_deque_max_req_ready),
    .out_deque_max_en(heap_out_deque_max_en),
    .out_deque_max_ready(heap_out_deque_max_ready),
    .out_deque_max_ooo_flow_id(heap_out_deque_max_ooo_flow_id),
    .out_deque_max_priority(heap_out_deque_max_priority),
    .queue_ready(), // Unused
    .queue_size(heap_size)
);
end
else begin
$error("[SC] Unimplemented scheduling policy.");
end

// Flow reassembly
flow_reassembly flow_reassembly_inst (
    // General inputs
    .clk(clk),
    .rst(rst),
    // Heap input
    .heap_out_deque_min_en(heap_out_deque_min_en),
    .heap_out_deque_min_ready(heap_out_deque_min_ready),
    .heap_out_deque_min_ooo_flow_id(heap_out_deque_min_ooo_flow_id),
    .heap_out_deque_min_priority(heap_out_deque_min_priority),
    // Scheduler read channel
    .scheduler_rdch_rden(reassembly_rdch_rden),
    .scheduler_rdch_ooo_flow_id(reassembly_rdch_ooo_flow_id),
    .scheduler_rdch_ready(reassembly_rdch_ready),
    .scheduler_rdch_rd_valid(reassembly_rdch_rd_valid),
    .scheduler_rdch_rd_ooo_flow_invalid(reassembly_rdch_rd_ooo_flow_invalid),
    .scheduler_rdch_meta(reassembly_rdch_meta),
    .scheduler_rdch_fce(reassembly_rdch_fce),
    // Scheduler write channel
    .scheduler_wrch_wren(reassembly_wrch_wren),
    .scheduler_wrch_ready(reassembly_wrch_ready),
    .scheduler_wrch_is_delete(reassembly_wrch_is_delete),
    .scheduler_wrch_update_fce(reassembly_wrch_update_fce),
    .scheduler_wrch_rel_pkt_cnt(reassembly_wrch_rel_pkt_cnt),
    // GC request
    .gc_req_state_idle(reassembly_gc_req_state_idle),
    .gc_req_fifo_rdreq(reassembly_gc_req_fifo_rdreq),
    .gc_req_fifo_empty(reassembly_gc_req_fifo_empty),
    .gc_req_fifo_q(reassembly_gc_req_fifo_q),
    .gc_fl_fill_level(gc_reassembly_fl_size),
    // GC response
    .gc_rsp_fifo_full(reassembly_gc_rsp_fifo_full),
    .gc_rsp_fifo_data(reassembly_gc_rsp_fifo_data),
    .gc_rsp_fifo_wrreq(reassembly_gc_rsp_fifo_wrreq),
    // Reorder FIFO
    .reorder_meta(out_reassembly_fifo_meta),
    .reorder_valid(out_reassembly_fifo_valid),
    .reorder_ready(out_reassembly_fifo_ready),
    .reorder_almost_full(out_reassembly_fifo_almost_full),
    // Debug
    .reassembly_state_idle(reassembly_state_idle)
);

endmodule
