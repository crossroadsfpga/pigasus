import argparse
import xml.etree.ElementTree as ET
import os
from jinja2 import Environment, FileSystemLoader
from copy import copy
from copy import deepcopy
#from ROM import ROM
from math import log2
from math import ceil

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

pg_rules = get_pg_rules()
half_pg_rules = pg_rules>>1

context['pg_rules'] = pg_rules
context['half_pg_rules'] = half_pg_rules

########################################################
env = Environment(loader=FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('port_group.template')

# Render the template for the output file.
rendered_file = template.render(context=context)

# Write output file
with open('port_group.sv', 'w') as outFile:
    outFile.write(rendered_file)

