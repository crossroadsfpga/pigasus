




`ifndef STRUCT_S
`define STRUCT_S

//`define SIM
`define USE_BRAM
`define BRAM_CHECKPKT_BUF
`define NO_C2F
//`define DISABLE_NF_BYPASS
// `define NO_BP

// Packet buffer
// STORE 1024 pkts, each pkt takes 32 * 512 bits = 2 KB.
// 32 * 1024 = 32768 entries.
`ifdef USE_BRAM
parameter PKT_NUM = 1024;
`else
parameter PKT_NUM = 2688;
`endif
//BUF
parameter IN_BUF_DEPTH = 16384;
//free space threshold
//Bigger than one pkt
parameter DS_THRESH = 100;
//special port for ACK packets
parameter ACK_PKT_PORT=16'hFFFF;


parameter PKTBUF_AWIDTH = ($clog2(PKT_NUM) + 5);
parameter PKTBUF_DEPTH = (32 * PKT_NUM);
parameter PKT_AWIDTH = $clog2(PKT_NUM);
parameter FT_SUBTABLE = 4;
parameter FT_SIZE = 8192;
parameter FT_DEPTH = (FT_SIZE / FT_SUBTABLE);
parameter FT_AWIDTH = $clog2(FT_DEPTH);
parameter PQ_DEPTH = 8;
parameter PQ_AWIDTH = $clog2(PQ_DEPTH);
parameter LL_DEPTH = (PKT_NUM / 2);
parameter LL_AWIDTH = $clog2(LL_DEPTH);
parameter HEADER_OFFSET = 1;
parameter FP_DWIDTH = 256;
parameter FP_EWIDTH = $clog2((FP_DWIDTH / 8));
parameter ETH_HDR_LEN = 14;
parameter SRC_MAC = 48'h112233445566;
parameter DST_MAC = 48'h665544332211;
parameter ETH_IP = 16'h0800;
parameter ETH_META = 16'hFFFE;
parameter ETH_USR = 16'hFFFF;
parameter PROT_ETH = 16'h0800;
parameter IP_V4 = 4'h4;
parameter PROT_TCP = 8'h06;
parameter PROT_UDP = 8'h11;
parameter NS = 8'hFF;
parameter S_UDP = PROT_UDP;
parameter S_TCP = PROT_TCP;
parameter TCP_FIN = 0;
parameter TCP_SYN = 1;
parameter TCP_RST = 2;
parameter TCP_PSH = 3;
parameter TCP_FACK = 4;
parameter TCP_URG = 5;
parameter TCP_ECE = 6;
parameter TCP_CWR = 7;
parameter TCP_NS = 8;
parameter PKT_FORWARD = 0;
parameter PKT_DROP = 1;
parameter PKT_CHECK = 2;
parameter PKT_OOO = 3;
parameter PKT_FORWARD_OOO = 4;
parameter PKT_DONE = 5;
parameter STAT_AWIDTH = 5;
parameter ETH_0_REG         = 5'b00_000;
parameter ETH_1_REG         = 5'b00_001;
parameter TOP_REG           = 5'b10_001;
parameter STATS_0_REG       = 5'b10_010;
parameter STATS_1_REG       = 5'b10_011;
parameter FC_0_REG          = 5'b10_100;
parameter FC_1_REG          = 5'b10_101;
parameter PCIE              = 5'b10_110;
parameter DRAM              = 5'b10_111;
parameter PDU_NO = 2'b00;
parameter PDU_FIRST = 2'b01;
parameter PDU_MIDDLE = 2'b10;
parameter PDU_LAST = 2'b11;

typedef struct packed {
    logic sop;
    logic eop;
    logic [5:0] empty;
    logic [511:0] data;
} flit_t;

typedef struct packed {
    logic sop;
    logic eop;
    logic [511:0] data;
} flit_lite_t;

typedef struct packed {
    logic sop;
    logic eop;
    logic [5:0] empty;
} flit_meta_t;
parameter LL_DWIDTH = ((((((1 + 32) + 16) + 16) + PKT_AWIDTH) + 1) + 56);

typedef struct packed {
    logic valid;                    // Valid
    logic [31:0] seq;               // Sequence
    logic [15:0] len;               // Length
    logic [LL_AWIDTH-1:0] next;     // Next
    logic [PKT_AWIDTH-1:0] pktID;   // PktID
    logic [4:0] flits;
    logic last;                     // Last
    logic [55:0] last_7_bytes;      // Last
} entry_t;
parameter TUPLE_DWIDTH = (((32 + 32) + 16) + 16);

typedef struct packed {
    logic [31:0] sIP;
    logic [31:0] dIP;
    logic [15:0] sPort;
    logic [15:0] dPort;
} tuple_t;


typedef struct packed {
    logic [31:0] c2f_kmem_high_1;   // higher 32 bit of kernel memory, FPGA read only
    logic [31:0] c2f_kmem_low_1;    // lower 32 bit of kernel memory, FPGA read only
    logic [31:0] c2f_head_1;        // head pointer, FPGA read only
    logic [31:0] c2f_tail_1;        // tail pointer, CPU read only

    logic [31:0] f2c_kmem_high_1;   // higher 32 bit of kernel memory, FPGA read only
    logic [31:0] f2c_kmem_low_1;    // lower 32 bit of kernel memory, FPGA read only
    logic [31:0] f2c_head_1;        // head pointer, FPGA read only
    logic [31:0] f2c_tail_1;        // tail pointer, CPU read only

    logic [31:0] c2f_kmem_high;     // higher 32 bit of kernel memory, FPGA read only
    logic [31:0] c2f_kmem_low;      // lower 32 bit of kernel memory, FPGA read only
    logic [31:0] c2f_head;          // head pointer, FPGA read only
    logic [31:0] c2f_tail;          // tail pointer, CPU read only

    logic [31:0] f2c_kmem_high;     // higher 32 bit of kernel memory, FPGA read only
    logic [31:0] f2c_kmem_low;      // lower 32 bit of kernel memory, FPGA read only
    logic [31:0] f2c_head;          // head pointer, FPGA read only
    logic [31:0] f2c_tail;          // tail pointer, CPU read only
} pcie_block_t;
parameter FT_DWIDTH = (((((((1 + TUPLE_DWIDTH) + 32) + LL_AWIDTH) + 1) + PKT_AWIDTH) + 56) + (4 * FT_AWIDTH));

typedef struct packed {
    logic valid;
    tuple_t tuple;
    logic [31:0] seq;
    logic [LL_AWIDTH-1:0] pointer;
    logic ll_valid;
    logic [PKT_AWIDTH-1:0] slow_cnt;
    logic [55:0] last_7_bytes;
    logic [FT_AWIDTH-1:0] addr0;
    logic [FT_AWIDTH-1:0] addr1;
    logic [FT_AWIDTH-1:0] addr2;
    logic [FT_AWIDTH-1:0] addr3;
} fce_t; // Flow context entry

typedef struct packed {
    tuple_t tuple;
    logic [FT_AWIDTH-1:0] addr0;
    logic [FT_AWIDTH-1:0] addr1;
    logic [FT_AWIDTH-1:0] addr2;
    logic [FT_AWIDTH-1:0] addr3;
    logic [2:0] opcode;
} fce_meta_t;
parameter FT_INSERT = 1;
parameter FT_UPDATE = 2;
parameter FT_DELETE = 3;
parameter PQ_OP_FAST_INSERT = 0;
parameter PQ_OP_FAST_DELETE = 1;
parameter META_WIDTH = (((((((((((8 + TUPLE_DWIDTH) + 32) + 16) + PKT_AWIDTH) + 6) + 5) + 9) + 9) + 3) + 2) + 56);

typedef struct packed {
    logic [7:0] prot;
    tuple_t tuple;
    logic [31:0] seq;
    logic [15:0] len;               // Payload length
    logic [PKT_AWIDTH-1:0] pktID;
    logic [5:0] empty;
    logic [4:0] flits;              // Total number of flits
    logic [8:0] hdr_len;            // In bytes
    logic [8:0] tcp_flags;
    logic [2:0] pkt_flags;
    logic [1:0] pdu_flag;
    logic [55:0] last_7_bytes;
} metadata_t; // Metadata
parameter RID_WIDTH = 16;
parameter RULE_S_WIDTH = (RID_WIDTH + 4);

typedef struct packed {
    logic last;
    logic [2:0] bucket;
    logic [RID_WIDTH-1:0] data;
} rule_s_t; // Metadata
parameter RULE_AWIDTH = 13;
parameter RULE_DEPTH = (1 << RULE_AWIDTH);
parameter PG_RULES = 8;
parameter PG_AWIDTH = 9;
parameter PG_DEPTH = (1 << PG_AWIDTH);
parameter PG_ENTRY_WIDTH = 11;
parameter RULE_PG_WIDTH = (4 * PG_AWIDTH);

typedef struct packed {
    logic [PG_AWIDTH-1:0] pg3;
    logic [PG_AWIDTH-1:0] pg2;
    logic [PG_AWIDTH-1:0] pg1;
    logic [PG_AWIDTH-1:0] pg0;
} rule_pg_t;

typedef struct packed {
    logic tcp;
    logic src;
    logic any;
    logic range;
    logic list;
    logic single;
    logic [4:0] table_index;
} pg_entry_t;
parameter PG_RANGE_DWIDTH = 102;
parameter PG_RANGE_AWIDTH = 5;
parameter PG_RANGE_DEPTH = (1 << PG_RANGE_AWIDTH);

typedef struct packed {
    logic list;
    logic [4:0]  list_index;
    logic [15:0] range_start2;
    logic [15:0] range_end2;
    logic [15:0] range_start1;
    logic [15:0] range_end1;
    logic [15:0] range_start0;
    logic [15:0] range_end0;
} pg_range_t;
parameter PG_LIST_DWIDTH = 112;
parameter PG_LIST_AWIDTH = 5;
parameter PG_LIST_DEPTH = (1 << PG_RANGE_AWIDTH);

typedef struct packed {
    logic [15:0] value6;
    logic [15:0] value5;
    logic [15:0] value4;
    logic [15:0] value3;
    logic [15:0] value2;
    logic [15:0] value1;
    logic [15:0] value0;
} pg_list_t;
parameter PG_HTTP_DWIDTH = 32;
parameter PG_HTTP_AWIDTH = 1;
parameter PG_HTTP_DEPTH = (1 << PG_HTTP_AWIDTH);
parameter NFP_DWIDTH = 128;
parameter NFP_EWIDTH = $clog2((NFP_DWIDTH / 8));
parameter NF_WIDTH = 17;
parameter FP_WIDTH = 128;
parameter BUCKET_WIDTH = (FP_WIDTH / 8);
parameter BUCKET_BITS = $clog2(BUCKET_WIDTH);

typedef struct packed {
    logic last;
    logic [RULE_AWIDTH-1:0] data;
} rule_nf_t; // Metadata
parameter RULE_NF_WIDTH = (RULE_AWIDTH + 1);
parameter NF_IN_RULES = 8;
parameter NF_OUT_RULES = 2;
parameter PDU_DEPTH = 4096;
parameter PDU_AWIDTH = $clog2(PDU_DEPTH);
parameter PDU_NUM = 256;
parameter PDUBUF_AWIDTH = ($clog2(PDU_NUM) + 5);
parameter PDUBUF_DEPTH = (32 * PDU_NUM);
parameter PDUID_WIDTH = $clog2(PDU_NUM);

typedef struct packed {
    logic [223:0] padding;
    logic [31:0] action;
    logic [31:0] pdu_flit;
    logic [31:0] pdu_size;
    logic [31:0] num_ruleID;
    logic [31:0] prot;
    tuple_t tuple;
    logic [31:0] pdu_id;
} pdu_hdr_t;
parameter RB_DEPTH = 261567;
parameter RB_AWIDTH = $clog2(RB_DEPTH);
parameter RB_BRAM_OFFSET = 4;
parameter C2F_RB_DEPTH = 512;
parameter C2F_RB_AWIDTH = $clog2(C2F_RB_DEPTH);
parameter ACTION_NOCHECK = 0;
parameter ACTION_NOMATCH = 1;
parameter ACTION_MATCH = 2;
parameter ACTION_CHECK = 3;
parameter ACTION_WIDTH = 4;
parameter PDU_META_WIDTH = (((PDUID_WIDTH + ACTION_WIDTH) + 5) + 11);

typedef struct packed {
    logic [PDUID_WIDTH-1:0]  pdu_id;
    logic [ACTION_WIDTH-1:0] action;
    logic [4:0]              flits; // Total number of flits
    logic [10:0]             pdu_size;
} pdu_metadata_t; // Metadata
parameter DDR_WR_WIDTH = ((27 + 512) + 2);

typedef struct packed {
    logic [26:0]    addr;
    logic [511:0]   data;
    logic           sop;
    logic           eop;
} ddr_wr_t;
parameter DDR_RD_WIDTH = 29;

typedef struct packed
{
    logic [26:0] addr;
    logic        sop;
    logic        eop;
} ddr_rd_t;
parameter DDR_REQ_WIDTH = ((27 + 512) + 1);

typedef struct packed {
    logic           wr;
    logic [26:0]    addr;
    logic [511:0]   data;
} ddr_req_t;

//Flow control
typedef struct packed
{
    logic [47:0] eth_dst_mac;
    logic [47:0] eth_src_mac;
    logic [15:0] eth_type;
    logic [3:0]  ip_version;
    logic [3:0]  ip_ihl;
    logic [5:0]  ip_dscp;
    logic [1:0]  ip_ecn;
    logic [15:0] ip_len;
    logic [15:0] ip_id;
    logic [2:0]  ip_flags;
    logic [12:0] ip_fo;
    logic [7:0]  ip_ttl;
    logic [7:0]  ip_prot;
    logic [15:0] ip_chsm;
    logic [31:0] ip_sip;
    logic [31:0] ip_dip;
    logic [15:0] udp_sport;
    logic [15:0] udp_dport;
    logic [15:0] udp_len;
    logic [15:0] udp_chsm;
} udp_hdr_t;    


typedef struct packed
{
    udp_hdr_t     udp_hdr;
    logic [31:0]  data;
    logic [143:0] padding;
} ack_pkt_t;

`endif
