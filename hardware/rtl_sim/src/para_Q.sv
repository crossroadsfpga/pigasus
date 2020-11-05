`include "./src/struct_s.sv"
module para_Q (
    input logic         clk,
    input logic         rst,

    // Port A
    input tuple_t       addr_a,
    input fce_t         data_a,
    input logic         rden_a,
    input logic         wren_a,
    output logic        rd_valid_a, // 2 cycle delay
    output logic        rd_hit_a,   // Hit in queue?
    output fce_t        q_a,

    // Port B
    input tuple_t       addr_b,
    input fce_t         data_b,
    input logic         rden_b,
    input logic         wren_b,
    output logic        rd_valid_b, // 2 cycle delay
    output logic        rd_hit_b,   // Hit in queue?
    output fce_t        q_b,

    // Insert/Delete operations
    input logic         op_en,
    input logic         op_id, // PQ_OP_FAST_{INSERT, DELETE}
    input fce_t         op_data,

    // Deque operation
    input logic         deque_en,
    output fce_t        deque_data,
    output logic        deque_done, // Raised when deque completes

    // Error signals
    output logic [7:0]  error,
    output logic        is_error_fatal,

    // Debug signals
    output logic        full,
    output logic        empty,
    input logic         debug
);

/**
 * Input pipeline registers.
 */
// Port R/Ws
fce_t data_a_r;
logic rden_a_r;
logic wren_a_r;
fce_t data_b_r;
logic rden_b_r;
logic wren_b_r;

// Insert, delete, deque
logic op_en_r;
logic op_id_r;
fce_t op_data_r;
logic deque_en_r;

// Housekeeping
fce_t entries[PQ_DEPTH-1:0]; // Queue entries
logic [PQ_AWIDTH:0] valid_count; // No. of valid entries
logic [PQ_DEPTH-1:0] is_valid; // Valid entries bitvector
logic [PQ_DEPTH-1:0] is_hit_a_r; // Hits (Port A) bitvector
logic [PQ_DEPTH-1:0] is_hit_b_r; // Hits (Port B) bitvector
logic [PQ_DEPTH-1:0] is_hit_delete_r; // Hits (Delete) bitvector

logic is_deque; // Perform a deque on this cycle
logic is_delete; // Perform a delete on this cycle
logic is_insert; // Perform an insert on this cycle
logic [PQ_DEPTH-1:0] shift_vec; // Entries-to-shift bitvector
logic [PQ_DEPTH-1:0] first_empty; // Left-most empty entry (one-hot)

// Error states and signals
localparam ERROR_FATAL_INSERT_FULL  = 8'b1;      // Inserting into a full queue
localparam ERROR_FATAL_A_B_COLLIDE  = 8'b1 << 1; // Accesses A, B incompatible
localparam ERROR_FATAL_DUPLICATES   = 8'b1 << 2; // Detected duplicate entries
localparam ERROR_FATAL_CORRUPT_Q    = 8'b1 << 3; // Queue state is corrupted
localparam ERROR_FATAL_DEQUE_OP     = 8'b1 << 4; // Same-cycle deque/delete
localparam ERROR_DELETE_NO_ENTRY    = 8'b1 << 5; // Entry to delete DNE
localparam ERROR_WRITE_NO_ENTRY     = 8'b1 << 6; // Entry to write DNE
localparam ERROR_AB_OP_COLLIDE      = 8'b1 << 7; // Accesses A/B and op collide

localparam ERROR_FATAL_MASK = (ERROR_FATAL_INSERT_FULL  |
                               ERROR_FATAL_A_B_COLLIDE  |
                               ERROR_FATAL_DUPLICATES   |
                               ERROR_FATAL_CORRUPT_Q    |
                               ERROR_FATAL_DEQUE_OP     );
// Queue state corrupted?
logic queue_corrupted;

int i;
always @(*) begin
    for (i = 0; i < PQ_DEPTH; i++) begin
        is_valid[i] = entries[i].valid;
    end
end

// Deque, delete, insert signals
assign is_deque = deque_en_r;
assign is_delete = (is_hit_delete_r != 0);
assign is_insert = (op_en_r & (op_id_r == PQ_OP_FAST_INSERT));

// Shift bitvector
assign shift_vec[0] = deque_en_r | is_hit_delete_r[0];
assign shift_vec[1] = shift_vec[0] | is_hit_delete_r[1];
assign shift_vec[2] = shift_vec[1] | is_hit_delete_r[2];
assign shift_vec[3] = shift_vec[2] | is_hit_delete_r[3];
assign shift_vec[4] = shift_vec[3] | is_hit_delete_r[4];
assign shift_vec[5] = shift_vec[4] | is_hit_delete_r[5];
assign shift_vec[6] = shift_vec[5] | is_hit_delete_r[6];
assign shift_vec[7] = shift_vec[6] | is_hit_delete_r[7];

// First empty entry (and valid count)
always @(*) begin
    queue_corrupted = 0;
    valid_count = 0;
    first_empty = 0;
    case (is_valid)
        8'b00000000: begin
            valid_count = 0;
            first_empty = 8'b00000001;
        end
        8'b00000001: begin
            valid_count = 1;
            first_empty = 8'b00000010;
        end
        8'b00000011: begin
            valid_count = 2;
            first_empty = 8'b00000100;
        end
        8'b00000111: begin
            valid_count = 3;
            first_empty = 8'b00001000;
        end
        8'b00001111: begin
            valid_count = 4;
            first_empty = 8'b00010000;
        end
        8'b00011111: begin
            valid_count = 5;
            first_empty = 8'b00100000;
        end
        8'b00111111: begin
            valid_count = 6;
            first_empty = 8'b01000000;
        end
        8'b01111111: begin
            valid_count = 7;
            first_empty = 8'b10000000;
        end
        8'b11111111: begin
            valid_count = 8;
            first_empty = 8'b00000000;
        end
        default: begin
            queue_corrupted = 1;
        end
    endcase
end

// Input pipeline registers
always @( posedge clk) begin
    op_en_r <= op_en;
    op_id_r <= op_id;
    data_a_r <= data_a;
    rden_a_r <= rden_a;
    wren_a_r <= wren_a;
    data_b_r <= data_b;
    rden_b_r <= rden_b;
    wren_b_r <= wren_b;
    op_data_r <= op_data;
    deque_en_r <= deque_en;
end

always @( posedge clk) begin
    if (rst) begin
        for (i = 0; i < PQ_DEPTH; i++) begin
            entries[i] <= 0; // Clear queue
        end
        // Output signals
        q_a <= 0;
        q_b <= 0;
        error <= 0;
        rd_valid_a <= 0;
        rd_valid_b <= 0;
        deque_data <= 0;
        deque_done <= 0;
        // Intermediate signals
        is_hit_a_r <= 0;
        is_hit_b_r <= 0;
        is_hit_delete_r <= 0;
    end
    else begin
        /**
         * Set error state. Note: If more than one error is triggered
         * on a single cycle, reports the most significant/fatal one.
         */
        // Could not find the entry corresponding to the write access
        if ((wren_a_r & (is_hit_a_r == 0)) |
            (wren_b_r & (is_hit_b_r == 0))) begin
            error <= (error | ERROR_WRITE_NO_ENTRY);
        end
        // Could not find the entry corresponding to the delete op
        if (op_en_r & (op_id_r == PQ_OP_FAST_DELETE) & !is_delete) begin
            error <= (error | ERROR_DELETE_NO_ENTRY);
        end
        // Accessing an entry that's being simultaneously deleted
        if (is_delete & ((is_hit_a_r == is_hit_delete_r) |
                         (is_hit_b_r == is_hit_delete_r))) begin
            error <= (error | ERROR_AB_OP_COLLIDE);
        end
        // Attempting to deque and delete on the same cycle
        if (is_deque & is_delete) begin
            error <= (error | ERROR_FATAL_DEQUE_OP);
        end
        // Accesses A and B collide in an undefined way
        if ((is_hit_a_r != 0) & (is_hit_a_r == is_hit_b_r) & wren_a_r) begin
            error <= (error | ERROR_FATAL_A_B_COLLIDE);
        end
        // Inserting into a full queue
        if (is_insert & full & !shift_vec[PQ_DEPTH-1]) begin
            error <= (error | ERROR_FATAL_INSERT_FULL);
        end
        // Queue is corrupted
        if (queue_corrupted) begin
            error <= (error | ERROR_FATAL_CORRUPT_Q);
        end

        // Pipeline stage 0: Compute hit-vectors. In order to maintain a con-
        // sistent view of the queue across pipeline stages, changes to queue
        // entries in the next pipeline stage must reflect immediately in the
        // hit vector computation.
        for (i = 0; i < PQ_DEPTH-1; i++) begin

            // Not shifting, use queue positions as-is
            if (!shift_vec[i]) begin
                is_hit_a_r[i] <= (entries[i].valid                          &
                                  (rden_a | wren_a)                         &
                                  (addr_a == entries[i].tuple)              );

                is_hit_b_r[i] <= (entries[i].valid                          &
                                  (rden_b | wren_b)                         &
                                  (addr_b == entries[i].tuple)              );

                is_hit_delete_r[i] <= (entries[i].valid                     &
                                       op_en                                &
                                       (op_id == PQ_OP_FAST_DELETE)         &
                                       (op_data.tuple == entries[i].tuple)  );

                // Inserting a new element into the queue
                if (is_insert & first_empty[i]) begin
                    is_hit_a_r[i] <= (op_data_r.valid                        &
                                      (rden_a | wren_a)                      &
                                      (addr_a == op_data_r.tuple)            );

                    is_hit_b_r[i] <= (op_data_r.valid                        &
                                      (rden_b | wren_b)                      &
                                      (addr_b == op_data_r.tuple)            );

                    is_hit_delete_r[i] <= (op_data_r.valid                   &
                                           op_en                             &
                                           (op_id == PQ_OP_FAST_DELETE)      &
                                           (op_data.tuple == op_data_r.tuple));
                end
            end
            // Shifting is enabled. If there was an incoming write or insert
            // to the right of this entry, patch this bit of the hit-vector.
            else begin
                is_hit_a_r[i] <= (entries[i+1].valid                        &
                                  (rden_a | wren_a)                         &
                                  (addr_a == entries[i+1].tuple)            );

                is_hit_b_r[i] <= (entries[i+1].valid                        &
                                  (rden_b | wren_b)                         &
                                  (addr_b == entries[i+1].tuple)            );

                is_hit_delete_r[i] <= (entries[i+1].valid                   &
                                       op_en                                &
                                       (op_id == PQ_OP_FAST_DELETE)         &
                                       (op_data.tuple == entries[i+1].tuple));

                // Inserting a new element into the queue
                if (is_insert & first_empty[i+1]) begin
                    is_hit_a_r[i] <= (op_data_r.valid                        &
                                      (rden_a | wren_a)                      &
                                      (addr_a == op_data_r.tuple)            );

                    is_hit_b_r[i] <= (op_data_r.valid                        &
                                      (rden_b | wren_b)                      &
                                      (addr_b == op_data_r.tuple)            );

                    is_hit_delete_r[i] <= (op_data_r.valid                   &
                                           op_en                             &
                                           (op_id == PQ_OP_FAST_DELETE)      &
                                           (op_data.tuple == op_data_r.tuple));
                end
            end
        end
        // Not shifting. Simply write/insert to this entry.
        if (!shift_vec[PQ_DEPTH-1]) begin
            is_hit_a_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                        &
                                       (rden_a | wren_a)                                &
                                       (addr_a == entries[PQ_DEPTH-1].tuple)            );

            is_hit_b_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                        &
                                       (rden_b | wren_b)                                &
                                       (addr_b == entries[PQ_DEPTH-1].tuple)            );

            is_hit_delete_r[PQ_DEPTH-1] <= (entries[PQ_DEPTH-1].valid                   &
                                            op_en                                       &
                                            (op_id == PQ_OP_FAST_DELETE)                &
                                            (op_data.tuple == entries[PQ_DEPTH-1].tuple));

            if (is_insert & first_empty[PQ_DEPTH-1]) begin
                is_hit_a_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_a | wren_a)                        &
                                           (addr_a == op_data_r.tuple)              );

                is_hit_b_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_b | wren_b)                        &
                                           (addr_b == op_data_r.tuple)              );

                is_hit_delete_r[PQ_DEPTH-1] <= (op_data_r.valid                     &
                                                op_en                               &
                                                (op_id == PQ_OP_FAST_DELETE)        &
                                                (op_data.tuple == op_data_r.tuple)  );
            end
        end
        // Shifting is enabled. If the queue is completely full and
        // there's a pending insertion, the data is inserted here.
        else begin
            is_hit_a_r[PQ_DEPTH-1] <= 0;
            is_hit_b_r[PQ_DEPTH-1] <= 0;
            is_hit_delete_r[PQ_DEPTH-1] <= 0;

            if (is_insert & (first_empty == 0)) begin
                is_hit_a_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_a | wren_a)                        &
                                           (addr_a == op_data_r.tuple)              );

                is_hit_b_r[PQ_DEPTH-1] <= (op_data_r.valid                          &
                                           (rden_b | wren_b)                        &
                                           (addr_b == op_data_r.tuple)              );

                is_hit_delete_r[PQ_DEPTH-1] <= (op_data_r.valid                     &
                                                op_en                               &
                                                (op_id == PQ_OP_FAST_DELETE)        &
                                                (op_data.tuple == op_data_r.tuple)  );
            end
        end

        // Pipeline stage 1: Handle the write (ports A, B),
        // insert, and shift logic for each queue entry.
        for (i = 0; i < PQ_DEPTH-1; i++) begin

            // Not shifting. If required, simply update the
            // entry with the data to write or insert.
            if (!shift_vec[i]) begin
                if (wren_a_r & is_hit_a_r[i]) begin
                    entries[i] <= data_a_r;
                end
                else if (wren_b_r & is_hit_b_r[i]) begin
                    entries[i] <= data_b_r;
                end
                else if (is_insert & first_empty[i]) begin
                    entries[i] <= op_data_r;
                end
                // Default: latch entry
            end
            // Shifting is enabled. If there was an incoming write or insert to
            // the right of this entry, apply it here, instead. Since shift_vec
            // is a cascading signal, the subsequent iterations of the loop will
            // also enter this conditional block.
            else begin
                if (wren_a_r & is_hit_a_r[i+1]) begin
                    entries[i] <= data_a_r;
                end
                else if (wren_b_r & is_hit_b_r[i+1]) begin
                    entries[i] <= data_b_r;
                end
                else if (is_insert & first_empty[i+1]) begin
                    entries[i] <= op_data_r;
                end
                else begin
                    entries[i] <= entries[i+1];
                end
            end
        end
        // Not shifting. Simply write/insert to this entry.
        if (!shift_vec[PQ_DEPTH-1]) begin
            if (wren_a_r & is_hit_a_r[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= data_a_r;
            end
            else if (wren_b_r & is_hit_b_r[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= data_b_r;
            end
            else if (is_insert & first_empty[PQ_DEPTH-1]) begin
                entries[PQ_DEPTH-1] <= op_data_r;
            end
            // Default: latch entry
        end
        // Shifting is enabled. If the queue is completely full and
        // there's a pending insertion, insert the data here. Else,
        // fill this entry with zeros.
        else begin
            if (is_insert & (first_empty == 0)) begin
                entries[PQ_DEPTH-1] <= op_data_r;
            end
            else begin
                entries[PQ_DEPTH-1] <= 0;
            end
        end

        // Handle reads for Port A
        rd_hit_a <= (is_hit_a_r != 0) & rden_a_r;
        rd_valid_a <= rden_a_r;
        case (is_hit_a_r)
            8'b00000000: begin
                q_a <= 0;
            end
            8'b00000001: begin
                q_a <= entries[0];
            end
            8'b00000010: begin
                q_a <= entries[1];
            end
            8'b00000100: begin
                q_a <= entries[2];
            end
            8'b00001000: begin
                q_a <= entries[3];
            end
            8'b00010000: begin
                q_a <= entries[4];
            end
            8'b00100000: begin
                q_a <= entries[5];
            end
            8'b01000000: begin
                q_a <= entries[6];
            end
            8'b10000000: begin
                q_a <= entries[7];
            end
            // Detected duplicate entries!
            default: begin
                error <= (error | ERROR_FATAL_DUPLICATES);
            end
        endcase

        // Handle reads for Port B
        rd_hit_b <= (is_hit_b_r != 0) & rden_b_r;
        rd_valid_b <= rden_b_r;
        case (is_hit_b_r)
            8'b00000000: begin
                q_b <= 0;
            end
            8'b00000001: begin
                q_b <= entries[0];
            end
            8'b00000010: begin
                q_b <= entries[1];
            end
            8'b00000100: begin
                q_b <= entries[2];
            end
            8'b00001000: begin
                q_b <= entries[3];
            end
            8'b00010000: begin
                q_b <= entries[4];
            end
            8'b00100000: begin
                q_b <= entries[5];
            end
            8'b01000000: begin
                q_b <= entries[6];
            end
            8'b10000000: begin
                q_b <= entries[7];
            end
            // Detected duplicate entries!
            default: begin
                error <= (error | ERROR_FATAL_DUPLICATES);
            end
        endcase

        // If addresses for Ports A, B collide and
        // wren_b is set, forward B's write to q_a.
        if (rden_a_r & wren_b_r & (is_hit_a_r == is_hit_b_r)) begin
            q_a <= data_b_r;
        end

        // Handle deque output
        deque_data <= entries[0];
        deque_done <= 0;
        if (is_deque) begin
            deque_done <= 1;

            // If required, forward the write
            // from ports A, B to the output.
            if (wren_a_r & is_hit_a_r[0]) begin
                deque_data <= data_a_r;
            end
            else if (wren_b_r & is_hit_b_r[0]) begin
                deque_data <= data_b_r;
            end
            // Default: output list head
        end
    end
    // Debug
    if (debug) begin
        $display("Number of valid entries: %d", valid_count);
        $display("Valid vector: %b", is_valid);
        $display("Shift vector: %b", shift_vec);
        $display("Delete vector: %b", is_hit_delete_r);
        $display("1st empty entry: %b", first_empty);
        $display("Port A's hit vector: %b", is_hit_a_r);
        $display("Port B's hit vector: %b", is_hit_b_r);
        $display("Performing deque? %d", is_deque);
        $display("Performing delete? %d", is_delete);
        $display("Performing insert? %d", is_insert);
        $display("Global error state: %b", error);
        $display("Is error(s) fatal? %d\n", is_error_fatal);
    end
end

// Error signals
assign is_error_fatal = ((error & ERROR_FATAL_MASK) != 0);

// Debug signals
assign empty    = (is_valid == 0);
assign full     = (is_valid == 8'b11111111);

endmodule
