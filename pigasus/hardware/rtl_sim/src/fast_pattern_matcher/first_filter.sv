`include "./src/struct_s.sv"
module first_filter(
    input                        clk,
    input                        rst,
    input [FP_DWIDTH-1:0]        in_data,
    input                        in_valid,
    input                        in_sop,
    input                        in_eop,
    input [FP_EWIDTH-1:0]        in_empty,
    output logic [FP_DWIDTH-1:0] out_data,
    output logic                 out_valid
);


logic [12:0] addr0;
logic [63:0] q0;
logic [127:0] temp_st0;
logic [12:0] addr1;
logic [63:0] q1;
logic [127:0] temp_st1;
logic [12:0] addr2;
logic [63:0] q2;
logic [127:0] temp_st2;
logic [12:0] addr3;
logic [63:0] q3;
logic [127:0] temp_st3;
logic [12:0] addr4;
logic [63:0] q4;
logic [127:0] temp_st4;
logic [12:0] addr5;
logic [63:0] q5;
logic [127:0] temp_st5;
logic [12:0] addr6;
logic [63:0] q6;
logic [127:0] temp_st6;
logic [12:0] addr7;
logic [63:0] q7;
logic [127:0] temp_st7;
logic [12:0] addr8;
logic [63:0] q8;
logic [127:0] temp_st8;
logic [12:0] addr9;
logic [63:0] q9;
logic [127:0] temp_st9;
logic [12:0] addr10;
logic [63:0] q10;
logic [127:0] temp_st10;
logic [12:0] addr11;
logic [63:0] q11;
logic [127:0] temp_st11;
logic [12:0] addr12;
logic [63:0] q12;
logic [127:0] temp_st12;
logic [12:0] addr13;
logic [63:0] q13;
logic [127:0] temp_st13;
logic [12:0] addr14;
logic [63:0] q14;
logic [127:0] temp_st14;
logic [12:0] addr15;
logic [63:0] q15;
logic [127:0] temp_st15;
logic [12:0] addr16;
logic [63:0] q16;
logic [127:0] temp_st16;
logic [12:0] addr17;
logic [63:0] q17;
logic [127:0] temp_st17;
logic [12:0] addr18;
logic [63:0] q18;
logic [127:0] temp_st18;
logic [12:0] addr19;
logic [63:0] q19;
logic [127:0] temp_st19;
logic [12:0] addr20;
logic [63:0] q20;
logic [127:0] temp_st20;
logic [12:0] addr21;
logic [63:0] q21;
logic [127:0] temp_st21;
logic [12:0] addr22;
logic [63:0] q22;
logic [127:0] temp_st22;
logic [12:0] addr23;
logic [63:0] q23;
logic [127:0] temp_st23;
logic [12:0] addr24;
logic [63:0] q24;
logic [127:0] temp_st24;
logic [12:0] addr25;
logic [63:0] q25;
logic [127:0] temp_st25;
logic [12:0] addr26;
logic [63:0] q26;
logic [127:0] temp_st26;
logic [12:0] addr27;
logic [63:0] q27;
logic [127:0] temp_st27;
logic [12:0] addr28;
logic [63:0] q28;
logic [127:0] temp_st28;
logic [12:0] addr29;
logic [63:0] q29;
logic [127:0] temp_st29;
logic [12:0] addr30;
logic [63:0] q30;
logic [127:0] temp_st30;
logic [12:0] addr31;
logic [63:0] q31;
logic [127:0] temp_st31;

logic [FP_DWIDTH-1:0] in_reg;
logic [63:0] state;
logic [63:0] next_state;
logic in_valid_reg;
logic in_valid_reg_1;

logic [127:0] shiftor0;
logic [127:0] shiftor_state_0;
logic [127:0] shiftor1;
logic [127:0] shiftor_state_1;
logic [127:0] shiftor2;
logic [127:0] shiftor_state_2;
logic [127:0] shiftor3;
logic [127:0] shiftor_state_3;

logic new_pkt;
logic new_pkt_reg;
logic state_valid;
logic last;
logic last_r;
logic last_r1;
logic [FP_DWIDTH-1:0] mask;
logic [8:0] shift;

assign addr0 = in_reg[0*8+12:0*8];
assign addr1 = in_reg[1*8+12:1*8];
assign addr2 = in_reg[2*8+12:2*8];
assign addr3 = in_reg[3*8+12:3*8];
assign addr4 = in_reg[4*8+12:4*8];
assign addr5 = in_reg[5*8+12:5*8];
assign addr6 = in_reg[6*8+12:6*8];
assign addr7 = in_reg[7*8+12:7*8];
assign addr8 = in_reg[8*8+12:8*8];
assign addr9 = in_reg[9*8+12:9*8];
assign addr10 = in_reg[10*8+12:10*8];
assign addr11 = in_reg[11*8+12:11*8];
assign addr12 = in_reg[12*8+12:12*8];
assign addr13 = in_reg[13*8+12:13*8];
assign addr14 = in_reg[14*8+12:14*8];
assign addr15 = in_reg[15*8+12:15*8];
assign addr16 = in_reg[16*8+12:16*8];
assign addr17 = in_reg[17*8+12:17*8];
assign addr18 = in_reg[18*8+12:18*8];
assign addr19 = in_reg[19*8+12:19*8];
assign addr20 = in_reg[20*8+12:20*8];
assign addr21 = in_reg[21*8+12:21*8];
assign addr22 = in_reg[22*8+12:22*8];
assign addr23 = in_reg[23*8+12:23*8];
assign addr24 = in_reg[24*8+12:24*8];
assign addr25 = in_reg[25*8+12:25*8];
assign addr26 = in_reg[26*8+12:26*8];
assign addr27 = in_reg[27*8+12:27*8];
assign addr28 = in_reg[28*8+12:28*8];
assign addr29 = in_reg[29*8+12:29*8];
assign addr30 = in_reg[30*8+12:30*8];
assign addr31 = last ? {5'b0,in_reg[(31+1)*8-1:31*8]} : {in_data[4:0],in_reg[(31+1)*8-1:31*8]};

assign temp_st0 = q0 << 0*8;
assign temp_st1 = q1 << 1*8;
assign temp_st2 = q2 << 2*8;
assign temp_st3 = q3 << 3*8;
assign temp_st4 = q4 << 4*8;
assign temp_st5 = q5 << 5*8;
assign temp_st6 = q6 << 6*8;
assign temp_st7 = q7 << 7*8;
assign temp_st8 = q8 << 0*8;
assign temp_st9 = q9 << 1*8;
assign temp_st10 = q10 << 2*8;
assign temp_st11 = q11 << 3*8;
assign temp_st12 = q12 << 4*8;
assign temp_st13 = q13 << 5*8;
assign temp_st14 = q14 << 6*8;
assign temp_st15 = q15 << 7*8;
assign temp_st16 = q16 << 0*8;
assign temp_st17 = q17 << 1*8;
assign temp_st18 = q18 << 2*8;
assign temp_st19 = q19 << 3*8;
assign temp_st20 = q20 << 4*8;
assign temp_st21 = q21 << 5*8;
assign temp_st22 = q22 << 6*8;
assign temp_st23 = q23 << 7*8;
assign temp_st24 = q24 << 0*8;
assign temp_st25 = q25 << 1*8;
assign temp_st26 = q26 << 2*8;
assign temp_st27 = q27 << 3*8;
assign temp_st28 = q28 << 4*8;
assign temp_st29 = q29 << 5*8;
assign temp_st30 = q30 << 6*8;
assign temp_st31 = q31 << 7*8;


assign shiftor0 =  temp_st0 | temp_st1 | temp_st2 | temp_st3 | temp_st4 | temp_st5 | temp_st6 | temp_st7 | 0;
assign shiftor1 =  temp_st8 | temp_st9 | temp_st10 | temp_st11 | temp_st12 | temp_st13 | temp_st14 | temp_st15 | 0;
assign shiftor2 =  temp_st16 | temp_st17 | temp_st18 | temp_st19 | temp_st20 | temp_st21 | temp_st22 | temp_st23 | 0;
assign shiftor3 =  temp_st24 | temp_st25 | temp_st26 | temp_st27 | temp_st28 | temp_st29 | temp_st30 | temp_st31 | 0;

assign shiftor_state_0 = shiftor0 | state;
assign shiftor_state_1 = shiftor1 | shiftor_state_0[127:64];
assign shiftor_state_2 = shiftor2 | shiftor_state_1[127:64];
assign shiftor_state_3 = shiftor3 | shiftor_state_2[127:64];

//assign out_data = {state_high2[63:0],state_high1[63:0],state_high[63:0],state_low[63:0]} | mask;
assign out_data[64*0+63:64*0] = shiftor_state_0[63:0] | mask[64*0+63:64*0];
//assign out_data = {state_high2[63:0],state_high1[63:0],state_high[63:0],state_low[63:0]} | mask;
assign out_data[64*1+63:64*1] = shiftor_state_1[63:0] | mask[64*1+63:64*1];
//assign out_data = {state_high2[63:0],state_high1[63:0],state_high[63:0],state_low[63:0]} | mask;
assign out_data[64*2+63:64*2] = shiftor_state_2[63:0] | mask[64*2+63:64*2];
//assign out_data = {state_high2[63:0],state_high1[63:0],state_high[63:0],state_low[63:0]} | mask;
assign out_data[64*3+63:64*3] = shiftor_state_3[63:0] | mask[64*3+63:64*3];

assign next_state = shiftor_state_3[127:64];
//assign next_state = shiftor_state_3[127:64];


always @ (posedge clk) begin
    shift   <= (32-in_empty)*8;
    last    <= in_valid & in_eop;
    last_r  <= last;
    last_r1 <= last_r;

    if(last_r)begin
        mask <= {FP_DWIDTH-1{1'b1}} << shift;
    end else begin
        mask <= 0;
    end
end

always @ (posedge clk) begin
    in_valid_reg   <= in_valid;
    in_valid_reg_1 <= in_valid_reg;
    out_valid      <= in_valid_reg_1;

    // state update
    if (out_valid)begin
        if (last_r1) begin
            state <= 64'h0003070f1f3f7fff;
        end else begin
            state <= next_state;
        end
    end

    if (in_valid) begin
        in_reg <= in_data;
    end

    if (rst) begin
        state <= 64'h0003070f1f3f7fff;
    end
end

rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_0 (
	.q_a       (q0),    
	.q_b       (q1),    
	.address_a (addr0),
	.address_b (addr1),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_1 (
	.q_a       (q2),    
	.q_b       (q3),    
	.address_a (addr2),
	.address_b (addr3),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_2 (
	.q_a       (q4),    
	.q_b       (q5),    
	.address_a (addr4),
	.address_b (addr5),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_3 (
	.q_a       (q6),    
	.q_b       (q7),    
	.address_a (addr6),
	.address_b (addr7),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_4 (
	.q_a       (q8),    
	.q_b       (q9),    
	.address_a (addr8),
	.address_b (addr9),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_5 (
	.q_a       (q10),    
	.q_b       (q11),    
	.address_a (addr10),
	.address_b (addr11),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_6 (
	.q_a       (q12),    
	.q_b       (q13),    
	.address_a (addr12),
	.address_b (addr13),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_7 (
	.q_a       (q14),    
	.q_b       (q15),    
	.address_a (addr14),
	.address_b (addr15),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_8 (
	.q_a       (q16),    
	.q_b       (q17),    
	.address_a (addr16),
	.address_b (addr17),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_9 (
	.q_a       (q18),    
	.q_b       (q19),    
	.address_a (addr18),
	.address_b (addr19),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_10 (
	.q_a       (q20),    
	.q_b       (q21),    
	.address_a (addr20),
	.address_b (addr21),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_11 (
	.q_a       (q22),    
	.q_b       (q23),    
	.address_a (addr22),
	.address_b (addr23),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_12 (
	.q_a       (q24),    
	.q_b       (q25),    
	.address_a (addr24),
	.address_b (addr25),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_13 (
	.q_a       (q26),    
	.q_b       (q27),    
	.address_a (addr26),
	.address_b (addr27),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_14 (
	.q_a       (q28),    
	.q_b       (q29),    
	.address_a (addr28),
	.address_b (addr29),
	.clock     (clk)   
);
rom_2port #(
	.DWIDTH(64),
	.AWIDTH(13),
	.MEM_SIZE(8192),
	.INIT_FILE("./src/memory_init/match_table.mif")
)
match_table_15 (
	.q_a       (q30),    
	.q_b       (q31),    
	.address_a (addr30),
	.address_b (addr31),
	.clock     (clk)   
);

endmodule