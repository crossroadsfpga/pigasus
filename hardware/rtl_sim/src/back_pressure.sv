module back_pressure #(
    parameter FULL_LEVEL = 490
) (
    input   logic clk,
    input   logic rst,
    input   logic in_valid,
    input   logic in_ready,
    input   logic out_valid,
    input   logic out_ready,
    output  logic almost_full
);

localparam AWIDTH = ($clog2(FULL_LEVEL) + 1);

logic [AWIDTH-1:0] cnt;

// Update cnt
always @(posedge clk) begin
    if (rst) begin
        cnt <= 0;
    end
    else begin
        if (in_valid & in_ready) begin
            if (out_valid & out_ready) begin
                cnt <= cnt;
            end
            else begin
                cnt <= cnt + 1'b1;
            end
        end
        else begin
            if (out_valid & out_ready) begin
                cnt <= cnt - 1'b1;
            end
            else begin
                cnt <= cnt;
            end
        end
    end
end
always @(posedge clk) begin
    if (rst) begin
        almost_full <= 0;
    end
    else begin
        if (cnt >= FULL_LEVEL) begin
            almost_full <= 1;
        end
        else begin
            almost_full <= 0;
        end
    end
end

endmodule
