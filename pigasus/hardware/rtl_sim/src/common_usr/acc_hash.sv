// Latency = 6
module acc_hash(clk, p,
           a0b0, a0b1, a0b2, a0b3,
           a1b0, a1b1, a1b2, a1b3,
           a2b0, a2b1, a2b2,
           a3b0, a3b1, a3b2,
           a4b0, a4b1,
           a5b0, a5b1,
           a6b0,
           a7b0);

parameter ANDMSK = 64'hffffffffffffffff;
parameter NBITS = 15;

input clk;
output reg [NBITS-1:0] p;

input [23:0] a0b0;
input [23:0] a0b1;
input [23:0] a0b2;
input [23:0] a0b3;
input [23:0] a1b0;
input [23:0] a1b1;
input [23:0] a1b2;
input [23:0] a1b3;
input [23:0] a2b0;
input [23:0] a2b1;
input [23:0] a2b2;
input [23:0] a3b0;
input [23:0] a3b1;
input [23:0] a3b2;
input [23:0] a4b0;
input [23:0] a4b1;
input [23:0] a5b0;
input [23:0] a5b1;
input [23:0] a6b0;
input [23:0] a7b0;

reg  [23:0] msk_a0b0;
reg  [23:0] msk_a0b1;
reg  [23:0] msk_a0b2;
reg  [23:0] msk_a0b3;
reg  [23:0] msk_a1b0;
reg  [23:0] msk_a1b1;
reg  [23:0] msk_a1b2;
reg  [23:0] msk_a1b3;
reg  [23:0] msk_a2b0;
reg  [23:0] msk_a2b1;
reg  [23:0] msk_a2b2;
reg  [23:0] msk_a3b0;
reg  [23:0] msk_a3b1;
reg  [23:0] msk_a3b2;
reg  [23:0] msk_a4b0;
reg  [23:0] msk_a4b1;
reg  [23:0] msk_a5b0;
reg  [23:0] msk_a5b1;
reg  [23:0] msk_a6b0;
reg  [23:0] msk_a7b0;

reg [32:0] a01_b0;
reg [32:0] a23_b0;
reg [32:0] a45_b0;
reg [32:0] a67_b0;
reg [32:0] a01_b1;
reg [32:0] a23_b1;
reg [32:0] a45_b1;
reg [32:0] a01_b2;
reg [32:0] a23_b2;
reg [32:0] a01_b3;

reg  [33:0] add_a01_b1_a23_b0;
reg  [33:0] add_a01_b2_a45_b0;
reg  [16:0] add_a01_b3_a23_b2;
reg  [16:0] add_a45_b1_a67_b0;
reg  [32:0] a01_b0_reg;
reg  [32:0] a23_b1_reg;

reg  [50:0] sum0_reg;
reg  [34:0] sum1_reg;
reg  [16:0] sum2_reg;

reg  [50:0] half_sum0_reg;
reg  [35:0] half_sum1_reg;

reg  [64:0] sum;

localparam LSB_BYTES_MASKED = (ANDMSK[63:56]==0) ? 8 :
                              (ANDMSK[55:48]==0) ? 7 :
                              (ANDMSK[47:40]==0) ? 6 :
                              (ANDMSK[39:32]==0) ? 5 :
                              (ANDMSK[31:24]==0) ? 4 :
                              (ANDMSK[23:16]==0) ? 3 :
                              (ANDMSK[15: 8]==0) ? 2 :
                              (ANDMSK[7 : 0]==0) ? 1 : 0;

