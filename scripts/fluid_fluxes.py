#! /usr/bin/env python
import pupynere
import matplotlib.pyplot as plt
import matplotlib
import sys
import numpy
import os


if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=pupynere.netcdf_file('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=pupynere.netcdf_file('b2tallies.nc','r')
times=f.variables['times']
fnaxreg=f.variables['fnaxreg']
fnayreg=f.variables['fnayreg']
extsnareg=f.variables['b2sext_sna_reg']
species_names=f.variables['species']
species=[''.join(species_names[i,:]).strip() for i in range(species_names.shape[0])]

nargs=len(sys.argv)
S=0
E=len(species)-1
if nargs > 1: S=int(sys.argv[1])
if nargs > 2: E=int(sys.argv[2])

print species[S],species[E]

if vreg == 2:

  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnaxreg[:,S:E+1,2],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,1],axis=1), label='S')
  plt.plot(times[:],-numpy.sum(fnayreg[:,S:E+1,2],axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1)-numpy.sum(fnaxreg[:,S:E+1,2],axis=1)+numpy.sum(fnayreg[:,S:E+1,1],axis=1)-numpy.sum(fnayreg[:,S:E+1,2],axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

elif vreg == 5:

  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1), label='W')
  plt.plot(times[:],-numpy.sum(fnaxreg[:,S:E+1,4],axis=1), label='-E')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,2],axis=1), label='core')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,1],axis=1), label='pflxl')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,3],axis=1), label='pflxr')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnayreg[:,S:E+1,5:8],axis=1),axis=1), label='-N')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1)-numpy.sum(fnaxreg[:,S:E+1,4],axis=1)+numpy.sum(fnayreg[:,S:E+1,2],axis=1)+numpy.sum(fnayreg[:,S:E+1,1],axis=1)+numpy.sum(fnayreg[:,S:E+1,3],axis=1)-numpy.sum(numpy.sum(fnayreg[:,S:E+1,5:8],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')
  
else:

  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1), label='W1')
  plt.plot(times[:],-numpy.sum(fnaxreg[:,S:E+1,4],axis=1), label='-E1')
  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,5],axis=1), label='W2')
  plt.plot(times[:],-numpy.sum(fnaxreg[:,S:E+1,8],axis=1), label='-E2')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,2],axis=1), label='core1')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,1],axis=1), label='pflxl1')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,3],axis=1), label='pflxr1')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnayreg[:,S:E+1,5:8],axis=1),axis=1), label='-N1')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,9],axis=1), label='core2')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,8],axis=1), label='pflxl2')
  plt.plot(times[:],numpy.sum(fnayreg[:,S:E+1,10],axis=1), label='pflxr2')
  plt.plot(times[:],-numpy.sum(numpy.sum(fnayreg[:,S:E+1,12:15],axis=1),axis=1), label='-N2')
  plt.plot(times[:],numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='EXT')
  plt.plot(times[:],numpy.sum(fnaxreg[:,S:E+1,1],axis=1)-numpy.sum(fnaxreg[:,S:E+1,4],axis=1)+numpy.sum(fnayreg[:,S:E+1,2],axis=1)+numpy.sum(fnayreg[:,S:E+1,1],axis=1)+numpy.sum(fnayreg[:,S:E+1,3],axis=1)-numpy.sum(numpy.sum(fnayreg[:,S:E+1,5:8],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1)+numpy.sum(fnaxreg[:,S:E+1,5],axis=1)-numpy.sum(fnaxreg[:,S:E+1,8],axis=1)+numpy.sum(fnayreg[:,S:E+1,9],axis=1)+numpy.sum(fnayreg[:,S:E+1,8],axis=1)+numpy.sum(fnayreg[:,S:E+1,10],axis=1)-numpy.sum(numpy.sum(fnayreg[:,S:E+1,12:15],axis=1),axis=1)+numpy.sum(extsnareg[:,S:E+1,0],axis=1), label='Sum')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel(species[S] + "--" + species[E] + "   ( - losses / + sources )")

if vreg == 2:

  WEST=numpy.sum(fnaxreg[-1,S:E+1,1],axis=0)
  EAST=-numpy.sum(fnaxreg[-1,S:E+1,2],axis=0)
  SOUTH=numpy.sum(fnayreg[-1,S:E+1,1],axis=0)
  NORTH=-numpy.sum(fnayreg[-1,S:E+1,2],axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  SUM=WEST+EAST+SOUTH+NORTH+EXT

  print 'South(%s--%s) = %s' % (species[S],species[E],SOUTH)
  print 'North(%s--%s) = %s' % (species[S],species[E],NORTH)
  print 'East(%s--%s) = %s' % (species[S],species[E],EAST)
  print 'West(%s--%s) = %s' % (species[S],species[E],WEST)
  print 'Ext(%s--%s) = %s' % (species[S],species[E],EXT)
  print 'Sum(%s--%s) = %s' % (species[S],species[E],SUM)

elif vreg == 5:

  WEST=numpy.sum(fnaxreg[-1,S:E+1,1],axis=0)
  west=numpy.sum(fnaxreg[-1,S:E+1,2],axis=0)
  east=-numpy.sum(fnaxreg[-1,S:E+1,3],axis=0)
  EAST=-numpy.sum(fnaxreg[-1,S:E+1,4],axis=0)
  CORE=numpy.sum(fnayreg[-1,S:E+1,2],axis=0)
  SEP=numpy.sum(fnayreg[-1,S:E+1,4],axis=0)
  PFLXL=numpy.sum(fnayreg[-1,S:E+1,1],axis=0)
  PFLXR=numpy.sum(fnayreg[-1,S:E+1,3],axis=0)
  NORTH=-numpy.sum(numpy.sum(fnayreg[-1,S:E+1,5:8],axis=0),axis=0)
  EXT=numpy.sum(extsnareg[-1,S:E+1,0],axis=0)
  EXTCORE=numpy.sum(extsnareg[-1,S:E+1,1],axis=0)
  SUM=WEST+EAST+CORE+PFLXL+PFLXR+NORTH+EXT

print 'SumCore(%s--%s) = %s' % (species[S],species[E],CORE-SEP+EXTCORE)
# print 'SumSOL(%s--%s) = %s' % (species[S],species[E],SEP-numpy.sum(fnayreg[-1,S:E+1,6],axis=0)+west+east)

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
