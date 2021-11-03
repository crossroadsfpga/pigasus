#! /usr/bin/env python3

import sys
import os
from os import listdir
from os.path import isdir, isfile, join
import shutil

def list_to_txt(mylist,fname):
    with open(fname, 'w') as f:
        for item in mylist:
            f.write("%s" % item)

def change_module_name(fname,new_name):
    new_file = []
    first = 0
    f = open(fname,'r')
    for line in f:
        if ("module" in line) and ("endmodule" not in line) and not first:
            old = line.split()
            old[1]=new_name
            for j in range(0,len(old)):
                if j==0:
                    new = old[j]
                else:
                    new = new + " " + old[j]
            new_module = new+"\n"
            new_file.append(new_module)
            first = 1
            #print(new_module)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)

def change_wrapper(fname,new_name):
    new_file = []
    f = open(fname,'r')
    for line in f:
        #change module name
        if "module" in line and "endmodule" not in line:
            old = line.split()
            old[1]=new_name
            for j in range(0,len(old)):
                if j==0:
                    new = old[j]
                else:
                    new = new + " " + old[j]
            new_module = new+"\n"
            new_file.append(new_module)
            #print(new_module)
        #change data width
        elif "511" in line:
            new_line = line.replace("511","SYMBOLS_PER_BEAT*BITS_PER_SYMBOL-1")
            new_file.append(new_line)
        #change the sub component
        elif "#(" in line:
            old = line.split()
            old[0]=new_name.replace("wrapper","core")
            for j in range(0,len(old)):
                if j==0:
                    new = old[j]
                else:
                    new = new + " " + old[j]
            new_module = new+"\n"
            new_file.append(new_module)
            #print(new_module)
        else:
            if "mlab" in new_name:
                if "parameter FIFO_DEPTH" in line:
                    new_line = line.replace("512","32")
                    new_file.append(new_line)
                else:
                    new_file.append(line)
            else:
                new_file.append(line)

    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)

def change_to_mlab(fname,new_name):
    new_file = []
    f = open(fname,'r')
    for line in f:
        if "module" in line and "endmodule" not in line:
            old = line.split()
            old[1]=new_name
            for j in range(0,len(old)):
                if j==0:
                    new = old[j]
                else:
                    new = new + " " + old[j]
            new_module = new+"\n"
            new_file.append(new_module)
            #print(new_module)
        elif "infer_mem [DEPTH-1 : 0]" in line or "mem [DEPTH - 1 : 0]" in line:
            if "dc" in new_name:
                new_line = "    (* ramstyle=\"MLAB, no_rw_check\" *) reg [PAYLOAD_WIDTH-1 : 0] mem [DEPTH-1 : 0];"+"\n"
            #sc uses infer mem
            else:
                new_line = "    (* ramstyle=\"MLAB\" *) reg [PAYLOAD_WIDTH-1 : 0] infer_mem [DEPTH-1 : 0];"+"\n"
            new_file.append(new_line)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)


def change_rom(fname,new_name,dwidth,awidth,mem_size):
    new_file = []
    first_input = 1
    no_pli = 0
    f = open(fname,'r')
    
    for line in f:
        #add paramter in the beginning. 
        if "input" in line and first_input:
            first_input = 0
            new_string = "    parameter DWIDTH = "+str(dwidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter AWIDTH = "+str(awidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter MEM_SIZE = "+str(mem_size)+";\n"
            new_file.append(new_string)
            new_string = "    parameter INIT_FILE = \"./hashtable0.mif\";\n"
            new_file.append(new_string)


        if str(dwidth-1) in line and ("q" in line or "data" in line or "sub_wire" in line):
            #print (line)
            new_line = line.replace(str(dwidth-1),"DWIDTH-1")
            if str(dwidth) in line:
                new_line = new_line.replace(str(dwidth)+"'h","")
            new_file.append(new_line)
        elif str(dwidth) in line and (("width" in line) or ("data" in line) or ("sub_wire" in line)):
            #print (line)
            new_line = line.replace(str(dwidth),"DWIDTH")
            new_file.append(new_line)
        elif str(awidth-1) in line and "address" in line:
            new_line = line.replace(str(awidth-1),"AWIDTH-1")
            new_file.append(new_line)
        elif str(awidth) in line and "widthad" in line:
            new_line = line.replace(str(awidth),"AWIDTH")
            new_file.append(new_line)
        elif str(mem_size) in line and "numwords" in line:
            #print ("mem_size = "+str(mem_size))
            new_line = line.replace(str(mem_size),"MEM_SIZE")
            new_file.append(new_line)
        elif "NO_PLI" in line:
            new_file.append("//"+line)
            no_pli = 1
        elif ".rif" in line:
            new_file.append("//"+line)
        elif "init_file" in line:
            new_line = line.replace("\"\"","INIT_FILE")    
            new_file.append(new_line)
        elif "`" in line and no_pli:
            new_file.append("//"+line)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)


