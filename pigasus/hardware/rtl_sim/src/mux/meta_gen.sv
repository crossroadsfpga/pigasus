`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

//Take meta data and generate a Ethernet Frame
module meta_gen (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // In Meta data
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    output  logic           in_meta_ready,

    // Out 
    output  logic [511:0]   out_data,
    output  logic           out_valid,
    output  logic           out_sop,
    output  logic           out_eop,
    output  logic [5:0]     out_empty,
    input   logic           out_ready,
    input   logic           out_almost_full
);
    //min size packet
    assign out_sop = 1'b1;
    assign out_eop = 1'b1;
    assign out_valid = in_meta_valid;
    assign in_meta_ready = out_ready;
    assign out_data = {DST_MAC,SRC_MAC,ETH_META,in_meta_data,148'b0};
    assign out_empty = 0;

endmodule
