`include "active_msg.vh"

module mkWriteAvalon_wrapper (
    input logic clk,
    input logic SoftReset,

    input logic [63:0] setWr_addr_write,

    output logic topA_write,
    output logic [16:0] topA_address,
    output logic [520:0] topA_writedata,
    input logic topA_waitrequest,

    server.svr write  
);

    mkWriteAvalon my_wr (
        .CLK(clk),
        .RST_N(~SoftReset),

        .topA_write(topA_write),
        .topA_address(topA_address),
        .topA_writedata(topA_writedata),
        .topA_waitrequest(topA_waitrequest),
        .topA_readdatavalid(1'b0),

        .write_txFull(write.txFull),
        .write_tx_msg(write.txP.tx_msg),
        .EN_write_tx(write.txP.tx),
        .write_rxEmpty(write.rxP.rxEmpty),
        .EN_write_rxPop(write.rxPop),
        .write_rx_msg(write.rxP.rx_msg),

        .setWr_addr_write(setWr_addr_write)
    );

endmodule
