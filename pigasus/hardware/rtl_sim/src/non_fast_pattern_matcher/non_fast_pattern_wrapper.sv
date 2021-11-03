`timescale 1 ps / 1 ps
//`define DUMMY
`define DEBUG
`include "./src/struct_s.sv"
module non_fast_pattern_wrapper(
    input   logic           clk,
    input   logic           rst,
    input   logic           clk_high,
    input   logic           rst_high,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,
    output  logic           in_pkt_almost_full,

    // In Meta data
    input   logic           in_meta_valid,
    input   metadata_t      in_meta_data,
    output  logic           in_meta_ready,
    output  logic           in_meta_almost_full,

    // In User data
    input   logic           in_usr_sop,
    input   logic           in_usr_eop,
    input   logic [511:0]   in_usr_data,
    input   logic [5:0]     in_usr_empty,
    input   logic           in_usr_valid,
    output  logic           in_usr_ready,

    // Out Pkt data
    output  logic [511:0]   out_pkt_data,
    output  logic           out_pkt_valid,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready,
    input   logic           out_pkt_almost_full,
    output  logic [1:0]     out_pkt_channel,

    // Out Meta data
    output  metadata_t      out_meta_data,
    output  logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,
    output  logic [1:0]     out_meta_channel,

    // Out User data
    output  logic [511:0]   out_usr_data,
    output  logic           out_usr_valid,
    output  logic           out_usr_sop,
    output  logic           out_usr_eop,
    output  logic [5:0]     out_usr_empty,
    input   logic           out_usr_ready,
    input   logic           out_usr_almost_full,
    output  logic [1:0]     out_usr_channel,

    //stats
    output  logic [31:0]    max_raw_pkt_fifo,
    output  logic [31:0]    max_pkt_fifo,
    output  logic [31:0]    max_rule_fifo
);

`ifdef DUMMY
    assign out_pkt_sop   = in_pkt_sop;
    assign out_pkt_eop   = in_pkt_eop;
    assign out_pkt_data  = in_pkt_data;
    assign out_pkt_empty = in_pkt_empty;
    assign out_pkt_valid = in_pkt_valid;
    assign in_pkt_ready  = out_pkt_ready;
   
    assign out_meta_valid = in_meta_valid;
    assign out_meta_data  = in_meta_data;
    assign in_meta_ready  = out_meta_ready;

    assign out_usr_sop   = in_usr_sop;
    assign out_usr_eop   = in_usr_eop;
    assign out_usr_data  = in_usr_data;
    assign out_usr_empty = in_usr_empty;
    assign out_usr_valid = in_usr_valid;
    assign in_usr_ready  = out_usr_ready;
`else
logic [511:0]   piped_pkt_data;
logic           piped_pkt_valid;
logic           piped_pkt_sop;
logic           piped_pkt_eop;
logic [5:0]     piped_pkt_empty;
logic           piped_pkt_almost_full;

logic           pkt_almost_full;
logic [31:0]    pkt_csr_readdata;

logic           pkt_fifo_ready0;
logic           pkt_fifo_ready1;

logic [511:0]   pkt_fifo_data;
logic           pkt_fifo_valid;
logic           pkt_fifo_ready;
logic           pkt_fifo_sop;
logic           pkt_fifo_eop;
logic [5:0]     pkt_fifo_empty;

logic           in_pkt_fifo_almost_full;
logic [31:0]    in_pkt_csr_readdata;
logic [511:0]   in_pkt_fifo_data;
logic           in_pkt_fifo_valid;
logic           in_pkt_fifo_ready;
logic           in_pkt_fifo_sop;
logic           in_pkt_fifo_eop;
logic [5:0]     in_pkt_fifo_empty;

logic           pkt_shift_valid;
logic           pkt_shift_ready;
logic [511:0]   pkt_shift_data;
logic           pkt_shift_sop;
logic           pkt_shift_eop;
logic [5:0]     pkt_shift_empty;

logic           cdc_pkt_almost_full;
logic [31:0]    cdc_pkt_csr_readdata;
logic           cdc_pkt_valid;
logic [511:0]   cdc_pkt_data;
logic           cdc_pkt_ready;
logic           cdc_pkt_sop;
logic           cdc_pkt_eop;
logic [5:0]     cdc_pkt_empty;

