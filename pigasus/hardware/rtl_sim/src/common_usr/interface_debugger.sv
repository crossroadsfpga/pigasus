`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps
//debug interface
module interface_debugger (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    input   logic           in_pkt_ready,

    // In Meta data
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    input   logic           in_meta_ready,

    // In User data
    input   logic [511:0]   in_usr_data,
    input   logic           in_usr_valid,
    input   logic           in_usr_sop,
    input   logic           in_usr_eop,
    input   logic [5:0]     in_usr_empty,
    input   logic           in_usr_ready,

    // Out Pkt data
    input   logic [511:0]   out_pkt_data,
    input   logic           out_pkt_valid,
    input   logic           out_pkt_sop,
    input   logic           out_pkt_eop,
    input   logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready,
    input   logic           out_pkt_almost_full,
    input   logic [1:0]     out_pkt_channel,

    // Out Meta data
    input   metadata_t      out_meta_data,
    input   logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,
    input   logic           out_meta_channel,

    // Out User data
    input   logic [511:0]   out_usr_data,
    input   logic           out_usr_valid,
    input   logic           out_usr_sop,
    input   logic           out_usr_eop,
    input   logic [5:0]     out_usr_empty,
    input   logic           out_usr_ready,
    input   logic           out_usr_almost_full,
    input   logic [1:0]     out_usr_channel
);

logic [31:0] in_pkt_cnt;
logic [31:0] in_pkt_sop_cnt;
logic [31:0] in_flit_cnt;
logic [31:0] in_meta_cnt;
logic [31:0] in_rule_cnt;
logic [31:0] in_rule_last_cnt;

logic [31:0] out_pkt_cnt;
logic [31:0] out_pkt_sop_cnt;
logic [31:0] out_flit_cnt;
logic [31:0] out_meta_cnt;
logic [31:0] out_rule_cnt;
logic [31:0] out_rule_last_cnt;

always@(posedge clk)begin
    if(rst)begin
        in_pkt_cnt  <= 0;
        in_pkt_sop_cnt <= 0;
        in_flit_cnt <= 0;
        in_meta_cnt <= 0;
        in_rule_cnt <= 0;
        in_rule_last_cnt <= 0;
        out_pkt_cnt  <= 0;
        out_pkt_sop_cnt <= 0;
        out_flit_cnt <= 0;
        out_meta_cnt <= 0;
        out_rule_cnt <= 0;
        out_rule_last_cnt <= 0;
    end else begin
        if(in_pkt_valid & in_pkt_ready)begin
            in_flit_cnt <= in_flit_cnt + 1;
            if(in_pkt_eop)begin
                in_pkt_cnt <= in_pkt_cnt + 1;
            end
            if(in_pkt_sop)begin
                in_pkt_sop_cnt <= in_pkt_sop_cnt + 1;
            end
        end
        if(in_meta_valid & in_meta_ready)begin
            in_meta_cnt <= in_meta_cnt + 1;
        end
        if(in_usr_valid & in_usr_ready)begin
            if(in_usr_eop)begin
                in_rule_last_cnt <= in_rule_last_cnt + 1;
            end else begin
                in_rule_cnt <= in_rule_cnt + 1;
            end
        end
        if(out_pkt_valid & out_pkt_ready)begin
            out_flit_cnt <= out_flit_cnt + 1;
            if(out_pkt_eop)begin
                out_pkt_cnt <= out_pkt_cnt + 1;
            end
            if(out_pkt_sop)begin
                out_pkt_sop_cnt <= out_pkt_sop_cnt + 1;
            end
        end
        if(out_meta_valid & out_meta_ready)begin
            out_meta_cnt <= out_meta_cnt + 1;
        end
        if(out_usr_valid & out_usr_ready)begin
            if(out_usr_eop)begin
                out_rule_last_cnt <= out_rule_last_cnt + 1;
            end else begin
                out_rule_cnt <= out_rule_cnt + 1;
            end
        end
    end
end

endmodule
