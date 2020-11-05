`timescale 1 ps / 1 ps
//`define DUMMY
`define DEBUG
`include "./src/struct_s.sv"
module non_fast_pattern(
    input   logic                   clk,
    input   logic                   rst,
    input   logic                   clk_high,
    input   logic                   rst_high,
    input   logic                   in_sop,
    input   logic                   in_eop,
    input   logic [511:0]           in_data,
    input   logic [5:0]             in_empty,
    input   logic                   in_valid,
    output  logic                   in_ready,
    input   logic                   in_rule_sop,
    input   logic                   in_rule_eop,
    input   logic [127:0]           in_rule_data,
    input   logic [3:0]             in_rule_empty,
    input   logic                   in_rule_valid,
    output  logic                   in_rule_ready,
    input   logic                   in_meta_valid,
    input   metadata_t              in_meta_data,
    output  logic                   in_meta_ready,
    output  logic                   out_sop,
    output  logic                   out_eop,
    output  logic [511:0]           out_data,
    output  logic [5:0]             out_empty,
    output  logic                   out_valid,
    input   logic                   out_ready,
    input   logic                   out_almost_full,
    output  logic                   no_check_sop,
    output  logic                   no_check_eop,
    output  logic [511:0]           no_check_data,
    output  logic [5:0]             no_check_empty,
    output  logic                   no_check_valid,
    input   logic                   no_check_ready,
    input   logic                   no_check_almost_full,
    output  logic                   no_check_1_sop,
    output  logic                   no_check_1_eop,
    output  logic [511:0]           no_check_1_data,
    output  logic [5:0]             no_check_1_empty,
    output  logic                   no_check_1_valid,
    input   logic                   no_check_1_ready,
    input   logic                   no_check_1_almost_full,
    output  logic                   out_rule_sop,
    output  logic                   out_rule_eop,
    output  logic [127:0]           out_rule_data,
    output  logic [3:0]             out_rule_empty,
    output  logic                   out_rule_valid,
    input   logic                   out_rule_ready,
    input   logic                   out_rule_almost_full,
    output  logic                   out_meta_valid,
    output  metadata_t              out_meta_data,
    input   logic                   out_meta_ready,
    //stats
    output  logic [31:0]            max_raw_pkt_fifo,
    output  logic [31:0]            max_pkt_fifo,
    output  logic [31:0]            max_rule_fifo,
    input   logic [15:0]            forward_th
);

`ifdef DUMMY
    assign out_sop   = in_sop;
    assign out_eop   = in_eop;
    assign out_data  = in_data;
    assign out_empty = in_empty;
    assign out_valid = in_valid;
    assign in_ready  = out_ready;

    assign no_check_sop   = 0;
    assign no_check_eop   = 0;
    assign no_check_data  = 0;
    assign no_check_empty = 0;
    assign no_check_valid = 0;
    assign no_check_1_sop   = 0;
    assign no_check_1_eop   = 0;
    assign no_check_1_data  = 0;
    assign no_check_1_empty = 0;
    assign no_check_1_valid = 0;

    assign out_rule_sop   = in_rule_sop;
    assign out_rule_eop   = in_rule_eop;
    assign out_rule_data  = in_rule_data[31:0];
    assign out_rule_empty = in_rule_empty;
    assign out_rule_valid = in_rule_valid;
    assign in_rule_ready  = out_rule_ready;
   
    assign out_meta_valid = in_meta_valid;
    assign out_meta_data  = in_meta_data;
    assign in_meta_ready  = out_meta_ready;
`else

typedef enum {
    IDLE,
    RULE,
    NO_CHECK,
    CHECK,
    FORWARD
} state_t;
state_t state;

typedef enum {
    FP_IDLE,
    FP_RULE,
    FP_CHECK,
    FP_MATCH,
    FP_LAST
} fp_state_t;
fp_state_t fp_state;

metadata_t in_meta_data_r;
logic          raw_pkt_sop;
logic          raw_pkt_eop;
logic  [5:0]   raw_pkt_empty;
logic          raw_pkt_valid;
logic [511:0]  raw_pkt_data;
logic          raw_pkt_ready;
logic          raw_pkt_fifo_sop;
logic          raw_pkt_fifo_eop;
logic  [5:0]   raw_pkt_fifo_empty;
logic          raw_pkt_fifo_valid;
logic [511:0]  raw_pkt_fifo_data;
logic          raw_pkt_fifo_ready;
logic [31:0]   raw_pkt_csr_readdata;
logic          raw_pkt_almost_full;

logic          forward_raw_pkt_sop;
logic          forward_raw_pkt_eop;
logic  [5:0]   forward_raw_pkt_empty;
logic          forward_raw_pkt_valid;
logic [511:0]  forward_raw_pkt_data;
logic          forward_raw_pkt_ready;
logic          forward_raw_pkt_fifo_sop;
logic          forward_raw_pkt_fifo_eop;
logic  [5:0]   forward_raw_pkt_fifo_empty;
logic          forward_raw_pkt_fifo_valid;
logic [511:0]  forward_raw_pkt_fifo_data;
logic          forward_raw_pkt_fifo_ready;
logic [31:0]   forward_raw_pkt_csr_readdata;
logic          forward_raw_pkt_almost_full;
logic          arb_pkt_sop;
logic          arb_pkt_eop;
logic  [5:0]   arb_pkt_empty;
logic          arb_pkt_valid;
logic [511:0]  arb_pkt_data;
logic          arb_pkt_ready;
logic          arb_pkt_fifo_sop;
logic          arb_pkt_fifo_eop;
logic  [5:0]   arb_pkt_fifo_empty;
logic          arb_pkt_fifo_valid;
logic [511:0]  arb_pkt_fifo_data;
logic          arb_pkt_fifo_ready;
logic [31:0]   arb_pkt_csr_readdata;
logic          arb_pkt_almost_full;

