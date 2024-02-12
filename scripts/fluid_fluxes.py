#! /usr/bin/env python
from __future__ import print_function
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
ns=f.dimensions['ns'].size
times=f.variables['times']
fnareg=f.variables['fnareg']
extsnareg=f.variables['b2sext_sna_reg']
species_names=f.variables['species']
species=[b''.join(species_names[i,:]).strip().decode('utf-8') for i in range(species_names.shape[0])]

nargs=len(sys.argv)
S=0
E=len(species)-1
if nargs > 1: S=int(sys.argv[1])
if nargs > 2: E=int(sys.argv[2])

print(species[S],species[E])

if vreg == 2:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,2],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,3],axis=1), label='S')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,2],axis=1)+numpy.sum(fnareg[:,S:E+1,3],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif vreg == 3:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,2],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,4],axis=1), label='S')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,6],axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,2],axis=1)+numpy.sum(fnareg[:,S:E+1,4],axis=1)-numpy.sum(fnareg[:,S:E+1,6],axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif vreg == 5:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,8],axis=1), label='core')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,7],axis=1), label='pflxl')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,9],axis=1), label='pflxr')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,11:13],axis=1),axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(fnareg[:,S:E+1,8],axis=1)+numpy.sum(fnareg[:,S:E+1,7],axis=1)+numpy.sum(fnareg[:,S:E+1,9],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,11:13],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif vreg == 6:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,9],axis=1), label='core')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,8],axis=1), label='pflxl')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,10],axis=1), label='pflxr')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,13],axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(fnareg[:,S:E+1,9],axis=1)+numpy.sum(fnareg[:,S:E+1,8],axis=1)+numpy.sum(fnareg[:,S:E+1,10],axis=1)-numpy.sum(fnareg[:,S:E+1,13],axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif vreg == 8:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-E1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,5],axis=1), label='E2')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,8],axis=1), label='-E3')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,15],axis=1), label='core')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,14],axis=1), label='pflxl')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,16],axis=1)+numpy.sum(fnareg[:,S:E+1,23],axis=1), label='pflxr1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,21],axis=1)+numpy.sum(fnareg[:,S:E+1,22],axis=1), label='pflxr2')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,18:20],axis=1),axis=1)-numpy.sum(fnareg[:,S:E+1,26],axis=1), label='-N1')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,24:25],axis=1),axis=1), label='-N2')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(fnareg[:,S:E+1,5],axis=1)-numpy.sum(fnareg[:,S:E+1,8],axis=1)+numpy.sum(fnareg[:,S:E+1,15],axis=1)+numpy.sum(fnareg[:,S:E+1,14],axis=1)+numpy.sum(fnareg[:,S:E+1,16],axis=1)+numpy.sum(fnareg[:,S:E+1,23],axis=1)+numpy.sum(fnareg[:,S:E+1,21],axis=1)+numpy.sum(fnareg[:,S:E+1,22],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,18:20],axis=1),axis=1)-numpy.sum(fnareg[:,S:E+1,26],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,24:25],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif freg == 27:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W1')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-E1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,5],axis=1), label='W2')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,8],axis=1), label='-E2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,14],axis=1), label='core1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,13],axis=1), label='pflxl1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,15],axis=1), label='pflxr1')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,17:19],axis=1),axis=1), label='-N1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,21],axis=1), label='core2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,20],axis=1), label='pflxl2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,22],axis=1), label='pflxr2')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,24:26],axis=1),axis=1), label='-N2')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(fnareg[:,S:E+1,14],axis=1)+numpy.sum(fnareg[:,S:E+1,13],axis=1)+numpy.sum(fnareg[:,S:E+1,15],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,17:19],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1)+numpy.sum(fnareg[:,S:E+1,5],axis=1)-numpy.sum(fnareg[:,S:E+1,8],axis=1)+numpy.sum(fnareg[:,S:E+1,21],axis=1)+numpy.sum(fnareg[:,S:E+1,20],axis=1)+numpy.sum(fnareg[:,S:E+1,22],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,24:26],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif freg == 28:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1), label='W1')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,4],axis=1), label='-E1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,5],axis=1), label='W2')
  plt.plot(times[:],-numpy.sum(fnareg[:,S:E+1,8],axis=1), label='-E2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,15],axis=1), label='core1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,14],axis=1), label='pflxl1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,16],axis=1), label='pflxr1')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,18:20],axis=1),axis=1), label='-N1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,22],axis=1), label='core2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,21],axis=1), label='pflxl2')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,23],axis=1), label='pflxr2')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnareg[:,S:E+1,25:27],axis=1),axis=1), label='-N2')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,1],axis=1)-numpy.sum(fnareg[:,S:E+1,4],axis=1)+numpy.sum(fnareg[:,S:E+1,15],axis=1)+numpy.sum(fnareg[:,S:E+1,14],axis=1)+numpy.sum(fnareg[:,S:E+1,16],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,18:20],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1)+numpy.sum(fnareg[:,S:E+1,5],axis=1)-numpy.sum(fnareg[:,S:E+1,8],axis=1)+numpy.sum(fnareg[:,S:E+1,22],axis=1)+numpy.sum(fnareg[:,S:E+1,21],axis=1)+numpy.sum(fnareg[:,S:E+1,23],axis=1)-numpy.sum(numpy.sum(fnareg[:,S:E+1,25:27],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel(species[S] + "--" + species[E] + "   ( - losses / + sources )")

