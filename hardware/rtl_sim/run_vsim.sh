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
cp -r ../scripts/generated_files ./src/common


vlog +define+SIM +define+PKT_FILE=\"$PKT_FILE\" +define+PKT_FILE_NB_LINES=$PKT_FILE_NB_LINES ./src/*.sv -sv 
#vlog *.v
vlog ./src/common/*.sv -sv
vlog ./src/common/*.v
vlog ./src/mspm/string_matcher/*.sv -sv
vlog ./src/mspm/non_fast_pattern/*.sv -sv

#GUI full debug
#vsim tb -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver -voptargs="+acc"

#Fast
vsim -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver -c -do "run -all" tb
