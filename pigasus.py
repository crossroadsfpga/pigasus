#### Pigasus 2.0 Fluid Configuration ####
# This file is used to generate new Pigasus 2.0 based designs.
# In short - to run this just run "python3 pigasus.py" from the terminal.
#
# Sections:
# PARAMETER CONFIGURATION: customize Pigasus modules' parameters.
# DEFINITIONS: define modules and/or see examples of modules.
# TOP LEVEL PORTS: see and/or add/subtract new ports to the toplevel.
# OBJECTS: instantiate objects here.
# CONNECTIONS: define connections between objects
# RUN PASSES: choose which passes to run (limited selection right now)

import sys
import os

from fluid.header import *
from fluid.vtl import *
from fluid.genericplatform import *
from fluid.visualizer import *
from fluid.services import *
from fluid.connections import *

#### PARAMETER CONFIGURATION ####
# use this to configure parameters in struct_s.sv
# {constant name}_V is the value of {constant name} for disambiguation
# some constants may be repeated with different suffixes if eg. there is a choice
# for eg. PKT_NUM has PKT_NUM_BRAM_V and PKT_NUM_V for with BRAM or without

# if you are going to script this, note that they MUST be global variables for the generator
# to pick them up.

PKT_NUM_BRAM_V = 1024
PKT_NUM_V = 2688

FT_SUBTABLE_V = 4
FT_SIZE_V = 8192
PQ_DEPTH_V = 8

HEADER_OFFSET_V = 1

FP_DWIDTH_V = 256

ETH_HDR_LEN_V = 14
SRC_MAC_V = "48'h112233445566"
DST_MAC_V = "48'h665544332211"
ETH_IP_V = "16'h0800"
ETH_META_V = "16'hFFFE"
ETH_USR_V = "16'hFFFF"
PROT_ETH_V = "16'h0800"
IP_V4_V = "4'h4"
PROT_TCP_V = "8'h06"
PROT_UDP_V = "8'h11"
NS_V = "8'hFF"

TCP_FIN_V = 0
TCP_SYN_V = 1
TCP_RST_V = 2
TCP_PSH_V = 3
TCP_FACK_V = 4
TCP_URG_V = 5
TCP_ECE_V = 6
TCP_CWR_V = 7
TCP_NS_V = 8

PKT_FORWARD_V = 0
PKT_DROP_V = 1
PKT_CHECK_V = 2
PKT_OOO_V = 3
PKT_FORWARD_OOO_V = 4
PKT_DONE_V = 5

STAT_AWIDTH_V = 5
ETH_0_REG_V = "5'b00_000"
ETH_1_REG_V = "5'b00_001"
TOP_REG_V = "5'b10_001"
STATS_0_REG_V = "5'b10_010"
PCIE_V = "5'b10_101"
DRAM_V = "5'b10_110"

PDU_NO_V = "2'b00"
PDU_FIRST_V = "2'b01"
PDU_MIDDLE_V = "2'b10"
PDU_LAST_V = "2'b11"

FT_INSERT_V = 1
FT_UPDATE_V = 2
FT_DELETE_V = 3
PQ_OP_FAST_INSERT_V = 0
PQ_OP_FAST_DELETE_V = 1

RID_WIDTH_V = 16

RULE_AWIDTH_V = 13
PG_RULES_V = 8 
PG_AWIDTH_V = 9
PG_ENTRY_WIDTH_V = 11

PG_RANGE_DWIDTH_V = 102
PG_RANGE_AWIDTH_V = 5

PG_LIST_DWIDTH_V = 112
PG_LIST_AWIDTH_V = 5

PG_HTTP_DWIDTH_V = 32
PG_HTTP_AWIDTH_V = 11

NFP_DWIDTH_V = 128
NF_WIDTH_V = 17
FP_WIDTH_V = 128
NF_IN_RULES_V = 8
NF_OUT_RULES_V = 2

