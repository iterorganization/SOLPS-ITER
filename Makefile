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

.PHONY: solps solps_mpi all all_mpi carre divgeo b25 b25_mpi eirene eirene_mpi b25eirene b25eirene_mpi uinp triang sonnet-light b2sxdr manual depend tags clean clean_% %_debug VERSION

DEFAULT: solps




# Basic compile targets
#----------------------


solps:     carre divgeo b25eirene     uinp triang sonnet-light manual

solps_mpi: carre divgeo b25eirene_mpi uinp triang sonnet-light manual


all:     carre divgeo b25     eirene     b25eirene     uinp triang sonnet-light manual

all_mpi: carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp triang sonnet-light manual


carre:
	cd modules/Carre; ${MAKE} SOLPS_DEBUG=""


divgeo:
	cd modules/DivGeo;         ${MAKE}
	cd modules/DivGeo/equtrn;  ${MAKE}
	cd modules/DivGeo/convert; ${MAKE}


eirene:
	cd modules/Eirene; ${MAKE}

eirene_mpi:
	cd modules/Eirene; ${MAKE} USE_MPI=-DUSE_MPI


b25:
	cd modules/B2.5; ${MAKE}

b25_mpi:
	cd modules/B2.5; ${MAKE} USE_MPI=-DUSE_MPI


b25eirene:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE

b25eirene_mpi:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI


uinp:
	cd modules/Uinp; ${MAKE}


triang:
	cd modules/Triang; ${MAKE}


sonnet-light:
	@-mkdir -p ${SOLPSLIB}
ifeq ($(shell [ -e ${SOLPSLIB}/libsonnet.a ] && echo yes || echo no ),no)
	cd modules/Sonnet-light; ${MAKE} all; ${MAKE} install INSTALL_USERAREA=${SOLPSLIB}
endif

b2sxdr:   # strange sequence of commands, but works!
	cd modules/solps4-5; ${MAKE} tags
	cd modules/solps4-5; ${MAKE} listobj
	cd modules/solps4-5; ${MAKE} depend
	cd modules/solps4-5; ${MAKE}; ${MAKE}; rm builds/${HOST_NAME}.${COMPILER}${EXT_DBG}/libb2_solps?.a; ${MAKE}

manual:
	cd doc/solps; ${MAKE}


tags:
	cd modules/Carre;          ${MAKE} tags
	cd modules/Eirene;         ${MAKE} tags
	cd modules/B2.5;           ${MAKE} tags
	cd modules/Uinp;           ${MAKE} tags
	cd modules/Triang;         ${MAKE} tags
	cd modules/DivGeo;         ${MAKE} tags
	cd modules/DivGeo/equtrn;  ${MAKE} tags
#	cd modules/solps4-5;       ${MAKE} tags
	rm -f TAGS ; etags -o TAGS modules/Carre/src/*/*.F modules/Carre/src/include/*.* modules/Eirene/*/*.f modules/Eirene/interfaces/*/*.f modules/Eirene/user-routines/*/*.f modules/Eirene/interfaces/*/*.[Ff]90 modules/B2.5/src.local/*.F modules/B2.5/src/*/*.F modules/B2.5/src/*/*.[Hh] modules/B2.5/src/common/*.* modules/B2.5/src/common/COUPLE/*.F modules/Uinp/src/*.F modules/Uinp/src/*.inc modules/Uinp/src/*.h modules/Triang/src/*/*.f modules/DivGeo/equtrn/src/*.f modules/DivGeo/equtrn/src/*.inc modules/DivGeo/convert/src/*.f modules/DivGeo/src/*.[ch]

listobj:
	cd modules/Carre;          ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} listobj
	cd modules/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Triang;         ${MAKE} listobj
	cd modules/DivGeo;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
#	cd modules/solps4-5;       ${MAKE} listobj

depend:
	cd modules/Carre;          ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI
	cd modules/Eirene;         ${MAKE} depend
	cd modules/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Triang;         ${MAKE} depend
	cd modules/DivGeo;         ${MAKE} depend
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE 
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
#	cd modules/solps4-5;       ${MAKE} depend

VERSION:
	cd modules/B2.5;   ${MAKE} VERSION
	cd modules/Eirene; ${MAKE} VERSION
	cd modules/Carre;  ${MAKE} VERSION
	cd modules/DivGeo; ${MAKE} VERSION



# Debug targets
#--------------

debug: solps_debug

%_debug:
	${MAKE} $(@:%_debug=%) SOLPS_DEBUG=yes


# Compile with no graphics
#-------------------------

nox: manual
	cd modules/Carre; ${MAKE} NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE NOPLOT
	cd modules/Uinp; ${MAKE}
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS="" mods
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS=""

nox_mpi: manual
	cd modules/Carre; ${MAKE} NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE LD_GR=""  LD_GKS="" USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI NOPLOT
	cd modules/Uinp; ${MAKE}
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS="" mods
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS=""


# Clean targets
#--------------


clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp clean_triang clean_sonnet-light clean_manual

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp clean_triang clean_sonnet-light clean_manual


clean_all:       clean_carre clean_divgeo clean_b25     clean_eirene     clean_b25eirene     clean_uinp clean_triang clean_manual

clean_all_mpi:   clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp clean_triang clean_manual



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


clean_b25eirene:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE


clean_b25eirene_mpi:
	cd modules/Eirene; ${MAKE} clean OUSE_B25=-DB25_EIRENE   USE_MPI=-DUSE_MPI
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI


clean_uinp:
	cd modules/Uinp; ${MAKE} clean


clean_triang:
	cd modules/Triang; ${MAKE} clean

clean_sonnet-light:
	cd modules/Sonnet-light; ${MAKE} clean

clean_b2sxdr:
	cd modules/solps4-5; ${MAKE} clean

clean_manual:
	cd doc/solps; ${MAKE} clean