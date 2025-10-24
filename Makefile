# Test whether required environment variables are set
# If not, attempt to determine them automatically

UNAME := $(shell uname)

# Identify HOST_NAME
ifndef HOST_NAME
  ifneq ($(UNAME),Darwin)
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
export MAKETAGS

# Setup debug flags
EXT_DBG =
ifdef SOLPS_DEBUG
EXT_DBG = .debug
endif

# Setup MPI flags
EXT_MPI =
MPI_OPTS = USE_MPI=-DUSE_MPI SOLPS_MPI=yes
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif

# Setup OpenMP flag
EXT_OPENMP =
ifdef SOLPS_OPENMP
EXT_OPENMP = .openmp
endif
OMP_OPTB = USE_OPENMP=-D_OPENMP SOLPS_OPENMP=yes

OPT_NOX = LD_GR="" LD_GKS=""

ifdef LD_NETCDF
B25_SERIAL = mods nc2text_simple nc_reduce
else
B25_SERIAL = mods
endif

DIMENSIONS = 0
ifeq ($(shell [ -s modules/B2.5/src/modules/b2mod_dimensions.F ] && echo yes || echo no ),yes)
DIMENSIONS = 1
endif

MAKEO = ${MAKE} ${MAKE_OPTIONS}
ifeq (${DIMENSIONS},1)
MAKEE = ${MAKEO} DIMENSIONS_MODULE=yes
else
MAKEE = ${MAKEO}
endif

.PHONY: solps solps_nox solps_openmp solps_mpi solps_openmp_mpi solps_mpi_openmp nox nox_openmp nox_mpi nox_openmp_mpi nox_mpi_openmp all all_openmp all_nox all_mpi all_openmp_mpi all_mpi_openmp all_nox_openmp all_nox_openmp_mpi all_nox_mpi_openmp all_nox_mpi all_mpi_nox carre carre_nox divgeo divgeo_nox b25 b25_openmp b25_mpi b25_openmp_mpi b25_mpi_openmp b25_nox b25_nox_openmp b25_nox_mpi b25_nox_openmp_mpi b25_nox_mpi_openmp b25_ig b25_all_mpi b25_all_openmp b25_all_openmp_mpi b25_all_mpi_openmp eirene eirene_mpi eirene_nox eirene_nox_mpi b25eirene b25eirene_openmp b25eirene_mpi b25eirene_openmp_mpi b25eirene_mpi_openmp b25eirene_nox b25eirene_nox_mpi b25eirene_ig b25eirene_all_mpi b25eirene_nox_mpi uinp uinp_nox uinp_openmp uinp_mpi uinp_openmp_mpi uinp_mpi_openmp uinp_nox_openmp uinp_nox_mpi uinp_nox_openmp_mpi uinp_nox_mpi_openmp triang triang_nox triang_mpi triang_nox_mpi amds amds_mpi amds_openmp amds_openmp_mpi fxdr sonnet-light nc2text_simple nc_reduce b2sxdr manual local depend depend_nox tags listobj listobj_nox clean clean_% debug %_debug VERSION help nox_build nox_build_mpi nox_build_openmp nox_build_openmp_mpi nox_build_mpi_openmp b25_diff_d b25_diff_b b25_tgt b25_adj b25_hess_tgt b25_diff_dd

DEFAULT: solps


# Basic compile targets
#----------------------


solps: divgeo b25eirene carre uinp triang amds manual

solps_nox: nox

solps_openmp: divgeo b25eirene_openmp carre uinp_openmp triang amds_openmp manual

solps_mpi: divgeo b25eirene_mpi carre uinp_mpi triang_mpi amds_mpi manual

solps_openmp_mpi: divgeo b25eirene_openmp_mpi carre uinp_openmp_mpi triang_mpi amds_openmp_mpi manual

solps_mpi_openmp: solps_openmp_mpi

nox: divgeo_nox b25eirene_nox carre_nox uinp_nox triang_nox manual

