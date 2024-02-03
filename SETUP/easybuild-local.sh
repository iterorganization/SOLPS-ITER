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
repositories. The only requirement for this script is recent version
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

Note that above minimal example requires Python 3.8+, `lmod`, and
`ksh` to be installed on the system and functional. The rest is
installed by the script under the `easybuild.local` directory or
elsewhere if desired.

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
    SETUP/easybuild-local.sh GGD-1.10.4-GCC-10.2.0-DD-3.38.1.eb
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
    SETUP/easybuild-local.sh --imas-foss install
    SETUP/easybuild-local.sh --imas-intel install
    SETUP/easybuild-local.sh --imas install
    SETUP/easybuild-local.sh --imas-apps
    SETUP/easybuild-local.sh --patch-imas-modules

## Package notes


### OpenSSL

Qt5 and Qt6 should have OpenSSL version 1.1.1 installed on the system
and not by the EasyBuild module. This resolves problems when compiling
ParaView and PySide6 (shiboken6) since system /lib64 might be in place
of OpenSSL module and symbol incompatibility.

### ParaView

Building ParaView can run out of memory or crashes on some machines
and for that use lower threads or even `--parallel 1` for serial build.

### IMAS

IMAS installer is needed to build IMAS modules. There is no EasyBuild
for IMAS! After IMAS is built AMNS, GGD, and Viz can be built. Note
that by default IMAS module name assumes "some" compilers without
having toolchain in its name. For example `IMAS/3.40.1-4.11.9-2020b`
module may or may not contain `ifort` modules. This means that
`--imas-foss` will build only *foss* FORTRAN modules, while
`--imas-intel` will build only *intel* FORTRAN modules.
`--imas` will build all compiler versions and is usually used by 
`setup.csh.ITER.ifort64` and some `--imas-apps`. So, in principle 
all 3 IMAS variants needs to be built. For 'foss-only' IMAS apps some
prerequisites will need to be adapted to exclude INTEL dependencies.

### AMNS, GGD, Viz

AMNS requires system to having latexmk package installed on the system.

Dependency to IMAS for AMNS, GGD and VIZ needs to be updated with

    ('IMAS/3.40.1-4.11.9-2020b', EXTERNAL_MODULE),

GGD and AMNS modules must not have CPATH otherwise `pkg-config ggd
amns --cflags` will not have GGD include path

    sed -i -e /CPATH/d easybuild.local/modules/*/GGD/* 
    sed -i -e /CPATH/d easybuild.local/modules/*/AMNS/*

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
from *UL* can be used as template by using short `hostname` as local
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

### AMD compute cluster with Lustre 2.14

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

System python version 3.6.8 is too old and causes "permission denied"
when copytree in vityual environment Python is running. Newer version
through modules works. However, Easybuild refuses build module if the
same module is already loaded! We overcome this initilal problem by
firstly installing everything and then hiding loaded Python with

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
GPFS. One NumPy test out of 20000 fails in SciPy-bundle.

Qt5 and PyQt5 fails to build with QtWebEngine and should be disabled.
 
Since tcsh, spawning bash in this shell. fails to inherit module
command add the following function to this script

    module ()
    {
        eval `/usr/bin/modulecmd bash $*`
    }


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
   easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-10.2.0.eb
SETUP/easybuild-local.sh SciPy-bundle-2020.11-intel-2020b.eb  --skip-test-step
sed -i -e s/ENABLE_JAVA=ON/ENABLE_JAVA=OFF/ \
    easyconfigs.local/h/HDC/HDC-0.17.3-GCCcore-10.2.0-Java-11.eb
SETUP/easybuild-local.sh ParaView-5.10.0-intel-2020b-mpi.eb --parallel 16
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
TAG_AL=${TAG_AL:-4.11.9}

setup=${solps_top}/SETUP/setup-easybuild.local && test -f ${setup} && . ${setup}
    
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
SOLPS_ITER_FOSS_2020b_MODULES="
        CMake/3.20.1-GCCcore-10.2.0
        xarray/0.16.2-foss-2020b
        makedepend/1.0.6-GCCcore-10.2.0
        MSCL/1.2.3-GCCcore-10.2.0
        GR/0.0.94-GCCcore-10.2.0
        GLI/4.5.31-GCCcore-10.2.0
        NCL/6.6.2-foss-2020b
        NAG/26-GCC-10.2.0
        Ghostscript/9.53.3-GCCcore-10.2.0
        Doxygen/1.8.20-GCCcore-10.2.0
        ParaView/5.10.0-foss-2020b-mpi
        PyQt5/5.15.1-GCCcore-10.2.0
        motif/2.3.8-GCCcore-10.2.0
        gnuplot/5.4.1-GCCcore-10.2.0
        texlive/20210216-GCCcore-10.2.0
        libtirpc/1.3.1-GCCcore-10.2.0
        SimDB/0.7.1-foss-2020b
        Fundamental-Constants/0.1.1
        ToFu/1.5.1-foss-2020b
        netCDF-Fortran/4.5.3-gompi-2020b
        netcdf4-python/1.5.5.1-foss-2020b
        flex/2.6.4-GCCcore-10.2.0
        "

# Listed in SETUP/setup.csh.ITER.ifort64
SOLPS_ITER_INTEL_2020b_MODULES="
        CMake/3.20.1-GCCcore-10.2.0
        xarray/0.16.2-intel-2020b
        makedepend/1.0.6-GCCcore-10.2.0
        MSCL/1.2.2-intel-2020b
        GR/0.0.94-GCCcore-10.2.0
        GLI/4.5.31-GCCcore-10.2.0
        NCL/6.6.2-intel-2020b
        NAG/26-intel-2020b
        Ghostscript/9.53.3-GCCcore-10.2.0
        Doxygen/1.8.20-GCCcore-10.2.0
        ParaView/5.10.0-intel-2020b-mpi
        PyQt5/5.15.2-GCCcore-10.2.0
        motif/2.3.8-intel-2020b
        gnuplot/5.4.1-GCCcore-10.2.0
        texlive/20210216-GCCcore-10.2.0
        libtirpc/1.3.1-GCCcore-10.2.0
        SimDB/0.7.1-intel-2020b
        Fundamental-Constants/0.1.1
        ToFu/1.5.1-intel-2020b
        netcdf4-python/1.5.5.1-intel-2020b
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
    AMNS/1.4.0-foss-2020b-DD-${TAG_DD}
    GGD/1.10.4-GCC-10.2.0-DD-${TAG_DD}
    Viz/2.8.0-foss-2020b
    SimDB/0.7.1-foss-2020b
    IMAS/${TAG_DD}-${TAG_AL}-2020b
    GGD/1.10.4-intel-2020b-DD-${TAG_DD}
    AMNS/1.4.0-intel-2020b-DD-${TAG_DD}
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

#module () 
#{ 
#    eval `/usr/bin/modulecmd bash $*` 
#}

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
