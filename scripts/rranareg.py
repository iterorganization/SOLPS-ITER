#! /usr/bin/env python
from __future__ import print_function
import pupynere
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy
import re

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=pupynere.netcdf_file('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=pupynere.netcdf_file('b2tallies.nc','r')
times=f.variables['times']
rranareg=f.variables['rranareg']
species_names=f.variables['species']
species=[b''.join(species_names[i,:]).strip().decode('utf-8') for i in range(species_names.shape[0])]

nargs=len(sys.argv)
R=0
if nargs > 1: R=int(sys.argv[1])

for i in range(rranareg.shape[1]):
  print ('%8s : %8.2e' % (species[i],rranareg[-1,i,R]))
  plt.plot(times[:],rranareg[:,i,R], label=species[i])
print ('%8s : %8.2e' % ('Sum',numpy.sum(rranareg[-1,:,R],axis=0)))
plt.plot(times[:],numpy.sum(rranareg[:,:,R],axis=1), label='Sum')

ncol=max(1,rranareg.shape[1]/10)

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False, ncol=ncol)
plt.xlabel('time')
plt.ylabel('rranareg for region = '+str(R))

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
  plt.savefig('rranareg.' + os.getenv('SOLPS_PYTHON_PLOT'))