nox_openmp: divgeo_nox b25eirene_nox_openmp carre_nox uinp_nox_openmp triang_nox manual

solps_nox_openmp: nox_openmp

solps_openmp_nox: nox_openmp

nox_mpi: divgeo_nox b25eirene_nox_mpi carre_nox uinp_nox_mpi triang_nox_mpi manual

solps_nox_mpi: nox_mpi

solps_mpi_nox: nox_mpi

nox_openmp_mpi: divgeo_nox b25eirene_nox_openmp_mpi carre_nox uinp_nox_openmp_mpi triang_nox_mpi manual

nox_mpi_openmp: nox_openmp_mpi

solps_openmp_mpi_nox: nox_openmp_mpi

solps_mpi_openmp_nox: nox_openmp_mpi

solps_nox_openmp_mpi: nox_openmp_mpi

solps_nox_mpi_openmp: nox_openmp_mpi

all: divgeo b25 eirene b25eirene carre uinp triang amds manual

all_nox: divgeo_nox b25_nox eirene_nox b25eirene_nox carre_nox uinp_nox triang_nox manual

all_openmp: divgeo b25_openmp eirene b25eirene_openmp carre uinp_openmp triang amds_openmp manual

all_mpi: divgeo b25_mpi eirene_mpi b25eirene_mpi carre uinp_mpi triang_mpi amds_mpi manual

all_nox_openmp: divgeo_nox b25_nox_openmp eirene_nox b25eirene_nox_openmp carre_nox uinp_nox_openmp triang_nox manual

all_openmp_nox: all_nox_openmp

all_nox_mpi: divgeo_nox b25_nox_mpi eirene_nox_mpi b25eirene_nox_mpi carre_nox uinp_nox_mpi triang_nox_mpi manual

all_mpi_nox: all_nox_mpi

all_openmp_mpi: divgeo b25_openmp_mpi eirene_mpi b25eirene_openmp_mpi carre uinp_openmp_mpi triang_mpi amds_openmp_mpi manual

all_mpi_openmp: all_openmp_mpi

all_nox_openmp_mpi: divgeo_nox b25_nox_openmp_mpi eirene_nox_mpi b25eirene_nox_openmp_mpi carre_nox uinp_nox_openmp_mpi triang_nox_mpi manual

all_nox_mpi_openmp: all_nox_openmp_mpi

all_openmp_mpi_nox: all_nox_openmp_mpi

all_mpi_openmp_nox: all_nox_openmp_mpi

carre2: carre

carre:
	cd modules/Carre2; ${MAKE}

carre_nox:
	cd modules/Carre2; ${MAKE} NCARG_ROOT="" LD_NCARG=""

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

eirene:
	cd modules/Eirene; ${MAKEE}

eirene_mpi:
	cd modules/Eirene; ${MAKEE} ${MPI_OPTS}

eirene_nox:
	cd modules/Eirene; ${MAKEE} ${OPT_NOX}

eirene_nox_mpi:
	cd modules/Eirene; ${MAKEE} ${MPI_OPTS} ${OPT_NOX}

b25: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO}

b25_diff_d: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} DIFF_D

b25_diff_b: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} DIFF_B

b25_diff_dd: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} DIFF_DD

b25_tgt: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} TANGENT TGT=yes

b25_adj: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ADJOINT ADJ=yes

b25_hess_tgt: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} HESS_TGT HESS_TGT=yes

b25_all: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ALL

b25_openmp: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB}

b25_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${MPI_OPTS}

b25_openmp_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}

b25_mpi_openmp: b25_openmp_mpi

b25_nox: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} NOPLOT

b25_ig: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} USE_IMPGYRO=-DUSE_IMPGYRO ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_IMPGYRO=-DUSE_IMPGYRO

b25_all_openmp: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${OMP_OPTB}

b25_nox_openmp: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} NOPLOT

b25_openmp_nox: b25_nox_openmp

b25_nox_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${MPI_OPTS} NOPLOT

b25_mpi_nox: b25_nox_mpi

