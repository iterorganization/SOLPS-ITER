#! /usr/bin/env python3
'''
Date : 05/12/2008
Authors : Matthieu Haefele based on IDL scripts provided by David Coster

This script demonstrates the capabilities of Python/NumPy/matplotlib tools to show fusion data.
Basically it reads datasets from solps server through MDS+ and either display or write a resulting 
picture on disk thanks to matplotlib.

It provides the function compare_shots which reads 1D datasets from a list of shots on a server 
through MDS+ and either displays or writes a resulting picture on disk thanks to matplotlib. 
The picture consists in a 9X9 plot on which data from all the specified  shots are displayed. If
filename is omitted, a X window pop up, if filename is specified, no window pop up, but a picture 
is generated on disk with name filename. 
'''

import MDSplus
import numpy

# matplotlib.pyplot is a collection of command style functions that make matplotlib work like matlab
import matplotlib.pyplot as plt

# matplotlib.ticker contains classes to support completely configurable tick locating and formatting.
import matplotlib.ticker as ticker
	
def compare_shots(shot, filename=None, server='solps-mdsplus.ipp.mpg.de:8001'):
	'''
This function reads 1D datasets from shot <shot> on solps server <server> through MDS+ and either
displays or writes a resulting picture on disk thanks to matplotlib. 
* shot : python list of integer which are the shots. Mandatory argument
* filename : python string which contains the name of the genereated file. Optional argument.
* server : MDS+ server to connect. Optional argument, default value=solps-mdsplus.aug.ipp.mpg.de:8001
	'''
	
	params = {'axes.labelsize': 10,
							'axes.titlesize': 10,
							'xtick.labelsize': 4,
							'ytick.labelsize': 4,
							'lines.markersize' : 3,
							'text.usetex': True
							}
		
	
	if filename == None:
		# No filename supplied, displaying on screen
		params['backend'] =  'GTK3Agg'             #'QtAgg', 'ps', 'svg','png'
	else:
		# Filename provided, then it"s a png
		params['backend'] =  'png'             #'QtAgg', 'ps', 'svg','png'
							
	
	plt.rcParams.update(params)
	
	
	# compare_shots is called with an array of shots. Let's get is length
	ncase = len(shot)
	
  # Let's create a few identical arrays whose dimensions and type are in arrayspec
	arrayspec=(ncase,numpy.int32)

	# Creating arrays expanding array specification
	nx  = numpy.zeros(*arrayspec)
	ny  = numpy.zeros(*arrayspec)
	ns  = numpy.zeros(*arrayspec)
	imp = numpy.zeros(*arrayspec)
	omp = numpy.zeros(*arrayspec)
	sep = numpy.zeros(*arrayspec)
	
	
	
	conn = MDSplus.Connection(server)
	for i in range(ncase):
		conn.openTree('solps',shot[i])
		nx[i]=conn.get('\\top.snapshot.dimensions:nx')
		ny[i]=conn.get('\\top.snapshot.dimensions:ny')
		print('opening shot '+ str(shot[i]) + ' => nx, ny='+str(nx[i]) + ' ' + str(ny[i]))
		# Someday maybe, all this will work in Python 3. One shall then write 
		# print(''opening shot '+ str(shot[i]) + ' => nx, ny='+str(nx[i]) + ' ' + str(ny[i]))
		
		ns[i]=conn.get('\\top.snapshot.dimensions:ns')
		imp[i]=conn.get('\\top.snapshot.dimensions:imp')
		omp[i]=conn.get('\\top.snapshot.dimensions:omp')
		sep[i]=conn.get('\\top.snapshot.dimensions:sep')
		conn.closeTree('solps',shot[i])
	
        # Another array specification
	arrayspec=((ncase,ny[0],nx[0]),numpy.float64)

   	# Let's create these float arrays
	dsrad = numpy.zeros( *arrayspec)
	dspol = numpy.zeros( *arrayspec)
	dspar = numpy.zeros (*arrayspec)
	te    = numpy.zeros (*arrayspec)
	ti    = numpy.zeros (*arrayspec)
	nel   = numpy.zeros (*arrayspec)
	
	
	
	for i in range(ncase):
		conn.openTree('solps',shot[i])
		dsrad[i,:,:]=conn.get('\\top.snapshot.grid:dsrad')
		dspol[i,:,:]=conn.get('\\top.snapshot.grid:dspol')
		dspar[i,:,:]=conn.get('\\top.snapshot.grid:dspar')
		te[i,:,:]=conn.get('\\top.snapshot:te')
		ti[i,:,:]=conn.get('\\top.snapshot:ti')
		nel[i,:,:]=conn.get('\\top.snapshot:ne')
		conn.closeTree('solps',shot[i])
	
	conn.disconnect()
	
	
	#build the figure (Let's go Picasso)
        # Layout is a list composed of
        # [number of sub-plot, legend of the left axis, data, location in the tokamak (Inner target, Outer midplane or Outer target), subplot upper title,subplot lower title ] 
	layout=[[1,'Te',te, 0, 'Inner target', ''],
          [2,'',te,omp[0], 'Outer midplane', ''],
          [3,'',te,nx[0]-1, 'Outer target', ''], 
          [4,'Ti',ti, 0, '', ''],
          [5,'',ti,omp[0], '', ''],
          [6,'',ti,nx[0]-1, '', ''],
          [7,'ne',nel, 0, '', 'distance wrt sep'],
          [8,'',nel,omp[0], '', 'distance wrt sep'],
          [9,'',nel,nx[0]-1, '', 'distance wrt sep']
         ]
	
	# Matplotlib plot definitions : point shape, linked or not, color
	line_style = ['o-b', '^-g', 's-r', '+-c', 'x-m', 'D-y', '1-k', 'h-']
	
	# sub-plot number j[0] in a 3x3 subplot. last number ranges from 1 to 3x3, line-major
	print('generating figures')
	for j in layout:
		plotgridshape=(3,3,j[0])
		cur_fig = plt.subplot(*plotgridshape)

		# Finds with the ticker module nice ticks locations, up to 5 locators
		cur_fig.xaxis.set_major_locator(ticker.MaxNLocator(5))
	
		cur_fig.set_xlabel(j[5])
		cur_fig.set_ylabel(j[1])
		cur_fig.set_title(j[4])

		# In each subplot, plot all the cases, each with its line style
		for i in range(ncase):
			cur_fig.plot(dsrad[i,:,j[3]],j[2][i,:,j[3]], line_style[i])
	
	
	# Some more space between sub-plots
	plt.subplots_adjust(wspace=0.15, hspace=0.2)
	
	if filename == None:
		plt.show()
	else:
		plt.savefig(filename)
	
	
compare_shots([11437,11438,11447,11448,11449,11450])
