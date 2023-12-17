#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Created on 15/05/2023
@author: pshenoa

The script provides summary of target heat and particle load routines produced via
echo "0100 wlld" | b2plot

The script searches for the relevant associated files and if found produces:
    
    trg_sum.dat - containing integral, average and peak values of heat and particle fluxes
"""

import logging
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

import numpy as np
import sys
import os

"!!! BASIC SETUP: START !!!"

"Files containing the data to work on"
div_names  = ['LOWER INNER DIVERTOR', 'LOWER OUTER DIVERTOR', 'UPPER INNER DIVERTOR', 'UPPER OUTER DIVERTOR']
wlld_names = [    'ld_tg_i.dat',           'ld_tg_o.dat',         'ld_tg_ui.dat',         'ld_tg_uo.dat']
fptg_names   = [    'fp_tg_i.dat',           'fp_tg_o.dat',         'fp_tg_ui.dat',         'fp_tg_uo.dat']

"Directory searched for the corresponding *.dat files"
wlld_dir = 'wrk.tmp'
if (np.size(sys.argv) > 1):
    wlld_dir = sys.argv[1]
logging.info('WORK DIRECTORY: %s',wlld_dir)

"Output file name"
out_file = 'trg_sum.dat'
"Log file"
log_file = 'trg_sum.exe.log'
"Log file produced by the script"
if (np.size(sys.argv) > 2):
    log_file = sys.argv[2]
logging.info('LOG FILE: %s',log_file)

logging.basicConfig(filename=log_file,format='%(levelname)s:%(filename)s-%(funcName)s: %(message)s',level=logging.INFO,filemode='w')

"Length of string in 10 symlobs per unit cannot be lower then 4"
str_len = 7

"Variable list, names legend and actions"
wlld_quan_int  = ['Wtot',         'Wpls',          'Wneut',          'Wrad']
wlld_name_int  = ['Q total [MW]', 'Q plasma [MW]', 'Q neutral [MW]', 'Q radiation [MW]']
wlld_quan_avg  = ['Wtot',             'ne',        'Te',      'Ti']
wlld_name_avg  = ['q total [MW/m^2]', 'ne [m^-3]', 'Te [eV]', 'Ti [eV]']
wlld_quan_pkv  = ['Wtot',             'Wpls',              'Wneut',              'Wrad',                 'ne',        'Te',      'Ti',]
wlld_name_pkv  = ['q total [MW/m^2]', 'q plasma [MW/m^2]', 'q neutral [MW/m^2]', 'q radiation [MW/m^2]', 'ne [m^-3]', 'Te [eV]', 'Ti [eV]']

fptg_quan_int  = ['H_flux_ion',       'H_flux_atm',        'H2_flux_mol',       'D_flux_ion',       'D_flux_atm',        'D2_flux_mol',       'T_flux_ion',       'T_flux_atm',        'T2_flux_mol',       'He_ion_flux',       'Be_ion_flux',       'Li_ion_flux',       'C_ion_flux',       'N_ion_flux',       'Ne_ion_flux',       'Ar_ion_flux',       'W_ion_flux' ]
fptg_name_int  = ['H ion flux [1/s]', 'H atom flux [1/s]', 'H2 mol flux [1/s]', 'D ion flux [1/s]', 'D atom flux [1/s]', 'D2 mol flux [1/s]', 'T ion flux [1/s]', 'T atom flux [1/s]', 'T2 mol flux [1/s]', 'He ion flux [1/s]', 'Be ion flux [1/s]', 'Li ion flux [1/s]', 'C ion flux [1/s]', 'N ion flux [1/s]', 'Ne ion flux [1/s]', 'Ar ion flux [1/s]', 'W ion flux [1/s]' ]
fptg_quan_avg  = ['H_pres_atm',           'H2_pres_mol',               'D_pres_atm',           'D2_pres_mol',               'T_pres_atm',           'T2_pres_mol' ]
fptg_name_avg  = ['H atom pressure [Pa]', 'H2 molecule pressure [Pa]', 'D atom pressure [Pa]', 'D2 molecule pressure [Pa]', 'T atom pressure [Pa]', 'T2 molecule pressure [Pa]' ]
fptg_quan_pkv  = ['H_pres_atm',           'H2_pres_mol',               'D_pres_atm',           'D2_pres_mol',               'T_pres_atm',           'T2_pres_mol' ]
fptg_name_pkv  = ['H atom pressure [Pa]', 'H2 molecule pressure [Pa]', 'D atom pressure [Pa]', 'D2 molecule pressure [Pa]', 'T atom pressure [Pa]', 'T2 molecule pressure [Pa]' ]



"!!! BASIC SETUP: END !!!"

"=========================================================="

"!!! SUBROUTINES: START !!!"

"==== READ_FLE ==="
""" 
Reads supplied *.dat file (called trc in what follows because the subroutine
is coppied from plot_trc and I was lazy to change name convention)

