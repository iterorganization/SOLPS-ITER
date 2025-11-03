#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on 22/03/2023
@author: pshenoa

DESCRIPTION
This script produces multipage.pdf file and number of plot files N.ps from the SOLPS
tracing files located in the $trc_dir folder, plots are based on the supplied command
file plot_trc.cmd

OUTPUT
Multipage (multipage.pdf) file and a series of separate XXXX.ps figures placed in $trc_dir

USAGE
python plot_trc.py
(intended to be used as a driver in plot_trc and plot_trg scripts)
with plot_trc.exe.cmd and wrk.tmp present in the exectution directory

IMPORTANT
plot_trc.cmd and $trc_dir should be present in the directory which is
usually handled by the giverning script plot_trc

WHAT CAN BE CHANGED
Generally speaking only the first block "BASIC SETUP" is expected to be changed
if one does not like the fonts, colour scheme etc.
"""

import matplotlib
import matplotlib.pyplot as plt

import netCDF4 as nc
import numpy as np
import sys
import os

import logging
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

"!!! BASIC SETUP: START !!!"

log_file = 'plot_trc.exe.log'
"Log file produced by the script"
if (np.size(sys.argv) > 3):
    log_file = sys.argv[3]
logging.basicConfig(filename=log_file,format='%(levelname)s:%(filename)s-%(funcName)s: %(message)s',level=logging.INFO,filemode='w')

cmd_file = 'plot_trc.exe.cmd'
"Name of the command file"
if (np.size(sys.argv) > 1):
    cmd_file = sys.argv[1]
logging.info('COMMAND FILE: %s',cmd_file)

trc_dir = 'wrk.tmp'
"Directory searched for the corresponding *.trc files"
if (np.size(sys.argv) > 2):
    trc_dir = sys.argv[2]
logging.info('WORK DIRECTORY: %s',trc_dir)

pdf_out = trc_dir + '/multipage.pdf'
"Name of the multipage pdf file produced along with the separate .ps files"

ntime_file = '.ntime'
"Hidden file containing specific time handling if required"

plt_file = '.plt_setup'
"Hidden file overwriting default line, marker and label sizes"

"Default plotting options"
default_fig_size=(3.37,2.5275)
default_line_color = ['tab:red', 'tab:blue', 'tab:green', 'tab:gray', 'tab:purple','tab:orange', 'tab:cyan', 'tab:olive', 'tab:brown',  'tab:pink' ]
default_marker = ['o', 's', '^', 'v', 'p','h', '*', 'D', 'X',  'P' ]

default_line_width = 1.0
default_markersize = 6
default_size_ticks = 10
default_size_xlabel = 10
default_size_title = 10
default_size_legend = 10
"Check if setup file is present and change defaults accordingly"
if ( os.path.isfile(plt_file) == True ):
    logging.info('Plot setup file %s found, reading...',plt_file)
    with open(plt_file) as ff:
        try:
            data = np.loadtxt(ff, comments='#', dtype='float')
            if ( np.size(data) == 6):
                    default_line_width = data[0]
                    logging.info('new linewidth = %s',default_line_width)
                    default_markersize = int(data[1])
                    logging.info('new markersize = %s',default_markersize)
                    default_size_ticks = int(data[2])
                    logging.info('new ticks size = %s',default_size_ticks)
                    default_size_xlabel = int(data[3])
                    logging.info('new x label size = %s',default_size_xlabel)
                    default_size_title = int(data[4])
                    logging.info('new title size = %s',default_size_title)
                    default_size_legend = int(data[5])
                    logging.info('new legend size = %s',default_size_legend)
            else:
                logging.error('inconsistent format of %s, default values will be used',plt_file)
        except:
            logging.error('inconsistent format of %s, default values will be used',plt_file)

output_format = 'ps'

eps = 1.e-30
pl_maxval = 1.10
mi_maxval = 0.90
pl_minval = 0.90
mi_minval = 1.10
pl_maxi = 1.0
mi_maxi = 1.0
pl_mini = 1.0
mi_mini = 1.0
minmarg = 0.1

logging.info('OUTPUT: .ps pictures will be produced')
produce_pdf = False
if (np.size(sys.argv) > 4):
    if (sys.argv[4] == "pdf"):
        logging.info('OUTPUT: multipage .pdf file will be produced')
        produce_pdf = True
        from matplotlib.backends.backend_pdf import PdfPages

"""Governs the axis limits:
    maxval, minval - Y axis limits
    maxi,   mini   - X limits
    minmarg        - minimal margin as fraction of (maxval - minval)
                     used to prevent small values merging with the figure boarders
                     only applied to linear scale figures

Example:

maxval = np.amax(ymass)
if (maxval < 0.):
    maxval = maxval*mi_maxval
else:
    maxval = maxval*pl_maxval
