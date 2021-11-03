`include "./src/struct_s.sv"

module esram_wrapper(
    input   logic           clk_esram_ref, // 100 MHz
    output  logic           esram_pll_lock,
`ifdef USE_BRAM
    input   logic           clk_esram, // 200 MHz
`elsif SIM
    input   logic           clk_esram, // 200 MHz
`else
    output  logic           clk_esram, // 200 MHz
`endif
    input   logic           wren,
    input   logic [16:0]    wraddress,
    input   logic [519:0]   wrdata,
    input   logic           rden,
    input   logic [16:0]    rdaddress,
    output  logic           rd_valid,
    output  logic [519:0]   rddata
);

// In simulation, we just use a big BRAM to accelerate simulation speed.
`ifdef USE_BRAM
localparam DEPTH = (PKT_NUM*32);
localparam AWIDTH = ($clog2(DEPTH));

logic rden_r;
assign esram_pll_lock = 1;

// Two cycles read latency
always @(posedge clk_esram) begin
    rden_r <= rden;
    rd_valid <= rden_r;
end

bram_simple2port #(
    .AWIDTH(AWIDTH),
    .DWIDTH(520),
    .DEPTH(DEPTH)
)
esrm_sim (
    .clock     (clk_esram),
    .data      (wrdata),
    .rdaddress (rdaddress),
    .rden      (rden),
    .wraddress (wraddress),
    .wren      (wren),
    .q         (rddata)
);

