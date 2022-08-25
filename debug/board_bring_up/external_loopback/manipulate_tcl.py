#! /usr/bin/env python3

import sys

def change_tcl(fname):
    new_file = []
    first = 1
    f = open(fname,'r')
    for line in f:
        if ("set" in line) and first:
            new_line = "#Port 0 Eth \n"
            new_file.append(new_line)
            first = 0

        if ("BASE_TRFC" in line):
            new_line = " set BASE_TRFC \t 0x04001000 \n"
            new_file.append(new_line)
        else:
            new_file.append(line)

        if ("RECO_CH" in line):
            new_file.append("#Port 1 Eth \n")
            new_file.append("#set BASE_KR4         0x02000000 \n")
            new_file.append("#set BASE_RXPHY       0x02000300 \n")
            new_file.append("#set BASE_TXMAC       0x02000400 \n")
            new_file.append("#set BASE_RXMAC       0x02000500 \n")
            new_file.append("#set BASE_TXSTATS     0x02000800 \n")
            new_file.append("#set BASE_RXSTATS     0x02000900 \n")
            new_file.append("#set BASE_TRFC        0x02001000 \n")
            new_file.append("#set BASE_PMDC        0x02002000 \n")
            new_file.append("#set BASE_S10RECO     0x02010000 \n")
            new_file.append("#set RECO_CH          0x02001000 \n")
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)

if __name__ == "__main__":
    fname = sys.argv[1]
    
    change_tcl(fname)

