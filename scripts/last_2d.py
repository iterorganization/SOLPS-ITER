#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on 26/06/2023
@author: pshenoa

DESCRIPTION
This script averages the data contained in wrk.tmp, following the .RES file prescriptions
.RES file contains a number IRES interpreted as follows:
IRES - positive   :   data will be averaged over the last "int(IRES) timesteps"
IRES - negative   :   data will be averaged over the last "float(IRES) ms"
DEFAULT           :   data will be averaged over the last "1 ms"

TRC_FLE   - tracing files to be averaged
            (at the moment residuals.trc, blnn.trc, blnm.trc and sources.trc are excluded)
            all of of them are treated in the similar manner, i.e. all the quantities are averaged
            and put into the resulting file under the original names
b2time    - handled with the separate routine
            for time-dependent quantities treatment is straightforward and similar to the .trc ones
            for quantities depending on "nc" first two are labeled _l and _u the rest if present - _uX (_u2,_u3 etc)
            the remaining quantities (not "nc" vectors and 2D) are handled separately by last_3d.py (in development)
b2tallies - handled with separate routine
            by convention the naming of the averaged quantities in this routine is as follows:
            XX_reg_ns, where reg is the region number VN for Nth volumetric-region, XN for Nth x-region and
            YN for Nth y-region, and ns is the species index (i.e. Ntot_V04_D1 for example)

The script also reads .VarID file, therefore obtained cut and midplane definitions can in future be used
for more detailed handling of b2time vectors and similar multidimensional infomation.

OUTPUT
last_2d_out   - raw output file containing "file of origin : averaged quantity name : value "
                for all the averaged quantities
last_2d_out_f - formated output file, contains are controlled via last_2d.exe.cmd

USAGE
python plot_trc.py
(intended to be used as a driver for last_2d script)
with tracing and netcdf files present in wrk.tmp directory

IMPORTANT
data should be present in ./wrk.tmp which is
usually handled by the governing script last_2d

WHAT CAN BE CHANGED
Generally speaking only the first block "BASIC SETUP" is expected to be changed
i.e. new tracing files can be added to the list.
"""

import logging
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

import netCDF4 as nc
import numpy as np
import sys
import os
import datetime

"!!! BASIC SETUP: START !!!"

cmd_file = 'last_2d.exe.cmd'
"Name of the command file"
if (np.size(sys.argv) > 1):
    cmd_file = sys.argv[1]
logging.info('COMMAND FILE: %s',cmd_file)

trc_dir = 'wrk.tmp'
"Directory searched for the corresponding *.trc and *.nc files"
if (np.size(sys.argv) > 2):
    trc_dir = sys.argv[2]
logging.info('WORK DIRECTORY: %s',trc_dir)


"Name of the command file"

res_file = '.RES'
"Hidden file containing specific time handling if required"
"if absent RES defaults to 1 ms"

var_file = '.VarID'
"Hidden file containing the key run parameters, used to obtain species names as well as OMP, IMP, SEP locations"

log_file = 'last_2d.exe.log'
"Log file produced by the script"
if (np.size(sys.argv) > 3):
    log_file = sys.argv[3]
logging.info('LOG FILE: %s',log_file)

logging.basicConfig(filename=log_file,format='%(levelname)s:%(filename)s-%(funcName)s: %(message)s',level=logging.INFO,filemode='w')

b2time_FLE = 'b2time'
b2tallies_FLE = 'b2tallies'
TRC_FLE = ['sepdata', 'blne', 'blnn_SPb', 'integral', 'user_SPb', 'user', 'intshrt']
".trc files that will be averaged"

raw_file = 'last_2d_out'
fmt_file = 'last_2d_out_f'
"Output will be written to these files"

"!!! BASIC SETUP: END !!!"

"=========================================================="

"!!! SUBROUTINES: START !!!"

"==== READ_VarID ==="
"""
Reads supplied .VarID file
sequential read filling all the quantities up to SUMZ_ALL*

OUTPUT:
    var_read  - logical, TRUE if data could could be read
    NSPEC     - number of atomic species
    NS        - number of ion species
    SPEC[i]   - species names
    SUMZ_1[i] - the first fluid of a species
    SUMZ_N[i] - the last fluid of a species
    NX        - the last column of the grid (the outer target)
    NY        - the last row of the grid (the outer edge)
    NSEP      - the separatrix row of the grid
    NMP_I     - the inner midplane column
    NMP_O     - the outer midplane column
    NTP_I     - the inner top target column
    NTP_O     - the outer top target column
    NXC_I     - the inner x-point column
    NXC_O     - the outer x-point column
    NXT_I     - the inner top x-point column
    NXT_O     - the outer top x-point column
    NNISO     - the number of isolating cuts