b25_nox_openmp_mpi: nc2text_simple nc_reduce
	cd modules/B2.5; ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS} NOPLOT

b25_nox_mpi_openmp: b25_nox_openmp_mpi

b25_mpi_openmp_nox: b25_nox_openmp_mpi

b25_openmp_mpi_nox: b25_nox_openmp_mpi

b25_all_mpi: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${MPI_OPTS} ALL

b25_all_openmp_mpi: nc2text_simple nc_reduce
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE} ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} ${OMP_OPTB} ${MPI_OPTS} ALL

b25_all_mpi_openmp: b25_all_openmp_mpi

b25eirene: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE

b25eirene_all: nc2text_simple nc_reduce
	cd modules/Eirene;   ${MAKEE} USE_B25=-DB25_EIRENE
	cd modules/solps4-5; ${MAKE}  links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ALL

b25eirene_nox: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE NOPLOT

b25eirene_openmp: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}

b25eirene_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}

b25eirene_openmp_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} SOLPS_OPENMP=yes
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}

b25eirene_mpi_openmp: b25eirene_openmp_mpi

b25eirene_nox_openmp: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX} SOLPS_OPENMP=yes
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} NOPLOT

b25eirene_nox_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} NOPLOT

b25eirene_ig: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE}  USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${B25_SERIAL}
	cd modules/B2.5;   ${MAKEO} USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

b25eirene_all_openmp: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes
	cd modules/solps4-5; ${MAKE}  SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ALL

b25eirene_all_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/solps4-5; ${MAKE}  SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ALL

b25eirene_all_openmp_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${MPI_OPTS} SOLPS_OPENMP=yes
	cd modules/solps4-5; ${MAKE}  SOLPS_MPI=yes SOLPS_OPENMP=yes links
	cd modules/B2.5;     ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5;     ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ALL

b25eirene_all_mpi_openmp: b25eirene_all_openmp_mpi

b25eirene_nox_openmp_mpi: nc2text_simple nc_reduce
	cd modules/Eirene; ${MAKEE} USE_B25=-DB25_EIRENE ${OPT_NOX} ${MPI_OPTS} SOLPS_OPENMP=yes
	cd modules/B2.5; ${MAKE}  USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${B25_SERIAL}
	cd modules/B2.5; ${MAKEO} USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} NOPLOT

b25eirene_nox_mpi_openmp: b25eirene_nox_openmp_mpi

uinp: b25eirene carre
	cd modules/Uinp; ${MAKEO}

uinp_nox: b25eirene_nox carre_nox
	cd modules/Uinp; ${MAKEO}

uinp_openmp: b25eirene_openmp carre
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB}

uinp_mpi: b25eirene_mpi carre
	cd modules/Uinp; ${MAKEO} ${MPI_OPTS}

uinp_openmp_mpi: b25eirene_openmp_mpi carre
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}

uinp_mpi_openmp: uinp_openmp_mpi

uinp_nox_openmp: b25eirene_nox_openmp carre_nox
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB}

uinp_openmp_nox: uinp_nox_openmp

uinp_nox_mpi: b25eirene_nox_mpi carre_nox
	cd modules/Uinp; ${MAKEO} ${MPI_OPTS}

uinp_mpi_nox: uinp_nox_mpi

uinp_nox_openmp_mpi: b25eirene_nox_openmp_mpi carre_nox
	cd modules/Uinp; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}

uinp_nox_mpi_openmp: uinp_nox_openmp_mpi

uinp_mpi_openmp_nox: uinp_nox_openmp_mpi

uinp_openmp_mpi_nox: uinp_nox_openmp_mpi

triang:
	cd modules/Triang; ${MAKE}

triang_mpi:
	cd modules/Triang; ${MAKE} ${MPI_OPTS}

triang_nox:
	cd modules/Triang; ${MAKE} ${OPT_NOX} mods
	cd modules/Triang; ${MAKE} ${OPT_NOX}

triang_nox_mpi:
	cd modules/Triang; ${MAKE} ${MPI_OPTS} ${OPT_NOX} mods
	cd modules/Triang; ${MAKE} ${MPI_OPTS} ${OPT_NOX}

