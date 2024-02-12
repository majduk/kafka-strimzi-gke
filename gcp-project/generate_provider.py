#!/usr/bin/python3

from jinja2 import Template
import glob

tfvars = {}
try:
  import hcl
  for tfname in glob.glob("./*.tfvars"):
    with open(tfname, "r") as tfvars_in:
      tfvars = tfvars | hcl.load(tfvars_in)
except ImportError:
  sys.stderr.write('*tfvars config not supported. Install hcl module\n')
try:
  import json
  for tfname in glob.glob("./*.tfvars.json"):
    with open(tfname, "r") as tfvars_in:
      tfvars = tfvars | json.load(tfvars_in)
except ImportError:
  sys.stderr.write('*tfvars.json config not supported. Install json module\n')

if len(tfvars) > 0:
  for tfname in glob.glob("./*.j2"):
      with open(tfname, "r") as f:
          fname = tfname.replace(".j2","")
          Template(f.read()).stream(tfvars).dump(fname)
  exit(0)
else:
  sys.stderr.write("Configuration empty, aborting\n")
  exit(1)