PDU_DEPTH_V = 4096
PDU_NUM_V = 256

RB_DEPTH_V = 261567
RB_BRAM_OFFSET_V = 4

C2F_RB_DEPTH_V = 512

ACTION_NOCHECK_V = 0
ACTION_NOMATCH_V = 1
ACTION_MATCH_V = 2
ACTION_CHECK_V = 3
ACTION_WIDTH_V = 4


# if you want to change a constant that's not above, change it 
# in the struct_s() "function" below. This is a VTL function.
# VTL is a custom DSL for writing Verilog directly from Python.
# This function has no effect at Python run time.

@vtl_nomodule
def struct_s():
    # packet stuff
    T("""
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
`ifdef USE_BRAM""")
    PKT_NUM = Param(PKT_NUM_BRAM_V)
    T("`else")
    PKT_NUM = Param(PKT_NUM_V)
    T("`endif")
    
    PKTBUF_AWIDTH = Param(clog2(PKT_NUM) + 5)
    PKTBUF_DEPTH = Param(32 * PKT_NUM)
    PKT_AWIDTH = Param(clog2(PKT_NUM))

    # Flow table
    FT_SUBTABLE = Param(FT_SUBTABLE_V)
    FT_SIZE = Param(FT_SIZE_V)
    FT_DEPTH = Param(FT_SIZE/FT_SUBTABLE)
    FT_AWIDTH = Param(clog2(FT_DEPTH))
    PQ_DEPTH = Param(PQ_DEPTH_V)
    PQ_AWIDTH = Param(clog2(PQ_DEPTH))

    # Linked list
    LL_DEPTH = Param(PKT_NUM/2)
    LL_AWIDTH = Param(clog2(LL_DEPTH))
    HEADER_OFFSET = Param(HEADER_OFFSET_V)

    # Fast pattern
    FP_DWIDTH = Param(FP_DWIDTH_V)
    FP_EWIDTH = Param(clog2(FP_DWIDTH/8))

    # Ethernet
    ETH_HDR_LEN = Param(ETH_HDR_LEN_V)
    SRC_MAC = Param(SRC_MAC_V)
    DST_MAC = Param(DST_MAC_V)
    ETH_IP = Param(ETH_IP_V)
    ETH_META = Param(ETH_META_V)
    ETH_USR = Param(ETH_USR_V)
    
    PROT_ETH = Param(PROT_ETH_V)
    IP_V4 = Param(IP_V4_V)
    PROT_TCP = Param(PROT_TCP_V)
    PROT_UDP = Param(PROT_UDP_V)

    NS = Param(NS_V)
    S_UDP = Param(PROT_UDP)
    S_TCP = Param(PROT_TCP)

    TCP_FIN = Param(TCP_FIN_V)
    TCP_SYN = Param(TCP_SYN_V)
    TCP_RST = Param(TCP_RST_V)
    TCP_PSH = Param(TCP_PSH_V)
    TCP_FACK = Param(TCP_FACK_V)
    TCP_URG = Param(TCP_URG_V)
    TCP_ECE = Param(TCP_ECE_V)
    TCP_CWR = Param(TCP_CWR_V)
    TCP_NS = Param(TCP_NS_V)

    PKT_FORWARD = Param(PKT_FORWARD_V)
    PKT_DROP = Param(PKT_DROP_V)
    PKT_CHECK = Param(PKT_CHECK_V)
    PKT_OOO = Param(PKT_OOO_V)
    PKT_FORWARD_OOO = Param(PKT_FORWARD_OOO_V)
    PKT_DONE = Param(PKT_DONE_V)

    # Stats
    STAT_AWIDTH = Param(STAT_AWIDTH_V)
    ETH_0_REG = Param(ETH_0_REG_V)
    ETH_1_REG = Param(ETH_1_REG_V)
    TOP_REG = Param(TOP_REG_V)
    STATS_0_REG = Param(STATS_0_REG_V)
    PCIE = Param(PCIE_V)
    DRAM = Param(DRAM_V)

    # PDU
    PDU_NO = Param(PDU_NO_V)
    PDU_FIRST = Param(PDU_FIRST_V)
    PDU_MIDDLE = Param(PDU_MIDDLE_V)
    PDU_LAST = Param(PDU_LAST_V)

    T("""
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
} flit_meta_t;""")

    # Linked list entry
    LL_DWIDTH = Param(1 + 32 + 16 + 16 + PKT_AWIDTH + 1 + 56)
    T("""
typedef struct packed {
    logic valid;                    // Valid
    logic [31:0] seq;               // Sequence
    logic [15:0] len;               // Length
    logic [LL_AWIDTH-1:0] next;     // Next
    logic [PKT_AWIDTH-1:0] pktID;   // PktID
    logic [4:0] flits;
    logic last;                     // Last
    logic [55:0] last_7_bytes;      // Last
} entry_t;""")

    # Tuple
    TUPLE_DWIDTH = Param(32 + 32 + 16 + 16)
    T("""
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
} pcie_block_t;""")

    FT_DWIDTH = Param(1 + TUPLE_DWIDTH + 32 + LL_AWIDTH + 1 + PKT_AWIDTH + 56 + (4 * FT_AWIDTH))
    T("""
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
} fce_meta_t;""")

    FT_INSERT = Param(FT_INSERT_V)
    FT_UPDATE = Param(FT_UPDATE_V)
    FT_DELETE = Param(FT_DELETE_V)

    PQ_OP_FAST_INSERT = Param(PQ_OP_FAST_INSERT_V)
    PQ_OP_FAST_DELETE = Param(PQ_OP_FAST_DELETE_V)

    META_WIDTH = Param(8 + TUPLE_DWIDTH + 32 + 16 + PKT_AWIDTH + 6 + 5 + 9 + 9 + 3 + 2 + 56)
    T("""
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
} metadata_t; // Metadata""")

    RID_WIDTH = Param(RID_WIDTH_V)
    RULE_S_WIDTH = Param(RID_WIDTH + 4)
    T("""
typedef struct packed {
    logic last;
    logic [2:0] bucket;
    logic [RID_WIDTH-1:0] data;
} rule_s_t; // Metadata""")

    RULE_AWIDTH = Param(RULE_AWIDTH_V)
    RULE_DEPTH = Param(1 << RULE_AWIDTH)
    PG_RULES = Param(PG_RULES_V)
    PG_AWIDTH = Param(PG_AWIDTH_V)
    PG_DEPTH = Param(1 << PG_AWIDTH)
    PG_ENTRY_WIDTH = Param(PG_ENTRY_WIDTH_V)
    RULE_PG_WIDTH = Param(4 * PG_AWIDTH)
    T("""
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
} pg_entry_t;""")

    PG_RANGE_DWIDTH = Param(PG_RANGE_DWIDTH_V)
    PG_RANGE_AWIDTH = Param(PG_RANGE_AWIDTH_V)
    PG_RANGE_DEPTH = Param(1 << PG_RANGE_AWIDTH)
    T("""
typedef struct packed {
    logic list;
    logic [4:0]  list_index;
    logic [15:0] range_start2;
    logic [15:0] range_end2;
    logic [15:0] range_start1;
    logic [15:0] range_end1;
    logic [15:0] range_start0;
    logic [15:0] range_end0;
} pg_range_t;""")

    PG_LIST_DWIDTH = Param(PG_LIST_DWIDTH_V)
    PG_LIST_AWIDTH = Param(PG_LIST_AWIDTH_V)
    PG_LIST_DEPTH = Param(1 << PG_RANGE_AWIDTH)
    T("""
typedef struct packed {
    logic [15:0] value6;
    logic [15:0] value5;
    logic [15:0] value4;
    logic [15:0] value3;
    logic [15:0] value2;
    logic [15:0] value1;
    logic [15:0] value0;
} pg_list_t;""")

    PG_HTTP_DWIDTH = Param(PG_HTTP_DWIDTH_V)
    PG_HTTP_AWIDTH = Param(PG_HTTP_AWIDTH_V)
    PG_HTTP_DEPTH = Param(1 << PG_HTTP_AWIDTH)

    NFP_DWIDTH = Param(NFP_DWIDTH_V)
    NFP_EWIDTH = Param(clog2(NFP_DWIDTH/8))
    NF_WIDTH = Param(NF_WIDTH_V)
    FP_WIDTH = Param(FP_WIDTH_V)
    BUCKET_WIDTH = Param(FP_WIDTH/8)
    BUCKET_BITS = Param(clog2(BUCKET_WIDTH))
    T("""
typedef struct packed {
    logic last;
    logic [RULE_AWIDTH-1:0] data;
} rule_nf_t; // Metadata""")
    RULE_NF_WIDTH = Param(RULE_AWIDTH + 1)
    NF_IN_RULES = Param(NF_IN_RULES_V)
    NF_OUT_RULES = Param(NF_OUT_RULES_V)

    PDU_DEPTH = Param(PDU_DEPTH_V)
    PDU_AWIDTH = Param(clog2(PDU_DEPTH))
    PDU_NUM = Param(PDU_NUM_V)
    PDUBUF_AWIDTH = Param(clog2(PDU_NUM) + 5)
    PDUBUF_DEPTH = Param(32 * PDU_NUM)
    PDUID_WIDTH = Param(clog2(PDU_NUM))
    T("""
typedef struct packed {
    logic [223:0] padding;
    logic [31:0] action;
    logic [31:0] pdu_flit;
    logic [31:0] pdu_size;
    logic [31:0] num_ruleID;
    logic [31:0] prot;
    tuple_t tuple;
    logic [31:0] pdu_id;
} pdu_hdr_t;""")

    RB_DEPTH = Param(RB_DEPTH_V)
    RB_AWIDTH = Param(clog2(RB_DEPTH))
    RB_BRAM_OFFSET = Param(RB_BRAM_OFFSET_V)

    C2F_RB_DEPTH = Param(C2F_RB_DEPTH_V)
    C2F_RB_AWIDTH = Param(clog2(C2F_RB_DEPTH))

    ACTION_NOCHECK = Param(ACTION_NOCHECK_V)
    ACTION_NOMATCH = Param(ACTION_NOMATCH_V)
    ACTION_MATCH = Param(ACTION_MATCH_V)
    ACTION_CHECK = Param(ACTION_CHECK_V)
    ACTION_WIDTH = Param(ACTION_WIDTH_V)

    PDU_META_WIDTH = Param(PDUID_WIDTH + ACTION_WIDTH + 5 + 11)
    T("""
typedef struct packed {
    logic [PDUID_WIDTH-1:0]  pdu_id;
    logic [ACTION_WIDTH-1:0] action;
    logic [4:0]              flits; // Total number of flits
    logic [10:0]             pdu_size;
} pdu_metadata_t; // Metadata""")

    DDR_WR_WIDTH = Param(27 + 512 + 2)
    T("""
typedef struct packed {
    logic [26:0]    addr;
    logic [511:0]   data;
    logic           sop;
    logic           eop;
} ddr_wr_t;""")

    DDR_RD_WIDTH = Param(29)
    T("""
typedef struct packed
{
    logic [26:0] addr;
    logic        sop;
    logic        eop;
} ddr_rd_t;""")

    DDR_REQ_WIDTH = Param(27 + 512 + 1)
    T("""
typedef struct packed {
    logic           wr;
    logic [26:0]    addr;
    logic [511:0]   data;
} ddr_req_t;

`endif""")

