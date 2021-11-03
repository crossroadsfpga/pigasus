#### Pigasus 2.0 Fluid Services ####
from .header import *
from .parse_ast import *

# All Fluid services must inherit from the base Service class
# Reassembles network stream into TCP packets
class Reassembler(Service):
    def __init__(self, name):
        # the name of the implementing file reassembler_service.sv (note the lack of file extension)
        super().__init__("reassembler_service", SourceType.SYSTEM_VERILOG, name)

        # connect to clock and reset of the top level
        # argument order is (internal_name_in_SV_file, external_name_in_top_level)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")

        # misc connections
        self.add_extern_connection("pkt_buffer_writeaddress", "pkt_buf_wraddress")
        self.add_extern_connection("pkt_buffer_write", "pkt_buf_wren")
        self.add_extern_connection("pkt_buffer_writedata", "pkt_buf_wrdata")

        self.add_extern_connection("pkt_buffer_readaddress", "pkt_buf_rdaddress")
        self.add_extern_connection("pkt_buffer_read", "pkt_buf_rden")
        self.add_extern_connection("pkt_buffer_readvalid", "pkt_buf_rd_valid")
        self.add_extern_connection("pkt_buffer_readdata", "pkt_buf_rddata")

        # stats and sundry
        self.add_control("parser_meta_csr_readdata", 32, Direction.OUTPUT)
        self.add_control("stats_incomp_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_parser_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_ft_in_meta", 32, Direction.OUTPUT)
        self.add_control("stats_ft_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_emptylist_in", 32, Direction.OUTPUT)
        self.add_control("stats_emptylist_out", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_forward_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_drop_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_check_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_ooo_meta", 32, Direction.OUTPUT)
        self.add_control("stats_dm_in_forward_ooo_meta", 32, Direction.OUTPUT)
        self.add_control("stats_nopayload_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_dm_check_pkt", 32, Direction.OUTPUT)

        # again, confusing provides-requires relationship here
        # note that "input" and "output" ports are just "conventional" data flow direction
        # all ports are actually bidirectional

        # basically, it "provides" a place for Ethernet to push packets (input ports)
        self.add_provides("eth", 32, 512, channel_type="Ethernet")

        # it requires an ethernet service to push nopayload packets to (output ports)
        self.add_requires("nopayload", channel_type="Nopayload")

        # it requires the rest of Pigasus to send reassembled packets to (output ports)
        self.add_requires("out_pkt", channel_type="Packet")
        self.add_requires("out_meta", channel_type="Meta")
        self.add_requires("out_usr", channel_type="Usr")


# fastest (and also simplest) pattern matcher stage
class FastPatternMatcher(Service):
    def __init__(self, name):
        super().__init__("fast_pm_service", SourceType.SYSTEM_VERILOG, name)
        # this module crosses a bunch of clock domains, so connect it to all the clocks in the toplevel
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")
        self.add_extern_connection("Clk_front", "clk_high")
        self.add_extern_connection("Rst_front_n", "rst_n")
        self.add_extern_connection("Clk_back", "clk_pcie")
        self.add_extern_connection("Rst_back_n", "rst_n_pcie")

        # stats and stuff
        self.add_control("sm_bypass_af", 32, Direction.OUTPUT)
        self.add_control("sm_cdc_af", 32, Direction.OUTPUT)

        self.add_control("stats_out_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_out_rule", 32, Direction.OUTPUT)
        self.add_control("stats_nocheck_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt_s", 32, Direction.OUTPUT)

        # similar logic as the Reassembler service above
        # FPM "provides" a place for Reassembler to push packets (input ports)
        self.add_provides("in_pkt", 32, 512, channel_type="Packet")
        self.add_provides("in_meta", 32, 512, channel_type="Meta")
        self.add_provides("in_usr", 32, 512, channel_type="Usr")

        # FPM "requires" an Ethernet service to push nocheck packets to (output ports)
        self.add_requires("fp_nocheck", channel_type="FPNocheck")

        # FPM "requires" the rest of Pigasus to push packets to (output ports)
        self.add_requires("out_pkt", channel_type="Packet")
        self.add_requires("out_meta", channel_type="Meta")
        self.add_requires("out_usr", channel_type="Usr")


# port group matcher
# same explanations as above
class PortGroupMatcher(Service):
    def __init__(self, name):
        super().__init__("port_group_matcher_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk_pcie")
        self.add_extern_connection("Rst_n", "rst_n_pcie")

        self.add_control("stats_out_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_out_rule", 32, Direction.OUTPUT)
        self.add_control("stats_nocheck_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt_s", 32, Direction.OUTPUT)
        self.add_control("pg_no_pg_rule_cnt", 32, Direction.OUTPUT)
        self.add_control("pg_int_rule_cnt", 32, Direction.OUTPUT)

        self.add_provides("in_pkt", 32, 512, channel_type="Packet")
        self.add_provides("in_meta", 32, 512, channel_type="Meta")
        self.add_provides("in_usr", 32, 512, channel_type="Usr")
        self.add_requires("pg_nocheck", channel_type="PGNocheck")
        self.add_requires("out_pkt", channel_type="Packet")
        self.add_requires("out_meta", channel_type="Meta")
        self.add_requires("out_usr", channel_type="Usr")


# slow, more elaborate pattern matcher
# same explanations as above
class NonFastPatternMatcher(Service):
    def __init__(self, name):
        super().__init__("non_fast_pm_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk_pcie")
        self.add_extern_connection("Rst_n", "rst_n_pcie")
        self.add_extern_connection("Clk_high", "clk_high")
        self.add_extern_connection("Rst_high_n", "rst_n_high")

        self.add_control("stats_out_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_out_meta", 32, Direction.OUTPUT)
        self.add_control("stats_out_rule", 32, Direction.OUTPUT)
        self.add_control("stats_nocheck_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_check_pkt_s", 32, Direction.OUTPUT)
        self.add_control("stats_bypass_pkt", 32, Direction.OUTPUT)
        self.add_control("stats_bypass_pkt_s", 32, Direction.OUTPUT)
        self.add_control("stats_bypass_meta", 32, Direction.OUTPUT)
        self.add_control("stats_bypass_rule", 32, Direction.OUTPUT)

        self.add_control("bypass_fill_level", 32, Direction.OUTPUT)
        self.add_control("bypass2nf_fill_level", 32, Direction.OUTPUT)
        self.add_control("nf2bypass_fill_level", 32, Direction.OUTPUT)
        self.add_control("nf_max_raw_pkt_fifo", 32, Direction.OUTPUT)
        self.add_control("nf_max_pkt_fifo", 32, Direction.OUTPUT)
        self.add_control("nf_max_rule_fifo", 32, Direction.OUTPUT)

        self.add_provides("in_pkt", 32, 512, channel_type="Packet")
        self.add_provides("in_meta", 32, 512, channel_type="Meta")
        self.add_provides("in_usr", 32, 512, channel_type="Usr")
        self.add_requires("nfp_nocheck")
        self.add_requires("out_pkt", channel_type="Packet")
        self.add_requires("out_meta", channel_type="Meta")
        self.add_requires("out_usr", channel_type="Usr")


# talks to the CPU for the really complicated matching cases
# the externs are PCIe signals 
class DMA(Service):
    def __init__(self, name):
        super().__init__("dma_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk_pcie")
        self.add_extern_connection("Rst_n", "rst_n_pcie")

        # attach this module's signals to PCIe connections at the top level
        self.add_extern_connection("pcie_rb_wr_data", "pcie_rb_wr_data")
        self.add_extern_connection("pcie_rb_wr_addr", "pcie_rb_wr_addr")
        self.add_extern_connection("pcie_rb_wr_en", "pcie_rb_wr_en")
        self.add_extern_connection("pcie_rb_wr_base_addr", "pcie_rb_wr_base_addr")
        self.add_extern_connection("pcie_rb_almost_full", "pcie_rb_almost_full")
        self.add_extern_connection("pcie_rb_update_valid", "internal_rb_update_valid")
        self.add_extern_connection("pcie_rb_update_size", "pcie_rb_update_size")
        self.add_extern_connection("disable_pcie", "disable_pcie")
        self.add_extern_connection("pdumeta_cpu_data", "pdumeta_cpu_data")
        self.add_extern_connection("pdumeta_cpu_valid", "pdumeta_cpu_valid")
        self.add_extern_connection("pdumeta_cpu_ready", "pdumeta_cpu_ready")
        self.add_extern_connection("pdumeta_cpu_csr_readdata", "pdumeta_cpu_csr_readdata")
        self.add_extern_connection("ddr_wr_req_data", "ddr_wr_req_data")
        self.add_extern_connection("ddr_wr_req_valid", "ddr_wr_req_valid")
        self.add_extern_connection("ddr_wr_req_almost_full", "ddr_wr_req_almost_full")
        self.add_extern_connection("ddr_rd_req_data", "ddr_rd_req_data")
        self.add_extern_connection("ddr_rd_req_valid", "ddr_rd_req_valid")
        self.add_extern_connection("ddr_rd_req_almost_full", "ddr_rd_req_almost_full")
        self.add_extern_connection("ddr_rd_resp_data", "ddr_rd_resp_out_data")
        self.add_extern_connection("ddr_rd_resp_valid", "ddr_rd_resp_out_valid")
        self.add_extern_connection("ddr_rd_resp_almost_full", "ddr_rd_resp_out_ready")

        self.add_provides("in_pkt", 32, 512, channel_type="Packet")
        self.add_provides("in_meta", 32, 512, channel_type="Meta")
        self.add_provides("in_usr", 32, 512, channel_type="Usr")
        self.add_requires("nomatch_pkt", channel_type="NomatchDMA")


# same explanations as above
# externs connect to ethernet interface
class Ethernet(Service):
    def __init__(self, name):
        super().__init__("ethernet_service_multi_out", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")
        
        # to/from ethernet interface
        self.add_extern_connection("out_data", "out_data")
        self.add_extern_connection("out_valid", "out_valid")
        self.add_extern_connection("out_ready", "out_ready")
        self.add_extern_connection("out_sop", "out_sop")
        self.add_extern_connection("out_eop", "out_eop")
        self.add_extern_connection("out_empty", "out_empty")
        self.add_extern_connection("in_sop", "in_sop")
        self.add_extern_connection("in_eop", "in_eop")
        self.add_extern_connection("in_data", "in_data")
        self.add_extern_connection("in_empty", "in_empty")
        self.add_extern_connection("in_valid", "in_valid")

        self.add_requires("in")
        self.add_provides("out0", 32, 512)
        self.add_provides("out1", 32, 512)
        self.add_provides("out2", 32, 512)
        self.add_provides("out3", 32, 512)
        self.add_provides("out4", 32, 512)


# slightly tweaked Ethernet service for pigasus_multi.py
# (changed names of some signals)
class EthernetMulti(Service):
    def __init__(self, name):
        super().__init__("ethernet_service_multi_out", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")
        
        self.add_extern_connection("out_data", "out_data")
        self.add_extern_connection("out_valid", "out_valid")
        self.add_extern_connection("out_ready", "out_ready")
        self.add_extern_connection("out_sop", "out_sop")
        self.add_extern_connection("out_eop", "out_eop")
        self.add_extern_connection("out_empty", "out_empty")
        self.add_extern_connection("in_sop", "in_sop")
        self.add_extern_connection("in_eop", "in_eop")
        self.add_extern_connection("in_data", "in_data")
        self.add_extern_connection("in_empty", "in_empty")
        self.add_extern_connection("in_valid", "in_valid")
        self.add_extern_connection("in_ready", "in_ready")

        self.add_requires("in")
        self.add_provides("out0", 32, 512)
        self.add_provides("out1", 32, 512)
        self.add_provides("out2", 32, 512)
        self.add_provides("out3", 32, 512)
        self.add_provides("out4", 32, 512)


# Other Ethernet sevice for pigasus_multi.py
class EthernetOther(Service):
    def __init__(self, name):
        super().__init__("ethernet_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")
        
        self.add_extern_connection("out_data", "out_1_data")
        self.add_extern_connection("out_valid", "out_1_valid")
        self.add_extern_connection("out_ready", "out_1_ready")
        self.add_extern_connection("out_sop", "out_1_sop")
        self.add_extern_connection("out_eop", "out_1_eop")
        self.add_extern_connection("out_empty", "out_1_empty")
        self.add_extern_connection("in_sop", "0")
        self.add_extern_connection("in_eop", "0")
        self.add_extern_connection("in_data", "0")
        self.add_extern_connection("in_empty", "0")
        self.add_extern_connection("in_valid", "0")
        self.add_extern_connection("in_ready", "")

        self.add_requires("in")
        self.add_provides("out", 32, 512)


# Stream split for pigasus_muli.py
class StreamMux(Service):
    def __init__(self, name):
        super().__init__("stream_mux_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")

        self.add_provides("in_pkt", 32, 512)
        self.add_provides("in_meta", 32, 512)
        self.add_provides("in_usr", 32, 512)
        self.add_requires("out")

# Stream join for pigasus_muli.py
class StreamDemux(Service):
    def __init__(self, name):
        super().__init__("stream_demux_service", SourceType.SYSTEM_VERILOG, name)
        self.add_extern_connection("Clk", "clk")
        self.add_extern_connection("Rst_n", "rst_n")

        self.add_provides("in", 32, 512)
        self.add_requires("out_pkt")
        self.add_requires("out_meta")
        self.add_requires("out_usr")
