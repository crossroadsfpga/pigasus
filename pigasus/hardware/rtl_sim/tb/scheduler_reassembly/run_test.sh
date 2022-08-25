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

# TODO(natre): This is a hack. Ideally we'd want to colocate
# artifacts with the source code and keep them under version
# control, but unfortunately there isn't a good way of doing
# this today (git LFS doesn't play well with public repos).
# Fix this whenever that changes.
if [ ! -d "data" ]; then
  printf "Data directory missing, downloading now... "
  wget -O data.tar.gz \
    https://www.dropbox.com/s/vhbkjv3c2t4u9vs/data.tar.gz?dl=0 \
    > /dev/null 2>&1
  printf "Done\n"

  tar -zxf data.tar.gz
  rm -rf data.tar.gz
fi

# Common prologue. Arg: CommonDefines
run_testcase_prologue() {
  cd ../../
  rm -rf work
  rm -f vsim.wlf
  vlib work > /dev/null 2>&1

  common_defines=("$@")
  vlog "${common_defines[@]}" ./src/*.*v -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/common/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/common/*.v > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/common_usr/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/common_usr/*.v > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/buffer/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/fast_pattern_matcher/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/mux/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/non_fast_pattern_matcher/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/parser/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/pcie/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/port_group/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/reassembly/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/reassembly/surge_protector/heap_ops_pkg.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/reassembly/surge_protector/*.sv -sv > /dev/null 2>&1
  vlog "${common_defines[@]}" ./src/services/*.sv -sv > /dev/null 2>&1
}

# Common epilogue. Arg: TestCaseName
run_testcase_epilogue() {
  OUTPUT=$(vsim -L $altera_mf_ver -L $altera_lnsim_ver -L $altera_ver \
          -L $lpm_ver -L $sgate_ver -L $fourteennm_ver -L $fourteennm_ct1_ver \
          -c -do "run -all" tb_scheduler_reassembly | grep -e "PASS" -e "FAIL")

  if grep -q "FAIL" <<< ${OUTPUT}
  then
    printf "${RED}${OUTPUT}${NC}\n"
  elif grep -q "PASS $1" <<< ${OUTPUT}
  then
    printf "${GREEN}PASS${NC}\n"
  else
    printf "${RED}Test not run${NC}\n"
  fi

  cd tb/scheduler_reassembly
}

run_testcase () {
  while IFS=',' read -r TEST_CASE PKT_FILE RATE_INNOCENT RATE_ATTACK PKT_NUM; do
    printf "Running ${TEST_CASE}... "

    common_defines=()
    common_defines+=( '+define+SIM' )
    common_defines+=( '+define+PKT_NUM='${PKT_NUM} )
    if [[ ${TEST_CASE} == *"WSJF"* ]]; then
      common_defines+=( '+define+ENABLE_SURGEPROTECTOR' )
    fi

    PKT_FILE_NB_LINES=$(wc -l < ${PKT_FILE})
    run_testcase_prologue "${common_defines[@]}" # Run prologue

    vlog \
      "${common_defines[@]}" \
      +define+TEST_CASE=\"${TEST_CASE}\" \
      +define+PKT_FILE=\"./tb/scheduler_reassembly/${PKT_FILE}\" \
      +define+PKT_FILE_NB_LINES=${PKT_FILE_NB_LINES} \
      +define+RATE_INNOCENT=${RATE_INNOCENT} \
      +define+RATE_ATTACK=${RATE_ATTACK} \
      ./tb/scheduler_reassembly/tb_scheduler_reassembly.sv -sv > /dev/null 2>&1

    run_testcase_epilogue ${TEST_CASE} # Run epilogue
  done <<< $1
}

# Format: TestCaseName, PacketFile, RateInnocent,
#         RateAttack, PacketBufferSize
declare -a testcases=(
    'TEST_FCFS_BASIC_INORDER,data/inorder.pkt,10,0,1024'
    'TEST_FCFS_BASIC_OOO,data/ooo.pkt,10,0,1024'
    'TEST_WSJF_BASIC_INORDER,data/inorder.pkt,10,0,1024'
    'TEST_WSJF_BASIC_OOO,data/ooo.pkt,10,0,1024'
    'TEST_WSJF_ACA_MITIGATION,data/adversarial.pkt,10,1,16384'
)

for c in ${testcases[@]}; do
  run_testcase $c
done
