#! /usr/bin/env python

import numpy as np
import MDSplus
import os
import re

def read_sputter(projectile, target):
    SOLPSTOP = os.getenv("SOLPSTOP")
    try:
        f=open('%s/modules/B2.5/Database/trim.data/sputter.data/%s%s.y' % (SOLPSTOP, projectile.lower(), target.lower()))

        R={}

        line = f.readline()
        sline = line.split(' ')
        R['process'] = sline[1]
        R['quantity'] = sline[2]
        R['projectile'] = sline[4]
        R['target'] = sline[6][0:-1]

        line = f.readline()
        sline = re.split('[ =\n][ =]*', line)
        R['z1'] = float(sline[sline.index("z1")+1])
        R['m1'] = float(sline[sline.index("m1")+1])
        R['z2'] = float(sline[sline.index("z2")+1])
        R['m2'] = float(sline[sline.index("m2")+1])
        R['Es'] = float(sline[sline.index("Es")+1])
        R['rho'] = float(sline[sline.index("rho")+1])

        line = f.readline()
        sline = re.split('[ =,\n][ =,]*', line)
        R['ne'] = int(sline[sline.index("ne")+1])
        R['na'] = int(sline[sline.index("na")+1])

        line = f.readline()
        line = f.readline()
        R['angles'] = np.array(re.split('[ ]+', line)[1:9+1])

        line = f.readline()
        rest = f.readlines()
        values = np.loadtxt(rest)

        R['energies'] = values[:,0]
        R['yields'] = values[:,1:]

    except:
        R = None

    return R

def read_solps(shot):

    conn = MDSplus.Connection('solps-mdsplus.aug.ipp.mpg.de:8001')

    solps = {}
    conn.openTree('solps', shot)
    solps['shot'] = shot
    solps['te'] = conn.get('\\top.snapshot:te').value
    solps['ne'] = conn.get('\\top.snapshot:ne').value
    solps['ti'] = conn.get('\\top.snapshot:ti').value
    solps['na'] = conn.get('\\top.snapshot:na').value
    solps['po'] = conn.get('\\top.snapshot:po').value
    solps['rza'] = conn.get('\\top.snapshot:rza').value
    solps['hx'] = conn.get('\\top.snapshot:hx').value
    solps['fnax'] = conn.get('\\top.snapshot:fnax').value
    solps['species'] = [t.split('\x00')[0][1:] for t in conn.get('\\top:snapshot:textpl')]
    conn.closeTree('solps', shot)
    return solps

def inner_target(S, sputter, column=2):
    R={}
    R['tef'] = (S['te'][:,0]*S['hx'][:,1]+S['te'][:,1]*S['hx'][:,0])/(S['hx'][:,0]+S['hx'][:,1])
    R['tif'] = (S['ti'][:,0]*S['hx'][:,1]+S['ti'][:,1]*S['hx'][:,0])/(S['hx'][:,0]+S['hx'][:,1])
    R['pof'] = S['po'][:,0]
    R['zaf'] = (S['rza'][:,:,0]*S['hx'][:,1]+S['rza'][:,:,1]*S['hx'][:,0])/(S['hx'][:,0]+S['hx'][:,1])
    R['Ei']  = R['tif'] + R['pof']*R['zaf']
    if sputter is None:
        R['sputter_yield'] = 0.0 * R['Ei']
    else:
        R['sputter_yield'] = np.interp(R['Ei'], sputter['energies'], sputter['yields'][:,column], left=0.0)
    R['sputtered'] = R['sputter_yield'] * np.maximum(0.0, -S['fnax'][:,:,0])
    return R

def outer_target(S, sputter, column=2):
    R={}
    R['tef'] = (S['te'][:,-1]*S['hx'][:,-2]+S['te'][:,-2]*S['hx'][:,-1])/(S['hx'][:,-1]+S['hx'][:,-2])
    R['tif'] = (S['ti'][:,-1]*S['hx'][:,-2]+S['ti'][:,-2]*S['hx'][:,-1])/(S['hx'][:,-1]+S['hx'][:,-2])
    R['pof'] = S['po'][:,-1]
    R['zaf'] = (S['rza'][:,:,-1]*S['hx'][:,-2]+S['rza'][:,:,-2]*S['hx'][:,-1])/(S['hx'][:,-1]+S['hx'][:,-2])
    R['Ei']  = R['tif'] + R['pof']*R['zaf']
    if sputter is None:
        R['sputter_yield'] = 0.0 * R['Ei']
    else:
        R['sputter_yield'] = np.interp(R['Ei'], sputter['energies'], sputter['yields'][:,column], left=0.0)
    R['sputtered'] = R['sputter_yield'] * np.maximum(0.0, S['fnax'][:,:,-1])
    return R
