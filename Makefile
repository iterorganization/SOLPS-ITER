# Test whether required environment variables are set
# If not, attempt to determine them automatically

UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
	MACOS := 1
else
	MACOS := 0
endif

# Identify HOST_NAME
ifndef HOST_NAME
	ifeq ($(MACOS),false)
	# Assuming to work on some HPC cluster
	  ifeq ($(shell [ -e whereami ] && echo yes || echo no ),yes)
	    # Identify host from whereami-script
	    HOST_NAME = $(shell echo `./whereami|tail -1`)
	    ifneq (,$(findstring UNKNOWN,${HOST_NAME}))
	      # If no specific host identified, use default settings
	      HOST_NAME = default
	    endif
	  else
	    # If whereami-script not found, use default settings
	    HOST_NAME = default
	  endif
	  export HOST_NAME
	  ifeq (${HOST_NAME},default)
	    $(warning HOST_NAME not recognized. Using ${HOST_NAME})
	  endif
	else
	# Using MacOS, so assuming to work on a local device
	# So far only the compilation of b25, eirene and b25eirene,
	# in both serial, mpi and openmpi mode, but without graphics,
	# has been tested as successful on MacOS
		 HOST_NAME = DARWIN
	endif
endif

# Identify compiler
ifndef COMPILER
  ifeq ($(shell [ -e default_compiler ] && echo yes || echo no ),yes)
    # Identify compiler from default_compiler-script
    COMPILER = $(shell echo `./default_compiler|tail -1`)
  else
    # If script not found, use default compiler ifort64
    COMPILER = ifort64
    $(warning Using default compiler ${COMPILER})
  endif
  export COMPILER
endif

# Set SOLPSTOP and SOLPSLIB if not already defined in the environment
export SOLPSTOP ?= ${PWD}
export SOLPSLIB ?= ${PWD}/lib/${HOST_NAME}.${COMPILER}

