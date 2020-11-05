`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

module pkt_checker (
    input   logic           clk,
    input   logic           rst,
    input   logic           in_sop,
    input   logic           in_eop,
    input   logic           in_valid,
    input   logic           in_ready,
    output  logic [31:0]    error
);

typedef enum {
    IDLE,
    SOP,
    EOP,
    ERROR
} state_t;
state_t state;

assign empty_meta = 0;
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        error <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                if (in_valid & in_ready) begin
                    if (in_sop) begin
                        state <= SOP;
                    end
                    else begin
                        error <= error + 1;
                    end
                end
            end
            SOP: begin
                if (in_valid & in_ready) begin
                    if (in_eop) begin
                        if (!in_sop) begin
                            state <= EOP;
                        end
                    end
                    else begin
                        if (in_sop) begin
                            error <= error + 1;
                        end
                    end
                end
            end
            EOP: begin
                // Expect sop
                if (in_valid & in_ready) begin
                    if (in_sop) begin
                        if (!in_eop) begin
                            state <= SOP;
                        end
                    end
                    else begin
                        error <= error + 1;
                    end
                end
            end
            default: begin
                $display("Error state!");
                $finish;
            end
        endcase
    end
end

endmodule
