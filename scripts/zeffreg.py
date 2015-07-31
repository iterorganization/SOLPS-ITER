#! /usr/bin/env python
import pupynere
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy
import subprocess

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=pupynere.netcdf_file('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=pupynere.netcdf_file('b2tallies.nc','r')
vreg=f.dimensions['vreg']
times=f.variables['times']
nereg=f.variables['nereg']
ne2reg=f.variables['ne2reg']

for i in numpy.arange(0, vreg):
    plt.plot(times[:], ne2reg[:,i]/nereg[:,i], label=str(i))
    print "zeff(%s) = %s" % (i, ne2reg[-1,i]/nereg[-1,i])

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('zeff')

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
  plt.savefig('zeffreg.' + os.getenv('SOLPS_PYTHON_PLOT'))




