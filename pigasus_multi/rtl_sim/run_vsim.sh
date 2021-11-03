#!/bin/sh
SRC_PATH="$pigasus_rep_dir/pigasus/hardware/rtl_sim"
MULTI_PATH="$pigasus_rep_dir/pigasus_multi/rtl_sim"
altera_ver="$SIM_LIB_PATH/altera_ver"
lpm_ver="$SIM_LIB_PATH/lpm_ver"
sgate_ver="$SIM_LIB_PATH/sgate_ver"
altera_mf_ver="$SIM_LIB_PATH/altera_mf_ver"
altera_lnsim_ver="$SIM_LIB_PATH/altera_lnsim_ver"
fourteennm_ver="$SIM_LIB_PATH/fourteennm_ver"
fourteennm_ct1_ver="$SIM_LIB_PATH/fourteennm_ct1_ver"

#clean up working directory
if [ -d "work" ] 
then
    rm -r work
fi
if [ -d "vsim.wlf" ] 
then
    rm vsim.wlf
fi
#always use latest src from pigasus directory
if [ -d "src" ] 
then
    rm -r src
fi
cp -r $SRC_PATH/src ./
rm ./src/tb.sv
rm ./src/top.sv
cp ./*.sv ./src/

if [ -d "input_gen" ] 
then
    rm -r input_gen
fi
cp -r $SRC_PATH/input_gen ./

vlib work
PKT_FILE=${1:-"./input_gen/output.pkt"}
PKT_FILE_NB_LINES=$(wc -l < $PKT_FILE)


#regenerate the fast pattern code
cd ./src/fast_pattern_matcher/
./update.sh
cd ../../
#regenerate the port group code
cd ./src/port_group/
./update.sh
cd ../../
#regenerate the non-fast pattern code
cd ./src/non_fast_pattern_matcher/
./update.sh
cd ../../

vlog +define+SIM +define+PKT_FILE=\"$PKT_FILE\" +define+PKT_FILE_NB_LINES=$PKT_FILE_NB_LINES ./src/*.sv -sv 
#vlog *.v
vlog +define+SIM ./src/common/*.sv -sv
vlog +define+SIM ./src/common/*.v
vlog +define+SIM ./src/common_usr/*.sv -sv
vlog +define+SIM ./src/common_usr/*.v
vlog +define+SIM ./src/buffer/*.sv -sv
vlog +define+SIM ./src/fast_pattern_matcher/*.sv -sv
vlog +define+SIM ./src/mux/*.sv -sv
vlog +define+SIM ./src/non_fast_pattern_matcher/*.sv -sv
vlog +define+SIM ./src/parser/*.sv -sv
vlog +define+SIM ./src/pcie/*.sv -sv
vlog +define+SIM ./src/port_group/*.sv -sv
vlog +define+SIM ./src/reassembly/*.sv -sv
vlog +define+SIM ./src/services/*.sv -sv

#GUI full debug
#vsim tb -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver -voptargs="+acc"

#Fast
vsim -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver -c -do "run -all" tb