ifndef NO_MOTIF
amds: b25eirene
	cd modules/amds; ${MAKEO}

amds_mpi: b25eirene_mpi
	cd modules/amds; ${MAKEO} ${MPI_OPTS}

amds_openmp: b25eirene_openmp
	cd modules/amds; ${MAKEO} ${OMP_OPTB}

amds_openmp_mpi: b25eirene_openmp_mpi
	cd modules/amds; ${MAKEO} ${OMP_OPTB} ${MPI_OPTS}
else
amds:
amds_mpi:
amds_openmp:
amds_openmp_mpi:
	$(warning AMDS will not be compiled because Motif library file is not installed.)
endif

fxdr: sonnet-light
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

b2sxdr: sonnet-light
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
else
	$(warning SOLPS-ITER Manual will not be produced because NO_MANUAL switch is activated.)
endif

local:
	cd modules/Eirene;   ${MAKEE} local
	cd modules/B2.5;     ${MAKE} local
	cd modules/solps4-5; ${MAKE} local

tags:
	cd modules/Carre2;         ${MAKE} tags
	cd modules/Eirene;         ${MAKEE} tags
	cd modules/B2.5;           ${MAKE} tags
	cd modules/Uinp;           ${MAKE} tags
	cd modules/Triang;         ${MAKE} tags
	cd modules/DivGeo;         ${MAKE} tags
	cd modules/DivGeo/convert; ${MAKE} tags
	cd modules/DivGeo/equtrn;  ${MAKE} tags
