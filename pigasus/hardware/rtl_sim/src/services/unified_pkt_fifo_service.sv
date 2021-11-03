`include "active_msg.vh"
`include "channel_if.vh"

module unified_pkt_fifo_service #(
    //new parameters
    parameter FIFO_NAME = "FIFO",
    parameter MEM_TYPE = "M20K",
    parameter DUAL_CLOCK = 0,
    parameter USE_ALMOST_FULL = 0,
    parameter FULL_LEVEL = 450,//does not matter is USE_ALMOST_FULL is 0
    //parameters used for generated IP
    parameter SYMBOLS_PER_BEAT    = 64,
    parameter BITS_PER_SYMBOL     = 8,
    parameter FIFO_DEPTH          = 512
) (
    input logic Clk_i, 
    input logic Rst_n_i,
    input logic Clk_o, 
    input logic Rst_n_o,

    output logic [31:0] fill_level,
    output logic [31:0] overflow,

    server.svr in,
    server.clt out
);

    channel_if#(.WIDTH(SYMBOLS_PER_BEAT*BITS_PER_SYMBOL)) port[2](); 
    channel_if#(.WIDTH(SYMBOLS_PER_BEAT*BITS_PER_SYMBOL)) blank[2](); 

    client_epig_shim#(.DATA_BITS(SYMBOLS_PER_BEAT*BITS_PER_SYMBOL)) in_cs
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .svr2fl(in),
        .rx(blank[0]),
        .tx(port[0])
    );

unified_pkt_fifo  #(
    .FIFO_NAME        (FIFO_NAME),
    .MEM_TYPE         (MEM_TYPE),
    .DUAL_CLOCK       (DUAL_CLOCK),
    .USE_ALMOST_FULL  (USE_ALMOST_FULL),
    .FULL_LEVEL       (FULL_LEVEL),
    .SYMBOLS_PER_BEAT (SYMBOLS_PER_BEAT),
    .BITS_PER_SYMBOL  (BITS_PER_SYMBOL),
    .FIFO_DEPTH       (FIFO_DEPTH)
)
my_FIFO (
    .in_clk            (Clk_i),
    .in_reset          (~Rst_n_i),
    .out_clk           (Clk_o),//not used
    .out_reset         (~Rst_n_o),
    .in_data           (port[0].data),
    .in_valid          (port[0].valid),
    .in_ready          (port[0].ready),
    .in_startofpacket  (port[0].sop),
    .in_endofpacket    (port[0].eop),
    .in_empty          (port[0].empty),
    .out_data          (port[1].data),
    .out_valid         (port[1].valid),
    .out_ready         (port[1].ready),
    .out_startofpacket (port[1].sop),
    .out_endofpacket   (port[1].eop),
    .out_empty         (port[1].empty),
    .fill_level        (fill_level),
    .almost_full       (port[0].almost_full),
    .overflow          (overflow)
);

generate
if (DUAL_CLOCK==1) begin
    server_epig_shim#(.DATA_BITS(SYMBOLS_PER_BEAT*BITS_PER_SYMBOL)) out_ss
    (
        .clk(Clk_o),
        .SoftReset(~Rst_n_o),
        .fl2clt(out),
        .tx(blank[1]),
        .rx(port[1])
    );
end else begin
    server_epig_shim#(.DATA_BITS(SYMBOLS_PER_BEAT*BITS_PER_SYMBOL)) out_ss
    (
        .clk(Clk_i),
        .SoftReset(~Rst_n_i),
        .fl2clt(out),
        .tx(blank[1]),
        .rx(port[1])
    );
end
endgenerate
endmodule