if vreg == 2:

  WEST=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  EAST=-numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  SOUTH=numpy.sum(fnareg[-1,S:E+1,3],axis=0)
  NORTH=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print('South(%s--%s) = %s' % (species[S],species[E],SOUTH))
  print('North(%s--%s) = %s' % (species[S],species[E],NORTH))
  print('East(%s--%s) = %s' % (species[S],species[E],EAST))
  print('West(%s--%s) = %s' % (species[S],species[E],WEST))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))

elif vreg == 3:

  WEST=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  EAST=-numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  SOUTH=numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  NORTH=-numpy.sum(fnareg[-1,S:E+1,6],axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print('South(%s--%s) = %s' % (species[S],species[E],SOUTH))
  print('North(%s--%s) = %s' % (species[S],species[E],NORTH))
  print('East(%s--%s) = %s' % (species[S],species[E],EAST))
  print('West(%s--%s) = %s' % (species[S],species[E],WEST))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))

elif vreg == 5:

  WEST=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  west=numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  east=-numpy.sum(fnareg[-1,S:E+1,3],axis=0)
  EAST=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  CORE=numpy.sum(fnareg[-1,S:E+1,8],axis=0)
  SEP=numpy.sum(fnareg[-1,S:E+1,10],axis=0)
  PFLXL=numpy.sum(fnareg[-1,S:E+1,7],axis=0)
  PFLXR=numpy.sum(fnareg[-1,S:E+1,9],axis=0)
  NORTH=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,11:13],axis=0),axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST+EAST+CORE+PFLXL+PFLXR+NORTH+EXT

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))
  print('Sep(%s--%s) = %s' % (species[S],species[E],SEP))
  print('North(%s--%s) = %s' % (species[S],species[E],NORTH))
  print('East(%s--%s) = %s' % (species[S],species[E],EAST))
  print('east(%s--%s) = %s' % (species[S],species[E],east))
  print('west(%s--%s) = %s' % (species[S],species[E],west))
  print('West(%s--%s) = %s' % (species[S],species[E],WEST))
  print('Pflxl(%s--%s) = %s' % (species[S],species[E],PFLXL))
  print('Pflxr(%s--%s) = %s' % (species[S],species[E],PFLXR))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))
  print('ExtCore(%s--%s) = %s' % (species[S],species[E],EXTCORE))
  print('SumCore(%s--%s) = %s' % (species[S],species[E],CORE-SEP+EXTCORE))

elif vreg == 6:

  WEST=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  west=numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  east=-numpy.sum(fnareg[-1,S:E+1,3],axis=0)
  EAST=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  CORE=numpy.sum(fnareg[-1,S:E+1,9],axis=0)
  SEP=numpy.sum(fnareg[-1,S:E+1,11],axis=0)
  PFLXL=numpy.sum(fnareg[-1,S:E+1,8],axis=0)
  PFLXR=numpy.sum(fnareg[-1,S:E+1,10],axis=0)
  ISLAND=numpy.sum(fnareg[-1,S:E+1,15],axis=0)
  NORTH=-numpy.sum(fnareg[-1,S:E+1,13],axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST+EAST+CORE+PFLXL+PFLXR+NORTH+EXT

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))
  print('Sep(%s--%s) = %s' % (species[S],species[E],SEP))
  print('North(%s--%s) = %s' % (species[S],species[E],NORTH))
  print('East(%s--%s) = %s' % (species[S],species[E],EAST))
  print('east(%s--%s) = %s' % (species[S],species[E],east))
  print('west(%s--%s) = %s' % (species[S],species[E],west))
  print('West(%s--%s) = %s' % (species[S],species[E],WEST))
  print('Pflxl(%s--%s) = %s' % (species[S],species[E],PFLXL))
  print('Pflxr(%s--%s) = %s' % (species[S],species[E],PFLXR))
  print('Island(%s--%s) = %s' % (species[S],species[E],ISLAND))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))
  print('ExtCore(%s--%s) = %s' % (species[S],species[E],EXTCORE))
  print('SumCore(%s--%s) = %s' % (species[S],species[E],CORE-SEP+EXTCORE))