logic          pkt_sop;
logic          pkt_eop;
logic  [5:0]   pkt_empty;
logic          pkt_valid;
logic [511:0]  pkt_data;
logic          pkt_ready;
logic          pkt_align_sop;
logic          pkt_align_eop;
logic  [5:0]   pkt_align_empty;
logic          pkt_align_valid;
logic [511:0]  pkt_align_data;
logic          pkt_align_ready;
logic          pkt_shift_sop;
logic          pkt_shift_eop;
logic  [5:0]   pkt_shift_empty;
logic          pkt_shift_valid;
logic [511:0]  pkt_shift_data;
logic          pkt_shift_ready;
logic          pkt_fifo_sop;
logic          pkt_fifo_eop;
logic  [5:0]   pkt_fifo_empty;
logic          pkt_fifo_valid;
logic [511:0]  pkt_fifo_data;
logic          pkt_fifo_ready;
logic [31:0]   pkt_csr_readdata;
logic          pkt_almost_full;
logic          rule_sop;
logic          rule_eop;
logic  [3:0]   rule_empty;
logic          rule_valid;
logic [127:0]  rule_data;
logic          rule_ready;
logic          rule_fifo_sop;
logic          rule_fifo_eop;
logic  [3:0]   rule_fifo_empty;
logic          rule_fifo_valid;
logic [127:0]  rule_fifo_data;
logic          rule_fifo_ready;
logic [31:0]   rule_csr_readdata;
logic          rule_almost_full;
logic          forward_rule_sop;
logic          forward_rule_eop;
logic  [3:0]   forward_rule_empty;
logic          forward_rule_valid;
logic [127:0]  forward_rule_data;
logic          forward_rule_ready;
logic          forward_rule_fifo_sop;
logic          forward_rule_fifo_eop;
logic  [3:0]   forward_rule_fifo_empty;
logic          forward_rule_fifo_valid;
logic [127:0]  forward_rule_fifo_data;
logic          forward_rule_fifo_ready;
logic [31:0]   forward_rule_csr_readdata;
logic          forward_rule_almost_full;
logic          arb_rule_sop;
logic          arb_rule_eop;
logic  [1:0]   arb_rule_empty;
logic          arb_rule_valid;
logic [31:0]   arb_rule_data;
logic          arb_rule_ready;
logic          arb_rule_fifo_sop;
logic          arb_rule_fifo_eop;
logic  [1:0]   arb_rule_fifo_empty;
logic          arb_rule_fifo_valid;
logic [31:0]   arb_rule_fifo_data;
logic          arb_rule_fifo_ready;
logic [31:0]   arb_rule_csr_readdata;
logic          arb_rule_almost_full;
logic          rule_packer_sop;
logic          rule_packer_eop;
logic  [3:0]   rule_packer_empty;
logic          rule_packer_valid;
logic [127:0]  rule_packer_data;
logic          rule_packer_ready;
metadata_t     meta_data;
logic          meta_valid;
logic          meta_ready;
metadata_t     meta_fifo_data;
logic          meta_fifo_valid;
logic          meta_fifo_ready;
metadata_t     forward_meta_data;
logic          forward_meta_valid;
logic          forward_meta_ready;
metadata_t     forward_meta_fifo_data;
logic          forward_meta_fifo_valid;
logic          forward_meta_fifo_ready;
metadata_t     arb_meta_data;
logic          arb_meta_valid;
logic          arb_meta_ready;
metadata_t     arb_meta_fifo_data;
logic          arb_meta_fifo_valid;
logic          arb_meta_fifo_ready;

logic          pkt_done;
logic          rule_done;
logic          temp_pkt_ready;

logic          pkt_adapter_sop;
logic          pkt_adapter_eop;
logic  [2:0]   pkt_adapter_empty;
logic          pkt_adapter_valid;
logic [127:0]  pkt_adapter_data;
logic          pkt_adapter_ready;

rule_nf_t      rule_int_data_0;
logic          rule_int_valid_0;
logic          rule_int_ready_0;
rule_nf_t      rule_int_data_1;
logic          rule_int_valid_1;
logic          rule_int_ready_1;

rule_nf_t      rule_out_data_0;
logic          rule_out_valid_0;
logic          rule_out_ready_0;
rule_nf_t      rule_out_data_1;
logic          rule_out_valid_1;
logic          rule_out_ready_1;

logic [FP_WIDTH-1:0]    pkt_fp_data;
logic                   pkt_fp_valid;
logic                   pkt_fp_ready;
logic [FP_WIDTH-1:0]    pkt_fp_fifo_data;
logic                   pkt_fp_fifo_valid;
logic                   pkt_fp_fifo_ready;
logic [31:0]            pkt_fp_csr_readdata;
logic                   pkt_fp_almost_full;
logic                   pkt_fp_almost_full_r1;
logic                   pkt_fp_almost_full_high;
logic [FP_WIDTH-1:0]    fp_0;
logic [FP_WIDTH-1:0]    fp_1;
logic [RULE_AWIDTH-1:0] fp_addr_0;
logic [RULE_AWIDTH-1:0] fp_addr_1;


logic                   rule_fp_rd_0;
logic                   rule_fp_rd_r_0;
logic                   rule_fp_rd_valid_0;
logic [FP_WIDTH-1:0]    rule_fp_data_0;
logic [RULE_AWIDTH-1:0] rule_latch_0;
logic                   rule_fp_rd_1;
logic                   rule_fp_rd_r_1;
logic                   rule_fp_rd_valid_1;
logic [FP_WIDTH-1:0]    rule_fp_data_1;
logic [RULE_AWIDTH-1:0] rule_latch_1;

logic                   has_match;
logic                   has_match_0;
logic                   has_match_1;
logic                   match_0;
logic                   match_1;

logic [8:0]  pkt_hdr;
logic [55:0] last_7_bytes;
logic [55:0] last_7_bytes_r;
logic [7:0]  prot;
logic [7:0]  prot_r;

