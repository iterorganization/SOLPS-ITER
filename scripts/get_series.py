#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on 06/07/2023
@author: pshenoa

DESCRIPTION
This script gets the average data from last_2d raw output files (last_2d_out) for every run in the series
the results are concatenated and written to the output file named after the series

The script work is governed by several command files that should be present in the directory where
the script is executed:

series.exe      :  the file that contains the series name and mapping of the runs composing it.

    Syntax:
        series  : "Series_name" : "key"
                      the output data will be called Series_name.dat
                      keys can add special treatment if needed. Several keys can be added separated by "/"
                      Currently available keys:
                            "add_units" - will add units from get_series.exe.cmd to the legend (if present)
                            "scale"     - will scale the quantities with values given in get_series.exe.cmd
        run     : "run_name" : "run_path"
                      individual runs in the output file will be marked via run_name
                      the run_path is local or absolute path to the associated run data.

get_series.exe.cmd  :  similar to the formatted last_2d output (description can be found in the example
                       file found in the script/commands directory along with the example_of_.series file)

OUTPUT
Series_name.dat - contains a table of data described in get_series.exe.cmd file for every run of the series
                  fetched from the last_2d_out file located in the associated run_path

USAGE
python get_series.py
(intended to be used as a driver for get_series script)
with associated .series and get_series.cmd files present

IMPORTANT
averaged data for every run in the series should be present in run_path
which is usually handled by the governing script get_series (if possible)

WHAT CAN BE CHANGED
New keys can be added, although it requires some understanding of the script
"""

import logging
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

import netCDF4 as nc
import numpy as np
import sys
import os

"!!! BASIC SETUP: START !!!"

log_file = 'get_series.exe.log'
"Log file produced by the script"
logging.basicConfig(filename=log_file,format='%(levelname)s:%(filename)s-%(funcName)s: %(message)s',level=logging.INFO,filemode='w')

cmd_file = 'get_series.exe.cmd'
"Name of the command file"

series_file = 'series.exe'
"Hidden file containing specific information about the series and composing run"

raw_file = 'last_2d_out'
"Name of the files containing raw last_2d output used to get the series data"

out_file_ext ='.dat'
"suffix added after the series label to the name of an outup file"

"!!! BASIC SETUP: END !!!"

"=========================================================="

"!!! SUBROUTINES: START !!!"

"==== READ_Series ==="
"""
Reads the series_file to setup the series data

INPUT:
    series_file - path to the series file

OUTPUT:
    file_read -  logical, if .TRUE. data was read
    slabels   -  series label used to the output file production
    keys      -  special treatment for series, defaults to "none"
    rlabels   -  list of run labels controlling the series
    rpaths    -  paths to the run files
    rtos      -  run to series mapping
