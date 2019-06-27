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
b2stbr_sna_reg=f.variables['b2stbr_sna_reg']
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

for i in range(len(bounds)):
  plt.plot(times[:],numpy.sum(b2stbr_sna_reg[:,bounds[i][0]:bounds[i][1],R],axis=1), label=elements[bounds[i][0]])
  print('B2STBR_SNA_REG(%s) = %s' % (elements[bounds[i][0]],numpy.sum(b2stbr_sna_reg[-1,bounds[i][0]:bounds[i][1],R],axis=0)))
plt.plot(times[:],numpy.sum(b2stbr_sna_reg[:,:,R],axis=1), label='Sum')
print('B2STBR_SNA_REG(SUM) = %s' % (numpy.sum(b2stbr_sna_reg[-1,:,R],axis=0)))

if  matplotlib.__version__ <=  '0.98.1':
  plt.legend(loc=0)
else:
  plt.legend(loc=0, frameon=False)
plt.xlabel('time')
plt.ylabel('b2stbr_sna_reg for region = '+str(R))

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
  
plt.show()