"""
def READ_VarID():

    LL     = ''
    L      = 0
    NSPEC  = 0
    NS     = 0
    SPEC   = ['']
    SUMZ_1 = [0]
    SUMZ_N = [0]
    NX     = 0
    NY     = 0
    NSEP   = 0
    NMP_I  = 0
    NMP_O  = 0
    NNISO  = 0
    NXC_I  = 0
    NXC_O  = 0
    NXT_I  = 0
    NXT_O  = 0
    NTP_I  = 0
    NTP_O  = 0

    if ( os.path.isfile(var_file) == False ):
            var_read = False
            return var_read, LL, L, NSPEC, NS, SPEC, SUMZ_1, SUMZ_N, NX, NY, NSEP, NMP_I, NMP_O, NNISO, NXC_I, NXC_O, NXT_I, NXT_O, NTP_I, NTP_O;
    else:
        var_read = True

    "Count number of lines in the file"
    with open(var_file, 'r') as fp:
        for count, line in enumerate(fp):
            pass
    nlines = count + 1
    logging.info('Start reading %s file containing %s lines',var_file, nlines)

    "Open file and process it line by line"
    with open(var_file,"r") as ff:

        line = ff.readline()
        s = line.find('=')
        if ( s == -1):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'LL'
            if ( var == dvar ):
                try:
                    LL=str(val).strip()
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'L'
            if ( var == dvar ):
                try:
                    L=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NSPEC'
            if ( var == dvar ):
                try:
                    NSPEC=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NS'
            if ( var == dvar ):
                try:
                    NS=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        SPEC_tmp = []
        SUMZ_1_tmp = np.zeros(NSPEC, dtype=np.int64)
        SUMZ_N_tmp = np.zeros(NSPEC, dtype=np.int64)
        for i in range(1,NSPEC+1):
            line = ff.readline()
            s = line.find('=')
            if ( s == -1 ):
                logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
            else:
                var = line[0:s]
                val = line[s+1:]
                dvar = 'SPEC[' + str(i) + ']'
                if ( var == dvar ):
                    try:
                        SPEC_wrk=str(val)[0:2]
                        SPEC_wrk=SPEC_wrk.replace('_','')
                        SPEC_tmp=np.append(SPEC_tmp,SPEC_wrk)
                    except:
                        logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
                        SPEC_tmp=np.append(SPEC_tmp,'')
                else:
                    logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                    SPEC_tmp=np.append(SPEC_tmp,'')
                    var_read = False
            line = ff.readline()
            s = line.find('=')
            if ( s == -1 ):
                logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
            else:
                var = line[0:s]
                val = line[s+1:]
                dvar = 'SUMZ_1[' + str(i) + ']'
                if ( var == dvar ):
                    try:
                        SUMZ_1_tmp[i-1]=np.int64(val)
                    except:
                        logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
                        SUMZ_1_tmp[i-1]=0
                else:
                    logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                    SUMZ_1_tmp[i-1]=0
                    var_read = False
            line = ff.readline()
            s = line.find('=')
            if ( s == -1 ):
                logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
            else:
                var = line[0:s]
                val = line[s+1:]
                dvar = 'SUMZ_N[' + str(i) + ']'
                if ( var == dvar ):
                    try:
                        SUMZ_N_tmp[i-1]=np.int64(val)
                    except:
                        logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
                        SUMZ_N_tmp[i-1]=0
                else:
                    logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                    SUMZ_N_tmp[i-1]=0
                    var_read = False
        SPEC = SPEC_tmp
        SUMZ_1 = SUMZ_1_tmp
        SUMZ_N = SUMZ_N_tmp

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NX'
            if ( var == dvar ):
                try:
                    NX=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NY'
            if ( var == dvar ):
                try:
                    NY=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NSEP'
            if ( var == dvar ):
                try:
                    NSEP=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NMP_I'
            if ( var == dvar ):
                try:
                    NMP_I=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NMP_O'
            if ( var == dvar ):
                try:
                    NMP_O=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NNISO'
            if ( var == dvar ):
                try:
                    NY=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NXC_I'
            if ( var == dvar ):
                try:
                    NXC_I=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NXC_O'
            if ( var == dvar ):
                try:
                    NXC_O=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NXT_I'
            if ( var == dvar ):
                try:
                    NXT_I=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NXT_O'
            if ( var == dvar ):
                try:
                    NXT_O=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NTP_I'
            if ( var == dvar ):
                try:
                    NTP_I=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

        line = ff.readline()
        s = line.find('=')
        if ( s == -1 ):
            logging.error('unexpected line: %s in %s file, skipping', line.strip(), var_file)
        else:
            var = line[0:s]
            val = line[s+1:]
            dvar = 'NTP_O'
            if ( var == dvar ):
                try:
                    NTP_O=np.int64(val)
                except:
                    logging.error('value (%s) of variable (%s) is a wrong type and wont be set', val, var)
            else:
                logging.error('variable read (%s) does not match expected format (%s)', val, dvar)
                var_read = False

    logging.info('%s file successfully read',var_file)

    return var_read, LL, L, NSPEC, NS, SPEC, SUMZ_1, SUMZ_N, NX, NY, NSEP, NMP_I, NMP_O, NNISO, NXC_I, NXC_O, NXT_I, NXT_O, NTP_I, NTP_O;

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

    if ( os.path.isfile(input_file) == False ):
        logging.warning("%s is absent... looking for %s instead...",input_file,input_file_trc)
        if ( os.path.isfile(input_file_trc) == False ):
            logging.critical("neither %s nor %s found... skipping...",input_file,input_file_trc)
            return file_read, trc_header, trc_data;
        else:
            input_file = input_file_trc

    logging.info("readig data from %s", input_file)

    "Try reading standard .trc file"
    "assuming: file begins with # marked comment lines and last of them contrains data headers"
    logging.info('tring to read %s assuming text file in .trc standard format',input_file)
    with open(input_file,"r") as ff:
        while True:
            try:
                line = ff.readline()
            except:
                logging.critical("sequential read of file %s have failed...",input_file)
                return file_read, trc_header, trc_data;
            else:
                if ( line == '' ):
                    logging.critical("no data found in %s",input_file)
                    return file_read, trc_header, trc_data;
                elif ( (line[0] != '#') and (trc_header == '') ):
                    logging.critical("no header found in %s",input_file)
                    return file_read, trc_header, trc_data;
                elif ( line[0] == '#' ):
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
    logging.info('data from %s successfully read',input_file)

    "Get rid of potential NaN problems when plotting"
    np.nan_to_num(trc_data)

    "Check if there is more than one point in time and header size is consistent with data size"
    if ( np.ndim(trc_data) == 2 ):
        if ( len(trc_header) != len(trc_data[:,0]) ):
            logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(trc_header),len(trc_data[:,0]))
            file_read = False
    elif ( (np.ndim(trc_data) == 1) and (np.size(trc_data) == len(trc_header)) ):
        logging.warning('Dataset from file %s (dimension == 1), trying to procceed assuming that file contains one data point... ::ndim(data)::%s::',input_file,np.ndim(trc_data))
        dummy_data = np.zeros((len(trc_header),1), dtype=float)
        dummy_data[:,0] = trc_data
        trc_data =dummy_data
    else:
        logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(trc_header),np.size(trc_data))
        file_read = False

    return file_read, trc_header, trc_data;

"==== READ_B2TIME ==="
"""
Reads supplied b2time_FLE file (assuming netCDF format of current b2time.nc)

