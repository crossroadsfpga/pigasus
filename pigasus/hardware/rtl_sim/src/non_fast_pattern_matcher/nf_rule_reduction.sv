`include "./src/struct_s.sv"
module nf_rule_reduction(
    input            clk,
    input            rst,
    input [511:0]    in_rule_data,
    input            in_rule_valid,
    input            in_rule_sop,
    input            in_rule_eop,
    input [5:0]      in_rule_empty,
    output logic     in_rule_ready,
    output logic [16*2-1:0] out_rule_data,
    output logic     out_rule_valid,
    output logic     out_rule_sop,
    output logic     out_rule_eop,
    input            out_rule_ready
);

logic                                     rule_depacker_sop;
logic                                     rule_depacker_eop;
logic [127:0] rule_depacker_data;
logic                                     rule_depacker_valid;
logic                                     rule_depacker_ready;


rule_nf_t    rule_data_0;
logic        rule_valid_0;
logic        rule_ready_0;
logic [31:0] rule_csr_readdata_0;
logic        rule_almost_full_0;
rule_nf_t    rule_data_1;
logic        rule_valid_1;
logic        rule_ready_1;
logic [31:0] rule_csr_readdata_1;
logic        rule_almost_full_1;
rule_nf_t    rule_data_2;
logic        rule_valid_2;
logic        rule_ready_2;
logic [31:0] rule_csr_readdata_2;
logic        rule_almost_full_2;
rule_nf_t    rule_data_3;
logic        rule_valid_3;
logic        rule_ready_3;
logic [31:0] rule_csr_readdata_3;
logic        rule_almost_full_3;
rule_nf_t    rule_data_4;
logic        rule_valid_4;
logic        rule_ready_4;
logic [31:0] rule_csr_readdata_4;
logic        rule_almost_full_4;
rule_nf_t    rule_data_5;
logic        rule_valid_5;
logic        rule_ready_5;
logic [31:0] rule_csr_readdata_5;
logic        rule_almost_full_5;
rule_nf_t    rule_data_6;
logic        rule_valid_6;
logic        rule_ready_6;
logic [31:0] rule_csr_readdata_6;
logic        rule_almost_full_6;
rule_nf_t    rule_data_7;
logic        rule_valid_7;
logic        rule_ready_7;
logic [31:0] rule_csr_readdata_7;
logic        rule_almost_full_7;

rule_nf_t    int_data_0_0;
logic        int_valid_0_0;
logic        int_ready_0_0;
rule_nf_t    int_data_0_1;
logic        int_valid_0_1;
logic        int_ready_0_1;
rule_nf_t    int_data_1_0;
logic        int_valid_1_0;
logic        int_ready_1_0;
rule_nf_t    int_data_1_1;
logic        int_valid_1_1;
logic        int_ready_1_1;
rule_nf_t    int_data_2_0;
logic        int_valid_2_0;
logic        int_ready_2_0;
rule_nf_t    int_data_2_1;
logic        int_valid_2_1;
logic        int_ready_2_1;
rule_nf_t    int_data_3_0;
logic        int_valid_3_0;
logic        int_ready_3_0;
rule_nf_t    int_data_3_1;
logic        int_valid_3_1;
logic        int_ready_3_1;
rule_nf_t    int_data_4_0;
logic        int_valid_4_0;
logic        int_ready_4_0;
rule_nf_t    int_data_4_1;
logic        int_valid_4_1;
logic        int_ready_4_1;
rule_nf_t    int_data_5_0;
logic        int_valid_5_0;
logic        int_ready_5_0;
rule_nf_t    int_data_5_1;
logic        int_valid_5_1;
logic        int_ready_5_1;
rule_nf_t    int_data_6_0;
logic        int_valid_6_0;
logic        int_ready_6_0;
rule_nf_t    int_data_6_1;
logic        int_valid_6_1;
logic        int_ready_6_1;
rule_nf_t    int_data_7_0;
logic        int_valid_7_0;
logic        int_ready_7_0;
rule_nf_t    int_data_7_1;
logic        int_valid_7_1;
logic        int_ready_7_1;

rule_nf_t    last_layer_data_0;
logic        last_layer_valid_0;
logic        last_layer_ready_0;
rule_nf_t    last_layer_data_1;
logic        last_layer_valid_1;
logic        last_layer_ready_1;

logic enq;
logic all_last;
logic sync_ready;
logic sync_valid;
logic sync_sop;
logic sync_eop;
logic sync_almost_full;
logic [16*2-1:0] sync_data;
logic [15:0] sync_cnt;


//Convert rule_depacker to individual rules
always@(posedge clk)begin
    if(rst)begin
        rule_valid_0 <= 1'b0;  
        rule_valid_1 <= 1'b0;  
        rule_valid_2 <= 1'b0;  
        rule_valid_3 <= 1'b0;  
        rule_valid_4 <= 1'b0;  
        rule_valid_5 <= 1'b0;  
        rule_valid_6 <= 1'b0;  
        rule_valid_7 <= 1'b0;  
        rule_depacker_ready <= 1'b0;
    end else begin
        rule_valid_0 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*0+RULE_AWIDTH-1:16*0]!=0));
        rule_valid_1 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*1+RULE_AWIDTH-1:16*1]!=0));
        rule_valid_2 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*2+RULE_AWIDTH-1:16*2]!=0));
        rule_valid_3 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*3+RULE_AWIDTH-1:16*3]!=0));
        rule_valid_4 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*4+RULE_AWIDTH-1:16*4]!=0));
        rule_valid_5 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*5+RULE_AWIDTH-1:16*5]!=0));
        rule_valid_6 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*6+RULE_AWIDTH-1:16*6]!=0));
        rule_valid_7 <= rule_depacker_valid & rule_depacker_ready & (rule_depacker_eop | (rule_depacker_data[16*7+RULE_AWIDTH-1:16*7]!=0));
        rule_depacker_ready <=  !rule_almost_full_0 &  !rule_almost_full_1 &  !rule_almost_full_2 &  !rule_almost_full_3 &  !rule_almost_full_4 &  !rule_almost_full_5 &  !rule_almost_full_6 &  !rule_almost_full_7 &  1;
    end
    rule_data_0.last <= rule_depacker_eop;
    rule_data_0.data <= rule_depacker_data[16*0+RULE_AWIDTH-1:16*0];
    rule_data_1.last <= rule_depacker_eop;
    rule_data_1.data <= rule_depacker_data[16*1+RULE_AWIDTH-1:16*1];
    rule_data_2.last <= rule_depacker_eop;
    rule_data_2.data <= rule_depacker_data[16*2+RULE_AWIDTH-1:16*2];
    rule_data_3.last <= rule_depacker_eop;
    rule_data_3.data <= rule_depacker_data[16*3+RULE_AWIDTH-1:16*3];
    rule_data_4.last <= rule_depacker_eop;
    rule_data_4.data <= rule_depacker_data[16*4+RULE_AWIDTH-1:16*4];
    rule_data_5.last <= rule_depacker_eop;
    rule_data_5.data <= rule_depacker_data[16*5+RULE_AWIDTH-1:16*5];
    rule_data_6.last <= rule_depacker_eop;
    rule_data_6.data <= rule_depacker_data[16*6+RULE_AWIDTH-1:16*6];
    rule_data_7.last <= rule_depacker_eop;
    rule_data_7.data <= rule_depacker_data[16*7+RULE_AWIDTH-1:16*7];
end

assign sync_sop = (sync_cnt == 0) ? sync_valid : 1'b0;
assign all_last =  last_layer_data_0.last &  last_layer_data_1.last &  1;
assign enq =  last_layer_valid_0 &  last_layer_valid_1 &  !sync_almost_full;
 
assign last_layer_ready_0 = enq & (all_last | !last_layer_data_0.last);
assign last_layer_ready_1 = enq & (all_last | !last_layer_data_1.last);

//Sync output rules
always@(posedge clk)begin
    if(rst)begin
        sync_valid <= 1'b0;       
        sync_eop <= 1'b0;
        sync_cnt <= 0;
    end else begin
        sync_valid <= enq;
        sync_eop <= all_last;
        if(sync_valid)begin
            if(sync_eop)begin
                sync_cnt <= 0;
            end else begin
                sync_cnt <= sync_cnt + 1'b1;
            end
        end
    end
    sync_data[16*1-1:16*0]  <= last_layer_data_0.data;
    sync_data[16*2-1:16*1]  <= last_layer_data_1.data;
end 



//Depacker
rule_depacker_512_128 rule_depacker_inst(
    .clk            (clk),
    .rst            (rst),
    .in_rule_data   (in_rule_data),
    .in_rule_valid  (in_rule_valid),
    .in_rule_ready  (in_rule_ready),
    .in_rule_sop    (in_rule_sop),
    .in_rule_eop    (in_rule_eop),
    .in_rule_empty  (in_rule_empty),
    .out_rule_data  (rule_depacker_data),
    .out_rule_valid (rule_depacker_valid),
    .out_rule_ready (rule_depacker_ready),
    .out_rule_sop   (rule_depacker_sop),
    .out_rule_eop   (rule_depacker_eop),
    .out_rule_empty ()
);


//input FIFOs

unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_0"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_0 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_0),
    .in_valid          (rule_valid_0),
    .in_ready          (rule_ready_0),
    .out_data          (int_data_0_0),
    .out_valid         (int_valid_0_0),
    .out_ready         (int_ready_0_0),
    .fill_level        (rule_csr_readdata_0),
    .almost_full       (rule_almost_full_0),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_1"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_1 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_1),
    .in_valid          (rule_valid_1),
    .in_ready          (rule_ready_1),
    .out_data          (int_data_1_0),
    .out_valid         (int_valid_1_0),
    .out_ready         (int_ready_1_0),
    .fill_level        (rule_csr_readdata_1),
    .almost_full       (rule_almost_full_1),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_2"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_2 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_2),
    .in_valid          (rule_valid_2),
    .in_ready          (rule_ready_2),
    .out_data          (int_data_2_0),
    .out_valid         (int_valid_2_0),
    .out_ready         (int_ready_2_0),
    .fill_level        (rule_csr_readdata_2),
    .almost_full       (rule_almost_full_2),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_3"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_3 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_3),
    .in_valid          (rule_valid_3),
    .in_ready          (rule_ready_3),
    .out_data          (int_data_3_0),
    .out_valid         (int_valid_3_0),
    .out_ready         (int_ready_3_0),
    .fill_level        (rule_csr_readdata_3),
    .almost_full       (rule_almost_full_3),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_4"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_4 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_4),
    .in_valid          (rule_valid_4),
    .in_ready          (rule_ready_4),
    .out_data          (int_data_4_0),
    .out_valid         (int_valid_4_0),
    .out_ready         (int_ready_4_0),
    .fill_level        (rule_csr_readdata_4),
    .almost_full       (rule_almost_full_4),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_5"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_5 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_5),
    .in_valid          (rule_valid_5),
    .in_ready          (rule_ready_5),
    .out_data          (int_data_5_0),
    .out_valid         (int_valid_5_0),
    .out_ready         (int_ready_5_0),
    .fill_level        (rule_csr_readdata_5),
    .almost_full       (rule_almost_full_5),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_6"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_6 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_6),
    .in_valid          (rule_valid_6),
    .in_ready          (rule_ready_6),
    .out_data          (int_data_6_0),
    .out_valid         (int_valid_6_0),
    .out_ready         (int_ready_6_0),
    .fill_level        (rule_csr_readdata_6),
    .almost_full       (rule_almost_full_6),
    .overflow          ()
);


unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO_7"),
    .MEM_TYPE         ("MLAB"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (24),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (RULE_NF_WIDTH),
    .FIFO_DEPTH       (32)
) in_fifo_7 (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (rule_data_7),
    .in_valid          (rule_valid_7),
    .in_ready          (rule_ready_7),
    .out_data          (int_data_7_0),
    .out_valid         (int_valid_7_0),
    .out_ready         (int_ready_7_0),
    .fill_level        (rule_csr_readdata_7),
    .almost_full       (rule_almost_full_7),
    .overflow          ()
);


//Reduction tree
    nf_reduction_2t1 reduction_unit_0_0 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_0_0),
        .in_valid_0   (int_valid_0_0),
        .in_ready_0   (int_ready_0_0),
        .in_data_1    (int_data_1_0),
        .in_valid_1   (int_valid_1_0),
        .in_ready_1   (int_ready_1_0),
        .out_data     (int_data_0_1),
        .out_valid    (int_valid_0_1),
        .out_ready    (int_ready_0_1)
    );
    nf_reduction_2t1 reduction_unit_1_0 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_2_0),
        .in_valid_0   (int_valid_2_0),
        .in_ready_0   (int_ready_2_0),
        .in_data_1    (int_data_3_0),
        .in_valid_1   (int_valid_3_0),
        .in_ready_1   (int_ready_3_0),
        .out_data     (int_data_1_1),
        .out_valid    (int_valid_1_1),
        .out_ready    (int_ready_1_1)
    );
    nf_reduction_2t1 reduction_unit_2_0 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_4_0),
        .in_valid_0   (int_valid_4_0),
        .in_ready_0   (int_ready_4_0),
        .in_data_1    (int_data_5_0),
        .in_valid_1   (int_valid_5_0),
        .in_ready_1   (int_ready_5_0),
        .out_data     (int_data_2_1),
        .out_valid    (int_valid_2_1),
        .out_ready    (int_ready_2_1)
    );
    nf_reduction_2t1 reduction_unit_3_0 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_6_0),
        .in_valid_0   (int_valid_6_0),
        .in_ready_0   (int_ready_6_0),
        .in_data_1    (int_data_7_0),
        .in_valid_1   (int_valid_7_0),
        .in_ready_1   (int_ready_7_0),
        .out_data     (int_data_3_1),
        .out_valid    (int_valid_3_1),
        .out_ready    (int_ready_3_1)
    );
    nf_reduction_2t1 reduction_unit_0_1 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_0_1),
        .in_valid_0   (int_valid_0_1),
        .in_ready_0   (int_ready_0_1),
        .in_data_1    (int_data_1_1),
        .in_valid_1   (int_valid_1_1),
        .in_ready_1   (int_ready_1_1),
        .out_data     (last_layer_data_0),
        .out_valid    (last_layer_valid_0),
        .out_ready    (last_layer_ready_0)
    );
    nf_reduction_2t1 reduction_unit_1_1 (
        .clk          (clk), 
        .rst          (rst),
        .in_data_0    (int_data_2_1),
        .in_valid_0   (int_valid_2_1),
        .in_ready_0   (int_ready_2_1),
        .in_data_1    (int_data_3_1),
        .in_valid_1   (int_valid_3_1),
        .in_ready_1   (int_ready_3_1),
        .out_data     (last_layer_data_1),
        .out_valid    (last_layer_valid_1),
        .out_ready    (last_layer_ready_1)
    );

//output fifo
unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] rule_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (2),
    .BITS_PER_SYMBOL  (16),
    .FIFO_DEPTH       (512)
) output_rule_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (sync_data),
    .in_valid          (sync_valid),
    .in_ready          (sync_ready),
    .in_startofpacket  (sync_sop),
    .in_endofpacket    (sync_eop),
    .in_empty          (sync_empty),
    .out_data          (out_rule_data),
    .out_valid         (out_rule_valid),
    .out_ready         (out_rule_ready),
    .out_startofpacket (out_rule_sop),
    .out_endofpacket   (out_rule_eop),
    .out_empty         (),
    .fill_level        (sync_csr_readdata),
    .almost_full       (sync_almost_full),
    .overflow          ()
);


endmodule