assumes # lines in the beginning to be all comments but the last one
the last one is read as line of headers, rest as data

INPUT: 
    in_file   - name of the *.dat file expected in trc_dir

OUTPUT:
    file_read  - BOOLEAN .true. if file was read
    header - list of 'physcal quantities'
    data   - massive of associated data
"""
def READ_FLE(in_file):
    
    file_read = False
    header = []
    data = []
        
    input_file = '{0}{1}{2}'.format(wlld_dir, '/', in_file )

    if ( os.path.isfile(input_file) == False ):
        logging.critical("no %s, found... no data will be read",input_file)
        return file_read, header, data;
    
    logging.info('readig data from %s assuming text file of standard format (# before header)', input_file)

    "Try reading standard input file"
    "assuming: file begins with # marked comment lines and last of them contrains data headers"
    with open(input_file,"r") as ff:
        while True:
            try:
                line = ff.readline()
            except:
                logging.critical("sequential read of file %s have failed...",input_file)
                return file_read, header, data;                
            else:
                if (line == ''):
                    logging.critical("no data found in %s",input_file) 
                    return file_read, header, data;                
                elif ((line[0] != '#') and (header == '')):
                       logging.caritical("no header found in %s",input_file) 
                       return file_read, header, data;
                elif (line[0] == '#'):
                      header = line[1:].strip().split()
                else:
                    break;

    with open(input_file) as ff:
        try:
            data = np.loadtxt(ff, comments='#', dtype='double', unpack=True)
        except:
            logging.critical('data from %s could not be loaded, check file for consitency', input_file)
            return file_read, header, data;
        file_read = True
    
    "Get rid of potential Nan problems when plotting"
    np.nan_to_num(data)

    "Check if header size is consistent with data size"
    if ( len(header) != len(data[:,0]) ):
        logging.critical('Length of header and dataset do not match! Check file %s for consistency... ::len(header):len(data):%s:%s::',input_file,len(header),len(data[:,0]))
        file_read = False
    
    return file_read, header, data;
                
"==== choose_raw ==="
""" 
Fetches requested keyword in the list of data labels

INPUT: 
    data_list  - list of labels
    keywork    - label we are searching for

OUTPUT:
    ind        - index of the keyword in the list if found
    found      - BOOLEAN True if data has been found
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
 
"==== SET_GEOM ==="
""" 
Defines geometrical values required for further work on the data set

INPUT: 
    data_header  - list of data headers
    data         - actual data

OUTPUT:
    stp_ind      - index of strike point (in this convention the first cell of SOL)
    dlen         - length of the target elements starting from PFR-edge and 
                    moving to SOL-edge
    dsurf        - surface area of the target elements starting from PFR-edge and 
                    moving to SOL-edge
"""
def SET_GEOM(data_head,data):
    
    stp_ind = 0
    dlen = 0.
    dsurf = 0.
    
    found, x_ind = choose_raw(data_head,'x')
    if (found == False):
        logging.critical('data for coordinate along the target (x) not found, cannot setup geometry')
        return found, stp_ind, dlen, dsurf;
    x_coord = data[x_ind,:]
    ncell = np.size(x_coord)
    
    found, R_ind = choose_raw(data_head,'Rclfc')
    if (found == False):
        logging.critical('data for R coordinate (Rclfc) not found, cannot setup geometry')
        return found, stp_ind, dlen, dsurf;
    R_val = data[R_ind,:]
   
    "Find strike point position"
    stp_ind = -1
    if (x_coord[0] > 0.):
        stp_ind = 0
    else:
        for i in range(0,ncell):
            if (x_coord[ncell - 1 - i] > 0.):
                stp_ind = ncell - 1 - i
    
    if (stp_ind == -1):
        logging.info('no strike point found, index defined as: %s',stp_ind)
    else:
        logging.info('strike point found, index defined as: %s',stp_ind)
    
    "Find length and surface area of cells"
    dlen = np.zeros(ncell,dtype=np.float64)