# Include compiler settings
MAKES = ${SOLPSTOP}/Makefile
ifeq ($(shell [ -e SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST_NAME}.${COMPILER}
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
else
  $(warning SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif
ifeq ($(shell [ -e SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
  include SETUP/config.common.${COMPILER}
  MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
endif

# Include local compiler settings, if present
ifeq ($(shell [ -e SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST_NAME}.${COMPILER}.local
  MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
endif
ifeq ($(shell [ -e SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif

MAKETAGS ?= ctags -e -f

# Setup debug flag
EXT_DBG =
ifdef SOLPS_DEBUG
EXT_DBG = .debug
OPT_DBG = -DTRACE=ON
endif

# Setup MPI flag
EXT_MPI =
MPI_OPTS = USE_MPI=-DUSE_MPI SOLPS_MPI=yes
ifdef SOLPS_MPI
EXT_MPI = .mpi
OPT_MPI = -DMPI=ON
else
OPT_MPI = -DMPI=OFF
endif

# Setup OpenMP flag
EXT_OPENMP =
ifdef SOLPS_OPENMP
EXT_OPENMP = .openmp
OPT_OPENMP = -DOPENMP=ON
endif
OMP_OPTB = USE_OPENMP=-D_OPENMP SOLPS_OPENMP=yes
OMP_OPTE = USE_OPENMP=-DUSE_OPENMP SOLPS_OPENMP=yes

OPT_NOX = LD_GR="" LD_GKS=""

TOOLSHORT = ${HOST_NAME}.${COMPILER}
TOOLCHAIN = ${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_DBG}

ifdef LD_NETCDF
B25_SERIAL = mods nc2text_simple nc_reduce
else
B25_SERIAL = mods
endif

DEFLIBS =
DEGLIBS = -DGRAPHICS=ON
ifdef LIBGRS
DEGLIBS += -DLibGRS=${LIBGRS}
endif
ifdef LIBGKS
DEGLIBS += -DLibGKS=${LIBGKS}
endif
ifdef LIBX11
DEGLIBS += -DLibX11=${LIBX11}
endif
ifdef LIBXT
DEGLIBS += -DLibXt=${LIBXT}
endif
ifdef LIBZ
DEGLIBS += -DLibz=${LIBZ}
endif
ifdef LIBJSON
DEFLIBS += -DLibJSON=${LIBJSON}
endif
ifdef MODJSON
DEFLIBS += -DJSON_MODULES=${MODJSON}
endif
ifdef ADDLIBS
DEGLIBS += -DADD_LIBS="${ADDLIBS}"
endif
DEFOPTS =
ifdef LINK_OPTS
DEFOPTS += -DLINK_OPTIONS=${LINK_OPTS}
endif
ifdef FFLAGSEXTRA
DEFOPTS += -DFLAGS_EXTRA="${FFLAGSEXTRA}"
endif
ifdef SOLPS_DEBUG
DEFOPTS += -DCMAKE_BUILD_TYPE=Debug
endif
DEFMAKES = -DMAKES="${MAKES}"

CPLOPTS  = -DB25_EIRENE=ON
DIMENSIONS = 0
ifeq ($(shell [ -s modules/B2.5/src/modules/b2mod_dimensions.F ] && echo yes || echo no ),yes)
DIMENSIONS = 1
CPLOPTS += -DDIMENSIONS_MODULE=yes
endif

ifeq ($(UNAME),Darwin)
	ifneq (,$(filter eirene%,$(MAKECMDGOALS)))
    # Automatically not use cmake only for compiling Eirene standalone (bug?)
    NO_CMAKE := 1
	endif
	ifneq (,$(filter triang%,$(MAKECMDGOALS)))
    # Same for triang, which requires eirene_nox
    NO_CMAKE := 1
	endif
endif

MAKEO = ${MAKE} ${MAKE_OPTIONS}
MAKEF = ${MAKEO} -f config/Makefile
ifndef NO_CMAKE
MAKEE = ${MAKEO}
else
MAKEE = ${MAKEF}
endif
ifeq (${DIMENSIONS},1)
MAKEE += DIMENSIONS_MODULE=yes
endif
ifdef NO_CMAKE
MAKEC = ${MAKEE}
MAKEX = ${MAKEE} ${OPT_NOX}
else
ifeq ($(MPI_PRESENT),1)
include ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.mk
endif
ifdef SOLPS_MPI
OPT_MPI += -DMPI_VERSION=${MPI_VERSION}
endif
CMAKE_STEM = cmake ../../src -DEIRENE_INTERFACE=SOLPS-ITER -DEIRENE_USER-ROUTINES=iter ${DEFLIBS} ${DEFOPTS} ${DEFMAKES}
MAKEC = ${CMAKE_STEM} ${DEGLIBS}
MAKEM = FC=${MPI_FC} ${MAKEC} -DMPI=ON -DMPI_VERSION=${MPI_VERSION}
MAKEN = ${MAKEC} -DMPI=OFF -DOPENMP=ON
MAKEP = ${MAKEM} -DOPENMP=ON
MAKEX = ${CMAKE_STEM} -DGRAPHICS=OFF -DLibGRS="" -DLibGKS=""
MAKEY = FC=${MPI_FC} ${MAKEX} -DMPI=ON -DMPI_VERSION=${MPI_VERSION}
MAKEZ = ${MAKEX} -DMPI=OFF -DOPENMP=ON
MAKEA = ${MAKEY} -DOPENMP=ON
endif

# SOLPS_DEBUG, SOLPS_OPENMP and SOLPS_MPI will not be taken from environment,
# but will be passed by the corresponding make-targets
unexport SOLPS_OPENMP
unexport SOLPS_DEBUG
unexport SOLPS_MPI

.PHONY: solps solps_openmp solps_mpi solps_openmp_mpi solps_mpi_openmp nox nox_openmp nox_mpi nox_openmp_mpi nox_mpi_openmp all all_openmp all_nox all_mpi all_openmp_mpi all_mpi_openmp all_nox_openmp all_nox_openmp_mpi all_nox_mpi_openmp all_nox_mpi carre carre_nox divgeo divgeo_nox b25 b25_openmp b25_mpi b25_openmp_mpi b25_mpi_openmp b25_nox b25_nox_openmp b25_nox_mpi b25_nox_openmp_mpi b25_nox_mpi_openmp b25_ig b25_all_mpi b25_all_openmp b25_all_openmp_mpi b25_all_mpi_openmp eirene eirene_mpi eirene_openmp eirene_openmp_mpi eirene_nox eirene_openmp_nox eirene_nox_mpi eirene_nox_openmp_mpi b25eirene b25eirene_openmp b25eirene_mpi b25eirene_openmp_mpi b25eirene_mpi_openmp b25eirene_nox b25eirene_nox_mpi b25eirene_ig b25eirene_all_mpi b25eirene_nox_mpi uinp uinp_nox uinp_openmp uinp_mpi uinp_openmp_mpi uinp_mpi_openmp uinp_nox_openmp uinp_nox_mpi uinp_nox_openmp_mpi uinp_nox_mpi_openmp triang triang_nox triang_mpi triang_nox_mpi amds amds_mpi amds_openmp amds_openmp_mpi fxdr sonnet-light nc2text_simple nc_reduce b2sxdr manual local depend depend_nox tags listobj listobj_nox clean clean_% debug %_debug VERSION help nox_build nox_build_mpi nox_build_openmp nox_build_openmp_mpi nox_build_mpi_openmp

DEFAULT: solps


# Basic compile targets
#----------------------


solps:       carre divgeo b25eirene     uinp     triang amds sonnet-light manual

solps_openmp: carre divgeo b25eirene_openmp uinp_openmp triang amds_openmp sonnet-light manual

solps_mpi:   carre divgeo b25eirene_mpi uinp_mpi triang_mpi amds_mpi sonnet-light manual

solps_openmp_mpi: carre divgeo b25eirene_openmp_mpi uinp_openmp_mpi triang_mpi amds_openmp_mpi sonnet-light manual

solps_mpi_openmp: solps_openmp_mpi

nox:         carre_nox divgeo_nox b25eirene_nox uinp_nox triang_nox manual

nox_openmp:  carre_nox divgeo_nox b25eirene_nox_openmp uinp_nox_openmp triang_nox manual

nox_mpi:     carre_nox divgeo_nox b25eirene_nox_mpi uinp_nox_mpi triang_nox_mpi manual

nox_openmp_mpi: carre_nox divgeo_nox b25eirene_nox_openmp_mpi uinp_nox_openmp_mpi triang_nox_mpi manual

nox_mpi_openmp: nox_openmp_mpi

all:         carre divgeo b25     eirene     b25eirene     uinp     triang amds sonnet-light manual

all_nox:     carre_nox divgeo_nox b25_nox eirene_nox b25eirene_nox uinp_nox triang_nox manual

all_openmp:  carre divgeo b25_openmp eirene_openmp b25eirene_openmp uinp_openmp triang amds_openmp sonnet-light manual

all_mpi:     carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp_mpi triang_mpi amds_mpi sonnet-light manual

all_nox_openmp: carre_nox divgeo_nox b25_nox_openmp eirene_nox_openmp b25eirene_nox_openmp uinp_nox_openmp triang_nox manual

all_nox_mpi: carre_nox divgeo_nox b25_nox_mpi eirene_nox_mpi b25eirene_nox_mpi uinp_nox_mpi triang_nox_mpi manual

all_openmp_mpi: carre divgeo b25_openmp_mpi eirene_openmp_mpi b25eirene_openmp_mpi uinp_openmp_mpi triang_mpi amds_openmp_mpi sonnet-light manual

all_mpi_openmp: all_openmp_mpi

all_nox_openmp_mpi: carre_nox divgeo_nox b25_nox_openmp_mpi eirene_nox_openmp_mpi b25eirene_nox_openmp_mpi uinp_nox_openmp_mpi triang_nox_mpi manual

all_nox_mpi_openmp: all_nox_openmp_mpi

carre:
	cd modules/Carre; ${MAKE}

carre_nox:
	cd modules/Carre; ${MAKE} NCARG_ROOT="" LD_NCARG=""

divgeo:
ifndef NO_MOTIF
	cd modules/DivGeo;         ${MAKEO}
else
	$(warning DivGeo will not be compiled because Motif library is not installed.)
endif
	cd modules/DivGeo/equtrn;  ${MAKEO}
	cd modules/DivGeo/convert; ${MAKEO}

divgeo_nox:
	cd modules/DivGeo/equtrn;  ${MAKEO}
	cd modules/DivGeo/convert; ${MAKEO}


ifndef NO_CMAKE
	
eirene:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLCHAIN}
	cd modules/Eirene/builds/standalone.${TOOLCHAIN}; ${MAKEC} ${OPT_DBG} ${OPT_MPI} ${OPT_OPENMP}; ${MAKEO}

eirene_mpi:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.mpi${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.mpi${EXT_DBG}; ${MAKEM} ${OPT_DBG}; ${MAKEO}

eirene_openmp:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.openmp${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.openmp${EXT_DBG}; ${MAKEN} ${OPT_DBG}; ${MAKEO}

eirene_openmp_mpi:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.openmp.mpi${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.openmp.mpi${EXT_DBG}; ${MAKEP} ${OPT_DBG}; ${MAKEO}

eirene_nox:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLCHAIN}
	cd modules/Eirene/builds/standalone.${TOOLCHAIN}; ${MAKEX} ${OPT_DBG} ${OPT_MPI} ${OPT_OPENMP}; ${MAKEO}

eirene_nox_mpi:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.mpi${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.mpi${EXT_DBG}; ${MAKEY} ${OPT_DBG}; ${MAKEO}

eirene_nox_openmp:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.openmp${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.openmp${EXT_DBG}; ${MAKEZ} ${OPT_DBG}; ${MAKEO}

eirene_nox_openmp_mpi:
	@-mkdir -p modules/Eirene/builds/standalone.${TOOLSHORT}.openmp.mpi${EXT_DBG}
	cd modules/Eirene/builds/standalone.${TOOLSHORT}.openmp.mpi${EXT_DBG}; ${MAKEA} ${OPT_DBG}; ${MAKEO}

else

eirene:
	cd modules/Eirene; ${MAKEE}

eirene_mpi:
	cd modules/Eirene; ${MAKEE} ${MPI_OPTS}

eirene_openmp:
	cd modules/Eirene; ${MAKEE} ${OMP_OPTE}

eirene_openmp_mpi:
	cd modules/Eirene; ${MAKEE} ${OMP_OPTE} ${MPI_OPTS}

eirene_nox:
	cd modules/Eirene; ${MAKEE} ${OPT_NOX}

eirene_nox_mpi:
	cd modules/Eirene; ${MAKEE} ${MPI_OPTS} ${OPT_NOX}

eirene_nox_openmp:
	cd modules/Eirene; ${MAKEE} ${OMP_OPTE} ${OPT_NOX}

eirene_nox_openmp_mpi:
	cd modules/Eirene; ${MAKEE} ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}

endif

eirene_mpi_openmp: eirene_openmp_mpi

eirene_nox_mpi_openmp: eirene_nox_openmp_mpi

b25:
	cd modules/B2.5; ${MAKE} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO}

b25_all:
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ALL

b25_openmp: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB}

b25_mpi:
	cd modules/B2.5; ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${MPI_OPTS}

b25_openmp_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}

b25_mpi_openmp: b25_openmp_mpi

b25_nox:
	cd modules/B2.5; ${MAKE} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} NOPLOT

b25_ig:
	cd modules/B2.5; ${MAKE} USE_IMPGYRO=-DUSE_IMPGYRO ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_IMPGYRO=-DUSE_IMPGYRO

b25_all_openmp: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${OMP_OPTB}

b25_nox_openmp: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} NOPLOT

b25_nox_mpi:
	cd modules/B2.5; ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${MPI_OPTS} NOPLOT

b25_nox_openmp_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS} NOPLOT

b25_nox_mpi_openmp: b25_nox_openmp_mpi

b25_all_mpi:
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${MPI_OPTS} ALL

b25_all_openmp_mpi: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${OMP_OPTB} ${MPI_OPTS} ALL

b25_all_mpi_openmp: b25_all_openmp_mpi

b25eirene:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}; ${MAKEC} ${OPT_DBG} ${OPT_MPI} ${OPT_OPENMP} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE

b25eirene_all:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}; ${MAKEC} ${OPT_DBG} ${OPT_MPI} ${OPT_OPENMP} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene;   ${MAKEE} USE_B25=-DB25_EIRENE
endif
	cd modules/solps4-5; ${MAKE}  links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ALL

b25eirene_nox:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLCHAIN}; ${MAKEX} ${OPT_DBG} ${OPT_MPI} ${OPT_OPENMP} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX}
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE NOPLOT

b25eirene_openmp: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}; ${MAKEN} ${OPT_DBG} ${OPT_OPENMP} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}

b25eirene_mpi:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}; ${MAKEM} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS}
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}

