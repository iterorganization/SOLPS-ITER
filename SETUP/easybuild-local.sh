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

Essentially, this script extends functionality of the
[EasyBuild](http://easybuild.readthedocs.org/) tool by adding search
paths to ITER-specific easyconfigs (`.eb`) for sources from ITER Git
repositories. 

The only requirement for this script is recent version
of Python 3 and modulesfiles or lmod support. The rest is being
downloaded from internet and ITER Git website. Quick start for
building may be by creating Personal Access Token from
https://git.iter.org/plugins/servlet/access-tokens/manage and entering

~~~ bash
    export ITER_USERNAME=myusernameatiter # Replace
    export HTTP_AUTH_BEARER="ReplaceWithPersonalAccessToken"
    ssh-copy-id ${ITER_USERNAME}@gpc-access.iter.org
    SETUP/easybuild-local.sh --help | more
    SETUP/easybuild-local.sh
~~~

Some unpublished EasyBuild files are only available at ITER SDCC cluster
or are still unmerged under pull request at 
[EasyBuild Pull requests](https://github.com/easybuilders/easybuild-framework/pulls).
To facilitate easy copy of such recipes for selected modules from 
SDCC `--fetch module(s)` functionality is provided.
In order for fetch to work a local SSH key needs to be copied to ITER cluster with
`ssh-copy-id`.

Note that above minimal example requires Python 3.8+, `lmod`, `tcsh` and
`ksh` to be installed on the system and functional. The rest is
installed by the script under the `easybuild.local` directory or
elsewhere if desired.

Lmod and Lua are default and recommended way to handle modules.
You may need to export `EASYBUILD_MODULES_TOOL` and 
`EASYBUILD_MODULE_SYNTAX` environment variable to match you cluster
environment.

Some knowledge of EasyBuild is needed to resolve possible compile
problems. The script will need to be run several times with different
arguments on the machine where local modules are being built. It may
take a day to build everything from scratch. Script without arguments
will by default build all foss modules and if fails it can be
restarted until all modules are listed in green.

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


For a large software distribution such as SOLPS-ITER it is important
that all modules use the same parent modules. For example Qt and PySide
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

before running this script. Otherwise, modules will be installed under
`easybuild.local/software` and `easybuild.local/modules/all`.

To use such build modules use

    module use ${PWD}/easybuild.local/modules/all

### Site specific configuration

Instead of exporting environment variables one can save site-specific
configuration under `SETUP/setup.easybuild.local` that is sourced
if exists. For example:

    export EASYBUILD_PREFIX=/opt/pkg/ITER
    export EASYBUILD_MODULES_TOOL=Lmod
    export HTTP_AUTH_BEARER=MTk1ODA1MzE1MTI3OoHVFKMpL/kn8BQKWBiLFNfrCTrU
    export EASYBUILD_BUILDPATH=/dev/shm/
    export ITER_USERNAME=kosl
    module purge
    module load AlmaLinux/profile  python-3.8.12-gcc-8.5.0-bvu5tg4

### SOLPS-ITER gfortran modules

Follow success of each step below and adapt `.eb` files as necessary
by putting them into easyconfigs.local

    SETUP/easybuild-local.sh --help | less
    SETUP/easybuild-local.sh # defaults to foss modules
    SETUP/easybuild-local.sh Viz-2.8.0-foss-2023b.eb --robot


### SOLPS-ITER ifort64 modules

Building INTEL modules assumes that EULA license is accepted.
INTEL IMAS is being built with

    SETUP/easybuild-local.sh --intel

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
      OpenMPI-4.1.6-GCC-13.2.0.eb

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
    SETUP/easybuild-local.sh --patch-imas-modules

## Package notes

### Invalid source checksums

Often there are some checksum problems at ITER easyconfigs due to
improper source tag specifications. To remedy this situation a quick
refresh can be used after config and source files fetched:

   SETUP/easybuild-local.sh SimDB-0.11.0-gfbf-2023b.eb --inject-checksums
   SETUP/easybuild-local.sh SimDB-0.11.0-gfbf-2023b.eb
   SETUP/easybuild-local.sh UDA-2.7.5-GCC-13.2.0.eb --inject-checksums --force 
   SETUP/easybuild-local.sh UDA-2.7.5-GCC-13.2.0.eb

### MSCL,ESMF,GSL,... on cluster with AMD processors and Intel toolchain

Due to Intel libries dependent packages requires disabled architecture
optimisation flags with

   SETUP/easybuild-local.sh MSCL-1.2.4-iimkl-2023b.eb --optarch=GENERIC
   SETUP/easybuild-local.sh ESMF-8.6.1-intel-2023b.eb --optarch=GENERIC --robot
   SETUP/easybuild-local.sh GSL-2.7-intel-compilers-2023.2.1.eb --optarch=GENERIC
   
### OpenSSL

Qt5 and Qt6 should have OpenSSL version 1.1.1 installed on the system
and not by the EasyBuild module. This resolves problems when compiling
ParaView and PySide6 (shiboken6) since system /lib64 might be in place
of OpenSSL module and symbol incompatibility.

### ParaView

Building ParaView can run out of memory or crashes on some machines
and for that use lower threads or even `--parallel 1` for serial build.

### AMNS, GGD, Viz

AMNS requires system to having latexmk package installed on the system.

Dependency to IMAS for AMNS, GGD and VIZ needs to be updated with

    ('IMAS/3.40.1-4.11.9-2023b', EXTERNAL_MODULE),

If IMAS-AL MATLAB is not required it can be removed from AMNS with 
~~~ diff
diff --git a/easybuild/easyconfigs/a/AMNS/AMNS-1.5.1-foss-2023b-DD-3.42.0.eb b/easybuild/easyconfigs/a/AMNS/AMNS-1.5.1-foss-2023b-DD-3.42.0.eb
index 9ebb3bc..0a64acd 100644
--- a/easybuild/easyconfigs/a/AMNS/AMNS-1.5.1-foss-2023b-DD-3.42.0.eb
+++ b/easybuild/easyconfigs/a/AMNS/AMNS-1.5.1-foss-2023b-DD-3.42.0.eb
@@ -31,7 +31,7 @@ builddependencies = [
     ('IMAS-AL-Fortran', '5.3.0', versionsuffix),
     ('IMAS-AL-Java', '5.3.0', versionsuffix),
     ('IMAS-AL-Python', '5.3.0', versionsuffix),
-    ('IMAS-AL-Matlab', '5.3.0', versionsuffix),
+#    ('IMAS-AL-Matlab', '5.3.0', versionsuffix),
 ]
~~~

GGD and AMNS modules must not have CPATH otherwise `pkg-config ggd
amns --cflags` will not have GGD include path

    sed -i -e /CPATH/d easybuild.local/modules/*/GGD/* 
    sed -i -e /CPATH/d easybuild.local/modules/*/AMNS/*

or 

    sed -i -e /CPATH/d ${EASYBUILD_PREFIX}/modules/*/GGD/* 
    sed -i -e /CPATH/d ${EASYBUILD_PREFIX}/modules/*/AMNS/*


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
cp easybuild.local/easybuild/easyconfigs/p/PyQt5/PyQt5-5.15.2-GCCcore-13.2.0.eb  easyconfigs.local/p/PyQt5/
sed -i -e s/--no-designer-plugin// easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-13.2.0.eb
vi easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-13.2.0.eb # to Qt/5.15.2
SETUP/easybuild-local.sh PyQt5-5.15.2-GCCcore-13.2.0.eb --force

# INTEL toolchain
SETUP/easybuild-local.sh SciPy-bundle-2020.11-intel-2023b.eb --skip-test-step
~~~

Note that there can be only slight version differences bewteen Qt5 and PyQt5.


#### Changing Qt5 version in gnuplot

     mkdir -p easyconfigs.local/g/gnuplot
     cp easybuild.local/easybuild/easyconfigs/g/gnuplot/gnuplot-5.4.1-GCCcore-13.2.0.eb easyconfigs.local/g/gnuplot/
     sed -i -e /Qt5/s/5.14.2/5.15.2/ easyconfigs.local/g/gnuplot/gnuplot-5.4.1-GCCcore-13.2.0.eb
     SETUP/easybuild-local.sh gnuplot-5.4.1-GCCcore-13.2.0.eb --force

#### HDF5-1.10.7-iimpi-2023b.eb used by netCDF-4.7.4-iimpi-2023b.eb

AMD processors fail building numpy as part of SciPy-bundle. Numpy
fails on AMD processors due to disabled SSE message. With added extra
toolchain fortran AVX options

     toolchainopts = {'pic': True, 'usempi': True, 'extra_fcflags': '-march=core-avx2'}

### ITER SDCC cluster with RHEL9

OpenMPI with Slurm and PMI requires rebuild for dependent packages
such as NetCDF, HDF5, ... 


    SETUP/easybuild-local.sh --force --skip-test-step \
      --try-amend="configopts=--with-slurm --with-pmi" \
      OpenMPI-4.1.6-GCC-13.2.0.eb


Several processor generations in compute nodes (gen9, gen10, gen11)
exists and for building the oldest (gen9) should be in order to run
modules on all nodes without crashes due to binary incompatibility.

ITER Organization is using "Forward Trust SSL Proxy" and `--help` does
not work due to intermediate self-signed certificate. To overcome this
issue we need to download intermediate CA certificates and append them
to existing Python CA certificates trust with

    openssl s_client -showcerts -connect api.github.com:443 \
    | sed -n -e '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' \ 
    >> easybuild.local/lib/python3.*/site-packages/certifi/cacert.pem

This manual will then show correctly in local browser too

    SETUP/easybuild-local.sh  --help

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

    srun -N1 -n36 -p gen10 --pty bash -i

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
SETUP/easybuild-local.sh --help | less
sed -i -e "/configopts =/s|.*|= configopts = '--with-slurm --with-pmi=/opt/slurm/current --with-pmi-libdir=/opt/slurm/current/lib'|" \
 easyconfigs.local/o/OpenMPI/OpenMPI-4.1.2-GCC-13.2.0.eb
SETUP/easybuild-local.sh SciPy-bundle-2020.11-foss-2023b.eb --skip-test-step
SETUP/easybuild-local.sh NVHPC-21.2.eb --accept-eula-for=NVHPC --cuda-compute-capabilities=7.0
SETUP/easybuild-local.sh Qt6-6.2.3-GCCcore-13.2.0.eb --robot
~~~
Fix GGD and AMNS modules for CPATH. 


ParaView should be run with 

    /usr/NX/scripts/vgl/vglrun paraview 

### Marconi Fusion

CentOS Linux release 7.2 with Intel Xeon CPU E5-2697 v4 @ 2.30GHz
(skylake)

~~~ bash
export EASYBUILD_MODULES_TOOL=EnvironmentModules
SETUP/easybuild-local.sh SciPy-bundle-2020.11-foss-2023b.eb --skip-test-step
sed -i -e "/^configopts/s/'"'$'"/ -skip qtwebengine'/" \
  -e /check_qtwebengine/s/True/False/ \
  easyconfigs.local/q/Qt5/Qt5-5.15.2-GCCcore-13.2.0.eb
sed -i -e "/('PyQtWebEngine'/,/})/d" -e "/('Qt5Webkit'/d" \
   easyconfigs.local/p/PyQt5/PyQt5-5.15.2-GCCcore-13.2.0.eb
SETUP/easybuild-local.sh SciPy-bundle-2020.11-intel-2023b.eb  --skip-test-step
sed -i -e s/ENABLE_JAVA=ON/ENABLE_JAVA=OFF/ \
    easyconfigs.local/h/HDC/HDC-0.17.3-GCCcore-13.2.0-Java-11.eb
SETUP/easybuild-local.sh ParaView-5.10.0-intel-2023b-mpi.eb --parallel 16
~~~

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
  easyconfigs.local/o/OpenMPI/OpenMPI-4.1.2-GCC-13.2.0.eb
sed -i -e "/configopts/s/'$/ --enable-qt-help=no'/" \
  easybuild.local/easybuild/easyconfigs/d/DBus/DBus-1.13.18-GCCcore-13.2.0.eb
~~~

## Usage

~~~ 
SETUP/easybuild-local.sh [OPTION... | easybuild_command...]

  --help                prints and opens this manual, then EasyBuild help
  --intel               build INTEL toolchain and modules
  --pull                pulls Git repos for IMAS and updates EasyBuild configs
  --fetch module(s)	fetch EasyBuild files for listed modules from SDCC cluster
  --patch-imas-modules  fixes AMNS and GGD module by removing CPATH

ENVIRONMENT variables:

  TAG_DD                   IMAS data dictionary version
  TAG_AL                   IMAS access layer version
  EASYBUILD_PREFIX         Software installation directory prefix
  EASYBUILD_MODULES_TOOL   Modules tool (Lmod, EnvironmentModules)
  EASYBUILD_MODULE_SYNTAX  Tcl or Lua syntax for modulefiles generated
  HTTP_AUTH_BEARER         Personal token for downloading of ITER GIT sources
  ITER_USERNAME            Username at ITER SDCC cluster to be used for scp

Files:

  SETUP/setup.easybuild.local Site specific environment variables and modules

~~~
EOF
}
trap 'ec=$?; ((ec != 0)) && echo -e "\e[31mExited with failure: $ec\e[m"' EXIT 

solps_top=$(git rev-parse --show-toplevel)
EASYBUILD_LOCAL=${solps_top}/easybuild.local

TAG_DD=${TAG_DD:-3.42.0}
TAG_AL=${TAG_AL:-5.3.0}

setup=${solps_top}/SETUP/setup.easybuild.local && test -f ${setup} && . ${setup}
    
export EASYBUILD_PREFIX=${EASYBUILD_PREFIX:-${EASYBUILD_LOCAL}}
export MODULEPATH=${EASYBUILD_PREFIX}/modules/all
export EASYBUILD_GITHUB_USER=${EASYBUILD_GITHUB_USER:-${USER}}
export EASYBUILD_MODULES_TOOL=${EASYBUILD_MODULES_TOOL:-Lmod}
export EASYBUILD_MODULE_SYNTAX=${EASYBUILD_MODULE_SYNTAX:-Lua}
export EASYBUILD_ALLOW_MODULES_TOOL_MISMATCH=1
export PATH=${EASYBUILD_LOCAL}/bin:${PATH}
ebrp=${EASYBUILD_LOCAL}/easybuild/easyconfigs
ebrp=${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs/easybuild/easyconfigs:${ebrp}
ebrp=${solps_top}/easyconfigs.local:${ebrp}
export EASYBUILD_ROBOT_PATHS=${ebrp}

if ! test -d ${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs
   then # Install local EasyBuild
       rm -rf ${EASYBUILD_LOCAL}
       python3 -m venv ${EASYBUILD_LOCAL}
       ${EASYBUILD_LOCAL}/bin/python -m pip install --upgrade pip wheel
       ${EASYBUILD_LOCAL}/bin/python -m pip install setuptools grip \
                keyring GitPython keyrings.alt easybuild
       git clone ssh://git@git.iter.org/imex/easybuild-easyconfigs.git \
            -b develop ${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs
       test -d ${solps_top}/easyconfigs.local || \
	    git clone ssh://git@git.iter.org/imex/easybuild-easyconfigs.git \
		-b SOLPS-ITER ${solps_top}/easyconfigs.local
fi

#if ! command -v ksh 2>&1 >/dev/null
#then
#    echo "ksh (required by GR) could not be found! Install package."
#    exit 1
#fi
if ! command -v csh 2>&1 >/dev/null
then
    echo "csh (required by NCL and SOLPS) could not be found! Install tcsh."
    exit 1
fi


# Listed in SETUP/setup.csh.ITER.gfortran
SOLPS_ITER_FOSS_2023b_MODULES="
	xarray/2024.5.0-gfbf-2023b --from-ITER-cluster
	makedepend/1.0.9-GCCcore-13.2.0
	MSCL/1.2.4-GCCcore-13.2.0
	GR/0.0.94-GCCcore-13.2.0 --from-ITER-cluster
	GLI/4.5.31-GCCcore-13.2.0 --from-ITER-cluster
	NCL/6.6.2-foss-2023b --from-pr=20262 --from-pr=21176
	flex/2.6.4-GCCcore-13.2.0
	Doxygen/1.9.8-GCCcore-13.2.0
	netCDF/4.9.2-gompi-2023b
	netCDF-Fortran/4.6.1-gompi-2023b
	Ghostscript/10.02.1-GCCcore-13.2.0
	CMake/3.27.6-GCCcore-13.2.0
	ParaView/5.12.0-foss-2023b-Qt5
	Qt5/5.15.13-GCCcore-13.2.0
	netCDF-Fortran/4.6.1-gompi-2023b
	netcdf4-python/1.6.5-foss-2023b
	motif/2.3.8-GCCcore-13.2.0 --from-ITER-cluster
	texlive/20230313-GCC-13.2.0
	SimDB/0.11.0-gfbf-2023b
	json-fortran/8.5.2-GCC-13.2.0
	Data-Dictionary/${TAG_DD}-GCCcore-13.2.0 --from-ITER-cluster
	MDSplus/7.132.0-GCCcore-13.2.0 --from-ITER-cluster
	IMAS-AL-MDSplus-models/5.2.2-GCCcore-13.2.0-DD-${TAG_DD} --from-ITER-cluster
	cython-cmake/0.1.0-GCCcore-13.2.0 --from-ITER-cluster
       	UDA/2.7.5-GCC-13.2.0 --from-pr=19765 --ignore-checksums
	IMAS-AL-Fortran/${TAG_AL}-foss-2023b-DD-${TAG_DD} --from-ITER-cluster
	IMAS-AL-Python/${TAG_AL}-foss-2023b-DD-${TAG_DD} --from-ITER-cluster
	IDStools/2.0.0-gfbf-2023b
	GGD/1.12.0-foss-2023b-DD-${TAG_DD}
	GTS/0.7.6-GCCcore-13.2.0 --from-ITER-cluster # For graphviz
	Graphviz/9.0.0-GCCcore-13.2.0 --from-ITER-cluster 
	AMNS/1.5.1-foss-2023b-DD-${TAG_DD}
	build/1.0.3-GCCcore-13.2.0 --from-ITER-cluster 
	PySide6/6.6.2-GCCcore-13.2.0 --from-ITER-cluster
	PyOpenGL/3.1.7-GCCcore-13.2.0 --from-ITER-cluster
       	PyQtGraph/0.13.7-foss-2023b --from-ITER-cluster
	Viz/2.8.0-foss-2023b
	astropy/6.1.0-gfbf-2023b --from-ITER-cluster
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
	xarray/2024.5.0-iimkl-2023b --from-ITER-cluster
	makedepend/1.0.9-GCCcore-13.2.0
	ESMF/8.6.1-intel-2023b --from-ITER-cluster --optarch=GENERIC
	GEOS/3.12.1-intel-compilers-2023.2.1 --from-ITER-cluster --optarch=GENERIC 
	GSL/2.7-intel-compilers-2023.2.1 --from-ITER-cluster --optarch=GENERIC
	Boost/1.83.0-intel-compilers-2023.2.1 --from-ITER-cluster
	HDF5/1.14.4.3-iimpi-2023b --from-ITER-cluster --optarch=GENERIC
       	arpack-ng/3.9.0-intel-2023b --from-ITER-cluster
	Armadillo/12.8.0-intel-2023b  --from-ITER-cluster
	MSCL/1.2.4-iimkl-2023b --from-ITER-cluster
	GR/0.0.94-GCCcore-13.2.0
	GLI/4.5.31-GCCcore-13.2.0
	NCL/6.6.2-intel-2023b --from-pr=20262 --from-pr=21176 --optarch=GENERIC
	netCDF/4.9.2-iimpi-2023b
	netCDF-Fortran/4.6.1-iimpi-2023b
	NAG/26-intel-compilers-2023.2.1
	Ghostscript/10.02.1-GCCcore-13.2.0
	Doxygen/1.9.8-GCCcore-13.2.0
	Qt5/5.15.13-GCCcore-13.2.0
	motif/2.3.8-GCCcore-13.2.0
	texlive/20230313-intel-compilers-2023.2.1
	libtirpc/1.3.4-GCCcore-13.2.0
	SimDB/0.11.0-iimkl-2023b
	ToFu/1.7.9-iimkl-2023b
	netcdf4-python/1.6.5-intel-2023b
	json-fortran/8.5.2-intel-compilers-2023.2.1
  	IMAS-AL-Fortran/${TAG_AL}-intel-2023b-DD-${TAG_DD}
  	IMAS-AL-Python/${TAG_AL}-intel-2023b-DD-${TAG_DD}
  	IDStools/2.0.0-iimkl-2023b
  	GGD/1.12.0-intel-2023b-DD-${TAG_DD}
  	AMNS/1.5.1-intel-2023b-DD-${TAG_DD}
  	load Viz/2.8.0-intel-2023b
        "
#pr=20262 --from-pr=21176 --optarch=GENERIC

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
    echo "$@" | while read -r line  ; do
	module="${line%% *}"
	test -z "${module}" && continue # skip empty line
	optional_args=${line#* }
	if [ "${optional_args}" = "${module}" ]; then optional_args=""; fi
        if test -f ${EASYBUILD_PREFIX}/modules/all/${module}*
        then echo -e "\e[32mModule ${module} exists. Skipping build.\e[m"
        else echo -e "\e[34mBuilding required SOLPS-ITER module ${line}$ec\e[m"
	     if [[ "${optional_args}" == *"--from-ITER-cluster"* ]]
	     then fetch_from_iter_cluster ${module}
		  optional_args="${optional_args#*--from-ITER-cluster}"
	     fi
             easybuild_file=$(echo ${module}.eb | tr / -)
             eb --robot ${eb_auth} ${easybuild_file} ${optional_args}
        fi
    done
}

case "${1##--}" in
    "") # No argument given. Build all gfortran
        build_modules "${SOLPS_ITER_FOSS_2023b_MODULES}"
        ;;
    intel)
        shift
        build_modules "${SOLPS_ITER_INTEL_2023b_MODULES}"
        ;;
    pull)
        set -x
        ${EASYBUILD_LOCAL}/bin/python -m pip install --upgrade pip easybuild
        cd ${solps_top}/easyconfigs.local && git pull --autostash
        cd ${EASYBUILD_LOCAL}/imas-easybuild-easyconfigs && git pull
        ;;
    patch-imas-modules)
        sed -i -e /CPATH/d ${MODULEPATH}/GGD/*
        sed -i -e /CPATH/d ${MODULEPATH}/AMNS/*
        ;;
    fetch)
	shift
	fetch_from_iter_cluster $*
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