#    dsurf = np.zeros(ncell,dtype=np.float64)
    
    "Standard case is stp_ind >=0"
    if (stp_ind >= 0):
        "Deal with SOL first"
        xlen = 2.*x_coord[stp_ind]
        dlen[stp_ind] = xlen
        tlen = xlen
        for i in range(stp_ind+1,ncell):
            xlen = 2.*(x_coord[i] - tlen)
            dlen[i] = xlen
            tlen = tlen + xlen
        "Now deal with PFR if present"
        if (stp_ind > 0):
            xlen = -2.*x_coord[stp_ind-1]
            dlen[stp_ind-1] = xlen
            tlen = xlen
            for i in range(0,stp_ind-1):
                xlen = -2.*(x_coord[stp_ind-2-i] + tlen)
                dlen[stp_ind-2-i] = xlen
                tlen = tlen + xlen
    else:
        "Not standard case, only PFR present, should never happen"
        xlen = -2.*x_coord[ncell-1]
        dlen[ncell-1] = xlen
        tlen = xlen
        for i in range(0,ncell-1):
            xlen = -2.*(x_coord[ncell-2-i] + tlen)
            dlen[ncell-2-i] = xlen
            tlen = tlen + xlen
    
    dsurf = 2.*np.pi*R_val*dlen
    
            
    return found, stp_ind, dlen, dsurf;

"==== INT_QUAN ==="
""" 
Integrates desired quantity along the target plate

INPUT: 
    data_header  - list of data headers
    data         - actual data
    quan         - name of quantity to integrate
    stp_ind      - index of strike point (in this convention the first cell of SOL)
    dsurf        - surface area of the target elements starting from PFR-edge and 
                    moving to SOL-edge

OUTPUT:
    found         - logical, True if data was obtained
    int_all       - integral over the whole target
    int_pfr       - integral over the PFR part of the target
    int_sol       - integral over the SOL part of the target
"""
def INT_QUAN(data_head,data,stp_ind,dsurf,quan):

    int_all = 0.
    int_pfr = 0.
    int_sol = 0.

    found, val_ind = choose_raw(data_head,quan)
    if (found == False):
        logging.error('data for %s not found, no integration will be carried out',quan)
        return found, int_all, int_pfr, int_sol;
    else:
        logging.info('integrating %s',quan)
    val = data[val_ind,:]
    
    "Standard case is stp_ind >=0"
    if (stp_ind >= 0):
        "Deal with SOL first"
        int_sol = np.sum(val[stp_ind:]*dsurf[stp_ind:])
        "Now deal with PFR if present"
        if (stp_ind > 0):
            int_pfr = np.sum(val[0:stp_ind]*dsurf[0:stp_ind])
    else:
        "Not standard case, only PFR present, should never happen"
        int_pfr = np.sum(val*dsurf)
    "Obtain total"
    int_all = int_sol + int_pfr
    
    return found, int_all, int_pfr, int_sol;