elif vreg == 8:

  WEST=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  west=numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  east1=-numpy.sum(fnareg[-1,S:E+1,6],axis=0)
  EAST1=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  EAST2=numpy.sum(fnareg[-1,S:E+1,5],axis=0)
  east3=-numpy.sum(fnareg[-1,S:E+1,7],axis=0)
  EAST3=-numpy.sum(fnareg[-1,S:E+1,8],axis=0)
  CORE=numpy.sum(fnareg[-1,S:E+1,15],axis=0)
  SEP=numpy.sum(fnareg[-1,S:E+1,17],axis=0)
  PFLXL=numpy.sum(fnareg[-1,S:E+1,14],axis=0)
  PFLXR1=numpy.sum(fnareg[-1,S:E+1,16],axis=0)+numpy.sum(fnareg[-1,S:E+1,23],axis=0)
  PFLXR2=numpy.sum(fnareg[-1,S:E+1,21],axis=0)+numpy.sum(fnareg[-1,S:E+1,22],axis=0)
  NORTH1=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,18:20],axis=0),axis=0)-numpy.sum(fnareg[-1,S:E+1,26],axis=0)
  NORTH2=-numpy.sum(fnareg[-1,S:E+1,24],axis=0)-numpy.sum(fnareg[-1,S:E+1,25],axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST+EAST1+EAST2+EAST3+CORE+PFLXL+PFLXR1+PFLXR2+NORTH1+NORTH2+EXT

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))
  print('Sep(%s--%s) = %s' % (species[S],species[E],SEP))
  print('North1(%s--%s) = %s' % (species[S],species[E],NORTH1))
  print('East1(%s--%s) = %s' % (species[S],species[E],EAST1))
  print('east1(%s--%s) = %s' % (species[S],species[E],east1))
  print('west1(%s--%s) = %s' % (species[S],species[E],west1))
  print('West1(%s--%s) = %s' % (species[S],species[E],WEST1))
  print('North2(%s--%s) = %s' % (species[S],species[E],NORTH2))
  print('East2(%s--%s) = %s' % (species[S],species[E],EAST2))
  print('east3(%s--%s) = %s' % (species[S],species[E],east3))
  print('East3(%s--%s) = %s' % (species[S],species[E],EAST3))
  print('Pflxl(%s--%s) = %s' % (species[S],species[E],PFLXL))
  print('Pflxr1(%s--%s) = %s' % (species[S],species[E],PFLXR1))
  print('Pflxr2(%s--%s) = %s' % (species[S],species[E],PFLXR2))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))
  print('ExtCore(%s--%s) = %s' % (species[S],species[E],EXTCORE))

elif freg == 27:

  WEST1=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  west1=numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  east1=-numpy.sum(fnareg[-1,S:E+1,3],axis=0)
  EAST1=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  WEST2=numpy.sum(fnareg[-1,S:E+1,5],axis=0)
  west2=numpy.sum(fnareg[-1,S:E+1,6],axis=0)
  east2=-numpy.sum(fnareg[-1,S:E+1,7],axis=0)
  EAST2=-numpy.sum(fnareg[-1,S:E+1,8],axis=0)
  CORE1=numpy.sum(fnareg[-1,S:E+1,14],axis=0)
  SEP1=numpy.sum(fnareg[-1,S:E+1,16],axis=0)
  PFLXL1=numpy.sum(fnareg[-1,S:E+1,13],axis=0)
  PFLXR1=numpy.sum(fnareg[-1,S:E+1,15],axis=0)
  NORTH1=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,17:19],axis=0),axis=0)
  CORE2=numpy.sum(fnareg[-1,S:E+1,21],axis=0)
  SEP2=numpy.sum(fnareg[-1,S:E+1,23],axis=0)
  PFLXL2=numpy.sum(fnareg[-1,S:E+1,20],axis=0)
  PFLXR2=numpy.sum(fnareg[-1,S:E+1,22],axis=0)
  NORTH2=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,24:26],axis=0),axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST1+EAST1+CORE1+PFLXL1+PFLXR1+NORTH1+WEST2+EAST2+CORE2+PFLXL2+PFLXR2+NORTH2+EXT

  print('Core1(%s--%s) = %s' % (species[S],species[E],CORE1))
  print('Sep1(%s--%s) = %s' % (species[S],species[E],SEP1))
  print('North1(%s--%s) = %s' % (species[S],species[E],NORTH1))
  print('East1(%s--%s) = %s' % (species[S],species[E],EAST1))
  print('east1(%s--%s) = %s' % (species[S],species[E],east1))
  print('west1(%s--%s) = %s' % (species[S],species[E],west1))
  print('West1(%s--%s) = %s' % (species[S],species[E],WEST1))
  print('Core2(%s--%s) = %s' % (species[S],species[E],CORE2))
  print('Sep2(%s--%s) = %s' % (species[S],species[E],SEP2))
  print('North2(%s--%s) = %s' % (species[S],species[E],NORTH2))
  print('East2(%s--%s) = %s' % (species[S],species[E],EAST2))
  print('east2(%s--%s) = %s' % (species[S],species[E],east2))
  print('west2(%s--%s) = %s' % (species[S],species[E],west2))
  print('West2(%s--%s) = %s' % (species[S],species[E],WEST2))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))
  print('ExtCore(%s--%s) = %s' % (species[S],species[E],EXTCORE))
  print('SumCore(%s--%s) = %s' % (species[S],species[E],CORE1+CORE2-SEP1-SEP2+EXTCORE))