"""

"!!! BASIC SETUP: END !!!"

"=========================================================="

"!!! SUBROUTINES: START !!!"


"==== READ_TRC ==="
"""
Reads supplied *.trc file
assumes # lines in the beginning to be all comments but the last one
the last one is read as line of headers, rest as data

INPUT:
    trc_file   - name of the *.trc file expected in trc_dir

OUTPUT:
    file_read  - BOOLEAN .true. if file was read
    trc_header - list of 'physcal quantities'
    trc_data   - massive of associated data
"""
def READ_TRC(trc_file):

    file_read = False
    trc_header = []
    trc_data = []

    input_file = '{0}{1}{2}'.format(trc_dir, '/', trc_file )
    input_file_trc = '{0}{1}{2}{3}'.format(trc_dir, '/', trc_file,'.trc' )
    input_file_dat = '{0}{1}{2}{3}'.format(trc_dir, '/', trc_file,'.dat' )
    input_file_nc = '{0}{1}{2}{3}'.format(trc_dir, '/', trc_file,'.nc' )

    if ( os.path.isfile(input_file) == False ):
        logging.warning("%s is absent... looking for %s instead...",input_file,input_file_trc)
        if ( os.path.isfile(input_file_trc) == False ):
            logging.warning("%s is absent... looking for %s instead...",input_file_trc,input_file_dat)
            if ( os.path.isfile(input_file_dat) == False ):
                logging.warning("%s is absent... looking for %s instead...",input_file_dat,input_file_nc)
                if ( os.path.isfile(input_file_nc) == False ):
                    logging.critical("no %s, %s, %s or %s found... no data will be read",input_file,input_file_trc,input_file_dat,input_file_nc)
                    return file_read, trc_header, trc_data;
                else:
                    input_file = input_file_nc
            else:
                input_file = input_file_dat
        else:
            input_file = input_file_trc

    logging.info("readig data from %s", input_file)


    "Try reading netCDF4"
    logging.info('trying to read %s assuming netCDF4 format',input_file)
    try:
        f = nc.Dataset(input_file)
    except:
        logging.warning('file %s could not be handled by netCDF4 reader, trying other options...', input_file)
    else:
        logging.info('netCDF4 dataset loaded from %s, searching for time variable', input_file)
        ftmp = f.variables
        fdim = f.dimensions

        "Searching for time variable"
        nctimevars = ['timesa','time']
        for nctime in nctimevars:
            try:
                dummy = ftmp[nctime][:]
            except:
                logging.info('no %s variable found in %s',nctime,input_file)
                dummy = []
            else:
                logging.info('time variable found: %s',nctime)
                dummy = ftmp[nctime][:]
                break;
        if ( np.size(dummy) == 0 ):
            logging.critical('no time data found in %s, data wont be read...',input_file)
            return file_read, trc_header, trc_data;
        trc_header = ["time"]

        "Searching for nc dimension"
        ncdim = 'nc'
        try:
            ncut = fdim[ncdim].size
        except:
            logging.info('no %s dimension found in %s',ncdim,input_file)
            ncut = 0
        else:
            logging.info('%s dimension found: %s',ncdim,ncut)

        dummy_data = np.zeros((ncut*len(ftmp.keys()),np.size(dummy)), dtype=np.float64)
        dummy_data[0,:] = dummy
        i = 1
        for var in ftmp.keys():
            if ( var != nctime ):
                dummy = ftmp[var][:]
                if ( np.ndim(dummy) == 1 ):
                    trc_header = np.append(trc_header,var)
                    dummy_data[i,:] = dummy
                    i = i + 1
                elif ( np.ndim(dummy) == 2 ):
                    dumdim = ftmp[var].dimensions
                    if (dumdim[1] == ncdim ):
                        if ( ncut > 1 ):
                            var1 = str(var) + '_l'
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,0]
                            i = i + 1
                            var1 = str(var) + '_u'
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,1]
                            i = i + 1
                            if ( ncut > 2 ):
                                for j in range(2,ncut+1):
                                    var1 = str(var) + '_u' + str(j)
                                    trc_header = np.append(trc_header,var1)
                                    dummy_data[i,:] = dummy[:,j]
                                    i = i + 1
                        else:
                            var1 = str(var) + '_l'
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,0]
                            i = i + 1
                    else:
                        logging.info('variable %s is a vector of dim %s, no rule to handle this data',var,dumdim)
                else:
                    logging.info("unforeseen dimension %s of variable %s, skipping...",np.ndim(dummy),var)
        trc_data = np.zeros((i,np.size(dummy_data[0,:])), dtype=np.float64)
        trc_data = dummy_data[:i,:]
        file_read = True


    "Try reading standard .trc file"
    "assuming: file begins with # marked comment lines and last of them contrains data headers"
    if ( file_read == False ):
        logging.info('tryng to read %s assuming text file in .trc standard format',input_file)
        with open(input_file,"r") as ff:
            while True:
                try:
                    line = ff.readline()
                except:
                    logging.critical("sequential read of file %s have failed...",input_file)
                    return file_read, trc_header, trc_data;
                else:
                    if (line == ''):
                        logging.critical("no data found in %s",input_file)
                        return file_read, trc_header, trc_data;
                    elif ((line[0] != '#') and (trc_header == '')):
                        logging.critical("no header found in %s",input_file)
                        return file_read, trc_header, trc_data;
                    elif (line[0] == '#'):
                        trc_header = line[1:].strip().split()
                    else:
                        break;

        with open(input_file) as ff:
            try:
                trc_data = np.loadtxt(ff, comments='#', dtype='double', unpack=True)
            except:
                logging.critical('data from %s could not be loaded, check file for consitency', input_file)
                return file_read, trc_header, trc_data;
        file_read = True

    "Get rid of potential NaN problems when plotting"
    testnan = np.isnan(trc_data)
    if ( np.any(testnan) == True ):
        logging.error('NaN values encountered and will be automatically replaced')
        trc_data = np.nan_to_num(trc_data)

    "Check if there is more than one point in time and header size is consistent with data size"
    if ( np.ndim(trc_data) == 2 ):
        if ( len(trc_header) != len(trc_data[:,0]) ):
            logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(trc_header),len(trc_data[:,0]))
            file_read = False
    else:
        logging.critical('Dataset dimension != 2 (probably no output has been written or file only contains one time-point only) Check file %s for consistency... ::ndim(data)::%s::',input_file,np.ndim(trc_data))
        file_read = False

    return file_read, trc_header, trc_data;

"==== choose_raw ==="
"""
Fetches requested keyword in the list of data labels