logic [15:0]  forward_th_r1;
logic [15:0]  forward_th_r2;

logic forward;
logic forward_busy;
logic fp_fsm_busy;

`ifdef DEBUG
logic [15:0] raw_pkt_in_cnt;
logic [15:0] raw_pkt_out_cnt;
logic [15:0] pkt_fp_in_cnt;
logic [15:0] pkt_fp_out_cnt;
logic [15:0] rule_input_cnt;
logic [15:0] rule_in_cnt;
logic [15:0] rule_out_cnt;
logic [15:0] meta_in_cnt;
logic [15:0] meta_out_cnt;

`endif

//Stats
always @(posedge clk) begin
    forward_th_r1 <= forward_th;
    forward_th_r2 <= forward_th_r1;
end

always @(posedge clk) begin
    if (rst) begin
        max_raw_pkt_fifo <= 0;
        max_pkt_fifo <= 0;
        max_rule_fifo <= 0;
    end else begin
        if(max_raw_pkt_fifo < raw_pkt_csr_readdata)begin
            max_raw_pkt_fifo <= raw_pkt_csr_readdata;
        end
        if(max_pkt_fifo < pkt_csr_readdata)begin
            max_pkt_fifo <= pkt_csr_readdata;
        end
        if(max_rule_fifo < rule_csr_readdata)begin
            max_rule_fifo <= rule_csr_readdata;
        end
    end
end


assign in_ready = (state == NO_CHECK) | temp_pkt_ready;

assign forward_busy = forward_raw_pkt_almost_full | forward_rule_almost_full;
assign fp_fsm_busy  = pkt_almost_full | rule_almost_full | raw_pkt_almost_full | pkt_fp_almost_full;
//Logic to decide which packet should be forwarded
always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
        in_meta_ready <= 0;
        in_rule_ready <= 0;
        no_check_valid <= 0;
        rule_done <= 0;
        pkt_done <= 0;
        rule_valid <= 0;
        pkt_valid  <= 0;
        raw_pkt_valid  <= 0;
        meta_valid <= 0;
        temp_pkt_ready <= 0;
        pkt_hdr <= 0;
        last_7_bytes <= 0;
        prot <= NS;
        forward <= 0;
        forward_rule_valid <= 0;
        forward_raw_pkt_valid  <= 0;
        forward_meta_valid <= 0;
    end else begin
        case (state)
            IDLE: begin
                in_meta_ready <= 0;
                in_rule_ready <= 0;
                no_check_valid <= 0;
                rule_done <= 0;
                pkt_done <= 0;
                meta_valid <= 0;
                pkt_hdr <= 0;
                forward <= 0;
                forward_rule_valid <= 0;
                forward_raw_pkt_valid  <= 0;
                forward_meta_valid <= 0;

                if (in_meta_valid & !no_check_almost_full) begin
                    //forward
                    if(raw_pkt_csr_readdata >= forward_th_r2)begin
                        if(!forward_busy)begin
                            forward <= 1;
                            state <= RULE;
                            in_meta_ready <= 1;
                            in_meta_data_r <= in_meta_data;
                        end
                    end else begin
                        if(!fp_fsm_busy)begin
                            state <= RULE;
                            in_meta_ready <= 1;
                            in_meta_data_r <= in_meta_data;
                        end
                    end
                end
            end
            RULE: begin
                //deq in_meta data
                in_meta_ready <= 0;
                if(in_rule_valid) begin
                    if (in_rule_eop) begin
                        state <= NO_CHECK;
                        in_rule_ready <= 1;
                    end else if (forward)begin
                        state <= FORWARD;
                        in_rule_ready <= 1;
                        temp_pkt_ready <= 1;
                    end else begin
                        state <= CHECK;
                        in_rule_ready <= 1;
                        temp_pkt_ready <= 1;
                    end
                end
            end
            NO_CHECK: begin
                //only deq one element
                in_rule_ready <= 0;
                no_check_valid <= in_valid & in_ready;
                if(in_valid & in_eop)begin
                    state <= IDLE;
                end
            end
            CHECK: begin
                rule_valid <= 0;
                pkt_valid  <= 0;
                raw_pkt_valid  <= 0;
                if(in_rule_ready & in_rule_valid)begin
                    rule_valid <= 1;
                    rule_eop <= in_rule_eop;
                    //stop fetching rule
                    if(in_rule_eop)begin
                        in_rule_ready <= 0;
                        rule_done <= 1;
                    end
                end

                if(in_valid & temp_pkt_ready)begin
                    pkt_valid <= 1;
                    pkt_hdr <= in_meta_data_r.hdr_len;
                    last_7_bytes <= in_meta_data_r.last_7_bytes;
                    prot <= in_meta_data_r.prot;
                    raw_pkt_valid <= 1;
                    if(in_eop)begin
                        temp_pkt_ready <= 0;
                        pkt_done <= 1;
                    end
                end
                if(rule_done & pkt_done)begin
                    state <= IDLE;
                    meta_valid <= 1;
                    meta_data <= in_meta_data_r;
                end
            end
            FORWARD: begin
                forward_rule_valid <= 0;
                forward_raw_pkt_valid  <= 0;
                if(in_rule_ready & in_rule_valid)begin
                    forward_rule_valid <= 1;
                    forward_rule_eop <= in_rule_eop;
                    //stop fetching rule
                    if(in_rule_eop)begin
                        in_rule_ready <= 0;
                        rule_done <= 1;
                    end
                end

                if(in_valid & temp_pkt_ready)begin
                    forward_raw_pkt_valid <= 1;
                    if(in_eop)begin
                        temp_pkt_ready <= 0;
                        pkt_done <= 1;
                    end
                end
                if(rule_done & pkt_done)begin
                    state <= IDLE;
                    forward_meta_valid <= 1;
                    forward_meta_data <= in_meta_data_r;
                end
            end
        endcase
    end

    //move wide data signals outside of rst
    no_check_sop   <= in_sop;
    no_check_eop   <= in_eop;
    no_check_empty <= in_empty;
    no_check_data  <= in_data;

    raw_pkt_sop   <= in_sop;
    raw_pkt_eop   <= in_eop;
    raw_pkt_empty <= in_empty;
    raw_pkt_data  <= in_data;

    pkt_sop   <= in_sop;
    pkt_eop   <= in_eop;
    pkt_empty <= in_empty;
    pkt_data  <= in_data;
    //rule
    rule_sop   <= 0;
    rule_empty <= 0;
    rule_data  <= in_rule_data;

    last_7_bytes_r <= last_7_bytes;
    prot_r <= prot;


    //forward
    forward_raw_pkt_sop   <= in_sop;
    forward_raw_pkt_eop   <= in_eop;
    forward_raw_pkt_empty <= in_empty;
    forward_raw_pkt_data  <= in_data;
    forward_rule_sop   <= 0;
    forward_rule_empty <= 0;
    forward_rule_data  <= in_rule_data;

