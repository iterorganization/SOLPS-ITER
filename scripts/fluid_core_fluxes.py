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

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,3],axis=1), label='core')

elif vreg == 3:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,4],axis=1), label='core')

elif vreg == 5:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,8],axis=1), label='core')

elif vreg == 6:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,9],axis=1), label='core')

elif vreg == 8:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,15],axis=1), label='core')

elif freg == 27:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,14],axis=1), label='core1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,21],axis=1), label='core2')

elif freg == 28:

  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,15],axis=1), label='core1')
  plt.plot(times[:],numpy.sum(fnareg[:,S:E+1,22],axis=1), label='core2')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel(species[S] + "--" + species[E] + "   ( - losses / + sources )")

if vreg == 2:

  CORE=numpy.sum(fnareg[-1,S:E+1,3],axis=0)

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))

elif vreg == 3:

  CORE=numpy.sum(fnareg[-1,S:E+1,4],axis=0)

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))

elif vreg == 5:

  CORE=numpy.sum(fnareg[-1,S:E+1,8],axis=0)

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))

elif vreg == 6:

  CORE=numpy.sum(fnareg[-1,S:E+1,9],axis=0)

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))

elif vreg == 8:

  CORE=numpy.sum(fnareg[-1,S:E+1,15],axis=0)

  print('Core(%s--%s) = %s' % (species[S],species[E],CORE))

elif freg == 27:

  CORE1=numpy.sum(fnareg[-1,S:E+1,14],axis=0)
  CORE2=numpy.sum(fnareg[-1,S:E+1,21],axis=0)

  print('Core1(%s--%s) = %s' % (species[S],species[E],CORE1))
  print('Core2(%s--%s) = %s' % (species[S],species[E],CORE2))

elif freg == 28:

  CORE1=numpy.sum(fnareg[-1,S:E+1,15],axis=0)
  CORE2=numpy.sum(fnareg[-1,S:E+1,22],axis=0)

  print('Core1(%s--%s) = %s' % (species[S],species[E],CORE1))
  print('Core2(%s--%s) = %s' % (species[S],species[E],CORE2))

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
  plt.savefig('fluid_core_fluxes.' + os.getenv('SOLPS_PYTHON_PLOT'))