b25eirene_openmp_mpi: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}; ${MAKEP} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} SOLPS_OPENMP=yes
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}

b25eirene_mpi_openmp: b25eirene_openmp_mpi

b25eirene_nox_openmp: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}; ${MAKEZ} ${OPT_OPENMP} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX} SOLPS_OPENMP=yes
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} NOPLOT

b25eirene_nox_mpi:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}; ${MAKEY} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} NOPLOT

b25eirene_ig:
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE}  USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${B25_SERIAL}
	cd modules/B2.5;   ${MAKEO} USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

b25eirene_all_openmp: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp${EXT_DBG}; ${MAKEN} ${OPT_OPENMP} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes
endif
	cd modules/solps4-5; ${MAKE}  SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ALL

b25eirene_all_mpi:
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.mpi${EXT_DBG}; ${MAKEM} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS}
endif
	cd modules/solps4-5; ${MAKE}  SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ALL

b25eirene_all_openmp_mpi: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}; ${MAKEP} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} SOLPS_OPENMP=yes
endif
	cd modules/solps4-5; ${MAKE}  SOLPS_MPI=yes SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ALL

b25eirene_all_mpi_openmp: b25eirene_all_openmp_mpi

b25eirene_nox_openmp_mpi: nc2text_simple nc_reduce
ifndef NO_CMAKE
	@-mkdir -p modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}
	cd modules/Eirene/builds/couple_SOLPS-ITER.${TOOLSHORT}.openmp.mpi${EXT_DBG}; ${MAKEY} ${OPT_OPENMP} ${OPT_DBG} ${CPLOPTS}; ${MAKEO}
