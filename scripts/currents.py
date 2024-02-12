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
freg=f.dimensions['freg'].size
times=f.variables['times']
fchreg=f.variables['fchreg']
extschreg=f.variables['b2sext_sch_reg']

if vreg == 2:

  plt.plot(times[:],fchreg[:,1], label='W')
  plt.plot(times[:],-fchreg[:,2], label='-E')
  plt.plot(times[:],fchreg[:,3], label='S')
  plt.plot(times[:],-fchreg[:,4], label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,2]+fchreg[:,3]-fchreg[:,4]+extschreg[:,0], label='Sum')

elif vreg == 3:

  plt.plot(times[:],fchreg[:,1], label='W')
  plt.plot(times[:],-fchreg[:,2], label='-E')
  plt.plot(times[:],fchreg[:,4], label='core')
  plt.plot(times[:],-fchreg[:,6], label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,2]+fchreg[:,4]-fchreg[:,6]+extschreg[:,0], label='Sum')

elif vreg == 5:

  plt.plot(times[:],fchreg[:,1], label='W')
  plt.plot(times[:],-fchreg[:,4], label='-E')
  plt.plot(times[:],fchreg[:,8], label='core')
  plt.plot(times[:],fchreg[:,7], label='pflxl')
  plt.plot(times[:],fchreg[:,9], label='pflxr')
  plt.plot(times[:],-numpy.sum(fchreg[:,11:13],axis=1), label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,4]+fchreg[:,8]+fchreg[:,7]+fchreg[:,9]-numpy.sum(fchreg[:,11:13],axis=1)+extschreg[:,0], label='Sum')

elif vreg == 8:

  plt.plot(times[:],fchreg[:,1], label='W')
  plt.plot(times[:],-fchreg[:,4], label='-E1')
  plt.plot(times[:],fchreg[:,5], label='E2')
  plt.plot(times[:],-fchreg[:,8], label='-E3')
  plt.plot(times[:],fchreg[:,15], label='core')
  plt.plot(times[:],fchreg[:,14], label='pflxl')
  plt.plot(times[:],fchreg[:,16]+numpy.sum(fchreg[:,21:23],axis=1), label='pflxr')
  plt.plot(times[:],-numpy.sum(fchreg[:,18:20],axis=1)-numpy.sum(fchreg[:,24:26],axis=1), label='-N')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,4]+fchreg[:,5]-fchreg[:,8]+fchreg[:,15]+fchreg[:,14]+fchreg[:,16]+numpy.sum(fchreg[:,21:23],axis=1)-numpy.sum(fchreg[:,18:20],axis=1)-numpy.sum(fchreg[:,24:26],axis=1)+extschreg[:,0], label='Sum')

elif freg == 27:

  plt.plot(times[:],fchreg[:,1], label='W1')
  plt.plot(times[:],-fchreg[:,4], label='-E1')
  plt.plot(times[:],fchreg[:,5], label='W2')
  plt.plot(times[:],-fchreg[:,8], label='-E2')
  plt.plot(times[:],fchreg[:,14], label='core1')
  plt.plot(times[:],fchreg[:,13], label='pflxl1')
  plt.plot(times[:],fchreg[:,15], label='pflxr1')
  plt.plot(times[:],-numpy.sum(fchreg[:,17:19],axis=1), label='-N1')
  plt.plot(times[:],fchreg[:,21], label='core2')
  plt.plot(times[:],fchreg[:,20], label='pflxl2')
  plt.plot(times[:],fchreg[:,22], label='pflxr2')
  plt.plot(times[:],-fchreg[:,24:26], label='-N2')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,4]+fchreg[:,14]+fchreg[:,13]+fchreg[:,15]-numpy.sum(fchreg[:,17:19],axis=1)+fchreg[:,5]-fchreg[:,8]+fchreg[:,21]+fchreg[:,20]+fchreg[:,22]-fchreg[:,24:26]+extschreg[:,0], label='Sum')

elif freg == 28:

  plt.plot(times[:],fchreg[:,1], label='W1')
  plt.plot(times[:],-fchreg[:,4], label='-E1')
  plt.plot(times[:],fchreg[:,5], label='W2')
  plt.plot(times[:],-fchreg[:,8], label='-E2')
  plt.plot(times[:],fchreg[:,15], label='core1')
  plt.plot(times[:],fchreg[:,14], label='pflxl1')
  plt.plot(times[:],fchreg[:,16], label='pflxr1')
  plt.plot(times[:],-numpy.sum(fchreg[:,18:20],axis=1), label='-N1')
  plt.plot(times[:],fchreg[:,22], label='core2')
  plt.plot(times[:],fchreg[:,21], label='pflxl2')
  plt.plot(times[:],fchreg[:,23], label='pflxr2')
  plt.plot(times[:],-fchreg[:,25:27], label='-N2')
  plt.plot(times[:],extschreg[:,0], label='EXT')
  plt.plot(times[:],fchreg[:,1]-fchreg[:,4]+fchreg[:,15]+fchreg[:,14]+fchreg[:,16]-numpy.sum(fchreg[:,18:20],axis=1)+fchreg[:,5]-fchreg[:,8]+fchreg[:,22]+fchreg[:,21]+fchreg[:,23]-fchreg[:,25:27]+extschreg[:,0], label='Sum')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel("current ( - losses / + sources )")

