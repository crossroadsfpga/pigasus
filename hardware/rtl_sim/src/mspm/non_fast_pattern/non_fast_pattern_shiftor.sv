module non_fast_pattern_shiftor (
    input   logic           clk,
    input   logic           rst,
    input   logic           in_sop,
    input   logic           in_eop,
    input   logic           in_valid,
    input   logic [127:0]   in_data,
    input   logic [2:0]     in_empty,
    output  logic           in_ready,
    output  logic           out_valid,
    output  logic [127:0]   out_data
);

localparam AWIDTH = 14;
localparam DEPTH  = (1 << AWIDTH);
localparam PADDING = (AWIDTH-8);
logic [AWIDTH-1:0] addr    [15:0];
logic [63:0]       q       [15:0];
logic [127:0]      temp_st [15:0];
logic [127:0]      temp_low;
logic [127:0]      temp_high;

logic last;
logic last_r;
logic [127:0] mask;
logic [63:0] state;
logic [63:0] next_state;
logic [127:0] state_low;
logic [127:0] state_high;
logic in_valid_reg;
logic [127:0] in_data_reg;
logic [8:0] shift;
// No back pressure
assign in_ready = 1;

//register input
always @ (posedge clk) begin
    last_r <= last;
    in_valid_reg <= in_valid;
    out_valid <= in_valid_reg;

    //state update
    if(in_valid & in_sop)begin
        state <= 64'h000103070f1f3fff;
    end else begin
        if(out_valid)begin
            state <= next_state;
        end
    end
    in_data_reg <= in_data;
end

always @ (posedge clk) begin
    shift <= (16-in_empty)*8;
    last <= in_valid & in_eop;

    if(last)begin
        mask <= {128{1'b1}} << shift;
    end else begin
        mask <= 0;
    end
end


//Lookup match table byte-by-byte
generate
genvar i;
for(i=0;i<15;i=i+1)begin
    assign addr[i] = in_data_reg[8*(i+1)+PADDING-1:8*i];
end
endgenerate
//last one
assign addr[15] = last ? {6'b0,in_data_reg[(15+1)*8-1:8*7]} 
                 : {in_data[PADDING-1:0],in_data_reg[(15+1)*8-1:8*15]};


generate
for(i=0;i<8;i=i+1)begin
    assign temp_st[i] = q[i] << i*8;
end
endgenerate
generate
for(i=0;i<8;i=i+1)begin
    assign temp_st[i+8] = q[i+8] << i*8;
end
endgenerate

assign temp_low  = temp_st[0]|temp_st[1]|temp_st[2]|temp_st[3]
                  |temp_st[4]|temp_st[5]|temp_st[6]|temp_st[7];
assign temp_high = temp_st[8]|temp_st[9]|temp_st[10]|temp_st[11]
                  |temp_st[12]|temp_st[13]|temp_st[14]|temp_st[15];

assign state_low = temp_low | state;
assign state_high = temp_high | temp_low[127:64];

assign out_data = {state_high[63:0],state_low[63:0]} | mask;
assign next_state = state_high[127:64];

generate
for(i=0;i<8;i=i+1)begin
rom_2port_noreg #(
    .DWIDTH(64),
    .AWIDTH(AWIDTH),
    .MEM_SIZE(DEPTH),
    .INIT_FILE("./src/memory_init/shift_or.mif")
)
match_table (
    .q_a       (q[2*i]),    
    .q_b       (q[2*i+1]),    
    .address_a (addr[2*i]),
    .address_b (addr[2*i+1]),
    .clock     (clk)   
);
end
endgenerate


endmodule
