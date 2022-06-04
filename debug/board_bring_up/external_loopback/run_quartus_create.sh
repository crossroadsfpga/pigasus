#! /usr/bin/env sh

rm -rf quartus_project
mkdir quartus_project


#Copy Ethernet example design
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design ./quartus_project/
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G ./quartus_project/
cp ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/ex_100G.ip ./quartus_project/

#Replace the quartus files
rm ./quartus_project/hardware_test_design/alt_ehipc2_hw.qsf
rm ./quartus_project/hardware_test_design/alt_ehipc2_hw.sdc
rm ./quartus_project/hardware_test_design/alt_ehipc2_hw.v
cp src/alt_ehipc2_hw.* ./quartus_project/hardware_test_design/


# copy hwtest
if [ -d "./hw_test/hwtest/" ]
then
    rm -r ./hw_test/hwtest/
fi
cp -r ./ethernet/ip_gen_alt_ehipc2_0_example_design/alt_ehipc2_0_example_design/hardware_test_design/hwtest ./hw_test/
./manipulate_tcl.py ./hw_test/hwtest/altera/sval_top/reg_map_inc.tcl