INPUT:
    data_list  - list of labels
    keyword    - label we are searching for

OUTPUT:
    ind        - index of the keyword in the list if found
    found      - BOOLEAN .TRUE. if data has been found
"""
def choose_raw(data_list, keyword):

    found = False
    ind = -1

    for i in range(0,np.size(data_list)):
        if (keyword == data_list[i]):
            ind = i
            found = True

    if (ind == -1):
        logging.error("Data for: %s was not found in the processed file",keyword)

    return found, ind;

"==== PLT ==="
"""
General plotting engine

INPUT:
    pnum       - number of quantities to be plotted
    sgrid      - boolean defines if grid should be plotted or not
    slog       - logical, True if xsemilog is required
    sline      - logical, True if points are connected by lines
    smark      - logical, True if points are marked
    ymaxx      - Y-axis max limit
    yminn      - Y-amis min limit
    xmaxx      - X-axis max limit
    xminn      - X-amis min limit
    xmass      - X axis array, i.e. time or iteration
    ymass      - Y axis arrya, contains all the plotted quantities
                 stored as [:,i] where is runs over the quantities
    labelmass  - array of quantity labels
    maskmass   - indecies of quantities in .trc file, if <=0 abscent
                 and quantity wont be plotted
    ftitle     - plot title (can use Latex format if preceded with r'')
    xlabel     - x axis label
    file_out   - the output file name
    pdf        - multipage pdf file for plots output

OUTPUT:
    produces the output plot file file_out.$output_format
