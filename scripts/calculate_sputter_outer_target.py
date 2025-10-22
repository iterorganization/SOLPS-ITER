#! /usr/bin/env python

import numpy as np
#import matplotlib.pyplot as plt
import argparse
import re
import sputter

parser=argparse.ArgumentParser(description="""
Calculate sputtering at the outer target based on the SOLPS data
stored in the MDSplus server solps-mdsplus.ipp.mpg.de
""", formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("--target", "-t", type=str, help="Target material (default W)",default='W')
parser.add_argument("Shot", type=int, help="Shot number")
args=parser.parse_args()

SOLPS   = sputter.read_solps(args.Shot)

ns, ny, nx = SOLPS['na'].shape

i_x = nx-2
projectile_o = ''
for i_s in range(ns):
    projectile = re.split('[+0-9]', SOLPS['species'][i_s])[0]
    if projectile != projectile_o:
        SPUTTER      = sputter.read_sputter(projectile,args.target)
        projectile_o = projectile
        OT           = sputter.outer_target(SOLPS, SPUTTER)
    for i_y in range(ny-2):
        print(' %3i %3i %3i  %- #11.03G %- #11.03G %- #11.03G %- #11.03G %- #11.03G %- #11.03G %- #11.03G' % (i_x, i_y, i_s, OT['tef'][i_y+1], OT['tif'][i_y+1], OT['pof'][i_y+1], OT['zaf'][i_s][i_y+1], OT['Ei'][i_s][i_y+1], OT['sputter_yield'][i_s][i_y+1], OT['sputtered'][i_s][i_y+1]))
