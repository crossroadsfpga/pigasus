import argparse
import xml.etree.ElementTree as ET
import os
from jinja2 import Environment, FileSystemLoader
from copy import copy
from copy import deepcopy
#from ROM import ROM
from math import log2
from math import ceil

def get_byte_size():
    byte_size = 0
    f = open("../struct_s.sv")
    for line in f:
        if("FP_DWIDTH" in line):
            byte_string = line.split("=")[1]
            byte_string = byte_string.split(";")[0]
            byte_size = int(byte_string) >> 3
            break
    return byte_size

def get_pg_rules():
    pg_rules = 0
    f = open("../struct_s.sv")
    for line in f:
        if("PG_RULES" in line):
            pg_rules_string = line.split("=")[1]
            pg_rules_string = pg_rules_string.split(";")[0]
            pg_rules = int(pg_rules_string)
            break
    return pg_rules

#Main function

context = {}
byte_size = get_byte_size()
half_byte_size = byte_size >> 1
#Does not change for now
bucket_size = 8
byte_pos = []
bucket = []
nbits = []
andmsk = []
mem_size = []
bm_size = []
arb_size = 8


pg_rules = get_pg_rules()
last_layer_width = pg_rules//bucket_size
layer = int(log2(byte_size//last_layer_width))
layer_list = []
layer_list_half = []
#this is 2^5 = 32
fifo_depth = 5 


nbits.append(15)
nbits.append(15)
nbits.append(12)
nbits.append(12)
nbits.append(11)
nbits.append(12)
nbits.append(10)
nbits.append(8)

andmsk.append("64'hffffffffffffffff")
andmsk.append("64'hffffffffffffffff")
andmsk.append("64'hffffffffffffff00")
andmsk.append("64'hffffffffffff0000")
andmsk.append("64'hffffffffff000000")
andmsk.append("64'hffffffff00000000")
andmsk.append("64'hffffff0000000000")
andmsk.append("64'hffff000000000000")

for i in range(0,bucket_size):
    temp = 2**nbits[i]
    mem_size.append(temp)
    bm_size.append(int(temp/8))

for i in range(0,byte_size):
    byte_pos.append(i)

for i in range(0,bucket_size):
    bucket.append(i)

for i in range(0,layer):
    layer_list.append(byte_size>>i)
    layer_list_half.append(byte_size>>(i+1))


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
context['layer'] = layer
context['layer_list'] = layer_list
context['layer_list_half'] = layer_list_half
context['last_layer_width'] = last_layer_width
#print (layer)
#print (layer_list)
#print (layer_list_half)
#print (last_layer_width)
########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('first_filter.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('first_filter.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('hashtable_top.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('hashtable_top.sv', 'w') as outFile:
    outFile.write(rendered_file)


########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('frontend.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('frontend.sv', 'w') as outFile:
    outFile.write(rendered_file)

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('backend.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('backend.sv', 'w') as outFile:
    outFile.write(rendered_file)


########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('string_matcher.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('string_matcher.sv', 'w') as outFile:
    outFile.write(rendered_file)

