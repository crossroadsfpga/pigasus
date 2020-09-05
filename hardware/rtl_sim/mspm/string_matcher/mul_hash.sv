module mul_hash(clk,ce,a,in_v,p,out_v);
parameter ANDMSK = 64'hdfdfdfdfdfdfdfdf;
parameter NBITS = 15;
input clk;
input ce;
input[63:0] a;
input in_v;
output reg [NBITS-1:0] p;
output reg out_v;

wire [63:0] b;
wire [17:0] a0;
wire [17:0] a1;
wire [17:0] a2;
wire [17:0] a3;
wire [17:0] b0;
wire [17:0] b1;
wire [17:0] b2;
wire [17:0] b3;

wire [36:0] ab0;
wire [36:0] ab18;
wire [36:0] ab36;
wire [36:0] ab36_1;
wire [36:0] ab54;
wire [36:0] ab54_1;

reg  [63:0] sum1_0;
reg  [63:0] sum2_0;
reg  [63:0] sum3_0;
reg  [63:0] sum_1;
reg  [63:0] sum_sign;

wire [2:0] ena;

reg [63:0] a_reg0;
reg [63:0] b_reg0;
reg [63:0] a_reg1;
reg [63:0] b_reg1;
reg [63:0] a_reg2;
reg [63:0] b_reg2;
reg in_v_reg0;
reg in_v_reg1;


wire signed [63:0] temp;
wire [63:0] after_and;

reg sign;
reg sign_r1;
reg sign_r2;
reg sign_r3;
reg sign_r4;
reg sign_r5;
reg sign_r6;
reg sign_r7;

reg valid;
reg valid_r1;
reg valid_r2;
reg valid_r3;
reg valid_r4;
reg valid_r5;
reg valid_r6;
reg valid_r7;
reg valid_r8;
reg valid_r9;
reg valid_r10;


assign b = 64'h0b4e0ef37bc32127;
assign a0 = a_reg2[17:0];
assign a1 = a_reg2[35:18];
assign a2 = a_reg2[53:36];
assign a3 = a_reg2[63:54];
assign b0 = b_reg2[17:0];
assign b1 = b_reg2[35:18];
assign b2 = b_reg2[53:36];
assign b3 = b_reg2[63:54];

assign ena = {1'b0,1'b0,ce};
 
always @ (posedge clk) begin
    if (ce) begin
        a_reg0 <= a;
        b_reg0 <= b;
        a_reg1 <= a_reg0 & ANDMSK;
        b_reg1 <= b_reg0;
        b_reg2 <= b_reg1;
		if(a_reg0[63]) begin
			sign <= 1;
		end else begin
			sign <= 0;
		end		

        if(sign) begin
            a_reg2 <= ~a_reg1 + 1;
        end else begin
            a_reg2 <= a_reg1;
        end

		sign_r1 <= sign;
		sign_r2 <= sign_r1;
		sign_r3 <= sign_r2;
		sign_r4 <= sign_r3;
		sign_r5 <= sign_r4;
		sign_r6 <= sign_r5;
		sign_r7 <= sign_r6;
		valid_r1 <= in_v;
		valid_r2 <= valid_r1;
		valid_r3 <= valid_r2;
		valid_r4 <= valid_r3;
		valid_r5 <= valid_r4;
		valid_r6 <= valid_r5;
		valid_r7 <= valid_r6;
		valid_r8 <= valid_r7;
		valid_r9 <= valid_r8;
		valid_r10 <= valid_r9;
		out_v <= valid_r10;

		sum1_0 <= (ab18 << 18) + ab0;
		sum2_0 <= (ab36[27:0] + ab36_1[27:0]) << 36;
		sum3_0 <= (ab54[9:0] + ab54_1[9:0]) << 54;

		sum_1 <= sum1_0 + sum2_0 + sum3_0;
        
		if(sign_r7) begin
			sum_sign <= ~sum_1 + 1;
		end else begin
			sum_sign <= sum_1;
		end
		p <= sum_sign[63:64-NBITS];
	end

end


	dsp u_18 (
		.ay      (a0),      //   input,  width = 18,      ay.ay
		.by      (a1),      //   input,  width = 18,      by.by
		.ax      (b1),      //   input,  width = 18,      ax.ax
		.bx      (b0),      //   input,  width = 18,      bx.bx
		.resulta (ab18), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);

	dsp u_36 (
		.ay      (a0),      //   input,  width = 18,      ay.ay
		.by      (a2),      //   input,  width = 18,      by.by
		.ax      (b2),      //   input,  width = 18,      ax.ax
		.bx      (b0),      //   input,  width = 18,      bx.bx
		.resulta (ab36), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);

	dsp u_54 (
		.ay      (a0),      //   input,  width = 18,      ay.ay
		.by      (a1),      //   input,  width = 18,      by.by
		.ax      (b3),      //   input,  width = 18,      ax.ax
		.bx      (b2),      //   input,  width = 18,      bx.bx
		.resulta (ab54), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);

	dsp u_54_1 (
		.ay      (a2),      //   input,  width = 18,      ay.ay
		.by      (a3),      //   input,  width = 18,      by.by
		.ax      (b1),      //   input,  width = 18,      ax.ax
		.bx      (b0),      //   input,  width = 18,      bx.bx
		.resulta (ab54_1), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);
	singledsp u_0 (
		.ay      (a0),      //   input,  width = 18,      ay.ay
		.ax      (b0),      //   input,  width = 18,      ax.ax
		.resulta (ab0), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);
	singledsp u_36_1 (
		.ay      (a1),      //   input,  width = 18,      ay.ay
		.ax      (b1),      //   input,  width = 18,      ax.ax
		.resulta (ab36_1), //  output,  width = 37, resulta.resulta
		.clk0    (clk),    //   input,   width = 1,    clk0.clk
		.clk1    (clk),    //   input,   width = 1,    clk1.clk
		.clk2    (clk),    //   input,   width = 1,    clk2.clk
		.ena     (ena)      //   input,   width = 3,     ena.ena
	);

endmodule
