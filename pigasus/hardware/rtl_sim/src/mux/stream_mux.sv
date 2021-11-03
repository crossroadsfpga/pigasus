`include "./src/struct_s.sv"
`timescale 1 ps / 1 ps

module stream_mux (
    // Clk & rst
    input   logic         clk,
    input   logic         rst,

    // In Pkt data
    input   logic [511:0]   in_pkt_data,
    input   logic           in_pkt_valid,
    input   logic           in_pkt_sop,
    input   logic           in_pkt_eop,
    input   logic [5:0]     in_pkt_empty,
    output  logic           in_pkt_ready,

    // In Meta data
    input   metadata_t      in_meta_data,
    input   logic           in_meta_valid,
    output  logic           in_meta_ready,

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

logic [511:0]   out_meta_data;
logic           out_meta_valid;
logic           out_meta_sop;
logic           out_meta_eop;
logic [5:0]     out_meta_empty;
logic           out_meta_ready;
logic           out_meta_almost_full;
logic [511:0]   fifo_meta_data;
logic           fifo_meta_valid;
logic           fifo_meta_sop;
logic           fifo_meta_eop;
logic [5:0]     fifo_meta_empty;
logic           fifo_meta_ready;
logic [31:0]    meta_csr_readdata;

logic [511:0]   out_usr_data;
logic           out_usr_valid;
logic           out_usr_sop;
logic           out_usr_eop;
logic [5:0]     out_usr_empty;
logic           out_usr_ready;
logic           out_usr_almost_full;
logic [511:0]   fifo_usr_data;
logic           fifo_usr_valid;
logic           fifo_usr_sop;
logic           fifo_usr_eop;
logic [5:0]     fifo_usr_empty;
logic           fifo_usr_ready;
logic [31:0]    usr_csr_readdata;
    
meta_gen meta_gen_inst(
    .clk            (clk),
    .rst            (rst),
    .in_meta_data   (in_meta_data),
    .in_meta_valid  (in_meta_valid),
    .in_meta_ready  (in_meta_ready),
    .out_data       (out_meta_data),
    .out_valid      (out_meta_valid),
    .out_sop        (out_meta_sop),
    .out_eop        (out_meta_eop),
    .out_empty      (out_meta_empty),
    .out_ready      (out_meta_ready),
    .out_almost_full(out_meta_almost_full)
);

usr_gen usr_gen_inst(
    .clk            (clk),
    .rst            (rst),
    .in_usr_data    (in_usr_data),
    .in_usr_valid   (in_usr_valid),
    .in_usr_sop     (in_usr_sop),
    .in_usr_eop     (in_usr_eop),
    .in_usr_empty   (in_usr_empty),
    .in_usr_ready   (in_usr_ready),
    .out_data       (out_usr_data),
    .out_valid      (out_usr_valid),
    .out_sop        (out_usr_sop),
    .out_eop        (out_usr_eop),
    .out_empty      (out_usr_empty),
    .out_ready      (out_usr_ready),
    .out_almost_full(out_usr_almost_full)
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[mux] meta_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) meta_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (out_meta_data),
    .in_valid          (out_meta_valid),
    .in_ready          (out_meta_ready),
    .in_startofpacket  (out_meta_sop),
    .in_endofpacket    (out_meta_eop),
    .in_empty          (out_meta_empty),
    .out_data          (fifo_meta_data),
    .out_valid         (fifo_meta_valid),
    .out_ready         (fifo_meta_ready),
    .out_startofpacket (fifo_meta_sop),
    .out_endofpacket   (fifo_meta_eop),
    .out_empty         (fifo_meta_empty),
    .fill_level        (meta_csr_readdata),
    .almost_full       (out_meta_almost_full),
    .overflow          ()
);

unified_pkt_fifo  #(
    .FIFO_NAME        ("[mux] usr_FIFO"),
    .MEM_TYPE         ("M20K"),
    .DUAL_CLOCK       (0),
    .USE_ALMOST_FULL  (1),
    .FULL_LEVEL       (470),
    .SYMBOLS_PER_BEAT (64),
    .BITS_PER_SYMBOL  (8),
    .FIFO_DEPTH       (512)
) usr_fifo (
    .in_clk            (clk),
    .in_reset          (rst),
    .out_clk           (),//not used
    .out_reset         (),
    .in_data           (out_usr_data),
    .in_valid          (out_usr_valid),
    .in_ready          (out_usr_ready),
    .in_startofpacket  (out_usr_sop),
    .in_endofpacket    (out_usr_eop),
    .in_empty          (out_usr_empty),
    .out_data          (fifo_usr_data),
    .out_valid         (fifo_usr_valid),
    .out_ready         (fifo_usr_ready),
    .out_startofpacket (fifo_usr_sop),
    .out_endofpacket   (fifo_usr_eop),
    .out_empty         (fifo_usr_empty),
    .fill_level        (usr_csr_readdata),
    .almost_full       (out_usr_almost_full),
    .overflow          ()
);

st_multiplexer_pkt_3 mux_inst (
    .clk               (clk),
    .reset_n           (!rst),
    .out_data          (out_data),
    .out_valid         (out_valid),
    .out_ready         (out_ready),
    .out_startofpacket (out_sop),
    .out_endofpacket   (out_eop),
    .out_empty         (out_empty),
    .out_channel       (),
    .in0_data          (in_pkt_data),
    .in0_valid         (in_pkt_valid),
    .in0_ready         (in_pkt_ready),
    .in0_startofpacket (in_pkt_sop),
    .in0_endofpacket   (in_pkt_eop),
    .in0_empty         (in_pkt_empty),
    .in1_data          (fifo_meta_data),
    .in1_valid         (fifo_meta_valid),
    .in1_ready         (fifo_meta_ready),
    .in1_startofpacket (fifo_meta_sop),
    .in1_endofpacket   (fifo_meta_eop),
    .in1_empty         (fifo_meta_empty),
    .in2_data          (fifo_usr_data),
    .in2_valid         (fifo_usr_valid),
    .in2_ready         (fifo_usr_ready),
    .in2_startofpacket (fifo_usr_sop),
    .in2_endofpacket   (fifo_usr_eop),
    .in2_empty         (fifo_usr_empty)
);

endmodule