"""
def READ_Series(series_file):

    file_read = False
    slabels = []
    keys    = []
    rlabels = []
    rpaths  = []
    rtos    = []
    rcount  = 0

    if ( os.path.isfile(series_file) == False ):
        logging.critical("%s file absent... nothing to be done",series_file)
        return file_read, slabels, keys, rlabels, rpaths, rtos;
    else:
        logging.info('Reading series file %s',series_file)

    "Count number of lines in the file"
    with open(series_file, 'r') as fp:
        for count, line in enumerate(fp):
            pass
    nlines = count + 1
    logging.info('series file %s containing %s lines to be executed',series_file, nlines)

    "Open file and process it line by line"
    with open(series_file,"r") as sf:
        for k in range(1,nlines+1):
            line = sf.readline()
            "Check if line is empty to avoid errors"
            if ( line.strip() == '' ):
                continue;
            "Check if line contains a command"
            tmp = line
            s = tmp.find(':')
            "If not, skip it"
            if ( s == -1):
                continue;
            cmd = tmp[:s].strip()
            if ( cmd == 'series' ):
                logging.info('%s command encountered, reading arguments',cmd)
                tmp = tmp[s+1:]
                s = tmp.find(':')
                if ( s == -1):
                    logging.error('%s command requires 2 arguments, only one is given, skipping', cmd)
                    continue;
                arg1_tmp = tmp[:s].strip()
                arg2_tmp = tmp[s+1:].strip()
                if ( arg2_tmp == ''):
                    arg2_tmp = 'none'
                if ( (arg1_tmp != '') and (arg2_tmp != '')):
                    slabels = np.append(slabels,arg1_tmp)
                    keys = np.append(keys,arg2_tmp)
                    rtos = np.append(rtos,rcount)
                else:
                    logging.error('%s recieved at least one empty argument (%s:%s), skipping',cmd,arg1_tmp,arg2_tmp)
            elif ( cmd == 'run' ):
                if ( np.size(slabels) == 0):
                    logging.error('%s command encountered before a series was assigned, skipping',cmd)
                    continue;
                logging.info('%s command encountered, reading arguments',cmd)
                tmp = tmp[s+1:]
                s = tmp.find(':')
                if ( s == -1):
                    logging.error('%s command requires 2 arguments, only one is given, skipping', cmd)
                    continue;
                arg1_tmp = tmp[:s].strip()
                arg2_tmp = tmp[s+1:].strip()
                if ( (arg1_tmp != '') and (arg2_tmp != '')):
                    rlabels = np.append(rlabels,arg1_tmp)
                    rpaths = np.append(rpaths,arg2_tmp)
                    rcount = rcount + 1
                else:
                    logging.error('%s recieved at least one empty argument (%s:%s), skipping',cmd,arg1_tmp,arg2_tmp)
            else:
                logging.error('unrecognized command "%s", skipping',cmd)
        rtos = np.append(rtos,rcount)

    for i in range(0,np.size(slabels)):
        if ( rtos[i] == rtos[i+1]):
            rtos = np.delete(rtos,i)
            slabels = np.delete(slabels,i)
            keys = np.delete(keys,i)

    if ( (np.size(slabels) > 0) and (np.size(rlabels) > 0) ):
        file_read = True
        logging.info('Series information successfully read')
    else:
        logging.critical('%s lacks properly described series (%s) or runs (%s)',series_file,np.size(slabels),np.size(rlabels))

    return file_read, slabels, keys, rlabels, rpaths, rtos;

"==== READ_CMD ==="
"""
Reads the cmd_file and provides the data necessary to process raw last_2d_out files

INPUT:
    cmd_file    - path to the command file

OUTPUT:
    file_read -  logical, if .TRUE. data was read
    cmd_fle   -  list of the files of origin for the averaged quantities
    cmd_quan  -  list of averaged quantities to be included in the series summary
    cmd_scl   -  scaling factors for the averaged quantities
    cmd_txt   -  labels to overwrite the quantity names
    cmd_uni   -  units of the resulting values
"""
def READ_CMD(cmd_file):

    file_read = False
    cmd_fle   = []
    cmd_quan  = []
    cmd_scl   = []
    cmd_txt   = []
    cmd_uni   = []

    if ( os.path.isfile(cmd_file) == False ):
        logging.critical("%s file absent... nothing to be done",cmd_file)
        return file_read, cmd_fle, cmd_quan, cmd_scl, cmd_txt, cmd_uni;
    else:
        logging.info('Reading command file %s',cmd_file)

    "Count number of lines in the file"
    with open(cmd_file, 'r') as fp:
        for count, line in enumerate(fp):
            pass
    nlines = count + 1
    logging.info('command file %s containing %s lines to be executed',cmd_file, nlines)

    "Open file and process it line by line"
    with open(cmd_file,"r") as cmf:
        for k in range(1,nlines+1):
            line = cmf.readline()
            "Check if line is empty to avoid errors"
            if ( line.strip() == '' ):
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
                tmp_scl = np.float(tmp_scl)
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

    if ( np.size(cmd_fle) > 0 ):
        file_read = True
        logging.info('Series information successfully read')
    else:
        logging.critical('%s contains no properly described commands',cmd_file)

    return file_read, cmd_fle, cmd_quan, cmd_scl, cmd_txt, cmd_uni;

"==== READ_L2D ==="
"""
Reads the raw last_2d_out files

