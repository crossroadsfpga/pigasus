#!/bin/bash
altera_ver="$SIM_LIB_PATH/altera_ver"
lpm_ver="$SIM_LIB_PATH/lpm_ver"
sgate_ver="$SIM_LIB_PATH/sgate_ver"
altera_mf_ver="$SIM_LIB_PATH/altera_mf_ver"
altera_lnsim_ver="$SIM_LIB_PATH/altera_lnsim_ver"
fourteennm_ver="$SIM_LIB_PATH/fourteennm_ver"
fourteennm_ct1_ver="$SIM_LIB_PATH/fourteennm_ct1_ver"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

run_testcase () {
  rm -rf work
  rm -f vsim.wlf

  vlib work > /dev/null 2>&1
  vlog +define+SIM ../../src/common/*.sv -sv > /dev/null 2>&1
  vlog +define+SIM ../../src/common/*.v > /dev/null 2>&1
  vlog +define+SIM ../../src/reassembly/surge_protector/ffs.sv -sv > /dev/null 2>&1
  vlog +define+SIM ../../src/reassembly/surge_protector/heap_ops_pkg.sv -sv > /dev/null 2>&1
  vlog +define+SIM ../../src/reassembly/surge_protector/pipelined_heap.sv -sv > /dev/null 2>&1
  vlog +define+SIM +define+TEST_CASE=\"$1\" tb_pipelined_heap.sv -sv > /dev/null 2>&1

  OUTPUT=$(vsim -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver \
          -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver \
          -c -do "run -all" tb_pipelined_heap | grep -e "PASS" -e "FAIL")

  printf "Running $1... "
  if grep -q "FAIL" <<< ${OUTPUT}
  then
    printf "${RED}${OUTPUT}${NC}\n"
  elif grep -q "PASS $1" <<< ${OUTPUT}
  then
    printf "${GREEN}PASS${NC}\n"
  else
    printf "${RED}Test not run${NC}\n"
  fi
}

declare -a testcases=(
    'TEST_BASIC_ENQUE'
    'TEST_BASIC_DEQUE_MIN'
    'TEST_BASIC_DEQUE_MAX'
    'TEST_HEAP_PROPERTY'
    'TEST_CAPACITY_LIMITS'
    'TEST_PIPELINING_ENQUE'
    'TEST_PIPELINING_MIXED'
    'TEST_DEQUE_COLLISIONS'
    'TEST_RESET'
)

for c in ${testcases[@]}; do
  run_testcase $c
done
