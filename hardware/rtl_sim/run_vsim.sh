#!/bin/sh
rm -r work
rm vsim.wlf

sim_lib_path="/home/zzhao1/sim_lib/verilog_libs/"
altera_ver="$sim_lib_path/altera_ver"
lpm_ver="$sim_lib_path/lpm_ver"
sgate_ver="$sim_lib_path/sgate_ver"
altera_mf_ver="$sim_lib_path/altera_mf_ver"
altera_lnsim_ver="$sim_lib_path/altera_lnsim_ver"
fourteennm_ver="$sim_lib_path/fourteennm_ver"
fourteennm_ct1_ver="$sim_lib_path/fourteennm_ct1_ver"

vlib work
PKT_FILE=${1:-"./input_gen/output.pkt"}
PKT_FILE_NB_LINES=$(wc -l < $PKT_FILE)

vlog +define+PKT_FILE=\"$PKT_FILE\" +define+PKT_FILE_NB_LINES=$PKT_FILE_NB_LINES *.sv -sv 
#vlog *.v
vlog ./common/*.sv -sv
vlog ./common/*.v
vlog ./mspm/string_matcher/*.sv -sv

#GUI full debug
#vsim tb -L altera_mf_ver -L altera_lnsim_ver -L altera_ver -L lpm_ver -L sgate_ver -L fourteennm_ver -L fourteennm_ct1_ver -voptargs="+acc"

#Fast
vsim -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver -c -do "run -all" tb