logic [31:0]    in_meta_fifo_csr_readdata;
logic           in_meta_fifo_valid;
metadata_t      in_meta_fifo_data;
logic           in_meta_fifo_ready;
logic           in_meta_fifo_almost_full;

logic           int_meta_valid;
metadata_t      int_meta_data;
logic           int_meta_ready;

logic                    pkt_adapter_valid;
logic [NFP_DWIDTH-1:0]   pkt_adapter_data;
logic                    pkt_adapter_ready;
logic                    pkt_adapter_sop;
logic                    pkt_adapter_eop;
logic [NFP_EWIDTH-1:0]   pkt_adapter_empty;

logic [31:0]         pkt_fp_csr_readdata;
logic                pkt_fp_almost_full;
logic [FP_WIDTH-1:0] pkt_fp_data;
logic                pkt_fp_valid;
logic                pkt_fp_ready;
logic [FP_WIDTH-1:0] pkt_fp_fifo_data;
logic                pkt_fp_fifo_valid;
logic                pkt_fp_fifo_ready;

logic [16*2-1:0] rule_data;
logic     rule_valid;
logic     rule_sop;
logic     rule_eop;
logic     rule_ready;

logic [511:0]   fp_rule_data;
logic           fp_rule_valid;
logic           fp_rule_sop;
logic           fp_rule_eop;
logic [5:0]     fp_rule_empty;
logic           fp_rule_ready;

`ifdef DEBUG
logic [15:0] raw_pkt_in_cnt;
logic [15:0] raw_pkt_out_cnt;
logic [15:0] shift_pkt_in_cnt;
logic [15:0] shift_pkt_out_cnt;
logic [15:0] pkt_fp_in_cnt;
logic [15:0] pkt_fp_out_cnt;
logic [15:0] rule_input_cnt;
logic [15:0] rule_in_cnt;
logic [15:0] rule_out_cnt;
logic [15:0] meta_in_cnt;
logic [15:0] meta_out_cnt;

always@(posedge clk)begin
    if(rst)begin
        raw_pkt_in_cnt <= 0;
        raw_pkt_out_cnt <= 0;
        shift_pkt_in_cnt <= 0;
        shift_pkt_out_cnt <= 0;
        rule_input_cnt <= 0;
        rule_in_cnt <= 0;
        rule_out_cnt <= 0;
        meta_in_cnt <= 0;
        meta_out_cnt <= 0;
    end else begin
        if(in_pkt_valid & in_pkt_ready & in_pkt_eop)begin
            raw_pkt_in_cnt <= raw_pkt_in_cnt + 1;
        end 
        if(out_pkt_valid & out_pkt_ready & out_pkt_eop)begin
            raw_pkt_out_cnt <= raw_pkt_out_cnt + 1;
        end 
        if(in_pkt_fifo_valid & in_pkt_fifo_ready & in_pkt_fifo_eop)begin
            shift_pkt_in_cnt <= shift_pkt_in_cnt + 1;
        end
        if(pkt_shift_valid & pkt_shift_ready & pkt_shift_eop)begin
            shift_pkt_out_cnt <= shift_pkt_out_cnt + 1;
        end
        if(in_usr_valid & in_usr_ready & in_usr_eop)begin
            rule_input_cnt <= rule_input_cnt + 1;
        end
        if(rule_valid & rule_ready & rule_eop)begin
            rule_in_cnt <= rule_in_cnt + 1;
        end
        if(fp_rule_valid & fp_rule_ready & fp_rule_eop)begin
            rule_out_cnt <= rule_out_cnt + 1;
        end
        if(in_meta_fifo_valid & in_meta_fifo_ready)begin
            meta_in_cnt <= meta_in_cnt + 1;
        end
        if(int_meta_valid & int_meta_ready)begin
            meta_out_cnt <= meta_out_cnt + 1;
        end
    end
end

always@(posedge clk_high)begin
    if(rst_high)begin
        pkt_fp_in_cnt <= 0;
        pkt_fp_out_cnt <= 0;
    end else begin
        if(pkt_adapter_valid & pkt_adapter_ready & pkt_adapter_eop)begin
            pkt_fp_in_cnt <= pkt_fp_in_cnt + 1;
        end 
        if(pkt_fp_valid)begin
            pkt_fp_out_cnt <= pkt_fp_out_cnt + 1;
        end 
    end
end

`endif

assign piped_pkt_almost_full = pkt_almost_full | in_pkt_fifo_almost_full;