#### DEFINITIONS ####
# For other service class definitions, see fluid/services.py
# For definitions of connections, see fluid/connections.py

# An example that can be slotted into Pigasus 2.0
# class Identity(Service):
#     def __init__(self, name):
#         super().__init__("identity", SourceType.SYSTEM_VERILOG, name)
#         self.add_extern_connection("clk", "clk_pcie")
#         self.add_extern_connection("rst_n", "rst_n_pcie")
        
#         self.add_provides("in_pkt", 32, 512, channel_type="Packet")
#         self.add_provides("in_meta", 32, 512, channel_type="Meta")
#         self.add_provides("in_usr", 32, 512, channel_type="Usr")

#         self.add_requires("out_pkt", channel_type="Packet")
#         self.add_requires("out_meta", channel_type="Meta")
#         self.add_requires("out_usr", channel_type="Usr")


        


# Start constructing the application
registers = GenericRegisters("soma_csr", SourceType.SYSTEM_VERILOG)
platform = GenericPlatform("clk", "rst_n", registers)

# Use ugly hack for pasting some prewritten code that doesn't quite fit into Fluid
# TODO: get rid of top_base.sv somehow (new module?)
app = Application(platform, path_prefix="./", top_name="top", top_includes=["./src/struct_s.sv", "./src/stats_reg.sv"], paste_files=["top_base.sv"], hide_controls=True)