INPUT:
    trc_file   - name of the b2time file expected in trc_dir

OUTPUT:
    file_read  - BOOLEAN .true. if file was read
    trc_header - list of 'physcal quantities'
    trc_data   - massive of associated data
"""
def READ_B2TIME(trc_file):

    file_read = False
    trc_header = []
    trc_data = []

    input_file = '{0}{1}{2}'.format(trc_dir, '/', trc_file )
    input_file_nc = '{0}{1}{2}{3}'.format(trc_dir, '/', trc_file,'.nc' )

    if ( os.path.isfile(input_file) == False ):
        logging.warning("%s is absent... looking for %s instead...",input_file,input_file_nc)
        if ( os.path.isfile(input_file_nc) == False ):
            logging.critical("neither %s nor %s found... skipping...",input_file,input_file_nc)
            return file_read, trc_header, trc_data;
        else:
            input_file = input_file_nc

    logging.info("readig data from %s", input_file)


    "Try reading netCDF4"
    logging.info('trying to read %s assuming netCDF4 format',input_file)
    try:
        f = nc.Dataset(input_file)
    except:
        logging.critical('file %s could not be handled by netCDF4 reader... skipping...', input_file)
        return file_read, trc_header, trc_data;
    else:
        logging.info('netCDF4 dataset loaded from %s, searching for time variable', input_file)
        ftmp = f.variables
        fdim = f.dimensions

        "Searching for time variable"
        nctimevars = ['timesa','times']
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
            logging.info('%s dimension found: %s',nctime,ncut)

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
                    logging.info("unforeseen dimension 2 (%s) of variable %s, skipping...",np.ndim(dummy),var)
        trc_data = np.zeros((i,np.size(dummy_data[0,:])), dtype=np.float64)
        trc_data = dummy_data[:i,:]
        file_read = True
        logging.info('data from %s successfully read',input_file)

    "Get rid of potential NaN problems when plotting"
    np.nan_to_num(trc_data)

    "Check if there is more than one point in time and header size is consistent with data size"
    if ( np.ndim(trc_data) == 2 ):
        if ( len(trc_header) != len(trc_data[:,0]) ):
            logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(trc_header),len(trc_data[:,0]))
            file_read = False
    else:
        logging.critical('Dataset dimension != 2 (probably no output has been written or file only contains one time-point only) Check file %s for consistency... ::ndim(data)::s::',input_file,np.ndim(trc_data))
        file_read = False

    return file_read, trc_header, trc_data;

"==== READ_B2TALLIES ==="
"""
Reads supplied b2tallies_FLE file (assuming netCDF format of current b2time.nc)

INPUT:
    trc_file   - name of the b2tallies file expected in trc_dir

