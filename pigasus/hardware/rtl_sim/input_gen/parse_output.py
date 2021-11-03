#!/usr/bin/python
import os
import sys
import csv
import re

def parse_line(line):
    empty = 0
    temp = line.replace(" ","")
    temp = temp.split(":")[1]
    length = len(temp)
    if (length - 1 == 32):
        res = temp[:-1]
    else:
        empty = (32 - (length - 1))//2
        res = temp[:-1] + (empty*2)*'f'
    #print len(res)
    return res,empty


outname = "output.pkt"
fname = sys.argv[1]
sop = 0
eop = 1
empty_p = 0
empty_c = 0
data_p = [None] * 4
data_c = 0
data_field = 0



f = open(fname)
fout = open(outname,"w")
p = 0;
c = 0;
cnt = 0
for i,line in enumerate(f):
    #print line
    if ("0x" in line and ">" not in line):
        c = 1
        data_c,empty_c = parse_line(line)
    else:
        c = 0
    if("0x0000:" in line):
        sop = 1

    if (p==1 and c==1):
        eop = 0

        if (cnt == 4):

            fout.write(str(sop)+str(eop)+str(format(empty_p,'x')).zfill(2)+data_p[0]+data_p[1]+data_p[2]+data_p[3]+"\n")
            #print str(sop)+str(eop)+str(format(empty_p,'x')).zfill(2)+data_p[0]+data_p[1]+data_p[2]+data_p[3]+"\n"
            cnt = 0
            sop = 0
    elif (p==1 and c==0):
        print ("cnt = ",cnt, "empty_p = ",empty_p)
        eop = 1
        empty_p = empty_p + (4-cnt) * 16
        for j in range(0,cnt):
            if j == 0:
                data_field = data_p[0]
            else:
                data_field = data_field + data_p[j]
        data_field = data_field + ((4-cnt) * 16 * 2) * 'f'
        fout.write(str(sop)+str(eop)+str(format(empty_p,'x')).zfill(2)+data_field+"\n")
        #print str(sop)+str(eop)+str(format(empty_p,'x')).zfill(2)+data_field+"\n"
        sop = 0
        cnt = 0
    else:
        eop = 0
    p = c
    #print(data_c)
    if (c):
        data_p[cnt] = data_c
        cnt += 1
    empty_p = empty_c
f.close()
fout.close()
