`include "./src/struct_s.sv"
module rule_reduction(
    input clk,
    input rst,
    input [127:0] rule_data,
    input         rule_valid,
    input         rule_eop,
    output logic  rule_ready,
    output rule_nf_t rule_out_data_0,
    output logic     rule_out_valid_0,
    input  logic     rule_out_ready_0,
    output rule_nf_t rule_out_data_1,
    output logic     rule_out_valid_1,
    input  logic     rule_out_ready_1
);

localparam L1_FIFO_DEPTH = 64;
localparam L1_TH = (L1_FIFO_DEPTH-24);

logic [RULE_AWIDTH-1:0] l1_cache_0;
logic [RULE_AWIDTH-1:0] rule_data_0;
rule_nf_t    l1_in_data_0;
logic        l1_in_valid_0;
logic        l1_in_ready_0;
rule_nf_t    l1_out_data_0;
logic        l1_out_valid_0;
logic        l1_out_ready_0;
logic        l1_almost_full_0;
logic [31:0] l1_csr_readdata_0;
logic [RULE_AWIDTH-1:0] l1_cache_1;
logic [RULE_AWIDTH-1:0] rule_data_1;
rule_nf_t    l1_in_data_1;
logic        l1_in_valid_1;
logic        l1_in_ready_1;
rule_nf_t    l1_out_data_1;
logic        l1_out_valid_1;
logic        l1_out_ready_1;
logic        l1_almost_full_1;
logic [31:0] l1_csr_readdata_1;
logic [RULE_AWIDTH-1:0] l1_cache_2;
logic [RULE_AWIDTH-1:0] rule_data_2;
rule_nf_t    l1_in_data_2;
logic        l1_in_valid_2;
logic        l1_in_ready_2;
rule_nf_t    l1_out_data_2;
logic        l1_out_valid_2;
logic        l1_out_ready_2;
logic        l1_almost_full_2;
logic [31:0] l1_csr_readdata_2;
logic [RULE_AWIDTH-1:0] l1_cache_3;
logic [RULE_AWIDTH-1:0] rule_data_3;
rule_nf_t    l1_in_data_3;
logic        l1_in_valid_3;
logic        l1_in_ready_3;
rule_nf_t    l1_out_data_3;
logic        l1_out_valid_3;
logic        l1_out_ready_3;
logic        l1_almost_full_3;
logic [31:0] l1_csr_readdata_3;
logic [RULE_AWIDTH-1:0] l1_cache_4;
logic [RULE_AWIDTH-1:0] rule_data_4;
rule_nf_t    l1_in_data_4;
logic        l1_in_valid_4;
logic        l1_in_ready_4;
rule_nf_t    l1_out_data_4;
logic        l1_out_valid_4;
logic        l1_out_ready_4;
logic        l1_almost_full_4;
logic [31:0] l1_csr_readdata_4;
logic [RULE_AWIDTH-1:0] l1_cache_5;
logic [RULE_AWIDTH-1:0] rule_data_5;
rule_nf_t    l1_in_data_5;
logic        l1_in_valid_5;
logic        l1_in_ready_5;
rule_nf_t    l1_out_data_5;
logic        l1_out_valid_5;
logic        l1_out_ready_5;
logic        l1_almost_full_5;
logic [31:0] l1_csr_readdata_5;
logic [RULE_AWIDTH-1:0] l1_cache_6;
logic [RULE_AWIDTH-1:0] rule_data_6;
rule_nf_t    l1_in_data_6;
logic        l1_in_valid_6;
logic        l1_in_ready_6;
rule_nf_t    l1_out_data_6;
logic        l1_out_valid_6;
logic        l1_out_ready_6;
logic        l1_almost_full_6;
logic [31:0] l1_csr_readdata_6;
logic [RULE_AWIDTH-1:0] l1_cache_7;
logic [RULE_AWIDTH-1:0] rule_data_7;
rule_nf_t    l1_in_data_7;
logic        l1_in_valid_7;
logic        l1_in_ready_7;
rule_nf_t    l1_out_data_7;
logic        l1_out_valid_7;
logic        l1_out_ready_7;
logic        l1_almost_full_7;
logic [31:0] l1_csr_readdata_7;

logic        l1_all_last_0;
logic [3:0]  l1_req_0;
logic [3:0]  l1_grant_0;
rule_nf_t    l2_in_data_0;
logic        l2_in_valid_0;
logic        l2_in_ready_0;
logic        l2_almost_full_0;
logic [31:0] l2_csr_readdata_0;
logic        l1_all_last_1;
logic [3:0]  l1_req_1;
logic [3:0]  l1_grant_1;
rule_nf_t    l2_in_data_1;
logic        l2_in_valid_1;
logic        l2_in_ready_1;
logic        l2_almost_full_1;
logic [31:0] l2_csr_readdata_1;
assign rule_data_0 = rule_data[0*16+RULE_AWIDTH-1:0*16];
assign rule_data_1 = rule_data[1*16+RULE_AWIDTH-1:1*16];
assign rule_data_2 = rule_data[2*16+RULE_AWIDTH-1:2*16];
assign rule_data_3 = rule_data[3*16+RULE_AWIDTH-1:3*16];
assign rule_data_4 = rule_data[4*16+RULE_AWIDTH-1:4*16];
assign rule_data_5 = rule_data[5*16+RULE_AWIDTH-1:5*16];
assign rule_data_6 = rule_data[6*16+RULE_AWIDTH-1:6*16];
assign rule_data_7 = rule_data[7*16+RULE_AWIDTH-1:7*16];

//push data into FIFO
always @(posedge clk)begin
    if(rst)begin
        l1_in_valid_0 <= 0;
        l1_cache_0 <= 0;
        l1_in_valid_1 <= 0;
        l1_cache_1 <= 0;
        l1_in_valid_2 <= 0;
        l1_cache_2 <= 0;
        l1_in_valid_3 <= 0;
        l1_cache_3 <= 0;
        l1_in_valid_4 <= 0;
        l1_cache_4 <= 0;
        l1_in_valid_5 <= 0;
        l1_cache_5 <= 0;
        l1_in_valid_6 <= 0;
        l1_cache_6 <= 0;
        l1_in_valid_7 <= 0;
        l1_cache_7 <= 0;
    end else begin
    l1_in_data_0.data <= rule_data_0;
    l1_in_data_0.last <= rule_eop;

    l1_in_valid_0 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_0 <= 1;
            l1_cache_0 <= 0;
        end else if ((rule_data_0 !=0) &  
            (rule_data_0 !=l1_cache_0))begin
            l1_in_valid_0 <= 1;
            l1_cache_0 <= rule_data_0;
        end
    end
    l1_in_data_1.data <= rule_data_1;
    l1_in_data_1.last <= rule_eop;

    l1_in_valid_1 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_1 <= 1;
            l1_cache_1 <= 0;
        end else if ((rule_data_1 !=0) &  
            (rule_data_1 !=l1_cache_1))begin
            l1_in_valid_1 <= 1;
            l1_cache_1 <= rule_data_1;
        end
    end
    l1_in_data_2.data <= rule_data_2;
    l1_in_data_2.last <= rule_eop;

    l1_in_valid_2 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_2 <= 1;
            l1_cache_2 <= 0;
        end else if ((rule_data_2 !=0) &  
            (rule_data_2 !=l1_cache_2))begin
            l1_in_valid_2 <= 1;
            l1_cache_2 <= rule_data_2;
        end
    end
    l1_in_data_3.data <= rule_data_3;
    l1_in_data_3.last <= rule_eop;

    l1_in_valid_3 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_3 <= 1;
            l1_cache_3 <= 0;
        end else if ((rule_data_3 !=0) &  
            (rule_data_3 !=l1_cache_3))begin
            l1_in_valid_3 <= 1;
            l1_cache_3 <= rule_data_3;
        end
    end
    l1_in_data_4.data <= rule_data_4;
    l1_in_data_4.last <= rule_eop;

    l1_in_valid_4 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_4 <= 1;
            l1_cache_4 <= 0;
        end else if ((rule_data_4 !=0) &  
            (rule_data_4 !=l1_cache_4))begin
            l1_in_valid_4 <= 1;
            l1_cache_4 <= rule_data_4;
        end
    end
    l1_in_data_5.data <= rule_data_5;
    l1_in_data_5.last <= rule_eop;

    l1_in_valid_5 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_5 <= 1;
            l1_cache_5 <= 0;
        end else if ((rule_data_5 !=0) &  
            (rule_data_5 !=l1_cache_5))begin
            l1_in_valid_5 <= 1;
            l1_cache_5 <= rule_data_5;
        end
    end
    l1_in_data_6.data <= rule_data_6;
    l1_in_data_6.last <= rule_eop;

    l1_in_valid_6 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_6 <= 1;
            l1_cache_6 <= 0;
        end else if ((rule_data_6 !=0) &  
            (rule_data_6 !=l1_cache_6))begin
            l1_in_valid_6 <= 1;
            l1_cache_6 <= rule_data_6;
        end
    end
    l1_in_data_7.data <= rule_data_7;
    l1_in_data_7.last <= rule_eop;

    l1_in_valid_7 <= 0;
    if(rule_valid & rule_ready)begin
        if(rule_eop)begin
            l1_in_valid_7 <= 1;
            l1_cache_7 <= 0;
        end else if ((rule_data_7 !=0) &  
            (rule_data_7 !=l1_cache_7))begin
            l1_in_valid_7 <= 1;
            l1_cache_7 <= rule_data_7;
        end
    end
    end
end
assign rule_ready =  (!l1_almost_full_0)&  (!l1_almost_full_1)&  (!l1_almost_full_2)&  (!l1_almost_full_3)&  (!l1_almost_full_4)&  (!l1_almost_full_5)&  (!l1_almost_full_6)&  (!l1_almost_full_7)&  1;

assign l1_all_last_0 =  (l1_out_data_0.last & l1_out_valid_0) &  (l1_out_data_1.last & l1_out_valid_1) &  (l1_out_data_2.last & l1_out_valid_2) &  (l1_out_data_3.last & l1_out_valid_3) &  !l2_almost_full_0;

//generate request, combinationally logic
always @(*)begin
    l1_req_0[0] = l1_out_valid_0 & !l1_out_data_0.last & !l2_almost_full_0;
    l1_out_ready_0  = l1_grant_0[0];       
    l1_req_0[1] = l1_out_valid_1 & !l1_out_data_1.last & !l2_almost_full_0;
    l1_out_ready_1  = l1_grant_0[1];       
    l1_req_0[2] = l1_out_valid_2 & !l1_out_data_2.last & !l2_almost_full_0;
    l1_out_ready_2  = l1_grant_0[2];       
    l1_req_0[3] = l1_out_valid_3 & !l1_out_data_3.last & !l2_almost_full_0;
    l1_out_ready_3  = l1_grant_0[3];       
    //sync case
    if(l1_all_last_0) begin
        l1_req_0 = 0;
        l1_out_ready_0 = 1;
        l1_out_ready_1 = 1;
        l1_out_ready_2 = 1;
        l1_out_ready_3 = 1;
    end
end

                    
//dequeue FIFO and write to next FIFO
always @(posedge clk)begin
    if(rst)begin
        l2_in_valid_0 <= 0;
    end else begin
        //sync case
        if(l1_all_last_0) begin
            l2_in_valid_0 <= 1;
        //normal case
        end else begin
            l2_in_valid_0 <= |l1_grant_0;
        end
    end
    //sync case
    if(l1_all_last_0) begin
        l2_in_data_0.last <= 1;
        l2_in_data_0.data <= 0;
    //normal case
    end else begin
        case(l1_grant_0)
            4'b0001: l2_in_data_0 <= l1_out_data_0;
            4'b0010: l2_in_data_0 <= l1_out_data_1;
            4'b0100: l2_in_data_0 <= l1_out_data_2;
            4'b1000: l2_in_data_0 <= l1_out_data_3;
            default: l2_in_data_0 <= 0;
        endcase
    end   
end
assign l1_all_last_1 =  (l1_out_data_4.last & l1_out_valid_4) &  (l1_out_data_5.last & l1_out_valid_5) &  (l1_out_data_6.last & l1_out_valid_6) &  (l1_out_data_7.last & l1_out_valid_7) &  !l2_almost_full_1;

//generate request, combinationally logic
always @(*)begin
    l1_req_1[0] = l1_out_valid_4 & !l1_out_data_4.last & !l2_almost_full_1;
    l1_out_ready_4  = l1_grant_1[0];       
    l1_req_1[1] = l1_out_valid_5 & !l1_out_data_5.last & !l2_almost_full_1;
    l1_out_ready_5  = l1_grant_1[1];       
    l1_req_1[2] = l1_out_valid_6 & !l1_out_data_6.last & !l2_almost_full_1;
    l1_out_ready_6  = l1_grant_1[2];       
    l1_req_1[3] = l1_out_valid_7 & !l1_out_data_7.last & !l2_almost_full_1;
    l1_out_ready_7  = l1_grant_1[3];       
    //sync case
    if(l1_all_last_1) begin
        l1_req_1 = 0;
        l1_out_ready_4 = 1;
        l1_out_ready_5 = 1;
        l1_out_ready_6 = 1;
        l1_out_ready_7 = 1;
    end
end

                    
//dequeue FIFO and write to next FIFO
always @(posedge clk)begin
    if(rst)begin
        l2_in_valid_1 <= 0;
    end else begin
        //sync case
        if(l1_all_last_1) begin
            l2_in_valid_1 <= 1;
        //normal case
        end else begin
            l2_in_valid_1 <= |l1_grant_1;
        end
    end
    //sync case
    if(l1_all_last_1) begin
        l2_in_data_1.last <= 1;
        l2_in_data_1.data <= 0;
    //normal case
    end else begin
        case(l1_grant_1)
            4'b0001: l2_in_data_1 <= l1_out_data_4;
            4'b0010: l2_in_data_1 <= l1_out_data_5;
            4'b0100: l2_in_data_1 <= l1_out_data_6;
            4'b1000: l2_in_data_1 <= l1_out_data_7;
            default: l2_in_data_1 <= 0;
        endcase
    end   
end



//L1 FIFO
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_0 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_0),
    .csr_writedata       (0),
    .in_data             (l1_in_data_0),              
    .in_valid            (l1_in_valid_0),             
    .in_ready            (l1_in_ready_0),             
    .out_data            (l1_out_data_0),              
    .out_valid           (l1_out_valid_0),             
    .out_ready           (l1_out_ready_0)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_0 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_0),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_0)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_1 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_1),
    .csr_writedata       (0),
    .in_data             (l1_in_data_1),              
    .in_valid            (l1_in_valid_1),             
    .in_ready            (l1_in_ready_1),             
    .out_data            (l1_out_data_1),              
    .out_valid           (l1_out_valid_1),             
    .out_ready           (l1_out_ready_1)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_1 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_1),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_1)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_2 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_2),
    .csr_writedata       (0),
    .in_data             (l1_in_data_2),              
    .in_valid            (l1_in_valid_2),             
    .in_ready            (l1_in_ready_2),             
    .out_data            (l1_out_data_2),              
    .out_valid           (l1_out_valid_2),             
    .out_ready           (l1_out_ready_2)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_2 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_2),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_2)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_3 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_3),
    .csr_writedata       (0),
    .in_data             (l1_in_data_3),              
    .in_valid            (l1_in_valid_3),             
    .in_ready            (l1_in_ready_3),             
    .out_data            (l1_out_data_3),              
    .out_valid           (l1_out_valid_3),             
    .out_ready           (l1_out_ready_3)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_3 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_3),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_3)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_4 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_4),
    .csr_writedata       (0),
    .in_data             (l1_in_data_4),              
    .in_valid            (l1_in_valid_4),             
    .in_ready            (l1_in_ready_4),             
    .out_data            (l1_out_data_4),              
    .out_valid           (l1_out_valid_4),             
    .out_ready           (l1_out_ready_4)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_4 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_4),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_4)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_5 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_5),
    .csr_writedata       (0),
    .in_data             (l1_in_data_5),              
    .in_valid            (l1_in_valid_5),             
    .in_ready            (l1_in_ready_5),             
    .out_data            (l1_out_data_5),              
    .out_valid           (l1_out_valid_5),             
    .out_ready           (l1_out_ready_5)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_5 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_5),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_5)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_6 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_6),
    .csr_writedata       (0),
    .in_data             (l1_in_data_6),              
    .in_valid            (l1_in_valid_6),             
    .in_ready            (l1_in_ready_6),             
    .out_data            (l1_out_data_6),              
    .out_valid           (l1_out_valid_6),             
    .out_ready           (l1_out_ready_6)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_6 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_6),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_6)
);
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l1_fifo_mlab_7 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l1_csr_readdata_7),
    .csr_writedata       (0),
    .in_data             (l1_in_data_7),              
    .in_valid            (l1_in_valid_7),             
    .in_ready            (l1_in_ready_7),             
    .out_data            (l1_out_data_7),              
    .out_valid           (l1_out_valid_7),             
    .out_ready           (l1_out_ready_7)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l1_bp_7 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l1_csr_readdata_7),
    .csr_writedata  (),
    .almost_full    (l1_almost_full_7)
);


//L2 FIFO
fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l2_fifo_mlab_0 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l2_csr_readdata_0),
    .csr_writedata       (0),
    .in_data             (l2_in_data_0),              
    .in_valid            (l2_in_valid_0),             
    .in_ready            (l2_in_ready_0),             
    .out_data            (rule_out_data_0),              
    .out_valid           (rule_out_valid_0),             
    .out_ready           (rule_out_ready_0)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l2_bp_0 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l2_csr_readdata_0),
    .csr_writedata  (),
    .almost_full    (l2_almost_full_0)
);

rr_arbiter_4 #(
    .DWIDTH(4)
)
l2_arb_0(
    .clk    (clk),
    .rst    (rst),
    .req    (l1_req_0),
    .grant  (l1_grant_0)
);


fifo_wrapper_infill_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(L1_FIFO_DEPTH)
)
l2_fifo_mlab_1 (
    .clk                 (clk),                 
    .reset               (rst),        
    .csr_address         (0),
    .csr_read            (1'b1),
    .csr_write           (1'b0),
    .csr_readdata        (l2_csr_readdata_1),
    .csr_writedata       (0),
    .in_data             (l2_in_data_1),              
    .in_valid            (l2_in_valid_1),             
    .in_ready            (l2_in_ready_1),             
    .out_data            (rule_out_data_1),              
    .out_valid           (rule_out_valid_1),             
    .out_ready           (rule_out_ready_1)             
);

dc_back_pressure #(
    .FULL_LEVEL(L1_TH)
)
l2_bp_1 (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (l2_csr_readdata_1),
    .csr_writedata  (),
    .almost_full    (l2_almost_full_1)
);

rr_arbiter_4 #(
    .DWIDTH(4)
)
l2_arb_1(
    .clk    (clk),
    .rst    (rst),
    .req    (l1_req_1),
    .grant  (l1_grant_1)
);




endmodule
