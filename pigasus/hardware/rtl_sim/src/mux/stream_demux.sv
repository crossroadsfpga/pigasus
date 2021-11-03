`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

module stream_demux (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // in
    input   logic [511:0]   in_data,
    input   logic           in_valid,
    input   logic           in_sop,
    input   logic           in_eop,
    input   logic [5:0]     in_empty,
    output  logic           in_ready,

    // out Pkt data
    output  logic [511:0]   out_pkt_data,
    output  logic           out_pkt_valid,
    output  logic           out_pkt_sop,
    output  logic           out_pkt_eop,
    output  logic [5:0]     out_pkt_empty,
    input   logic           out_pkt_ready,
    input   logic           out_pkt_almost_full,

    // Out Meta data
    output  metadata_t      out_meta_data,
    output  logic           out_meta_valid,
    input   logic           out_meta_ready,
    input   logic           out_meta_almost_full,

    // Out User data
    output  logic [511:0]   out_usr_data,
    output  logic           out_usr_valid,
    output  logic           out_usr_sop,
    output  logic           out_usr_eop,
    output  logic [5:0]     out_usr_empty,
    input   logic           out_usr_ready,
    input   logic           out_usr_almost_full
);

logic [15:0]    eth_type;
logic           pkt_ready;
logic           meta_ready;
logic           usr_ready;

logic [511:0]   in_data_reg;
logic           in_sop_reg;
logic           in_eop_reg;
logic           in_valid_reg;

typedef enum{
    FIRST,
    PKT,
    USR
}state_t;
state_t state;

assign eth_type = in_data[128*3+31:128*3+16];
//Ready to send to pkt buffer
assign pkt_ready = ((state==FIRST) & (eth_type == ETH_IP) & !out_pkt_almost_full) | (state==PKT);
assign meta_ready = (state==FIRST) & (eth_type == ETH_META) & !out_meta_almost_full;
assign usr_ready = ((state==FIRST) & (eth_type == ETH_USR) & !out_usr_almost_full) | (state==USR);

assign in_ready = pkt_ready | meta_ready | usr_ready;

always@(posedge clk)begin
    if(rst)begin
        state <= FIRST;       
        out_pkt_valid <= 0;
        out_pkt_empty <= 0;
        out_pkt_sop <= 0;
        out_pkt_eop <= 0;
        out_meta_valid <= 0;
        out_usr_valid <= 0;
        out_usr_empty <= 0;
        out_usr_sop <= 0;
        out_usr_eop <= 0;
    end else begin
        case(state)
            FIRST:begin
                out_pkt_sop <= 0;
                out_pkt_eop <= 0;
                out_pkt_valid <= 0;
                out_pkt_empty <= 0;
                out_meta_valid <= 0;
                out_usr_valid <= 0;
                out_usr_empty <= 0;
                out_usr_sop <= 0;
                out_usr_eop <= 0;
                if(in_valid & in_sop)begin
                    case(eth_type)
                        ETH_IP:begin
                            if(!out_pkt_almost_full)begin
                                out_pkt_valid <= 1;
                                out_pkt_sop   <= 1;
                                if(in_eop)begin
                                    state <= FIRST;
                                    out_pkt_eop   <= 1;
                                    out_pkt_empty <= in_empty;
                                end else begin
                                    state <= PKT;
                                end
                            end
                        end
                        ETH_META:begin
                            if(!out_meta_almost_full)begin
                                state <= FIRST;
                                out_meta_valid <= 1;
                            end
                        end
                        ETH_USR:begin
                            if(!out_usr_almost_full)begin
                                state <= USR;
                                
                            end
                        end
                    endcase
                end
            end
            PKT:begin
                out_pkt_valid <= in_valid;
                out_pkt_empty <= in_empty;
                out_pkt_sop   <= 0;
                out_pkt_eop   <= in_eop;
                if(in_valid & in_eop)begin
                    state <= FIRST;
                end
            end
            USR:begin
                 out_usr_valid <= in_valid && !in_sop;
		         out_usr_sop <= in_sop_reg;
                 out_usr_eop <= in_eop;//one less cycle
                 if(in_valid & in_eop)begin
                     state <= FIRST;
                 end
            end
        endcase
    end
    //Value stay unchanged if in_valid is 0
    if(in_valid)begin
        in_data_reg <= in_data;
        in_sop_reg <= in_sop;
    end
    //in_eop_reg <= in_eop;

    out_pkt_data <= in_data;
    out_meta_data <= in_data[399:148];
    out_usr_data <= {in_data_reg[399:0],in_data[511:400]};
end
    

endmodule
