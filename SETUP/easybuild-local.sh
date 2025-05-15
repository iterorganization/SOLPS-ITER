#!/bin/bash -e

function help() { cat << 'EOF'

EasyBuild for SOLPS-ITER modules
================================

For easier building of `gfortran` and `ifort64` toolchains, including
IMAS modules and tools for SOLPS-ITER, a `SETUP/easybuild-local.sh`
script is provided. This script includes a complete list of modules as
they appear on ITER SDCC cluster is convenient for standalone/local
"builders" and for site administrators that want to build
ITER-equivalent installation on their machine. Example
`setup.csh.UL.gfortran` and `setup.csh.UL.ifort64` are thus very
similar to `setup.csh.ITER.gfortran` and `setup.csh.ITER.ifort64`,
respectively. Configs `config.UL.gfortran` and `config.UL.ifort64` can
actually be symlinked to config.ITER versions.

Essentially, this script extends functionality of
[EasyBuild](http://easybuild.readthedocs.org/) tool by adding search
paths to ITER-specific easyconfigs (`.eb`) for sources from ITER Git
repositories.

The only requirement for this script is recent version
of Python 3 and modulesfiles or lmod support. The rest is being
downloaded from internet and ITER Git website. Quick astart for
building may be by creating Personal Access Token from
https://git.iter.org/plugins/servlet/access-tokens/manage and entering

~~~ bash
    export EASYBUILD_MODULES_TOOL=Lmod # EnvironmentModules are default
    export HTTP_AUTH_BEARER="ReplaceWithPersonalAccessToken"
    SETUP/easybuild-local.sh --help | more
    SETUP/easybuild-local.sh
    SETUP/easybuild-local.sh --imas-foss install
    SETUP/easybuild-local.sh --imas-apps
~~~

Some unpublished EasyBuild config files are only available at ITER SDCC cluster
or are still unmerged under pull request at
[EasyBuild Pull requests](https://github.com/easybuilders/easybuild-framework/pulls).
To facilitate easy copy of such recipes for selected modules from
SDCC `--fetch-sdcc module(s)` functionality is provided.
In order for fetch to work a local SSH key needs to be copied to ITER cluster with
`ssh-copy-id`.

Note that above minimal example requires Python 3.8+, `lmod` or
`modules`, `tcsh` and `ksh` to be installed on the system and
functional. The rest is installed by the script under the
`easybuild.local` directory or elsewhere (system-wide) if desired.

Lmod and Lua are default and recommended way to handle modules.
You may need to export `EASYBUILD_MODULES_TOOL` and
`EASYBUILD_MODULE_SYNTAX` environment variable to match you cluster
environment.

Some knowledge of EasyBuild is needed to resolve possible compile
problems. The script will need to be run several times with different
arguments on the machine where local modules are being built. It may
take a day to build everything from scratch. Script without arguments
will by default build all non-IMAS modules and if fails it can be
restarted. IMAS modules are built with IMAS installer and not with
EasyBuild. After IMAS modules are being built then IMAS applications
can be built using `--imas-apps` switch or explicitly naming `.eb`
file that exists in search path.

Building `intel` toolchain and corresponding modules is optional and
everyting can be built with `foss` toolchain.

## Directory structure

There are two directories under SOLPS top being created/used by this
script:

 - easybuild.local/ contains local Python and EasyBuild install including
   https://git.iter.org/projects/IMEX/repos/easybuild-easyconfigs

 - easyconfigs.local/ is an overlay of site specific Easyconfigs that are
   different or missing from local EasyBuild or IMAS extra easyconfigs

The collection of the EasyBuild config files (with extension .eb), is done from
various repositiories in the order of apperance:

1. [EasyBuild easyconfigs latest release](https://github.com/easybuilders/easybuild-easyconfig)
   from PyPi installed under `${SOLPS_TOP}/easybuild.local/easybuild/easyconfigs/`.
2. [IMAS easybuild-easyconfigs Git repository](https://git.iter.org/projects/IMEX/repos/easybuild-easyconfigs/)
   for ITER software installed under `${SOLPS_TOP}/easybuild.local/imas-easybuild-easyconfigs`
3. [Easybuild easyconfigs from pull requests](https://github.com/easybuilders/easybuild-framework/pulls) for
   unmerged software that should reside under EasyBuild easyconfigs. Location
   of these files obtained with `--from-pr` switch is under temporary build directories.
4. As a last resort, unpublished EasyBuild config files are fetched from ITER SDCC cluster
   with `--from-ITER` switch and stored under `${SOLPS_TOP}/easyconfigs.local/` that takes priority
   in `--robot` search path. Sources for unpublished software is fetched too.
   Note that unpublished dependencies residing at ITER cluster are required to be fetched beforehand.


Quite some number of easyconfigs can only be found installed on ITER
that are slight modification of toolchain. Missing `.eb` and `.patch`
files can be copied manually from ITER cluster

     /work/imas/opt/EasyBuild/software/<module>/<version>/easybuild/

into

    easyconfigs.local/<first_letter>/<module>/

The `easyconfigs.local` is actually a SOLPS-ITER distribution of
required easyconfigs from [ITER Git
repository](https://git.iter.org/projects/IMEX/repos/easybuild-easyconfigs/browse?at=refs%2Fheads%2FSOLPS-ITER)
including some general purpose or site-tailored easyconfigs that
should rather be [pushed to
upstream](https://github.com/easybuilders/easybuild-easyconfigs/pulls).

For a large software distribution such as SOLPS-ITER it is important
that all modules use the same parent modules. For example Qt and PyQt
should be aligned with only one version. Replacing with newer version
might lead to crashes and symbol problems. Often problems occur with
OpenSSL that should be the latest system provided one. Complete build
of installed software is around 50 GB while downloaded sources take
another 12 GB. At least 65 GB is therefore needed for both toolchain
modules.

## Building

If `EASYBUILD_PREFIX` environment variable is set then this will be
target location (for system wide) where modules and software will be
installed. For example

    export EASYBUILD_PREFIX=/opt/pkg/ITER

before running this script. Otherwise modules will be installed under
`easybuild.local/software` and `easybuild.local/modules/all`.

To use build modules use

    module use ${PWD}/easybuild.local/modules/all

### Site specific configuration

Instead of exporting environment variables one can save site-specific
configuration under `SETUP/setup-easybuild.local` that is sourced
if exists. For example:

    export EASYBUILD_PREFIX=/opt/pkg/ITER
    export EASYBUILD_MODULES_TOOL=Lmod
    export INTEL_LICENSE_FILE=/opt/pkg/etc/intel.lic
    export HTTP_AUTH_BEARER=MTk1ODA1MzE1MTI3OoHVFKMpL/kn8BQKWBiLFNfrCTrU
    export EASYBUILD_BUILDPATH=/dev/shm/
    module purge
    module load AlmaLinux/profile  python-3.8.12-gcc-8.5.0-bvu5tg4

### SOLPS-ITER gfortran modules

Follow success of each step below and adapt `.eb` files as necessary
by putting them into easyconfigs.local

    SETUP/easybuild-local.sh --help | less
    SETUP/easybuild-local.sh # defaults to foss modules
    SETUP/easybuild-local.sh --imas-foss 
    SETUP/easybuild-local.sh --imas-foss install
    SETUP/easybuild-local.sh GGD-1.11.0-GCC-10.2.0-DD-3.38.1.eb
    sed -i -e /CPATH/d easybuild.local/modules/*/GGD/*
    SETUP/easybuild-local.sh Viz-2.8.0-foss-2020b.eb --robot
    SETUP/easybuild-local.sh SimDB-0.7.1-foss-2020b.eb --robot

### SOLPS-ITER ifort64 modules

Before building INTEL toolchain

    export INTEL_LICENSE_FILE=/opt/pkg/etc/intel.lic

Then remaining INTEL IMAS is being built

    SETUP/easybuild-local.sh --intel
    SETUP/easybuild-local.sh --imas-intel clean # optional
    SETUP/easybuild-local.sh --imas-intel
    SETUP/easybuild-local.sh --imas install
    SETUP/easybuild-local.sh --imas-apps
    sed -i -e /CPATH/d easybuild.local/modules/*/GGD/*
    sed -i -e /CPATH/d easybuild.local/modules/*/AMNS/*


## GCC, foss, gompi and OpenMPI toolchains

Toolchains need to be compatible including depending software. For
that reason the missing EasyBuild files are being created from the
nearest similar toolchain. OpenMPI is site-specific and usually
includes SLURM scheduler. It is advised that the latest OpenMPI is
build and version is replaced within `foss` and `gompi` toolchains.
Default OpenMPI configopts are empty and can be tweaked by directly
editing easyconfig file or alternatively by amending config options
and forcing rebuild even if built succesfully with

    SETUP/easybuild-local.sh --force \
      --try-amend="configopts=--with-slurm --with-pmi=/usr --with-pmi-libdir=/usr/lib64" \
      OpenMPI-4.1.2-GCC-10.2.0.eb

## HTTP authentication setup

Some sources are available for download only from git.iter.org site and
you need to have HTTP download password generated by generating personal
access token that is actually http password with your credentials. Use
https://git.iter.org/plugins/servlet/access-tokens/manage to generate
the token and then export it with setenv or export (bash)

    export HTTP_AUTH_BEARER='ChangeThisBearerkn8BQKWBiLFNfrCTru'

Instead of using automatic download from ITER site one can use manual
download and save it under `easybuild.local/sources/<letter>/<package>/`.

## Updating local build repositories for new environment build

When this script is updated with new IMAS tools, several repositories
need to be updated too. The easiest way to update for new environment
build is to issue

    SETUP/easybuild-local.sh --pull

and then usual rebuild of new packages with

    SETUP/easybuild-local.sh
    SETUP/easybuild-local.sh --intel

## Compiling SOLPS-ITER with locally installed modules

Setup from the University of Ljubljana (UL) provides ITER
modules compatibility and therefore it is universal to
be used with local builds (residing under easybuild.local/software).
To load the modules and compile SOLPS-ITER use the following recipe:

~~~ csh
tcsh
setenv SOLPS_HOST_NAME_FORCE UL
source setup.csh gfortran
make depend
make
~~~

## Package notes

### Invalid source checksums

Often there are some checksum problems at ITER easyconfigs due to
improper source tag specifications. To remedy this situation a quick
refresh can be used after config and source files fetched:

   SETUP/easybuild-local.sh SimDB-0.11.0-gfbf-2023b.eb --inject-checksums
   SETUP/easybuild-local.sh SimDB-0.11.0-gfbf-2023b.eb
   SETUP/easybuild-local.sh UDA-2.7.5-GCC-13.2.0.eb --inject-checksums --force
   SETUP/easybuild-local.sh UDA-2.7.5-GCC-13.2.0.eb

### CPATH problems with pkg-config

GGD and AMNS, json-fortran modules must not have CPATH otherwise
`pkg-config ggd amns --cflags` will not have include paths printed and
SOLPS-ITER will fail to find includes listed in CPATH.  As a post
process there is `--patch-modules-cpath` switch that can be used to
fix incorrectly built module files. Another way can be to unset CPATH
in `setup.csh.*.*` files.


### MSCL,ESMF,GSL,... on cluster with AMD processors and Intel toolchain

Due to Intel libries dependent packages requires disabled architecture
optimisation flags with

    SETUP/easybuild-local.sh MSCL-1.2.4-iimkl-2023b.eb --optarch=GENERIC
    SETUP/easybuild-local.sh ESMF-8.6.1-intel-2023b.eb --optarch=GENERIC --robot
    SETUP/easybuild-local.sh GSL-2.7-intel-compilers-2023.2.1.eb --optarch=GENERIC

### NCL and HDF5

NCL from PR #21176 introduces higher HDF5 version that is fixed by the
official toolchain to HDF5/1.14.3 and thus modification of (Armadillo,
GDAL, NCL, netCDF) EB configs if fetched from the ITER SDCC is
required too. NCL for Intel requires to `--include-easyblocks-from-pr=3409`.

The problem is exhibited at Tcl version of modules only while at Lua
the replacement is silently ignored. See Marconi or IFERC subsection
below on how to address this correctly.

### OpenSSL

Qt5 and Qt6 should have OpenSSL version 1.1.1 installed on the system
and not by the EasyBuild module. This resolves problems when compiling
ParaView and PySide6 (shiboken6) since system /lib64 might be in place
of OpenSSL module and symbol incompatibility.

### ParaView

Building ParaView can run out of memory or crashes on some machines
and for that use lower threads or even `--parallel 1` for serial build.

### IMAS

ParaView Catalyst configuration does not work correctly with CMake/3.26 or higher.
For that the recommended way is to backport to CMake/3.20 with the following commands:

~~~ bash
mkdir -p easyconfigs.local/c/CMake
cp easybuild.local/easybuild/easyconfigs/c/CMake/CMake-3.27.6-GCCcore-13.2.0.eb easyconfigs.local/c/CMake/CMake-3.20.1-GCCcore-13.2.0.eb
sed -i -e s/3.27.6/3.20.1/ easyconfigs.local/c/CMake/CMake-3.20.1-GCCcore-13.2.0.eb
SETUP/easybuild-local.sh CMake-3.20.1-GCCcore-13.2.0.eb --inject-checksums --force
SETUP/easybuild-local.sh CMake-3.20.1-GCCcore-13.2.0.eb
~~~

### GR

Hiden dependency for GKS libraries (modules GR) is library `pixman-devel`
that needs to be installed system-wide.

### AMNS, GGD, Viz

AMNS requires system to having latexmk package installed on the system.

Dependency to IMAS for AMNS, GGD and VIZ needs to be updated with

    ('IMAS/3.40.1-4.11.9-2020b', EXTERNAL_MODULE),

    sed -i -e '/IMAS-AL/{s/5.2.1/5.4.0/;s/3.41/4.0/}' easybuild.local/imas-easybuild-easyconfigs/easybuild/easyconfigs/v/Viz/Viz-2.8.0-*.eb

If IMAS-AL MATLAB is not required it can be removed from AMNS with

or 

    sed -i -e /CPATH/d ${EASYBUILD_PREFIX}/modules/*/GGD/* 
    sed -i -e /CPATH/d ${EASYBUILD_PREFIX}/modules/*/AMNS/*

### Texlive 20210216-GCCcore-10.2.0

Incorrect EasyBuild file was corrected by changing version in install command

    %(builddir)s/install-tl-20210324/install-tl

and a historic CTAN repository from Erlangen-Nürnberg was necessary to build 
the package.

### NAGfor

Incorrect checksum when building was updated with computing

    sha256sum easybuild.local/sources/n/NAGfor/NAGfor-6.2.14.tgz

and replaciing checksum with

    mkdir -p easyconfigs.local/n/NAGfor/
    cp easybuild.local/easybuild/easyconfigs/n/NAGfor/NAGfor-6.2.14.eb \
     easyconfigs.local/n/NAGfor/
    vi easyconfigs.local/n/NAGfor/NAGfor-6.2.14.eb


### NVHPC required by IMAS installer

PGI FORTRAN compiler is provided inside NVHPC for building IMAS
modules. Build manually with

    SETUP/easybuild-local.sh NVHPC-21.2.eb --accept-eula-for=NVHPC \
        --cuda-compute-capabilities=8.0


### MDSplus

IMAS Installer actually requires jTraverse.jar provided by
MDSplus-Java module that is then used in `setup.csh.HOST.toolchain`
too!

### SimDB

Requires OpenLDAP to be installed on the system.

    yum install openldap-devel

## Setting up local SOLPS-ITER setup.csh

For new HPC sites that `./wheremai` returns `UNKNOWN` it is
recommended to update this script. Otherwise, local setup can be
created from ITER template, retaining only SDCC modules. Similar setup
from *UL* can be used as a template by using short `hostname` as local
setup host name for each compiler.

~~~ bash
host_name=`hostname --short | tr a-z A-Z`
echo "Creating local ${host_name} setup"
echo "setenv HOST_NAME ${host_name}" > SETUP/setup.csh.HOST_NAME.local
cp SETUP/setup.csh.UL.ifort64 SETUP/setup.csh.${host_name}.ifort64
cp SETUP/setup.csh.UL.gfortran SETUP/setup.csh.${host_name}.gfortran
sed -i -e "/module u/s,/.*,${PWD}/easybuild.local/modules/all,;/PySide6\|Qt6/d"\
  SETUP/setup.csh.${host_name}.ifort64 SETUP/setup.csh.${host_name}.gfortran
# or in case installed under ${EASYBUILD_PREFIX}
sed -i -e "/module use/s,/.*,${EASYBUILD_PREFIX}/modules/all,;/PySide6\|Qt6/d" \
  SETUP/setup.csh.${host_name}.ifort64 SETUP/setup.csh.${host_name}.gfortran
~~~

Note that UL's setup template changes HOST_NAME internally back to ITER
in order to reuse SOLPS-ITER and submodules configs.

## Site notes

The following notes are guides for builders with similar setup. ITER
site notes are just proof of concept and guide for other sites that
already have EasyBuild modules in place and want to install complete
SOLPS-ITER toolchain, including IMAS. Confer notes below with your
machine on how to resolve similar problems.

### AMD processors with Intel toolchain

Many packages require `--optarch=GENERIC` to be built when runnning
Intel toolchain for AMD processors. Messages such as

    Please verify that both the operating system and the processor support
    Intel(R) X87, CMOV, MMX, SSE, SSE2, SSE3, SSSE3, SSE4_1, SSE4_2, MOVBE,
    POPCNT, AVX, F16C, FMA, BMI, LZCNT, AVX2 and ADX instructions.

indicate such requirement. To address the issue the affected Intel based
packages have this flag added in the script and might affect performance
to some extent. If having Intel CPU, you may remove these flags in the
script or rebuild the packages without it.

### AMD compute cluster with Lustre 2.14 (outdated)

Building on Lustre 2.14 requires Python 3.8
Using system Python 3.6.8 fails within shutil.copytree() function.

   module load python-3.8.12-gcc-8.5.0-bvu5tg4
   export EASYBUILD_MODULES_TOOL=Lmod


ParaView requires Qt/5.15.2 for qhelpgenerator to work on Trinity
desktop. To avoid clashes it is required to change all Qt dependent
libraries such as PyQt5 with PyQt5 designer plugin enabled for SOLPS
GUI. Note that PyQt5 installs Qt Designer plugin `libpyqt5.so` inside
Qt5/plugins directory and any change to Qt5 requires `--force` rebuild
of PyQt5 too.

~~~ bash
mkdir -p easyconfigs.local/p/PyQt5
cp easybuild.local/easybuild/easyconfigs/p/PyQt5/PyQt5-5.15.2-GCCcore-10.2.0.eb  easyconfigs.local/p/PyQt5/
sed -i -e s/--no-designer-plugin// easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-10.2.0.eb
vi easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-10.2.0.eb # to Qt/5.15.2
SETUP/easybuild-local.sh PyQt5-5.15.2-GCCcore-10.2.0.eb --force

# INTEL toolchain
SETUP/easybuild-local.sh SciPy-bundle-2020.11-intel-2020b.eb --skip-test-step
~~~

Note that there can be only slight version differences bewteen Qt5 and PyQt5.


#### Changing Qt5 version in gnuplot

     mkdir -p easyconfigs.local/g/gnuplot
     cp easybuild.local/easybuild/easyconfigs/g/gnuplot/gnuplot-5.4.1-GCCcore-10.2.0.eb easyconfigs.local/g/gnuplot/
     sed -i -e /Qt5/s/5.14.2/5.15.2/ easyconfigs.local/g/gnuplot/gnuplot-5.4.1-GCCcore-10.2.0.eb
     SETUP/easybuild-local.sh gnuplot-5.4.1-GCCcore-10.2.0.eb --force

#### HDF5-1.10.7-iimpi-2020b.eb used by netCDF-4.7.4-iimpi-2020b.eb

AMD processors fail building numpy as part of SciPy-bundle. Numpy
fails on AMD processors due to disabled SSE message. With added extra
toolchain fortran AVX options

     toolchainopts = {'pic': True, 'usempi': True, 'extra_fcflags': '-march=core-avx2'}

### ITER cluster with CentOS 8.2 and GPFS

OpenMPI with Slurm and PMI requires rebuild for dependent packages
such as NetCDF, HDF5, ...

    module load Python/3.9.5-GCCcore-10.2.0-bare
    SETUP/easybuild-local.sh  --help | less
    tmp_path=$PATH tmp_llp=$LD_LIBRARY_PATH tmp_pp=$PYTHONPATH 
    module purge
    export PATH=$tmp_path LD_LIBRARY_PATH=$tmp_llp PYTHONPATH=$tmp_pp
    export INTEL_LICENSE_FILE=27010@io-ws-ls1  


ITER Organization is using "Forward Trust SSL Proxy" and `--help` does
not work due to intermediate self-signed certificate. To overcome this
issue we need to download intermediate CA certificates and append them
to existing Python CA certificates trust with

    openssl s_client -showcerts -connect api.github.com:443 \
    | sed -n -e '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' \
    >> easybuild.local/lib/python3.*/site-packages/certifi/cacert.pem

This manual will then show correctly in local browser too

    SETUP/easybuild-local.sh  --help

Binutils easyblock *sanity check* incorrectly assumes that no static
linking was done as `ldd` shows zlib loaded in LD_LIBRARY_PATH.
However, this is comming from our EasyBuild Python. We skip the sanity
check step by adding a line at end of all binutils easyconfigs

    sed -i -e '$askipsteps = ["sanitycheck"]' \
      easybuild.local/easybuild/easyconfigs/b/binutils/*.eb

Since building on ITER cluster is unnecessary and this is just proof
of concept, useful for testing, one might consider to build everything
faster in large shared memory filesystem (180 GB) found on SDCC login
nodes by setting

      export EASYBUILD_PREFIX=/dev/shm/$USER

or to local SSD if enough space is available

      export EASYBUILD_PREFIX=/tmp/$USER

Do not forget to remove /dev/shm/$USER imediately after testing! We
can build even faster with number of processors doubled on compute
nodes

    srun -N1 -n36 -p gen10_ib --pty bash -i

### EU IM Gateway cluster eufus.eu

CentOS Linux release 7.4 with tcsh as a default shell with SLURM 21 on
GPFS.


~~~ csh
module load python-3.8.8-gcc-6.4.0-ev3ryed
setenv HTTP_AUTH_BEARER MTk1ODA1MzE1MTI3Oo......
setenv EASYBUILD_MODULES_TOOL EnvironmentModulesC
setenv INTEL_LICENSE_FILE /cineca/prod/opt/compilers/intel/pe-xe-2020/binary/server.lic
SETUP/easybuild-local.sh --help | less
sed -i -e "/configopts =/s|.*|= configopts = '--with-slurm --with-pmi=/opt/slurm/current --with-pmi-libdir=/opt/slurm/current/lib'|" \
 easyconfigs.local/o/OpenMPI/OpenMPI-4.1.2-GCC-10.2.0.eb
SETUP/easybuild-local.sh SciPy-bundle-2020.11-foss-2020b.eb --skip-test-step
SETUP/easybuild-local.sh NVHPC-21.2.eb --accept-eula-for=NVHPC --cuda-compute-capabilities=7.0
SETUP/easybuild-local.sh Qt6-6.2.3-GCCcore-10.2.0.eb --robot
~~~
Fix GGD and AMNS modules for CPATH. 


ParaView should be run with

    /usr/NX/scripts/vgl/vglrun paraview

### Marconi Fusion

CentOS Linux release 7.2 with Intel Xeon CPU E5-2697 v4 @ 2.30GHz
(skylake)

~~~ bash
export EASYBUILD_MODULES_TOOL=EnvironmentModules
SETUP/easybuild-local.sh SciPy-bundle-2020.11-foss-2020b.eb --skip-test-step
sed -i -e "/^configopts/s/'"'$'"/ -skip qtwebengine'/" \
  -e /check_qtwebengine/s/True/False/ \
  easyconfigs.local/q/Qt5/Qt5-5.15.2-GCCcore-10.2.0.eb
sed -i -e "/('PyQtWebEngine'/,/})/d" -e "/('Qt5Webkit'/d" \
   easybuild.local/easybuild/easyconfigs/p/PyQt5/PyQt5-5.15.13-GCCcore-13.2.0.eb
sed -i -e -e "/configopts/s/'"'$'"/ -no-sql-mysql'/" \
   easybuild.local/easybuild/easyconfigs/p/PyQt5/PyQt5-5.15.13-GCCcore-13.2.0.eb

sed -i -e "s/qtwayland=OFF/& -DBUILD_qtwebengine=OFF/" -e "s,'lib/libQt6WebEngine.*SHLIB_EXT,," \
  -e "s,'include/QtWebEngineCore',,"  easybuild.local/easybuild/easyconfigs/q/Qt6/Qt6-6.6.3-GCCcore-13.2.0.eb

SETUP/easybuild-local.sh netcdf4-python-1.6.5-foss-2023b.eb --skip-test-step

sed -i -e "/checksums/abuilddependencies = [('binutils', '2.40')]" \
  easybuild.local/easybuild/easyconfigs/i/imkl/imkl-2023.2.0.eb

SETUP/easybuild-local.sh SciPy-bundle-2023.12-iimkl-2023b.eb  --from-pr=20262 --ignore-test-failure

SETUP/easybuild-local.sh --fetch-sdcc Armadillo/12.8.0-intel-2023b
sed -i -e s/1.14.4.3/1.14.3/ easyconfigs.local/a/Armadillo/Armadillo-12.8.0-intel-2023b.eb
SETUP/easybuild-local.sh Armadillo-12.8.0-intel-2023b.eb --force

SETUP/easybuild-local.sh --fetch-sdcc Boost/1.83.0-intel-compilers-2023.2.1
sed   -e "s/%%(namelower)s_%s.tar.gz.*)/boost_1_82_0.tar.gz'/" -e s/_1.83/_1_82/  easyconfigs.local/b/Boost/Boost-1.83.0-intel-compilers-2023.2.1.eb
SETUP/easybuild-local.sh Boost-1.83.0-intel-compilers-2023.2.1.eb --inject-checksums --force
SETUP/easybuild-local.sh Boost-1.83.0-intel-compilers-2023.2.1.eb

SETUP/easybuild-local.sh --fetch-sdcc GDAL/3.9.0-intel-2023b
sed -i -e s/1.14.4.3/1.14.3/ easyconfigs.local/g/GDAL/GDAL-3.9.0-intel-2023b.eb
SETUP/easybuild-local.sh GDAL-3.9.0-intel-2023b.eb

SETUP/easybuild-local.sh --fetch-sdcc NCL/6.6.2-intel-2023b
sed -i -e s/1.14.4.3/1.14.3/  easyconfigs.local/n/NCL/NCL-6.6.2-intel-2023b.eb
SETUP/easybuild-local.sh NCL-6.6.2-intel-2023b.eb

SETUP/easybuild-local.sh ParaView-5.12.0-intel-2023b-mpi.eb --parallel 16
~~~

### Marconi 100 

Red Hat Enterprise Linux release 8.1 with POWER9 CPU ppc64le 

SLURM PMI2 is not available on M100. 
~~~ bash
module load python/3.8.2
export EASYBUILD_MODULES_TOOL=EnvironmentModules
sed -i -e "/configopts =.*slurm/s|.*|configopts = '--with-slurm'|" \
 easyconfigs.local/o/OpenMPI/OpenMPI-4.1.2-GCC-10.2.0.eb
SETUP/easybuild-local.sh SciPy-bundle-2020.11-foss-2020b.eb --skip-test-step
SETUP/easybuild-local.sh ParaView-5.10.0-foss-2020b-mpi.eb --parallel 2
~~~

Python 3.8.6 requires newer `setuptools` or to be removed from Python bundle.

### Debian 11 workstation

Python 3.9.2 provided by the system is sufficient for building the
modules. No SLURM or PMI can be found by OpenMPI. DBus falsely finds
Qt5 and tries to generate help and for that we need to explicityly
disable its generation. Korn shell (ksh) is required for GR software build!

~~~ bash
sudo apt-get install -y libssl-dev latexmk lmod ksh
export HTTP_AUTH_BEARER=DSSDDAsdf1MzE1MT....
source /etc/profile.d/lmod.sh
export EASYBUILD_MODULES_TOOL=Lmod
SETUP/easybuild-local.sh --help
sed -i -e "/^configopts/s/^/# /" \
  easyconfigs.local/o/OpenMPI/OpenMPI-4.1.2-GCC-10.2.0.eb
sed -i -e "/configopts/s/'$/ --enable-qt-help=no'/" \
  easybuild.local/easybuild/easyconfigs/d/DBus/DBus-1.13.18-GCCcore-10.2.0.eb
~~~

### SUSE Linux Enterprise Server 15 SP1 at IFERC cluster behind a firewall

Requires dynamic local SOCKS5 proxy to be created before connecting to
IFERC and then remotely redirect SOCKS5 trafic to local machine.  For
python3, required by Easybuild, bootstrapping PySocks wheel is needed
to install the virtual environment manually. Since Easybuild does not
support SOCKS5 the easiest is to rsync local or ITER installation
sources to IFERC before starting of building packages or redirect all
`urllib.requests` in `filetool.py` to default SOCKS5 proxy tunel as
shown in the commands below. Note that this approach does not use
`http_proxy` or `https_proxy`. Replace username `kosl` and bearer
password (`HTTP_AUTH_BEARER`).

~~~ bash
python3 -m pip download pysocks # Dowload the wheel
scp PySocks-*-py3-none-any.whl kosl@jfrs.iferc-csc.jp: # Copy the wheel to JFRS
ssh -D 1080 -C -N -f `hostname` # Creates SOCKS5 proxy on a local machine
ssh -R 1080:localhost:1080 kosl@jfrs.iferc-csc.jp # Login and tunel SOCKS5 to my local proxy
ssh-keygen -t ed25519 # generate a key for remote access
cat .ssh/id_ed25519.pub # paste the key to  https://git.iter.org/plugins/servlet/ssh/account/key
cat > ~/.ssh/config << __EOF__
Host gpc-access.iter.org
HostName gpc-access.iter.org
ProxyCommand nc -v -x 127.0.0.1:1080 %h %p
__EOF__
ssh-copy-id kosl@gpc-access.iter.org
git config --global http.proxy 'socks5://127.0.0.1:1080'
git config --global https.proxy 'socks5://127.0.0.1:1080'
git config --global core.sshCommand 'ssh -o ProxyCommand="nc -v -x 127.0.0.1:1080 %h %p"'
git clone --recursive ssh://git@git.iter.org/bnd/solps-iter.git

cd solps-iter
cat > SETUP/setup.easybuild.local << __EOF__
export EASYBUILD_MODULES_TOOL=EnvironmentModulesC
export EASYBUILD_MODULE_SYNTAX=Tcl
export HTTP_AUTH_BEARER=MTk1ODA1MzE1MTI3OoHVFKMpL/kn8BQKWBiLFNfrC....
export EASYBUILD_BUILDPATH=/tmp
export ITER_USERNAME=kosl
module purge
module load modules
__EOF__

python3 -m venv easybuild.local
easybuild.local/bin/python install ~/PySocks-*-py3-none-any.whl
easybuild.local/bin/python install --upgrade  pip wheel
easybuild.local/bin/python -m pip install setuptools grip keyring GitPython keyrings.alt easybuild
git clone ssh://git@git.iter.org/imex/easybuild-easyconfigs.git \
            -b develop easybuild.local/imas-easybuild-easyconfigs
mkdir  easyconfigs.local

cat > filetools.diff << __EOF__
--- easybuild.local/lib64/python3.6/site-packages/easybuild/tools/filetools.py.orig     2025-01-19 04:38:15.609982000 +0900
+++ easybuild.local/lib64/python3.6/site-packages/easybuild/tools/filetools.py  2025-01-19 04:39:53.207489000 +0900
@@ -59,6 +59,10 @@
 import time
 import zlib
 from functools import partial
+import socks
+import socket
+socks.set_default_proxy(socks.SOCKS5, '127.0.0.1', 1080)
+socket.socket = socks.socksocket

 from easybuild.base import fancylogger
 from easybuild.tools import LooseVersion, run
__EOF__
patch < filetools.diff

echo "proxy = socks5://127.0.0.1:1080" > ~/.curlrc
ESMF_OS=Linux SETUP/easybuild-local.sh ESMF-8.6.1-foss-2023b.eb
sed -i -e "/source_urls/s|'.*'|'https://archives.boost.io/release/1.83.0/source'|"  easybuild.local/easybuild/easyconfigs/b/Boost/Boost-1.83.0-GCC-13.2.0.eb
sed -i -e "/source_urls/s|'.*'|'http://sources.buildroot.net/qhull'|" easybuild.local/easybuild/easyconfigs/q/Qhull/Qhull-2020.2-GCCcore-13.2.0.eb
sed -i -e "/'GTK+', version/a'configopts': '-Dprint_backends=file'," easybuild.local/easybuild/easyconfigs/g/GTK3/GTK3-3.24.39-GCCcore-13.2.0.eb
OMPI_MCA_btl=self,vader SETUP/easybuild-local.sh netcdf4-python-1.6.5-foss-2023b.eb --skip-test-step
sed -i -e "s/qtwayland=OFF/& -DBUILD_qtwebengine=OFF/" -e "s,'lib/libQt6WebEngine.*SHLIB_EXT,," \
  -e "s,'include/QtWebEngineCore',,"  easybuild.local/easybuild/easyconfigs/q/Qt6/Qt6-6.6.3-GCCcore-13.2.0.eb
sed -i -e /IMAS-AL-Matlab/d easybuild.local/imas-easybuild-easyconfigs/easybuild/easyconfigs/a/AMNS/AMNS-1.6.0*.eb
SETUP/easybuild-local.sh
CPATH=/usr/include/netpbm SETUP/easybuild-local.sh GTS-0.7.6-GCCcore-13.2.0.eb
sed -i -e '/sanity_check_commands/a"module load GCC && "' easybuild.local/imas-easybuild-easyconfigs/easybuild/easyconfigs/f/Fundamental-Constants/Fundamental-Constants-0.1.1.eb
sed -i -e s/5.2.1/5.4.0/ -e s/3.41.0/4.0.0/  easybuild.local/imas-easybuild-easyconfigs/easybuild/easyconfigs/v/Viz/Viz-2.8.0-foss-2023b.eb
SETUP/easybuild-local.sh
# INTEL toolchain
sed -i -e "/dependencies/askipsteps = ['sanitycheck']" easybuild.local/easybuild/easyconfigs/i/impi/impi-2021.10.0-intel-compilers-2023.2.1.eb
SETUP/easybuild-local.sh --intel
SETUP/easybuild-local.sh netCDF-4.9.2-iimpi-2023b.eb  --skip-test-step
ESMF_OS=Linux SETUP/easybuild-local.sh ESMF-8.6.1-intel-2023b.eb
SETUP/easybuild-local.sh --intel
SETUP/easybuild-local.sh --fetch-sdcc GDAL/3.9.0-intel-2023b
sed -i -e s/1.14.4.3/1.14.3/ easyconfigs.local/g/GDAL/GDAL-3.9.0-intel-2023b.eb
sed -i -e s/1.14.4.3/1.14.3/ easyconfigs.local/a/Armadillo/Armadillo-12.8.0-intel-2023b.eb
SETUP/easybuild-local.sh Armadillo-12.8.0-intel-2023b.eb --force
SETUP/easybuild-local.sh GDAL-3.9.0-intel-2023b.eb
sed -i -e s/1.14.4.3/1.14.3/ easyconfigs.local/n/NCL/NCL-6.6.2-intel-2023b.eb
SETUP/easybuild-local.sh NCL-6.6.2-intel-2023b.eb  --include-easyblocks-from-pr=3409
SETUP/easybuild-local.sh --fetch-sdcc poppler/24.04.0-intel-compilers-2023.2.1
sed -i  -e 's/LCMS=OFF/& -DENABLE_GPGME=OFF/' easyconfigs.local/p/poppler/poppler-24.04.0-intel-compilers-2023.2.1.eb
SETUP/easybuild-local.sh  poppler-24.04.0-intel-compilers-2023.2.1.eb
SETUP/easybuild-local.sh --intel
SETUP/easybuild-local.sh matplotlib-3.8.2-iimkl-2023b.eb
cd easyconfigs.local/m/matplotlib
curl -o qhull-2020-src-8.0.2.tgz http://sources.buildroot.net/qhull/qhull-2020-src-8.0.2.tgz
mkdir -p easyconfigs.local/q/Qhull
cp easybuild.local/easybuild/easyconfigs/q/Qhull/Qhull-2020.2-GCCcore-13.2.0.eb easyconfigs.local/q/Qhull/Qhull-2020.2-intel-2023b.eb
sed -i -e s/GCCcore/intel/ -e s/13.2.0/2023b/ easyconfigs.local/q/Qhull/Qhull-2020.2-intel-2023b.eb # change toolchain
SETUP/easybuild-local.sh Qhull-2020.2-intel-2023b.eb
vi easyconfigs.local/m/matplotlib/matplotlib-3.8.2-iimkl-2023b.eb # change Qhull
SETUP/easybuild-local.sh matplotlib-3.8.2-iimkl-2023b.eb
sed -i  -e "/dependencies/iskipsteps = ['sanitycheck']" easyconfigs.local/n/netcdf4-python/netcdf4-python-1.6.5-intel-2023b.eb
SETUP/easybuild-local.sh netcdf4-python-1.6.5-intel-2023b.eb  --skip-test-step
sed -i -e s/5.2.1/5.4.0/ -e s/3.41.0/4.0.0/ -e s/2.7.5/2.8.0/ easybuild.local/imas-easybuild-easyconfigs/easybuild/easyconfigs/v/Viz/Viz-2.8.0-intel-2023b.eb
SETUP/easybuild-local.sh Viz-2.8.0-intel-2023b.eb
# Compiling SOLPS-ITER
setenv SOLPS_HOST_NAME_FORCE UL
source setup.csh
setenv LD_PRELOAD ${EBROOTOPENSSL}/lib/libcrypto.so
make depend
make
~~~~

- Package `Perl-bundle-CPAN-5.38.0-GCCcore-13.2.0.eb` requires package
  `Term::ReadLine::Gnu` to be commented out due to missing
  `libtermcap`.
- Package `ESMF-8.6.1-foss-2023b.eb` incorrectly identified Cray as
  Unicos and requires `ESMF_OS=Linux` preset before NCL build stage.
- Boost archive not anymore JFrog landing requires source change
- Qhull source download fails short unless `source_url` changed
- GTK3 must be compiled without CUPS for Ghostscript
- netcdf4-python should not do sanity checks with limited locked memory
- Qt6 should be patched for build without Wayland and QtWebEngine
- Build `gnupg-bundle` without gpgme and poppler with `-DENABLE_GPGME=OFF`
- GTS fails to find `pgm.h` and we suggest `CPATH=/usr/include/netpbm` to build it.
- AMNS built without MATLAB
- Fundamental-Constants assumes gfortran to be installed in system path for sanity checks.
- Viz requires alignment with newer IMAS to build against. AL_VERSION can be fixed in alias.
- Intel compilers do not have enough locked memory to do sanity checks
- Armadillo, GDAL require HDF5 version fix for NCL consistency in Intel toolchain
- OpenSSL requires `setenv LD_PRELOAD ${EBROOTOPENSSL}/lib/libcrypto.so` when building
  (with `make`) or running SOLPS-ITER!
- Matplotlib for Intel requires Qhull to be built separately

## Usage

~~~
SETUP/easybuild-local.sh [OPTION... | easybuild_command...]

  --help                prints and opens this manual, then EasyBuild help
  --imas-foss           builds IMAS with foss-2020b toolchain
  --imas-foss install   installs IMAS and module
  --intel               build INTEL modules and toolchain
  --imas-intel clean    cleans IMAS repository before rebuilding
  --imas-intel          builds IMAS with INTEL toolchain 
  --imas-intel install  installs IMAS and module built with INTEL
  --imas                builds default CentOS-8 IMAS built with GCC and INTEL
  --imas install        installs IMAS CentOS-8 module built with GCC and INTEL
  --imas-apps           builds all IMAS applications
  --pull                pulls Git repos for IMAS and updates EasyBuild configs
  --patch-imas-modules  fixes AMNS and GGD module by removing CPATH

ENVIRONMENT variables:

  TAG_DD                   IMAS data dictionary version
  TAG_AL                   IMAS access layer version
  EASYBUILD_PREFIX         Software installation directory prefix
  EASYBUILD_MODULES_TOOL   Modules tool (Lmod, EnvironmentModules)
  EASYBUILD_MODULE_SYNTAX  Tcl or Lua syntax for modulefiles generated
  HTTP_AUTH_BEARER         Personal token for downloading of ITER GIT sources

Files:

  SETUP/setup-easybuild.local Site specific environment variables and modules

~~~
EOF
}
trap 'ec=$?; ((ec != 0)) && echo -e "\e[31mExited with failure: $ec\e[m"' EXIT

solps_top=$(git rev-parse --show-toplevel)
EASYBUILD_LOCAL=${solps_top}/easybuild.local

TAG_DD=${TAG_DD:-3.40.1}
TAG_AL=${TAG_AL:-5.1.0}

setup=${solps_top}/SETUP/setup.easybuild.local && test -f ${setup} && . ${setup}

export EASYBUILD_PREFIX=${EASYBUILD_PREFIX:-${EASYBUILD_LOCAL}}
export MODULEPATH=${EASYBUILD_PREFIX}/modules/all
export EASYBUILD_GITHUB_USER=${EASYBUILD_GITHUB_USER:-${USER}}
export EASYBUILD_MODULES_TOOL=${EASYBUILD_MODULES_TOOL:-EnvironmentModules}
export EASYBUILD_MODULE_SYNTAX=${EASYBUILD_MODULE_SYNTAX:-Tcl}
export EASYBUILD_ALLOW_MODULES_TOOL_MISMATCH=1
export PATH=${EASYBUILD_LOCAL}/bin:${PATH}
ebrp=${EASYBUILD_LOCAL}/easybuild/easyconfigs
ebrp=${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs/easybuild/easyconfigs:${ebrp}
ebrp=${solps_top}/easyconfigs.local:${ebrp}
export EASYBUILD_ROBOT_PATHS=${ebrp}

if ! test -d ${EASYBUILD_LOCAL}/imas-installer ; then # Install local EasyBuild
        rm -rf ${EASYBUILD_LOCAL}
        python3 -m venv ${EASYBUILD_LOCAL}
        ${EASYBUILD_LOCAL}/bin/python -m pip install --upgrade pip wheel
        ${EASYBUILD_LOCAL}/bin/python -m pip install setuptools grip \
                keyring GitPython keyrings.alt easybuild
        git clone ssh://git@git.iter.org/imex/easybuild-easyconfigs.git \
            -b develop ${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs
        git clone ssh://git@git.iter.org/imex/easybuild-easyconfigs.git \
            -b SOLPS-ITER ${solps_top}/easyconfigs.local
        git clone ssh://git@git.iter.org/imas/installer.git \
                ${EASYBUILD_LOCAL}/imas-installer
fi


# Listed in SETUP/setup.csh.ITER.gfortran
SOLPS_ITER_FOSS_2023b_MODULES="
	gnuplot/5.4.8-GCCcore-12.3.0
	xarray/2024.5.0-gfbf-2023b --from-ITER-SDCC
	makedepend/1.0.9-GCCcore-13.2.0
	MSCL/1.2.4-GCCcore-13.2.0
	GR/0.0.94-GCCcore-13.2.0 --from-ITER-SDCC
	GLI/4.5.31-GCCcore-13.2.0 --from-ITER-SDCC
	g2clib/1.9.0-GCCcore-13.2.0 --from-ITER-SDCC
	NCL/6.6.2-foss-2023b --from-ITER-SDCC
	flex/2.6.4-GCCcore-13.2.0
	Doxygen/1.9.8-GCCcore-13.2.0
	netCDF/4.9.2-gompi-2023b
	netCDF-Fortran/4.6.1-gompi-2023b --filter-env-vars=CPATH
	Ghostscript/10.02.1-GCCcore-13.2.0
	CMake/3.27.6-GCCcore-13.2.0
	ParaView/5.12.0-foss-2023b-Qt5
	Qt5/5.15.13-GCCcore-13.2.0
	netcdf4-python/1.6.5-foss-2023b
	motif/2.3.8-GCCcore-13.2.0 --from-ITER-SDCC
	texlive/20230313-GCC-13.2.0
	SimDB/0.11.0-gfbf-2023b --ignore-checksums
	json-fortran/8.5.2-GCC-13.2.0 --filter-env-vars=CPATH
	Data-Dictionary/${TAG_DD}-GCCcore-13.2.0 --from-ITER-SDCC
	MDSplus/7.132.0-GCCcore-13.2.0 --from-ITER-SDCC
	UDA/2.8.0-GCC-13.2.0 --from-pr=19765 --ignore-checksums
        cython-cmake/0.2.0-GCCcore-13.2.0 --from-ITER-SDCC
	IMAS-AL-MDSplus-models/5.2.2-foss-2023b-DD-${TAG_DD} --from-ITER-SDCC
	IMAS-AL-Core/5.4.2-foss-2023b --from-ITER-SDCC
	IMAS-AL-Fortran/${TAG_AL}-foss-2023b-DD-${TAG_DD} --from-ITER-SDCC
	IMAS-AL-Python/${TAG_AL}-foss-2023b-DD-${TAG_DD} --from-ITER-SDCC
	IDStools/2.0.0-gfbf-2023b --ignore-checksums
	GGD/1.13.0-foss-2023b-DD-${TAG_DD} --filter-env-vars=CPATH
	GTS/0.7.6-GCCcore-13.2.0 --from-ITER-SDCC
	Graphviz/9.0.0-GCCcore-13.2.0 --from-ITER-SDCC
	AMNS/1.6.0-foss-2023b-DD-${TAG_DD} --filter-env-vars=CPATH
	build/1.0.3-GCCcore-13.2.0 --from-ITER-SDCC
	PySide6/6.6.2-GCCcore-13.2.0 --from-ITER-SDCC
	GR/0.73.6-GCCcore-13.2.0 --from-ITER-SDCC
	PyOpenGL/3.1.7-GCCcore-13.2.0 --from-ITER-SDCC
	PyQtGraph/0.13.7-foss-2023b --from-ITER-SDCC
	Viz/2.8.0-foss-2023b
	astropy/6.1.0-gfbf-2023b --from-ITER-SDCC
	ToFu/1.7.9-gfbf-2023b --from-pr=20999
        "

# Listed in SETUP/setup.csh.ITER.ifort64
SOLPS_ITER_INTEL_2023b_MODULES="
	intel-compilers/2023.2.1 --accept-eula-for=Intel-oneAPI
  	imkl/2023.2.0 --accept-eula-for=Intel-oneAPI
	impi/2021.10.0-intel-compilers-2023.2.1 --accept-eula-for=Intel-oneAPI
	iimpi/2023b --accept-eula-for=Intel-oneAPI
	CMake/3.27.6-GCCcore-13.2.0
	SciPy-bundle/2023.12-iimkl-2023b --from-pr=20262
	xarray/2024.5.0-iimkl-2023b --from-ITER-SDCC
	makedepend/1.0.9-GCCcore-13.2.0
	ESMF/8.6.1-intel-2023b --from-ITER-SDCC --optarch=GENERIC
	GEOS/3.12.1-intel-compilers-2023.2.1 --from-ITER-SDCC --optarch=GENERIC
	GSL/2.7-intel-compilers-2023.2.1 --from-ITER-SDCC --optarch=GENERIC
	Boost/1.83.0-intel-compilers-2023.2.1 --from-ITER-SDCC
	HDF5/1.14.3-iimpi-2023b --from-ITER-SDCC --optarch=GENERIC
	arpack-ng/3.9.0-intel-2023b --from-ITER-SDCC
	Armadillo/12.8.0-intel-2023b  --from-ITER-SDCC
	MSCL/1.2.4-iimkl-2023b --from-ITER-SDCC
	GR/0.0.94-GCCcore-13.2.0 --from-ITER-SDCC
	GLI/4.5.31-GCCcore-13.2.0
	GDAL/3.9.0-intel-2023b --from-ITER-SDCC
	NCL/6.6.2-intel-2023b --from-ITER-SDCC --include-easyblocks-from-pr=3409 --optarch=GENERIC
	netCDF/4.9.2-iimpi-2023b
	netCDF-Fortran/4.6.1-iimpi-2023b --filter-env-vars=CPATH
	Ghostscript/10.02.1-GCCcore-13.2.0
	Doxygen/1.9.8-GCCcore-13.2.0
	Qt5/5.15.13-GCCcore-13.2.0
	motif/2.3.8-GCCcore-13.2.0
	texlive/20230313-intel-compilers-2023.2.1  --from-pr=20701 --optarch=GENERIC
	libtirpc/1.3.4-GCCcore-13.2.0
	SimDB/0.11.0-iimkl-2023b --ignore-checksums
	matplotlib/3.8.2-iimkl-2023b --from-ITER-SDCC --optarch=GENERIC
	astropy/6.1.0-iimkl-2023b --from-ITER-SDCC --optarch=GENERIC
	ToFu/1.7.9-iimkl-2023b --from-pr=20999
	mpi4py/3.1.5-iimpi-2023b --from-ITER-SDCC
	netcdf4-python/1.6.5-intel-2023b --from-ITER-SDCC
	json-fortran/8.5.2-intel-compilers-2023.2.1 --filter-env-vars=CPATH
	UDA/2.8.0-intel-compilers-2023.2.1 --from-ITER-SDCC
	IMAS-AL-Fortran/${TAG_AL}-intel-2023b-DD-${TAG_DD}
	IMAS-AL-Python/${TAG_AL}-intel-2023b-DD-${TAG_DD}
	IDStools/2.0.0-iimkl-2023b --ignore-checksums
	GGD/1.13.0-intel-2023b-DD-${TAG_DD} --filter-env-vars=CPATH
	AMNS/1.6.0-intel-2023b-DD-${TAG_DD} --filter-env-vars=CPATH
	PyQtGraph/0.13.7-intel-2023b --from-ITER-SDCC
	Viz/2.8.0-intel-2023b
	PySide6/6.6.2-GCCcore-13.2.0 --from-ITER-SDCC
	GR/0.73.6-GCCcore-13.2.0 --from-ITER-SDCC
        "
  
# Listed in imas-installer/site-config/Makefile.ITER.HPC.foss-2020b
# with addition to Saxon, NVHPC modules required to build IMAS
IMAS_FOSS_2020b_MODULES="
        Doxygen/1.8.20-GCCcore-10.2.0
        texlive/20210216-GCCcore-10.2.0
        Java/11.0.2
        ant/1.10.8-Java-11
        GCC/10.2.0
        Blitz++/1.0.2-GCCcore-10.2.0
        libMemcached/1.0.18-GCCcore-10.2.0
        Python/3.8.6-GCCcore-10.2.0
        PyAL/1.4.1-GCCcore-10.2.0
        PyYAML/5.3.1-GCCcore-10.2.0
        MDSplus-Java/7.96.17-GCCcore-10.2.0-Java-11
        UDA/2.7.1-GCCcore-10.2.0
        foss/2020b
        SciPy-bundle/2020.11-foss-2020b
        matplotlib/3.3.3-foss-2020b
        IDStools/1.14.1-foss-2020b
        PyHDC/0.17.3-foss-2020b
        HDF5/1.10.7-gompi-2020b
        NAGfor/6.2.14
        Saxon-HE/10.3-Java-11
        libtirpc/1.3.1-GCCcore-10.2.0
        "
#        NVHPC/21.2
#        MDSplus/7.96.17-GCCcore-10.2.0

# Listed in imas-installer/site-config/Makefile.ITER.HPC.intel-2020b
# MDSplus must be with Java
IMAS_INTEL_2020b_MODULES="
     Doxygen/1.8.20-GCCcore-10.2.0
     texlive/20210216-GCCcore-10.2.0
     Java/11.0.2
     ant/1.10.8-Java-11
     GCC/10.2.0
     Blitz++/1.0.2-GCCcore-10.2.0
     libMemcached/1.0.18-GCCcore-10.2.0
     Python/3.8.6-GCCcore-10.2.0
     PyAL/1.4.1-GCCcore-10.2.0
     PyYAML/5.3.1-GCCcore-10.2.0
     MDSplus-Java/7.96.17-GCCcore-10.2.0-Java-11
     UDA/2.7.1-GCCcore-10.2.0
     intel/2020b
     SciPy-bundle/2020.11-intel-2020b
     matplotlib/3.3.3-intel-2020b
     IDStools/1.10.0-intel-2020b
     PyHDC/0.17.3-intel-2020b
     HDF5/1.10.7-iimpi-2020b
     NVHPC/21.2
     NAGfor/6.2.14
     Saxon-HE/10.3-Java-11
     libtirpc/1.3.1-GCCcore-10.2.0
     "

# IMAS modules are built separately and listed here for check only
IMAS_2020b_APPLICATIONS="
    IMAS/${TAG_DD}-${TAG_AL}-2020b
    AMNS/1.5.0-GCC-10.2.0-DD-${TAG_DD}
    GGD/1.11.0-GCC-10.2.0-DD-${TAG_DD}
    Viz/2.8.0-foss-2020b
    SimDB/0.7.1-foss-2020b
    IMAS/${TAG_DD}-${TAG_AL}-2020b
    GGD/1.11.0-iccifort-2020.4.304-DD-${TAG_DD}
    AMNS/1.5.0-iccifort-2020.4.304-DD-${TAG_DD}
    Viz/2.8.0-intel-2020b
    SimDB/0.7.1-intel-2020b
    "

# Creating authentication for download from http://git.iter.org/
if [ -n "${HTTP_AUTH_BEARER}" ]; then
    echo "iter.org::Authorization: Bearer ${HTTP_AUTH_BEARER}" \
         > ${EASYBUILD_LOCAL}/http-headers.txt
    chmod 600 ${EASYBUILD_LOCAL}/http-headers.txt
fi
if [ -r ${EASYBUILD_LOCAL}/http-headers.txt ]; then
    eb_auth="--http-header-fields-urlpat=${EASYBUILD_LOCAL}/http-headers.txt"
else  cat <<EOF
Warning: No HTTP_AUTH_BEARER
Use https://git.iter.org/plugins/servlet/access-tokens/manage to create
Personal access token aka Bearer password and export it in the command line.
EOF
fi

function fetch_from_iter_cluster()
{
    ITER_USERNAME=${ITER_USERNAME:-${USER}}
    site=${ITER_USERNAME}@sdcc-login02
    target=easyconfigs.local
    iter_ebprefix=/work/imas/opt/EasyBuild
    proxy='-o StrictHostKeyChecking=no -o "ProxyCommand ssh '
    proxy=${proxy}${ITER_USERNAME}'@gpc-access.iter.org -W %h:%p"'

    for arg in $*
    do module=${arg%%,}
       echo "Fetching EasyBuild files and sources for ${module}"
       name=$(echo ${module}|sed 's,/.*,,')
       subdir=$(echo ${name}|cut -c1|tr '[:upper:]' '[:lower:]')
       ebname=$(echo ${module}.[eb|sed s,/,-,)
       ebdir=${iter_ebprefix}/software/${module}/easybuild
       mkdir -p ${target}/${subdir}/${name}
       cmd="scp -r ${proxy} ${site}:${ebdir}/*.[pe][ba]* ${target}/${subdir}/${name}"
       #echo $subdir/$name $module $ebname $cmd
       /bin/sh -c "${cmd} || echo Failed command ${cmd}"
       sources=${EASYBUILD_PREFIX}/sources/${subdir}/${name}
       mkdir -p ${sources}
       cmd="scp -r ${proxy} ${site}:${iter_ebprefix}/sources/${subdir}/${name}/* ${sources}"
       /bin/sh -c "${cmd} || echo Failed command ${cmd}"
    done
}

function build_imas() {
    echo "Building IMAS $*"
    module list
    set -x
    cd ${EASYBUILD_LOCAL}/imas-installer
    export IMAS_HOME=${EASYBUILD_PREFIX}/imas
    export INSTALL_MOD_DIR=${EASYBUILD_PREFIX}/modules/all
    test -d ${IMAS_HOME}/core/IMAS/${TAG_DD}-${TAG_AL}/models && \
        chmod -R +w ${IMAS_HOME}/core/IMAS/${TAG_DD}-${TAG_AL}*/models
    make IMAS_NAGFOR=no IMAS_HDC=no IMAS_MEX=no IMAS_PGI=no IMAS_JAVA=no $*
}

function add_imas_lite() { # IMAS without matplotlib as a dependency
    v=${TAG_DD}-${TAG_AL}-${1}
    mf=${MODULEPATH}/IMAS/${v}
    if test -f ${mf}; then
        sed -e /matplotlib/d ${mf} > ${mf}-lite
        ln -sf ${v} ${EASYBUILD_PREFIX}/imas/core/IMAS/${v}-lite
    fi
}

function build_modules () {
    for m in $*; do       
        if test -f ${EASYBUILD_PREFIX}/modules/all/${m}
        then echo -e "\e[32mModule ${m} exists. Skipping build.\e[m"
        else echo -e "\e[34mBuilding required SOLPS-ITER module ${m}$ec\e[m"
             em=$(echo ${m}.eb | tr / -)
             eb --robot ${eb_auth} ${em}
        fi
    done
}

case "${1##--}" in
    "") # No argument given. Build all gfortran
        build_modules ${SOLPS_ITER_FOSS_2020b_MODULES} ${IMAS_FOSS_2020b_MODULES}
        ;;
    intel)
        shift
        build_modules ${SOLPS_ITER_INTEL_2020b_MODULES} ${IMAS_INTEL_2020b_MODULES}
        ;;
    imas-foss)
        shift
        module load ${IMAS_FOSS_2020b_MODULES}
        export IMAS_CONFIG_FILE=site-config/Makefile.ITER.HPC.foss-2020b
        build_imas IMAS_IFORT=no TAG_DD=${TAG_DD} TAG_AL=${TAG_AL} $*
        add_imas_lite foss-2020b
        ;;
    imas-intel)
        shift
        module load ${IMAS_INTEL_2020b_MODULES}
        export IMAS_CONFIG_FILE=site-config/Makefile.ITER.HPC.intel-2020b
        build_imas TAG_DD=${TAG_DD} TAG_AL=${TAG_AL} $*
        add_imas_lite intel-2020b
        ;;
    imas)
        shift
        module load ${IMAS_INTEL_2020b_MODULES}
        export IMAS_CONFIG_FILE=site-config/Makefile.ITER.HPC.CentOS-8
        build_imas TAG_DD=${TAG_DD} TAG_AL=${TAG_AL} $*
        add_imas_lite 2020b
        ;;    
    imas-apps)
        build_modules ${IMAS_2020b_APPLICATIONS}
        ;;
    pull)
        set -x
        ${EASYBUILD_LOCAL}/bin/python -m pip install --upgrade pip easybuild
        cd ${solps_top}/easyconfigs.local && git pull --autostash
        cd ${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs && git pull
        cd ${EASYBUILD_LOCAL}/imas-installer && git pull && make cache
        ;;
    patch-imas-modules)
        sed -i -e /CPATH/d ${MODULEPATH}/GGD/*
        sed -i -e /CPATH/d ${MODULEPATH}/AMNS/*
        ;;
    help)
        help | grip --title="EasyBuild for SOLPS-ITER modules" \
                    --export -> ${EASYBUILD_LOCAL}/README.html
        2>/dev/null xdg-open ${EASYBUILD_LOCAL}/README.html  &
        eb --help
        help
        echo "Help in HTML is available as ${EASYBUILD_LOCAL}/README.html"
        ;;
    *) eb ${eb_auth} "$@"
esac