"==== AVG_QUAN ==="
""" 
Averages desired quantity along the target plate (averaging against surface area not length)

INPUT: 
    data_header  - list of data headers
    data         - actual data
    quan         - name of quantity to integrate
    stp_ind      - index of strike point (in this convention the first cell of SOL)
    dsurf        - surface area of the target elements starting from PFR-edge and 
                    moving to SOL-edge

OUTPUT:
    found         - logical, True if data was obtained
    avg_all       - average over the whole target
    avg_pfr       - average over the PFR part of the target
    avg_sol       - average over the SOL part of the target
"""
def AVG_QUAN(data_head,data,stp_ind,dsurf,quan):

    int_all = 0.
    int_pfr = 0.
    int_sol = 0.
    surf_all = 1.e-30
    surf_pfr = 1.e-30
    surf_sol = 1.e-30

    found, val_ind = choose_raw(data_head,quan)
    if (found == False):
        logging.error('data for %s not found, no averaging will be carried out',quan)
        return found, int_all, int_pfr, int_sol;       
    else:
        logging.info('averaging %s',quan)
    val = data[val_ind,:]
    
    "Standard case is stp_ind >=0"
    if (stp_ind >= 0):
        "Deal with SOL first"
        int_sol = np.sum(val[stp_ind:]*dsurf[stp_ind:])
        surf_sol = np.sum(dsurf[stp_ind:])
        "Now deal with PFR if present"
        if (stp_ind > 0):
            int_pfr = np.sum(val[0:stp_ind]*dsurf[0:stp_ind])
            surf_pfr = np.sum(dsurf[0:stp_ind])
    else:
        "Not standard case, only PFR present, should never happen"
        int_pfr = np.sum(val*dsurf)
        surf_pfr = np.sum(dsurf)
    "Obtain total"
    int_all = int_sol + int_pfr
    surf_all = surf_sol + surf_pfr
    
    "Average"
    avg_all = int_all/surf_all
    avg_sol = int_sol/surf_sol
    avg_pfr = int_pfr/surf_pfr
    
    
    return found, avg_all, avg_pfr, avg_sol;

"==== PKV_QUAN ==="
""" 
Find peak value of desired quantity along the target plate 

INPUT: 
    data_header  - list of data headers
    data         - actual data
    quan         - name of quantity to integrate
    stp_ind      - index of strike point (in this convention the first cell of SOL)

OUTPUT:
    found         - logical, True if data was obtained
    pkv_all       - peak value over the whole target
    pkv_pfr       - peak value over the PFR part of the target
    pkv_sol       - peak value over the SOL part of the target
"""
def PKV_QUAN(data_head,data,stp_ind,quan):

    pkv_all = 0.
    pkv_pfr = 0.
    pkv_sol = 0.

    found, val_ind = choose_raw(data_head,quan)
    if (found == False):
        logging.error('data for %s not found, peak values will not be obtained',quan)
        return found, pkv_all, pkv_pfr, pkv_sol;       
    else:
        logging.info('searching for the peak value of %s',quan)
    val = data[val_ind,:]
    
    "Standard case is stp_ind >=0"
    if (stp_ind >= 0):
        "Deal with SOL first"
        pkv_sol = np.amax(val[stp_ind:])
        "Now deal with PFR if present"
        if (stp_ind > 0):
            pkv_pfr = np.amax(val[0:stp_ind])
    else:
        "Not standard case, only PFR present, should never happen"
        pkv_pfr = np.amax(val)
    "Obtain total"
    pkv_all = np.maximum(pkv_sol, pkv_pfr)

    
    return found, pkv_all, pkv_pfr, pkv_sol;

"==== WRT_APD ==="
""" 
Appends daga to output file 

INPUT: 
    str_len      - controls the file format, i.e. the length of individual line
    title        - written in the beginning of appended data
    val_tot      - data for total quantities
    val_pfr      - data for PFR quantities
    val_sol      - data for SOL quantities
    val_names    - data description strings
    val_seq      - splitters used to distinguish between 
    apd_file     - name of the output file

OUTPUT:
    Appends data to upd_file
    """
