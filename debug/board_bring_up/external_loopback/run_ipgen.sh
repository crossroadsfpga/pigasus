#! /usr/bin/env sh

#Clean old data
rm -f ip_gen.qsf
rm -f ip_gen.qpf
rm -f ip_gen.qsys
rm -rf ip_gen
rm -rf qdb
rm -rf ip

#Generate Ethernet
rm -rf ethernet
mkdir ethernet
cp eth.tcl ethernet/
cd ethernet
qsys-script --script=eth.tcl
#generate example design
qsys-generate ip_gen_alt_ehipc2_0.ip -example-design
cd ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design/common/
qsys-generate reset_ip.ip --synthesis=VERILOG --part=1SM21BHU2F53E1VG 
qsys-generate alt_ehipc2_jtag_avalon.ip --synthesis=VERILOG --part=1SM21BHU2F53E1VG 
qsys-generate alt_ehipc2_sys_pll.ip --synthesis=VERILOG --part=1SM21BHU2F53E1VG
qsys-generate probe8.ip --synthesis=VERILOG --part=1SM21BHU2F53E1VG 
qsys-generate reset_ip.ip --synthesis=VERILOG --part=1SM21BHU2F53E1VG 
cd ../../../../../