#### TOP LEVEL PORTS ####
# Clocks, resets, and other external signals
#
# Tip: use self.add_extern_connection() from inside your service
# to connect to one of these signals (example usage in fluid/services.py)
# Direction is specified relative to Pigasus (eg. clocks are inputs)
app.add_extern("clk", 1, Direction.INPUT)
app.add_extern("rst", 1, Direction.INPUT)
app.add_extern("clk_high", 1, Direction.INPUT)
app.add_extern("rst_high", 1, Direction.INPUT)
app.add_extern("clk_pcie", 1, Direction.INPUT)
app.add_extern("rst_pcie", 1, Direction.INPUT)
app.add_extern("in_sop", 1, Direction.INPUT)
app.add_extern("in_eop", 1, Direction.INPUT)
app.add_extern("in_data", 512, Direction.INPUT)
app.add_extern("in_empty", 6, Direction.INPUT)
app.add_extern("in_valid", 1, Direction.INPUT)
app.add_extern("out_data", 512, Direction.OUTPUT)
app.add_extern("out_valid", 1, Direction.OUTPUT)
app.add_extern("out_sop", 1, Direction.OUTPUT)
app.add_extern("out_eop", 1, Direction.OUTPUT)
app.add_extern("out_empty", 6, Direction.OUTPUT)
app.add_extern("out_ready", 1, Direction.INPUT)
app.add_extern("pkt_buf_wren", 1, Direction.OUTPUT)
app.add_extern("pkt_buf_wraddress", 17, Direction.OUTPUT)
app.add_extern("pkt_buf_rdaddress", 17, Direction.OUTPUT)
app.add_extern("pkt_buf_wrdata", 520, Direction.OUTPUT)
app.add_extern("pkt_buf_rden", 1, Direction.OUTPUT)
app.add_extern("pkt_buf_rd_valid", 1, Direction.INPUT)
app.add_extern("pkt_buf_rddata", 520, Direction.INPUT)
app.add_extern("pcie_rb_wr_data", 514, Direction.OUTPUT)
app.add_extern("pcie_rb_wr_addr", 12, Direction.OUTPUT)
app.add_extern("pcie_rb_wr_en", 1, Direction.OUTPUT)
app.add_extern("pcie_rb_wr_base_addr", 12, Direction.INPUT)
app.add_extern("pcie_rb_almost_full", 1, Direction.INPUT)
app.add_extern("pcie_rb_update_valid", 1, Direction.OUTPUT)
app.add_extern("pcie_rb_update_size", 12, Direction.OUTPUT)
app.add_extern("disable_pcie", 1, Direction.INPUT)
app.add_extern("pdumeta_cpu_data", 28, Direction.INPUT)
app.add_extern("pdumeta_cpu_valid", 1, Direction.INPUT)
app.add_extern("pdumeta_cnt", 10, Direction.OUTPUT)
app.add_extern("ddr_wr_req_data", 541, Direction.OUTPUT)
app.add_extern("ddr_wr_req_valid", 1, Direction.OUTPUT)
app.add_extern("ddr_wr_req_almost_full", 1, Direction.INPUT)
app.add_extern("ddr_rd_req_data", 29, Direction.OUTPUT)
app.add_extern("ddr_rd_req_valid", 1, Direction.OUTPUT)
app.add_extern("ddr_rd_req_almost_full", 1, Direction.INPUT)
app.add_extern("ddr_rd_resp_data", 512, Direction.INPUT)
app.add_extern("ddr_rd_resp_valid", 1, Direction.INPUT)
app.add_extern("ddr_rd_resp_almost_full", 1, Direction.OUTPUT)
app.add_extern("clk_status", 1, Direction.INPUT)
app.add_extern("status_addr", 30, Direction.INPUT)
app.add_extern("status_read", 1, Direction.INPUT)
app.add_extern("status_write", 1, Direction.INPUT)
app.add_extern("status_writedata", 32, Direction.INPUT)
app.add_extern("status_readdata", 32, Direction.OUTPUT)
app.add_extern("status_readdata_valid", 1, Direction.OUTPUT)