//Pkt path
pkt_almost_full_nogap #(
    .DWIDTH(512),
    .EWIDTH(6),
    .NUM_PIPES(2)
) pkt_almost_full_inst (
    .clk                    (clk),
    .rst                    (rst),
    .in_data                (in_pkt_data),
    .in_valid               (in_pkt_valid),
    .in_ready               (in_pkt_ready),
    .in_sop                 (in_pkt_sop),
    .in_eop                 (in_pkt_eop),
    .in_empty               (in_pkt_empty),
    .out_data               (piped_pkt_data),
    .out_valid              (piped_pkt_valid),
    .out_almost_full        (piped_pkt_almost_full),
    .out_sop                (piped_pkt_sop),
    .out_eop                (piped_pkt_eop),
    .out_empty              (piped_pkt_empty)
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] bypass_pkt_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) bypass_pkt_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (piped_pkt_data),
    .in_valid          (piped_pkt_valid),
    .in_ready          (),
    .in_startofpacket  (piped_pkt_sop),
    .in_endofpacket    (piped_pkt_eop),
    .in_empty          (piped_pkt_empty),
    .out_data          (pkt_fifo_data),
    .out_valid         (pkt_fifo_valid),
    .out_ready         (pkt_fifo_ready),
    .out_startofpacket (pkt_fifo_sop),
    .out_endofpacket   (pkt_fifo_eop),
    .out_empty         (pkt_fifo_empty),
    .fill_level        (pkt_csr_readdata),
    .almost_full       (pkt_almost_full),
    .overflow          ()
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] in_pkt_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) in_pkt_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (piped_pkt_data),
    .in_valid          (piped_pkt_valid),
    .in_ready          (),
    .in_startofpacket  (piped_pkt_sop),
    .in_endofpacket    (piped_pkt_eop),
    .in_empty          (piped_pkt_empty),
    .out_data          (in_pkt_fifo_data),
    .out_valid         (in_pkt_fifo_valid),
    .out_ready         (in_pkt_fifo_ready),
    .out_startofpacket (in_pkt_fifo_sop),
    .out_endofpacket   (in_pkt_fifo_eop),
    .out_empty         (in_pkt_fifo_empty),
    .fill_level        (in_pkt_csr_readdata),
    .almost_full       (in_pkt_fifo_almost_full),
    .overflow          ()
);

pkt_data_shift data_shift_inst (
    .clk                    (clk),
    .rst                    (rst),
    .in_pkt_sop             (in_pkt_fifo_sop),
    .in_pkt_eop             (in_pkt_fifo_eop),
    .in_pkt_valid           (in_pkt_fifo_valid),
    .in_pkt_data            (in_pkt_fifo_data),
    .in_pkt_empty           (in_pkt_fifo_empty),
    .in_pkt_ready           (in_pkt_fifo_ready),
    .in_meta_data           (in_meta_data),
    .in_meta_valid          (in_meta_valid),
    .in_meta_ready          (in_meta_ready),
    .out_pkt_sop            (pkt_shift_sop),
    .out_pkt_eop            (pkt_shift_eop),
    .out_pkt_valid          (pkt_shift_valid),
    .out_pkt_data           (pkt_shift_data),
    .out_pkt_empty          (pkt_shift_empty),
    .out_pkt_ready          (),
    .out_pkt_almost_full    (cdc_pkt_almost_full),
    .out_meta_data          (in_meta_fifo_data),
    .out_meta_valid         (in_meta_fifo_valid),
    .out_meta_ready         (in_meta_fifo_ready),
    .out_meta_almost_full   (in_meta_fifo_almost_full)
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] in_pkt_cdc_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (1),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) in_pkt_cdc (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (clk_high),
    .out_reset         (rst_high),
    .in_data           (pkt_shift_data),
    .in_valid          (pkt_shift_valid),
    .in_ready          (pkt_shift_ready),
    .in_startofpacket  (pkt_shift_sop),
    .in_endofpacket    (pkt_shift_eop),
    .in_empty          (pkt_shift_empty),
    .out_data          (cdc_pkt_data),
    .out_valid         (cdc_pkt_valid),
    .out_ready         (cdc_pkt_ready),
    .out_startofpacket (cdc_pkt_sop),
    .out_endofpacket   (cdc_pkt_eop),
    .out_empty         (cdc_pkt_empty),
    .fill_level        (cdc_pkt_csr_readdata),
    .almost_full       (cdc_pkt_almost_full),
    .overflow          ()
);