OUTPUT:
    file_read  - BOOLEAN .true. if file was read
    trc_header - list of 'physcal quantities'
    trc_data   - massive of associated data
"""
def READ_B2TALLIES(trc_file):

    file_read = False
    trc_header = []
    trc_data = []

    input_file = '{0}{1}{2}'.format(trc_dir, '/', trc_file )
    input_file_nc = '{0}{1}{2}{3}'.format(trc_dir, '/', trc_file,'.nc' )

    if ( os.path.isfile(input_file) == False ):
        logging.warning("%s is absent... looking for %s instead...",input_file,input_file_nc)
        if ( os.path.isfile(input_file_nc) == False ):
            logging.critical("neither %s nor %s found... skipping...",input_file,input_file_nc)
            return file_read, trc_header, trc_data;
        else:
            input_file = input_file_nc

    logging.info("readig data from %s", input_file)


    "Try reading netCDF4"
    logging.info('trying to read %s assuming netCDF4 format',input_file)
    try:
        f = nc.Dataset(input_file)
    except:
        logging.critical('file %s could not be handled by netCDF4 reader... skipping...', input_file)
        return file_read, trc_header, trc_data;
    else:
        logging.info('netCDF4 dataset loaded from %s, searching for time variable', input_file)
        ftmp = f.variables
        fdim = f.dimensions

        "Searching for time variable"
        nctimevars = ['timesa','times']
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

        "Searching for vreg dimension"
        vrdim = 'vreg'
        try:
            vreg = fdim[vrdim].size
            vrlbl = []
            for j in range(0,vreg):
                if ( j < 10 ):
                    dumlbl = '_V0' + str(j)
                    vrlbl.append(dumlbl)
                else:
                    dumlbl = '_V' + str(j)
                    vrlbl.append(dumlbl)
        except:
            logging.critical('no %s dimension found in %s, data wont be read...',vrdim,input_file)
            return file_read, trc_header, trc_data;
        else:
            logging.info('%s dimension found: %s',vrdim,vreg)

        "Searching for xreg dimension"
        xrdim = 'xreg'
        try:
            xreg = fdim[xrdim].size
            xrlbl = []
            for j in range(0,xreg):
                if ( j < 10 ):
                    dumlbl = '_X0' + str(j)
                    xrlbl.append(dumlbl)
                else:
                    dumlbl = '_X' + str(j)
                    xrlbl.append(dumlbl)
        except:
            logging.critical('no %s dimension found in %s, data wont be read...',xrdim,input_file)
            return file_read, trc_header, trc_data;
        else:
            logging.info('%s dimension found: %s',xrdim,xreg)

        "Searching for yreg dimension"
        yrdim = 'yreg'
        try:
            yreg = fdim[yrdim].size
            yrlbl = []
            for j in range(0,yreg):
                if ( j < 10 ):
                    dumlbl = '_Y0' + str(j)
                    yrlbl.append(dumlbl)
                else:
                    dumlbl = '_Y' + str(j)
                    yrlbl.append(dumlbl)
        except:
            logging.critical('no %s dimension found in %s, data wont be read...',yrdim,input_file)
            return file_read, trc_header, trc_data;
        else:
            logging.info('%s dimension found: %s',yrdim,yreg)

        "Searching for ns dimension"
        nsdim = 'ns'
        specvar = 'species'
        try:
            ns = fdim[nsdim].size
            nslbl = []
            dumchar = ftmp[specvar][:]
            for j in range(0,ns):
                dumlbl = '_' + str(dumchar[j]).translate({ord(i): None for i in "b[]' "})
                nslbl.append(dumlbl)
        except:
            logging.critical('no %s dimension found in %s, data wont be read...',nsdim,input_file)
            return file_read, trc_header, trc_data;
        else:
            logging.info('%s dimension found: %s',nsdim,ns)

        mreg = np.max([vreg,xreg,yreg])
        dummy_data = np.zeros((mreg*ns*len(ftmp.keys()),np.size(dummy)), dtype=np.float64)
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
                    if ( dumdim[1] == vrdim ):
                        for j in range(0,vreg):
                            var1 = str(var) + vrlbl[j]
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,j]
                            i = i + 1
                    elif ( dumdim[1] == xrdim ):
                        for j in range(0,xreg):
                            var1 = str(var) + xrlbl[j]
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,j]
                            i = i + 1
                    elif ( dumdim[1] == yrdim ):
                        for j in range(0,yreg):
                            var1 = str(var) + yrlbl[j]
                            trc_header = np.append(trc_header,var1)
                            dummy_data[i,:] = dummy[:,j]
                            i = i + 1
                    else:
                        logging.info("unforeseen dimension 2 (%s) of variable %s, skipping...",dumdim[1],var)
                elif ( np.ndim(dummy) == 3 ):
                    dumdim = ftmp[var].dimensions
                    if ( dumdim[1] == nsdim ):
                        for k in range(0,ns):
                            if ( dumdim[2] == vrdim ):
                                for j in range(0,vreg):
                                    var1 = str(var) + vrlbl[j] + nslbl[k]
                                    trc_header = np.append(trc_header,var1)
                                    dummy_data[i,:] = dummy[:,k,j]
                                    i = i + 1
                            elif ( dumdim[2] == xrdim ):
                                for j in range(0,xreg):
                                    var1 = str(var) + xrlbl[j] + nslbl[k]
                                    trc_header = np.append(trc_header,var1)
                                    dummy_data[i,:] = dummy[:,k,j]
                                    i = i + 1
                            elif ( dumdim[2] == yrdim ):
                                for j in range(0,yreg):
                                    var1 = str(var) + yrlbl[j] + nslbl[k]
                                    trc_header = np.append(trc_header,var1)
                                    dummy_data[i,:] = dummy[:,k,j]
                                    i = i + 1
                            else:
                                logging.info("unforeseen dimension 3 (%s) of variable %s, skipping...",dumdim[2],var)
                    else:
                        logging.info("unforeseen dimension 2 (%s) of variable %s, skipping...",dumdim[1],var)
                else:
                    logging.info('variable %s is a vector of dim %s, no rule to handle this data',var,dumdim)
        trc_data = np.zeros((i,np.size(dummy_data[0,:])), dtype=np.float64)
        trc_data = dummy_data[:i,:]
        file_read = True
        logging.info('data from %s successfully read',input_file)

    "Get rid of potential NaN problems when plotting"
    np.nan_to_num(trc_data)

    "Check if there is more than one point in time and header size is consistent with data size"
    if ( np.ndim(trc_data) == 2 ):
        if ( len(trc_header) != len(trc_data[:,0]) ):
            logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(trc_header),len(trc_data[:,0]))
            file_read = False
    else:
        logging.critical('Dataset dimension != 2 (probably no output has been written or file only contains one time-point only) Check file %s for consistency... ::ndim(data)::s::',input_file,np.ndim(trc_data))
        file_read = False

    return file_read, trc_header, trc_data;

"==== SET_IRES ==="
"""
Reads res_file if suppled otherwise sets IRES to defult