def WRT_APP(str_len,title,extra_line,val_tot,val_pfr,val_sol,val_names,val_seq,apd_file):
    
    if (str_len < 6):
        str_len = 6
    
    with open(apd_file,'a') as ff:
        
        delim = '##########'
        prin = ''
        for i in range(0,str_len):
            prin = prin + delim
        prin = prin + '\n'    
        ff.write(prin)
        
        ttl = title.strip()
        ttl_len = len(ttl)
        if (ttl_len > str_len*10 ):
            logging.warning('title length %s is greater then the limit, title will be cut to %s',ttl_len,str_len*10)
            ttl = ttl[0:str_len*10]
            ttl_len = len(ttl)
        step = int((str_len*10 - ttl_len)/2)
        prin = ' '*step + ttl + '\n'
        ff.write(prin)

        delim = '##########'
        prin = ''
        for i in range(0,str_len):
            prin = prin + delim
        prin = prin +'\n'     
        ff.write(prin)

        if (extra_line != ''):
            if (len(extra_line) > str_len*10):
                logging.warning('extra_line length %s is greater then the limit, it will be cut to %s',len(extra_line),str_len*10)
                prin = extra_line[0:str_len*10] + '\n'
            else:
                step = int((str_len*10 - len(extra_line))/2)
                prin = ' '*step + extra_line + '\n'
            ff.write(prin)
            ff.write('\n') 
        else:
            ff.write('\n')
        
        for k in range(0,3):
            if (k == 0):
                datan = ' INTEGRAL DATA '
            elif (k == 1):
                datan = ' AVERAGED DATA '
            elif (k == 2):
                datan = ' PEAK DATA '
                
            step = '      SOL      ' + '      PFR      ' + '     TOTAL     '
            prin = datan + ' '*(str_len*10 - len(step) - len(datan)) + step + '\n'
            ff.write(prin)

            delim = '----------'
            prin = ''
            for i in range(0,str_len):
                prin = prin + delim
            prin = prin +'\n'     
            ff.write(prin)

            for i in range(val_seq[k],val_seq[k+1]):
                name = val_names[i]
                tlen = len(name)
                mlen = str_len*10 - 4 - 3*15
                if (tlen > mlen):
                    logging.warning('the output quantity name (%s) lenth %s is longer then the string length %s and will be truncated',name,tlen,mlen)
                    name = name[0:mlen]
                else:
                    name = name + ' '*(mlen-tlen)
                prin = '  ' + name + ': '
                prn = '{0}{1}'.format(prin,'  % 7.6E' % val_sol[i])
                prin = prn
                prn = '{0}{1}'.format(prin,'  % 7.6E' % val_pfr[i])
                prin = prn
                prn = '{0}{1}'.format(prin,'  % 7.6E' % val_tot[i])
                prin = prn + '\n'
                ff.write(prin)

                delim = '----------'
                prin = ''
                for i in range(0,str_len):
                    prin = prin + delim
                prin = prin +'\n'     
                ff.write(prin)
            
            ff.write('\n')
            
    return;
            
        


"!!! SUBROUTINES: END !!!"

"================================================================="

"!!! DRIVER: START !!!"