INPUT:
    raw_file  - path raw last_2d file

OUTPUT:
    file_read -  logical, if .TRUE. data was read
    l2d_files   -  list of files with the original the data
    l2d_header  -  list of headers for the original data
    l2d_data    -  averaged data
"""
def READ_L2D(raw_file):

    file_read  = True
    l2d_files  = []
    l2d_header = []
    l2d_data   = []

    if ( os.path.isfile(raw_file) == False ):
        logging.critical("%s file absent... no data will be read",raw_file)
        return file_read, l2d_files, l2d_header, l2d_data;

    with open(raw_file) as ff:
        try:
            l2d_files_tmp = np.loadtxt(ff, comments='#', dtype='str', delimiter=':',usecols=0)
        except:
            logging.critical('A field in %s could not be handled...',raw_file)
            return file_read, l2d_files, l2d_header, l2d_data;

    with open(raw_file) as ff:
        try:
            l2d_header_tmp = np.loadtxt(ff, comments='#', dtype='str', delimiter=':',usecols=1)
        except:
            logging.critical('B field in %s could not be handled... ',cmd_file)
            return file_read, l2d_files, l2d_header, l2d_data;

    with open(raw_file) as ff:
        try:
            l2d_data_tmp = np.loadtxt(ff, comments='#', dtype='float', delimiter=':',usecols=2)
        except:
            logging.critical('C field in %s could not be handled...',raw_file)
            return file_read, l2d_files, l2d_header, l2d_data;

    if ( (np.size(l2d_files_tmp) == np.size(l2d_header_tmp)) and (np.size(l2d_files_tmp) == np.size(l2d_data_tmp)) ):
        l2d_size = np.size(l2d_files_tmp)
    else:
        logging.critical('read data sizes are inconsistent (%s:%s:%s)...',np.size(l2d_files_tmp),np.size(l2d_header_tmp),np.size(l2d_data_tmp))
        return file_read, l2d_files, l2d_header, l2d_data;

    if ( l2d_size == 0 ):
        logging.error('%s seems empty... please check',raw_file)
        return file_read, l2d_files, l2d_header, l2d_data;
    elif ( l2d_size == 1):
        l2d_files = np.append(l2d_files,str(l2d_files_tmp).strip())
        l2d_header = np.append(l2d_header,str(l2d_header_tmp).strip())
        l2d_data = np.append(l2d_data,np.float(l2d_data_tmp))
    else:
        for i in range(0,l2d_size):
            l2d_files = np.append(l2d_files,str(l2d_files_tmp[i]).strip())
            l2d_header = np.append(l2d_header,str(l2d_header_tmp[i]).strip())
            l2d_data = np.append(l2d_data,np.float(l2d_data_tmp[i]))

    logging.info('%s read',raw_file)

    return file_read, l2d_files, l2d_header, l2d_data;

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

"==== GRAB_DATA==="
"""
Fetches the required fields (based on cmd file read) form the last_2d raw output data
the quantities that were not found are replaced with zeros

INPUT:
    cmd_fle     -  list of files containing the original data for desired ouptput quantities
    cmd_quan    -  list of desired quantities
    l2d_files   -  list of files with the original the data
    l2d_header  -  list of headers for the original data
    l2d_data    -  averaged data

OUTPUT:
    grb_done    -  logical, .TRUE. if data was successfully grabbed
    grb_data    -  vector containing the required data
