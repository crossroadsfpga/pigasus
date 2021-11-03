import argparse
import xml.etree.ElementTree as ET
import os
from jinja2 import Environment, FileSystemLoader
from copy import copy
from copy import deepcopy
#from ROM import ROM
from math import log2
from math import ceil

def get_nf_in_rules():
    nf_in_rules = 0
    f = open("../struct_s.sv")
    for line in f:
        if("NF_IN_RULES" in line):
            nf_in_rules_string = line.split("=")[1]
            nf_in_rules_string = nf_in_rules_string.split(";")[0]
            nf_in_rules = int(nf_in_rules_string)
            break
    return nf_in_rules

def get_nf_out_rules():
    nf_out_rules = 0
    f = open("../struct_s.sv")
    for line in f:
        if("NF_OUT_RULES" in line):
            nf_out_rules_string = line.split("=")[1]
            nf_out_rules_string = nf_out_rules_string.split(";")[0]
            nf_out_rules = int(nf_out_rules_string)
            break
    return nf_out_rules

def get_byte_size():
    byte_size = 0
    f = open("../struct_s.sv")
    for line in f:
        if("NFP_DWIDTH" in line):
            byte_string = line.split("=")[1]
            byte_string = byte_string.split(";")[0]
            byte_size = int(byte_string) >> 3
            break
    return byte_size

context = {}
nf_in_rules = get_nf_in_rules()
nf_out_rules = get_nf_out_rules()
nf_out_rules_half = nf_out_rules//2
nf_rule_layer = int(log2(nf_in_rules//nf_out_rules))
nf_rule_layer_half = []
 

byte_size = get_byte_size()
half_byte_size = byte_size >> 1
bucket_size = 8
byte_pos = []
bucket = []
nbits = []
andmsk = []
mem_size = []
bm_size = []
arb_size = 8
#this is 2^5 = 32
fifo_depth = 5 
cal_layer = int(log2(byte_size)) + 1
byte_size_log = []

nbits.append(17)
nbits.append(13)
nbits.append(13)
nbits.append(13)
nbits.append(13)
nbits.append(12)
nbits.append(11)
nbits.append(10)

andmsk.append("64'hffffffffffffffff")
andmsk.append("64'hffffffffffffff00")
andmsk.append("64'hffffffffffff0000")
andmsk.append("64'hffffffffff000000")
andmsk.append("64'hffffffff00000000")
andmsk.append("64'hffffff0000000000")
andmsk.append("64'hffff000000000000")
andmsk.append("64'hff00000000000000")

for i in range(0,bucket_size):
    temp = 2**nbits[i]
    mem_size.append(temp)
    bm_size.append(int(temp/8))

for i in range(0,byte_size):
    byte_pos.append(i)

for i in range(0,bucket_size):
    bucket.append(i)

for i in range(0,nf_rule_layer):
    nf_rule_layer_half.append(nf_in_rules>>(i+1))

for i in range(0,cal_layer):
    byte_size_log.append(byte_size>>i)


context['byte_pos'] = byte_pos
context['bucket'] = bucket
context['bucket_size'] = bucket_size
context['byte_size'] = byte_size
context['half_byte_size'] = half_byte_size
context['nbits'] = nbits
context['andmsk'] = andmsk
context['mem_size'] = mem_size
context['bm_size'] = bm_size
context['arb_size'] = arb_size
context['fifo_depth'] = fifo_depth
context['shiftor_num'] = byte_size >> 3
context['nf_in_rules'] = nf_in_rules
context['nf_out_rules'] = nf_out_rules
context['nf_out_rules_half'] = nf_out_rules_half
context['nf_rule_layer'] = nf_rule_layer
context['nf_rule_layer_half'] = nf_rule_layer_half
context['cal_layer'] = cal_layer
context['byte_size_log'] = byte_size_log

#print (nf_in_rules, nf_out_rules)
#print (nf_rule_layer_half)
########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('non_fast_pattern_wrapper.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('non_fast_pattern_wrapper.sv', 'w') as outFile:
    outFile.write(rendered_file)


########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('non_fast_pattern_ht.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('non_fast_pattern_ht.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('shift_or.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('non_fast_pattern_shiftor.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('non_fast_pattern_sm.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('non_fast_pattern_sm.sv', 'w') as outFile:
    outFile.write(rendered_file)


########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('cal_fp.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('cal_fp.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('nf_rule_reduction.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('nf_rule_reduction.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('nf_fp_matcher.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('nf_fp_matcher.sv', 'w') as outFile:
    outFile.write(rendered_file)


