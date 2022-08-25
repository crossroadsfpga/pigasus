# (C) 2001-2019 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


create_clock -name {ref_clk_0} -period 1.552 -waveform { 0.000 0.776 } [get_ports {i_clk_ref_0}]
create_clock -name {ref_clk_1} -period 1.552 -waveform { 0.000 0.776 } [get_ports {i_clk_ref_1}]
create_clock -name {altera_reserved_tck} -period 40 [get_ports {altera_reserved_tck}]

set REF_CLK_0	      [get_clocks ref_clk_0]
set CORECLK_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*tx_clkout|ch0]
set CORECLKRX_0       [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*rx_clkout|ch0]
set RX_CLK0_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set RX_CLK1_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[1].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set TX_CLK0_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set TX_CLK1_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[1].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set RX_CLK2_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[2].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set RX_CLK3_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[3].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set TX_CLK2_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[2].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set TX_CLK3_0         [get_clocks av_top_0|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[3].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]

set REF_CLK_1	      [get_clocks ref_clk_1]
set CORECLK_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*tx_clkout|ch0]
set CORECLKRX_1       [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*rx_clkout|ch0]
set RX_CLK0_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set RX_CLK1_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[1].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set TX_CLK0_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set TX_CLK1_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[1].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set RX_CLK2_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[2].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set RX_CLK3_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[3].s10_xcvr_native_inst|*rx_pcs_x2_clk|ch0]
set TX_CLK2_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[2].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]
set TX_CLK3_1         [get_clocks av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[3].s10_xcvr_native_inst|*tx_pcs_x2_clk|ch0]



set OSC_CLK         [get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk]
set CLK100          [get_clocks u0|altera_iopll_0_outclk0]
set IOPLL_REF       [get_clocks u0|altera_iopll_0_refclk]


if {! [is_post_route]} {
   # fitter; 15% at 402.83 MHz
   set_clock_uncertainty -setup -add -from $CORECLK_0 0.372
   set_clock_uncertainty -setup -add -from $CORECLKRX_0 0.372
} else {
   # everywhere else
}
if {! [is_post_route]} {
   # fitter; 15% at 402.83 MHz
   set_clock_uncertainty -setup -add -from $CORECLK_1 0.372
   set_clock_uncertainty -setup -add -from $CORECLKRX_1 0.372
} else {
   # everywhere else
}


#Zhipeng Update
set_clock_groups -exclusive  -group  $CORECLK_0  -group $CORECLKRX_0 -group $OSC_CLK  -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $RX_CLK0_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $RX_CLK1_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $TX_CLK0_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $TX_CLK1_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $RX_CLK2_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $RX_CLK3_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $TX_CLK2_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1
set_clock_groups -exclusive  -group  $TX_CLK3_0 -group $OSC_CLK -group $REF_CLK_0 -group $CLK100 -group $IOPLL_REF -group $CORECLK_1 -group $CORECLKRX_1 -group $REF_CLK_1


set_clock_groups -exclusive  -group  $CORECLK_1  -group $CORECLKRX_1 -group $OSC_CLK  -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $RX_CLK0_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $RX_CLK1_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $TX_CLK0_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $TX_CLK1_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $RX_CLK2_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $RX_CLK3_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $TX_CLK2_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
set_clock_groups -exclusive  -group  $TX_CLK3_1 -group $OSC_CLK -group $REF_CLK_1 -group $CLK100 -group $IOPLL_REF -group $CORECLK_0 -group $CORECLKRX_0 -group $REF_CLK_0
#end Zhipeng


# From Timequest cookbook
set_clock_groups -exclusive -group [get_clocks altera_reserved_tck]

# From "AV SoC Golden Hardware Reference Design"
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]


# for unconstrained input and output paths
set_false_path -from [get_keepers {cpu_resetn}]
set_false_path -to   [get_ports {user_led[*]}]
set_false_path -to [get_ports {user_io[*]}]


## TRY THIS
proc alt_ehipc2_constraint_net_delay {from_reg to_reg max_net_delay {check_exist 0}} {
    
    # Check for instances
    set inst [get_registers -nowarn ${to_reg}]
    
    # Check number of instances
    set inst_num [llength [query_collection -report -all $inst]]
    if {$inst_num > 0} {
        # Uncomment line below for debug purpose
        #puts "${inst_num} ${to_reg} instance(s) found"
    } else {
        # Uncomment line below for debug purpose
        #puts "No ${to_reg} instance found"
    }
    
    if {($check_exist == 0) || ($inst_num > 0)} {
        if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
            set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ps
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -200ps
        } else {
            set_net_delay -from [get_pins -compatibility_mode ${from_reg}|q] -to [get_registers ${to_reg}] -max $max_net_delay
            
            # Relax the fitter effort
            set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ps
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -200ps
        }
    }
}

alt_ehipc2_constraint_net_delay {av_top_0|alt_ehipc2_0|alt_ehipc2_reset_controller_inst|tx_ch_rst_inst|tx_aib_reset_out_stage[*]} \
                                   {av_top|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*} \
                                   2ns

alt_ehipc2_constraint_net_delay {av_top_0|alt_ehipc2_0|alt_ehipc2_reset_controller_inst|rx_ch_rst_inst|rx_aib_reset_out_stage[*]} \
                                   {av_top|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*} \
                                   2ns

alt_ehipc2_constraint_net_delay {av_top_1|alt_ehipc2_0|alt_ehipc2_reset_controller_inst|tx_ch_rst_inst|tx_aib_reset_out_stage[*]} \
                                   {av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*} \
                                   2ns

alt_ehipc2_constraint_net_delay {av_top_1|alt_ehipc2_0|alt_ehipc2_reset_controller_inst|rx_ch_rst_inst|rx_aib_reset_out_stage[*]} \
                                   {av_top_1|alt_ehipc2_0|alt_ehipc2_hard_inst|altera_xcvr_native_inst|g_native_phy_inst[0].s10_xcvr_native_inst|*} \
                                   2ns
