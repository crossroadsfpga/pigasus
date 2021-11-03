`include "channel_if.vh"
`include "active_msg.vh"
`include "./src/struct_s.sv"

module port_group_matcher_service  (
    input logic Clk, 
    input logic Rst_n,

    output logic [31:0]     stats_out_pkt,
    output logic [31:0]     stats_out_meta,
    output logic [31:0]     stats_out_rule,
    output logic [31:0]     stats_nocheck_pkt,
    output logic [31:0]     stats_check_pkt,
    output logic [31:0]     stats_check_pkt_s,
    
    output  logic [31:0]    pg_no_pg_rule_cnt,
    output  logic [31:0]    pg_int_rule_cnt,

    server.svr in_pkt,
    server.svr in_meta,
    server.svr in_usr,
    server.clt pg_nocheck,
    server.clt out_pkt,
    server.clt out_meta,
    server.clt out_usr
);

    server#(.DATA_BITS(512))               pg_pkt_ifc();

    port_group_client port_group_inst (
        .Clk(Clk), 
        .Rst_n(Rst_n),
    
        .stats_out_pkt (stats_out_pkt),
        .stats_out_meta(stats_out_meta),
        .stats_out_rule(stats_out_rule),  
        .no_pg_rule_cnt(pg_no_pg_rule_cnt),
        .pg_rule_cnt(pg_int_rule_cnt),
    
        .in_pkt(in_pkt),
        .in_meta(in_meta),
        .in_usr(in_usr),
        .out_pkt(pg_pkt_ifc),
        .out_meta(out_meta),
        .out_usr(out_usr)
    );
    
    fork_service pg_fork (
        .Clk(Clk), 
        .Rst_n(Rst_n),
    
        .stats_out_pkt0   (stats_nocheck_pkt),
        .stats_out_pkt1   (stats_check_pkt),
        .stats_out_pkt1_s (stats_check_pkt_s),
        
        .in(pg_pkt_ifc),
        .out0(pg_nocheck),
        .out1(out_pkt)
    );


endmodule