INPUT:
    res_file  - name of the file defining period of the data averageing

OUTPUT:
    IRES  - positive integer (data will be averaged over the last IRES timeteps)
            or negative real (data will be averaged over the last IRES ms)
"""
def SET_IRES(res_file):

    "Set defualt IRES"
    IRES = -1.00E-03

    if ( os.path.isfile(res_file) == True ):
        with open(res_file) as ff:
            try:
                IRES_tmp = np.loadtxt(ff, comments='#', dtype='float', unpack=True)
                if ( IRES_tmp > 0. ):
                    IRES = int(IRES_tmp)
                    logging.info("IRES set by %s. Averaging performed over the last %s iterations",res_file,IRES)
                elif ( IRES_tmp < 0. ):
                    IRES = IRES_tmp*1.e-3
                    logging.info("IRES set by %s. Averaging performed over the last %s sec",res_file,IRES)
                else:
                    logging.info("IRES set by %s is ZERO... default IRES = %s sec applied",res_file, IRES)
            except:
                logging.error('data from %s could not be loaded... default IRES = %s sec applied', res_file,IRES)
    else:
        logging.info("%s file absent... default IRES = %s sec applied",res_file, IRES)

    return IRES;

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
        if ( keyword == data_list[i] ):
            ind = i
            found = True

    if ( ind == -1 ):
        logging.error("Data for: %s was not found in the processed file",keyword)

    return found, ind;

"==== match_raw ==="
"""
Fetches requested combination of keywords in 2 list of data labels

INPUT:
    data_list_up  - list of upper labels
    data_list_dw  - list of lower labels
    keyword_up    - label of upper level
    keyword_dw    - label of lower level

OUTPUT:
    ind        - index of the keyword in both list if found
    found      - BOOLEAN .TRUE. if data has been found
"""
def match_raw(datalist_up, keyword_up, datalist_dw, keyword_dw):

    found = False
    ind = -1

    if ( np.size(datalist_up) != np.size(datalist_dw) ):
        logging.error('sizes of the data lists do not match (%s:%s)',np.size(datalist_up),np.size(datalist_dw))
        return found, ind;

    for i in range(0,np.size(datalist_up)):
        if ( (keyword_up == datalist_up[i]) and (keyword_dw == datalist_dw[i]) ):
            ind = i
            found = True

    if ( ind == -1 ):
        logging.error("Data for: (%s + %s) was not found in the data list",keyword_up,keyword_dw)

    return found, ind;

"==== TRC_AVG ==="
"""
Averages provided data

INPUT:
    trc_header  -  list of headers for the associated data
    trc_data    -  data to be averaged
    ires        -  the averaging parameter:
                    positive ineger  - number of iterations to average
                    or negative real - time in sec to average

OUTPUT:
    averaged    -  Logical .TRUE. if routine succeded, .FALSE. otherwise
    avg_header  -  list of headers for the averaged data
    avg_data    -  averaged data
