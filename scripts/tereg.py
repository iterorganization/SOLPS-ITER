#! /usr/bin/env python
from __future__ import print_function
import netCDF4
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy
import re

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=netCDF4.Dataset('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=netCDF4.Dataset('b2tallies.nc','r')
times=f.variables['times']
tereg=f.variables['tereg']
volreg=f.variables['volreg']
species_names=f.variables['species']
species=[b''.join(species_names[i,:]).strip().decode('utf-8') for i in range(species_names.shape[0])]

for i in range(tereg.shape[1]):
  plt.semilogy(times[:],tereg[:,i], label=str(i))

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('tereg')

cwd=os.getcwd()
l=0
ncwd=''
for i in cwd.split('/'):
  if l + 1 + len(i) < 100:
    ncwd = ncwd + '/' + i
    l = l + 1 + len(i)
  else:
    ncwd = ncwd + '/\n' + i
    l = len(i)
plt.suptitle(ncwd[1:], fontsize=10)
  
if os.getenv('SOLPS_PYTHON_PLOT') is None:
  plt.show()
else:
  plt.savefig('tereg.' + os.getenv('SOLPS_PYTHON_PLOT'))