"""
def GRAB_DATA(cmd_fle, cmd_quan, l2d_files, l2d_header, l2d_data):

    grb_done = False
    grb_data = []

    for i in range(0,np.size(cmd_fle)):
        found, ind = match_raw(l2d_files, cmd_fle[i], l2d_header, cmd_quan[i])
        if ( found == True ):
            logging.info('fetching the value for quantity %s of origin %s',cmd_quan[i],cmd_fle[i])
            val = np.float(l2d_data[ind])
        else:
            logging.warning('quantity %s of origin %s was not found',cmd_quan[i],cmd_fle[i])
            val = 0.
        grb_data = np.append(grb_data,val)

    if ( np.size(cmd_fle) == np.size(grb_data) ):
        logging.info('Data grabbed')
        grb_done = True
    else:
        logging.info('Something went wrong data was not grabbed')

    return grb_done, grb_data;

"!!! SUBROUTINES: END !!!"

"================================================================="

"!!! DRIVER: START !!!"

def main():

    series_read, slabels, keys, rlabels, rpaths, rtos = READ_Series(series_file)

    if ( series_read == False ):
        logging.critical('%s not read... aborting',series_file)
        sys.exit()

    cmd_read, cmd_fle, cmd_quan, cmd_scl, cmd_txt, cmd_uni = READ_CMD(cmd_file)

    if ( cmd_read == False ):
        logging.critical('%s not read... aborting',cmd_file)
        sys.exit()

    "Cycle over series"
    for i in range(0,np.size(slabels)):

        series_out = slabels[i] + out_file_ext

        "Handle keys"
        if ( keys[i] != 'none' ):
            keys_local = []
            tmp = str(keys[i])
            s = tmp.find('/')
            while ( s >= 0):
                hlp = tmp[:s].strip()
                tmp = tmp[s+1:]
                keys_local = np.append(keys_local,hlp)
                s = tmp.find('/')
            keys_local = np.append(keys_local,tmp.strip())
        else:
            keys_local = ['none']

        "Write header"
        with open(series_out,'w') as sf:
            if ( 'add_units' in keys_local ):
                logging.info('"add_units" key encountered, units will be added to the header of series %s',slabels[i])
                header_txt = []
                for k in range(0,np.size(cmd_txt)):
                    hlp = cmd_txt[k] + '(' + cmd_uni[k] +')'
                    header_txt = np.append(header_txt,hlp)
            else:
                header_txt = cmd_txt
            line = '#  run'
            for k in range(0,np.size(header_txt)):
                line = line + '    ' + header_txt[k]
            line = line + ' \n'
            sf.write(line)

        "Try to grab the run data"
        for j in range(int(rtos[i]),int(rtos[i+1])):

            if ( rpaths[j][-1] == '/'):
                l2d_path = rpaths[j] + raw_file
            else:
                l2d_path = rpaths[j] + '/' + raw_file
            if ( os.path.isfile(l2d_path) == False ):
                logging.error("%s file is absent at given run path %s",raw_file,rpaths[j])
                continue;

            l2d_read, l2d_files, l2d_header, l2d_data = READ_L2D(l2d_path)
            if ( l2d_read == False ):
                logging.error('%s file at path %s could not be read',raw_file,rpaths[j])
                continue;

            grb_done, grb_data = GRAB_DATA(cmd_fle, cmd_quan, l2d_files, l2d_header, l2d_data)
            if ( grb_done == False ):
                logging.error('data grabbing failed')
                continue;

            with open(series_out,'a') as sf:
                if ( 'scale' in keys_local):
                    logging.info('"scale" key encountered, the run %s data in series %s will be scaled according to the command file',rlabels[j],slabels[i])
                    scaled_data = []
                    for k in range(0,np.size(grb_data)):
                        if ( cmd_scl[k] != 0.):
                            hlp = grb_data[k] * cmd_scl[k]
                        else:
                            hlp = grab_data[k]
                        scaled_data = np.append(scaled_data,hlp)
                    out_data = scaled_data
                else:
                    out_data = grb_data
                line = '  ' + rlabels[j]
                for k in range(0,np.size(out_data)):
                    hlp = '{0}'.format('% 7.6E' % out_data[k])
                    line = line + '  ' + hlp
                line = line + ' \n'
                sf.write(line)

        logging.info('data for series %s of %s was successfully written to %s',i+1,np.size(slabels),series_out)

"!!! DRIVER: END !!!"

"================================================================="

"!!! EXECUTION LOOP !!!"

if __name__ == "__main__":
    main()
