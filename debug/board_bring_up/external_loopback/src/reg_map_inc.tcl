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


#==============================================================================
#                    High Level Address map
#==============================================================================
#Port 0 Eth
 set BASE_KR4       0x00000
 set BASE_RXPHY     0x00300
 set BASE_TXMAC     0x00400
 set BASE_RXMAC     0x00500
 set BASE_TXSTATS   0x00800
 set BASE_RXSTATS   0x00900
 set BASE_TRFC      0x04001000
 set BASE_PMDC      0x02000
 set BASE_S10RECO   0x10000
 set RECO_CH        0x01000

 #port 1 Eth
# set BASE_KR4       0x02000000
# set BASE_RXPHY     0x02000300
# set BASE_TXMAC     0x02000400
# set BASE_RXMAC     0x02000500
# set BASE_TXSTATS   0x02000800
# set BASE_RXSTATS   0x02000900
# set BASE_TRFC      0x06001000
# set BASE_PMDC      0x02002000
# set BASE_S10RECO   0x02010000
# set RECO_CH        0x02001000

#==============================================================================
