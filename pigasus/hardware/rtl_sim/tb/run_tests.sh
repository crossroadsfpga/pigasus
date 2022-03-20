#!/bin/bash

# Update common dir
rm -rf ../src/common
cp -r ../../scripts/generated_files ../src/common

declare -a testdirs=(
    'ffs'
    'pipelined_heap'
    'pipelined_heap_wrapper'
    'scheduler_reassembly'
)

for testdir in ${testdirs[@]}; do
  pwd=$(pwd)
  echo "-----------------------------------------------"
  echo "tb_${testdir}"
  echo "-----------------------------------------------"
  cd ${testdir}; ./run_test.sh; cd ${pwd};
done