else
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX} ${MPI_OPTS} SOLPS_OPENMP=yes
endif
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} NOPLOT

b25eirene_nox_mpi_openmp: b25eirene_nox_openmp_mpi

uinp: b25eirene
	cd modules/Uinp; ${MAKEO}

uinp_nox: uinp

uinp_openmp: b25eirene_openmp
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB}

uinp_mpi: b25eirene_mpi
	cd modules/Uinp; ${MAKEO} ${MPI_OPTS}

uinp_openmp_mpi: b25eirene_openmp_mpi
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}

uinp_mpi_openmp: uinp_openmp_mpi

uinp_nox_openmp: uinp_openmp

uinp_nox_mpi: uinp_mpi

uinp_nox_openmp_mpi: uinp_openmp_mpi

uinp_nox_mpi_openmp: uinp_openmp_mpi

triang: eirene_nox 
	cd modules/Triang; ${MAKE}

triang_mpi: eirene_nox_mpi
	cd modules/Triang; ${MAKE} ${MPI_OPTS}

triang_nox: eirene_nox
	cd modules/Triang; ${MAKE} ${OPT_NOX} mods
	cd modules/Triang; ${MAKE} ${OPT_NOX}

triang_nox_mpi: eirene_nox_mpi
	cd modules/Triang; ${MAKE} ${MPI_OPTS} ${OPT_NOX} mods
	cd modules/Triang; ${MAKE} ${MPI_OPTS} ${OPT_NOX}