def change_ram(fname,new_name,dwidth,awidth,mem_size):
    new_file = []
    first_input = 1
    no_pli = 0
    f = open(fname,'r')
    
    for line in f:
        #add paramter in the beginning. 
        if "input" in line and first_input:
            first_input = 0
            new_string = "    parameter DWIDTH = "+str(dwidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter AWIDTH = "+str(awidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter DEPTH = "+str(mem_size)+";\n"
            new_file.append(new_string)


        if str(dwidth-1) in line and ("q" in line or "data" in line or "sub_wire" in line):
            #print (line)
            new_line = line.replace(str(dwidth-1),"DWIDTH-1")
            if str(dwidth) in line:
                new_line = new_line.replace(str(dwidth)+"'h","")
            new_file.append(new_line)
        elif str(dwidth) in line and (("width" in line) or ("data" in line) or ("sub_wire" in line)):
            #print (line)
            new_line = line.replace(str(dwidth),"DWIDTH")
            new_file.append(new_line)
        elif str(awidth-1) in line and "address" in line:
            new_line = line.replace(str(awidth-1),"AWIDTH-1")
            new_file.append(new_line)
        elif str(awidth) in line and "widthad" in line:
            new_line = line.replace(str(awidth),"AWIDTH")
            new_file.append(new_line)
        elif str(mem_size) in line and "numwords" in line:
            #print ("mem_size = "+str(mem_size))
            new_line = line.replace(str(mem_size),"DEPTH")
            new_file.append(new_line)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)

