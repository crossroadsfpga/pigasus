`include "./src/struct_s.sv"
module non_fast_pattern_ht(clk,
    dout_0_0,dout_valid_0_0,
    dout_0_1,dout_valid_0_1,
    dout_0_2,dout_valid_0_2,
    dout_0_3,dout_valid_0_3,
    dout_0_4,dout_valid_0_4,
    dout_0_5,dout_valid_0_5,
    dout_0_6,dout_valid_0_6,
    dout_0_7,dout_valid_0_7,
    dout_0_8,dout_valid_0_8,
    dout_0_9,dout_valid_0_9,
    dout_0_10,dout_valid_0_10,
    dout_0_11,dout_valid_0_11,
    dout_0_12,dout_valid_0_12,
    dout_0_13,dout_valid_0_13,
    dout_0_14,dout_valid_0_14,
    dout_0_15,dout_valid_0_15,
    dout_1_0,dout_valid_1_0,
    dout_1_1,dout_valid_1_1,
    dout_1_2,dout_valid_1_2,
    dout_1_3,dout_valid_1_3,
    dout_1_4,dout_valid_1_4,
    dout_1_5,dout_valid_1_5,
    dout_1_6,dout_valid_1_6,
    dout_1_7,dout_valid_1_7,
    dout_1_8,dout_valid_1_8,
    dout_1_9,dout_valid_1_9,
    dout_1_10,dout_valid_1_10,
    dout_1_11,dout_valid_1_11,
    dout_1_12,dout_valid_1_12,
    dout_1_13,dout_valid_1_13,
    dout_1_14,dout_valid_1_14,
    dout_1_15,dout_valid_1_15,
    dout_2_0,dout_valid_2_0,
    dout_2_1,dout_valid_2_1,
    dout_2_2,dout_valid_2_2,
    dout_2_3,dout_valid_2_3,
    dout_2_4,dout_valid_2_4,
    dout_2_5,dout_valid_2_5,
    dout_2_6,dout_valid_2_6,
    dout_2_7,dout_valid_2_7,
    dout_2_8,dout_valid_2_8,
    dout_2_9,dout_valid_2_9,
    dout_2_10,dout_valid_2_10,
    dout_2_11,dout_valid_2_11,
    dout_2_12,dout_valid_2_12,
    dout_2_13,dout_valid_2_13,
    dout_2_14,dout_valid_2_14,
    dout_2_15,dout_valid_2_15,
    dout_3_0,dout_valid_3_0,
    dout_3_1,dout_valid_3_1,
    dout_3_2,dout_valid_3_2,
    dout_3_3,dout_valid_3_3,
    dout_3_4,dout_valid_3_4,
    dout_3_5,dout_valid_3_5,
    dout_3_6,dout_valid_3_6,
    dout_3_7,dout_valid_3_7,
    dout_3_8,dout_valid_3_8,
    dout_3_9,dout_valid_3_9,
    dout_3_10,dout_valid_3_10,
    dout_3_11,dout_valid_3_11,
    dout_3_12,dout_valid_3_12,
    dout_3_13,dout_valid_3_13,
    dout_3_14,dout_valid_3_14,
    dout_3_15,dout_valid_3_15,
    dout_4_0,dout_valid_4_0,
    dout_4_1,dout_valid_4_1,
    dout_4_2,dout_valid_4_2,
    dout_4_3,dout_valid_4_3,
    dout_4_4,dout_valid_4_4,
    dout_4_5,dout_valid_4_5,
    dout_4_6,dout_valid_4_6,
    dout_4_7,dout_valid_4_7,
    dout_4_8,dout_valid_4_8,
    dout_4_9,dout_valid_4_9,
    dout_4_10,dout_valid_4_10,
    dout_4_11,dout_valid_4_11,
    dout_4_12,dout_valid_4_12,
    dout_4_13,dout_valid_4_13,
    dout_4_14,dout_valid_4_14,
    dout_4_15,dout_valid_4_15,
    dout_5_0,dout_valid_5_0,
    dout_5_1,dout_valid_5_1,
    dout_5_2,dout_valid_5_2,
    dout_5_3,dout_valid_5_3,
    dout_5_4,dout_valid_5_4,
    dout_5_5,dout_valid_5_5,
    dout_5_6,dout_valid_5_6,
    dout_5_7,dout_valid_5_7,
    dout_5_8,dout_valid_5_8,
    dout_5_9,dout_valid_5_9,
    dout_5_10,dout_valid_5_10,
    dout_5_11,dout_valid_5_11,
    dout_5_12,dout_valid_5_12,
    dout_5_13,dout_valid_5_13,
    dout_5_14,dout_valid_5_14,
    dout_5_15,dout_valid_5_15,
    dout_6_0,dout_valid_6_0,
    dout_6_1,dout_valid_6_1,
    dout_6_2,dout_valid_6_2,
    dout_6_3,dout_valid_6_3,
    dout_6_4,dout_valid_6_4,
    dout_6_5,dout_valid_6_5,
    dout_6_6,dout_valid_6_6,
    dout_6_7,dout_valid_6_7,
    dout_6_8,dout_valid_6_8,
    dout_6_9,dout_valid_6_9,
    dout_6_10,dout_valid_6_10,
    dout_6_11,dout_valid_6_11,
    dout_6_12,dout_valid_6_12,
    dout_6_13,dout_valid_6_13,
    dout_6_14,dout_valid_6_14,
    dout_6_15,dout_valid_6_15,
    dout_7_0,dout_valid_7_0,
    dout_7_1,dout_valid_7_1,
    dout_7_2,dout_valid_7_2,
    dout_7_3,dout_valid_7_3,
    dout_7_4,dout_valid_7_4,
    dout_7_5,dout_valid_7_5,
    dout_7_6,dout_valid_7_6,
    dout_7_7,dout_valid_7_7,
    dout_7_8,dout_valid_7_8,
    dout_7_9,dout_valid_7_9,
    dout_7_10,dout_valid_7_10,
    dout_7_11,dout_valid_7_11,
    dout_7_12,dout_valid_7_12,
    dout_7_13,dout_valid_7_13,
    dout_7_14,dout_valid_7_14,
    dout_7_15,dout_valid_7_15,
    din,
    din_sop,
    din_valid
);

input clk;
input [127:0] din;
input din_valid;
input din_sop;
output logic [NF_WIDTH-1:0] dout_0_0;
output logic dout_valid_0_0;
output logic [NF_WIDTH-1:0] dout_0_1;
output logic dout_valid_0_1;
output logic [NF_WIDTH-1:0] dout_0_2;
output logic dout_valid_0_2;
output logic [NF_WIDTH-1:0] dout_0_3;
output logic dout_valid_0_3;
output logic [NF_WIDTH-1:0] dout_0_4;
output logic dout_valid_0_4;
output logic [NF_WIDTH-1:0] dout_0_5;
output logic dout_valid_0_5;
output logic [NF_WIDTH-1:0] dout_0_6;
output logic dout_valid_0_6;
output logic [NF_WIDTH-1:0] dout_0_7;
output logic dout_valid_0_7;
output logic [NF_WIDTH-1:0] dout_0_8;
output logic dout_valid_0_8;
output logic [NF_WIDTH-1:0] dout_0_9;
output logic dout_valid_0_9;
output logic [NF_WIDTH-1:0] dout_0_10;
output logic dout_valid_0_10;
output logic [NF_WIDTH-1:0] dout_0_11;
output logic dout_valid_0_11;
output logic [NF_WIDTH-1:0] dout_0_12;
output logic dout_valid_0_12;
output logic [NF_WIDTH-1:0] dout_0_13;
output logic dout_valid_0_13;
output logic [NF_WIDTH-1:0] dout_0_14;
output logic dout_valid_0_14;
output logic [NF_WIDTH-1:0] dout_0_15;
output logic dout_valid_0_15;
output logic [NF_WIDTH-1:0] dout_1_0;
output logic dout_valid_1_0;
output logic [NF_WIDTH-1:0] dout_1_1;
output logic dout_valid_1_1;
output logic [NF_WIDTH-1:0] dout_1_2;
output logic dout_valid_1_2;
output logic [NF_WIDTH-1:0] dout_1_3;
output logic dout_valid_1_3;
output logic [NF_WIDTH-1:0] dout_1_4;
output logic dout_valid_1_4;
output logic [NF_WIDTH-1:0] dout_1_5;
output logic dout_valid_1_5;
output logic [NF_WIDTH-1:0] dout_1_6;
output logic dout_valid_1_6;
output logic [NF_WIDTH-1:0] dout_1_7;
output logic dout_valid_1_7;
output logic [NF_WIDTH-1:0] dout_1_8;
output logic dout_valid_1_8;
output logic [NF_WIDTH-1:0] dout_1_9;
output logic dout_valid_1_9;
output logic [NF_WIDTH-1:0] dout_1_10;
output logic dout_valid_1_10;
output logic [NF_WIDTH-1:0] dout_1_11;
output logic dout_valid_1_11;
output logic [NF_WIDTH-1:0] dout_1_12;
output logic dout_valid_1_12;
output logic [NF_WIDTH-1:0] dout_1_13;
output logic dout_valid_1_13;
output logic [NF_WIDTH-1:0] dout_1_14;
output logic dout_valid_1_14;
output logic [NF_WIDTH-1:0] dout_1_15;
output logic dout_valid_1_15;
output logic [NF_WIDTH-1:0] dout_2_0;
output logic dout_valid_2_0;
output logic [NF_WIDTH-1:0] dout_2_1;
output logic dout_valid_2_1;
output logic [NF_WIDTH-1:0] dout_2_2;
output logic dout_valid_2_2;
output logic [NF_WIDTH-1:0] dout_2_3;
output logic dout_valid_2_3;
output logic [NF_WIDTH-1:0] dout_2_4;
output logic dout_valid_2_4;
output logic [NF_WIDTH-1:0] dout_2_5;
output logic dout_valid_2_5;
output logic [NF_WIDTH-1:0] dout_2_6;
output logic dout_valid_2_6;
output logic [NF_WIDTH-1:0] dout_2_7;
output logic dout_valid_2_7;
output logic [NF_WIDTH-1:0] dout_2_8;
output logic dout_valid_2_8;
output logic [NF_WIDTH-1:0] dout_2_9;
output logic dout_valid_2_9;
output logic [NF_WIDTH-1:0] dout_2_10;
output logic dout_valid_2_10;
output logic [NF_WIDTH-1:0] dout_2_11;
output logic dout_valid_2_11;
output logic [NF_WIDTH-1:0] dout_2_12;
output logic dout_valid_2_12;
output logic [NF_WIDTH-1:0] dout_2_13;
output logic dout_valid_2_13;
output logic [NF_WIDTH-1:0] dout_2_14;
output logic dout_valid_2_14;
output logic [NF_WIDTH-1:0] dout_2_15;
output logic dout_valid_2_15;
output logic [NF_WIDTH-1:0] dout_3_0;
output logic dout_valid_3_0;
output logic [NF_WIDTH-1:0] dout_3_1;
output logic dout_valid_3_1;
output logic [NF_WIDTH-1:0] dout_3_2;
output logic dout_valid_3_2;
output logic [NF_WIDTH-1:0] dout_3_3;
output logic dout_valid_3_3;
output logic [NF_WIDTH-1:0] dout_3_4;
output logic dout_valid_3_4;
output logic [NF_WIDTH-1:0] dout_3_5;
output logic dout_valid_3_5;
output logic [NF_WIDTH-1:0] dout_3_6;
output logic dout_valid_3_6;
output logic [NF_WIDTH-1:0] dout_3_7;
output logic dout_valid_3_7;
output logic [NF_WIDTH-1:0] dout_3_8;
output logic dout_valid_3_8;
output logic [NF_WIDTH-1:0] dout_3_9;
output logic dout_valid_3_9;
output logic [NF_WIDTH-1:0] dout_3_10;
output logic dout_valid_3_10;
output logic [NF_WIDTH-1:0] dout_3_11;
output logic dout_valid_3_11;
output logic [NF_WIDTH-1:0] dout_3_12;
output logic dout_valid_3_12;
output logic [NF_WIDTH-1:0] dout_3_13;
output logic dout_valid_3_13;
output logic [NF_WIDTH-1:0] dout_3_14;
output logic dout_valid_3_14;
output logic [NF_WIDTH-1:0] dout_3_15;
output logic dout_valid_3_15;
output logic [NF_WIDTH-1:0] dout_4_0;
output logic dout_valid_4_0;
output logic [NF_WIDTH-1:0] dout_4_1;
output logic dout_valid_4_1;
output logic [NF_WIDTH-1:0] dout_4_2;
output logic dout_valid_4_2;
output logic [NF_WIDTH-1:0] dout_4_3;
output logic dout_valid_4_3;
output logic [NF_WIDTH-1:0] dout_4_4;
output logic dout_valid_4_4;
output logic [NF_WIDTH-1:0] dout_4_5;
output logic dout_valid_4_5;
output logic [NF_WIDTH-1:0] dout_4_6;
output logic dout_valid_4_6;
output logic [NF_WIDTH-1:0] dout_4_7;
output logic dout_valid_4_7;
output logic [NF_WIDTH-1:0] dout_4_8;
output logic dout_valid_4_8;
output logic [NF_WIDTH-1:0] dout_4_9;
output logic dout_valid_4_9;
output logic [NF_WIDTH-1:0] dout_4_10;
output logic dout_valid_4_10;
output logic [NF_WIDTH-1:0] dout_4_11;
output logic dout_valid_4_11;
output logic [NF_WIDTH-1:0] dout_4_12;
output logic dout_valid_4_12;
output logic [NF_WIDTH-1:0] dout_4_13;
output logic dout_valid_4_13;
output logic [NF_WIDTH-1:0] dout_4_14;
output logic dout_valid_4_14;
output logic [NF_WIDTH-1:0] dout_4_15;
output logic dout_valid_4_15;
output logic [NF_WIDTH-1:0] dout_5_0;
output logic dout_valid_5_0;
output logic [NF_WIDTH-1:0] dout_5_1;
output logic dout_valid_5_1;
output logic [NF_WIDTH-1:0] dout_5_2;
output logic dout_valid_5_2;
output logic [NF_WIDTH-1:0] dout_5_3;
output logic dout_valid_5_3;
output logic [NF_WIDTH-1:0] dout_5_4;
output logic dout_valid_5_4;
output logic [NF_WIDTH-1:0] dout_5_5;
output logic dout_valid_5_5;
output logic [NF_WIDTH-1:0] dout_5_6;
output logic dout_valid_5_6;
output logic [NF_WIDTH-1:0] dout_5_7;
output logic dout_valid_5_7;
output logic [NF_WIDTH-1:0] dout_5_8;
output logic dout_valid_5_8;
output logic [NF_WIDTH-1:0] dout_5_9;
output logic dout_valid_5_9;
output logic [NF_WIDTH-1:0] dout_5_10;
output logic dout_valid_5_10;
output logic [NF_WIDTH-1:0] dout_5_11;
output logic dout_valid_5_11;
output logic [NF_WIDTH-1:0] dout_5_12;
output logic dout_valid_5_12;
output logic [NF_WIDTH-1:0] dout_5_13;
output logic dout_valid_5_13;
output logic [NF_WIDTH-1:0] dout_5_14;
output logic dout_valid_5_14;
output logic [NF_WIDTH-1:0] dout_5_15;
output logic dout_valid_5_15;
output logic [NF_WIDTH-1:0] dout_6_0;
output logic dout_valid_6_0;
output logic [NF_WIDTH-1:0] dout_6_1;
output logic dout_valid_6_1;
output logic [NF_WIDTH-1:0] dout_6_2;
output logic dout_valid_6_2;
output logic [NF_WIDTH-1:0] dout_6_3;
output logic dout_valid_6_3;
output logic [NF_WIDTH-1:0] dout_6_4;
output logic dout_valid_6_4;
output logic [NF_WIDTH-1:0] dout_6_5;
output logic dout_valid_6_5;
output logic [NF_WIDTH-1:0] dout_6_6;
output logic dout_valid_6_6;
output logic [NF_WIDTH-1:0] dout_6_7;
output logic dout_valid_6_7;
output logic [NF_WIDTH-1:0] dout_6_8;
output logic dout_valid_6_8;
output logic [NF_WIDTH-1:0] dout_6_9;
output logic dout_valid_6_9;
output logic [NF_WIDTH-1:0] dout_6_10;
output logic dout_valid_6_10;
output logic [NF_WIDTH-1:0] dout_6_11;
output logic dout_valid_6_11;
output logic [NF_WIDTH-1:0] dout_6_12;
output logic dout_valid_6_12;
output logic [NF_WIDTH-1:0] dout_6_13;
output logic dout_valid_6_13;
output logic [NF_WIDTH-1:0] dout_6_14;
output logic dout_valid_6_14;
output logic [NF_WIDTH-1:0] dout_6_15;
output logic dout_valid_6_15;
output logic [NF_WIDTH-1:0] dout_7_0;
output logic dout_valid_7_0;
output logic [NF_WIDTH-1:0] dout_7_1;
output logic dout_valid_7_1;
output logic [NF_WIDTH-1:0] dout_7_2;
output logic dout_valid_7_2;
output logic [NF_WIDTH-1:0] dout_7_3;
output logic dout_valid_7_3;
output logic [NF_WIDTH-1:0] dout_7_4;
output logic dout_valid_7_4;
output logic [NF_WIDTH-1:0] dout_7_5;
output logic dout_valid_7_5;
output logic [NF_WIDTH-1:0] dout_7_6;
output logic dout_valid_7_6;
output logic [NF_WIDTH-1:0] dout_7_7;
output logic dout_valid_7_7;
output logic [NF_WIDTH-1:0] dout_7_8;
output logic dout_valid_7_8;
output logic [NF_WIDTH-1:0] dout_7_9;
output logic dout_valid_7_9;
output logic [NF_WIDTH-1:0] dout_7_10;
output logic dout_valid_7_10;
output logic [NF_WIDTH-1:0] dout_7_11;
output logic dout_valid_7_11;
output logic [NF_WIDTH-1:0] dout_7_12;
output logic dout_valid_7_12;
output logic [NF_WIDTH-1:0] dout_7_13;
output logic dout_valid_7_13;
output logic [NF_WIDTH-1:0] dout_7_14;
output logic dout_valid_7_14;
output logic [NF_WIDTH-1:0] dout_7_15;
output logic dout_valid_7_15;

logic [63:0] din_0_0;
logic din_valid_0_0;
logic [63:0] din_0_1;
logic din_valid_0_1;
logic [63:0] din_0_2;
logic din_valid_0_2;
logic [63:0] din_0_3;
logic din_valid_0_3;
logic [63:0] din_0_4;
logic din_valid_0_4;
logic [63:0] din_0_5;
logic din_valid_0_5;
logic [63:0] din_0_6;
logic din_valid_0_6;
logic [63:0] din_0_7;
logic din_valid_0_7;
logic [63:0] din_0_8;
logic din_valid_0_8;
logic [63:0] din_0_9;
logic din_valid_0_9;
logic [63:0] din_0_10;
logic din_valid_0_10;
logic [63:0] din_0_11;
logic din_valid_0_11;
logic [63:0] din_0_12;
logic din_valid_0_12;
logic [63:0] din_0_13;
logic din_valid_0_13;
logic [63:0] din_0_14;
logic din_valid_0_14;
logic [63:0] din_0_15;
logic din_valid_0_15;
logic [63:0] din_1_0;
logic din_valid_1_0;
logic [63:0] din_1_1;
logic din_valid_1_1;
logic [63:0] din_1_2;
logic din_valid_1_2;
logic [63:0] din_1_3;
logic din_valid_1_3;
logic [63:0] din_1_4;
logic din_valid_1_4;
logic [63:0] din_1_5;
logic din_valid_1_5;
logic [63:0] din_1_6;
logic din_valid_1_6;
logic [63:0] din_1_7;
logic din_valid_1_7;
logic [63:0] din_1_8;
logic din_valid_1_8;
logic [63:0] din_1_9;
logic din_valid_1_9;
logic [63:0] din_1_10;
logic din_valid_1_10;
logic [63:0] din_1_11;
logic din_valid_1_11;
logic [63:0] din_1_12;
logic din_valid_1_12;
logic [63:0] din_1_13;
logic din_valid_1_13;
logic [63:0] din_1_14;
logic din_valid_1_14;
logic [63:0] din_1_15;
logic din_valid_1_15;
logic [63:0] din_2_0;
logic din_valid_2_0;
logic [63:0] din_2_1;
logic din_valid_2_1;
logic [63:0] din_2_2;
logic din_valid_2_2;
logic [63:0] din_2_3;
logic din_valid_2_3;
logic [63:0] din_2_4;
logic din_valid_2_4;
logic [63:0] din_2_5;
logic din_valid_2_5;
logic [63:0] din_2_6;
logic din_valid_2_6;
logic [63:0] din_2_7;
logic din_valid_2_7;
logic [63:0] din_2_8;
logic din_valid_2_8;
logic [63:0] din_2_9;
logic din_valid_2_9;
logic [63:0] din_2_10;
logic din_valid_2_10;
logic [63:0] din_2_11;
logic din_valid_2_11;
logic [63:0] din_2_12;
logic din_valid_2_12;
logic [63:0] din_2_13;
logic din_valid_2_13;
logic [63:0] din_2_14;
logic din_valid_2_14;
logic [63:0] din_2_15;
logic din_valid_2_15;
logic [63:0] din_3_0;
logic din_valid_3_0;
logic [63:0] din_3_1;
logic din_valid_3_1;
logic [63:0] din_3_2;
logic din_valid_3_2;
logic [63:0] din_3_3;
logic din_valid_3_3;
logic [63:0] din_3_4;
logic din_valid_3_4;
logic [63:0] din_3_5;
logic din_valid_3_5;
logic [63:0] din_3_6;
logic din_valid_3_6;
logic [63:0] din_3_7;
logic din_valid_3_7;
logic [63:0] din_3_8;
logic din_valid_3_8;
logic [63:0] din_3_9;
logic din_valid_3_9;
logic [63:0] din_3_10;
logic din_valid_3_10;
logic [63:0] din_3_11;
logic din_valid_3_11;
logic [63:0] din_3_12;
logic din_valid_3_12;
logic [63:0] din_3_13;
logic din_valid_3_13;
logic [63:0] din_3_14;
logic din_valid_3_14;
logic [63:0] din_3_15;
logic din_valid_3_15;
logic [63:0] din_4_0;
logic din_valid_4_0;
logic [63:0] din_4_1;
logic din_valid_4_1;
logic [63:0] din_4_2;
logic din_valid_4_2;
logic [63:0] din_4_3;
logic din_valid_4_3;
logic [63:0] din_4_4;
logic din_valid_4_4;
logic [63:0] din_4_5;
logic din_valid_4_5;
logic [63:0] din_4_6;
logic din_valid_4_6;
logic [63:0] din_4_7;
logic din_valid_4_7;
logic [63:0] din_4_8;
logic din_valid_4_8;
logic [63:0] din_4_9;
logic din_valid_4_9;
logic [63:0] din_4_10;
logic din_valid_4_10;
logic [63:0] din_4_11;
logic din_valid_4_11;
logic [63:0] din_4_12;
logic din_valid_4_12;
logic [63:0] din_4_13;
logic din_valid_4_13;
logic [63:0] din_4_14;
logic din_valid_4_14;
logic [63:0] din_4_15;
logic din_valid_4_15;
logic [63:0] din_5_0;
logic din_valid_5_0;
logic [63:0] din_5_1;
logic din_valid_5_1;
logic [63:0] din_5_2;
logic din_valid_5_2;
logic [63:0] din_5_3;
logic din_valid_5_3;
logic [63:0] din_5_4;
logic din_valid_5_4;
logic [63:0] din_5_5;
logic din_valid_5_5;
logic [63:0] din_5_6;
logic din_valid_5_6;
logic [63:0] din_5_7;
logic din_valid_5_7;
logic [63:0] din_5_8;
logic din_valid_5_8;
logic [63:0] din_5_9;
logic din_valid_5_9;
logic [63:0] din_5_10;
logic din_valid_5_10;
logic [63:0] din_5_11;
logic din_valid_5_11;
logic [63:0] din_5_12;
logic din_valid_5_12;
logic [63:0] din_5_13;
logic din_valid_5_13;
logic [63:0] din_5_14;
logic din_valid_5_14;
logic [63:0] din_5_15;
logic din_valid_5_15;
logic [63:0] din_6_0;
logic din_valid_6_0;
logic [63:0] din_6_1;
logic din_valid_6_1;
logic [63:0] din_6_2;
logic din_valid_6_2;
logic [63:0] din_6_3;
logic din_valid_6_3;
logic [63:0] din_6_4;
logic din_valid_6_4;
logic [63:0] din_6_5;
logic din_valid_6_5;
logic [63:0] din_6_6;
logic din_valid_6_6;
logic [63:0] din_6_7;
logic din_valid_6_7;
logic [63:0] din_6_8;
logic din_valid_6_8;
logic [63:0] din_6_9;
logic din_valid_6_9;
logic [63:0] din_6_10;
logic din_valid_6_10;
logic [63:0] din_6_11;
logic din_valid_6_11;
logic [63:0] din_6_12;
logic din_valid_6_12;
logic [63:0] din_6_13;
logic din_valid_6_13;
logic [63:0] din_6_14;
logic din_valid_6_14;
logic [63:0] din_6_15;
logic din_valid_6_15;
logic [63:0] din_7_0;
logic din_valid_7_0;
logic [63:0] din_7_1;
logic din_valid_7_1;
logic [63:0] din_7_2;
logic din_valid_7_2;
logic [63:0] din_7_3;
logic din_valid_7_3;
logic [63:0] din_7_4;
logic din_valid_7_4;
logic [63:0] din_7_5;
logic din_valid_7_5;
logic [63:0] din_7_6;
logic din_valid_7_6;
logic [63:0] din_7_7;
logic din_valid_7_7;
logic [63:0] din_7_8;
logic din_valid_7_8;
logic [63:0] din_7_9;
logic din_valid_7_9;
logic [63:0] din_7_10;
logic din_valid_7_10;
logic [63:0] din_7_11;
logic din_valid_7_11;
logic [63:0] din_7_12;
logic din_valid_7_12;
logic [63:0] din_7_13;
logic din_valid_7_13;
logic [63:0] din_7_14;
logic din_valid_7_14;
logic [63:0] din_7_15;
logic din_valid_7_15;

logic [63:0] din_reg;
logic din_valid_reg;
logic [63:0] dummy_flit;

assign dummy_flit = 64'h0;

assign din_0_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_0_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_0_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_0_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_0_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_0_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_0_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_0_7 = din[63:0];
assign din_0_8 = din[71:8];
assign din_0_9 = din[79:16];
assign din_0_10 = din[87:24];
assign din_0_11 = din[95:32];
assign din_0_12 = din[103:40];
assign din_0_13 = din[111:48];
assign din_0_14 = din[119:56];
assign din_0_15 = din[127:64];
assign din_1_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_1_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_1_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_1_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_1_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_1_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_1_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_1_7 = din[63:0];
assign din_1_8 = din[71:8];
assign din_1_9 = din[79:16];
assign din_1_10 = din[87:24];
assign din_1_11 = din[95:32];
assign din_1_12 = din[103:40];
assign din_1_13 = din[111:48];
assign din_1_14 = din[119:56];
assign din_1_15 = din[127:64];
assign din_2_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_2_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_2_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_2_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_2_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_2_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_2_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_2_7 = din[63:0];
assign din_2_8 = din[71:8];
assign din_2_9 = din[79:16];
assign din_2_10 = din[87:24];
assign din_2_11 = din[95:32];
assign din_2_12 = din[103:40];
assign din_2_13 = din[111:48];
assign din_2_14 = din[119:56];
assign din_2_15 = din[127:64];
assign din_3_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_3_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_3_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_3_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_3_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_3_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_3_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_3_7 = din[63:0];
assign din_3_8 = din[71:8];
assign din_3_9 = din[79:16];
assign din_3_10 = din[87:24];
assign din_3_11 = din[95:32];
assign din_3_12 = din[103:40];
assign din_3_13 = din[111:48];
assign din_3_14 = din[119:56];
assign din_3_15 = din[127:64];
assign din_4_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_4_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_4_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_4_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_4_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_4_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_4_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_4_7 = din[63:0];
assign din_4_8 = din[71:8];
assign din_4_9 = din[79:16];
assign din_4_10 = din[87:24];
assign din_4_11 = din[95:32];
assign din_4_12 = din[103:40];
assign din_4_13 = din[111:48];
assign din_4_14 = din[119:56];
assign din_4_15 = din[127:64];
assign din_5_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_5_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_5_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_5_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_5_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_5_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_5_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_5_7 = din[63:0];
assign din_5_8 = din[71:8];
assign din_5_9 = din[79:16];
assign din_5_10 = din[87:24];
assign din_5_11 = din[95:32];
assign din_5_12 = din[103:40];
assign din_5_13 = din[111:48];
assign din_5_14 = din[119:56];
assign din_5_15 = din[127:64];
assign din_6_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_6_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_6_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_6_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_6_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_6_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_6_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_6_7 = din[63:0];
assign din_6_8 = din[71:8];
assign din_6_9 = din[79:16];
assign din_6_10 = din[87:24];
assign din_6_11 = din[95:32];
assign din_6_12 = din[103:40];
assign din_6_13 = din[111:48];
assign din_6_14 = din[119:56];
assign din_6_15 = din[127:64];
assign din_7_0 = din_sop ? {din[7:0],dummy_flit[63:8]} :
                         {din[7:0],din_reg[63:8]};
assign din_7_1 = din_sop ? {din[15:0],dummy_flit[63:16]} :
                         {din[15:0],din_reg[63:16]};
assign din_7_2 = din_sop ? {din[23:0],dummy_flit[63:24]} :
                         {din[23:0],din_reg[63:24]};
assign din_7_3 = din_sop ? {din[31:0],dummy_flit[63:32]} :
                         {din[31:0],din_reg[63:32]};
assign din_7_4 = din_sop ? {din[39:0],dummy_flit[63:40]} :
                         {din[39:0],din_reg[63:40]};
assign din_7_5 = din_sop ? {din[47:0],dummy_flit[63:48]} :
                         {din[47:0],din_reg[63:48]};
assign din_7_6 = din_sop ? {din[55:0],dummy_flit[63:56]} :
                         {din[55:0],din_reg[63:56]};

assign din_7_7 = din[63:0];
assign din_7_8 = din[71:8];
assign din_7_9 = din[79:16];
assign din_7_10 = din[87:24];
assign din_7_11 = din[95:32];
assign din_7_12 = din[103:40];
assign din_7_13 = din[111:48];
assign din_7_14 = din[119:56];
assign din_7_15 = din[127:64];

//Valid signals
assign din_valid_0_0 = din_valid & din_valid_reg;
assign din_valid_0_1 = din_valid & din_valid_reg;
assign din_valid_0_2 = din_valid & din_valid_reg;
assign din_valid_0_3 = din_valid & din_valid_reg;
assign din_valid_0_4 = din_valid & din_valid_reg;
assign din_valid_0_5 = din_valid & din_valid_reg;
assign din_valid_0_6 = din_valid & din_valid_reg;
assign din_valid_0_7 = din_valid;
assign din_valid_0_8 = din_valid;
assign din_valid_0_9 = din_valid;
assign din_valid_0_10 = din_valid;
assign din_valid_0_11 = din_valid;
assign din_valid_0_12 = din_valid;
assign din_valid_0_13 = din_valid;
assign din_valid_0_14 = din_valid;
assign din_valid_0_15 = din_valid;

assign din_valid_1_0 = din_valid & din_valid_reg;
assign din_valid_1_1 = din_valid & din_valid_reg;
assign din_valid_1_2 = din_valid & din_valid_reg;
assign din_valid_1_3 = din_valid & din_valid_reg;
assign din_valid_1_4 = din_valid & din_valid_reg;
assign din_valid_1_5 = din_valid & din_valid_reg;
assign din_valid_1_6 = din_valid;
assign din_valid_1_7 = din_valid;
assign din_valid_1_8 = din_valid;
assign din_valid_1_9 = din_valid;
assign din_valid_1_10 = din_valid;
assign din_valid_1_11 = din_valid;
assign din_valid_1_12 = din_valid;
assign din_valid_1_13 = din_valid;
assign din_valid_1_14 = din_valid;
assign din_valid_1_15 = din_valid;

assign din_valid_2_0 = din_valid & din_valid_reg;
assign din_valid_2_1 = din_valid & din_valid_reg;
assign din_valid_2_2 = din_valid & din_valid_reg;
assign din_valid_2_3 = din_valid & din_valid_reg;
assign din_valid_2_4 = din_valid & din_valid_reg;
assign din_valid_2_5 = din_valid;
assign din_valid_2_6 = din_valid;
assign din_valid_2_7 = din_valid;
assign din_valid_2_8 = din_valid;
assign din_valid_2_9 = din_valid;
assign din_valid_2_10 = din_valid;
assign din_valid_2_11 = din_valid;
assign din_valid_2_12 = din_valid;
assign din_valid_2_13 = din_valid;
assign din_valid_2_14 = din_valid;
assign din_valid_2_15 = din_valid;

assign din_valid_3_0 = din_valid & din_valid_reg;
assign din_valid_3_1 = din_valid & din_valid_reg;
assign din_valid_3_2 = din_valid & din_valid_reg;
assign din_valid_3_3 = din_valid & din_valid_reg;
assign din_valid_3_4 = din_valid;
assign din_valid_3_5 = din_valid;
assign din_valid_3_6 = din_valid;
assign din_valid_3_7 = din_valid;
assign din_valid_3_8 = din_valid;
assign din_valid_3_9 = din_valid;
assign din_valid_3_10 = din_valid;
assign din_valid_3_11 = din_valid;
assign din_valid_3_12 = din_valid;
assign din_valid_3_13 = din_valid;
assign din_valid_3_14 = din_valid;
assign din_valid_3_15 = din_valid;

assign din_valid_4_0 = din_valid & din_valid_reg;
assign din_valid_4_1 = din_valid & din_valid_reg;
assign din_valid_4_2 = din_valid & din_valid_reg;
assign din_valid_4_3 = din_valid;
assign din_valid_4_4 = din_valid;
assign din_valid_4_5 = din_valid;
assign din_valid_4_6 = din_valid;
assign din_valid_4_7 = din_valid;
assign din_valid_4_8 = din_valid;
assign din_valid_4_9 = din_valid;
assign din_valid_4_10 = din_valid;
assign din_valid_4_11 = din_valid;
assign din_valid_4_12 = din_valid;
assign din_valid_4_13 = din_valid;
assign din_valid_4_14 = din_valid;
assign din_valid_4_15 = din_valid;

assign din_valid_5_0 = din_valid & din_valid_reg;
assign din_valid_5_1 = din_valid & din_valid_reg;
assign din_valid_5_2 = din_valid;
assign din_valid_5_3 = din_valid;
assign din_valid_5_4 = din_valid;
assign din_valid_5_5 = din_valid;
assign din_valid_5_6 = din_valid;
assign din_valid_5_7 = din_valid;
assign din_valid_5_8 = din_valid;
assign din_valid_5_9 = din_valid;
assign din_valid_5_10 = din_valid;
assign din_valid_5_11 = din_valid;
assign din_valid_5_12 = din_valid;
assign din_valid_5_13 = din_valid;
assign din_valid_5_14 = din_valid;
assign din_valid_5_15 = din_valid;

assign din_valid_6_0 = din_valid & din_valid_reg;
assign din_valid_6_1 = din_valid;
assign din_valid_6_2 = din_valid;
assign din_valid_6_3 = din_valid;
assign din_valid_6_4 = din_valid;
assign din_valid_6_5 = din_valid;
assign din_valid_6_6 = din_valid;
assign din_valid_6_7 = din_valid;
assign din_valid_6_8 = din_valid;
assign din_valid_6_9 = din_valid;
assign din_valid_6_10 = din_valid;
assign din_valid_6_11 = din_valid;
assign din_valid_6_12 = din_valid;
assign din_valid_6_13 = din_valid;
assign din_valid_6_14 = din_valid;
assign din_valid_6_15 = din_valid;

assign din_valid_7_0 = din_valid;
assign din_valid_7_1 = din_valid;
assign din_valid_7_2 = din_valid;
assign din_valid_7_3 = din_valid;
assign din_valid_7_4 = din_valid;
assign din_valid_7_5 = din_valid;
assign din_valid_7_6 = din_valid;
assign din_valid_7_7 = din_valid;
assign din_valid_7_8 = din_valid;
assign din_valid_7_9 = din_valid;
assign din_valid_7_10 = din_valid;
assign din_valid_7_11 = din_valid;
assign din_valid_7_12 = din_valid;
assign din_valid_7_13 = din_valid;
assign din_valid_7_14 = din_valid;
assign din_valid_7_15 = din_valid;


always @ (posedge clk) begin
    din_reg <= din[127:64];
    din_valid_reg <= din_valid;
end


hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_0 (
    .clk (clk),
    .din0 (din_0_0),
    .din0_valid (din_valid_0_0),
    .din1 (din_0_1),
    .din1_valid (din_valid_0_1),
    .dout0 (dout_0_0),
    .dout0_valid (dout_valid_0_0),
    .dout1 (dout_0_1),
    .dout1_valid (dout_valid_0_1)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_1 (
    .clk (clk),
    .din0 (din_0_2),
    .din0_valid (din_valid_0_2),
    .din1 (din_0_3),
    .din1_valid (din_valid_0_3),
    .dout0 (dout_0_2),
    .dout0_valid (dout_valid_0_2),
    .dout1 (dout_0_3),
    .dout1_valid (dout_valid_0_3)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_2 (
    .clk (clk),
    .din0 (din_0_4),
    .din0_valid (din_valid_0_4),
    .din1 (din_0_5),
    .din1_valid (din_valid_0_5),
    .dout0 (dout_0_4),
    .dout0_valid (dout_valid_0_4),
    .dout1 (dout_0_5),
    .dout1_valid (dout_valid_0_5)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_3 (
    .clk (clk),
    .din0 (din_0_6),
    .din0_valid (din_valid_0_6),
    .din1 (din_0_7),
    .din1_valid (din_valid_0_7),
    .dout0 (dout_0_6),
    .dout0_valid (dout_valid_0_6),
    .dout1 (dout_0_7),
    .dout1_valid (dout_valid_0_7)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_4 (
    .clk (clk),
    .din0 (din_0_8),
    .din0_valid (din_valid_0_8),
    .din1 (din_0_9),
    .din1_valid (din_valid_0_9),
    .dout0 (dout_0_8),
    .dout0_valid (dout_valid_0_8),
    .dout1 (dout_0_9),
    .dout1_valid (dout_valid_0_9)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_5 (
    .clk (clk),
    .din0 (din_0_10),
    .din0_valid (din_valid_0_10),
    .din1 (din_0_11),
    .din1_valid (din_valid_0_11),
    .dout0 (dout_0_10),
    .dout0_valid (dout_valid_0_10),
    .dout1 (dout_0_11),
    .dout1_valid (dout_valid_0_11)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_6 (
    .clk (clk),
    .din0 (din_0_12),
    .din0_valid (din_valid_0_12),
    .din1 (din_0_13),
    .din1_valid (din_valid_0_13),
    .dout0 (dout_0_12),
    .dout0_valid (dout_valid_0_12),
    .dout1 (dout_0_13),
    .dout1_valid (dout_valid_0_13)
);

hashtable #(
    .ANDMSK(64'hffffffffffffffff),
    .NBITS(16),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(8192),
    .INIT_FILE("./src/memory_init/nf_bitmap0.mif")
)
hashtable_0_7 (
    .clk (clk),
    .din0 (din_0_14),
    .din0_valid (din_valid_0_14),
    .din1 (din_0_15),
    .din1_valid (din_valid_0_15),
    .dout0 (dout_0_14),
    .dout0_valid (dout_valid_0_14),
    .dout1 (dout_0_15),
    .dout1_valid (dout_valid_0_15)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_0 (
    .clk (clk),
    .din0 (din_1_0),
    .din0_valid (din_valid_1_0),
    .din1 (din_1_1),
    .din1_valid (din_valid_1_1),
    .dout0 (dout_1_0),
    .dout0_valid (dout_valid_1_0),
    .dout1 (dout_1_1),
    .dout1_valid (dout_valid_1_1)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_1 (
    .clk (clk),
    .din0 (din_1_2),
    .din0_valid (din_valid_1_2),
    .din1 (din_1_3),
    .din1_valid (din_valid_1_3),
    .dout0 (dout_1_2),
    .dout0_valid (dout_valid_1_2),
    .dout1 (dout_1_3),
    .dout1_valid (dout_valid_1_3)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_2 (
    .clk (clk),
    .din0 (din_1_4),
    .din0_valid (din_valid_1_4),
    .din1 (din_1_5),
    .din1_valid (din_valid_1_5),
    .dout0 (dout_1_4),
    .dout0_valid (dout_valid_1_4),
    .dout1 (dout_1_5),
    .dout1_valid (dout_valid_1_5)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_3 (
    .clk (clk),
    .din0 (din_1_6),
    .din0_valid (din_valid_1_6),
    .din1 (din_1_7),
    .din1_valid (din_valid_1_7),
    .dout0 (dout_1_6),
    .dout0_valid (dout_valid_1_6),
    .dout1 (dout_1_7),
    .dout1_valid (dout_valid_1_7)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_4 (
    .clk (clk),
    .din0 (din_1_8),
    .din0_valid (din_valid_1_8),
    .din1 (din_1_9),
    .din1_valid (din_valid_1_9),
    .dout0 (dout_1_8),
    .dout0_valid (dout_valid_1_8),
    .dout1 (dout_1_9),
    .dout1_valid (dout_valid_1_9)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_5 (
    .clk (clk),
    .din0 (din_1_10),
    .din0_valid (din_valid_1_10),
    .din1 (din_1_11),
    .din1_valid (din_valid_1_11),
    .dout0 (dout_1_10),
    .dout0_valid (dout_valid_1_10),
    .dout1 (dout_1_11),
    .dout1_valid (dout_valid_1_11)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_6 (
    .clk (clk),
    .din0 (din_1_12),
    .din0_valid (din_valid_1_12),
    .din1 (din_1_13),
    .din1_valid (din_valid_1_13),
    .dout0 (dout_1_12),
    .dout0_valid (dout_valid_1_12),
    .dout1 (dout_1_13),
    .dout1_valid (dout_valid_1_13)
);

hashtable #(
    .ANDMSK(64'hffffffffffffff00),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap1.mif")
)
hashtable_1_7 (
    .clk (clk),
    .din0 (din_1_14),
    .din0_valid (din_valid_1_14),
    .din1 (din_1_15),
    .din1_valid (din_valid_1_15),
    .dout0 (dout_1_14),
    .dout0_valid (dout_valid_1_14),
    .dout1 (dout_1_15),
    .dout1_valid (dout_valid_1_15)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_0 (
    .clk (clk),
    .din0 (din_2_0),
    .din0_valid (din_valid_2_0),
    .din1 (din_2_1),
    .din1_valid (din_valid_2_1),
    .dout0 (dout_2_0),
    .dout0_valid (dout_valid_2_0),
    .dout1 (dout_2_1),
    .dout1_valid (dout_valid_2_1)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_1 (
    .clk (clk),
    .din0 (din_2_2),
    .din0_valid (din_valid_2_2),
    .din1 (din_2_3),
    .din1_valid (din_valid_2_3),
    .dout0 (dout_2_2),
    .dout0_valid (dout_valid_2_2),
    .dout1 (dout_2_3),
    .dout1_valid (dout_valid_2_3)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_2 (
    .clk (clk),
    .din0 (din_2_4),
    .din0_valid (din_valid_2_4),
    .din1 (din_2_5),
    .din1_valid (din_valid_2_5),
    .dout0 (dout_2_4),
    .dout0_valid (dout_valid_2_4),
    .dout1 (dout_2_5),
    .dout1_valid (dout_valid_2_5)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_3 (
    .clk (clk),
    .din0 (din_2_6),
    .din0_valid (din_valid_2_6),
    .din1 (din_2_7),
    .din1_valid (din_valid_2_7),
    .dout0 (dout_2_6),
    .dout0_valid (dout_valid_2_6),
    .dout1 (dout_2_7),
    .dout1_valid (dout_valid_2_7)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_4 (
    .clk (clk),
    .din0 (din_2_8),
    .din0_valid (din_valid_2_8),
    .din1 (din_2_9),
    .din1_valid (din_valid_2_9),
    .dout0 (dout_2_8),
    .dout0_valid (dout_valid_2_8),
    .dout1 (dout_2_9),
    .dout1_valid (dout_valid_2_9)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_5 (
    .clk (clk),
    .din0 (din_2_10),
    .din0_valid (din_valid_2_10),
    .din1 (din_2_11),
    .din1_valid (din_valid_2_11),
    .dout0 (dout_2_10),
    .dout0_valid (dout_valid_2_10),
    .dout1 (dout_2_11),
    .dout1_valid (dout_valid_2_11)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_6 (
    .clk (clk),
    .din0 (din_2_12),
    .din0_valid (din_valid_2_12),
    .din1 (din_2_13),
    .din1_valid (din_valid_2_13),
    .dout0 (dout_2_12),
    .dout0_valid (dout_valid_2_12),
    .dout1 (dout_2_13),
    .dout1_valid (dout_valid_2_13)
);

hashtable #(
    .ANDMSK(64'hffffffffffff0000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap2.mif")
)
hashtable_2_7 (
    .clk (clk),
    .din0 (din_2_14),
    .din0_valid (din_valid_2_14),
    .din1 (din_2_15),
    .din1_valid (din_valid_2_15),
    .dout0 (dout_2_14),
    .dout0_valid (dout_valid_2_14),
    .dout1 (dout_2_15),
    .dout1_valid (dout_valid_2_15)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_0 (
    .clk (clk),
    .din0 (din_3_0),
    .din0_valid (din_valid_3_0),
    .din1 (din_3_1),
    .din1_valid (din_valid_3_1),
    .dout0 (dout_3_0),
    .dout0_valid (dout_valid_3_0),
    .dout1 (dout_3_1),
    .dout1_valid (dout_valid_3_1)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_1 (
    .clk (clk),
    .din0 (din_3_2),
    .din0_valid (din_valid_3_2),
    .din1 (din_3_3),
    .din1_valid (din_valid_3_3),
    .dout0 (dout_3_2),
    .dout0_valid (dout_valid_3_2),
    .dout1 (dout_3_3),
    .dout1_valid (dout_valid_3_3)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_2 (
    .clk (clk),
    .din0 (din_3_4),
    .din0_valid (din_valid_3_4),
    .din1 (din_3_5),
    .din1_valid (din_valid_3_5),
    .dout0 (dout_3_4),
    .dout0_valid (dout_valid_3_4),
    .dout1 (dout_3_5),
    .dout1_valid (dout_valid_3_5)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_3 (
    .clk (clk),
    .din0 (din_3_6),
    .din0_valid (din_valid_3_6),
    .din1 (din_3_7),
    .din1_valid (din_valid_3_7),
    .dout0 (dout_3_6),
    .dout0_valid (dout_valid_3_6),
    .dout1 (dout_3_7),
    .dout1_valid (dout_valid_3_7)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_4 (
    .clk (clk),
    .din0 (din_3_8),
    .din0_valid (din_valid_3_8),
    .din1 (din_3_9),
    .din1_valid (din_valid_3_9),
    .dout0 (dout_3_8),
    .dout0_valid (dout_valid_3_8),
    .dout1 (dout_3_9),
    .dout1_valid (dout_valid_3_9)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_5 (
    .clk (clk),
    .din0 (din_3_10),
    .din0_valid (din_valid_3_10),
    .din1 (din_3_11),
    .din1_valid (din_valid_3_11),
    .dout0 (dout_3_10),
    .dout0_valid (dout_valid_3_10),
    .dout1 (dout_3_11),
    .dout1_valid (dout_valid_3_11)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_6 (
    .clk (clk),
    .din0 (din_3_12),
    .din0_valid (din_valid_3_12),
    .din1 (din_3_13),
    .din1_valid (din_valid_3_13),
    .dout0 (dout_3_12),
    .dout0_valid (dout_valid_3_12),
    .dout1 (dout_3_13),
    .dout1_valid (dout_valid_3_13)
);

hashtable #(
    .ANDMSK(64'hffffffffff000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap3.mif")
)
hashtable_3_7 (
    .clk (clk),
    .din0 (din_3_14),
    .din0_valid (din_valid_3_14),
    .din1 (din_3_15),
    .din1_valid (din_valid_3_15),
    .dout0 (dout_3_14),
    .dout0_valid (dout_valid_3_14),
    .dout1 (dout_3_15),
    .dout1_valid (dout_valid_3_15)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_0 (
    .clk (clk),
    .din0 (din_4_0),
    .din0_valid (din_valid_4_0),
    .din1 (din_4_1),
    .din1_valid (din_valid_4_1),
    .dout0 (dout_4_0),
    .dout0_valid (dout_valid_4_0),
    .dout1 (dout_4_1),
    .dout1_valid (dout_valid_4_1)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_1 (
    .clk (clk),
    .din0 (din_4_2),
    .din0_valid (din_valid_4_2),
    .din1 (din_4_3),
    .din1_valid (din_valid_4_3),
    .dout0 (dout_4_2),
    .dout0_valid (dout_valid_4_2),
    .dout1 (dout_4_3),
    .dout1_valid (dout_valid_4_3)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_2 (
    .clk (clk),
    .din0 (din_4_4),
    .din0_valid (din_valid_4_4),
    .din1 (din_4_5),
    .din1_valid (din_valid_4_5),
    .dout0 (dout_4_4),
    .dout0_valid (dout_valid_4_4),
    .dout1 (dout_4_5),
    .dout1_valid (dout_valid_4_5)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_3 (
    .clk (clk),
    .din0 (din_4_6),
    .din0_valid (din_valid_4_6),
    .din1 (din_4_7),
    .din1_valid (din_valid_4_7),
    .dout0 (dout_4_6),
    .dout0_valid (dout_valid_4_6),
    .dout1 (dout_4_7),
    .dout1_valid (dout_valid_4_7)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_4 (
    .clk (clk),
    .din0 (din_4_8),
    .din0_valid (din_valid_4_8),
    .din1 (din_4_9),
    .din1_valid (din_valid_4_9),
    .dout0 (dout_4_8),
    .dout0_valid (dout_valid_4_8),
    .dout1 (dout_4_9),
    .dout1_valid (dout_valid_4_9)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_5 (
    .clk (clk),
    .din0 (din_4_10),
    .din0_valid (din_valid_4_10),
    .din1 (din_4_11),
    .din1_valid (din_valid_4_11),
    .dout0 (dout_4_10),
    .dout0_valid (dout_valid_4_10),
    .dout1 (dout_4_11),
    .dout1_valid (dout_valid_4_11)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_6 (
    .clk (clk),
    .din0 (din_4_12),
    .din0_valid (din_valid_4_12),
    .din1 (din_4_13),
    .din1_valid (din_valid_4_13),
    .dout0 (dout_4_12),
    .dout0_valid (dout_valid_4_12),
    .dout1 (dout_4_13),
    .dout1_valid (dout_valid_4_13)
);

hashtable #(
    .ANDMSK(64'hffffffff00000000),
    .NBITS(13),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(1024),
    .INIT_FILE("./src/memory_init/nf_bitmap4.mif")
)
hashtable_4_7 (
    .clk (clk),
    .din0 (din_4_14),
    .din0_valid (din_valid_4_14),
    .din1 (din_4_15),
    .din1_valid (din_valid_4_15),
    .dout0 (dout_4_14),
    .dout0_valid (dout_valid_4_14),
    .dout1 (dout_4_15),
    .dout1_valid (dout_valid_4_15)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_0 (
    .clk (clk),
    .din0 (din_5_0),
    .din0_valid (din_valid_5_0),
    .din1 (din_5_1),
    .din1_valid (din_valid_5_1),
    .dout0 (dout_5_0),
    .dout0_valid (dout_valid_5_0),
    .dout1 (dout_5_1),
    .dout1_valid (dout_valid_5_1)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_1 (
    .clk (clk),
    .din0 (din_5_2),
    .din0_valid (din_valid_5_2),
    .din1 (din_5_3),
    .din1_valid (din_valid_5_3),
    .dout0 (dout_5_2),
    .dout0_valid (dout_valid_5_2),
    .dout1 (dout_5_3),
    .dout1_valid (dout_valid_5_3)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_2 (
    .clk (clk),
    .din0 (din_5_4),
    .din0_valid (din_valid_5_4),
    .din1 (din_5_5),
    .din1_valid (din_valid_5_5),
    .dout0 (dout_5_4),
    .dout0_valid (dout_valid_5_4),
    .dout1 (dout_5_5),
    .dout1_valid (dout_valid_5_5)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_3 (
    .clk (clk),
    .din0 (din_5_6),
    .din0_valid (din_valid_5_6),
    .din1 (din_5_7),
    .din1_valid (din_valid_5_7),
    .dout0 (dout_5_6),
    .dout0_valid (dout_valid_5_6),
    .dout1 (dout_5_7),
    .dout1_valid (dout_valid_5_7)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_4 (
    .clk (clk),
    .din0 (din_5_8),
    .din0_valid (din_valid_5_8),
    .din1 (din_5_9),
    .din1_valid (din_valid_5_9),
    .dout0 (dout_5_8),
    .dout0_valid (dout_valid_5_8),
    .dout1 (dout_5_9),
    .dout1_valid (dout_valid_5_9)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_5 (
    .clk (clk),
    .din0 (din_5_10),
    .din0_valid (din_valid_5_10),
    .din1 (din_5_11),
    .din1_valid (din_valid_5_11),
    .dout0 (dout_5_10),
    .dout0_valid (dout_valid_5_10),
    .dout1 (dout_5_11),
    .dout1_valid (dout_valid_5_11)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_6 (
    .clk (clk),
    .din0 (din_5_12),
    .din0_valid (din_valid_5_12),
    .din1 (din_5_13),
    .din1_valid (din_valid_5_13),
    .dout0 (dout_5_12),
    .dout0_valid (dout_valid_5_12),
    .dout1 (dout_5_13),
    .dout1_valid (dout_valid_5_13)
);

hashtable #(
    .ANDMSK(64'hffffff0000000000),
    .NBITS(12),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(512),
    .INIT_FILE("./src/memory_init/nf_bitmap5.mif")
)
hashtable_5_7 (
    .clk (clk),
    .din0 (din_5_14),
    .din0_valid (din_valid_5_14),
    .din1 (din_5_15),
    .din1_valid (din_valid_5_15),
    .dout0 (dout_5_14),
    .dout0_valid (dout_valid_5_14),
    .dout1 (dout_5_15),
    .dout1_valid (dout_valid_5_15)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_0 (
    .clk (clk),
    .din0 (din_6_0),
    .din0_valid (din_valid_6_0),
    .din1 (din_6_1),
    .din1_valid (din_valid_6_1),
    .dout0 (dout_6_0),
    .dout0_valid (dout_valid_6_0),
    .dout1 (dout_6_1),
    .dout1_valid (dout_valid_6_1)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_1 (
    .clk (clk),
    .din0 (din_6_2),
    .din0_valid (din_valid_6_2),
    .din1 (din_6_3),
    .din1_valid (din_valid_6_3),
    .dout0 (dout_6_2),
    .dout0_valid (dout_valid_6_2),
    .dout1 (dout_6_3),
    .dout1_valid (dout_valid_6_3)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_2 (
    .clk (clk),
    .din0 (din_6_4),
    .din0_valid (din_valid_6_4),
    .din1 (din_6_5),
    .din1_valid (din_valid_6_5),
    .dout0 (dout_6_4),
    .dout0_valid (dout_valid_6_4),
    .dout1 (dout_6_5),
    .dout1_valid (dout_valid_6_5)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_3 (
    .clk (clk),
    .din0 (din_6_6),
    .din0_valid (din_valid_6_6),
    .din1 (din_6_7),
    .din1_valid (din_valid_6_7),
    .dout0 (dout_6_6),
    .dout0_valid (dout_valid_6_6),
    .dout1 (dout_6_7),
    .dout1_valid (dout_valid_6_7)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_4 (
    .clk (clk),
    .din0 (din_6_8),
    .din0_valid (din_valid_6_8),
    .din1 (din_6_9),
    .din1_valid (din_valid_6_9),
    .dout0 (dout_6_8),
    .dout0_valid (dout_valid_6_8),
    .dout1 (dout_6_9),
    .dout1_valid (dout_valid_6_9)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_5 (
    .clk (clk),
    .din0 (din_6_10),
    .din0_valid (din_valid_6_10),
    .din1 (din_6_11),
    .din1_valid (din_valid_6_11),
    .dout0 (dout_6_10),
    .dout0_valid (dout_valid_6_10),
    .dout1 (dout_6_11),
    .dout1_valid (dout_valid_6_11)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_6 (
    .clk (clk),
    .din0 (din_6_12),
    .din0_valid (din_valid_6_12),
    .din1 (din_6_13),
    .din1_valid (din_valid_6_13),
    .dout0 (dout_6_12),
    .dout0_valid (dout_valid_6_12),
    .dout1 (dout_6_13),
    .dout1_valid (dout_valid_6_13)
);

hashtable #(
    .ANDMSK(64'hffff000000000000),
    .NBITS(11),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(256),
    .INIT_FILE("./src/memory_init/nf_bitmap6.mif")
)
hashtable_6_7 (
    .clk (clk),
    .din0 (din_6_14),
    .din0_valid (din_valid_6_14),
    .din1 (din_6_15),
    .din1_valid (din_valid_6_15),
    .dout0 (dout_6_14),
    .dout0_valid (dout_valid_6_14),
    .dout1 (dout_6_15),
    .dout1_valid (dout_valid_6_15)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_0 (
    .clk (clk),
    .din0 (din_7_0),
    .din0_valid (din_valid_7_0),
    .din1 (din_7_1),
    .din1_valid (din_valid_7_1),
    .dout0 (dout_7_0),
    .dout0_valid (dout_valid_7_0),
    .dout1 (dout_7_1),
    .dout1_valid (dout_valid_7_1)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_1 (
    .clk (clk),
    .din0 (din_7_2),
    .din0_valid (din_valid_7_2),
    .din1 (din_7_3),
    .din1_valid (din_valid_7_3),
    .dout0 (dout_7_2),
    .dout0_valid (dout_valid_7_2),
    .dout1 (dout_7_3),
    .dout1_valid (dout_valid_7_3)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_2 (
    .clk (clk),
    .din0 (din_7_4),
    .din0_valid (din_valid_7_4),
    .din1 (din_7_5),
    .din1_valid (din_valid_7_5),
    .dout0 (dout_7_4),
    .dout0_valid (dout_valid_7_4),
    .dout1 (dout_7_5),
    .dout1_valid (dout_valid_7_5)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_3 (
    .clk (clk),
    .din0 (din_7_6),
    .din0_valid (din_valid_7_6),
    .din1 (din_7_7),
    .din1_valid (din_valid_7_7),
    .dout0 (dout_7_6),
    .dout0_valid (dout_valid_7_6),
    .dout1 (dout_7_7),
    .dout1_valid (dout_valid_7_7)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_4 (
    .clk (clk),
    .din0 (din_7_8),
    .din0_valid (din_valid_7_8),
    .din1 (din_7_9),
    .din1_valid (din_valid_7_9),
    .dout0 (dout_7_8),
    .dout0_valid (dout_valid_7_8),
    .dout1 (dout_7_9),
    .dout1_valid (dout_valid_7_9)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_5 (
    .clk (clk),
    .din0 (din_7_10),
    .din0_valid (din_valid_7_10),
    .din1 (din_7_11),
    .din1_valid (din_valid_7_11),
    .dout0 (dout_7_10),
    .dout0_valid (dout_valid_7_10),
    .dout1 (dout_7_11),
    .dout1_valid (dout_valid_7_11)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_6 (
    .clk (clk),
    .din0 (din_7_12),
    .din0_valid (din_valid_7_12),
    .din1 (din_7_13),
    .din1_valid (din_valid_7_13),
    .dout0 (dout_7_12),
    .dout0_valid (dout_valid_7_12),
    .dout1 (dout_7_13),
    .dout1_valid (dout_valid_7_13)
);

hashtable #(
    .ANDMSK(64'hff00000000000000),
    .NBITS(10),
    .DWIDTH(NF_WIDTH),
    .MEM_SIZE(128),
    .INIT_FILE("./src/memory_init/nf_bitmap7.mif")
)
hashtable_7_7 (
    .clk (clk),
    .din0 (din_7_14),
    .din0_valid (din_valid_7_14),
    .din1 (din_7_15),
    .din1_valid (din_valid_7_15),
    .dout0 (dout_7_14),
    .dout0_valid (dout_valid_7_14),
    .dout1 (dout_7_15),
    .dout1_valid (dout_valid_7_15)
);

endmodule