#### OBJECTS ####
# This section just creates objects, it does not wire them up.
# For creating connections, see next section (CONNECTIONS)

# Reassembler
reassembler = Reassembler("r")

# FIFO group from reassembler to FPM
dm2sm_cf = make_channel_fifo("clk", "rst_n", "dm2sm_fill_level")

# Fast Pattern Matcher
fpm = FastPatternMatcher("fpm")

# FIFO group from FPM to PGM
sm2pg_cf = make_channel_fifo("clk_pcie", "rst_n_pcie", "sm2pg_fill_level", dual_clock=True, clk_o="clk_pcie", rst_n_o="rst_n_pcie")

# Port Group Matcher
pgm = PortGroupMatcher("pg")

# FIFO group from  PGM to NFM
pg2nf_cf = make_channel_fifo("clk_pcie", "rst_n_pcie", "pg2nf_fill_level")

# Non-Fast Pattern Matcher
nfp = NonFastPatternMatcher("nf")

# FIFO group from NFM to CPU
bypassback2pdu_cf = make_channel_fifo("clk_pcie", "rst_n_pcie", "nf2pdu_fill_level")

# Confusingly, this is the CPU
# Named so because this module DMAs data around
dma = DMA("dma")

# FIFO from reassembly to ethernet
nopayload = make_unified_fifo("clk", "rst_n", "[top] fifo0", "dm_nopayload_pkt_csr_readdata")("fifo0")

