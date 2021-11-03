`include "../struct_s.sv"

//Generate ack packet
module ack_gen (
    //clk & rst   
    input  logic         clk,                                     
    input  logic         rst,                                  
    //Ethernet In & out
    input  logic         in_sop,          
    input  logic         in_eop,            
    input  logic [511:0] in_data,                    
    input  logic [5:0]   in_empty,                    
    input  logic         in_valid, 
    output logic         in_ready,
    output logic [511:0] out_data,       
    output logic         out_valid,       
    output logic         out_sop,       
    output logic         out_eop,       
    output logic [5:0]   out_empty,       
    input  logic         out_ready,       
    output ack_pkt_t     ack_pkt,
    output logic         ack_valid
);

//First flit
logic [47:0] eth_dst_mac;
logic [47:0] eth_src_mac;
logic [15:0] eth_type;
logic [3:0]  ip_version;
logic [3:0]  ip_ihl;
//Second flit
logic [5:0]  ip_dscp;
logic [1:0]  ip_ecn;
logic [15:0] ip_len;
logic [15:0] ip_id;
logic [2:0]  ip_flags;
logic [12:0] ip_fo;
logic [7:0]  ip_ttl;
logic [7:0]  ip_prot;
logic [7:0]  ip_chsm;
logic [31:0] ip_sip;
logic [15:0] ip_dip_high;
//Third flit
logic [15:0] ip_dip_low;
logic [15:0] udp_sport;
logic [15:0] udp_dport;
logic [15:0] udp_len;
logic [15:0] udp_chsm;
logic [15:0] tcp_sport;
logic [15:0] tcp_dport;
logic [31:0] tcp_seq;
logic [31:0] tcp_ack;
logic [3:0]  tcp_do;
logic [2:0]  tcp_rsv;
logic        tcp_ns;
logic        tcp_cwr;
logic        tcp_ece;
logic        tcp_urg;
logic        tcp_fack;
logic        tcp_psh;
logic        tcp_rst;
logic        tcp_syn;
logic        tcp_fin;
//Fourth flit
logic [15:0] tcp_win;
logic [15:0] tcp_chsm;
logic [15:0] tcp_urgp;

logic support;
logic [7:0] num_flit;

//First flit
assign eth_dst_mac = in_data[128*3+127:128*3+80];   //48
assign eth_src_mac = in_data[128*3+79:128*3+32];    //48
assign eth_type    = in_data[128*3+31:128*3+16];    //16
assign ip_version  = in_data[128*3+15:128*3+12];    //4 
assign ip_ihl      = in_data[128*3+11:128*3+8];     //4
assign ip_dscp     = in_data[128*3+7:128*3+2];      //6
assign ip_ecn      = in_data[128*3+1:128*3+0];      //2

//Second flit
assign ip_len = in_data[128*2+127:128*2+112];      //16
assign ip_id = in_data[128*2+111:128*2+96];        //16
assign ip_flags = in_data[128*2+95:128*2+93];      //3
assign ip_fo = in_data[128*2+92:128*2+80];         //13
assign ip_ttl = in_data[128*2+79:128*2+72];        //8
assign ip_prot = in_data[128*2+71:128*2+64];       //8
assign ip_chsm = in_data[128*2+63:128*2+48];       //16
assign ip_sip = in_data[128*2+47:128*2+16];        //32
assign ip_dip_high = in_data[128*2+15:128*2+0];    //16

//Third flit
assign ip_dip_low = in_data[128+127:128+112];  //16  
assign udp_sport = in_data[128+111:128+96];    //16
assign udp_dport = in_data[128+95:128+80];     //16
assign udp_len = in_data[128+79:128+64];       //16
assign udp_chsm = in_data[128+63:128+48];      //16

assign tcp_sport = in_data[128+111:128+96];    //16
assign tcp_dport = in_data[128+95:128+80];     //16
assign tcp_seq = in_data[128+79:128+48];       //32
assign tcp_ack = in_data[128+47:128+16];       //32
assign tcp_do  = in_data[128+15:128+12];       //4
assign tcp_rsv = in_data[128+11:128+9];        //3
assign tcp_ns  = in_data[128+8];           //1
assign tcp_cwr = in_data[128+7];           //1
assign tcp_ece = in_data[128+6];           //1
assign tcp_urg = in_data[128+5];           //1
assign tcp_fack = in_data[128+4];          //1
assign tcp_psh = in_data[128+3];           //1
assign tcp_rst = in_data[128+2];           //1
assign tcp_syn = in_data[128+1];           //1
assign tcp_fin = in_data[128+0];           //1

//Fourth flit
assign tcp_win = in_data[127:112];     //16
assign tcp_chsm = in_data[111:96];     //16
assign tcp_urgp = in_data[95:80];      //16

assign support = (eth_type == PROT_ETH) & (ip_version == IP_V4)
            & (ip_ihl == 5) & ((ip_prot == PROT_TCP) | (ip_prot == PROT_UDP));

always@(posedge clk)begin
    if(rst)begin
        ack_valid <= 0;
        ack_pkt <= 0;
        num_flit <= 0;
    end else begin
        ack_valid <= 0;
        if(in_valid & in_ready)begin
            if(in_sop)begin
                //switch the src and dst
                ack_pkt.udp_hdr.eth_dst_mac <= eth_src_mac;
                ack_pkt.udp_hdr.eth_src_mac <= eth_dst_mac;
                ack_pkt.udp_hdr.eth_type    <= eth_type;
                ack_pkt.udp_hdr.ip_version  <= ip_version;
                ack_pkt.udp_hdr.ip_ihl      <= ip_ihl;
                ack_pkt.udp_hdr.ip_dscp     <= ip_dscp;
                ack_pkt.udp_hdr.ip_ecn      <= ip_ecn;
                ack_pkt.udp_hdr.ip_len      <= ip_len;
                ack_pkt.udp_hdr.ip_id       <= ip_id;
                ack_pkt.udp_hdr.ip_flags    <= ip_flags;
                ack_pkt.udp_hdr.ip_fo       <= ip_fo;
                ack_pkt.udp_hdr.ip_ttl      <= ip_ttl;
                ack_pkt.udp_hdr.ip_prot     <= ip_prot;
                ack_pkt.udp_hdr.ip_chsm     <= ip_chsm;
                ack_pkt.udp_hdr.ip_sip      <= {ip_dip_high,ip_dip_low};
                ack_pkt.udp_hdr.ip_dip      <= ip_sip;
                //ack_pkt.udp_hdr.udp_sport   <= udp_dport;
                ack_pkt.udp_hdr.udp_sport   <= ACK_PKT_PORT;
                ack_pkt.udp_hdr.udp_dport   <= udp_sport;
                ack_pkt.udp_hdr.udp_len     <= udp_len;
                ack_pkt.udp_hdr.udp_chsm    <= udp_chsm;
                num_flit <= 1;
            end else begin
                num_flit <= num_flit + 1;
            end

            //send out ack packet after an entire packet has been consumed. 
            if(in_eop)begin
                ack_valid <= 1;
                if(in_sop)begin
                    ack_pkt.data <= 1;
                end else begin
                    ack_pkt.data <= num_flit + 1;
                end
            end
        end
    end
end

assign    out_data  = in_data;
assign    out_sop   = in_sop;
assign    out_eop   = in_eop;
assign    out_empty = in_empty;
assign    out_valid = in_valid;
assign    in_ready  = out_ready;
endmodule
