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
import re

if os.access('b2mn.exe.dir/b2tallies.nc', os.R_OK):
    f = netCDF4.Dataset('b2mn.exe.dir/b2tallies.nc','r')
else:
    f = netCDF4.Dataset('b2tallies.nc','r')
vreg = f.dimensions['vreg'].size
xreg = f.dimensions['xreg'].size
yreg = f.dimensions['yreg'].size
ns = f.dimensions['ns'].size
time = f.dimensions['time'].size
times = f.variables['times']
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

fnaxreg = f.variables['fnaxreg']
fnayreg = f.variables['fnayreg']
b2stbr_sna_reg = f.variables['b2stbr_sna_reg']
b2sext_sna_reg = f.variables['b2sext_sna_reg']

if vreg == 5:
    FULL_X = numpy.array([0,1,0,0,-1,0,0])
    FULL_Y = numpy.array([0,1,1,1,0,-1,-1,-1])
elif vreg ==2:
    FULL_X = numpy.array([0,1,-1])
    FULL_Y = numpy.array([0,1,-1])
else:
    raise ValueError('Value of vreg=%s not currently coded' % vreg)

for i in range(len(bounds)):
    fnax = (fnaxreg[:,bounds[i][0]:bounds[i][1],:].sum(axis=1)*FULL_X).sum(axis=1)
    fnay = (fnayreg[:,bounds[i][0]:bounds[i][1],:].sum(axis=1)*FULL_Y).sum(axis=1)
    b2stbr = b2stbr_sna_reg[:,bounds[i][0]:bounds[i][1],0].copy()
    b2stbr[:,0] = 0 # remove the neutral
    if b2stbr.shape[1] > 2: b2stbr[:,-1] = 0 # remove the fully stripped species for He and up
    b2stbr = b2stbr.sum(axis=1)

    b2sext = b2sext_sna_reg[:,bounds[i][0]:bounds[i][1],0].copy()
    b2sext = b2sext.sum(axis=1)

    fna_norm = numpy.max([numpy.max(numpy.abs(fnaxreg[:,bounds[i][0]:bounds[i][1],:])),numpy.max(numpy.abs(fnayreg[:,bounds[i][0]:bounds[i][1],:]))])
    print(elements[bounds[i][0]], fna_norm, (fnax+fnay+b2stbr+b2sext).mean(), ((fnax+fnay+b2stbr+b2sext)/fna_norm).mean())
    plt.plot(times[:],((fnax+fnay+b2stbr+b2sext)/fna_norm), label=elements[bounds[i][0]])
plt.xlabel('time [s]')
plt.ylabel('normalised particle error')
plt.title('Normalised particle error')
plt.legend(loc=0)
plt.show()
