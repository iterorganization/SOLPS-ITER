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
  $(warning SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif

# Include local compiler settings, if present
ifeq ($(shell [ -e SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST_NAME}.${COMPILER}.local
endif

# Setup debug flag
EXT_DBG =
ifdef SOLPS_DEBUG
EXT_DBG = .debug
endif

# Setup MPI flag
EXT_MPI =
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif

# SOLPS_DEBUG and SOLPS_MPI will not be taken from environment,
# but will be passed by the corresponding make-targets 
unexport SOLPS_DEBUG
unexport SOLPS_MPI

.PHONY: solps solps_mpi nox nox_mpi all all_nox all_mpi all_nox_mpi carre carre_nox divgeo divgeo_nox b25 b25_mpi b25_nox b25_nox_mpi b25_ig b25_all_mpi eirene eirene_mpi eirene_nox eirene_nox_mpi b25eirene b25eirene_mpi b25eirene_nox b25eirene_nox_mpi b25eirene_ig b25eirene_all_mpi uinp uinp_nox uinp_mpi uinp_nox_mpi triang triang_mpi triang_nox triang_nox_mpi amds amds_mpi fxdr sonnet-light b2sxdr manual local depend depend_nox tags listobj listobj_nox clean clean_% debug %_debug VERSION help nox_build nox_build_mpi

DEFAULT: solps




# Basic compile targets
#----------------------


solps:       carre divgeo b25eirene     uinp     triang amds sonnet-light manual

solps_mpi:   carre divgeo b25eirene_mpi uinp_mpi triang_mpi amds_mpi sonnet-light manual

nox:         carre_nox divgeo_nox b25eirene_nox uinp_nox triang_nox manual

nox_mpi:     carre_nox divgeo_nox b25eirene_nox_mpi uinp_nox_mpi triang_nox_mpi manual

all:         carre divgeo b25     eirene     b25eirene     uinp     triang amds sonnet-light manual

all_nox:     carre_nox divgeo_nox b25_nox eirene_nox b25eirene_nox uinp_nox triang_nox manual

all_mpi:     carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp_mpi triang_mpi amds_mpi sonnet-light manual

all_nox_mpi: carre_nox divgeo_nox b25_nox_mpi eirene_nox_mpi b25eirene_nox_mpi uinp_nox_mpi triang_nox_mpi manual

carre:
	cd modules/Carre; ${MAKE}

carre_nox:
	cd modules/Carre; ${MAKE} NCARG_ROOT="" LD_NCARG=""

divgeo:
	cd modules/DivGeo;         ${MAKE}
	cd modules/DivGeo/equtrn;  ${MAKE}
	cd modules/DivGeo/convert; ${MAKE}

divgeo_nox:
	cd modules/DivGeo/equtrn;  ${MAKE}
	cd modules/DivGeo/convert; ${MAKE}

eirene:
	cd modules/Eirene; ${MAKE}

eirene_mpi:
	cd modules/Eirene; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes

eirene_nox:
	cd modules/Eirene; ${MAKE} LD_GR="" LD_GKS=""

eirene_nox_mpi:
	cd modules/Eirene; ${MAKE} USE_MPI=-DUSE_MPI LD_GR="" LD_GKS="" SOLPS_MPI=yes

b25:
	cd modules/B2.5; ${MAKE}

b25_all:
	cd modules/solps4-5; ${MAKE} links
	cd modules/B2.5;     ${MAKE} ALL

b25_mpi:
	cd modules/B2.5; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes

b25_nox:
	cd modules/B2.5; ${MAKE} NOPLOT

b25_ig:
	cd modules/B2.5; ${MAKE} USE_IMPGYRO=-DUSE_IMPGYRO

b25_nox_mpi:
	cd modules/B2.5; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes NOPLOT

b25_all_mpi:
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes ALL

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
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes

b25eirene_nox_mpi:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes  LD_GR="" LD_GKS=""
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes NOPLOT

b25eirene_ig:
	cd modules/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO

b25eirene_all_mpi:
	cd modules/Eirene;   ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/solps4-5; ${MAKE} SOLPS_MPI=yes links
	cd modules/B2.5;     ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes ALL

uinp:
	cd modules/Uinp; ${MAKE}

uinp_nox: uinp

uinp_mpi:
	cd modules/Uinp; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes

uinp_nox_mpi: uinp_mpi

triang:
	cd modules/Triang; ${MAKE}

triang_mpi:
	cd modules/Triang; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes

triang_nox:
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS="" mods
	cd modules/Triang; ${MAKE} LD_GR="" LD_GKS=""

triang_nox_mpi:
	cd modules/Triang; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS="" mods
	cd modules/Triang; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""

amds:
	cd modules/amds; ${MAKE}

amds_mpi:
	cd modules/amds; ${MAKE} USE_MPI=-DUSE_MPI SOLPS_MPI=yes

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
	rm -f TAGS ; etags -o TAGS modules/Carre/src.local/*.F modules/Carre/src/*/*.F modules/Carre/src/include/*.* modules/Eirene/src.local/*.f modules/Eirene/src/*/*.f modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.f modules/Eirene/src/user-routines/user_iter/*.f modules/Eirene/src/geometry/time-routines/*.F modules/Eirene/src/*/*.[Ff]90 modules/Eirene/src/interfaces/couple_SOLPS-ITER/*.[Ff]90 modules/B2.5/src.local/*.F modules/B2.5/src/*/*.F modules/B2.5/src/*/*.F90 modules/B2.5/src/*/*.[Hh] modules/B2.5/src/common/*.* modules/B2.5/src/common/COUPLE/*.F modules/B2.5/src/documentation/*.xml modules/Uinp/src/*.F modules/Uinp/src/*.inc modules/Uinp/src/*.h modules/Triang/src/*/*.f modules/DivGeo/equtrn/src/*.f modules/DivGeo/equtrn/src/*.inc modules/DivGeo/convert/src/*.f modules/DivGeo/src/*.[ch] modules/DivGeo/dg.dgc modules/solps4-5/src/*.F || touch TAGS

listobj:
	cd modules/Carre;          ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Eirene;         ${MAKE} listobj
	cd modules/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Triang;         ${MAKE} listobj
	cd modules/Triang;         ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/DivGeo;         ${MAKE} listobj
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
#	cd modules/solps4-5;       ${MAKE} listobj

listobj_nox:
	cd modules/Carre;          ${MAKE} listobj NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS="" SOLPS_MPI=yes
	cd modules/Eirene;         ${MAKE} listobj LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} listobj LD_GR="" LD_GKS=""
	cd modules/Uinp;           ${MAKE} listobj
	cd modules/Uinp;           ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Triang;         ${MAKE} listobj LD_GR="" LD_GKS=""
	cd modules/Triang;         ${MAKE} listobj USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS="" 
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO LD_GR="" LD_GKS=""
#	cd modules/solps4-5;       ${MAKE} listobj

depend:
	cd modules/Carre;          ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Eirene;         ${MAKE} depend
	cd modules/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Triang;         ${MAKE} depend
	cd modules/Triang;         ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/DivGeo;         ${MAKE} depend
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE 
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO
	cd modules/amds;           ${MAKE} depend
#	cd modules/solps4-5;       ${MAKE} depend

depend_nox:
	cd modules/Carre;          ${MAKE} depend NCARG_ROOT="" LD_NCARG=""
	cd modules/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/Eirene;         ${MAKE} depend LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} depend LD_GR="" LD_GKS=""
	cd modules/Uinp;           ${MAKE} depend
	cd modules/Uinp;           ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/Triang;         ${MAKE} depend LD_GR="" LD_GKS=""
	cd modules/Triang;         ${MAKE} depend USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/DivGeo/equtrn;  ${MAKE} depend
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_IMPGYRO=-DUSE_IMPGYRO LD_GR="" LD_GKS=""

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
#---------------

# Dependencies are not duplicated across build targets

nox_build:     clean_build     listobj_nox depend_nox carre_nox divgeo_nox b25eirene_nox     uinp_nox     triang_nox

nox_build_mpi: clean_build_mpi listobj_nox depend_nox           divgeo_nox b25eirene_nox_mpi uinp_nox_mpi triang_nox_mpi


# Clean targets
#--------------


clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp     clean_triang clean_sonnet-light clean_manual clean_amds

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_sonnet-light clean_manual clean_amds

clean_build:     clean_carre clean_b25eirene clean_uinp clean_triang_nox

clean_build_mpi: clean_b25eirene_mpi clean_uinp_mpi

clean_all:       clean_carre clean_divgeo clean_b25     clean_eirene     clean_b25eirene     clean_uinp     clean_triang clean_manual

clean_all_nox:   clean_carre_nox clean_divgeo_nox clean_b25_nox clean_eirene_nox clean_b25eirene_nox clean_uinp clean_triang_nox clean_manual

clean_all_mpi:   clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp_mpi clean_triang_mpi clean_manual

clean_all_nox_mpi: clean_carre_nox clean_divgeo_nox clean_b25_nox_mpi clean_eirene_nox_mpi clean_b25eirene_nox_mpi clean_uinp_mpi clean_triang_nox_mpi clean_manual

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
	cd modules/Eirene; ${MAKE} clean

clean_eirene_nox:
	cd modules/Eirene; ${MAKE} clean LD_GR="" LD_GKS=""

clean_eirene_mpi:
	cd modules/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes

clean_eirene_nox_mpi:
	cd modules/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""

clean_b25:
	cd modules/B2.5; ${MAKE} clean

clean_b25_mpi:
	cd modules/B2.5; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes

clean_b25_nox:
	cd modules/B2.5; ${MAKE} clean LD_GR="" LD_GKS=""

clean_b25_nox_mpi:
	cd modules/B2.5; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""

clean_b25_ig:
	cd modules/B2.5; ${MAKE} clean USE_IMPGYRO=-DUSE_IMPGYRO

clean_b25eirene:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE

clean_b25eirene_mpi:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes

clean_b25eirene_nox:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE LD_GR="" LD_GKS=""
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE LD_GR="" LD_GKS=""

clean_b25eirene_nox_mpi:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""
	cd modules/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""

clean_b25eirene_ig:
	cd modules/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE    USE_IMPGYRO=-DUSE_IMPGYRO

clean_uinp:
	cd modules/Uinp; ${MAKE} clean

clean_uinp_mpi:
	cd modules/Uinp; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes

clean_triang:
	cd modules/Triang; ${MAKE} clean

clean_triang_mpi:
	cd modules/Triang; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes

clean_triang_nox:
	cd modules/Triang; ${MAKE} clean LD_GR="" LD_GKS=""

clean_triang_nox_mpi:
	cd modules/Triang; ${MAKE} clean USE_MPI=-DUSE_MPI SOLPS_MPI=yes LD_GR="" LD_GKS=""

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
	@echo "            solps : compile serial version (main codes)"
	@echo "        solps_mpi : compile MPI version (main codes)"
	@echo "      solps_debug : compile debug version (serial) (main codes)"
	@echo "  solps_mpi_debug : compile debug version (MPI) (main codes)"
	@echo "              all : compile serial version (all codes)"
	@echo "          all_mpi : compile MPI version (all codes)"
	@echo "        all_debug : compile debug version (serial) (all codes)"
	@echo "    all_mpi_debug : compile debug version (MPI) (all codes)"
	@echo "              nox : compile serial version (no X main codes)"
	@echo "          all_nox : compile serial version (all no X codes)"
	@echo "          nox_mpi : compile MPI version (no X main codes)"
	@echo "      all_nox_mpi : compile MPI version (all no X codes)"
	@echo "        nox_debug : compile debug version (serial) (no X main codes)"
	@echo "    all_nox_debug : compile debug version (serial) (all no X codes)"
	@echo "    nox_mpi_debug : compile debug version (MPI) (no X main codes)"
	@echo "all_nox_mpi_debug : compile debug version (MPI) (all no X codes)"
