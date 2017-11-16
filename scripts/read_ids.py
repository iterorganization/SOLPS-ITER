#! /usr/bin/env python
from __future__ import print_function
# Definition of the class structures in file imas.py
import imas
import numpy
import sys

'''
This sample program will open an existing pulse file (shot 8148, run 12) and will
read the stored edge_profiles IDSs.

It will then output the content of some fields of the edge_profiles IDSs.
'''

# This routine reads an edge_profiles IDS from the database, filling
# some fields of the IDS


def read_ids():
    """Class IMAS is the main class for the UAL.

    It contains a set of field classes, each corresponding to an IDS
    defined in the UAL The parameters passed to this creator define the
    shot and run number. The second pair of arguments defines the
    reference shot and run and is used when the a new database is
    created, as in this example.

    """
    my_ids_obj = imas.ids(8148, 12, 8148, 12)

    my_ids_obj.open()  # Open the database

    if my_ids_obj.isConnected():
        print('open OK!')
    else:
        print('open FAILED!')
        sys.exit()

    my_ids_obj.edge_profiles.get()

    print('   my_ids_obj = ')
    print(my_ids_obj.edge_profiles)

    my_ids_obj.close()


read_ids()
