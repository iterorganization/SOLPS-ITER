# SOLPS-ITER examples

Some complete cases are available are starting points at the web location:
https://portal.iter.org/departments/POP/CM/IMAS/SOLPS-ITER/
then inside the "Examples" folder.

The files contained in this directory are GIT version-controlled and thus
only small addenda to the full cases above.

The set of switches necessary to add to a `b2mn.dat` file to reproduce 5.0
behaviour are given in the `b2mn.dat.5.0` file.

The set of switches necessary to add to a b2mn.dat file to reproduce 5.0
behaviour are given in the b2mn.dat.5.0 file.

The `b2mn.dat.5.2` file contains the set of switches necessary to run the
5.2 model.

The `b2mn.dat.drifts` file is a stencil containing the recommended set of
switches necessary for setting up a case with full drifts, using the 5.2
physics model.

The `b2mn.dat.drifts` file is a stencil containing the recommended set of
switches necessary for setting up a case with full drifts, using the 5.2
physics model.


# Fetching External Data Examples

Large file examples are available by typing in the `runs/examples`:

        module load cmake
        cmake . && make

or

        make -C ${SOLPSWORK} fetch	

and then extract `*.tar.gz` linked examples that appear nearby
`*.tar.gz.md5` files by:

        tar xvzf of_example_available.tar.gz
        
For example, in the directory `~/solps-iter/runs/examples` a link with the
name `AUG_16151_D+C+He.tar.gz` should apper. This links points to the
example case `cc7d81bb3356467514344c57a7dece0c` stored in the local cache
`/imas/shared/boundary/solps-iter/assets/MD5/`. The name of the stored file
is its unique MD5 hash. To un-tar the contents
`$HOME/solps-iter/runs/examples` issue

    tar xvzf AUG_16151_D+C+He.tar.gz
    
And the example case is unpacked in the `$HOME/solps-iter/runs/examples`
directory.

# Preparing examples in ITER cluster to be downloaded by other users

With the use of md5sum we calculate the MD5 hash for `AUG_16151_D+C+He.tar.gz`.

First let's copy the already stored file with the following command to
`$HOME` directory:

    cp ~/solps-iter/runs/examples/AUG_16151_D+C+He.tar.gz .

Then we calculate the MD5 hash for `AUG_16151_D+C+He.tar.gz` and rename it
with the MD5 hash.

    md5sum AUG_16151_D+C+He.tar.gz
    Output: cc7d81bb3356467514344c57a7dece0c  AUG_16151_D+C+He.tar.gz
    mv AUG_16151_D+C+He.tar.gz cc7d81bb3356467514344c57a7dece0c \
       /work/imas/shared/external/assets/solps-iter/assets/MD5/

Above directory is synched to
http://static.iter.org/imas/assets/solps-iter/%(algo)/%(hash) There can be
many web servers from which users can fetch assets from. Other sites may
then just copy them to its shared directory too. For example, the server at
the university of Ljubljana now shares
http://viz.hpc.fs.uni-lj.si/assets/solps-iter/MD5.

Additional servers can share it's examples by adding the URL to
`ExternalData_URL_TEMPLATES` in `CMakeListsxt.txt` file.


# How to tell CMake to download the stored files

Now we want to include the example `AUG_16151_D+C+He.tar.gz` to the
repository, so it is available to other users.

To the directory `$HOME/solps-iter/runs/examples` you have to include a
`AUG_16151_D+C+He.tar.gz.md5` file, which contains its unique MD5 hash.

    cd $HOME/solps-iter/runs/examples
    echo cc7d81bb3356467514344c57a7dece0c > AUG_16151_D+C+He.tar.gz.md5
    # Now commit the newly added MD5 file
    git add AUG_16151_D+C+He.tar.gz.md5
    git commit -m "AUG16151 D+C+He example"
    git push
    
And that's it. The next time a user pulls the commit and fetches external
data.

# Local and cluster caches

It needs to be noted that CMake firstly searches for LOCAL_CACHES before it
tries to fetch the *ExternalData*. If it finds it, it checks if MD5 hashes
from $HOME/solps-iter/runs/examples/*.tar.gz.md5 matches with the file
names inside the `LOCAL_CACHE`. If it does, it will only create a link and
with the name *.tar.gz and pointing to the file in the `LOCAL_CACHE`. With
this we can also control the versions of the file since if a user changes
the examples and want to store it, the MD5 hash will also change. If there
are no matching files, `EXTERNAL_CACHES` will be searched.

Local caches needs to be writable by users on the machine in order to share
downloads. For that several directories are tried on the cluster. See
`CMakeLists.txt` where one can prepare common writable directory on the
cluser for assets sharing.
