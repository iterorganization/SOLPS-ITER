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
rqradreg=f.variables['rqradreg']

for R in range(rqradreg.shape[2]):
  plt.plot(times[:],numpy.sum(rqradreg[:,:,R],axis=1), label=str(R))
  print 'RQRADREG(%s) = %s' % (R,numpy.sum(rqradreg[-1,:,R],axis=0))

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('rqradreg by region')

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
  plt.savefig('rqradreg_region.' + os.getenv('SOLPS_PYTHON_PLOT'))
