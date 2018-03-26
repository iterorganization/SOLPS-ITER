#!/usr/bin/env python
#
# run as, for example: 2dt.py "nesepa nesepm nesepi"
#
# Have not checked yet against >2d arrays
#
# JDL
from netCDF4 import Dataset
import numpy as np
import matplotlib.pyplot as plt

def main(plotvars):
    file_in = "b2time.nc"

    plotvars = plotvars.split()

    try:
        ncIn = Dataset(file_in)
    except:
        print("Error: Could not open "+file_in)
        exit(0)
        
    timesa = ncIn.variables['timesa'][:]

    myvar = {}
    for item in plotvars:
        try:
            myvar[item] = ncIn.variables[item][:]
        except:
            print("Error: Could not load variable "+item)
            exit(0)

#    print(np.shape(myvar[plotvars[0]]))
    plt.figure()
    for i,item in enumerate(plotvars):
        plt.plot(timesa,np.squeeze(myvar[plotvars[i]]),label=item,marker='x')
        
    plt.xlabel("time (s)")
    plt.legend(loc="best")
    plt.show()
    
if __name__ == '__main__':
    import argparse
    import textwrap
    parser = argparse.ArgumentParser()
    parser.add_argument('plotvars', help = 'List of variables to plot from b2time.nc', type = str)
    args = parser.parse_args()

    main(args.plotvars)