ifndef NO_MOTIF
amds:
	cd modules/amds; ${MAKEO}

amds_mpi:
	cd modules/amds; ${MAKEO} ${MPI_OPTS}

amds_openmp:
	cd modules/amds; ${MAKEO} ${OMP_OPTB}

amds_openmp_mpi:
	cd modules/amds; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}
else
amds:
amds_mpi:
amds_openmp:
amds_openmp_mpi:
	$(warning AMDS will not be compiled because Motif library file is not installed.)
endif

fxdr:
	cd modules/fxdr; ${MAKEO}

sonnet-light:
	@-mkdir -p ${SOLPSLIB}
	cd modules/Sonnet-light; ${MAKE} all INSTALL_USERAREA=${SOLPSLIB}

nc2text: nc2text_simple

nc2text_simple:
	@-mkdir -p ${SOLPSTOP}/scripts/${TOOLCHAIN}
	cd modules/B2.5; ${MAKE} nc2text

nc_reduce:
	@-mkdir -p ${SOLPSTOP}/scripts/${TOOLCHAIN}
	cd modules/B2.5; ${MAKE} nc_reduce

b2sxdr:
	cd modules/solps4-5; ${MAKE} links
	cd modules/solps4-5; ${MAKE} tags
	cd modules/solps4-5; ${MAKE} listobj
	cd modules/solps4-5; ${MAKE} depend
	cd modules/solps4-5; ${MAKE}

manual:
ifndef NO_MANUAL
ifeq ($(shell [ -e ${SOLPSTOP}/doc/solps/b2cdci.F ] && echo yes || echo no ),no)
	cd doc/solps; ${MAKE} complete
else
	cd doc/solps; ${MAKE}
endif
	cd modules/Eirene/Manual; latexmk -pdfdvi eirene.tex
else
	$(warning SOLPS-ITER and Eirene manuals will not be produced because NO_MANUAL switch is activated.)
endif

local:
	cd modules/Eirene;   ${MAKEF} local links
	cd modules/B2.5;     ${MAKE} local
	cd modules/solps4-5; ${MAKE} local

tags:
	cd modules/Carre;          ${MAKE} tags
	cd modules/Eirene;         ${MAKEF} tags
	cd modules/B2.5;           ${MAKE} tags
	cd modules/Uinp;           ${MAKE} tags
	cd modules/Triang;         ${MAKE} tags
	cd modules/DivGeo;         ${MAKE} tags
	cd modules/DivGeo/convert; ${MAKE} tags
	cd modules/DivGeo/equtrn;  ${MAKE} tags