// These parameter muxes are resolved in synthesie.
always @ (*) begin
  msk_a0b0 = (LSB_BYTES_MASKED>=1) ? 24'd0 : a0b0;
  msk_a0b1 = (LSB_BYTES_MASKED>=1) ? 24'd0 : a0b1;
  msk_a0b2 = (LSB_BYTES_MASKED>=1) ? 24'd0 : a0b2;
  msk_a0b3 = (LSB_BYTES_MASKED>=1) ? 24'd0 : a0b3;
  msk_a1b0 = (LSB_BYTES_MASKED>=2) ? 24'd0 : a1b0;
  msk_a1b1 = (LSB_BYTES_MASKED>=2) ? 24'd0 : a1b1;
  msk_a1b2 = (LSB_BYTES_MASKED>=2) ? 24'd0 : a1b2;
  msk_a1b3 = (LSB_BYTES_MASKED>=2) ? 24'd0 : a1b3;
  msk_a2b0 = (LSB_BYTES_MASKED>=3) ? 24'd0 : a2b0;
  msk_a2b1 = (LSB_BYTES_MASKED>=3) ? 24'd0 : a2b1;
  msk_a2b2 = (LSB_BYTES_MASKED>=3) ? 24'd0 : a2b2;
  msk_a3b0 = (LSB_BYTES_MASKED>=4) ? 24'd0 : a3b0;
  msk_a3b1 = (LSB_BYTES_MASKED>=4) ? 24'd0 : a3b1;
  msk_a3b2 = (LSB_BYTES_MASKED>=4) ? 24'd0 : a3b2;
  msk_a4b0 = (LSB_BYTES_MASKED>=5) ? 24'd0 : a4b0;
  msk_a4b1 = (LSB_BYTES_MASKED>=5) ? 24'd0 : a4b1;
  msk_a5b0 = (LSB_BYTES_MASKED>=6) ? 24'd0 : a5b0;
  msk_a5b1 = (LSB_BYTES_MASKED>=6) ? 24'd0 : a5b1;
  msk_a6b0 = (LSB_BYTES_MASKED>=7) ? 24'd0 : a6b0; // Always non-zero
  msk_a7b0 = (LSB_BYTES_MASKED==8) ? 24'd0 : a7b0; // Always non-zero
end

// Addition tree
always @ (posedge clk) begin
  // level 1, mergin as into 16-bit values
  a01_b0 <= msk_a0b0 + {msk_a1b0, 8'd0};
  a23_b0 <= msk_a2b0 + {msk_a3b0, 8'd0};
  a45_b0 <= msk_a4b0 + {msk_a5b0, 8'd0};
  a67_b0 <= msk_a6b0 + {msk_a7b0, 8'd0};
  a01_b1 <= msk_a0b1 + {msk_a1b1, 8'd0};
  a23_b1 <= msk_a2b1 + {msk_a3b1, 8'd0};
  a45_b1 <= msk_a4b1 + {msk_a5b1, 8'd0};
  a01_b2 <= msk_a0b2 + {msk_a1b2, 8'd0};
  a23_b2 <= msk_a2b2 + {msk_a3b2, 8'd0};
  a01_b3 <= msk_a0b3 + {msk_a1b3, 8'd0};

  // Level 2, a01_b3, a23_b2, a45_b1, a67_b0
  // are cut short because of final truncation
  add_a01_b1_a23_b0 <= a01_b1       + a23_b0;
  add_a01_b2_a45_b0 <= a01_b2       + a45_b0;
  add_a01_b3_a23_b2 <= a01_b3[15:0] + a23_b2[15:0];
  add_a45_b1_a67_b0 <= a45_b1[15:0] + a67_b0[15:0];
  a01_b0_reg        <= a01_b0;
  a23_b1_reg        <= a23_b1;

  // Level 3
  sum0_reg <= (add_a01_b1_a23_b0<<16)  + a01_b0_reg;
  sum1_reg <=  add_a01_b2_a45_b0       + a23_b1_reg;
  sum2_reg <=  add_a01_b3_a23_b2[15:0] + add_a45_b1_a67_b0[15:0];

  // Level 4
  half_sum0_reg <= sum0_reg;
  half_sum1_reg <= {sum2_reg[15:0], 16'd0} + sum1_reg;

	// Final Addition
  sum <= half_sum0_reg + {half_sum1_reg[31:0], 32'd0};

  // Output selection
  p <= sum[63:64-NBITS];
end

endmodule