# FIFO from FPM to ethernet
sm_nocheck = make_unified_fifo("clk_pcie", "rst_n_pcie", "[top] fifo1", "sm_nocheck_pkt_csr_readdata", dual_clock=True, clk_o="clk", rst_n_o="rst_n")("fifo1")

# FIFO from PGM to ethernet
pg_nocheck = make_unified_fifo("clk_pcie", "rst_n_pcie", "[top] fifo2", "pg_nocheck_pkt_csr_readdata", dual_clock=True, clk_o="clk", rst_n_o="rst_n")("fifo2")

# FIFO from NFM to ethernet
nf_nocheck = make_unified_fifo("clk_pcie", "rst_n_pcie", "[top] fifo3", "nf_nocheck_pkt_csr_readdata", dual_clock=True, clk_o="clk", rst_n_o="rst_n")("fifo3")

# FIFO from DMA (CPU) to ethernet
nomatch = make_unified_fifo("clk_pcie", "rst_n_pcie", "[top] fifo4", "nomatch_pkt_csr_readdata", dual_clock=True, clk_o="clk", rst_n_o="rst_n")("fifo4")

# Ethernet interface
eth = Ethernet("ethernet")

#### Example module ####
# a block that does nothing, it just passes the data through
# like an identity function
# identity = Identity("id")