#	cd modules/solps4-5;       ${MAKE} tags
	rm -f TAGS ; ${MAKETAGS} TAGS modules/Carre/src.local/*.F modules/Carre/src/*/*.F modules/Carre/src/include/*.* modules/Eirene/src.local/*.f modules/Eirene/src/*/*.[Ff] modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.f modules/Eirene/src/user-routines/user_iter/*.f modules/Eirene/src/geometry/time-routines/*.F modules/Eirene/src/*/*.[Ff]90 modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.[Ff]90 modules/B2.5/src.local/*.F modules/B2.5/src/*/*.F modules/B2.5/src/*/*.F90 modules/B2.5/src/*/*.[Hh] modules/B2.5/src/common/*.* modules/B2.5/src/common/COUPLE/*.F modules/B2.5/src/documentation/*.xml modules/B2.5/src/documentation/*.py modules/Uinp/src/*.F modules/Uinp/src/*.inc modules/Uinp/src/*.h modules/Triang/src/*/*.f modules/DivGeo/equtrn/src/*.f modules/DivGeo/equtrn/src/*.f90 modules/DivGeo/equtrn/src/*.inc modules/DivGeo/convert/src/*.f modules/DivGeo/src/*.[ch] modules/DivGeo/dg.dgc modules/solps4-5/src/*.F scripts/nc2text_simple/*.F90 doc/solps/solps.tex modules/Eirene/Manual/eirene.tex modules/Eirene/Manual/tex/*.tex || touch TAGS

listobj:
	cd modules/Carre;          ${MAKE} listobj
	cd modules/Eirene;         ${MAKEF} listobj
	cd modules/Eirene;         ${MAKEF} listobj ${OMP_OPTE}
	cd modules/B2.5;           ${MAKE} listobj
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} listobj
	cd modules/DivGeo;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${OMP_OPTE}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}
ifeq (${MPI_PRESENT},1)
	cd modules/Eirene;         ${MAKEF} listobj ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} listobj ${OMP_OPTE} ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
endif
#	cd modules/solps4-5;       ${MAKE} listobj

listobj_nox:
	cd modules/Carre;          ${MAKE} listobj NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKEF} listobj ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj ${OMP_OPTE} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} listobj ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${OMP_OPTE} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}
ifeq (${MPI_PRESENT},1)
	cd modules/Eirene;         ${MAKEF} listobj ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
endif
#	cd modules/solps4-5;       ${MAKE} listobj

depend:
	cd modules/Carre;          ${MAKE} depend
	cd modules/Eirene;         ${MAKEF} depend
	cd modules/Eirene;         ${MAKEF} depend ${OMP_OPTE}
	cd modules/B2.5;           ${MAKE} depend
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} depend
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${OMP_OPTE}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;	   ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}
ifndef NO_MOTIF
	cd modules/DivGeo;         ${MAKE} depend
	cd modules/amds;           ${MAKE} depend
endif
ifeq (${MPI_PRESENT},1)
	cd modules/Eirene;         ${MAKEF} depend ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} depend ${OMP_OPTE} ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} depend ${MPI_OPTS}
	cd modules/B2.5;	   ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;	   ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
endif
#	cd modules/solps4-5;       ${MAKE} depend

depend_nox:
	cd modules/Carre;          ${MAKE} depend NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKEF} depend ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} depend ${OMP_OPTE} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} depend ${OPT_NOX}
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${OMP_OPTE} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}
ifeq (${MPI_PRESENT},1)
	cd modules/Eirene;         ${MAKEF} depend ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} depend ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} depend ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEF} depend USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
endif

VERSION:
	cd modules/B2.5;   ${MAKE} VERSION
	cd modules/Eirene; ${MAKEF} VERSION
	cd modules/Carre;  ${MAKE} VERSION
	cd modules/DivGeo; ${MAKE} VERSION
	cd modules/Uinp;   ${MAKE} VERSION

${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.mk: ${MAKES}
	@mkdir -p ${SOLPSTOP}/modules/Eirene/builds/binRelease
	printf "use mpi\nWRITE(*,fmt='(A12,I1)') 'MPI_VERSION=', MPI_VERSION\nEND" > ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.f90
	( ${MPI_FC} ${FCOPTS} ${INCLUDE} -o ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.f90 ${LD_MPI} && ( ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version | tail -n2 ) || \
	( printf "include 'mpif.h'\nWRITE(*,fmt='(A12,I1)') 'MPI_VERSION=', MPI_VERSION\nEND" > ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.f90 ; \
	( ${MPI_FC} ${FCOPTS} ${INCLUDE} -o ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.f90 ${LD_MPI} && ( ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version | tail -n2 ) || ( echo MPI_VERSION=0 ) ) ) ) > ${SOLPSTOP}/modules/Eirene/builds/binRelease/mpi_version.mk


# Debug targets
#--------------

debug: solps_debug

%_debug:
	${MAKE} $(@:%_debug=%) SOLPS_DEBUG=yes


# CI build tests
#---------------

# Dependencies are not duplicated across build targets

nox_build:     clean_build     listobj_nox depend_nox carre_nox divgeo_nox b25eirene_nox     uinp_nox     triang_nox

nox_build_mpi: clean_build_mpi listobj_nox depend_nox           divgeo_nox b25eirene_nox_mpi uinp_nox_mpi

nox_build_openmp: clean_build_openmp listobj_nox depend_nox b25eirene_nox_openmp uinp_nox_openmp

nox_build_openmp_mpi: clean_build_openmp_mpi listobj_nox depend_nox b25eirene_nox_openmp_mpi uinp_nox_openmp_mpi

nox_build_mpi_openmp: nox_build_openmp_mpi

# Clean targets
#--------------

clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp     clean_triang clean_sonnet-light clean_manual clean_amds

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_sonnet-light clean_manual clean_amds

clean_solps_openmp: clean_carre clean_divgeo clean_b25eirene_openmp clean_uinp_openmp clean_triang clean_sonnet-light clean_manual clean_amds

clean_solps_openmp_mpi: clean_carre clean_divgeo clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi clean_triang_mpi clean_sonnet-light clean_manual clean_amds

clean_solps_mpi_openmp: clean_solps_openmp_mpi

clean_build: clean_carre clean_b25eirene clean_uinp clean_triang_nox

clean_build_mpi: clean_b25eirene_mpi clean_uinp_mpi

clean_build_openmp: clean_b25eirene_openmp clean_uinp_openmp

clean_build_openmp_mpi: clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi

clean_build_mpi_openmp: clean_build_openmp_mpi

clean_nox: clean_carre_nox clean_divgeo_nox clean_b25eirene_nox clean_uinp clean_triang_nox clean_manual

clean_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_manual clean_amds

clean_nox_mpi: clean_carre_nox clean_divgeo_nox clean_b25eirene_nox_mpi clean_uinp_mpi clean_triang_nox_mpi clean_manual

clean_openmp: clean_carre clean_divgeo clean_b25eirene_openmp clean_uinp_openmp clean_triang clean_manual clean_amds

clean_nox_openmp: clean_carre_nox clean_divgeo_nox clean_b25eirene_nox_openmp clean_uinp_openmp clean_triang_nox clean_manual

clean_openmp_mpi: clean_carre clean_divgeo clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi clean_triang_mpi clean_manual clean_amds

clean_nox_openmp_mpi: clean_carre_nox clean_divgeo_nox clean_b25eirene_nox_openmp_mpi clean_uinp_openmp_mpi clean_triang_nox_mpi clean_manual

clean_mpi_openmp: clean_openmp_mpi

clean_nox_mpi_openmp: clean_nox_openmp_mpi

clean_all: clean_carre clean_divgeo clean_b25 clean_eirene clean_b25eirene clean_uinp clean_triang clean_manual clean_amds

clean_all_nox: clean_carre_nox clean_divgeo_nox clean_b25_nox clean_eirene_nox clean_b25eirene_nox clean_uinp clean_triang_nox clean_manual

clean_all_mpi: clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_manual clean_amds

clean_all_nox_mpi: clean_carre_nox clean_divgeo_nox clean_b25_nox_mpi clean_eirene_nox_mpi clean_b25eirene_nox_mpi clean_uinp_mpi clean_triang_nox_mpi clean_manual

clean_all_openmp: clean_carre clean_divgeo clean_b25_openmp clean_eirene_openmp clean_b25eirene_openmp clean_uinp_openmp clean_triang clean_manual clean_amds

clean_all_nox_openmp: clean_carre_nox clean_divgeo_nox clean_b25_nox_openmp clean_eirene_nox_openmp clean_b25eirene_nox_openmp clean_uinp_openmp clean_triang_nox clean_manual

clean_all_openmp_mpi: clean_carre clean_divgeo clean_b25_openmp_mpi clean_eirene_openmp_mpi clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi clean_triang_mpi clean_manual clean_amds

clean_all_nox_openmp_mpi: clean_carre_nox clean_divgeo_nox clean_b25_nox_openmp_mpi clean_eirene_nox_openmp_mpi clean_b25eirene_nox_openmp_mpi clean_uinp_openmp_mpi clean_triang_nox_mpi clean_manual

clean_all_mpi_openmp: clean_all_openmp_mpi

clean_all_nox_mpi_openmp: clean_all_nox_openmp_mpi

clean_carre:
	cd modules/Carre; ${MAKE} clean

clean_carre_nox:
	cd modules/Carre; ${MAKE} clean NCARG_ROOT="" LD_NCARG=""

clean_divgeo:
	cd modules/DivGeo;         ${MAKE} clean
	cd modules/DivGeo/equtrn;  ${MAKE} clean
	cd modules/DivGeo/convert; ${MAKE} clean

clean_divgeo_nox:
	cd modules/DivGeo/equtrn;  ${MAKE} clean
	cd modules/DivGeo/convert; ${MAKE} clean

clean_eirene:
	cd modules/Eirene; ${MAKEF} clean

clean_eirene_nox:
	cd modules/Eirene; ${MAKEF} clean ${OPT_NOX}

clean_eirene_mpi:
	cd modules/Eirene; ${MAKEF} clean ${MPI_OPTS}

clean_eirene_nox_mpi:
	cd modules/Eirene; ${MAKEF} clean ${MPI_OPTS} ${OPT_NOX}

clean_eirene_openmp:
	cd modules/Eirene; ${MAKEF} clean ${OMP_OPTE}

clean_eirene_nox_openmp:
	cd modules/Eirene; ${MAKEF} clean ${OMP_OPTE} ${OPT_NOX}

clean_eirene_openmp_mpi:
	cd modules/Eirene; ${MAKEF} clean ${OMP_OPTE} ${MPI_OPTS}

clean_eirene_nox_openmp_mpi:
	cd modules/Eirene; ${MAKEF} clean ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}

clean_eirene_mpi_openmp: clean_eirene_openmp_mpi

clean_eirene_nox_mpi_openmp: clean_eirene_nox_openmp_mpi

clean_b25:
	cd modules/B2.5; ${MAKE} clean

clean_b25_openmp:
	cd modules/B2.5; ${MAKE} clean ${OMP_OPTB}

clean_b25_mpi:
	cd modules/B2.5; ${MAKE} clean ${MPI_OPTS}

clean_b25_openmp_mpi:
	cd modules/B2.5; ${MAKE} clean ${OMP_OPTB} ${MPI_OPTS}

clean_b25_mpi_openmp: clean_b25_openmp_mpi

clean_b25_nox:
	cd modules/B2.5; ${MAKE} clean ${OPT_NOX}

clean_b25_nox_mpi:
	cd modules/B2.5; ${MAKE} clean ${MPI_OPTS} ${OPT_NOX}

clean_b25_nox_openmp:
	cd modules/B2.5; ${MAKE} clean ${OMP_OPTB} ${OPT_NOX}

clean_b25_nox_openmp_mpi:
	cd modules/B2.5; ${MAKE} clean ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}

clean_b25_nox_mpi_openmp: clean_b25_openmp_mpi

clean_b25_ig:
	cd modules/B2.5; ${MAKE} clean USE_IMPGYRO=-DUSE_IMPGYRO

clean_b25eirene:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE

clean_b25eirene_mpi:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}

clean_b25eirene_openmp:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${OMP_OPTE}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}

clean_b25eirene_nox_openmp:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${OMP_OPTE} ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}

clean_b25eirene_openmp_mpi:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}

clean_b25eirene_nox_openmp_mpi:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${OMP_OPTE} ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}

clean_b25eirene_mpi_openmp: clean_b25eirene_openmp_mpi

clean_b25eirene_nox_mpi_openmp: clean_b25eirene_nox_openmp_mpi

clean_b25eirene_nox:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OPT_NOX}

clean_b25eirene_nox_mpi:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}

clean_b25eirene_ig:
	cd modules/Eirene; ${MAKEF} clean USE_B25=-DB25_EIRENE   USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

clean_uinp:
	cd modules/Uinp; ${MAKE} clean

clean_uinp_openmp:
	cd modules/Uinp; ${MAKE} clean ${OMP_OPTB}

clean_uinp_mpi:
	cd modules/Uinp; ${MAKE} clean ${MPI_OPTS}

clean_uinp_openmp_mpi:
	cd modules/Uinp; ${MAKE} clean ${OMP_OPTB} ${MPI_OPTS}

clean_uinp_mpi_openmp: clean_uinp_openmp_mpi

clean_triang:
	cd modules/Triang; ${MAKE} clean

clean_triang_nox:
	cd modules/Triang; ${MAKE} clean ${OPT_NOX}

clean_triang_mpi:
	cd modules/Triang; ${MAKE} clean ${MPI_OPTS}

clean_triang_nox_mpi:
	cd modules/Triang; ${MAKE} clean ${MPI_OPTS} ${OPT_NOX}

clean_amds:
	cd modules/amds; ${MAKE} clean

clean_fxdr:
	cd modules/fxdr; ${MAKE} clean

clean_sonnet-light:
	cd modules/Sonnet-light; ${MAKE} clean

clean_b2sxdr:
	cd modules/solps4-5; ${MAKE} clean

clean_manual:
	cd doc/solps; ${MAKE} clean

# help
help:
	@echo "                 solps : compile serial version (main codes)"
	@echo "             solps_mpi : compile MPI version (main codes)"
	@echo "          solps_openmp : compile OpenMP version (main codes)"
	@echo "      solps_openmp_mpi : compile OpenMP+MPI version (main codes)"
	@echo "           solps_debug : compile debug version (serial) (main codes)"
	@echo "       solps_mpi_debug : compile debug version (MPI) (main codes)"
	@echo "    solps_openmp_debug : compile debug version (OpenMP) (main codes)"
	@echo "solps_openmp_mpi_debug : compile debug version (OpenMP+MPI) (main codes)"
	@echo "                   all : compile serial version (all codes)"
	@echo "               all_mpi : compile MPI version (all codes)"
	@echo "            all_openmp : compile OpenMP version (all codes)"
	@echo "             all_debug : compile debug version (serial) (all codes)"
	@echo "         all_mpi_debug : compile debug version (MPI) (all codes)"
	@echo "      all_openmp_debug : compile debug version (OpenMP) (all codes)"
	@echo "  all_openmp_mpi_debug : compile debug version (OpenMP+MPI) (all codes)"
	@echo "                   nox : compile serial version (no X main codes)"
	@echo "               all_nox : compile serial version (all no X codes)"
	@echo "               nox_mpi : compile MPI version (no X main codes)"
	@echo "           all_nox_mpi : compile MPI version (all no X codes)"
	@echo "            nox_openmp : compile OpenMP version (no X main codes)"
	@echo "        nox_openmp_mpi : compile OpenMP+MPI version (no X main codes)"
	@echo "             nox_debug : compile debug version (serial) (no X main codes)"
	@echo "         all_nox_debug : compile debug version (serial) (all no X codes)"
	@echo "         nox_mpi_debug : compile debug version (MPI) (no X main codes)"
	@echo "      nox_openmp_debug : compile debug version (OpenMP) (no X main codes)"
	@echo "     all_nox_mpi_debug : compile debug version (MPI) (all no X codes)"
	@echo "  nox_openmp_mpi_debug : compile debug version (OpenMP+MPI) (no X main codes)"
