#!/bin/sh
tcpdump -r $1 -xxn > raw_bytes.txt

#add an empty line at the end of the raw_bytes such that 
#python script would not miss the last pkt
echo >> raw_bytes.txt

#convert the raw_bytes to verilog ROM content
python3 parse_output.py raw_bytes.txt

rm raw_bytes.txt
