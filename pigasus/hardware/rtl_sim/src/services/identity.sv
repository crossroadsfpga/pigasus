`include "active_msg.vh"
`include "channel_if.vh"

module identity (
    input logic clk,
    input logic rst_n,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,

    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr
);

    // forward path working reliably
    channel_if #(.WIDTH(512)) pkt_channel_fw();
    channel_if #(.WIDTH($bits(metadata_t))) meta_channel_fw();
    channel_if #(.WIDTH(512)) usr_channel_fw();

    channel_if #(.WIDTH(512)) _b0();
    channel_if #(.WIDTH($bits(metadata_t))) _b1();
    channel_if #(.WIDTH(512)) _b2();

    channel_if #(.WIDTH(512)) _c0();
    channel_if #(.WIDTH($bits(metadata_t))) _c1();
    channel_if #(.WIDTH(512)) _c2();

    // convert from Fluid interface to streaming
    client_epig_shim #(.DATA_BITS(512)) pkt_service_to_channel (
        .clk(clk),
        .SoftReset(~rst_n),
        .svr2fl(in_pkt),
        .rx(_b0),
        .tx(pkt_channel_fw)
    );

    client_epig_shim #(.DATA_BITS($bits(metadata_t))) meta_service_to_channel (
        .clk(clk),
        .SoftReset(~rst_n),
        .svr2fl(in_meta),
        .rx(_b1),
        .tx(meta_channel_fw)
    );

    client_epig_shim #(.DATA_BITS(512)) usr_service_to_channel (
        .clk(clk),
        .SoftReset(~rst_n),
        .svr2fl(in_usr),
        .rx(_b2),
        .tx(usr_channel_fw)
    );

    // YOUR CODE HERE

    // convert from streaming to Fluid interface
    server_epig_shim #(.DATA_BITS(512)) pkt_channel_to_service (
        .clk(clk),
        .SoftReset(~rst_n),
        .fl2clt(out_pkt),
        .rx(pkt_channel_fw),
        .tx(_c0)
    );

    server_epig_shim #(.DATA_BITS($bits(metadata_t))) meta_channel_to_service (
        .clk(clk),
        .SoftReset(~rst_n),
        .fl2clt(out_meta),
        .rx(meta_channel_fw),
        .tx(_c1)
    );

    server_epig_shim #(.DATA_BITS(512)) usr_channel_to_service (
        .clk(clk),
        .SoftReset(~rst_n),
        .fl2clt(out_usr),
        .rx(usr_channel_fw),
        .tx(_c2)
    );
endmodule

    
