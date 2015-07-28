#! /usr/bin/env python
import MDSplus
import numpy
import matplotlib.pyplot as plt
import argparse
import patch

parser=argparse.ArgumentParser(description="compare two SOLPS shots", formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument("Shot1", type=int, help="Reference shot number")
parser.add_argument("Shot2", type=int, help="Comparison shot number")
args=parser.parse_args()

conn = MDSplus.Connection('solps-mdsplus.aug.ipp.mpg.de:8001')

conn.openTree('solps', args.Shot1)
te_new=conn.get('\\top.snapshot:te').value
ne_new=conn.get('\\top.snapshot:ne').value
ti_new=conn.get('\\top.snapshot:ti').value
na_new=conn.get('\\top.snapshot:na').value
r_old=conn.get('\\top.snapshot.grid:r').value
z_old=conn.get('\\top.snapshot.grid:z').value
vessel_old=conn.get('\\top.snapshot.grid:vessel').value
conn.closeTree('solps', args.Shot1)

conn.openTree('solps', args.Shot2)
te_old=conn.get('\\top.snapshot:te').value
ne_old=conn.get('\\top.snapshot:ne').value
ti_old=conn.get('\\top.snapshot:ti').value
na_old=conn.get('\\top.snapshot:na').value
r_new=conn.get('\\top.snapshot.grid:r').value
z_new=conn.get('\\top.snapshot.grid:z').value
vessel_new=conn.get('\\top.snapshot.grid:vessel').value
conn.closeTree('solps', args.Shot2)

if na_old.shape != na_new.shape:
  print "Shape mismatch between old and new: ", na_old.shape, na_new.shape
  exit()

ns, ny, nx = na_new.shape

te_frac_err=2*(te_new-te_old)/(te_new+te_old)
ne_frac_err=2*(ne_new-ne_old)/(ne_new+ne_old)
ti_frac_err=2*(ti_new-ti_old)/(ti_new+ti_old)
na_frac_err=2*(na_new-na_old)/(na_new+na_old)
print na_frac_err.shape

print "Maximum fractional error Te", numpy.abs(te_frac_err).max() 
print "Maximum fractional error ne", numpy.abs(ne_frac_err).max() 
print "Maximum fractional error Ti", numpy.abs(ti_frac_err).max() 
print "Maximum fractional error na", numpy.abs(na_frac_err).max(axis=1).max(axis=1)

patch.patch(te_frac_err, r_old, z_old, title='Te frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(te_frac_err).max()), flog=None, file='Te_frac_%s_%s.png' % (args.Shot1, args.Shot2))
patch.patch(ne_frac_err, r_old, z_old, title='ne frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(ne_frac_err).max()), flog=None, file='ne_frac_%s_%s.png' % (args.Shot1, args.Shot2))
patch.patch(ti_frac_err, r_old, z_old, title='Ti frac error %s/%s (Max %8.2e)' % (args.Shot1, args.Shot2, numpy.abs(ti_frac_err).max()), flog=None, file='Ti_frac_%s_%s.png' % (args.Shot1, args.Shot2))
