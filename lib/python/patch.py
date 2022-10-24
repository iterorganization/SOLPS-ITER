import numpy

import matplotlib.pyplot as plt
import matplotlib as mpl

def patch(arr, r, z, title=None, rmin=None, rmax=None, zmin=None, zmax=None, fmin=None, fmax=None, vessel=None, flog=None, file=None):
   """ Plots a 2d data field 'arr' on the unstructured mesh specified by
   'r' and 'z'.
   The title is (optionally) specified by 'title'.
   The bounds are optionally are specified by 'rmin', 'rmax', 'zmin',  'zmax',
   'fmin' and 'fmax'.
   The vessel can be specified as 'vessel'.
   If 'flog' is specified, then a log-scale will be used.
   'file', if specified, specifies the output file.
   SOLPS 5 conventions are used.
   """

   if (vessel is not None):   
      if numpy.bitwise_not((rmin is not None)):   
         rmin = min(r.min(),vessel[:,0].min(),vessel[:,2].min())
      if numpy.bitwise_not((rmax is not None)):   
         rmax = max(r.max(),vessel[:,0].max(),vessel[:,2].max())
      if numpy.bitwise_not((zmin is not None)):   
         zmin = min(r.min(),vessel[:,3].min(),vessel[:,3].min())
      if numpy.bitwise_not((zmax is not None)):   
         zmax = max(r.max(),vessel[:,3].max(),vessel[:,3].max())
   else:   
      if numpy.bitwise_not((rmin is not None)):   
         rmin = r.min()
      if numpy.bitwise_not((rmax is not None)):   
         rmax = r.max()
      if numpy.bitwise_not((zmin is not None)):   
         zmin = z.min()
      if numpy.bitwise_not((zmax is not None)):   
         zmax = z.max()
   
   if numpy.bitwise_not((fmin is not None)):   
      fmin = arr.min()
   if numpy.bitwise_not((fmax is not None)):   
      fmax = arr.max()
   if fmin == fmax:   
      fmin = 0.9 * fmin
      fmax = 1.1 * fmax
   if fmin == fmax:   
      fmin = fmin - 1.0
      fmax = fmax + 1.0
   t_r = r.copy()
   t_r[2:4,:,:] = numpy.roll(t_r[2:4,:,:],1,axis=0)
   t_z = z.copy()
   t_z[2:4,:,:] = numpy.roll(t_z[2:4,:,:],1,axis=0)
   fig = plt.figure(figsize=(6,8))
   ax1 = fig.add_axes([0.05, 0.05, 0.65, 0.90])
   ax2 = fig.add_axes([0.75, 0.05, 0.10, 0.90])
   ax1.set_autoscale_on(False)
   ax1.axis((rmin,rmax,zmin,zmax))
   ax1.set_aspect(aspect=1, adjustable='box')
   ax1.set_title(title)
#   cm = mpl.cm.OrRd
   cm = mpl.cm.Spectral
   if (flog is not None):   
      norm = mpl.colors.LogNorm(vmin=fmin, vmax=fmax)
   else:   
      norm = mpl.colors.Normalize(vmin=fmin,vmax=fmax)
   cb = mpl.colorbar.ColorbarBase(ax2, cmap=cm, norm=norm, orientation='vertical')
   t_arr = cb.cmap(norm(arr))[:,:,0:3]
   if (vessel is not None):   
      for i in numpy.arange(0, vessel.shape[0]):
         junk = ax1.plot([vessel[i,0], vessel[i,2]], [vessel[i,1], vessel[i,3]], 'k-')
   for i in numpy.arange(0, arr.shape[1]):
      for j in numpy.arange(0, arr.shape[0]):
         junk = ax1.fill(t_r[:,j,i], t_z[:,j,i], fc=t_arr[j,i,:].tolist(), lw=0.0)
   if (file is None):
      plt.show()
   else:
      plt.savefig(file,papertype='a4')
      plt.close(fig)
#   plt.clf()
   del t_r, t_z, t_arr, fig, ax1, ax2, cm, cb, norm, junk
   return

