#! /usr/bin/env sh

cd ..
rm -rf quartus_project
mkdir quartus_project

cd scripts

#Copy Ethernet example design
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design ../quartus_project/
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G ../quartus_project/
cp ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G.ip ../quartus_project/
#Copy PCIe core
cp -r pcie ../quartus_project/hardware_test_design/
#Copy PLL core
cp -r ip/ip_gen/user_pll ../quartus_project/hardware_test_design/common/
cp ip/ip_gen/user_pll.ip ../quartus_project/hardware_test_design/common/
#Copy RTL source
cp -r ../rtl_sim/src ../quartus_project/hardware_test_design/

if [ ! -d "../quartus_project/hardware_test_design/src/common" ] 
then
    cp -r generated_files ../quartus_project/hardware_test_design/src/common
fi

#Replace the quartus files
rm ../quartus_project/hardware_test_design/alt_ehipc2_hw.qsf
rm ../quartus_project/hardware_test_design/alt_ehipc2_hw.sdc
rm ../quartus_project/hardware_test_design/alt_ehipc2_hw.v
cp src/alt_ehipc2_hw.* ../quartus_project/hardware_test_design/
cp src/pc_loopback.sv ../quartus_project/hardware_test_design/


#copy hwtest 
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design/hwtest/* ../hw_test/hwtest/
./manipulate_tcl.py ../hw_test/hwtest/main.tcl