end

//rule_fp read
always @(posedge clk) begin
    rule_fp_rd_r_0 <= rule_fp_rd_0;
    rule_fp_rd_valid_0 <= rule_fp_rd_r_0;
    rule_fp_rd_r_1 <= rule_fp_rd_1;
    rule_fp_rd_valid_1 <= rule_fp_rd_r_1;
end

//Check fingerprint
always @(posedge clk) begin
    if (rst) begin
        fp_state <= FP_IDLE;
        rule_out_ready_0 <= 0;
        rule_out_ready_1 <= 0;
        rule_fp_rd_0 <= 0;
        rule_fp_rd_1 <= 0;
        fp_addr_0 <= 0;
        fp_addr_1 <= 0;
        has_match_0 <= 0;
        has_match_1 <= 0;
        arb_rule_valid <= 0;
        arb_rule_eop <= 0;
        arb_rule_data <= 0;
        rule_latch_0 <= 0;
        rule_latch_1 <= 0;
        pkt_fp_fifo_ready <= 0;
        raw_pkt_fifo_ready <= 0;
        arb_pkt_valid <= 0;
        no_check_1_valid <= 0;
        arb_meta_valid <= 0;
        meta_fifo_ready <= 0;
        has_match <= 0;
    end else begin
        case (fp_state)
            FP_IDLE: begin
                rule_out_ready_0 <= 0;
                rule_out_ready_1 <= 0;
                rule_fp_rd_0 <= 0;
                rule_fp_rd_1 <= 0;
                arb_rule_valid <= 0;
                arb_rule_eop <= 0;
                pkt_fp_fifo_ready <= 0;
                raw_pkt_fifo_ready <= 0;
                arb_pkt_valid <= 0;
                no_check_1_valid <= 0;
                arb_meta_valid <= 0;
                meta_fifo_ready <= 0;

                //only start processing when meta_fifo has data,
                //pkt_fp fifo has data, rule_out is valid
                //And downstream are not almost_full. 
                if(meta_fifo_valid & pkt_fp_fifo_valid & 
                   !arb_pkt_almost_full & !no_check_1_almost_full &
                   !arb_rule_almost_full)begin
                    if(rule_out_valid_0 | rule_out_valid_1)begin
                        //The last
                        if (rule_out_valid_0 & rule_out_data_0.last &
                            rule_out_valid_1 & rule_out_data_1.last) begin
                            fp_state <= FP_LAST;
                            raw_pkt_fifo_ready <= 1;
                            //deq rule_fifo here, as the next IDLE state 
                            //assumes the rule is already dequeued
                            rule_out_ready_0 <= 1;
                            rule_out_ready_1 <= 1;
                            //deq pkt_fp_fifo
                            pkt_fp_fifo_ready <= 1;

                        end else begin
                            fp_state <= FP_RULE;
                            rule_out_ready_0 <= rule_out_valid_0 & !rule_out_data_0.last;
                            rule_out_ready_1 <= rule_out_valid_1 & !rule_out_data_1.last;
                            rule_fp_rd_0 <= rule_out_valid_0;
                            rule_fp_rd_1 <= rule_out_valid_1;
                            //Rule 0 is considered invalid. Rule starts from 1.
                            fp_addr_0 <= rule_out_data_0.data - 1;
                            fp_addr_1 <= rule_out_data_1.data - 1;
                            rule_latch_0 <= rule_out_data_0.data;
                            rule_latch_1 <= rule_out_data_1.data;
                        end
                    end
                end
            end
            //read rule fp
            FP_RULE: begin
                rule_out_ready_0 <= 0;
                rule_out_ready_1 <= 0;
                rule_fp_rd_0 <= 0;
                rule_fp_rd_1 <= 0;
                //initilization is important
                rule_fp_data_0 <= 0;
                rule_fp_data_1 <= 0;
                if(rule_fp_rd_valid_0)begin
                    rule_fp_data_0 <= fp_0;
                end
                if(rule_fp_rd_valid_1)begin
                    rule_fp_data_1 <= fp_1;
                end

                if(rule_fp_rd_valid_0 | rule_fp_rd_valid_1)begin
                    fp_state <= FP_CHECK;
                end
            end
            //check whether the rule_fp is a subset of pkt_fp
            FP_CHECK: begin
                has_match_0 <= 0;
                has_match_1 <= 0;
                if(pkt_fp_fifo_valid)begin
                    if(match_0)begin
                        has_match_0 <= 1;
                    end
                    if(match_1)begin
                        has_match_1 <= 1;
                    end
                    
                    //one is a match
                    if(match_0 | match_1) begin
                        fp_state <= FP_MATCH;
                    end else begin
                        fp_state <= FP_IDLE;
                    end
                end
            end
            //push rule into rule FIFO
            FP_MATCH: begin
                arb_rule_valid <= 1;
                if(has_match_0)begin
                    arb_rule_data[15:0] <= rule_latch_0;
                end else begin
                    arb_rule_data[15:0] <= 0;
                end
                if(has_match_1)begin
                    arb_rule_data[31:16] <= rule_latch_1;
                end else begin
                    arb_rule_data[31:16] <= 0;
                end
                fp_state <= FP_IDLE;
                has_match <= 1; // At least one rule match in the packet.
            end
            //push pkt into pkt FIFO; clean up
            FP_LAST: begin
                arb_pkt_valid <= 0;
                no_check_1_valid <= 0;
                arb_rule_valid <= 0;
                rule_out_ready_0 <= 0;
                rule_out_ready_1 <= 0;
                //deq pkt_fp_fifo
                pkt_fp_fifo_ready <= 0;

                //push when the raw pkt_fifo has data
                if(raw_pkt_fifo_valid & raw_pkt_fifo_ready)begin
                    //last flit
                    if(raw_pkt_fifo_eop)begin
                        //insert last rule when the packet has match. 
                        if(has_match)begin
                            arb_rule_valid <= 1;
                        end
                        arb_rule_data <= 0;
                        arb_rule_eop  <= 1;
                        fp_state <= FP_IDLE;
                        raw_pkt_fifo_ready <= 0;

                        //clear has_match
                        has_match <= 0;
                        //push to out_meta
                        arb_meta_valid <= 1;
                        meta_fifo_ready <= 1;
                    end
                   
                    //if has match, push to PCIe
                    //else no check     
                    if(has_match)begin
                        arb_pkt_valid <= 1;
                    end else begin
                        no_check_1_valid <= 1;
                    end
                end
            end
        endcase
    end

    arb_pkt_sop   <= raw_pkt_fifo_sop;
    arb_pkt_eop   <= raw_pkt_fifo_eop;
    arb_pkt_empty <= raw_pkt_fifo_empty;
    arb_pkt_data  <= raw_pkt_fifo_data;

    no_check_1_sop   <= raw_pkt_fifo_sop;
    no_check_1_eop   <= raw_pkt_fifo_eop;
    no_check_1_empty <= raw_pkt_fifo_empty;
    no_check_1_data  <= raw_pkt_fifo_data;

    arb_meta_data <= meta_fifo_data;