//Use conditional generate
generate
    if(NFP_DWIDTH==64)begin
        st_adapter_512_64 adapter (
            .clk               (clk_high),
            .reset_n           (!rst_high),
            .in_data           (cdc_pkt_data),
            .in_valid          (cdc_pkt_valid),
            .in_ready          (cdc_pkt_ready),
            .in_startofpacket  (cdc_pkt_sop),
            .in_endofpacket    (cdc_pkt_eop),
            .in_empty          (cdc_pkt_empty),
            .out_data          (pkt_adapter_data),
            .out_valid         (pkt_adapter_valid),
            .out_ready         (pkt_adapter_ready),
            .out_startofpacket (pkt_adapter_sop),
            .out_endofpacket   (pkt_adapter_eop),
            .out_empty         (pkt_adapter_empty)
        );
    end else if(NFP_DWIDTH==128)begin
        st_adapter_512_128 adapter (
            .clk               (clk_high),
            .reset_n           (!rst_high),
            .in_data           (cdc_pkt_data),
            .in_valid          (cdc_pkt_valid),
            .in_ready          (cdc_pkt_ready),
            .in_startofpacket  (cdc_pkt_sop),
            .in_endofpacket    (cdc_pkt_eop),
            .in_empty          (cdc_pkt_empty),
            .out_data          (pkt_adapter_data),
            .out_valid         (pkt_adapter_valid),
            .out_ready         (pkt_adapter_ready),
            .out_startofpacket (pkt_adapter_sop),
            .out_endofpacket   (pkt_adapter_eop),
            .out_empty         (pkt_adapter_empty)
        );
    end else if(NFP_DWIDTH==256)begin
        st_adapter_512_256 data_adapter_inst (
            .clk               (clk_high),
            .reset_n           (!rst_high),
            .in_data           (cdc_pkt_data),
            .in_valid          (cdc_pkt_valid),
            .in_ready          (cdc_pkt_ready),
            .in_startofpacket  (cdc_pkt_sop),
            .in_endofpacket    (cdc_pkt_eop),
            .in_empty          (cdc_pkt_empty),
            .out_data          (pkt_adapter_data),
            .out_valid         (pkt_adapter_valid),
            .out_ready         (pkt_adapter_ready),
            .out_startofpacket (pkt_adapter_sop),
            .out_endofpacket   (pkt_adapter_eop),
            .out_empty         (pkt_adapter_empty)
        );
    end else if (NFP_DWIDTH==512) begin
        assign pkt_adapter_data  = cdc_pkt_data;
        assign pkt_adapter_valid = cdc_pkt_valid;
        assign pkt_adapter_sop   = cdc_pkt_sop;
        assign pkt_adapter_eop   = cdc_pkt_eop;
        assign pkt_adapter_empty = cdc_pkt_empty;
        assign cdc_pkt_ready     = pkt_adapter_ready;
    end
endgenerate

non_fast_pattern_sm sm_inst (
    .clk               (clk_high),
    .rst               (rst_high),
    .in_data           (pkt_adapter_data),
    .in_valid          (pkt_adapter_valid),
    .in_ready          (pkt_adapter_ready),
    .in_sop            (pkt_adapter_sop),
    .in_eop            (pkt_adapter_eop),
    .in_empty          (pkt_adapter_empty),
    .fp_data           (pkt_fp_data),
    .fp_valid          (pkt_fp_valid)
);

unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] pkt_fp_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (1),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (450),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (FP_WIDTH),
    .FIFO_DEPTH       (512)
) pkt_fp_fifo (
    .in_clk            (clk_high),
    .in_reset          (rst_high),
    .out_clk           (clk),
    .out_reset         (rst),
    .in_data           (pkt_fp_data),
    .in_valid          (pkt_fp_valid),
    .in_ready          (pkt_fp_ready),
    .out_data          (pkt_fp_fifo_data),
    .out_valid         (pkt_fp_fifo_valid),
    .out_ready         (pkt_fp_fifo_ready),
    .fill_level        (pkt_fp_csr_readdata),
    .almost_full       (pkt_fp_almost_full),
    .overflow          ()
);

//Metadata path