"""

def PLT(slog,sgrid,sline,smark,ymaxx,yminn,xmaxx,xminn,pnum,xmass,ymass,labelmass,ymaskmass,xlabel,ftitle,file_out,pdf):

    logging.info('plotting %s',file_out)
    if (produce_pdf == True):
        logging.info('adding page to %s',pdf_out)

    line_color = default_line_color
    if (pnum > np.size(default_line_color)):
        for i in range(0,np.int64(np.floor(pnum/np.size(default_line_color)))):
            line_color = np.append(line_color,default_line_color)

    if (sline == True):
        line = 'solid'
    else:
        line = 'None'

    if (smark == True):
        line_marker = default_marker
        if (pnum > np.size(default_marker)):
            for i in range(0,np.int64(np.floor(pnum/np.size(default_marker)))):
                line_marker = np.append(line_marker,default_marker)
    else:
        line_marker = ['None']
        for i in range(1,pnum):
            line_marker = np.append(line_marker,'None')


    ftitle = ftitle.replace(' ','\ ')
    ftitle = '{0}{1}{2}'.format(r'$\mathrm{',ftitle,'}$')

    for i in range(0,pnum):
        labelmass[i] = labelmass[i].replace('_{','@')
        labelmass[i] = labelmass[i].replace('_',' ')
        labelmass[i] = labelmass[i].replace('@','_{')
        labelmass[i] = labelmass[i].replace(' ','\ ')
        labelmass[i] = '{0}{1}{2}'.format(r'$\mathrm{',labelmass[i],'}$')

    mini = np.amin(xmass)
    if (mini < 0.):
        mini = mini*mi_mini
    else:
        mini = mini*pl_mini

    maxi = np.amax(xmass)
    if (maxi > 0.):
        maxi = maxi*pl_maxi
    else:
        maxi = maxi*mi_maxi

    if ( pnum == 1 ):
        vals = ymass
    else:
        vals = []
        for i in range(0,pnum):
            if (ymaskmass[i] >= 0):
                vals = np.append(vals,ymass[:,i])
    maxval = np.amax(vals)
    minval = np.amin(vals)

    if ((slog == True) and (minval <= 0.) ):
        logging.warning('log plot is asked, but some data <= 0... falling back to deault linear plot scale')
        slog = False

    if (maxval < 0.):
        maxval = maxval*mi_maxval
    else:
        maxval = maxval*pl_maxval

    if (minval > 0.):
        minval = minval*pl_minval
    else:
        minval = minval*mi_minval

    if (slog == False):
        totl = maxval - minval
        minfr = (np.amin(vals) - minval)/totl
        maxfr = (maxval - np.amax(vals))/totl
        if ( minfr < minmarg ):
            minval = np.amin(vals) - minmarg*totl
        if ( maxfr < minmarg ):
            maxval = np.amax(vals) + minmarg*totl

    if (ymaxx != ''):
        maxval = ymaxx
    if (yminn != ''):
        minval = yminn
    if (xmaxx != ''):
        maxi = xmaxx
    if (xminn != ''):
        mini = xminn

    if (minval > maxval):
        logging.info('minval > maxval, swapping them around')
        dummy = minval
        minmal = maxval
        maxval = dummy
    if (mini > maxi):
        logging.info('mini > maxi, swapping them around')
        dummy = mini
        mini = maxi
        maxi = dummy

    if ( minval == maxval ):
        minval = minval - 1.
        maxval = maxval + 1.
    if ( mini == maxi ):
        mini = mini - 1.
        maxi = maxi + 1.

    size_legend = default_size_legend
    if (pnum > 36):
        size_legend = size_legend - 5
    elif (pnum > 29):
        size_legend = size_legend - 4
    elif (pnum > 22):
        size_legend = size_legend - 3
    elif (pnum > 15):
        size_legend = size_legend - 2


    plt.locator_params(axis='y', nbins=8)
    plt.locator_params(axis='x', nbins=6)
    fig = plt.figure(num=1, figsize=default_fig_size)
    plt.rc('lines', linewidth=default_line_width, linestyle='-')
    plt.xticks(fontsize=default_size_ticks)
    plt.yticks(fontsize=default_size_ticks)
    plt.xlabel(xlabel,fontsize=default_size_xlabel)
    plt.title(ftitle,fontsize=default_size_title)
    plt.axis([mini,maxi,minval,maxval])
    if (sgrid == True):
        plt.grid(sgrid, color='g', linestyle='-.', linewidth=0.5)
    if (pnum == 1):
        if (slog == False):
            plt.plot(xmass, ymass, color=line_color[0], marker=line_marker[0], linestyle=line, markersize=default_markersize, label=labelmass[0])
        else:
            plt.semilogy(xmass, ymass, color=line_color[0], marker=line_marker[0], linestyle=line, markersize=default_markersize, label=labelmass[0])
    else:
        for i in range(0,pnum):
            if (ymaskmass[i] >= 0):
                if (slog == False):
                    plt.plot(xmass, ymass[:,i], color=line_color[i], marker=line_marker[i], linestyle=line, markersize=default_markersize, label=labelmass[i])
                else:
                    plt.semilogy(xmass, ymass[:,i], color=line_color[i], marker=line_marker[i], linestyle=line, markersize=default_markersize, label=labelmass[i])
    if ((np.sign(minval)*np.sign(maxval)) < 0):
        plt.plot([mini,maxi],[0,0],'k--', linewidth=1.0)
    plt.legend(bbox_to_anchor=(1.01, 1.),loc=2,borderaxespad=0.,fontsize=size_legend,frameon=True)
    plt.tight_layout()
    plt.savefig(file_out, format=output_format, bbox_inches='tight')
    if (produce_pdf == True):
        pdf.savefig()
    plt.cla()
    fig.clear()
    plt.close(1)

    return;

"==== PRODUCE_PAGE ==="
"""
Process the page creation

INPUT:
    page_title  - title associated with the current page
    page_number - sequential number of the page
    trc_header  - list of data in current .trc file
    trc_data    - data from current .trc file
    grid        - grid setting
                  'd' - default, i.e. no grid
                  'g' - green dashes lines (so far the only option)
    ptype       - plot type
                  'd' - default linear
                  'l' - semilog (Y axis log, X still linear)
    ltype       - line type
                  'l' - lines without markers
                  'm' - markers without lines
                  'c' - markers with lines
    xtype       - defines the X axsis data:
                  't' - plot against time
                  'i' - plot against iterations
    quan_names  - list of qantities to be plotted on Y axis arrya
    quan_scales - scaling factors for Y axis data
    xquan       - X-axis quantity to be used instead of default time
    xname       - X-axis name to be used in conjunction with xquan
    xscale      - X-axis scaling value applied in conjunction with xquan
    setprange   - logical vector of dim 4 each defining if strict limits are
                  imposed on the minimal and maximal values of X and Y
    prange      - limit values corresponding to setprange
    ntime       - if positive only data for time > ntime(s) will be plotted
                  if negative only data for last < ntime(s) will be plotted
    ctime       - number of iterations (from the tail) that will be ignored
    gtime       - takes a slice of X and Y data so that only every gtime-th point is plotted
                  if negative every gtime-th point is removed from the plotting data
    pdf         - multipage pdf file for plots output

