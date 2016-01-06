# Test whether required environment variables are set
# If not, attempt to determine them automatically

# Identify HOST_NAME 
ifndef HOST_NAME
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
ifeq ($(shell [ -e SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST_NAME}.${COMPILER}
else
  $(warning  SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif

# Include local compiler settings, if present
ifeq ($(shell [ -e SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST_NAME}.${COMPILER}.local
endif

# Setup debug flag
EXT_DBG =
ifdef SOLPS_DEBUG
EXT_DBG=.debug
endif

# SOLPS_DEBUG and SOLPS_MPI will not be taken from environment,
# but will be passed by the corresponding make-targets 
unexport SOLPS_DEBUG
unexport SOLPS_MPI

.PHONY: solps solps_mpi all all_mpi carre divgeo b25 b25_mpi eirene eirene_mpi b25eirene b25eirene_mpi b25eirene_ig uinp triang fxdr sonnet-light b2sxdr manual local depend tags clean clean_% %_debug VERSION help

DEFAULT: solps




# Basic compile targets
#----------------------


solps:     carre divgeo b25eirene     uinp     triang amds sonnet-light manual

solps_mpi: carre divgeo b25eirene_mpi uinp_mpi triang amds sonnet-light manual

nox:       carre_nox    b25eirene_nox uinp_nox triang_nox manual

nox_mpi:   carre_nox b25eirene_mpi_nox uinp_mpi_nox triang_nox manual

all:       carre divgeo b25     eirene     b25eirene     uinp     triang amds sonnet-light manual

all_mpi:   carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp_mpi triang amds sonnet-light manual

carre:
	cd modules/Carre; ${MAKE}

carre_nox:
	cd modules/Carre;  ${MAKE} NCARG_ROOT="" LD_NCARG=""

divgeo:
	cd modules/DivGeo;         ${MAKE}
	cd modules/DivGeo/equtrn;  ${MAKE}
	cd modules/DivGeo/convert; ${MAKE}

eirene:
	cd modules/Eirene; ${MAKE}

eirene_mpi:
	cd modules/Eirene; ${MAKE} USE_MPI=-DUSE_MPI

eirene_nox:
	cd modules/Eirene; ${MAKE} LD_GR="" LD_GKS=""

b25:
	cd modules/B2.5; ${MAKE}

b25_all:
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} ALL

b25_mpi:
	cd modules/B2.5; ${MAKE} USE_MPI=-DUSE_MPI

b25_nox:
	cd modules/B2.5; ${MAKE} NOPLOT

b25_ig:
	cd modules/B2.5; ${MAKE} USE_IMPGYRO=-DUSE_IMPGYRO

b25_all_mpi:
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} USE_MPI=-DUSE_MPI ALL

b25eirene:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE

b25eirene_all:
	cd modules/Eirene;   ${MAKE} USE_B25=-DB25_EIRENE
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} USE_EIRENE=-DB25_EIRENE ALL

b25eirene_nox:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE NOPLOT

b25eirene_mpi:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI

b25eirene_ig:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

b25eirene_all_mpi:
	cd modules/Eirene;   ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI ALL

b25eirene_mpi_nox:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE LD_GR=""  LD_GKS="" USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI NOPLOT

uinp:
	cd modules/Uinp; ${MAKE}

uinp_nox: uinp

uinp_mpi:
	cd modules/Uinp; ${MAKE} USE_MPI=-DUSE_MPI

uinp_mpi_nox: uinp_mpi

triang:
	cd modules/Triang; ${MAKE}

triang_nox:
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS="" mods
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS=""

amds:
	cd modules/amds; ${MAKE}

fxdr:
	cd modules/fxdr; ${MAKE}

sonnet-light:
	@-mkdir -p ${SOLPSLIB}
	cd modules/Sonnet-light; ${MAKE} all INSTALL_USERAREA=${SOLPSLIB}

b2sxdr:
	cd modules/solps4-5; ${MAKE} links
	cd modules/solps4-5; ${MAKE} tags
	cd modules/solps4-5; ${MAKE} listobj
	cd modules/solps4-5; ${MAKE} depend
	cd modules/solps4-5; ${MAKE}

manual:
ifeq ($(shell [ -e ${SOLPSTOP}/doc/solps/b2cdci.F ] && echo yes || echo no ),no)
	cd doc/solps; ${MAKE} complete
else
	cd doc/solps; ${MAKE} 
endif
ifeq ($(shell [ -d ${SOLPSTOP}/modules/DivGeo/equtrn/doxygen ] && echo yes || echo no ),no)
	cd modules/DivGeo/equtrn ; ${MAKE} DOC
endif

local:
	cd modules/Eirene; ${MAKE} local
	cd modules/B2.5;   ${MAKE} local

tags:
	cd modules/Carre;          ${MAKE} tags
	cd modules/Eirene;         ${MAKE} tags
	cd modules/B2.5;           ${MAKE} tags
	cd modules/Uinp;           ${MAKE} tags
	cd modules/Triang;         ${MAKE} tags
	cd modules/DivGeo;         ${MAKE} tags
	cd modules/DivGeo/convert; ${MAKE} tags
	cd modules/DivGeo/equtrn;  ${MAKE} tags
#	cd modules/solps4-5;       ${MAKE} tags
	rm -f TAGS ; etags -o TAGS modules/Carre/src/*/*.F modules/Carre/src/include/*.* modules/Eirene/src/*/*.f modules/Eirene/src/interfaces/*couple_SOLPS-ITER/*.f modules/Eirene/src/user-routines/user_iter/*.f modules/Eirene/src/geometry/trc-time-routines/*.f modules/Eirene/src/*/*.[Ff]90 modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.[Ff]90 modules/B2.5/src.local/*.F modules/B2.5/src/*/*.F modules/B2.5/src/*/*.F90 modules/B2.5/src/*/*.[Hh] modules/B2.5/src/common/*.* modules/B2.5/src/common/COUPLE/*.F modules/Uinp/src/*.F modules/Uinp/src/*.inc modules/Uinp/src/*.h modules/Triang/src/*/*.f modules/DivGeo/equtrn/src/*.f modules/DivGeo/equtrn/src/*.inc modules/DivGeo/convert/src/*.f modules/DivGeo/src/*.[ch] modules/DivGeo/dg.dgc

listobj:
	cd modules/Carre;          ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} listobj
	cd modules/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd modules/Triang;         ${MAKE} listobj
	cd modules/DivGeo;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
#	cd modules/solps4-5;       ${MAKE} listobj

depend:
	cd modules/Carre;          ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} depend
	cd modules/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend USE_MPI=-DUSE_MPI
	cd modules/Triang;         ${MAKE} depend
	cd modules/DivGeo;         ${MAKE} depend
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE 
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/amds;           ${MAKE} depend
#	cd modules/solps4-5;       ${MAKE} depend

VERSION:
	cd modules/B2.5;   ${MAKE} VERSION
	cd modules/Eirene; ${MAKE} VERSION
	cd modules/Carre;  ${MAKE} VERSION
	cd modules/DivGeo; ${MAKE} VERSION
	cd modules/Uinp;   ${MAKE} VERSION


# Debug targets
#--------------

debug: solps_debug

%_debug:
	${MAKE} $(@:%_debug=%) SOLPS_DEBUG=yes


# CI build tests
#--------------_

# Dependencies are not duplicated across build targets

nox_build:     clean_build     listobj depend carre_nox b25eirene_nox     uinp_nox     triang_nox

nox_build_mpi: clean_build_mpi listobj depend           b25eirene_mpi_nox uinp_mpi_nox


# Clean targets
#--------------


clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp     clean_triang clean_sonnet-light clean_manual

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp_mpi clean_triang clean_sonnet-light clean_manual

clean_build:     clean_carre clean_b25eirene clean_uinp clean_triang

clean_build_mpi: clean_b25eirene_mpi clean_uinp_mpi

clean_all:       clean_carre clean_divgeo clean_b25     clean_eirene     clean_b25eirene     clean_uinp     clean_triang clean_manual

clean_all_mpi:   clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp_mpi clean_triang clean_manual


clean_carre:
	cd modules/Carre; ${MAKE} clean


clean_divgeo:
	cd modules/DivGeo;         ${MAKE} clean
	cd modules/DivGeo/equtrn;  ${MAKE} clean
	cd modules/DivGeo/convert; ${MAKE} clean


clean_eirene:
	cd modules/Eirene; ${MAKE} clean

clean_eirene_mpi:
	cd modules/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI


clean_b25:
	cd modules/B2.5; ${MAKE} clean


clean_b25_mpi:
	cd modules/B2.5; ${MAKE} clean USE_MPI=-DUSE_MPI


clean_b25_ig:
	cd modules/B2.5; ${MAKE} clean USE_IMPGYRO=-DUSE_IMPGYRO


clean_b25eirene:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE


clean_b25eirene_mpi:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE   USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI

clean_b25eirene_ig:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

clean_uinp:
	cd modules/Uinp; ${MAKE} clean

clean_uinp_mpi:
	cd modules/Uinp; ${MAKE} clean USE_MPI=-DUSE_MPI

clean_triang:
	cd modules/Triang; ${MAKE} clean

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
	@echo "          solps : compile serial version (main codes)"
	@echo "      solps_mpi : compile MPI version (main codes)"
	@echo "    solps_debug : compile debug version (serial) (main codes)"
	@echo "solps_mpi_debug : compile debug version (MPI) (main codes)"
	@echo "            all : compile serial version (all codes)"
	@echo "        all_mpi : compile MPI version (all codes)"
	@echo "      all_debug : compile debug version (serial) (all codes)"
	@echo "  all_mpi_debug : compile debug version (MPI) (all codes)"
	@echo "            nox : compile serial version (no X main codes)"
	@echo "        nox_mpi : compile MPI version (no X main codes)"
	@echo "      nox_debug : compile debug version (serial) (no X main codes)"
	@echo "  nox_mpi_debug : compile debug version (MPI) (no X main codes)"