def change_diff_width_ram(fname,new_name,w_dwidth,w_awidth,w_depth,r_dwidth,r_awidth,r_depth):
    new_file = []
    first_input = 1
    no_pli = 0
    f = open(fname,'r')
    
    for line in f:
        #add paramter in the beginning. 
        if "input" in line and first_input:
            first_input = 0
            new_string = "    parameter W_DWIDTH = "+str(w_dwidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter W_AWIDTH = "+str(w_awidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter W_DEPTH = "+str(w_depth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter R_DWIDTH = "+str(r_dwidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter R_AWIDTH = "+str(r_awidth)+";\n"
            new_file.append(new_string)
            new_string = "    parameter R_DEPTH = "+str(r_depth)+";\n"
            new_file.append(new_string)


        if str(w_dwidth-1) in line and ("data" in line):
            new_line = line.replace(str(w_dwidth-1),"W_DWIDTH-1")
            new_file.append(new_line)
        elif str(w_dwidth) in line and ("width_a" in line):
            new_line = line.replace(str(w_dwidth),"W_DWIDTH")
            new_file.append(new_line)
        elif str(w_awidth-1) in line and "wraddress" in line:
            new_line = line.replace(str(w_awidth-1),"W_AWIDTH-1")
            new_file.append(new_line)
        elif str(w_awidth) in line and "widthad_a" in line:
            new_line = line.replace(str(w_awidth),"W_AWIDTH")
            new_file.append(new_line)
        elif str(w_depth) in line and "numwords_a" in line:
            new_line = line.replace(str(w_depth),"W_DEPTH")
            new_file.append(new_line)
        elif str(r_dwidth-1) in line and (("q" in line) or ("sub_wire" in line)):
            new_line = line.replace(str(r_dwidth-1),"R_DWIDTH-1")
            new_file.append(new_line)
        elif str(r_dwidth) in line and (("width_b" in line) or ("data_b" in line)):
            new_line = line.replace(str(r_dwidth),"R_DWIDTH")
            new_file.append(new_line)
        elif str(r_awidth-1) in line and "rdaddress" in line:
            new_line = line.replace(str(r_awidth-1),"R_AWIDTH-1")
            new_file.append(new_line)
        elif str(r_awidth) in line and "widthad_b" in line:
            new_line = line.replace(str(r_awidth),"R_AWIDTH")
            new_file.append(new_line)
        elif str(r_depth) in line and "numwords_b" in line:
            new_line = line.replace(str(r_depth),"R_DEPTH")
            new_file.append(new_line)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)

def change_multiplexer(fname,new_name):
    new_file = []
    first_input = 1
    no_pli = 0
    f = open(fname,'r')
    first = 0

    for line in f:
        #add paramter in the beginning. 
        if ("module" in line) and ("endmodule" not in line) and not first:
            new_line = line.replace("(","")
            new_file.append(new_line)
            new_line = "  #( parameter DWIDTH = 250 )\n"
            new_file.append(new_line)
            new_line = "  (\n"
            new_file.append(new_line)
            first = 1
        elif "250" in line:
            new_line = line.replace("250","DWIDTH")
            new_file.append(new_line)
        else:
            new_file.append(line)
    f.close()

    with open(fname, 'w') as f:
        for line in new_file:
            f.write("%s" % line)


def copy_file(ip_path,ip,dest_dir,keyword):
    file_path=ip_path+ip
    dirs = [f for f in listdir(file_path) if isdir(join(file_path, f))]
    for gen_dir in dirs:
        #print (gen_dir)
        if (keyword in gen_dir):
            if "st_adapter" in ip:
                if "data_format" in gen_dir:
                    sub_dir = gen_dir
            else:
                sub_dir = gen_dir

    file_path=ip_path+ip+"/"+sub_dir+"/synth/"
    files = [f for f in listdir(file_path) if isfile(join(file_path, f))]
    if "st_adapter" in ip:
        for f in files:
            if "ram" not in f:
                src_file_name=f
                break
    else:
        src_file_name=files[0]

    src_file = file_path+src_file_name
    shutil.copy(src_file,dest_dir)
    dst_file = dest_dir + "/" + src_file_name
    file_suffix = src_file_name.split(".")[1]
    new_dst_file = dest_dir + "/" + ip+"."+file_suffix
    os.rename(dst_file,new_dst_file)
    return new_dst_file
 
#set the file
ip_list = []

#fifo
ip_list.append("fifo_pkt_wrapper_infill")
ip_list.append("fifo_pkt_core_infill")
ip_list.append("fifo_pkt_wrapper")
ip_list.append("fifo_pkt_core")
ip_list.append("fifo_wrapper_infill")
ip_list.append("fifo_core_infill")
ip_list.append("fifo_wrapper")
ip_list.append("fifo_core")
ip_list.append("fifo_pkt_wrapper_infill_mlab")
ip_list.append("fifo_pkt_core_infill_mlab")
ip_list.append("fifo_wrapper_infill_mlab")
ip_list.append("fifo_core_infill_mlab")
ip_list.append("fifo_wrapper_mlab")
ip_list.append("fifo_core_mlab")
ip_list.append("dc_fifo_wrapper_infill")
ip_list.append("dc_fifo_core_infill")
ip_list.append("dc_fifo_wrapper")
ip_list.append("dc_fifo_core")
ip_list.append("dc_fifo_wrapper_infill_mlab")
ip_list.append("dc_fifo_core_infill_mlab")
ip_list.append("dc_fifo_wrapper_mlab")
ip_list.append("dc_fifo_core_mlab")


#rom
ip_list.append("rom_1port_mlab")
ip_list.append("rom_2port_noreg")
ip_list.append("rom_2port")

#ram
ip_list.append("bram_1port")
ip_list.append("bram_dc_diff_width")
ip_list.append("bram_simple2port")
ip_list.append("bram_true2port")

#st_adapter
ip_list.append("st_adapter_512_256")
ip_list.append("st_adapter_512_128")
ip_list.append("st_adapter_512_64")

#st_multiplexer
ip_list.append("st_multiplexer")
ip_list.append("st_multiplexer_pkt")
ip_list.append("st_multiplexer_pkt_3")

#dsp
ip_list.append("dsp")
ip_list.append("singledsp")


ip_path = "./ip/ip_gen/"

if os.path.isdir("generated_files"):
    shutil.rmtree("generated_files")
os.mkdir('generated_files')
dest_dir = "./generated_files"
#print(dest_dir)

for ip in ip_list:
    if "wrapper" in ip and "fifo" in ip:
        #Assume the non mlab is generated first
        if "mlab" in ip:
            src_file_name=ip.split("_mlab")[0]+".v"
            src_file = dest_dir + "/" + src_file_name
            dst_file = dest_dir + "/" + ip+".v"
            shutil.copy(src_file,dst_file)
            #os.rename(src_file,dst_file)
            change_wrapper(dst_file,ip)
        else:
            file_path=ip_path+ip+"/synth/"
            files = [f for f in listdir(file_path) if isfile(join(file_path, f))]
            src_file_name=files[0]
            src_file = file_path+files[0]
            #print(src_file)
            shutil.copy(src_file,dest_dir)
            dst_file = dest_dir + "/" + src_file_name
            change_wrapper(dst_file,ip)
    elif "core" in ip and "fifo" in ip:
        #Assume the non mlab is generated first
        if "mlab" in ip:
            src_file_name=ip.split("_mlab")[0]+".v"
            src_file = dest_dir + "/" + src_file_name
            dst_file = dest_dir + "/" + ip+".v"
            shutil.copy(src_file,dst_file)
            #os.rename(src_file,dst_file)
            change_to_mlab(dst_file,ip)
        else:
            file_path=ip_path+ip.replace("core","wrapper")
            dirs = [f for f in listdir(file_path) if isdir(join(file_path, f))]
            for gen_dir in dirs:
                #print (gen_dir)
                if "altera_avalon" in gen_dir:
                    sub_dir = gen_dir

            file_path=ip_path+ip.replace("core","wrapper")+"/"+sub_dir+"/synth/"
            files = [f for f in listdir(file_path) if isfile(join(file_path, f))]
            if "dc" in ip:
                for each_file in files:
                    #print (each_file)
                    if "sdc" not in each_file:
                        src_file_name=each_file
                        src_file = file_path+each_file
                        shutil.copy(src_file,dest_dir)
                        if "dc_fifo" in src_file_name:
                            dst_file = dest_dir + "/" + src_file_name
                            file_suffix = src_file_name.split(".")[1]
                            new_dst_file = dest_dir + "/" + ip+"."+file_suffix
                            os.rename(dst_file,new_dst_file)
            else:
                src_file_name=files[0]
                src_file = file_path+files[0]
                #print(src_file)
                shutil.copy(src_file,dest_dir)
                dst_file = dest_dir + "/" + src_file_name
                file_suffix = src_file_name.split(".")[1]
                new_dst_file = dest_dir + "/" + ip+"."+file_suffix
                os.rename(dst_file,new_dst_file)

            change_module_name(new_dst_file,ip)
    elif ("rom" in ip) or ("ram" in ip):
        if "rom" in ip:
            new_dst_file = copy_file(ip_path,ip,dest_dir,"rom")
        else: 
            new_dst_file = copy_file(ip_path,ip,dest_dir,"ram")

        change_module_name(new_dst_file,ip)
        if "rom_2port" in ip:
            change_rom(new_dst_file,ip,16,15,32768)
        elif "rom_1port" in ip:
            change_rom(new_dst_file,ip,16,5,32)
        elif ("bram" in ip) and ("dc" not in ip):
            change_ram(new_dst_file,ip,16,9,512)
        elif "bram_dc_diff_width" in ip:
            change_diff_width_ram(new_dst_file,ip,512,9,512,32,13,8192)
    elif "st_adapter" in ip:
        new_dst_file = copy_file(ip_path,ip,dest_dir,"adapter")
        change_module_name(new_dst_file,ip)
    elif "st_multiplexer" in ip:
        new_dst_file = copy_file(ip_path,ip,dest_dir,"multiplexer")
        change_module_name(new_dst_file,ip)
        if "pkt" not in ip:
            change_multiplexer(new_dst_file,ip)
    elif "dsp" in ip:
        new_dst_file = copy_file(ip_path,ip,dest_dir,"dsp")
        change_module_name(new_dst_file,ip)
    
