// Latency = 6
// Since multiplies are 8-bitx16-bit and half of bits in b
// are zero, synthesizer should use LUTs instead of DSPs
module mul_hash(clk, a, ab0, ab1, ab2, ab3);

input clk;
input[7:0] a;

// 4 terms of multiply
output reg [23:0] ab0;
output reg [23:0] ab1;
output reg [23:0] ab2;
output reg [23:0] ab3;

wire [63:0] b = 64'h0b4e0ef37bc32127;

reg [7:0] a_reg0;
reg [7:0] a_reg1;
reg [7:0] a_reg2;

wire [15:0] b0  = b[15: 0];
wire [15:0] b1  = b[31:16];
wire [15:0] b2  = b[47:32];
wire [15:0] b3  = b[63:48];
  
reg [23:0] ab0_reg0;
reg [23:0] ab1_reg0;
reg [23:0] ab2_reg0;
reg [23:0] ab3_reg0;

reg [23:0] ab0_reg1;
reg [23:0] ab1_reg1;
reg [23:0] ab2_reg1;
reg [23:0] ab3_reg1;

// Register inputs and outputs
always @ (posedge clk) begin
  a_reg0      <= a;
  a_reg1      <= a_reg0;
  a_reg2      <= a_reg1;

  ab0_reg0 <= a_reg2 * b0;
  ab1_reg0 <= a_reg2 * b1;
  ab2_reg0 <= a_reg2 * b2;
  ab3_reg0 <= a_reg2 * b3;

  ab0_reg1 <= ab0_reg0;
  ab1_reg1 <= ab1_reg0;
  ab2_reg1 <= ab2_reg0;
  ab3_reg1 <= ab3_reg0;

  ab0 <= ab0_reg1;
  ab1 <= ab1_reg1;
  ab2 <= ab2_reg1;
  ab3 <= ab3_reg1;
end

endmodule
