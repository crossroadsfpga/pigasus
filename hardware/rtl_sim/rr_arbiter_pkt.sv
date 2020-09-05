//Round-Robin Arbiter with pkt support

module rr_arbiter_pkt #(
    parameter DWIDTH = 2
) (
    input   logic               clk,
    input   logic               rst,
    input   logic [DWIDTH-1:0]  req,
    input   logic [DWIDTH-1:0]  sop,
    input   logic [DWIDTH-1:0]  eop,
    output  logic [DWIDTH-1:0]  grant
);

logic               lock;
logic [DWIDTH-1:0]  arb_req;
logic [DWIDTH-1:0]  arb_grant;
logic [DWIDTH-1:0]  lock_grant;

// Only perform arbitration at the begining of a pkt
assign arb_req = lock ? 0 : (req & sop);
assign grant = lock ? lock_grant : arb_grant;

always @(posedge clk) begin
    if (rst) begin
        lock <= 0;
        lock_grant <= 0;
    end
    else begin
        if (!lock) begin
            case (arb_grant)
                2'b01: begin
                    lock_grant <= 2'b01;
                    // Min-size pkt, don't lock
                    if (req[0] & !eop[0]) begin
                        lock <= 1;
                    end
                end
                2'b10: begin
                    lock_grant <= 2'b10;
                    if (req[1] & !eop[1]) begin
                        lock <= 1;
                    end
                end
                default: begin
                    lock_grant <= 2'b00;
                end
            endcase
        end
        // Release the lock
        else begin
            case (lock_grant)
                2'b01: begin
                    if (req[0] & eop[0]) begin
                        lock <= 0;
                        lock_grant <= 0;
                    end
                end
                2'b10: begin
                    if (req[1] & eop[1]) begin
                        lock <= 0;
                        lock_grant <= 0;
                    end
                end
            endcase
        end
    end
end

// Wrapper to support sop and eop
rr_arbiter #(
    .DWIDTH(DWIDTH)
)
arb_inst (
    .clk   (clk),
    .rst   (rst),
    .req   (arb_req),
    .grant (arb_grant)
);

endmodule