#	cd modules/solps4-5;       ${MAKE} tags
	rm -f TAGS ; ${MAKETAGS} TAGS modules/Carre2/src90/*/*.[Ff]90 modules/Carre2/src90/include/*.* modules/Eirene/src.local/*.f modules/Eirene/src/*/*.[Ffc] modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.f modules/Eirene/src/user-routines/user_iter/*.f modules/Eirene/src/geometry/time-routines/*.F modules/Eirene/src/*/*.[Ff]90 modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.[Ff]90 modules/B2.5/src.local/*.F modules/B2.5/src/*/*.F modules/B2.5/src/*/*/*.F modules/B2.5/src/*/*.F90 modules/B2.5/src/*/*/*.F90 modules/B2.5/src/*/*.[Hh] modules/B2.5/src/common/*.* modules/B2.5/src/common/COUPLE/*.F modules/B2.5/src/documentation/*.xml modules/B2.5/src/documentation/*.py modules/Uinp/src/*.F modules/Uinp/src/*.inc modules/Uinp/src/*.h modules/Triang/src/*/*.f modules/DivGeo/equtrn/src/*.f modules/DivGeo/equtrn/src/*.f90 modules/DivGeo/equtrn/src/*.inc modules/DivGeo/convert/src/*.f modules/DivGeo/src/*.[ch] modules/DivGeo/dg.dgc modules/solps4-5/src/*.F scripts/nc2text_simple/*.F90 doc/solps/*.tex doc/AFN_BCs_documentation/LaTeX_source_code/*.tex || touch TAGS

listobj:
	cd modules/Carre2;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKEE} listobj
	cd modules/B2.5;           ${MAKE} listobj
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/B2.5;           ${MAKE} listobj TGT=yes
	cd modules/B2.5;           ${MAKE} listobj ADJ=yes
	cd modules/B2.5;           ${MAKE} listobj HESS_TGT=yes
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} listobj
	cd modules/DivGeo;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}
ifndef NO_MPI
	cd modules/Eirene;         ${MAKEE} listobj ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
endif
#	cd modules/solps4-5;       ${MAKE} listobj

listobj_nox:
	cd modules/Carre2;         ${MAKE} listobj NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKEE} listobj ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj TGT=yes
	cd modules/B2.5;           ${MAKE} listobj ADJ=yes
	cd modules/B2.5;           ${MAKE} listobj HESS_TGT=yes
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} listobj ${OPT_NOX}
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}
ifndef NO_MPI
	cd modules/Eirene;         ${MAKEE} listobj ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} listobj ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} listobj ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEE} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
endif
#	cd modules/solps4-5;       ${MAKE} listobj

depend:
	cd modules/Carre2;         ${MAKE} depend
	cd modules/Eirene;         ${MAKEE} depend
	cd modules/B2.5;           ${MAKE} depend
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} depend
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;	   ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}
ifndef NO_MOTIF
	cd modules/DivGeo;         ${MAKE} depend
	cd modules/amds;           ${MAKE} depend
endif
ifndef NO_MPI
	cd modules/Eirene;         ${MAKE} depend ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} depend ${MPI_OPTS}
	cd modules/B2.5;	   ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;	   ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
endif
#	cd modules/solps4-5;       ${MAKE} depend
ifeq (${TAO_PRESENT},1)
# The following dependency builds must be done last as they change the filelist
	cd modules/B2.5;           ${MAKE} depend TGT=yes TAO=yes
	cd modules/B2.5;           ${MAKE} depend ADJ=yes TAO=yes
	cd modules/B2.5;           ${MAKE} depend HESS_TGT=yes TAO=yes
else
	cd modules/B2.5;           ${MAKE} depend TGT=yes
	cd modules/B2.5;           ${MAKE} depend ADJ=yes
	cd modules/B2.5;           ${MAKE} depend HESS_TGT=yes
endif

depend_nox:
	cd modules/Carre2;         ${MAKE} depend NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKEE} depend ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB}
	cd modules/Triang;         ${MAKE} depend ${OPT_NOX}
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}
ifndef NO_MPI
	cd modules/Eirene;         ${MAKEE} depend ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Uinp;           ${MAKE} depend ${MPI_OPTS}
	cd modules/Uinp;           ${MAKE} depend ${OMP_OPTB} ${MPI_OPTS}
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}
	cd modules/Eirene;         ${MAKEE} depend USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO ${OPT_NOX}
endif
ifeq (${TAO_PRESENT},1)
# The following dependency builds must be done last as they change the filelist
	cd modules/B2.5;           ${MAKE} depend TGT=yes TAO=yes
	cd modules/B2.5;           ${MAKE} depend ADJ=yes TAO=yes
	cd modules/B2.5;           ${MAKE} depend HESS_TGT=yes TAO=yes
else
	cd modules/B2.5;           ${MAKE} depend TGT=yes
	cd modules/B2.5;           ${MAKE} depend ADJ=yes
	cd modules/B2.5;           ${MAKE} depend HESS_TGT=yes
endif

VERSION:
	cd modules/B2.5;   ${MAKE} VERSION
	cd modules/Eirene; ${MAKEE} VERSION
	cd modules/Carre2; ${MAKE} VERSION
	cd modules/DivGeo; ${MAKE} VERSION
	cd modules/Uinp;   ${MAKE} VERSION

# Debug targets
#--------------

debug: solps_debug

%_debug:
	${MAKE} $(@:%_debug=%) SOLPS_DEBUG=yes


# CI build tests
#---------------

# Dependencies are not duplicated across build targets

nox_build: clean_build listobj_nox depend_nox divgeo_nox b25eirene_nox carre_nox uinp_nox triang_nox

nox_build_mpi: clean_build_mpi listobj_nox depend_nox divgeo_nox b25eirene_nox_mpi

nox_build_openmp: clean_build_openmp listobj_nox depend_nox b25eirene_nox_openmp

nox_build_openmp_mpi: clean_build_openmp_mpi listobj_nox depend_nox b25eirene_nox_openmp_mpi

nox_build_mpi_openmp: nox_build_openmp_mpi

# Clean targets
#--------------

clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp     clean_triang clean_manual clean_amds

clean_solps_nox: clean_nox

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_manual clean_amds

clean_solps_openmp: clean_carre clean_divgeo clean_b25eirene_openmp clean_uinp_openmp clean_triang clean_manual clean_amds

clean_solps_openmp_mpi: clean_carre clean_divgeo clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi clean_triang_mpi clean_manual clean_amds

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

clean_all_mpi_nox: clean_all_nox_mpi

clean_all_openmp: clean_carre clean_divgeo clean_b25_openmp clean_eirene clean_b25eirene_openmp clean_uinp_openmp clean_triang clean_manual clean_amds

clean_all_nox_openmp: clean_carre_nox clean_divgeo_nox clean_b25_nox_openmp clean_eirene_nox clean_b25eirene_nox_openmp clean_uinp_openmp clean_triang_nox clean_manual

clean_all_openmp_nox: clean_all_nox_openmp

clean_all_openmp_mpi: clean_carre clean_divgeo clean_b25_openmp_mpi clean_eirene_mpi clean_b25eirene_openmp_mpi clean_uinp_openmp_mpi clean_triang_mpi clean_manual clean_amds

clean_all_nox_openmp_mpi: clean_carre_nox clean_divgeo_nox clean_b25_nox_openmp_mpi clean_eirene_nox_mpi clean_b25eirene_nox_openmp_mpi clean_uinp_openmp_mpi clean_triang_nox_mpi clean_manual

clean_all_mpi_openmp: clean_all_openmp_mpi

clean_all_nox_mpi_openmp: clean_all_nox_openmp_mpi

clean_all_openmp_mpi_nox: clean_all_nox_openmp_mpi

clean_all_mpi_openmp_nox: clean_all_nox_openmp_mpi

clean_carre:
	cd modules/Carre2; ${MAKE} clean

clean_carre_nox:
	cd modules/Carre2; ${MAKE} clean NCARG_ROOT="" LD_NCARG=""

clean_divgeo:
	cd modules/DivGeo;         ${MAKE} clean
	cd modules/DivGeo/equtrn;  ${MAKE} clean
	cd modules/DivGeo/convert; ${MAKE} clean

clean_divgeo_nox:
	cd modules/DivGeo/equtrn;  ${MAKE} clean
	cd modules/DivGeo/convert; ${MAKE} clean

clean_eirene:
	cd modules/Eirene; ${MAKEE} clean

clean_eirene_nox:
	cd modules/Eirene; ${MAKEE} clean ${OPT_NOX}

clean_eirene_mpi:
	cd modules/Eirene; ${MAKEE} clean ${MPI_OPTS}

clean_eirene_nox_mpi:
	cd modules/Eirene; ${MAKEE} clean ${MPI_OPTS} ${OPT_NOX}

clean_b25:
	cd modules/B2.5; ${MAKE} clean

clean_b25_adj:
	cd modules/B2.5; ${MAKE} clean ADJ=yes

clean_b25_tgt:
	cd modules/B2.5; ${MAKE} clean TGT=yes

clean_b25_hess_tgt:
	cd modules/B2.5; ${MAKE} clean HESS_TGT=yes

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
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE

clean_b25eirene_mpi:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE ${MPI_OPTS}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${MPI_OPTS}

clean_b25eirene_openmp:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB}

clean_b25eirene_nox_openmp:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${OPT_NOX}

clean_b25eirene_openmp_mpi:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE ${MPI_OPTS} SOLPS_OPENMP=yes
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS}

clean_b25eirene_nox_openmp_mpi:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE SOLPS_OPENMP=yes ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OMP_OPTB} ${MPI_OPTS} ${OPT_NOX}

clean_b25eirene_mpi_openmp: clean_b25eirene_openmp_mpi

clean_b25eirene_nox_mpi_openmp: clean_b25eirene_nox_openmp_mpi

clean_b25eirene_nox:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${OPT_NOX}

clean_b25eirene_nox_mpi:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE ${MPI_OPTS} ${OPT_NOX}

clean_b25eirene_ig:
	cd modules/Eirene; ${MAKEE} clean USE_B25=-DB25_EIRENE   USE_IMPGYRO=-DUSE_IMPGYRO
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
