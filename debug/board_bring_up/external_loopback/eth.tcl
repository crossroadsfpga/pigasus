package require -exact qsys 18.0

# create the system "ip_gen_alt_ehipc2_0"
proc do_create_ip_gen_alt_ehipc2_0 {} {
	# create the system
	create_system ip_gen_alt_ehipc2_0
	set_project_property DEVICE {1SM21BHU2F53E1VG}
	set_project_property DEVICE_FAMILY {Stratix 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add the components
	add_instance alt_ehipc2_0 alt_ehipc2 19.2.0
	set_instance_parameter_value alt_ehipc2_0 {AN_CHAN} {1}
	set_instance_parameter_value alt_ehipc2_0 {AN_CR} {1}
	set_instance_parameter_value alt_ehipc2_0 {AN_PAUSE_C0} {1}
	set_instance_parameter_value alt_ehipc2_0 {AN_PAUSE_C1} {1}
	set_instance_parameter_value alt_ehipc2_0 {CASCADE_ATX_PLL} {1}
	set_instance_parameter_value alt_ehipc2_0 {CL72_PRBS} {0}
	set_instance_parameter_value alt_ehipc2_0 {DEV_BOARD} {1}
	set_instance_parameter_value alt_ehipc2_0 {ENABLE_ADME} {0}
	set_instance_parameter_value alt_ehipc2_0 {ENABLE_ANLT} {0}
	set_instance_parameter_value alt_ehipc2_0 {ENABLE_ASYNC_ADAPTERS} {0}
	set_instance_parameter_value alt_ehipc2_0 {ENABLE_JTAG_AVMM} {0}
	set_instance_parameter_value alt_ehipc2_0 {EXAMPLE_DESIGN} {1}
	set_instance_parameter_value alt_ehipc2_0 {GEN_SIM} {0}
	set_instance_parameter_value alt_ehipc2_0 {GEN_SYNTH} {1}
	set_instance_parameter_value alt_ehipc2_0 {HDL_FORMAT} {1}
	set_instance_parameter_value alt_ehipc2_0 {HW_DEVICE} {1}
	set_instance_parameter_value alt_ehipc2_0 {INITMAINVAL} {25}
	set_instance_parameter_value alt_ehipc2_0 {INITPOSTVAL} {13}
	set_instance_parameter_value alt_ehipc2_0 {INITPREVAL} {3}
	set_instance_parameter_value alt_ehipc2_0 {LINK_TIMER_KR} {504}
	set_instance_parameter_value alt_ehipc2_0 {PHY_ANALOG_VOLTAGE} {1_1V}
	set_instance_parameter_value alt_ehipc2_0 {PHY_REFCLK} {644.53125}
	set_instance_parameter_value alt_ehipc2_0 {PREMAINVAL} {30}
	set_instance_parameter_value alt_ehipc2_0 {PREPOSTVAL} {0}
	set_instance_parameter_value alt_ehipc2_0 {PREPREVAL} {0}
	set_instance_parameter_value alt_ehipc2_0 {STATUS_CLK_MHZ} {100.0}
	set_instance_parameter_value alt_ehipc2_0 {SYNTH_AN} {1}
	set_instance_parameter_value alt_ehipc2_0 {SYNTH_LT} {1}
	set_instance_parameter_value alt_ehipc2_0 {TRNWTWIDTH_gui} {127}
	set_instance_parameter_value alt_ehipc2_0 {USE_DEBUG_CPU} {0}
	set_instance_parameter_value alt_ehipc2_0 {VMAXRULE} {30}
	set_instance_parameter_value alt_ehipc2_0 {VMINRULE} {6}
	set_instance_parameter_value alt_ehipc2_0 {VODMINRULE} {14}
	set_instance_parameter_value alt_ehipc2_0 {VPOSTRULE} {25}
	set_instance_parameter_value alt_ehipc2_0 {VPRERULE} {16}
	set_instance_parameter_value alt_ehipc2_0 {additional_ipg_removed} {0}
	set_instance_parameter_value alt_ehipc2_0 {avmm_test} {0}
	set_instance_parameter_value alt_ehipc2_0 {duplex_mode} {enable}
	set_instance_parameter_value alt_ehipc2_0 {ehip_mode_gui} {MAC+PCS}
	set_instance_parameter_value alt_ehipc2_0 {ehip_rate_gui} {100G}
	set_instance_parameter_value alt_ehipc2_0 {enforce_max_frame_size_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {flow_control_gui} {No}
	set_instance_parameter_value alt_ehipc2_0 {forward_rx_pause_requests_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {link_fault_mode_gui} {OFF}
	set_instance_parameter_value alt_ehipc2_0 {preamble_passthrough_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {ready_latency} {0}
	set_instance_parameter_value alt_ehipc2_0 {rx_bytes_to_remove} {Remove CRC bytes}
	set_instance_parameter_value alt_ehipc2_0 {rx_max_frame_size_gui} {1518}
	set_instance_parameter_value alt_ehipc2_0 {rx_vlan_detection_gui} {1}
	set_instance_parameter_value alt_ehipc2_0 {source_address_insertion_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {strict_preamble_checking_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {strict_sfd_checking_gui} {0}
	set_instance_parameter_value alt_ehipc2_0 {tx_ipg_size_gui} {12}
	set_instance_parameter_value alt_ehipc2_0 {tx_max_frame_size_gui} {1518}
	set_instance_parameter_value alt_ehipc2_0 {tx_vlan_detection_gui} {1}
	set_instance_parameter_value alt_ehipc2_0 {txmac_saddr_gui} {73588229205}
	set_instance_property alt_ehipc2_0 AUTO_EXPORT true

	# add wirelevel expressions

	# add the exports
	set_interface_property i_stats_snapshot EXPORT_OF alt_ehipc2_0.i_stats_snapshot
	set_interface_property o_cdr_lock EXPORT_OF alt_ehipc2_0.o_cdr_lock
	set_interface_property i_eth_reconfig_addr EXPORT_OF alt_ehipc2_0.i_eth_reconfig_addr
	set_interface_property i_eth_reconfig_read EXPORT_OF alt_ehipc2_0.i_eth_reconfig_read
	set_interface_property i_eth_reconfig_write EXPORT_OF alt_ehipc2_0.i_eth_reconfig_write
	set_interface_property o_eth_reconfig_readdata EXPORT_OF alt_ehipc2_0.o_eth_reconfig_readdata
	set_interface_property o_eth_reconfig_readdata_valid EXPORT_OF alt_ehipc2_0.o_eth_reconfig_readdata_valid
	set_interface_property i_eth_reconfig_writedata EXPORT_OF alt_ehipc2_0.i_eth_reconfig_writedata
	set_interface_property o_eth_reconfig_waitrequest EXPORT_OF alt_ehipc2_0.o_eth_reconfig_waitrequest
	set_interface_property o_tx_lanes_stable EXPORT_OF alt_ehipc2_0.o_tx_lanes_stable
	set_interface_property o_rx_pcs_ready EXPORT_OF alt_ehipc2_0.o_rx_pcs_ready
	set_interface_property o_ehip_ready EXPORT_OF alt_ehipc2_0.o_ehip_ready
	set_interface_property o_rx_block_lock EXPORT_OF alt_ehipc2_0.o_rx_block_lock
	set_interface_property o_rx_am_lock EXPORT_OF alt_ehipc2_0.o_rx_am_lock
	set_interface_property o_rx_hi_ber EXPORT_OF alt_ehipc2_0.o_rx_hi_ber
	set_interface_property i_tx_pll_locked EXPORT_OF alt_ehipc2_0.i_tx_pll_locked
	set_interface_property o_local_fault_status EXPORT_OF alt_ehipc2_0.o_local_fault_status
	set_interface_property o_remote_fault_status EXPORT_OF alt_ehipc2_0.o_remote_fault_status
	set_interface_property i_clk_ref EXPORT_OF alt_ehipc2_0.i_clk_ref
	set_interface_property i_clk_tx EXPORT_OF alt_ehipc2_0.i_clk_tx
	set_interface_property i_clk_rx EXPORT_OF alt_ehipc2_0.i_clk_rx
	set_interface_property o_clk_pll_div64 EXPORT_OF alt_ehipc2_0.o_clk_pll_div64
	set_interface_property o_clk_pll_div66 EXPORT_OF alt_ehipc2_0.o_clk_pll_div66
	set_interface_property o_clk_rec_div64 EXPORT_OF alt_ehipc2_0.o_clk_rec_div64
	set_interface_property o_clk_rec_div66 EXPORT_OF alt_ehipc2_0.o_clk_rec_div66
	set_interface_property i_tx_serial_clk EXPORT_OF alt_ehipc2_0.i_tx_serial_clk
	set_interface_property i_csr_rst_n EXPORT_OF alt_ehipc2_0.i_csr_rst_n
	set_interface_property i_tx_rst_n EXPORT_OF alt_ehipc2_0.i_tx_rst_n
	set_interface_property i_rx_rst_n EXPORT_OF alt_ehipc2_0.i_rx_rst_n
	set_interface_property o_tx_serial EXPORT_OF alt_ehipc2_0.o_tx_serial
	set_interface_property i_rx_serial EXPORT_OF alt_ehipc2_0.i_rx_serial
	set_interface_property i_reconfig_clk EXPORT_OF alt_ehipc2_0.i_reconfig_clk
	set_interface_property i_reconfig_reset EXPORT_OF alt_ehipc2_0.i_reconfig_reset
	set_interface_property i_xcvr_reconfig_address EXPORT_OF alt_ehipc2_0.i_xcvr_reconfig_address
	set_interface_property i_xcvr_reconfig_read EXPORT_OF alt_ehipc2_0.i_xcvr_reconfig_read
	set_interface_property i_xcvr_reconfig_write EXPORT_OF alt_ehipc2_0.i_xcvr_reconfig_write
	set_interface_property o_xcvr_reconfig_readdata EXPORT_OF alt_ehipc2_0.o_xcvr_reconfig_readdata
	set_interface_property i_xcvr_reconfig_writedata EXPORT_OF alt_ehipc2_0.i_xcvr_reconfig_writedata
	set_interface_property o_xcvr_reconfig_waitrequest EXPORT_OF alt_ehipc2_0.o_xcvr_reconfig_waitrequest
	set_interface_property nonpcs_ports EXPORT_OF alt_ehipc2_0.nonpcs_ports
	set_interface_property pfc_ports EXPORT_OF alt_ehipc2_0.pfc_ports
	set_interface_property pause_ports EXPORT_OF alt_ehipc2_0.pause_ports

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="alt_ehipc2_0">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {ip_gen_alt_ehipc2_0.ip}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {ip_gen_alt_ehipc2_0}

	# save the system
	sync_sysinfo_parameters
	save_system ip_gen_alt_ehipc2_0
}

# create all the systems, from bottom up
do_create_ip_gen_alt_ehipc2_0
