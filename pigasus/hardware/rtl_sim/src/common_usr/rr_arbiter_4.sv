//Round-Robin Arbiter design based on 
//Arbiters: Design Ideas and Coding Styles (Matt Weber)

module rr_arbiter_4(clk,rst,
    req,grant
);

parameter DWIDTH = 4;

input clk;
input rst;
input [DWIDTH-1:0] req;
output logic [DWIDTH-1:0] grant;

logic [DWIDTH-1:0] mask;
logic [DWIDTH-1:0] req_masked;
logic [DWIDTH-1:0] higher_pri_reqs_1;
logic [DWIDTH-1:0] grant_1;
logic [DWIDTH-1:0] higher_pri_reqs_2;
logic [DWIDTH-1:0] grant_2;
logic no_req_masked;


//simple priority arbitration for masked portion
assign req_masked = req & mask;
//assign higher_pri_reqs_1[DWIDTH-1:1] = higher_pri_reqs_1[DWIDTH-2:0] | req_masked[DWIDTH-2:0];
//assign higher_pri_reqs_1[0] = 1'b0;
assign higher_pri_reqs_1[0] = 1'b0;
assign higher_pri_reqs_1[1] = req_masked[0];
assign higher_pri_reqs_1[2] = req_masked[0]|req_masked[1];
assign higher_pri_reqs_1[3] = req_masked[0]|req_masked[1]|req_masked[2];
//assign higher_pri_reqs_1[4] = req_masked[0]|req_masked[1]|req_masked[2]|req_masked[3];
//assign higher_pri_reqs_1[5] = req_masked[0]|req_masked[1]|req_masked[2]|req_masked[3]|req_masked[4];
//assign higher_pri_reqs_1[6] = req_masked[0]|req_masked[1]|req_masked[2]|req_masked[3]|req_masked[4]|req_masked[5]; 
//assign higher_pri_reqs_1[7] = req_masked[0]|req_masked[1]|req_masked[2]|req_masked[3]|req_masked[4]|req_masked[5]|req_masked[6]; 

assign grant_1 = req_masked & ~higher_pri_reqs_1;

//Simple priority aribration for unmasked portion
//assign higher_pri_reqs_2[DWIDTH-1:1] = higher_pri_reqs_2[DWIDTH-2:0] | req[DWIDTH-2:0];
//assign higher_pri_reqs_2[0] = 1'b0;
assign higher_pri_reqs_2[0] = 1'b0;
assign higher_pri_reqs_2[1] = req[0];
assign higher_pri_reqs_2[2] = req[0]|req[1];
assign higher_pri_reqs_2[3] = req[0]|req[1]|req[2];
//assign higher_pri_reqs_2[4] = req[0]|req[1]|req[2]|req[3];
//assign higher_pri_reqs_2[5] = req[0]|req[1]|req[2]|req[3]|req[4];
//assign higher_pri_reqs_2[6] = req[0]|req[1]|req[2]|req[3]|req[4]|req[5]; 
//assign higher_pri_reqs_2[7] = req[0]|req[1]|req[2]|req[3]|req[4]|req[5]|req[6]; 

assign grant_2 = req & ~higher_pri_reqs_2;

//Use grant_masked if there is any there, otherwise use grant_unmasked
assign no_req_masked = ~(|req_masked);
assign grant = ({DWIDTH{no_req_masked}} & grant_2) | grant_1;

always @(posedge clk)
begin
    if (rst) begin
        mask <= {DWIDTH{1'b1}};
    end else begin
        if (|req_masked) begin //which arbiter was used
            mask <= higher_pri_reqs_1;
        end else begin
            if (|req) begin //Only update if there's a req
                mask <= higher_pri_reqs_2;
            end else begin
                mask <= mask;
            end
        end
    end
end

endmodule

