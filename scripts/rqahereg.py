#! /usr/bin/env python
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
rqahereg=f.variables['rqahereg']
species_names=f.variables['species']
species=[''.join(species_names[i,:]).strip() for i in range(species_names.shape[0])]

nargs=len(sys.argv)
R=0
if nargs > 1: R=int(sys.argv[1])

for i in range(rqahereg.shape[1]):
  plt.plot(times[:],rqahereg[:,i,R], label=species[i])
  print species[i], rqahereg[-1,i,R]
plt.plot(times[:],numpy.sum(rqahereg[:,:,R],axis=1), label='Sum')
print 'Sum', numpy.sum(rqahereg[-1,:,R],axis=0)

ncol=max(1,rqahereg.shape[1]/10)

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False, ncol=ncol)
plt.xlabel('time')
plt.ylabel('rqahereg for region = '+str(R))

if os.getenv('SOLPS_PYTHON_PLOT') is None:
  plt.show()
else:
  plt.savefig('rqahereg.' + os.getenv('SOLPS_PYTHON_PLOT'))