`else
logic [71:0] c0_q;          // ram_output.s2c0_qb_0
logic [71:0] c1_q;          //           .s2c1_qb_0
logic [71:0] c2_q;          //           .s2c2_qb_0
logic [71:0] c3_q;          //           .s2c3_qb_0
logic [71:0] c4_q;          //           .s2c4_qb_0
logic [71:0] c5_q;          //           .s2c5_qb_0
logic [71:0] c6_q;          //           .s2c6_qb_0
logic [71:0] c7_q;          //           .s2c7_qb_0
logic [71:0] c0_data;       //  ram_input.s2c0_da_0
logic [16:0] c0_rdaddress;  //           .s2c0_adrb_0
logic        c0_rden_n;     //           .s2c0_meb_n_0
logic        c0_sd_n;       //           .s2c0_sd_n_0
logic [16:0] c0_wraddress;  //           .s2c0_adra_0
logic        c0_wren_n;     //           .s2c0_mea_n_0
logic [71:0] c1_data;       //           .s2c1_da_0
logic [16:0] c1_rdaddress;  //           .s2c1_adrb_0
logic        c1_rden_n;     //           .s2c1_meb_n_0
logic        c1_sd_n;       //           .s2c1_sd_n_0
logic [16:0] c1_wraddress;  //           .s2c1_adra_0
logic        c1_wren_n;     //           .s2c1_mea_n_0
logic [71:0] c2_data;       //           .s2c2_da_0
logic [16:0] c2_rdaddress;  //           .s2c2_adrb_0
logic        c2_rden_n;     //           .s2c2_meb_n_0
logic        c2_sd_n;       //           .s2c2_sd_n_0
logic [16:0] c2_wraddress;  //           .s2c2_adra_0
logic        c2_wren_n;     //           .s2c2_mea_n_0
logic [71:0] c3_data;       //           .s2c3_da_0
logic [16:0] c3_rdaddress;  //           .s2c3_adrb_0
logic        c3_rden_n;     //           .s2c3_meb_n_0
logic        c3_sd_n;       //           .s2c3_sd_n_0
logic [16:0] c3_wraddress;  //           .s2c3_adra_0
logic        c3_wren_n;     //           .s2c3_mea_n_0
logic [71:0] c4_data;       //           .s2c4_da_0
logic [16:0] c4_rdaddress;  //           .s2c4_adrb_0
logic        c4_rden_n;     //           .s2c4_meb_n_0
logic        c4_sd_n;       //           .s2c4_sd_n_0
logic [16:0] c4_wraddress;  //           .s2c4_adra_0
logic        c4_wren_n;     //           .s2c4_mea_n_0
logic [71:0] c5_data;       //           .s2c5_da_0
logic [16:0] c5_rdaddress;  //           .s2c5_adrb_0
logic        c5_rden_n;     //           .s2c5_meb_n_0
logic        c5_sd_n;       //           .s2c5_sd_n_0
logic [16:0] c5_wraddress;  //           .s2c5_adra_0
logic        c5_wren_n;     //           .s2c5_mea_n_0
logic [71:0] c6_data;       //           .s2c6_da_0
logic [16:0] c6_rdaddress;  //           .s2c6_adrb_0
logic        c6_rden_n;     //           .s2c6_meb_n_0
logic        c6_sd_n;       //           .s2c6_sd_n_0
logic [16:0] c6_wraddress;  //           .s2c6_adra_0
logic        c6_wren_n;     //           .s2c6_mea_n_0
logic [71:0] c7_data;       //           .s2c7_da_0
logic [16:0] c7_rdaddress;  //           .s2c7_adrb_0
logic        c7_rden_n;     //           .s2c7_meb_n_0
logic        c7_sd_n;       //           .s2c7_sd_n_0
logic [16:0] c7_wraddress;  //           .s2c7_adra_0
logic        c7_wren_n;     //           .s2c7_mea_n_0
logic        refclk;        //           .clock

logic rden_r1;
logic rden_r2;
logic rden_r3;
logic rden_r4;
logic rden_r5;
logic rden_r6;
logic rden_r7;
logic rden_r8;
logic rden_r9;
logic rden_r10;
logic rden_r11;

// Do not shutdown the channel
assign c0_sd_n = 1;
assign c1_sd_n = 1;
assign c2_sd_n = 1;
assign c3_sd_n = 1;
assign c4_sd_n = 1;
assign c5_sd_n = 1;
assign c6_sd_n = 1;
assign c7_sd_n = 1;

assign c0_rden_n = !rden;
assign c1_rden_n = !rden;
assign c2_rden_n = !rden;
assign c3_rden_n = !rden;
assign c4_rden_n = !rden;
assign c5_rden_n = !rden;
assign c6_rden_n = !rden;
assign c7_rden_n = !rden;

assign c0_wren_n = !wren;
assign c1_wren_n = !wren;
assign c2_wren_n = !wren;
assign c3_wren_n = !wren;
assign c4_wren_n = !wren;
assign c5_wren_n = !wren;
assign c6_wren_n = !wren;
assign c7_wren_n = !wren;

assign c0_rdaddress = rdaddress;
assign c1_rdaddress = rdaddress;
assign c2_rdaddress = rdaddress;
assign c3_rdaddress = rdaddress;
assign c4_rdaddress = rdaddress;
assign c5_rdaddress = rdaddress;
assign c6_rdaddress = rdaddress;
assign c7_rdaddress = rdaddress;

assign c0_wraddress = wraddress;
assign c1_wraddress = wraddress;
assign c2_wraddress = wraddress;
assign c3_wraddress = wraddress;
assign c4_wraddress = wraddress;
assign c5_wraddress = wraddress;
assign c6_wraddress = wraddress;
assign c7_wraddress = wraddress;

assign c0_data = wrdata[71:0];
assign c1_data = wrdata[143:72];
assign c2_data = wrdata[215:144];
assign c3_data = wrdata[287:216];
assign c4_data = wrdata[359:288];
assign c5_data = wrdata[431:360];
assign c6_data = wrdata[503:432];
assign c7_data = {56'b0,wrdata[519:504]};

assign rddata[71:0]    = c0_q;
assign rddata[143:72]  = c1_q;
assign rddata[215:144] = c2_q;
assign rddata[287:216] = c3_q;
assign rddata[359:288] = c4_q;
assign rddata[431:360] = c5_q;
assign rddata[503:432] = c6_q;
assign rddata[519:504] = c7_q;

// Fixed read latency 12 cycles
always @(posedge clk_esram) begin
    if (!esram_pll_lock) begin
        rden_r1  <= 0;
        rden_r2  <= 0;
        rden_r3  <= 0;
        rden_r4  <= 0;
        rden_r5  <= 0;
        rden_r6  <= 0;
        rden_r7  <= 0;
        rden_r8  <= 0;
        rden_r9  <= 0;
        rden_r10 <= 0;
        rden_r11 <= 0;
        rd_valid <= 0;
    end
    else begin
        rden_r1 <= rden;
        rden_r2 <= rden_r1;
        rden_r3 <= rden_r2;
        rden_r4 <= rden_r3;
        rden_r5 <= rden_r4;
        rden_r6 <= rden_r5;
        rden_r7 <= rden_r6;
        rden_r8 <= rden_r7;
        rden_r9 <= rden_r8;
        rden_r10 <= rden_r9;
        rden_r11 <= rden_r10;
        rd_valid <= rden_r11;
    end
end

esram esram_0 (
    .c0_q_0          (c0_q),          //  output,  width = 72, ram_output.s2c0_qb_0
    .c1_q_0          (c1_q),          //  output,  width = 72,           .s2c1_qb_0
    .c2_q_0          (c2_q),          //  output,  width = 72,           .s2c2_qb_0
    .c3_q_0          (c3_q),          //  output,  width = 72,           .s2c3_qb_0
    .c4_q_0          (c4_q),          //  output,  width = 72,           .s2c4_qb_0
    .c5_q_0          (c5_q),          //  output,  width = 72,           .s2c5_qb_0
    .c6_q_0          (c6_q),          //  output,  width = 72,           .s2c6_qb_0
    .c7_q_0          (c7_q),          //  output,  width = 72,           .s2c7_qb_0
    .esram2f_clk     (clk_esram),     //  output,   width = 1,           .esram2f_clk
    .iopll_lock2core (esram_pll_lock), //  output,   width = 1,           .iopll_lock2core
    .c0_data_0       (c0_data),       //   input,  width = 72,  ram_input.s2c0_da_0
    .c0_rdaddress_0  (c0_rdaddress),  //   input,  width = 11,           .s2c0_adrb_0
    .c0_rden_n_0     (c0_rden_n),     //   input,   width = 1,           .s2c0_meb_n_0
    .c0_sd_n_0       (c0_sd_n),       //   input,   width = 1,           .s2c0_sd_n_0
    .c0_wraddress_0  (c0_wraddress),  //   input,  width = 11,           .s2c0_adra_0
    .c0_wren_n_0     (c0_wren_n),     //   input,   width = 1,           .s2c0_mea_n_0
    .c1_data_0       (c1_data),       //   input,  width = 72,           .s2c1_da_0
    .c1_rdaddress_0  (c1_rdaddress),  //   input,  width = 11,           .s2c1_adrb_0
    .c1_rden_n_0     (c1_rden_n),     //   input,   width = 1,           .s2c1_meb_n_0
    .c1_sd_n_0       (c1_sd_n),       //   input,   width = 1,           .s2c1_sd_n_0
    .c1_wraddress_0  (c1_wraddress),  //   input,  width = 11,           .s2c1_adra_0
    .c1_wren_n_0     (c1_wren_n),     //   input,   width = 1,           .s2c1_mea_n_0
    .c2_data_0       (c2_data),       //   input,  width = 72,           .s2c2_da_0
    .c2_rdaddress_0  (c2_rdaddress),  //   input,  width = 11,           .s2c2_adrb_0
    .c2_rden_n_0     (c2_rden_n),     //   input,   width = 1,           .s2c2_meb_n_0
    .c2_sd_n_0       (c2_sd_n),       //   input,   width = 1,           .s2c2_sd_n_0
    .c2_wraddress_0  (c2_wraddress),  //   input,  width = 11,           .s2c2_adra_0
    .c2_wren_n_0     (c2_wren_n),     //   input,   width = 1,           .s2c2_mea_n_0
    .c3_data_0       (c3_data),       //   input,  width = 72,           .s2c3_da_0
    .c3_rdaddress_0  (c3_rdaddress),  //   input,  width = 11,           .s2c3_adrb_0
    .c3_rden_n_0     (c3_rden_n),     //   input,   width = 1,           .s2c3_meb_n_0
    .c3_sd_n_0       (c3_sd_n),       //   input,   width = 1,           .s2c3_sd_n_0
    .c3_wraddress_0  (c3_wraddress),  //   input,  width = 11,           .s2c3_adra_0
    .c3_wren_n_0     (c3_wren_n),     //   input,   width = 1,           .s2c3_mea_n_0
    .c4_data_0       (c4_data),       //   input,  width = 72,           .s2c4_da_0
    .c4_rdaddress_0  (c4_rdaddress),  //   input,  width = 11,           .s2c4_adrb_0
    .c4_rden_n_0     (c4_rden_n),     //   input,   width = 1,           .s2c4_meb_n_0
    .c4_sd_n_0       (c4_sd_n),       //   input,   width = 1,           .s2c4_sd_n_0
    .c4_wraddress_0  (c4_wraddress),  //   input,  width = 11,           .s2c4_adra_0
    .c4_wren_n_0     (c4_wren_n),     //   input,   width = 1,           .s2c4_mea_n_0
    .c5_data_0       (c5_data),       //   input,  width = 72,           .s2c5_da_0
    .c5_rdaddress_0  (c5_rdaddress),  //   input,  width = 11,           .s2c5_adrb_0
    .c5_rden_n_0     (c5_rden_n),     //   input,   width = 1,           .s2c5_meb_n_0
    .c5_sd_n_0       (c5_sd_n),       //   input,   width = 1,           .s2c5_sd_n_0
    .c5_wraddress_0  (c5_wraddress),  //   input,  width = 11,           .s2c5_adra_0
    .c5_wren_n_0     (c5_wren_n),     //   input,   width = 1,           .s2c5_mea_n_0
    .c6_data_0       (c6_data),       //   input,  width = 72,           .s2c6_da_0
    .c6_rdaddress_0  (c6_rdaddress),  //   input,  width = 11,           .s2c6_adrb_0
    .c6_rden_n_0     (c6_rden_n),     //   input,   width = 1,           .s2c6_meb_n_0
    .c6_sd_n_0       (c6_sd_n),       //   input,   width = 1,           .s2c6_sd_n_0
    .c6_wraddress_0  (c6_wraddress),  //   input,  width = 11,           .s2c6_adra_0
    .c6_wren_n_0     (c6_wren_n),     //   input,   width = 1,           .s2c6_mea_n_0
    .c7_data_0       (c7_data),       //   input,  width = 72,           .s2c7_da_0
    .c7_rdaddress_0  (c7_rdaddress),  //   input,  width = 11,           .s2c7_adrb_0
    .c7_rden_n_0     (c7_rden_n),     //   input,   width = 1,           .s2c7_meb_n_0
    .c7_sd_n_0       (c7_sd_n),       //   input,   width = 1,           .s2c7_sd_n_0
    .c7_wraddress_0  (c7_wraddress),  //   input,  width = 11,           .s2c7_adra_0
    .c7_wren_n_0     (c7_wren_n),     //   input,   width = 1,           .s2c7_mea_n_0
    .refclk          (clk_esram_ref)  //   input,   width = 1,           .clock
);
`endif
endmodule
