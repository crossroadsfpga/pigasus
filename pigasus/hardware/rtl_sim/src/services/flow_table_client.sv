`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module flow_table_client (
    input logic Clk, 
    input logic Rst_n,
    //stats
    output logic [31:0] stats_in_meta,
    output logic [31:0] stats_out_meta,


    server.svr in_meta,
    server.clt out_meta,
    server.clt forward_meta,
    server.clt reorder_meta
);

    channel_if#(.WIDTH($bits(metadata_t))) port[4](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank[4](); 

    //Stats
    logic [31:0] out_meta_cnt;
    logic [31:0] forward_meta_cnt;
    logic [31:0] reorder_meta_cnt;
    
    always @ (posedge Clk) begin
        if (~Rst_n) begin
            stats_out_meta <= 0;
        end else begin
            stats_out_meta <= out_meta_cnt + forward_meta_cnt + reorder_meta_cnt;
        end
    end

    client_epig_shim#(.DATA_BITS($bits(metadata_t))) in_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(in_meta),
        .rx(blank[0]),
        .tx(port[0])
    );

    flow_table_wrapper ftw_inst (
        .clk                       (Clk),
        .rst                       (~Rst_n),
        .in_meta_data              (port[0].data),
        .in_meta_valid             (port[0].valid),
        .in_meta_ready             (port[0].ready),
        .out_meta_data             (port[1].data),
        .out_meta_valid            (port[1].valid),
        .out_meta_ready            (port[1].ready),
        .out_meta_almost_full      (port[1].almost_full),
        .forward_meta_data         (port[2].data),
        .forward_meta_valid        (port[2].valid),
        .forward_meta_ready        (port[2].ready),
        .reorder_meta_data         (port[3].data),
        .reorder_meta_valid        (port[3].valid),
        .reorder_meta_ready        (port[3].ready),
        .reorder_meta_almost_full  (port[3].almost_full)
    );

    server_epig_shim#(.DATA_BITS($bits(metadata_t))) out_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(out_meta),
        .tx(blank[1]),
        .rx(port[1])
    );

    server_epig_shim#(.DATA_BITS($bits(metadata_t))) forward_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(forward_meta),
        .tx(blank[2]),
        .rx(port[2])
    );

    server_epig_shim#(.DATA_BITS($bits(metadata_t))) reorder_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(reorder_meta),
        .tx(blank[3]),
        .rx(port[3])
    );

    //stats
    stats_cnt in_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[0].valid),
        .ready      (port[0].ready),
        .stats_flit (stats_in_meta)
    );
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[1].valid),
        .ready      (port[1].ready),
        .stats_flit (out_meta_cnt)
    );
    stats_cnt forward_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[2].valid),
        .ready      (port[2].ready),
        .stats_flit (forward_meta_cnt)
    );
    stats_cnt reorder_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[3].valid),
        .ready      (port[3].ready),
        .stats_flit (reorder_meta_cnt)
    );

endmodule
