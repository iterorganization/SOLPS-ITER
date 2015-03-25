# Test whether required environment variables are set
# If not, attempt to determine them automatically

# Identify HOST 
ifndef HOST
  ifeq ($(shell [ -e whereami ] && echo yes || echo no ),yes)
    # Identify host from whereami-script
    HOST = $(shell echo `./whereami|tail -1`)
    ifneq (,$(findstring UNKNOWN,${HOST}))
      # If no specific host identified, use default settings
      HOST = default
    endif
  else
    # If whereami-script not found, use default settings 
    HOST = default
  endif
  export HOST
  ifeq (${HOST},default)
    $(warning HOST not recognized. Using ${HOST})
  endif
endif

# Identify compiler
ifndef COMPILER
  ifeq ($(shell [ -e setup.COMPILER.test ] && echo yes || echo no ),yes)
    # Identify compiler from setup.COMPILER-script
    COMPILER = $(shell echo `./setup.COMPILER.test|tail -1`)
  else
    # If script not found, use default compiler ifort64
    COMPILER = ifort64
    $(warning Using default compiler ${COMPILER})
  endif
  export COMPILER
endif

# Set SOLPSTOP and SOLPSLIB if not already defined in the environment
export SOLPSTOP ?= ${PWD}
export SOLPSLIB ?= ${PWD}/lib/${HOST}.${COMPILER}

# Include compiler settings
ifeq ($(shell [ -e SETUP/config.${HOST}.${COMPILER} ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST}.${COMPILER}
else
  $(warning  SETUP/config.${HOST}.${COMPILER} not found.)
endif

# Include local compiler settings, if present
ifeq ($(shell [ -e SETUP/config.${HOST}.${COMPILER}.local ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST}.${COMPILER}.local
endif

.PHONY: solps solps_mpi all all_mpi carre divgeo b25 b25_mpi eirene eirene_mpi b25eirene b25eirene_mpi uinp triang sonnet-light manual depend tags clean clean_% debug_% VERSION


# Basic compile targets
#----------------------


solps:     carre divgeo b25eirene     uinp triang sonnet-light manual

solps_mpi: carre divgeo b25eirene_mpi uinp triang sonnet-light manual


all:     carre divgeo b25     eirene     b25eirene     uinp triang sonnet-light manual

all_mpi: carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp triang sonnet-light manual


carre:
	cd src/Carre; ${MAKE}


divgeo:
	cd src/DivGeo;         ${MAKE}
	cd src/DivGeo/equtrn;  ${MAKE}
	cd src/DivGeo/convert; ${MAKE}


eirene:
	cd src/Eirene; ${MAKE}

eirene_mpi:
	cd src/Eirene; ${MAKE} USE_MPI=-DUSE_MPI


b25:
	cd src/B2.5; ${MAKE}

b25_mpi:
	cd src/B2.5; ${MAKE} USE_MPI=-DUSE_MPI


b25eirene:
	cd src/Eirene; ${MAKE} USE_B25=-DB25_EIRENE
	cd src/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE

b25eirene_mpi:
	cd src/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI

uinp:
	cd src/Uinp; ${MAKE}


triang:
	cd src/Triang; ${MAKE}


sonnet-light:
	-mkdir -p ${SOLPSLIB}
	cd src/Sonnet-light; ${MAKE} all; ${MAKE} install INSTALL_USERAREA=${SOLPSLIB}


manual:
	cd doc/solps; ${MAKE}


tags:
	cd src/Carre;          ${MAKE} tags
	cd src/Eirene;         ${MAKE} tags
	cd src/B2.5;           ${MAKE} tags
	cd src/Uinp;           ${MAKE} tags
	cd src/Triang;         ${MAKE} tags
	cd src/DivGeo;         ${MAKE} tags
	cd src/DivGeo/equtrn;  ${MAKE} tags
	rm -f TAGS ; etags -o TAGS src/Carre/src/*/*.F src/Carre/src/include/*.* src/Eirene/*/*.f src/Eirene/interfaces/*/*.f src/Eirene/user-routines/*/*.f src/Eirene/*/*.[Ff]90 src/B2.5/src.local/*.F src/B2.5/src/*/*.F src/B2.5/src/*/*.[Hh] src/B2.5/src/common/*.* src/B2.5/src/common/COUPLE/*.F src/Uinp/src/*.F src/Uinp/src/*.inc src/Uinp/src/*.h src/Triang/src/*/*.f src/DivGeo/equtrn/src/*.f src/DivGeo/equtrn/src/*.inc src/DivGeo/convert/src/*.f src/DivGeo/src/*.[ch]

listobj:
	cd src/Carre;          ${MAKE} listobj
	cd src/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd src/Eirene;         ${MAKE} listobj
	cd src/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} listobj
	cd src/Uinp;           ${MAKE} listobj
	cd src/Triang;         ${MAKE} listobj
	cd src/DivGeo;         ${MAKE} listobj
	cd src/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE
	cd src/Eirene;         ${MAKE} listobj USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE
	cd src/B2.5;           ${MAKE} listobj USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI

depend:
	cd src/Carre;          ${MAKE} depend
	cd src/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI
	cd src/Eirene;         ${MAKE} depend
	cd src/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} depend
	cd src/Uinp;           ${MAKE} depend
	cd src/Triang;         ${MAKE} depend
	cd src/DivGeo;         ${MAKE} depend
	cd src/DivGeo/equtrn;  ${MAKE} depend
	cd src/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE 
	cd src/Eirene;         ${MAKE} depend USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE
	cd src/B2.5;           ${MAKE} depend USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI

VERSION:
	cd src/B2.5;   ${MAKE} VERSION
	cd src/Eirene; ${MAKE} VERSION
	cd src/Carre;  ${MAKE} VERSION
	cd src/DivGeo; ${MAKE} VERSION



# Debug targets
#--------------


debug_%:
	${MAKE} $(@:debug_%=%) SOLPS_DEBUG=yes




# Clean targets
#--------------


clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp clean_triang clean_sonnet-light

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp clean_triang clean_sonnet-light


clean_all:       clean_carre clean_divgeo clean_b25     clean_eirene     clean_b25eirene     clean_uinp clean_triang

clean_all_mpi:   clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp clean_triang



clean_carre:
	cd src/Carre; ${MAKE} clean


clean_divgeo:
	cd src/DivGeo;         ${MAKE} clean
	cd src/DivGeo/equtrn;  ${MAKE} clean
	cd src/DivGeo/convert; ${MAKE} clean


clean_eirene:
	cd src/Eirene; ${MAKE} clean

clean_eirene_mpi:
	cd src/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI


clean_b25:
	cd src/B2.5; ${MAKE} clean


clean_b25_mpi:
	cd src/B2.5; ${MAKE} clean USE_MPI=-DUSE_MPI


clean_b25eirene:
	cd src/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE
	cd src/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE


clean_b25eirene_mpi:
	cd src/Eirene; ${MAKE} clean OUSE_B25=-DB25_EIRENE   USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI


clean_uinp:
	cd src/Uinp; ${MAKE} clean


clean_triang:
	cd src/Triang; ${MAKE} clean

clean_sonnet-light:
	cd src/Sonnet-light; ${MAKE} clean
