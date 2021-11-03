`timescale 1 ps / 1 ps
`include "./src/struct_s.sv"
module bypass_nf_back(
    input   logic           clk,
    input   logic           rst,
    // In Pkt data
    input   logic [511:0]   bypass_pkt_data,
    input   logic           bypass_pkt_valid,
    input   logic           bypass_pkt_sop,
    input   logic           bypass_pkt_eop,
    input   logic [5:0]     bypass_pkt_empty,
    output  logic           bypass_pkt_ready,
    output  logic           bypass_pkt_almost_full,

    // In Meta data
    input   logic           bypass_meta_valid,
    input   metadata_t      bypass_meta_data,
    output  logic           bypass_meta_ready,
    output  logic           bypass_meta_almost_full,

    // In User data
    input   logic           bypass_usr_sop,
    input   logic           bypass_usr_eop,
    input   logic [511:0]   bypass_usr_data,
    input   logic [5:0]     bypass_usr_empty,
    input   logic           bypass_usr_valid,
    output  logic           bypass_usr_ready,
    output  logic           bypass_usr_almost_full,

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
    output  logic           in_usr_almost_full,

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
    output  logic [1:0]     out_usr_channel
);

typedef enum{
    IDLE,
    PUSH_NF,
    BYPASS
} state_t;

state_t state;
logic pkt_done;
logic meta_done;
logic rule_done;
logic prio;

assign in_pkt_ready = !pkt_done &   (state == PUSH_NF);
assign in_meta_ready = !meta_done & (state == PUSH_NF);
assign in_usr_ready = !rule_done &  (state == PUSH_NF);


assign bypass_pkt_ready = !pkt_done &   (state == BYPASS);
assign bypass_meta_ready = !meta_done & (state == BYPASS);
assign bypass_usr_ready = !rule_done &  (state == BYPASS);

always@(posedge clk)begin
    if(rst)begin
        state <= IDLE;
        prio <= 1'b0;
        out_pkt_valid <= 1'b0;
        out_meta_valid <= 1'b0;
        out_usr_valid <= 1'b0;
        pkt_done <= 1'b0;
        meta_done <= 1'b0;
        rule_done <= 1'b0;
    end else begin
        case(state)
            IDLE:begin
                pkt_done <= 1'b0;
                meta_done <= 1'b0;
                rule_done <= 1'b0;
                if (!out_pkt_almost_full)begin
                    //if prio is 1, we select nf pkt first
                    //else we select bypass first
                    if(prio)begin
                        if(in_pkt_valid)begin
                            state <= PUSH_NF;
                        end else if (bypass_pkt_valid)begin
                            state <= BYPASS;
                        end
                    end else begin
                        if(bypass_pkt_valid)begin
                            state <= BYPASS;
                        end else if (in_pkt_valid)begin
                            state <= PUSH_NF;
                        end
                    end
                end
            end
            PUSH_NF:begin
                out_pkt_valid <= 1'b0;
                out_meta_valid <= 1'b0;
                out_usr_valid <= 1'b0;
                out_pkt_sop   <= in_pkt_sop;
                out_pkt_eop   <= in_pkt_eop;
                out_pkt_empty <= in_pkt_empty;
                out_pkt_data  <= in_pkt_data;
                out_meta_data <= in_meta_data;
                out_usr_sop   <= in_usr_sop;
                out_usr_eop   <= in_usr_eop;
                out_usr_empty <= in_usr_empty;
                out_usr_data  <= in_usr_data;
                if(!pkt_done)begin
                    out_pkt_valid <= in_pkt_valid;
                    if(in_pkt_eop & in_pkt_valid)begin
                        pkt_done <= 1'b1;
                    end
                end
                if(!meta_done)begin
                    out_meta_valid <= in_meta_valid;
                    if(in_meta_valid)begin
                        meta_done <= 1'b1;
                    end
                end
                if(!rule_done)begin
                    out_usr_valid <= in_usr_valid;
                    if(in_usr_eop & in_usr_valid)begin
                        rule_done <= 1'b1;
                    end
                end
                if(pkt_done & meta_done & rule_done)begin
                    state <= IDLE;
                    prio <= 1'b1;
                end
            end
            BYPASS:begin
                out_pkt_valid <= 1'b0;
                out_meta_valid <= 1'b0;
                out_usr_valid <= 1'b0;
                out_pkt_sop   <= bypass_pkt_sop;
                out_pkt_eop   <= bypass_pkt_eop;
                out_pkt_empty <= bypass_pkt_empty;
                out_pkt_data  <= bypass_pkt_data;
                out_meta_data <= bypass_meta_data;
                out_usr_sop   <= bypass_usr_sop;
                out_usr_eop   <= bypass_usr_eop;
                out_usr_empty <= bypass_usr_empty;
                out_usr_data  <= bypass_usr_data;
                if(!pkt_done)begin
                    out_pkt_valid <= bypass_pkt_valid;
                    if(bypass_pkt_eop & bypass_pkt_valid)begin
                        pkt_done <= 1'b1;
                    end
                end
                if(!meta_done)begin
                    out_meta_valid <= bypass_meta_valid;
                    if(bypass_meta_valid)begin
                        meta_done <= 1'b1;
                    end
                end
                if(!rule_done)begin
                    out_usr_valid <= bypass_usr_valid;
                    if(bypass_usr_eop & bypass_usr_valid)begin
                        rule_done <= 1'b1;
                    end
                end
                if(pkt_done & meta_done & rule_done)begin
                    state <= IDLE;
                    prio <= 1'b0;
                end
            end

        endcase
    end

end


endmodule
