#!/bin/bash

RED='\033[1;35m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Running ${RED}pigasus.py${GREEN}...${NC}"
python3 pigasus.py

echo -e "${RED}pigasus.py${GREEN} done. Copying built SV files to ${RED}pigasus/hardware/rtl_sim/src/${GREEN} directory...${NC}"
cp -v build/struct_s.sv pigasus/hardware/rtl_sim/src/struct_s.sv
cp -v build/top.sv pigasus/hardware/rtl_sim/src/top.sv

echo -e "${GREEN}Copy complete.${NC} \nIf there were no errors, follow instructions in ${RED}pigasus/README.md${NC} to simulate the RTL. \nGenerally this means running \n${YELLOW}cd pigasus/hardware/rtl_sim/input_gen && ./run.sh m10_100.pcap\ncd .. \n./run_vsim.sh${NC}\nafter you have setup the verilog_libs as mentioned in ${RED}pigasus/README.md${GREEN}.${NC}"
