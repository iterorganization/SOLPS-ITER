#! /usr/bin/env python

import netCDF4
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy


if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=netCDF4.Dataset('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=netCDF4.Dataset('b2tallies.nc','r')
vreg=f.dimensions['vreg'].size
xreg=f.dimensions['xreg'].size
yreg=f.dimensions['yreg'].size
times=f.variables['times']
fchxreg=f.variables['fchxreg']
fchyreg=f.variables['fchyreg']
extschreg=f.variables['b2sext_sch_reg']

if vreg == 2:

  plt.plot(times[:],fchxreg[:,1], label='W')
  plt.plot(times[:],-fchxreg[:,2], label='-E')
  plt.plot(times[:],fchyreg[:,1], label='S')
  plt.plot(times[:],-fchyreg[:,2], label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchxreg[:,1]-fchxreg[:,2]+fchyreg[:,1]-fchyreg[:,2]+extschreg[:,0], label='Sum')

elif vreg == 5:

  plt.plot(times[:],fchxreg[:,1], label='W')
  plt.plot(times[:],-fchxreg[:,4], label='-E')
  plt.plot(times[:],fchyreg[:,2], label='core')
  plt.plot(times[:],fchyreg[:,1], label='pflxl')
  plt.plot(times[:],fchyreg[:,3], label='pflxr')
  plt.plot(times[:],-numpy.sum(fchyreg[:,5:8],axis=1), label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchxreg[:,1]-fchxreg[:,4]+fchyreg[:,2]+fchyreg[:,1]+fchyreg[:,3]-numpy.sum(fchyreg[:,5:8],axis=1)+extschreg[:,0], label='Sum')

else:

  plt.plot(times[:],fchxreg[:,1], label='W1')
  plt.plot(times[:],-fchxreg[:,4], label='-E1')
  plt.plot(times[:],fchxreg[:,5], label='W2')
  plt.plot(times[:],-fchxreg[:,8], label='-E2')
  plt.plot(times[:],fchyreg[:,2], label='core1')
  plt.plot(times[:],fchyreg[:,1], label='pflxl1')
  plt.plot(times[:],fchyreg[:,3], label='pflxr1')
  plt.plot(times[:],-numpy.sum(fchyreg[:,5:8],axis=1), label='-N1')
  plt.plot(times[:],fchyreg[:,9], label='core2')
  plt.plot(times[:],fchyreg[:,8], label='pflxl2')
  plt.plot(times[:],fchyreg[:,10], label='pflxr2')
  plt.plot(times[:],-fchyreg[:,12:15], label='-N2')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchxreg[:,1]-fchxreg[:,4]+fchyreg[:,2]+fchyreg[:,1]+fchyreg[:,3]-numpy.sum(fchyreg[:,5:8],axis=1)+extschreg[:,0]+fchxreg[:,5]-fchxreg[:,8]+fchyreg[:,9]+fchyreg[:,8]+fchyreg[:,10]-fchyreg[:,12:15]+extschreg[:,0], label='Sum')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel("current ( - losses / + sources )")

if vreg == 2:

  WEST=fchxreg[-1,1]
  EAST=-fchxreg[-1,2]
  SOUTH=fchyreg[-1,1]
  NORTH=-fchyreg[-1,2]
  EXT=extschreg[-1,0]
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print('South = %s' % (SOUTH))
  print('North = %s' % (NORTH))
  print('East = %s' % (EAST))
  print('West = %s' % (WEST))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))

elif vreg == 5:

  WEST=fchxreg[-1,1]
  west=fchxreg[-1,2]
  east=-fchxreg[-1,3]
  EAST=-fchxreg[-1,4]
  CORE=fchyreg[-1,2]
  SEP=fchyreg[-1,4]
  PFLXL=fchyreg[-1,1]
  PFLXR=fchyreg[-1,3]
  NORTH=-numpy.sum(fchyreg[-1,5:8],axis=0)
  EXT=extschreg[-1,0]
  EXTCORE=extschreg[-1,1]
  SUM=WEST+EAST+CORE+PFLXL+PFLXR+NORTH+EXT

  print('Core = %s' % (CORE))
  print('Sep = %s' % (SEP))
  print('North = %s' % (NORTH))
  print('East = %s' % (EAST))
  print('east = %s' % (east))
  print('west = %s' % (west))
  print('West = %s' % (WEST))
  print('Pflxl = %s' % (PFLXL))
  print('Pflxr = %s' % (PFLXR))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))
  print('ExtCore = %s' % (EXTCORE))
  print('SumCore = %s' % (CORE-SEP+EXTCORE))

else:

  WEST1=fchxreg[-1,1]
  west1=fchxreg[-1,2]
  east1=-fchxreg[-1,3]
  EAST1=-fchxreg[-1,4]
  WEST2=fchxreg[-1,5]
  west2=fchxreg[-1,6]
  east2=-fchxreg[-1,7]
  EAST2=-fchxreg[-1,8]
  CORE1=fchyreg[-1,2]
  SEP1=fchyreg[-1,4]
  PFLXL1=fchyreg[-1,1]
  PFLXR1=fchyreg[-1,3]
  NORTH1=-numpy.sum(fchyreg[-1,5:8],axis=0)
  CORE2=fchyreg[-1,8]
  SEP2=fchyreg[-1,11]
  PFLXL2=fchyreg[-1,8]
  PFLXR2=fchyreg[-1,10]
  NORTH2=-fchyreg[-1,12:15]
  EXT=extschreg[-1,0]
  EXTCORE=extschreg[-1,1]
  SUM=WEST1+EAST1+CORE1+PFLXL1+PFLXR1+NORTH1+WEST2+EAST2+CORE2+PFLXL2+PFLXR2+NORTH2+EXT

  print('Core1 = %s' % (CORE1))
  print('Sep1 = %s' % (SEP1))
  print('North1 = %s' % (NORTH1))
  print('East1 = %s' % (EAST1))
  print('east1 = %s' % (east1))
  print('west1 = %s' % (west1))
  print('West1 = %s' % (WEST1))
  print('Core2 = %s' % (CORE2))
  print('Sep2 = %s' % (SEP2))
  print('North2 = %s' % (NORTH2))
  print('East2 = %s' % (EAST2))
  print('east2 = %s' % (east2))
  print('west2 = %s' % (west2))
  print('West2 = %s' % (WEST2))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))
  print('ExtCore = %s' % (EXTCORE))
  print('SumCore = %s' % (CORE1+CORE2-SEP1-SEP2+EXTCORE))

# print('SumSOL = %s' % (SEP-fchyreg[-1,6]+west+east))

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
  plt.savefig('fluid_fluxes.' + os.getenv('SOLPS_PYTHON_PLOT'))
