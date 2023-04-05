#! /usr/bin/env python
from __future__ import print_function
import netCDF4
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy
import subprocess

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=netCDF4.Dataset('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=netCDF4.Dataset('b2tallies.nc','r')
vreg=f.dimensions['vreg'].size
freg=f.dimensions['freg'].size
ns=f.dimensions['ns'].size
time=f.dimensions['time'].size
times=f.variables['times']
fhereg=f.variables['fhereg']
fhireg=f.variables['fhireg']

plt.plot(times[:],-fhereg[:,1]-fhireg[:,1], label='-W')
plt.plot(times[:],-fhereg[:,2]-fhireg[:,2], label='-w')
plt.plot(times[:],fhereg[:,3]+fhireg[:,3], label='e')
plt.plot(times[:],fhereg[:,4]+fhireg[:,4], label='E')
plt.plot(times[:],fhereg[:,8]+fhireg[:,8], label='core')
plt.plot(times[:],fhereg[:,10]+fhireg[:,10], label='sep')
plt.plot(times[:],numpy.sum(fhereg[:,11:13],axis=1)+numpy.sum(fhireg[:,11:13],axis=1), label='mcw')
plt.plot(times[:],-fhereg[:,7]-fhireg[:,7]-fhereg[:,9]-fhireg[:,9], label='-pfw')
if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time [s]')
plt.ylabel('energy fluxes [W]')

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
  plt.savefig('energy_analysis.' + os.getenv('SOLPS_PYTHON_PLOT'))




