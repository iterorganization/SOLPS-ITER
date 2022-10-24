#!/usr/bin/env python
#
# run as:  resall_D.py [-l N]
#
# optional argument -l N ==> display last N points
#
# JDL
import os.path
import numpy as np
import matplotlib.pyplot as plt
import itertools

def main(args):

    file_in = "b2mn.exe.dir/b2ftrace"
    if os.path.isfile(file_in):
        print("Reading "+file_in)
    else:
        file_in = "b2ftrace"
        if os.path.isfile(file_in):
            print("Reading "+file_in)
        else:
            print("Error: Could not find b2ftrace")
            exit(0)

    with open(file_in) as f:
        lines = f.readlines()

    mydatalist = []
    counter = 0
    read_data = False
    for line in lines:
        if "data" in line:
            counter += 1
            read_data = True
            continue
        if read_data:
            line = line.split()
            part_list = [float(i) for i in line]
            mydatalist.extend(part_list)

    mydata = np.array(mydatalist)
    mydata = mydata.reshape(counter,int(len(mydatalist)/counter))

    iend = np.size(mydata,0)
    if args.last > 0:
        iend = min(args.last,iend)

    plt.figure()
    if iend > 100:
        marker = itertools.cycle((None,None))
    else:
        marker = itertools.cycle((',', '+', '.', 'o', '*'))
    plt.plot(mydata[0:iend,2],marker=next(marker),label="conD0")
    plt.plot(mydata[0:iend,3],marker=next(marker),label="conD1")
    plt.plot(mydata[0:iend,4],marker=next(marker),label="momD0")
    plt.plot(mydata[0:iend,5],marker=next(marker),label="momD1")
    plt.plot(mydata[0:iend,6],marker=next(marker),label="totmom")
    plt.plot(mydata[0:iend,7],marker=next(marker),label="ee")
    plt.plot(mydata[0:iend,8],marker=next(marker),label="ei")
    plt.plot(mydata[0:iend,9],marker=next(marker),label="phi")
    plt.yscale('log')
    plt.xlabel("Iteration")
    plt.ylabel("norm of residuals")
    plt.legend(loc="best")
    plt.title(os.getcwd())
    plt.show()

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-l","--last",type = int,help = 'display last n entries',default=0)
    args = parser.parse_args()

    main(args)