elif freg == 28:

  WEST1=numpy.sum(fnareg[-1,S:E+1,1],axis=0)
  west1=numpy.sum(fnareg[-1,S:E+1,2],axis=0)
  east1=-numpy.sum(fnareg[-1,S:E+1,3],axis=0)
  EAST1=-numpy.sum(fnareg[-1,S:E+1,4],axis=0)
  WEST2=numpy.sum(fnareg[-1,S:E+1,5],axis=0)
  west2=numpy.sum(fnareg[-1,S:E+1,6],axis=0)
  east2=-numpy.sum(fnareg[-1,S:E+1,7],axis=0)
  EAST2=-numpy.sum(fnareg[-1,S:E+1,8],axis=0)
  CORE1=numpy.sum(fnareg[-1,S:E+1,15],axis=0)
  SEP1=numpy.sum(fnareg[-1,S:E+1,17],axis=0)
  PFLXL1=numpy.sum(fnareg[-1,S:E+1,14],axis=0)
  PFLXR1=numpy.sum(fnareg[-1,S:E+1,16],axis=0)
  NORTH1=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,18:20],axis=0),axis=0)
  CORE2=numpy.sum(fnareg[-1,S:E+1,22],axis=0)
  SEP2=numpy.sum(fnareg[-1,S:E+1,24],axis=0)
  PFLXL2=numpy.sum(fnareg[-1,S:E+1,21],axis=0)
  PFLXR2=numpy.sum(fnareg[-1,S:E+1,23],axis=0)
  NORTH2=-numpy.sum(numpy.sum(fnareg[-1,S:E+1,25:27],axis=0),axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST1+EAST1+CORE1+PFLXL1+PFLXR1+NORTH1+WEST2+EAST2+CORE2+PFLXL2+PFLXR2+NORTH2+EXT

  print('Core1(%s--%s) = %s' % (species[S],species[E],CORE1))
  print('Sep1(%s--%s) = %s' % (species[S],species[E],SEP1))
  print('North1(%s--%s) = %s' % (species[S],species[E],NORTH1))
  print('East1(%s--%s) = %s' % (species[S],species[E],EAST1))
  print('east1(%s--%s) = %s' % (species[S],species[E],east1))
  print('west1(%s--%s) = %s' % (species[S],species[E],west1))
  print('West1(%s--%s) = %s' % (species[S],species[E],WEST1))
  print('Core2(%s--%s) = %s' % (species[S],species[E],CORE2))
  print('Sep2(%s--%s) = %s' % (species[S],species[E],SEP2))
  print('North2(%s--%s) = %s' % (species[S],species[E],NORTH2))
  print('East2(%s--%s) = %s' % (species[S],species[E],EAST2))
  print('east2(%s--%s) = %s' % (species[S],species[E],east2))
  print('west2(%s--%s) = %s' % (species[S],species[E],west2))
  print('West2(%s--%s) = %s' % (species[S],species[E],WEST2))
  print('Ext(%s--%s) = %s' % (species[S],species[E],EXT))
  print('Sum(%s--%s) = %s' % (species[S],species[E],SUM))
  print('ExtCore(%s--%s) = %s' % (species[S],species[E],EXTCORE))
  print('SumCore(%s--%s) = %s' % (species[S],species[E],CORE1+CORE2-SEP1-SEP2+EXTCORE))

# print('SumSOL(%s--%s) = %s' % (species[S],species[E],SEP-numpy.sum(fnareg[-1,S:E+1,12],axis=0)+west+east))

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