//Big enough FIFO
unified_fifo  #(
    .FIFO_NAME        ("[non_fast_pattern] in_meta_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (1),
    .BITS_PER_SYMBOL  (META_WIDTH),
    .FIFO_DEPTH       (512)
) in_meta_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),
    .out_reset         (),
    .in_data           (in_meta_fifo_data),
    .in_valid          (in_meta_fifo_valid),
    .in_ready          (in_meta_fifo_ready),
    .out_data          (int_meta_data),
    .out_valid         (int_meta_valid),
    .out_ready         (int_meta_ready),
    .fill_level        (in_meta_fifo_csr_readdata),
    .almost_full       (in_meta_fifo_almost_full),
    .overflow          ()
);

//Rule path
nf_rule_reduction rule_reduction_inst(
    .clk              (clk),
    .rst              (rst),
    .in_rule_data     (in_usr_data),
    .in_rule_valid    (in_usr_valid),
    .in_rule_sop      (in_usr_sop),
    .in_rule_eop      (in_usr_eop),
    .in_rule_empty    (in_usr_empty),
    .in_rule_ready    (in_usr_ready),
    .out_rule_data    (rule_data),
    .out_rule_valid   (rule_valid),
    .out_rule_sop     (rule_sop),
    .out_rule_eop     (rule_eop),
    .out_rule_ready   (rule_ready)
);    

nf_fp_matcher fp_matcher_inst(
    .clk              (clk),
    .rst              (rst),
    .in_rule_data     (rule_data),
    .in_rule_valid    (rule_valid),
    .in_rule_sop      (rule_sop),
    .in_rule_eop      (rule_eop),
    .in_rule_ready    (rule_ready),
    .fp_data          (pkt_fp_fifo_data),
    .fp_valid         (pkt_fp_fifo_valid),
    .fp_ready         (pkt_fp_fifo_ready),
    .fp_rule_data     (fp_rule_data),           
    .fp_rule_valid    (fp_rule_valid),          
    .fp_rule_sop      (fp_rule_sop),  
    .fp_rule_eop      (fp_rule_eop),
    .fp_rule_empty    (fp_rule_empty),  
    .fp_rule_ready    (fp_rule_ready)
);

traffic_manager traffic_manager_inst (
    //clk & rst
    .clk                          (clk),            
    .rst                          (rst),       
    //In pkt data      
    .in_pkt_data                  (pkt_fifo_data),           
    .in_pkt_valid                 (pkt_fifo_valid),          
    .in_pkt_sop                   (pkt_fifo_sop),  
    .in_pkt_eop                   (pkt_fifo_eop),
    .in_pkt_empty                 (pkt_fifo_empty),  
    .in_pkt_ready                 (pkt_fifo_ready),
    //In Meta data      
    .in_meta_data                 (int_meta_data),           
    .in_meta_valid                (int_meta_valid),          
    .in_meta_ready                (int_meta_ready),
    //In User data      
    .in_usr_data                  (fp_rule_data),           
    .in_usr_valid                 (fp_rule_valid),          
    .in_usr_sop                   (fp_rule_sop),  
    .in_usr_eop                   (fp_rule_eop),
    .in_usr_empty                 (fp_rule_empty),  
    .in_usr_ready                 (fp_rule_ready),
    //Out pkt data      
    .out_pkt_data                 (out_pkt_data),           
    .out_pkt_valid                (out_pkt_valid),          
    .out_pkt_sop                  (out_pkt_sop),  
    .out_pkt_eop                  (out_pkt_eop),
    .out_pkt_empty                (out_pkt_empty),  
    .out_pkt_ready                (out_pkt_ready),
    .out_pkt_almost_full          (out_pkt_almost_full),
    .out_pkt_channel              (out_pkt_channel),
    //Out Meta data      
    .out_meta_data                (out_meta_data),           
    .out_meta_valid               (out_meta_valid),          
    .out_meta_ready               (out_meta_ready),
    .out_meta_almost_full         (out_meta_almost_full),
    .out_meta_channel             (out_meta_channel),
    //Out User data      
    .out_usr_data                 (out_usr_data),           
    .out_usr_valid                (out_usr_valid),          
    .out_usr_sop                  (out_usr_sop),  
    .out_usr_eop                  (out_usr_eop),
    .out_usr_empty                (out_usr_empty),  
    .out_usr_ready                (out_usr_ready),
    .out_usr_almost_full          (out_usr_almost_full),
    .out_usr_channel              (out_usr_channel)
);

`endif

endmodule