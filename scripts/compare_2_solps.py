#! /usr/bin/env python
from __future__ import print_function
import MDSplus
import numpy
import matplotlib.pyplot as plt
import argparse
import patch

def read_solps(shot, conn):
  solps={'shot': shot}
  conn.openTree('solps', solps['shot'])
  solps['te']     = conn.get('\\top.snapshot:te').value
  solps['ti']     = conn.get('\\top.snapshot:ti').value
  solps['ne']     = conn.get('\\top.snapshot:ne').value
  solps['na']     = conn.get('\\top.snapshot:na').value
  solps['r']      = conn.get('\\top.snapshot.grid:r').value
  solps['z']      = conn.get('\\top.snapshot.grid:z').value
  solps['vessel'] = conn.get('\\top.snapshot.grid:vessel').value
  conn.closeTree('solps', solps['shot'])
  return solps

parser=argparse.ArgumentParser(description="compare two SOLPS shots", formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("Shot1", type=int, help="Reference shot number")
parser.add_argument("Shot2", type=int, help="Comparison shot number")
args=parser.parse_args()

conn = MDSplus.Connection('solps-mdsplus.ipp.mpg.de:8001')

ref    = read_solps(args.Shot1, conn)
comp   = read_solps(args.Shot2, conn)

if ref['na'].shape != comp['na'].shape:
  print("Shape mismatch between old and new: ", ref['na'].shape, comp['na'].shape)
  exit()

ns, ny, nx = comp['na'].shape

te_frac_err=2*(comp['te']-ref['te'])/(comp['te']+ref['te'])
ne_frac_err=2*(comp['ne']-ref['ne'])/(comp['ne']+ref['ne'])
ti_frac_err=2*(comp['ti']-ref['ti'])/(comp['ti']+ref['ti'])
na_frac_err=2*(comp['na']-ref['na'])/(comp['na']+ref['na'])
print(na_frac_err.shape)

print("Maximum fractional error Te", numpy.abs(te_frac_err).max() )
print("Maximum fractional error ne", numpy.abs(ne_frac_err).max() )
print("Maximum fractional error Ti", numpy.abs(ti_frac_err).max() )
print("Maximum fractional error na", numpy.abs(na_frac_err).max(axis=1).max(axis=1))

patch.patch(te_frac_err, ref['r'], ref['z'], title='Te frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(te_frac_err).max()), flog=None, file='Te_frac_%s_%s.png' % (args.Shot1, args.Shot2))
patch.patch(ne_frac_err, ref['r'], ref['z'], title='ne frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(ne_frac_err).max()), flog=None, file='ne_frac_%s_%s.png' % (args.Shot1, args.Shot2))
patch.patch(ti_frac_err, ref['r'], ref['z'], title='Ti frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(ti_frac_err).max()), flog=None, file='Ti_frac_%s_%s.png' % (args.Shot1, args.Shot2))
