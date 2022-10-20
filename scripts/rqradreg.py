#! /usr/bin/env python
from __future__ import print_function
import netCDF4
import os
import matplotlib
if not os.getenv("DISPLAY"): matplotlib.use('Agg')
import matplotlib.pylab as plt
import sys
import numpy
import re

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
  f=netCDF4.Dataset('b2mn.exe.dir/b2tallies.nc','r')
else:
  f=netCDF4.Dataset('b2tallies.nc','r')
times=f.variables['times']
rqradreg=f.variables['rqradreg']
species_names=f.variables['species']
species=[b''.join(species_names[i,:]).strip().decode('utf-8') for i in range(species_names.shape[0])]

elements=[re.sub('[-+0-9]','',species[i]) for i in range(len(species))]

mask=[re.match('[a-zA-Z]+0$',species[i])!=None for i in range(len(species))]
s=0
bounds=[]
for i in range(mask.count(True)-1):
 e=mask.index(True,s+1)
 bounds+=[[s,e]]
 s=e

bounds+=[[s,len(mask)]]

nargs=len(sys.argv)
R=0
if nargs > 1: R=int(sys.argv[1])

rqradreg_species=numpy.zeros((rqradreg.shape[0],len(bounds)+1,rqradreg.shape[2]))
for i in range(len(bounds)):
  rqradreg_species[:,i,:] = numpy.sum(rqradreg[:,bounds[i][0]:bounds[i][1],:],axis=1)
rqradreg_species[:,len(bounds),:] = numpy.sum(rqradreg[:,:,:],axis=1)

if os.getenv('SOLPS_PYTHON_SAVE'):
  numpy.savetxt('rqradreg.' + os.getenv('SOLPS_PYTHON_SAVE'), numpy.concatenate((numpy.reshape(times[:],(times[:].shape[0],1)),rqradreg_species[:,:,R]),axis=1), header='Time ' + ' '.join(v for v in numpy.array(elements)[numpy.array(bounds)[:,0]]) + ' Sum')

for i in range(len(bounds)):
  plt.plot(times[:],rqradreg_species[:,i,R], label=elements[bounds[i][0]])
  print('RQRADREG(%s) = %s' % (elements[bounds[i][0]],rqradreg_species[-1,i,R]))
plt.plot(times[:],rqradreg_species[:,len(bounds),R], label='Sum')
print('RQRADREG(SUM) = %s' % (rqradreg_species[-1,len(bounds),R]))

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('rqradreg for region = '+str(R))

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
  plt.savefig('rqradreg.' + os.getenv('SOLPS_PYTHON_PLOT'))
