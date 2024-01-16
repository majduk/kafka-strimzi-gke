#!/usr/bin/python3

import json
from jinja2 import Template
import glob

with open("terraform.tfvars.json", "r") as tfvars_in:
      tfvars = json.load(tfvars_in)

for tfname in glob.glob("./*.j2"):
    with open(tfname, "r") as f:
        fname = tfname.replace(".j2","")
        Template(f.read()).stream(tfvars).dump(fname)
