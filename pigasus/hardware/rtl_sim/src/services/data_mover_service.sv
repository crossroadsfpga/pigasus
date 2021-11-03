`include "active_msg.vh"
`include "channel_if.vh"
`include "./src/struct_s.sv"

module data_mover_service (
    input logic Clk, 
    input logic Rst_n,
    output logic [31:0]                 stats_in_meta,
    output logic [31:0]                 stats_out_meta,
    output logic [31:0]                 stats_in_forward_meta,
    output logic [31:0]                 stats_in_drop_meta,
    output logic [31:0]                 stats_in_check_meta,
    output logic [31:0]                 stats_in_ooo_meta,
    output logic [31:0]                 stats_in_forward_ooo_meta,
    output logic [31:0]                 stats_nopayload_pkt,
    output logic [31:0]                 stats_check_pkt,

    output  logic [PKTBUF_AWIDTH-1:0]   pkt_buffer_address,
    output  logic                    pkt_buffer_read,
    input   logic                    pkt_buffer_readvalid,
    input   flit_t                   pkt_buffer_readdata,

    server.svr meta,
    server.clt pkt,
    server.clt check_pkt,
    server.clt check_meta,
    server.clt emptylist
);

    channel_if#(.WIDTH(PKT_AWIDTH)) port_empty(); 
    channel_if#(.WIDTH(PKT_AWIDTH)) blank_empty(); 
    channel_if#(.WIDTH(512)) port[2](); 
    channel_if#(.WIDTH(512)) blank[2](); 
    channel_if#(.WIDTH($bits(metadata_t))) port_meta[2](); 
    channel_if#(.WIDTH($bits(metadata_t))) blank_meta[2](); 

    //client_epig_shim#(.DATA_BITS(512)) pkt_cs
    //(
    //    .clk(Clk),
    //    .SoftReset(~Rst_n),
    //    .svr2fl(pkt),
    //    .rx(blank[0]),
    //    .tx(port[0])
    //);
    client_epig_shim#(.DATA_BITS($bits(metadata_t))) meta_cs
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .svr2fl(meta),
        .rx(blank_meta[0]),
        .tx(port_meta[0])
    );

    data_mover data_mover_inst (
        .clk                    (Clk),
        .rst                    (~Rst_n),
        .pkt_buffer_address     (pkt_buffer_address), 
        .pkt_buffer_read        (pkt_buffer_read),
        .pkt_buffer_readvalid   (pkt_buffer_readvalid),
        .pkt_buffer_readdata    (pkt_buffer_readdata),
        .emptylist_in_data      (port_empty.data),
        .emptylist_in_valid     (port_empty.valid),
        .emptylist_in_ready     (port_empty.ready),
        .pkt_sop                (port[0].sop),
        .pkt_eop                (port[0].eop),
        .pkt_valid              (port[0].valid),
        .pkt_data               (port[0].data),
        .pkt_empty              (port[0].empty),
        .pkt_ready              (port[0].ready),
        .pkt_almost_full        (port[0].almost_full),
        .check_pkt_sop          (port[1].sop),
        .check_pkt_eop          (port[1].eop),
        .check_pkt_valid        (port[1].valid),
        .check_pkt_data         (port[1].data),
        .check_pkt_empty        (port[1].empty),
        .check_pkt_ready        (port[1].ready),
        .check_pkt_almost_full  (port[1].almost_full),
        //.check_pkt_hdr          (dm_check_pkt_hdr),
        .check_meta_valid       (port_meta[1].valid),
        .check_meta_data        (port_meta[1].data),
        .check_meta_ready       (port_meta[1].ready),//not used
        .meta_valid             (port_meta[0].valid),
        .meta_data              (port_meta[0].data),
        .meta_ready             (port_meta[0].ready)
    );

    server_epig_shim#(.DATA_BITS(PKT_AWIDTH)) empty_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(emptylist),
        .tx(blank_empty),
        .rx(port_empty)
    );

    server_epig_shim#(.DATA_BITS(512)) pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(pkt),
        .tx(blank[0]),
        .rx(port[0])
    );
    server_epig_shim#(.DATA_BITS(512)) check_pkt_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(check_pkt),
        .tx(blank[1]),
        .rx(port[1])
    );

    server_epig_shim#(.DATA_BITS($bits(metadata_t))) meta_ss
    (
        .clk(Clk),
        .SoftReset(~Rst_n),
        .fl2clt(check_meta),
        .tx(blank_meta[1]),
        .rx(port_meta[1])
    );

    //stats
    metadata_t tmp_meta;
    assign tmp_meta = port_meta[0].data;
    
    always @ (posedge Clk) begin
        if (~Rst_n) begin
            stats_in_forward_meta <= 0;
            stats_in_drop_meta <= 0;
            stats_in_check_meta <= 0;
            stats_in_ooo_meta <= 0;
            stats_in_forward_ooo_meta <= 0;
        end else begin
    
            if (port_meta[0].ready & port_meta[0].valid) begin
                case (tmp_meta.pkt_flags)
                    PKT_FORWARD:     stats_in_forward_meta     <= stats_in_forward_meta + 1;
                    PKT_DROP:        stats_in_drop_meta        <= stats_in_drop_meta + 1;
                    PKT_CHECK:       stats_in_check_meta       <= stats_in_check_meta + 1;
                    PKT_OOO:         stats_in_ooo_meta         <= stats_in_ooo_meta + 1;
                    PKT_FORWARD_OOO: stats_in_forward_ooo_meta <= stats_in_forward_ooo_meta + 1;
                endcase
            end
        end
    end
  
    stats_cnt in_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port_meta[0].valid),
        .ready      (port_meta[0].ready),
        .stats_flit (stats_in_meta)
    );
    stats_cnt out_meta_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port_meta[1].valid),
        .ready      (port_meta[1].ready),
        .stats_flit (stats_out_meta)
    );

    stats_cnt nopayload_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[0].valid),
        .ready      (port[0].ready),
        .eop        (port[0].eop),
        .stats_pkt  (stats_nopayload_pkt)
    );

    stats_cnt check_pkt_inst(
        .Clk        (Clk),
        .Rst_n      (Rst_n),
        .valid      (port[1].valid),
        .ready      (port[1].ready),
        .eop        (port[1].eop),
        .stats_pkt  (stats_check_pkt)
    );
    
endmodule