"""
def TRC_AVG(trc_header, trc_data, ires):

    logging.info('Data averaging started')
    averaged   = False
    avg_header = []
    avg_data   = []

    "Grab the time data"
    found, ind = choose_raw(trc_header,'time')
    if ( found == False ):
        logging.critical('time data not found averaging cannot be performed')
        return averaged, avg_header, avg_data
    time = trc_data[ind,:]
    dimdat = np.size(time)
    if ( dimdat != 1):
        if ( ires < 0. ):
            nres = np.size(time) - 1
            while ((time[nres] - time[np.size(time)-1]) > ires):
                    nres = nres - 1
                    if ( nres == 0 ):
                        break;
        elif (ires > 0.):
            if ( np.size(time) > ires ):
                nres = np.size(time) - ires
            else:
                nres = 0
        else:
            logging.critical('unforeseen value of ires (%s)... averaging cannot be performed',ires)
            return averaged, avg_header, avg_data
        time = time[nres:]
        dtime = time[1:] - time[0:np.size(time)-1]
        ttime = time[np.size(time)-1] - time[0]

    "Cycle over the data"
    for k in range(0,np.size(trc_header)):
        quan = trc_header[k]
        if ( quan != 'time' ):
            found, ind = choose_raw(trc_header,quan)
            if ( dimdat != 1):
                val = trc_data[ind,:]
                val = val[nres:]
                dval = 0.5 * (val[1:] + val[0:np.size(val)-1])
                aval = np.sum(dval*dtime)/ttime
            else:
                aval = trc_data[ind,0]
            "append averaged data"
            if ( (np.isnan(aval) == False) and (np.isinf(aval) == False) ):
                avg_header = np.append(avg_header,quan)
                avg_data = np.append(avg_data,aval)

    averaged = True
    logging.info('Data successfully averaged')

    return averaged, avg_header, avg_data;

"==== WRITE_RAW ==="
"""
Writes the raw output (without filtering, scaling and formating) to the raw_file

INPUT:
    out_file    -  file to write data to
    l2d_files   -  list of files with the original the data
    l2d_header  -  list of headers for the original data
    l2d_data    -  averaged data
    ires        -  the averaging parameter to be used in header

OUTPUT:
    raw_file    -  file containing unformated averaged data in form
                    "original file name : quantity name like read : averaged value "
"""
def WRITE_RAW(out_file, l2d_files, l2d_header, l2d_data, ires):

    logging.info('Writing raw output to %s',out_file)
    if ( (np.size(l2d_files) != np.size(l2d_header)) or (np.size(l2d_files) != np.size(l2d_data)) ):
        logging.critical('dimensions of file, header and data list do not match (%s:%s:%s)... raw data wont be written',np.size(l2d_files),np.size(l2d_header),np.size(l2d_data))
        return;

    flen = 0
    hlen = 0
    for i in range(0,np.size(l2d_files)):
        flen_tmp = len(l2d_files[i])
        if ( flen_tmp > flen):
            flen = flen_tmp
        hlen_tmp = len(l2d_header[i])
        if ( hlen_tmp > hlen):
            hlen = hlen_tmp

    with open(out_file,'w') as ff:
        "Write header"
        line = '#' + 2*' ' + 'last_2d raw output' +'\n'
        ff.write(line)
        now = str(datetime.datetime.now())
        pos = now.find('.')
        if ( pos > 0 ):
            now = now[:pos]
        line ='#' + 2*' ' + 'produced:  ' + str(now) + '\n'
        ff.write(line)
        if ( ires < 0. ):
            resstr = '{0}{1}'.format(str(-ires*1.e+3),' milliseconds')
        elif (ires > 0.):
            resstr = '{0}{1}'.format(str(ires),' iterations')
        else:
            logging.error('inconsistent IRES (%s) provided for the header',ires)
            resstr = ' '
        line = '#' + 2*' ' + 'data averaged over ' + resstr + '\n'
        ff.write(line)
        line = '#' + 2*' ' + 69*'#' + '\n'
        ff.write(line)
        "Write data"
        for i in range(0,np.size(l2d_files)):
            flen_tmp = len(l2d_files[i])
            hlen_tmp = len(l2d_header[i])
            line = l2d_files[i] + (flen - flen_tmp)*' ' + '  :  ' + l2d_header[i] + (hlen - hlen_tmp)*' ' + '  :  ' + str(l2d_data[i]).strip() + '\n'
            ff.write(line)

    logging.info('Raw output written')

    return;

"==== WRITE_FMT ==="
"""
Writes the formated output (governed by the cmd_file)

INPUT:
    out_file    -  file to write data to
    cmd_file    -  command file govering the filtration, scaling, naming and formating
    l2d_files   -  list of files with the original the data
    l2d_header  -  list of headers for the original data
    l2d_data    -  averaged data
    ires        -  the averaging parameter to be used in header

OUTPUT:
    fmt_file    -  file containing unformated averaged data in form
                    "original file name : quantity name like read : averaged value "
