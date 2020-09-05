#!/bin/bash
#cd ./snort3-pigasus/src/pigasus/pcie/kernel/linux/
#sudo ./install
#cd 
#taskset --cpu-list 0 ./run_full.sh
for i in {0..31}
do
    taskset --cpu-list $i ./run_full.sh > res$i &

    #echo "Welcome $i times"
done
#taskset --cpu-list 0 ./run_full.sh > res0 &
#taskset --cpu-list 1 ./run_full.sh > res1 &
#taskset --cpu-list 2 ./run_full.sh > res2 &
#taskset --cpu-list 3 ./run_full.sh > res3 &
#taskset --cpu-list 4 ./run_full.sh > res4 &
#taskset --cpu-list 5 ./run_full.sh > res5 &
#taskset --cpu-list 6 ./run_full.sh > res6 &
#taskset --cpu-list 7 ./run_full.sh > res7 &