OUTPUT:
    prepares data for .ps file production with PLT
"""
def PRODUCE_PAGE(page_number,page_title,trc_header,trc_data,grid,ptype,ltype,xtype,xarg,quan_names,quan_labels,quan_scales,xquan,xname,xscale,setprange,prange,ntime,ctime,gtime,pdf):

    logging.info('producing page %s with title: %s',page_number,page_title)

    if (page_number == '' ):
        logging.warning('page number is absent... changing to XX')
        page_number = 'XX'

    if (page_title == ''):
        logging.warning('page title is absent... falling back to deault: Page %s',page_number)
        page_title = '{0}{1}'.format('Page ',page_number)

    if (np.ndim(trc_data) < 2 ):
        logging.critical('current tracing file contains only one time point, nothing will be plotted')
        return;

    "Obtaining X data"
    if (xtype == 't'):
        xlabel = r'$\mathrm{time, \ ms}$'
        found, ind = choose_raw(trc_header,'time')
        if (found == False):
            logging.warning('time data not found in the tracing file will plot against iterations')
            xtype = 'i'
            ind = 0
            xmass = trc_data[ind,:]
            xlabel = ''
        else:
            "Convert time to ms, deal with ntime"
            xmass = trc_data[ind,:]*1.e+3
            ntime = ntime*1.e+3
            if (ntime > 0.):
                k = np.size(xmass) - 1
                while (xmass[k] > ntime):
                    k = k - 1
                    if (k == 0):
                        break;
                xmass = xmass[k:]
            elif (ntime < 0.):
                k = np.size(xmass) - 1
                while ((xmass[k] - xmass[np.size(xmass)-1]) > ntime):
                    k = k - 1
                    if (k == 0):
                        break;
                xmass = xmass[k:]

    elif (xtype == 'u'):
        xlabel = xname.replace('_{','@')
        xlabel = xlabel.replace('_',' ')
        xname = xname.replace('@','_{')
        xname = xname.replace(' ','\ ')
        xlabel = '{0}{1}{2}'.format(r'$\mathrm{',xname,'}$')
        found, ind = choose_raw(trc_header, xquan)
        if (found == False):
            logging.warning('User defined X-axis quantity %s not found in the tracing file will plot against iterations',xquan)
            xtype = 'i'
            ind = 0
            xmass = trc_data[ind,:]
            xlabel = ''
        else:
            "Multiply by scaling factor"
            xmass = trc_data[ind,:]*xscale

    else:
        ind = 0
        xmass = trc_data[ind,:]
        xlabel = ''

    if (xtype == 'i'):
        xmass = np.arange(1,np.size(xmass))
        xlabel = r'$\mathrm{iterations}$'
        if (xarg > 0):
            xmass = xmass[np.size(xmass)-xarg-1:]


    "Obtaining Y data"
    ymaskmass = np.zeros(np.size(quan_names),dtype=np.int64)
    ymass = np.zeros((np.size(xmass),np.size(quan_names)))
    ydata = xmass*0.0
    for i in range(0,np.size(quan_names)):
        found, ind = choose_raw(trc_header,quan_names[i])
        if (found == True):
            ydata = trc_data[ind,:]*quan_scales[i]
            ydata = ydata[np.size(ydata)-np.size(xmass):]
            ymaskmass[i] = ind
        else:
            ymaskmass[i] = -1
        ymass[:,i] = ydata

    "Deal with ctime (cut last ctime iterations if needed)"
    if ((ctime > 0) and (np.size(xmass) > ctime)):
        xmass = xmass[:-ctime]
        ymass = ymass[:-ctime,:]
    elif (np.size(xmass) < ctime):
        logging.error('desired number of iterations to cut off (%s) is greater than data size (%s)',ctime,np.size(xmass))

    "Deal with gtime (pick every gtime point only)"
    if (gtime != 0):
        if (gtime > 0):
            xmass = xmass[::gtime]
            ymass = ymass[::gtime,:]
        elif (gtime < 0):
            dmask = np.arange(-gtime-1,xmass.size,-gtime)
            xmass = np.delete(xmass,dmask)
            if (np.ndim(ymass) == 1):
                ymass = np.delete(ymass,dmask)
            else:
                ymass_tmp = np.zeros((np.size(xmass),np.size(ymass[0,:])), dtype=np.float64)
                for i in range(0,np.size(ymass[0,:])):
                    ymass_tmp[:,i] = np.delete(ymass[:,i],dmask)
                ymass = ymass_tmp

    "Check if limits are set"
    if ((setprange[0] == True) and (ptype != 'l')):
        yminn = prange[0]
    else:
        yminn = ''
    if ((setprange[1] == True) and (ptype != 'l')):
        ymaxx = prange[1]
    else:
        ymaxx = ''
    if ((setprange[2] == True) and (ptype != 'l')):
        xminn = prange[2]
    else:
        xminn = ''
    if ((setprange[3] == True) and (ptype != 'l')):
        xmaxx = prange[3]
    else:
        xmaxx = ''

    "Checking if log plot can be produced"
    if (np.size(ymass) == 0):
        ptype = 'd'
        logging.warning('log plot is asked for Page %s, but there is no data present... falling back to deault linear plot',page_number)

    "Preparing the plot"
    plot = True
    slog = False
    sline = True
    smark = False
    sgrid = False
    pnum = np.size(quan_names)

    if (ptype == 'l'):
        slog = True

    if (grid == 'g'):
        sgrid = True

    if (ltype == 'm'):
        sline = False
        smark = True
    elif (ltype == 'c'):
        sline = True
        smark = True

    if (pnum < 1):
        logging.warning('no quantities assigned to page %s,nothing to plot',page_number)
        plot = False
    else:
        if (np.size(ymaskmass) > 1):
            if (np.amax(ymaskmass) < 0):
                logging.warning('all data for Page %s are 0, nothing to plot',page_number)
                plot = False
        else:
            if (ymaskmass[0] < 0):
                logging.warning('all data for Page %s are 0, nothing to plot',page_number)
                plot = False

    if ( np.abs(np.sum(ymass)) < eps):
        logging.warning('all data for Page %s are 0, nothing to plot',page_number)
        plot = False

    if (plot == True):
        if (page_number < 10):
            internal_page_number = '{0}{1}'.format('000',page_number)
        elif (page_number < 100):
            internal_page_number = '{0}{1}'.format('00',page_number)
        elif (page_number < 1000):
            internal_page_number = '{0}{1}'.format('0',page_number)
        else:
            internal_page_number = page_number
        fout = '{0}{1}{2}{3}{4}'.format(trc_dir,'/',internal_page_number,'.',output_format)
        PLT(slog,sgrid,sline,smark,ymaxx,yminn,xmaxx,xminn,pnum,xmass,ymass,quan_labels,ymaskmass,xlabel,page_title,fout,pdf)

    return;

"==== RESET_PAGE ==="
"""
Set page data to defualt dummy values

