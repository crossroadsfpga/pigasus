module dc_back_pressure #(
    parameter FULL_LEVEL = 490
) (
    input   logic           clk,
    input   logic           rst,
    output  logic           csr_address,
    output  logic           csr_read,
    output  logic           csr_write,
    input   logic [31:0]    csr_readdata,
    output  logic [31:0]    csr_writedata,
    output  logic           almost_full
);

assign csr_address      = 0;
assign csr_write        = 0;
assign csr_read         = 1;
assign csr_writedata    = 0;

always @(posedge clk) begin
    if (csr_readdata >= FULL_LEVEL) begin
        almost_full <= 1;
    end
    else begin
        almost_full <= 0;
    end
end

endmodule