if vreg == 2:

  WEST=fchreg[-1,1]
  EAST=-fchreg[-1,2]
  SOUTH=fchreg[-1,3]
  NORTH=-fchreg[-1,4]
  EXT=extschreg[-1,0]
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print('South = %s' % (SOUTH))
  print('North = %s' % (NORTH))
  print('East = %s' % (EAST))
  print('West = %s' % (WEST))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))

elif vreg == 3:

  WEST=fchreg[-1,1]
  EAST=-fchreg[-1,2]
  CORE=fchreg[-1,4]
  NORTH=-fchreg[-1,6]
  EXT=extschreg[-1,0]
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print('Core = %s' % (CORE))
  print('North = %s' % (NORTH))
  print('East = %s' % (EAST))
  print('West = %s' % (WEST))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))

elif vreg == 5:

  WEST=fchreg[-1,1]
  west=fchreg[-1,2]
  east=-fchreg[-1,3]
  EAST=-fchreg[-1,4]
  CORE=fchreg[-1,8]
  SEP=fchreg[-1,10]
  PFLXL=fchreg[-1,7]
  PFLXR=fchreg[-1,9]
  NORTH=-numpy.sum(fchreg[-1,11:13],axis=0)
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

elif vreg == 6:

  WEST=fchreg[-1,1]
  west=fchreg[-1,2]
  east=-fchreg[-1,3]
  EAST=-fchreg[-1,4]
  CORE=fchreg[-1,9]
  SEP=fchreg[-1,11]
  PFLXL=fchreg[-1,8]
  PFLXR=fchreg[-1,10]
  ISLAND=fchreg[-1,15]
  NORTH=-fchreg[-1,13]
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
  print('Island = %s' % (ISLAND))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))
  print('ExtCore = %s' % (EXTCORE))
  print('SumCore = %s' % (CORE-SEP+EXTCORE))

elif vreg == 8:

  WEST=fchreg[-1,1]
  west=fchreg[-1,2]
  east1=-fchreg[-1,3]
  EAST1=-fchreg[-1,4]
  EAST2=fchreg[-1,5]
  east3=fchreg[-1,7]
  EAST3=fchreg[-1,8]
  CORE=fchreg[-1,15]
  SEP=fchreg[-1,17]
  PFLXL=fchreg[-1,14]
  PFLXR=fchreg[-1,16]+numpy.sum(fchreg[-1,21:23],axis=0)
  NORTH=-numpy.sum(fchreg[-1,18:20],axis=0)-numpy.sum(fchreg[-1,24:26],axis=0)
  EXT=extschreg[-1,0]
  EXTCORE=extschreg[-1,1]
  SUM=WEST+EAST+CORE+PFLXL+PFLXR+NORTH+EXT

  print('Core = %s' % (CORE))
  print('Sep = %s' % (SEP))
  print('North = %s' % (NORTH))
  print('East1 = %s' % (EAST1))
  print('east1 = %s' % (east1))
  print('East2 = %s' % (EAST2))
  print('east3 = %s' % (east3))
  print('East3 = %s' % (EAST3))
  print('west = %s' % (west))
  print('West = %s' % (WEST))
  print('Pflxl = %s' % (PFLXL))
  print('Pflxr = %s' % (PFLXR))
  print('Ext = %s' % (EXT))
  print('Sum = %s' % (SUM))
  print('ExtCore = %s' % (EXTCORE))
  print('SumCore = %s' % (CORE-SEP+EXTCORE))

elif freg == 27:

  WEST1=fchreg[-1,1]
  west1=fchreg[-1,2]
  east1=-fchreg[-1,3]
  EAST1=-fchreg[-1,4]
  WEST2=fchreg[-1,5]
  west2=fchreg[-1,6]
  east2=-fchreg[-1,7]
  EAST2=-fchreg[-1,8]
  CORE1=fchreg[-1,14]
  SEP1=fchreg[-1,16]
  PFLXL1=fchreg[-1,13]
  PFLXR1=fchreg[-1,15]
  NORTH1=-numpy.sum(fchreg[-1,17:19],axis=0)
  CORE2=fchreg[-1,21]
  SEP2=fchreg[-1,23]
  PFLXL2=fchreg[-1,20]
  PFLXR2=fchreg[-1,22]
  NORTH2=-numpy.sum(fchreg[-1,24:26],axis=0)
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

elif freg == 28:

  WEST1=fchreg[-1,1]
  west1=fchreg[-1,2]
  east1=-fchreg[-1,3]
  EAST1=-fchreg[-1,4]
  WEST2=fchreg[-1,5]
  west2=fchreg[-1,6]
  east2=-fchreg[-1,7]
  EAST2=-fchreg[-1,8]
  CORE1=fchreg[-1,15]
  SEP1=fchreg[-1,17]
  PFLXL1=fchreg[-1,14]
  PFLXR1=fchreg[-1,16]
  NORTH1=-numpy.sum(fchreg[-1,18:20],axis=0)
  CORE2=fchreg[-1,22]
  SEP2=fchreg[-1,24]
  PFLXL2=fchreg[-1,21]
  PFLXR2=fchreg[-1,23]
  NORTH2=-numpy.sum(fchreg[-1,25:27],axis=0)
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

# print('SumSOL = %s' % (SEP-fchreg[-1,12]+west+east))

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
