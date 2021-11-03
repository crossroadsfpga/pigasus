#! /usr/bin/env python3

import sys

def change_tcl(fname):
    new_file = []
    first = 0
    f = open(fname,'r')
    for line in f:
        if ("source" in line) and not first:
            if "stats" not in line:
                new_line = "source [file join [file dirname [info script]] \"stats.tcl\"] \n"
                new_file.append(new_line)
            first = 1
        new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)


fname = sys.argv[1]

change_tcl(fname)

