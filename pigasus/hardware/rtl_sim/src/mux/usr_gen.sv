`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

//Take usr data and generate a Ethernet Frame
module usr_gen (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // In User data
    input   logic [511:0]   in_usr_data,
    input   logic           in_usr_valid,
    input   logic           in_usr_sop,
    input   logic           in_usr_eop,
    input   logic [5:0]     in_usr_empty,
    output  logic           in_usr_ready,

    // Out 
    output  logic [511:0]   out_data,
    output  logic           out_valid,
    output  logic           out_sop,
    output  logic           out_eop,
    output  logic [5:0]     out_empty,
    input   logic           out_ready,
    input   logic           out_almost_full
);
    logic last;
    logic [511:0] first_flit;
    logic [511:0] normal_flit;
    logic [511:0] last_flit;
    logic [511:0] in_usr_data_reg;

    typedef enum{
        FIRST_FLIT,
        NORMAL_FLIT,
        LAST_FLIT
    }state_t;

    state_t state;

    //Assume it is always aligned. 
    assign in_usr_ready = !((state==FIRST_FLIT) & out_almost_full);

    assign first_flit  = {DST_MAC,SRC_MAC,ETH_USR,in_usr_data[511:112]};
    assign normal_flit = {in_usr_data_reg[111:0],in_usr_data[511:112]};
    assign last_flit   = {in_usr_data_reg[111:0],400'b0};
    assign out_empty = 0;

    always@(posedge clk)begin
        if(rst)begin
            state <= FIRST_FLIT;
            out_valid <= 0;
            out_sop <= 0;
            out_eop <= 0;
        end else begin
            in_usr_data_reg <= in_usr_data;
            case(state)
                FIRST_FLIT:begin
                    out_valid <= 0;
                    out_sop <= 0;
                    out_eop <= 0;
                    if(in_usr_valid & in_usr_sop & !out_almost_full)begin
                        out_valid <= 1;
                        out_sop <= 1;
                        state <= NORMAL_FLIT;
                    end
                    out_data <= first_flit;
                end
                NORMAL_FLIT:begin
                     out_sop <= 0;
                     out_eop <= 0;
                     out_valid <= in_usr_valid;
                     out_data <= normal_flit;
                     if(in_usr_valid & in_usr_eop)begin
                         state <= LAST_FLIT;
                     end
                end
                LAST_FLIT:begin
                    out_eop <= 1;
                    out_valid <= 1;
                    out_data <= last_flit;
                    state <= FIRST_FLIT;
                end
            endcase
        end
    end

endmodule