"""
def WRITE_FMT(out_file, cmd_file, l2d_files, l2d_header, l2d_data, ires):

    logging.info('Writing formatted output to %s using command file %s',out_file,cmd_file)
    if ( (np.size(l2d_files) != np.size(l2d_header)) or (np.size(l2d_files) != np.size(l2d_data)) ):
        logging.critical('dimensions of file, header and data list do not match (%s:%s:%s)... raw data wont be written',np.size(l2d_files),np.size(l2d_header),np.size(l2d_data))
        return;

    if ( os.path.isfile(cmd_file) == False ):
        logging.critical("%s file absent... no %s will be written",cmd_file,out_file)
        return;

    "Count number of lines in the file"
    with open(cmd_file, 'r') as fp:
        for count, line in enumerate(fp):
            pass
    nlines = count + 1
    logging.info('command file %s containing %s lines to be executed',cmd_file, nlines)

    cmd_fle = []
    cmd_quan = []
    cmd_scl = []
    cmd_txt = []
    cmd_uni = []

    "Open file and process it line by line"
    with open(cmd_file,"r") as cmf:
        for k in range(1,nlines+1):
            line = cmf.readline()
            "Check if line is empty, if so delimiter will be produced in the output file"
            if ( line.strip() == '' ):
                cmd_fle = np.append(cmd_fle,'')
                cmd_quan = np.append(cmd_quan,'')
                cmd_scl = np.append(cmd_scl,1.0)
                cmd_txt = np.append(cmd_txt,'')
                cmd_uni = np.append(cmd_uni,'')
                continue;
            "Check if line is a comment"
            if ( (line[0] == '#') or (line[0] == '!')):
                continue;
            "Otherwise read arguments devided by :"
            "Argument A (see description in cmd_file)"
            tmp = line
            s = tmp.find(':')
            if ( s == -1):
                logging.error('unfinished command (%s) encounter while reading argument A, line %s of the command file %s, skipping...', line.strip(), k, cmd_file)
                continue;
            tmp_fle = tmp[:s].strip()
            "Argument B (see description in cmd_file)"
            tmp = tmp[s+1:]
            s = tmp.find(':')
            if ( s == -1):
                logging.error('unfinished command (%s) encounter while reading argument B, line %s of the command file %s, skipping...', line.strip(), k, cmd_file)
                continue;
            tmp_quan = tmp[:s].strip()
            "Argument C (see description in cmd_file)"
            tmp = tmp[s+1:]
            s = tmp.find(':')
            if ( s == -1):
                logging.error('unfinished command (%s) encounter while reading argument C, line %s of the command file %s, skipping...', line.strip(), k, cmd_file)
                continue;
            tmp_scl = tmp[:s].strip()
            try:
                tmp_scl = np.float64(tmp_scl)
            except:
                logging.error('error number expected (%s read) for argument C, line %s of the command file %s... will be replaced by 1.0', line.strip(), k, cmd_file)
                tmp_scl = 1.0
            "Argument D (see description in cmd_file)"
            tmp = tmp[s+1:]
            s = tmp.find(':')
            if ( s == -1):
                logging.error('unfinished command (%s) encounter while reading argument D, line %s of the command file %s, skipping...', line.strip(), k, cmd_file)
                continue;
            tmp_txt = tmp[:s].strip()
            if ( tmp_txt == '' ):
                tmp_txt = tmp_quan
            "Argument E (see description in cmd_file)"
            tmp = tmp[s+1:]
            tmp_uni = tmp.strip()
            if ( tmp_uni == '' ):
                tmp_uni = 'N/A'
            "Append obtained data to command arrays"
            cmd_fle = np.append(cmd_fle,tmp_fle)
            cmd_quan = np.append(cmd_quan,tmp_quan)
            cmd_scl = np.append(cmd_scl,tmp_scl)
            cmd_txt = np.append(cmd_txt,tmp_txt)
            cmd_uni = np.append(cmd_uni,tmp_uni)

    cmd_size = np.size(cmd_fle)
    hlen = 0
    ulen = 0
    for i in range(0,cmd_size):
        hlen_tmp = len(cmd_txt[i])
        if ( hlen_tmp > hlen):
            hlen = hlen_tmp
        ulen_tmp = len(cmd_uni[i])
        if ( ulen_tmp > ulen):
            ulen = ulen_tmp

    with open(out_file,'w') as ff:
        "Write header"
        line = '#' + 2*' ' + 'last_2d formatted output' +'\n'
        ff.write(line)
        now = str(datetime.datetime.now())
        pos = now.find('.')
        if ( pos > 0 ):
            now = now[:pos]
        line ='#' + 2*' ' + 'produced:  ' + str(now) + '\n'
        ff.write(line)
        if ( ires < 0. ):
            resstr = '{0}{1}'.format(str(-ires*1.e+3),' milliseconds')
        elif (ires > 0.):
            resstr = '{0}{1}'.format(str(ires),' iterations')
        else:
            logging.error('inconsistent IRES (%s) provided for the header',ires)
            resstr = ' '
        line = '#' + 2*' ' + 'data averaged over ' + resstr + '\n'
        ff.write(line)
        line = '#' + 2*' ' + 69*'#' + '\n'
        ff.write(line)
        "Write data"
        for i in range(0,cmd_size):
            if ( cmd_fle[i] == '' ):
                line = 24*' ' + (10 + 4 + hlen + ulen + 4)*'-' + ' \n'
                ff.write(line)
            else:
                found, ind = match_raw(l2d_files, cmd_fle[i], l2d_header, cmd_quan[i])
                if ( found == True ):
                    logging.info('writing formatted output for A:B:C:D:E => %s:%s:%s:%s:%s',cmd_fle[i],cmd_quan[i],cmd_scl[i],cmd_txt[i],cmd_uni[i])
                    val = np.float64(l2d_data[ind])
                    if ( cmd_scl[i] != 0.):
                        val = val * cmd_scl[i]
                    hlp = '{0}'.format('% 4.3E' % val)
                    tlen = len(cmd_txt[i])
                    line = 24*' ' + hlp + ' :: ' + cmd_txt[i] + (hlen - tlen)*' ' + '  [' + cmd_uni[i] + '] \n'
                    ff.write(line)
                else:
                    logging.warning('quantity %s of origin %s was not found and wont be written to the %s',cmd_quan[i],cmd_fle[i],out_file)

    logging.info('Formatted output written')

    return;

"!!! SUBROUTINES: END !!!"

"================================================================="

"!!! DRIVER: START !!!"

def main():

    var_read, LL, L, NSPEC, NS, SPEC, SUMZ_1, SUMZ_N, NX, NY, NSEP, NMP_I, NMP_O, NNISO, NXC_I, NXC_O, NXT_I, NXT_O, NTP_I, NTP_O = READ_VarID()

    logging.info('LL     : %s',LL)
    logging.info('L      : %s',L)
    logging.info('NSPEC  : %s',NSPEC)
    logging.info('NS     : %s',NS)
    logging.info('SPEC   : %s',SPEC)
    logging.info('SUMZ_1 : %s',SUMZ_1)
    logging.info('SUMZ_N : %s',SUMZ_N)
    logging.info('NX     : %s',NX)
    logging.info('NY     : %s',NY)
    logging.info('NSEP   : %s',NSEP)
    logging.info('NMP_I  : %s',NMP_I)
    logging.info('NMP_O  : %s',NMP_O)
    logging.info('NNISO  : %s',NNISO)
    logging.info('NXC_I  : %s',NXC_I)
    logging.info('NXC_O  : %s',NXC_O)
    logging.info('NXT_I  : %s',NXT_I)
    logging.info('NXT_O  : %s',NXT_O)
    logging.info('NTP_I  : %s',NTP_I)
    logging.info('NTP_O  : %s',NTP_O)

    "Get IRES value governing averaging"
    IRES = SET_IRES(res_file)

    "Dummy massives for the averaged data"
    l2d_files = []
    l2d_head  = []
    l2d_data  = []

    "Deal with .trc files"
    for i in range(0,np.size(TRC_FLE)):
        read, trc_header, trc_data = READ_TRC(TRC_FLE[i])
        if ( read == True ):
            averaged, avg_header, avg_data = TRC_AVG(trc_header, trc_data, IRES)
            if ( averaged == True):
                for k in range(0,np.size(avg_header)):
                    l2d_files = np.append(l2d_files,TRC_FLE[i])
                    l2d_head = np.append(l2d_head,avg_header[k])
                    l2d_data = np.append(l2d_data,avg_data[k])

    "Deal with b2time file"
    read, trc_header, trc_data = READ_B2TIME(b2time_FLE)
    if ( read == True ):
        averaged, avg_header, avg_data = TRC_AVG(trc_header, trc_data, IRES)
        if ( averaged == True):
            for k in range(0,np.size(avg_header)):
                l2d_files = np.append(l2d_files,b2time_FLE)
                l2d_head = np.append(l2d_head,avg_header[k])
                l2d_data = np.append(l2d_data,avg_data[k])

    "Deal with b2tallies file"
    read, trc_header, trc_data = READ_B2TALLIES(b2tallies_FLE)
    if ( read == True ):
        averaged, avg_header, avg_data = TRC_AVG(trc_header, trc_data, IRES)
        if ( averaged == True):
            for k in range(0,np.size(avg_header)):
                l2d_files = np.append(l2d_files,b2tallies_FLE)
                l2d_head = np.append(l2d_head,avg_header[k])
                l2d_data = np.append(l2d_data,avg_data[k])

    "Write raw output"
    WRITE_RAW(raw_file, l2d_files, l2d_head, l2d_data, IRES)

    "Write formatted output"
    WRITE_FMT(fmt_file, cmd_file, l2d_files, l2d_head, l2d_data, IRES)


"!!! DRIVER: END !!!"

"================================================================="

"!!! EXECUTION LOOP !!!"

if __name__ == "__main__":
    main()
