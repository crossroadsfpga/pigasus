`include "active_msg.vh"

module mkReadAvalon_wrapper (
    input logic clk,
    input logic SoftReset,

    input logic [16:0] setRd_addr_read,

    output logic topA_read,
    output logic [16:0] topA_address,
    input logic [520:0] topA_readdata,
    input logic topA_waitrequest,
    input logic topA_readdatavalid,

    server.svr read
);

    mkReadAvalon my_rd (
        .CLK(clk),
        .RST_N(~SoftReset),

        .topA_read(topA_read),
        .topA_address(topA_address),
        .topA_readdata(topA_readdata),
        .topA_waitrequest(topA_waitrequest),
        .topA_readdatavalid(topA_readdatavalid),

        .read_txFull(read.txFull),
        .read_tx_msg(read.txP.tx_msg),
        .EN_read_tx(read.txP.tx),
        .read_rxEmpty(read.rxP.rxEmpty),
        .EN_read_rxPop(read.rxPop),
        .read_rx_msg(read.rxP.rx_msg),
    
        .setRd_addr_read(setRd_addr_read)
    );

endmodule
