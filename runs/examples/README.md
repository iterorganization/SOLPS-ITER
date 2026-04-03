# SOLPS-ITER examples

Some complete cases are available as starting points at the web location:
https://zenodo.org/communities/solps/ and are labelled according to their
corresponding SOLPS-ITER version.

The files contained in this directory are GIT version-controlled and thus
only small addenda to the full cases above.

The set of switches necessary to add to a `b2mn.dat` file to reproduce 5.0
behaviour are given in the `b2mn.dat.5.0` file.

The set of switches necessary to add to a `b2mn.dat` file to reproduce 4.3
behaviour are given in the `b2mn.dat.4.3` file.

The `b2mn.dat.5.2` file contains the set of switches necessary to run the
5.2 model.

The `b2mn.dat.drifts` file is a stencil containing the recommended set of
switches necessary for setting up a case with full drifts, using the 5.2
physics model.

# Fetching External Data Examples

Large file examples are available by typing in the `runs/examples`:

        make help
        make

or

        make -C ${SOLPSWORK} fetch	

and then extract `*.tar.gz` linked examples that appear nearby
`*.tar.gz.md5` files by:

        tar xvzf of_example_available.tar.gz

We recommend to use `make help` and prepare the example with command such as:

        make tutorial-DivGeo_ITER_baseline_scenario
        
This will fetch the corresponding case from the Zenodo record as a `*.tar.gz` file
and decompress it in a directory with the name of the example within $SOLPSTOP/runs/examples.

# Preparing examples in ITER cluster to be downloaded by other users

It is recommend to use the command:

    make publish dir=<name_of_example_directory>

This will compress the directory as a `tar.gz` file and calculate its MD5 hash.

Then the file should be added to the Zenodo record, replacing its older version.
If the Zenodo record number changes, then it should be updated in the Makefile.
