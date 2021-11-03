`include "./src/struct_s.sv"
module nf_fp_matcher(
    input                 clk,
    input                 rst,
    input logic [16*2-1:0] in_rule_data,
    input logic           in_rule_valid,
    input logic           in_rule_sop,
    input logic           in_rule_eop,
    output logic          in_rule_ready,
    input [FP_WIDTH-1:0]  fp_data,
    input                 fp_valid,     
    output logic          fp_ready,      
    output logic [511:0]  fp_rule_data,  
    output logic          fp_rule_valid, 
    output logic          fp_rule_sop,   
    output logic          fp_rule_eop,   
    output logic [5:0]    fp_rule_empty, 
    input                 fp_rule_ready 
);
typedef enum {
    IDLE,
    RULE
} state_t;
state_t state;

logic rd;
logic rd_r1;
logic rd_r2;
logic last;
logic last_r1;
logic last_r2;
logic [FP_WIDTH-1:0] fp_data_r;
logic [FP_WIDTH-1:0] fp_data_r1;
logic [FP_WIDTH-1:0] fp_data_r2;
logic [16*2-1:0] in_rule_data_r;
logic [16*2-1:0] in_rule_data_r1;
logic [16*2-1:0] in_rule_data_r2;

logic [16*2-1:0] int_fp_rule_data;
logic        int_fp_rule_valid;
logic        int_fp_rule_sop;
logic        int_fp_rule_eop;
logic        int_fp_rule_ready;
logic [31:0] int_fp_rule_csr_readdata;
logic        int_fp_rule_almost_full;
logic [15:0] int_fp_rule_cnt;

logic [16*2-1:0] rulepacker_in_data;
logic        rulepacker_in_valid;
logic        rulepacker_in_sop;
logic        rulepacker_in_eop;
logic        rulepacker_in_ready;
logic [31:0] rulepacker_in_csr_readdata;
logic        rulepacker_in_almost_full;

logic [511:0] rulepacker_out_data;
logic         rulepacker_out_valid;
logic         rulepacker_out_sop;
logic         rulepacker_out_eop;
logic [5:0]   rulepacker_out_empty;
logic         rulepacker_out_ready;

logic [FP_WIDTH-1:0]    fp_0;
logic [RULE_AWIDTH-1:0] fp_addr_0;
logic [FP_WIDTH-1:0]    fp_1;
logic [RULE_AWIDTH-1:0] fp_addr_1;

//deq finger_print when all the rules for that packets are dequeued
assign fp_ready = !int_fp_rule_almost_full & in_rule_valid & in_rule_eop;

//deq a rule when there is finger_print
assign in_rule_ready = !int_fp_rule_almost_full & fp_valid;

always@(posedge clk)begin
    if(rst)begin
        rd <= 1'b0;
        last <= 1'b0;
    end else begin
        rd <= 1'b0;
        last <= 1'b0;
        if(fp_valid & !int_fp_rule_almost_full & in_rule_valid)begin
            if(in_rule_eop)begin
                last <= 1'b1;
            end else begin
                rd <= 1'b1;
                fp_addr_0 <= in_rule_data[16*0+RULE_AWIDTH-1:16*0] - 1;
                fp_addr_1 <= in_rule_data[16*1+RULE_AWIDTH-1:16*1] - 1;
            end
        end
    end
end

//delay
always@(posedge clk)begin
    rd_r1 <= rd;
    rd_r2 <= rd_r1;
    last_r1 <= last;
    last_r2 <= last_r1;
    //three cycles delay for in_rule_data and fp_data
    in_rule_data_r <= in_rule_data;
    in_rule_data_r1 <= in_rule_data_r;
    in_rule_data_r2 <= in_rule_data_r1;
    fp_data_r <= fp_data;
    fp_data_r1 <= fp_data_r;
    fp_data_r2 <= fp_data_r1;
end

assign match_0 = ((fp_data_r2 & fp_0) == fp_0) & (fp_0 != 0);
assign match_1 = ((fp_data_r2 & fp_1) == fp_1) & (fp_1 != 0);

assign int_fp_rule_sop = (int_fp_rule_cnt == 0) ? int_fp_rule_valid : 1'b0;
//Match rule fp with pkt fp
always@(posedge clk)begin
    if(rst)begin
        int_fp_rule_valid <= 1'b0;
        int_fp_rule_eop <= 1'b0;
        int_fp_rule_cnt <= 0;
    end else begin
        int_fp_rule_valid <= 1'b0;
        int_fp_rule_eop <= 1'b0;
        if(rd_r2)begin
            if(match_0)begin
                int_fp_rule_data[16*1-1:16*0] <= in_rule_data_r2[16*1-1:16*0];
            end else begin
                int_fp_rule_data[16*1-1:16*0] <= 16'b0;;
            end
            if(match_1)begin
                int_fp_rule_data[16*2-1:16*1] <= in_rule_data_r2[16*2-1:16*1];
            end else begin
                int_fp_rule_data[16*2-1:16*1] <= 16'b0;;
            end
            int_fp_rule_valid <=  match_0 |  match_1 |  0;
        end
        if(last_r2)begin
            int_fp_rule_valid <= 1'b1;
            int_fp_rule_eop   <= 1'b1;
            int_fp_rule_data <= 0;
        end
        if(int_fp_rule_valid)begin
            if(int_fp_rule_eop)begin
                int_fp_rule_cnt <= 0;
            end else begin
                int_fp_rule_cnt <= int_fp_rule_cnt + 1'b1;
            end
        end
    end
end

rom_2port #(
    .DWIDTH(FP_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./src/memory_init/rule_fp.mif")
)
fp_rom_0 (
    .q_a       (fp_0),    
    .q_b       (fp_1),    
    .address_a (fp_addr_0),
    .address_b (fp_addr_1),
    .clock     (clk)   
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] int_fp_rule_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (2),
    .BITS_PER_SYMBOL  (16),
    .FIFO_DEPTH       (512)
) int_fp_rule_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (int_fp_rule_data),
    .in_valid          (int_fp_rule_valid),
    .in_ready          (int_fp_rule_ready),
    .in_startofpacket  (int_fp_rule_sop),
    .in_endofpacket    (int_fp_rule_eop),
    .in_empty          (int_fp_rule_empty),
    .out_data          (rulepacker_in_data),
    .out_valid         (rulepacker_in_valid),
    .out_ready         (rulepacker_in_ready),
    .out_startofpacket (rulepacker_in_sop),
    .out_endofpacket   (rulepacker_in_eop),
    .out_empty         (rulepacker_in_empty),
    .fill_level        (int_fp_rule_csr_readdata),
    .almost_full       (int_fp_rule_almost_full),
    .overflow          ()
);


//rule packer
rule_packer_32_512 rule_packer_inst(
    .clk            (clk),
    .rst            (rst),
    .in_rule_data   (rulepacker_in_data),
    .in_rule_valid  (rulepacker_in_valid),
    .in_rule_ready  (rulepacker_in_ready),
    .in_rule_sop    (rulepacker_in_sop),
    .in_rule_eop    (rulepacker_in_eop),
    .in_rule_empty  (),
    .out_rule_data  (rulepacker_out_data),
    .out_rule_valid (rulepacker_out_valid),
    .out_rule_ready (rulepacker_out_ready),
    .out_rule_sop   (rulepacker_out_sop),
    .out_rule_eop   (rulepacker_out_eop),
    .out_rule_empty (rulepacker_out_empty)
);

//512-bit wide rule FIFO
unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_packer_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (0),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) rule_packer_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),//not used
    .in_data           (rulepacker_out_data),
    .in_valid          (rulepacker_out_valid),
    .in_ready          (rulepacker_out_ready),
    .in_startofpacket  (rulepacker_out_sop),
    .in_endofpacket    (rulepacker_out_eop),
    .in_empty          (rulepacker_out_empty),
    .out_data          (fp_rule_data),
    .out_valid         (fp_rule_valid),
    .out_ready         (fp_rule_ready),
    .out_startofpacket (fp_rule_sop),
    .out_endofpacket   (fp_rule_eop),
    .out_empty         (fp_rule_empty),
    .fill_level        (),
    .almost_full       (),
    .overflow          ()
);

endmodule
