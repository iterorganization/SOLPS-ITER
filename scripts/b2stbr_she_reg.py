#! /usr/bin/env python
import pupynere
import matplotlib.pyplot as plt
import matplotlib
import sys
import numpy
import os
import re

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=pupynere.netcdf_file('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=pupynere.netcdf_file('b2tallies.nc','r')
times=f.variables['times']
b2stbr_she_reg=f.variables['b2stbr_she_reg']
volreg=f.variables['volreg']
species_names=f.variables['species']
species=[''.join(species_names[i,:]).strip() for i in range(species_names.shape[0])]

for i in range(b2stbr_she_reg.shape[1]):
  plt.plot(times[:],b2stbr_she_reg[:,i], label=str(i))

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('b2stbr_she_reg')

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
  
plt.show()
