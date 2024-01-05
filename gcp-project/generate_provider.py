#!/usr/bin/python3

import hcl
from jinja2 import Template
import glob

with open("terraform.tfvars", "r") as tfvars_in:
      tfvars = hcl.load(tfvars_in)

for tfname in glob.glob("./*.j2"):
    with open(tfname, "r") as f:
        fname = tfname.replace(".j2","")
        Template(f.read()).stream(tfvars).dump(fname)