end

//rule_fp is a subset of pkt_fp_fifo_data
assign match_0 = ((pkt_fp_fifo_data & rule_fp_data_0) == rule_fp_data_0) 
                 & (rule_fp_data_0!=0);
assign match_1 = ((pkt_fp_fifo_data & rule_fp_data_1) == rule_fp_data_1)
                 & (rule_fp_data_1!=0);


//cross clock domain
always @(posedge clk) begin
    pkt_fp_almost_full_r1 <= pkt_fp_almost_full_high;
    pkt_fp_almost_full    <= pkt_fp_almost_full_r1;
end

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(4096),
    .USE_PACKETS(1)
)
raw_pkt_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (raw_pkt_csr_readdata),
    .csr_writedata     (0),
    .in_data           (raw_pkt_data),
    .in_valid          (raw_pkt_valid),
    .in_ready          (raw_pkt_ready), // Use almost full
    .in_startofpacket  (raw_pkt_sop),
    .in_endofpacket    (raw_pkt_eop),
    .in_empty          (raw_pkt_empty),
    .out_data          (raw_pkt_fifo_data),
    .out_valid         (raw_pkt_fifo_valid),
    .out_ready         (raw_pkt_fifo_ready),
    .out_startofpacket (raw_pkt_fifo_sop),
    .out_endofpacket   (raw_pkt_fifo_eop),
    .out_empty         (raw_pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(4020)
)
bp_raw_pkt_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (raw_pkt_csr_readdata),
    .csr_writedata  (),
    .almost_full    (raw_pkt_almost_full)
);