def main():
    
    "Check if out_file is present and remove old one if found"
    if ( os.path.isfile(out_file) == True ):
        logging.info("old output file %s is present and will be removed",out_file) 
        os.remove(out_file)
   
    
    ndiv   = np.size(div_names)
    nwlldi = np.size(wlld_quan_int)
    nwllda = np.size(wlld_quan_avg)
    nwlldp = np.size(wlld_quan_pkv)
    nfptgi = np.size(fptg_quan_int)
    nfptga = np.size(fptg_quan_avg)
    nfptgp = np.size(fptg_quan_pkv)
    extra_line = ''
    
    for k in range(0,ndiv):
        logging.info('working on %s',div_names[k])
        
        file_read, wlld_head, wlld_data = READ_FLE(wlld_names[k])
        if (file_read == True):
            geom_set, stp_ind, dlen, dsurf = SET_GEOM(wlld_head,wlld_data)
            if (geom_set == True):
                
                dsurf_pfr = np.sum(dsurf[0:stp_ind]) 
                dsurf_sol = np.sum(dsurf[stp_ind:]) 
                dsurf_tot = np.sum(dsurf) 
                wlld_tot = []
                wlld_pfr = []
                wlld_sol = []
                wlld_nam = []
                wlld_seq = [0]
                count = 0
                for i in range(0,nwlldi):
                    found, int_all, int_pfr, int_sol = INT_QUAN(wlld_head,wlld_data,stp_ind,dsurf,wlld_quan_int[i])
                    if (found == True):
                        count = count + 1
                        wlld_tot.append(int_all)
                        wlld_pfr.append(int_pfr)
                        wlld_sol.append(int_sol)
                        wlld_nam.append(wlld_name_int[i])
                wlld_seq.append(count)
                
                for i in range(0,nwllda):
                    found, avg_all, avg_pfr, avg_sol = AVG_QUAN(wlld_head,wlld_data,stp_ind,dsurf,wlld_quan_avg[i])
                    if (found == True):
                        count = count + 1
                        wlld_tot.append(avg_all)
                        wlld_pfr.append(avg_pfr)
                        wlld_sol.append(avg_sol)
                        wlld_nam.append(wlld_name_avg[i])
                wlld_seq.append(count)
                    
                for i in range(0,nwlldp):
                    found, pkv_all, pkv_pfr, pkv_sol = PKV_QUAN(wlld_head,wlld_data,stp_ind,wlld_quan_pkv[i])
                    if (found == True):
                        count = count + 1
                        wlld_tot.append(pkv_all)
                        wlld_pfr.append(pkv_pfr)
                        wlld_sol.append(pkv_sol)
                        wlld_nam.append(wlld_name_pkv[i])
                wlld_seq.append(count)
            
                title = div_names[k] + ' (' + wlld_names[k] + ') \n'
                extra_line = 'AREA [m^2] :: SOL//PFR//TOTAL ::'               
                extra = '{0}{1}{2}{3}'.format(extra_line,'% 4.3E' % dsurf_sol,' //% 4.3E' % dsurf_pfr,' //% 4.3E' % dsurf_tot)
                extra_line = extra 
                WRT_APP(str_len,title,extra_line,wlld_tot,wlld_pfr,wlld_sol,wlld_nam,wlld_seq,out_file)
                
        file_read, fptg_head, fptg_data = READ_FLE(fptg_names[k])
        if (file_read == True):
            geom_set, stp_ind, dlen, dsurf = SET_GEOM(wlld_head,wlld_data)
            if (geom_set == True):
                
                fptg_tot = []
                fptg_pfr = []
                fptg_sol = []
                fptg_nam = []
                fptg_seq = [0]
                count = 0
                for i in range(0,nfptgi):
                    found, int_all, int_pfr, int_sol = INT_QUAN(fptg_head,fptg_data,stp_ind,dsurf,fptg_quan_int[i])
                    if (found == True):
                        count = count + 1
                        fptg_tot.append(int_all)
                        fptg_pfr.append(int_pfr)
                        fptg_sol.append(int_sol)
                        fptg_nam.append(fptg_name_int[i])
                fptg_seq.append(count)
                
                for i in range(0,nfptga):
                    found, avg_all, avg_pfr, avg_sol = AVG_QUAN(fptg_head,fptg_data,stp_ind,dsurf,fptg_quan_avg[i])
                    if (found == True):
                        count = count + 1
                        fptg_tot.append(avg_all)
                        fptg_pfr.append(avg_pfr)
                        fptg_sol.append(avg_sol)
                        fptg_nam.append(fptg_name_avg[i])
                fptg_seq.append(count)
                    
                for i in range(0,nfptgp):
                    found, pkv_all, pkv_pfr, pkv_sol = PKV_QUAN(fptg_head,fptg_data,stp_ind,fptg_quan_pkv[i])
                    if (found == True):
                        count = count + 1
                        fptg_tot.append(pkv_all)
                        fptg_pfr.append(pkv_pfr)
                        fptg_sol.append(pkv_sol)
                        fptg_nam.append(fptg_name_pkv[i])
                fptg_seq.append(count)

                title = div_names[k] + ' (' + fptg_names[k] + ') \n'
                extra_line = ''
                WRT_APP(str_len,title,extra_line,fptg_tot,fptg_pfr,fptg_sol,fptg_nam,fptg_seq,out_file)
                
"!!! DRIVER: END !!!"

"================================================================="

"!!! EXECUTION LOOP !!!"
              
                    
if __name__ == "__main__":
    main()
        
