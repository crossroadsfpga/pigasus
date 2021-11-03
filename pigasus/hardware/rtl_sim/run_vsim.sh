#!/bin/sh
rm -r work
rm vsim.wlf

altera_ver="$SIM_LIB_PATH/altera_ver"
lpm_ver="$SIM_LIB_PATH/lpm_ver"
sgate_ver="$SIM_LIB_PATH/sgate_ver"
altera_mf_ver="$SIM_LIB_PATH/altera_mf_ver"
altera_lnsim_ver="$SIM_LIB_PATH/altera_lnsim_ver"
fourteennm_ver="$SIM_LIB_PATH/fourteennm_ver"
fourteennm_ct1_ver="$SIM_LIB_PATH/fourteennm_ct1_ver"

vlib work
PKT_FILE=${1:-"./input_gen/output.pkt"}
PKT_FILE_NB_LINES=$(wc -l < $PKT_FILE)

#update common dir
rm -r ./src/common
cp -r ../scripts/generated_files ./src/common

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

vlog +define+SIM +define+PKT_FILE=\"$PKT_FILE\" +define+PKT_FILE_NB_LINES=$PKT_FILE_NB_LINES ./src/*.*v -sv 
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