//Fully pipelined
data_align data_align_inst (
    .clk            (clk),
    .rst            (rst),
    .in_pkt_hdr     (pkt_hdr),
    .in_pkt_sop     (pkt_sop),
    .in_pkt_eop     (pkt_eop),
    .in_pkt_valid   (pkt_valid),
    .in_pkt_data    (pkt_data),
    .in_pkt_empty   (pkt_empty),
    .in_pkt_ready   (pkt_ready),                  
    .out_pkt_sop    (pkt_align_sop),
    .out_pkt_eop    (pkt_align_eop),
    .out_pkt_valid  (pkt_align_valid),
    .out_pkt_data   (pkt_align_data),
    .out_pkt_empty  (pkt_align_empty),
    .out_pkt_ready  (1'b1)               
);

//Fully pipelined
data_shift_512 data_shift_inst (
    .clk            (clk),
    .rst            (rst),
    .in_pkt_sop     (pkt_align_sop),
    .in_pkt_eop     (pkt_align_eop),
    .in_pkt_valid   (pkt_align_valid),
    .in_pkt_data    (pkt_align_data),
    .in_pkt_empty   (pkt_align_empty),
    .in_pkt_ready   (pkt_align_ready),
    .last_7_bytes   (last_7_bytes_r),
    .prot           (prot_r),
    .out_pkt_sop    (pkt_shift_sop),
    .out_pkt_eop    (pkt_shift_eop),
    .out_pkt_valid  (pkt_shift_valid),
    .out_pkt_data   (pkt_shift_data),
    .out_pkt_empty  (pkt_shift_empty),
    .out_pkt_ready  (1'b1)
);



dc_fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(4096),
    .USE_PACKETS(1)
)
pkt_fifo (
    .in_clk            (clk),
    .in_reset_n        (!rst),
    .out_clk           (clk_high),
    .out_reset_n       (!rst_high),
    .in_csr_address    (0),
    .in_csr_read       (1'b1),
    .in_csr_write      (1'b0),
    .in_csr_readdata   (pkt_csr_readdata),
    .in_csr_writedata  (0),
    .in_data           (pkt_shift_data),
    .in_valid          (pkt_shift_valid),
    .in_ready          (pkt_shift_ready),
    .in_startofpacket  (pkt_shift_sop),
    .in_endofpacket    (pkt_shift_eop),
    .in_empty          (pkt_shift_empty),
    .out_data          (pkt_fifo_data),
    .out_valid         (pkt_fifo_valid),
    .out_ready         (pkt_fifo_ready),
    .out_startofpacket (pkt_fifo_sop),
    .out_endofpacket   (pkt_fifo_eop),
    .out_empty         (pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(4020)
)
bp_pkt_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (pkt_csr_readdata),
    .csr_writedata  (),
    .almost_full    (pkt_almost_full)
);


st_adapter_512_128 adapter (
    .clk               (clk_high),
    .reset_n           (!rst_high),
    .in_data           (pkt_fifo_data),
    .in_valid          (pkt_fifo_valid),
    .in_ready          (pkt_fifo_ready),
    .in_startofpacket  (pkt_fifo_sop),
    .in_endofpacket    (pkt_fifo_eop),
    .in_empty          (pkt_fifo_empty),
    .out_data          (pkt_adapter_data),
    .out_valid         (pkt_adapter_valid),
    .out_ready         (pkt_adapter_ready),
    .out_startofpacket (pkt_adapter_sop),
    .out_endofpacket   (pkt_adapter_eop),
    .out_empty         (pkt_adapter_empty)
);


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


dc_fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(FP_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
pkt_fp_fifo (
    .in_clk            (clk_high),
    .in_reset_n        (!rst_high),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_csr_address    (0),
    .in_csr_read       (1'b1),
    .in_csr_write      (1'b1),
    .in_csr_readdata   (pkt_fp_csr_readdata),
    .in_csr_writedata  (0),
    .in_data           (pkt_fp_data),
    .in_valid          (pkt_fp_valid),
    .in_ready          (pkt_fp_ready),
    .in_startofpacket  (1'b0),
    .in_endofpacket    (1'b0),
    .in_empty          (6'b0),
    .out_data          (pkt_fp_fifo_data),
    .out_valid         (pkt_fp_fifo_valid),
    .out_ready         (pkt_fp_fifo_ready),
    .out_startofpacket (),
    .out_endofpacket   (),
    .out_empty         ()
);



dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_pkt_fp_fifo (
    .clk            (clk_high),
    .rst            (!rst_high),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (pkt_fp_csr_readdata),
    .csr_writedata  (),
    .almost_full    (pkt_fp_almost_full_high)
);

dc_fifo_wrapper_infill #(
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(1024),
    .USE_PACKETS(1)
)
rule_fifo (
    .in_clk            (clk),
    .in_reset_n        (!rst),
    .out_clk           (clk_high),
    .out_reset_n       (!rst_high),
    .in_csr_address    (0),
    .in_csr_read       (1'b1),
    .in_csr_write      (1'b0),
    .in_csr_readdata   (rule_csr_readdata),
    .in_csr_writedata  (0),
    .in_data           (rule_data),
    .in_valid          (rule_valid),
    .in_ready          (rule_ready),
    .in_startofpacket  (rule_sop),
    .in_endofpacket    (rule_eop),
    .in_empty          (rule_empty),
    .out_data          (rule_fifo_data),
    .out_valid         (rule_fifo_valid),
    .out_ready         (rule_fifo_ready),
    .out_startofpacket (rule_fifo_sop),
    .out_endofpacket   (rule_fifo_eop),
    .out_empty         (rule_fifo_empty)
);


dc_back_pressure #(
    .FULL_LEVEL(950)
)
bp_rule_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (rule_csr_readdata),
    .csr_writedata  (),
    .almost_full    (rule_almost_full)
);


//The rule_out fifo is inside the reduction logic
rule_reduction rule_reduction_inst(
    .clk              (clk_high),
    .rst              (rst_high),
    .rule_data        (rule_fifo_data),
    .rule_valid       (rule_fifo_valid),
    .rule_eop         (rule_fifo_eop),
    .rule_ready       (rule_fifo_ready),
    .rule_out_data_0  (rule_int_data_0),
    .rule_out_valid_0 (rule_int_valid_0),
    .rule_out_ready_0 (rule_int_ready_0),
    .rule_out_data_1  (rule_int_data_1),
    .rule_out_valid_1 (rule_int_valid_1),
    .rule_out_ready_1 (rule_int_ready_1)
);    

dc_fifo_wrapper_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(64),
    .USE_PACKETS(0)
)
rule_out_fifo_0 (
    .in_clk            (clk_high),
    .in_reset_n        (!rst_high),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_data           (rule_int_data_0),
    .in_valid          (rule_int_valid_0),
    .in_ready          (rule_int_ready_0),
    .in_startofpacket  (1'b0),
    .in_endofpacket    (1'b0),
    .in_empty          (0),
    .out_data          (rule_out_data_0),
    .out_valid         (rule_out_valid_0),
    .out_ready         (rule_out_ready_0),
    .out_startofpacket (),
    .out_endofpacket   (),
    .out_empty         ()
);

dc_fifo_wrapper_mlab #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(RULE_NF_WIDTH),
    .FIFO_DEPTH(64),
    .USE_PACKETS(0)
)
rule_out_fifo_1 (
    .in_clk            (clk_high),
    .in_reset_n        (!rst_high),
    .out_clk           (clk),
    .out_reset_n       (!rst),
    .in_data           (rule_int_data_1),
    .in_valid          (rule_int_valid_1),
    .in_ready          (rule_int_ready_1),
    .in_startofpacket  (1'b0),
    .in_endofpacket    (1'b0),
    .in_empty          (0),
    .out_data          (rule_out_data_1),
    .out_valid         (rule_out_valid_1),
    .out_ready         (rule_out_ready_1),
    .out_startofpacket (),
    .out_endofpacket   (),
    .out_empty         ()
);

fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
meta_fifo (
    .clk               (clk),
    .reset             (rst),
    .in_data           (meta_data),
    .in_valid          (meta_valid),
    .in_ready          (meta_ready), // Use almost full
    .out_data          (meta_fifo_data),
    .out_valid         (meta_fifo_valid),
    .out_ready         (meta_fifo_ready)
);


rom_2port #(
    .DWIDTH(FP_WIDTH),
    .AWIDTH(RULE_AWIDTH),
    .MEM_SIZE(RULE_DEPTH),
    .INIT_FILE("./src/memory_init/rule_fp.mif")
)
rom_2port_inst (
    .q_a       (fp_0),    
    .q_b       (fp_1),    
    .address_a (fp_addr_0),
    .address_b (fp_addr_1),
    .clock     (clk)   
);

//forward case
fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
forward_raw_pkt_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (forward_raw_pkt_csr_readdata),
    .csr_writedata     (0),
    .in_data           (forward_raw_pkt_data),
    .in_valid          (forward_raw_pkt_valid),
    .in_ready          (forward_raw_pkt_ready), // Use almost full
    .in_startofpacket  (forward_raw_pkt_sop),
    .in_endofpacket    (forward_raw_pkt_eop),
    .in_empty          (forward_raw_pkt_empty),
    .out_data          (forward_raw_pkt_fifo_data),
    .out_valid         (forward_raw_pkt_fifo_valid),
    .out_ready         (forward_raw_pkt_fifo_ready),
    .out_startofpacket (forward_raw_pkt_fifo_sop),
    .out_endofpacket   (forward_raw_pkt_fifo_eop),
    .out_empty         (forward_raw_pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_forward_raw_pkt_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (forward_raw_pkt_csr_readdata),
    .csr_writedata  (),
    .almost_full    (forward_raw_pkt_almost_full)
);

fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
forward_meta_fifo (
    .clk               (clk),
    .reset             (rst),
    .in_data           (forward_meta_data),
    .in_valid          (forward_meta_valid),
    .in_ready          (forward_meta_ready), // Use almost full
    .out_data          (forward_meta_fifo_data),
    .out_valid         (forward_meta_fifo_valid),
    .out_ready         (forward_meta_fifo_ready)
);

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(16),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
forward_rule_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1'b1),
    .csr_write         (1'b0),
    .csr_readdata      (forward_rule_csr_readdata),
    .csr_writedata     (0),
    .in_data           (forward_rule_data),
    .in_valid          (forward_rule_valid),
    .in_ready          (forward_rule_ready),
    .in_startofpacket  (forward_rule_sop),
    .in_endofpacket    (forward_rule_eop),
    .in_empty          (forward_rule_empty),
    .out_data          (forward_rule_fifo_data),
    .out_valid         (forward_rule_fifo_valid),
    .out_ready         (forward_rule_fifo_ready),
    .out_startofpacket (forward_rule_fifo_sop),
    .out_endofpacket   (forward_rule_fifo_eop),
    .out_empty         (forward_rule_fifo_empty)
);


dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_forward_rule_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (forward_rule_csr_readdata),
    .csr_writedata  (),
    .almost_full    (forward_rule_almost_full)
);


//Arb
fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(64),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
arb_pkt_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (arb_pkt_csr_readdata),
    .csr_writedata     (0),
    .in_data           (arb_pkt_data),
    .in_valid          (arb_pkt_valid),
    .in_ready          (arb_pkt_ready), // Use almost full
    .in_startofpacket  (arb_pkt_sop),
    .in_endofpacket    (arb_pkt_eop),
    .in_empty          (arb_pkt_empty),
    .out_data          (arb_pkt_fifo_data),
    .out_valid         (arb_pkt_fifo_valid),
    .out_ready         (arb_pkt_fifo_ready),
    .out_startofpacket (arb_pkt_fifo_sop),
    .out_endofpacket   (arb_pkt_fifo_eop),
    .out_empty         (arb_pkt_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_arb_pkt_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (arb_pkt_csr_readdata),
    .csr_writedata  (),
    .almost_full    (arb_pkt_almost_full)
);

st_multiplexer_pkt multiplexer_pkt (
    .clk               (clk),
    .reset_n           (!rst),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (out_ready),
    .out_startofpacket (out_sop),
    .out_endofpacket   (out_eop),
    .out_empty         (out_empty),
    .out_channel       (),
    .in0_data          (forward_raw_pkt_fifo_data),
    .in0_valid         (forward_raw_pkt_fifo_valid),
    .in0_ready         (forward_raw_pkt_fifo_ready),
    .in0_startofpacket (forward_raw_pkt_fifo_sop),
    .in0_endofpacket   (forward_raw_pkt_fifo_eop),
    .in0_empty         (forward_raw_pkt_fifo_empty),
    .in1_data          (arb_pkt_fifo_data),
    .in1_valid         (arb_pkt_fifo_valid),
    .in1_ready         (arb_pkt_fifo_ready),
    .in1_startofpacket (arb_pkt_fifo_sop),
    .in1_endofpacket   (arb_pkt_fifo_eop),
    .in1_empty         (arb_pkt_fifo_empty)
);

fifo_wrapper #(
    .SYMBOLS_PER_BEAT(1),
    .BITS_PER_SYMBOL(META_WIDTH),
    .FIFO_DEPTH(512),
    .USE_PACKETS(0)
)
arb_meta_fifo (
    .clk               (clk),
    .reset             (rst),
    .in_data           (arb_meta_data),
    .in_valid          (arb_meta_valid),
    .in_ready          (arb_meta_ready), // Use almost full
    .out_data          (arb_meta_fifo_data),
    .out_valid         (arb_meta_fifo_valid),
    .out_ready         (arb_meta_fifo_ready)
);

st_multiplexer #(
    .DWIDTH(META_WIDTH)
)
multiplexer_meta(
    .out_channel       (),
    .out_valid         (out_meta_valid),
    .out_ready         (out_meta_ready),
    .out_data          (out_meta_data),
    .in0_valid         (forward_meta_fifo_valid),
    .in0_ready         (forward_meta_fifo_ready),
    .in0_data          (forward_meta_fifo_data),
    .in1_valid         (arb_meta_fifo_valid),
    .in1_ready         (arb_meta_fifo_ready),
    .in1_data          (arb_meta_fifo_data),
    .clk               (clk),
    .reset_n           (!rst)
);

fifo_pkt_wrapper_infill #(
    .SYMBOLS_PER_BEAT(4),
    .BITS_PER_SYMBOL(8),
    .FIFO_DEPTH(512),
    .USE_PACKETS(1)
)
arb_rule_fifo (
    .clk               (clk),
    .reset             (rst),
    .csr_address       (0),
    .csr_read          (1),
    .csr_write         (0),
    .csr_readdata      (arb_rule_csr_readdata),
    .csr_writedata     (0),
    .in_data           (arb_rule_data),
    .in_valid          (arb_rule_valid),
    .in_ready          (arb_rule_ready), // Use almost full
    .in_startofpacket  (arb_rule_sop),
    .in_endofpacket    (arb_rule_eop),
    .in_empty          (arb_rule_empty),
    .out_data          (arb_rule_fifo_data),
    .out_valid         (arb_rule_fifo_valid),
    .out_ready         (arb_rule_fifo_ready),
    .out_startofpacket (arb_rule_fifo_sop),
    .out_endofpacket   (arb_rule_fifo_eop),
    .out_empty         (arb_rule_fifo_empty)
);

dc_back_pressure #(
    .FULL_LEVEL(450)
)
bp_nf_rule_fifo (
    .clk            (clk),
    .rst            (rst),
    .csr_address    (),
    .csr_read       (),
    .csr_write      (),
    .csr_readdata   (arb_rule_csr_readdata),
    .csr_writedata  (),
    .almost_full    (arb_rule_almost_full)
);


rule_packer_32_128 rule_packer_inst(
    .clk            (clk),
    .rst            (rst),
    .in_rule_data   (arb_rule_fifo_data),
    .in_rule_valid  (arb_rule_fifo_valid),
    .in_rule_ready  (arb_rule_fifo_ready), // Use almost full
    .in_rule_sop    (arb_rule_fifo_sop),
    .in_rule_eop    (arb_rule_fifo_eop),
    .in_rule_empty  (arb_rule_fifo_empty),
    .out_rule_data  (rule_packer_data),
    .out_rule_valid (rule_packer_valid),
    .out_rule_ready (rule_packer_ready),
    .out_rule_sop   (rule_packer_sop),
    .out_rule_eop   (rule_packer_eop),
    .out_rule_empty (rule_packer_empty)
);

rule_multiplexer multiplexer_rule (
    .clk               (clk),
    .reset_n           (!rst),
    .out_data          (out_rule_data),
    .out_valid         (out_rule_valid),
    .out_ready         (out_rule_ready),
    .out_startofpacket (out_rule_sop),
    .out_endofpacket   (out_rule_eop),
    .out_empty         (out_rule_empty),
    .out_channel       (),
    .in0_data          (forward_rule_fifo_data),
    .in0_valid         (forward_rule_fifo_valid),
    .in0_ready         (forward_rule_fifo_ready),
    .in0_startofpacket (1'b0),
    .in0_endofpacket   (forward_rule_fifo_eop),
    .in0_empty         (4'b0),
    .in1_data          (rule_packer_data),
    .in1_valid         (rule_packer_valid),
    .in1_ready         (rule_packer_ready),
    .in1_startofpacket (1'b0),
    .in1_endofpacket   (rule_packer_eop),
    .in1_empty         (4'b0)
);

`ifdef DEBUG
always @(posedge clk) begin
    if (rst) begin
        raw_pkt_in_cnt <= 0;
        raw_pkt_out_cnt <= 0;
        meta_in_cnt <= 0;
        meta_out_cnt <= 0;
        pkt_fp_out_cnt <= 0;
        rule_input_cnt <= 0;
        rule_in_cnt <= 0;
        rule_out_cnt <= 0;
    end else begin
        if(raw_pkt_valid & raw_pkt_ready & raw_pkt_eop)begin
            raw_pkt_in_cnt <= raw_pkt_in_cnt + 1;
        end
        if(raw_pkt_fifo_valid & raw_pkt_fifo_ready & raw_pkt_fifo_eop)begin
            raw_pkt_out_cnt <= raw_pkt_out_cnt + 1;
        end
        if(meta_valid & meta_ready)begin
            meta_in_cnt <= meta_in_cnt + 1;
        end
        if(meta_fifo_valid & meta_fifo_ready)begin
            meta_out_cnt <= meta_out_cnt + 1;
        end
        if(pkt_fp_fifo_valid & pkt_fp_fifo_ready)begin
            pkt_fp_out_cnt <= pkt_fp_out_cnt + 1;
        end
        if(rule_valid & rule_ready & rule_eop)begin
            rule_input_cnt <= rule_input_cnt + 1;
        end
        if(rule_fifo_valid & rule_fifo_ready & rule_fifo_eop)begin
            rule_in_cnt <= rule_in_cnt + 1;
        end
        if(rule_out_valid_0 & rule_out_ready_0 & rule_out_data_0.last & 
           rule_out_valid_1 & rule_out_ready_1 & rule_out_data_1.last)begin
            rule_out_cnt <= rule_out_cnt + 1;
        end
    end
end

always @(posedge clk_high) begin
    if (rst_high) begin
        pkt_fp_in_cnt <= 0;
    end else begin
        if(pkt_fp_valid & pkt_fp_ready)begin
            pkt_fp_in_cnt <= pkt_fp_in_cnt + 1;
        end
    end
end
`endif


`endif


endmodule