# FIFO to and from example module 
#identity_cf = make_channel_fifo("clk_pcie", "rst_n_pcie", "identity_fill_level")
#identity_cf2 = make_channel_fifo("clk_pcie", "rst_n_pcie", "identity2_fill_level")


#### CONNECTIONS ####
# Make connections between objects. This does not instantiate objects.
# If you want to instantiate new objects, see previous section (OBJECTS)
#
# Example usage: follow the instructions below with the tag
# * [ADD IDENTITY] to add Identity to the design between PGM and NFP
# (do only one at a time if you are following the instructions!)

# An app.direct() connection is a builtin connection type from the generator
# It generates to simple wires, no buffering
# app.noc() and app.fifo() are available in the full Fluid generator for NOC and FIFO connections
app.direct(eth.requires["in"], reassembler.provides["eth"])
app.direct(nopayload.requires["out"], eth.provides["out0"])
app.direct(nf_nocheck.requires["out"], eth.provides["out1"])
app.direct(nomatch.requires["out"], eth.provides["out2"])
app.direct(sm_nocheck.requires["out"], eth.provides["out3"])

app.direct(pg_nocheck.requires["out"], eth.provides["out4"])

# connect_channel_fifo() is a compound connection type
connect_channel_fifo_auto(app, dm2sm_cf, "dm2sm", reassembler, fpm)
connect_channel_fifo(app, sm2pg_cf, "sm2pg", fpm, pgm)

# [ADD IDENTITY] uncomment these two lines to connect PGM -> Identity -> NFP
#connect_channel_fifo_auto(app, identity_cf, "idc", pgm, identity)
#connect_channel_fifo_auto(app, identity_cf2, "idc2", identity, nfp)

# [ADD IDENTITY] comment this line to add Identity because we don't want PGM connected to both NFP and Identity
connect_channel_fifo_auto(app, pg2nf_cf, "pg2nf", pgm, nfp)

connect_channel_fifo_auto(app, bypassback2pdu_cf, "by2pd", nfp, dma)

app.direct(reassembler.requires["nopayload"], nopayload.provides["in"])
app.direct(fpm.requires["fp_nocheck"], sm_nocheck.provides["in"])
app.direct(pgm.requires["pg_nocheck"], pg_nocheck.provides["in"])
app.direct(nfp.requires["nfp_nocheck"], nf_nocheck.provides["in"])
app.direct(dma.requires["nomatch_pkt"], nomatch.provides["in"])


#### RUN PASSES ####

pass_manager = PassManager(app)
pass_manager.add_pass(GenericAnalysisPass)
pass_manager.add_pass(GenericTopPass)
pass_manager.add_pass(generate_visualizer_pass(VisualizerType.DEFAULT))
pass_manager.schedule_and_run_passes()

# to get the top.sv out
# let's write them to a build directory
os.system("rm -rf build && mkdir build")

# the files in AST form are located in the pass manager's data dict under "files"
# we know the file is called "top.sv"
# first compile it down to a string and then write that string to a chosen file
with open("build/top.sv", "w") as handle:
    top_ast = pass_manager.data["files"]["top.sv"]
    top_str = top_ast.compile(0)
    handle.write(top_str)

# the struct_s.sv file comes from the "function" at the beginning of this file
# it doesn't actually go through the generator
# so we just compile it directly by giving this file itself as the source
# it has to be the first result item since there's only one VTL "function"
# this may need to be changed if you write other VTL functions
with open("build/struct_s.sv", "w") as handle:
    struct_s_ast = vtl_compile(open(__file__).read())[0]
    struct_s_str = struct_s_ast.compile(0)
    handle.write(struct_s_str)

