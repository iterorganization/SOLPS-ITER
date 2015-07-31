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
rsanareg=f.variables['rsanareg']
rranareg=f.variables['rranareg']
species_names=f.variables['species']
species=[''.join(species_names[i,:]).strip() for i in range(species_names.shape[0])]

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

for i in range(len(bounds)):
  plt.plot(times[:],numpy.sum(rranareg[:,bounds[i][0]:bounds[i][1],R],axis=1)/numpy.sum(rsanareg[:,bounds[i][0]:bounds[i][1],R],axis=1), label=elements[bounds[i][0]])
plt.plot(times[:],numpy.sum(rranareg[:,:,R],axis=1)/numpy.sum(rsanareg[:,:,R],axis=1), label='Sum')

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('rranareg/rsanareg for region = '+str(R))

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
  plt.savefig('rranareg_per_rsanareg.' + os.getenv('SOLPS_PYTHON_PLOT'))