INPUT:
    None

OUTPUT:
    page_title   = 'Blank'
    grid         = 'd'
    ptype        = 'd'
    ltype        = 'l'
    xtype        = 't'
    xarg         = -1.0
    quan_names   = []
    quan_labels  = []
    quan_scales  = []
    setprange    = [False, False, False, False]
    prange       = [0., 0., 0., 0.]
    xquan        = ''
    xname        = ''
    xscale       = 1.
"""
def RESET_PAGE():

    logging.info('resetting page data to default dummy values')

    page_title = 'Blank'
    grid = 'd'
    ptype = 'd'
    ltype = 'l'
    xtype ='t'
    xarg = -1.0
    quan_names = []
    quan_labels = []
    quan_scales = []
    setprange = [False, False, False, False]
    prange = [0., 0., 0., 0.]
    xquan = ''
    xname = ''
    xscale = 1.

    return page_title, grid, ptype, ltype, xtype, xarg, quan_names, quan_labels, quan_scales, setprange, prange, xquan, xname, xscale;



"!!! SUBROUTINES: END !!!"

"================================================================="

"!!! DRIVER: START !!!"

def main():

    ntime = 0.
    ctime = 0
    gtime = 0

    "Check if command file is present"
    if ( os.path.isfile(cmd_file) == False ):
        logging.critical("command file %s is absent... cannot procceed",cmd_file)
        sys.exit('script interrupted, check the log file')

    "Check if specific time handling is required"
    if ( os.path.isfile(ntime_file) == True ):
        with open(ntime_file) as ff:
            try:
                data = np.loadtxt(ff, comments='#', dtype='float')
                if ( np.size(data) == 1):
                    ntime = data
                elif ( np.size(data) == 2):
                    ntime = data[0]
                    ctime = int(np.abs(data[1]))
                elif ( np.size(data) == 3):
                    ntime = data[0]
                    ctime = int(np.abs(data[1]))
                    gtime = int(data[2])
                else:
                    logging.error('unexpected format of ntime file %, defualt ntime = %s applied',ntime_file,ntime)
            except:
                logging.error('data from %s could not be loaded... default ntime = %s applied', ntime_file,ntime)
    else:
        logging.info('%s file absent... default ntime = %s sec applied',ntime_file,ntime)
    if ( ntime > 0. ):
        logging.info('NTIME: traces will be plotted from %s and on',ntime)
    elif  (ntime < 0. ):
        logging.info('NTIME: traces for the last %s will be plotted',-ntime)
    if ( ctime != 0 ):
        logging.info('CTIME: last %s iterations will be cut off',ctime)
    if ( gtime != 0 ):
        if (np.abs(gtime) == 1):
            logging.error('GTIME: wrong gtime value ecountered %s, will be reset to 0',gtime)
        else:
            logging.info('GTIME: every %s point will be plotted',gtime)

    "Setting default values for cycling"
    page_title, grid, ptype, ltype, xtype, xarg, quan_names, quan_labels, quan_scales, setprange, prange, xquan, xname, xscale = RESET_PAGE()

    trc_read = False
    page_first = False
    page_number = 0
    trc_header = []
    trc_data = []

    "Count number of lines in the file"
    with open(cmd_file, 'r') as fp:
        for count, line in enumerate(fp):
            pass
    nlines = count + 1
    logging.info('command file %s containing %s lines to be executed',cmd_file, nlines)

    "Open file and process it line by line"
    with open(cmd_file,"r") as cmf:
        k = 1
        while (k <= nlines):

            line = cmf.readline()

            "Check if line is empty before checking first symbol to avoid errors"
            if (line == ''):
                continue;

            "Check if line envokes a command"
            if (line[0] == '@'):

                s = line.find(':')

                if ( s == -1):
                    logging.critical('unfinished command %s encountered at line %s of the command file %s', line[1:].strip(), k, cmd_file)
                else:
                    cmd = line[1:s]
                    cmd_arg = line[s+1:].strip()

                "Cycle over commands"
                if (cmd.lower() == 'file'):

                    "Finish previous @page if it was asked for and there is a data to produce it"
                    if ( (page_first == True) and (trc_read == True)):
                        PRODUCE_PAGE(page_number,page_title,trc_header,trc_data,grid,ptype,ltype,xtype,xarg,quan_names,quan_labels,quan_scales,xquan,xname,xscale,setprange,prange,ntime,ctime,gtime,pdf)
                        page_first = False

                    "read file and reset @page parameters"
                    trc_read, trc_header, trc_data = READ_TRC(cmd_arg)
                    page_title, grid, ptype, ltype, xtype, xarg, quan_names, quan_labels, quan_scales, setprange, prange, xquan, xname, xscale = RESET_PAGE()

                elif (cmd.lower() =='page'):

                    "Check if it is the first page for a given .trc file if not production should start"
                    if ((page_first == False) and (trc_read == True)):
                        page_title = cmd_arg
                        page_number = page_number + 1
                        page_first = True
                        logging.info('starting page %s with title: %s', page_number, page_title)

                    elif ((page_first == True) and (trc_read == True)):
                        PRODUCE_PAGE(page_number,page_title,trc_header,trc_data,grid,ptype,ltype,xtype,xarg,quan_names,quan_labels,quan_scales,xquan,xname,xscale,setprange,prange,ntime,ctime,gtime,pdf)
                        page_title, grid, ptype, ltype, xtype, xarg, quan_names, quan_labels, quan_scales, setprange, prange, xquan, xname, xscale = RESET_PAGE()
                        page_title = cmd_arg
                        page_number = page_number + 1
                        logging.info('starting page %s with title: %s', page_number, page_title)

                    else:
                        logging.error('@page command called before @file, or @file could not be processed. Page wont be produced...')

                elif (cmd.lower() == 'log'):

                    ptype = 'l'
                    logging.info('logarithmic mode for page %s with title: %s', page_number, page_title)

                elif (cmd.lower() == 'points'):

                    ltype = 'm'
                    logging.info('lines replaced by markers for page %s with title: %s', page_number, page_title)

                elif (cmd.lower() == 'linepoints'):

                    ltype = 'c'
                    logging.info('lines supplemented by markers for page %s with title: %s', page_number, page_title)

                elif (cmd.lower() == 'grid'):

                    grid = 'g'
                    logging.info('grid lines added for page %s with title: %s', page_number, page_title)

                elif (cmd.lower() == 'setymin'):

                    try:
                        xarg = np.float64(cmd_arg)
                        setprange[0] = True
                        prange[0] = xarg
                        logging.info('lower Y-axis limit set to %s for page %s with title: %s', xarg, page_number, page_title)
                    except:
                        logging.error('command %s recieved %s argument while real value is expected and wont be applied',cmd,cmd_arg)

                elif (cmd.lower() == 'setymax'):

                    try:
                        xarg = np.float64(cmd_arg)
                        setprange[1] = True
                        prange[1] = xarg
                        logging.info('upper Y-axis limit set to %s for page %s with title: %s', xarg, page_number, page_title)
                    except:
                        logging.error('command %s recieved %s argument while real value is expected and wont be applied',cmd,cmd_arg)

                elif (cmd.lower() == 'setxmin'):

                    try:
                        xarg = np.float64(cmd_arg)
                        setprange[2] = True
                        prange[2] = xarg
                        logging.info('lower X-axis limit set to %s for page %s with title: %s', xarg, page_number, page_title)
                    except:
                        logging.error('command %s recieved %s argument while real value is expected and wont be applied',cmd,cmd_arg)

                elif (cmd.lower() == 'setxmax'):

                    try:
                        xarg = np.float64(cmd_arg)
                        setprange[3] = True
                        prange[3] = xarg
                        logging.info('upper X-axis limit set to %s for page %s with title: %s', xarg, page_number, page_title)
                    except:
                        logging.error('command %s recieved %s argument while real value is expected and wont be applied',cmd,cmd_arg)

                elif (cmd.lower() == 'setx'):

                    s = cmd_arg.find(':')
                    "Should be followed by name"
                    if ( s == -1):
                        logging.critical('unfinished data identifier %s for command %s encountered, command will be skipped', cmd_arg.strip(), cmd)

                    else:
                        xquan = cmd_arg[0:s].strip()
                        xtype = 'u'
                        cmd_arg = cmd_arg[s+1:]
                        s = cmd_arg.find(':')

                        "Can be followed by x axis title or blank"
                        if ( s == -1):
                            logging.warning('unfinished data label %s encountered for command %s default name %s will be used with no rescaling applied',cmd_arg.strip(),cmd,xquan)
                            xname = xquan

                        else:
                            xname = cmd_arg[0:s].strip()
                            cmd_arg = cmd_arg[s+1:]

                            "Can be followed by x axis scaling factor"
                            if (cmd_arg != ''):
                                try:
                                    cmd_arg = np.float64(cmd_arg.strip())
                                    xscale = cmd_arg
                                except:
                                    logging.error('command %s recieved %s scaling argument while real value is expected, no rescaling will be carried out',cmd,cmd_arg)

                        logging.info('data for page %s, named %s will be plotted against quantity %s, named %s scaled with a factor of %s', page_number, page_title, xquan, xname, xscale)

                elif (cmd.lower() =='iter'):

                    xtype = 'i'

                    try:
                        xarg = np.int64(cmd_arg)
                    except:
                        logging.error('command %s recieved %s argument while positive integer is expected',cmd,cmd_arg)
                    logging.info('plotting against last %s iterations for page %s with title: %s', cmd_arg, page_number, page_title)

                else:
                    logging.error('Command %s not implemented yet and will be skipped',cmd)

            "Check if line is data label"
            if (line[0] == ':'):

                s = line[1:].find(':')

                "Data identifier should start and end with :"
                if ( s == -1):
                    logging.critical('unfinished data identifier %s encountered at line %s of the command file %s', line[1:].strip(), k, cmd_file)

                else:
                    cmd = line[1:s+1]
                    quan_name = cmd
                    quan_label = cmd
                    quan_scale = 1.0

                    line = line[s+2:]
                    s = line.find(':')

                    "Arguments have to be separated with :"
                    "if one argument is given it is a label, otherwise label + scaling factor"

                    if ( s == -1):
                        cmd_arg = line.strip()
                        logging.warning('unfinished data label %s encountered, default name%s will be used with no rescaling applied',cmd_arg,quan_label)

                    else:
                        cmd_arg = line[0:s].strip()
                        if (cmd_arg != ''):
                            quan_label = cmd_arg
                        else:
                            logging.warning('empty label for %s default name will be used instead',cmd)

                        line = line[s+1:]
                        cmd_arg = line.strip()
                        if (cmd_arg != ''):
                            try:
                                cmd_arg = np.float64(cmd_arg)
                                quan_scale = cmd_arg
                            except:
                                logging.error('command %s recieved %s argument while real value is expected',cmd,cmd_arg)

                    quan_names = np.append(quan_names,quan_name)
                    quan_labels = np.append(quan_labels,quan_label)
                    quan_scales = np.append(quan_scales,quan_scale)
                    logging.info('adding quantity %s with label %s and scaling factor %s to page %s with title: %s', quan_name, quan_label, quan_scale, page_number, page_title)

            "cycle through command file lines"
            k = k + 1
            "Command file read ends here"

    "produce the final page if needed"
    if ((page_first == True) and (trc_read == True)):
        PRODUCE_PAGE(page_number,page_title,trc_header,trc_data,grid,ptype,ltype,xtype,xarg,quan_names,quan_labels,quan_scales,xquan,xname,xscale,setprange,prange,ntime,ctime,gtime,pdf)

"!!! DRIVER: END !!!"

"================================================================="

"!!! EXECUTION LOOP !!!"

if __name__ == "__main__":
    if ( produce_pdf == True):
        "Open multipage pdf file for writing"
        with PdfPages(pdf_out) as pdf:
            main()
    else:
        pdf='dummy'
        main()
