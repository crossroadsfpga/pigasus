#! /usr/bin/env sh
IP_PATH=$pigasus_rep_dir/pigasus/hardware/scripts/ 
SRC_PATH=$pigasus_rep_dir/pigasus/hardware/rtl_sim

for i in 0 1
do
cd ..
rm -rf quartus_project_$i
mkdir quartus_project_$i
cd scripts

#Copy Ethernet example design
cp -r $IP_PATH/ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design ../quartus_project_$i/
cp -r $IP_PATH/ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G ../quartus_project_$i/
cp $IP_PATH/ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G.ip ../quartus_project_$i/
#Copy PCIe core
cp -r $IP_PATH/pcie ../quartus_project_$i/hardware_test_design/
#Copy PLL core
cp -r $IP_PATH/ip/ip_gen/user_pll ../quartus_project_$i/hardware_test_design/common/
cp $IP_PATH/ip/ip_gen/user_pll.ip ../quartus_project_$i/hardware_test_design/common/
#Copy RTL source
cp -r $SRC_PATH/src ../quartus_project_$i/hardware_test_design/
rm ../quartus_project_$i/hardware_test_design/src/tb.sv
rm ../quartus_project_$i/hardware_test_design/src/top.sv
cp ../rtl_sim/src/*.sv ../quartus_project_$i/hardware_test_design/src/
 

if [ ! -d "../quartus_project_$i/hardware_test_design/src/common" ] 
then
    cp -r $IP_PATH/generated_files ../quartus_project_$i/hardware_test_design/src/common
fi

#Replace the quartus files
rm ../quartus_project_$i/hardware_test_design/alt_ehipc2_hw.qsf
rm ../quartus_project_$i/hardware_test_design/alt_ehipc2_hw.sdc
rm ../quartus_project_$i/hardware_test_design/alt_ehipc2_hw.v
cp src_$i/alt_ehipc2_hw.* ../quartus_project_$i/hardware_test_design/
cp src_$i/pc_loopback.sv ../quartus_project_$i/hardware_test_design/
cp -r flow_control ../quartus_project_$i/hardware_test_design/src/

#copy hwtest 
cp -r $IP_PATH/ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design/hwtest/* ../hw_test_$i/hwtest/
./manipulate_tcl.py ../hw_test_$i/hwtest/main.tcl

done
