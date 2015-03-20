# Test whether required environment variables are set
# If not, attempt to determine them automatically 
ifndef HOST
  ifeq ($(shell [ -e whereami ] && echo yes || echo no ),yes)
    HOST = $(shell echo `./whereami|tail -1`)
  else
    HOST =  default
  endif
  $(warning HOST not defined. Assuming ${HOST}.)
  export HOST
endif

ifndef OBJECTCODE
  OBJECTCODE = ifort64
  $(warning OBJECTCODE not defined. Using default compiler ifort64.)
  export OBJECTCODE
endif


# Include default compiler settings
ifeq ($(shell [ -e SETUP/config.${HOST}.${OBJECTCODE} ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST}.${OBJECTCODE}
  $(warning  Including SETUP/config.${HOST}.${OBJECTCODE})
else
  $(warning  SETUP/config.${HOST}.${OBJECTCODE} not found.)
endif

# Include local compiler settings, if present
ifeq ($(shell [ -e SETUP/config.${HOST}.${OBJECTCODE}.local ] && echo yes || echo no ),yes)
  include SETUP/config.${HOST}.${OBJECTCODE}.local
  $(warning  Including SETUP/config.${HOST}.${OBJECTCODE}.local)
endif

# Set SOLPSTOP if not already defined in the environment
export SOLPSTOP ?= ${PWD}
export SOLPSLIB ?= ${PWD}/lib/${HOST}.${OBJECTCODE}

BINDIR = ${PWD}/builds/${HOST}.${OBJECTCODE}

solps:     carre divgeo b25eirene     uinp triang sonnet-light manual

solps_mpi: carre divgeo b25eirene_mpi uinp triang sonnet-light manual


all:     carre divgeo b25     eirene     b25eirene     uinp triang manual

all_mpi: carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp triang manual


.PHONY: libs libs_mpi solps solps_mpi all all_mpi carre divgeo b25 b25_mpi eirene eirene_mpi b25eirene b25eirene_mpi manual depend tags clean clean_* VERSION


#libs:
#	cd lib; source install.sh


#libs_mpi:
#	cd lib; source install_mpi.sh


carre:
	cd src/Carre; ${MAKE}
#	@ln -sf ${BINDIR}/Carre/{carre,traduit,fcrr} ${BINDIR}


divgeo:
	cd src/DivGeo;         ${MAKE}
	cd src/DivGeo/equtrn;  ${MAKE}
	cd src/DivGeo/convert; ${MAKE}
#	@ln -sf ${BINDIR}/DivGeo/{dg,dg.dgc,dg.dgh} ${BINDIR}
#	@ln -sf ${BINDIR}/DivGeo/convert/{cnveir,cnvtria} ${BINDIR}
#	@ln -sf ${BINDIR}/DivGeo/equtrn/{cropequ,dg2dg,dg2ef,dg2vr,ef2dg,jt2dg,nk2dg,pb2dg,prinequ,pt2dg,risepsi,vr2dg} ${BINDIR}


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
#	@ln -sf ${BINDIR}/B25Eirene/Eirene/eirobj  ${BINDIR}
#	@ln -sf ${BINDIR}/B25Eirene/Eirene/eirobjx ${BINDIR}
	cd src/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE
#	@ln -sf ${BINDIR}/B25Eirene/B2.5/*.exe ${BINDIR}

b25eirene_mpi:
	cd src/Eirene; ${MAKE} USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
#	@ln -sf ${BINDIR}/B25Eirene.mpi/Eirene/eirobj  ${BINDIR}/eirobj.mpi
#	@ln -sf ${BINDIR}/B25Eirene.mpi/Eirene/eirobjx ${BINDIR}/eirobjx.mpi
	cd src/B2.5;   ${MAKE} USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
#	find -wholename "${BINDIR}/B25Eirene.mpi/*.exe" -exec ln -s {} "${BINDIR}" \;

uinp:
	cd src/Uinp; ${MAKE}
#	@ln -sf ${BINDIR}/Uinp/{uinp,ub2p} ${BINDIR}


triang:
	cd src/Triang; ${MAKE}
#	@ln -sf ${BINDIR}/Triang/{tria,triageom} ${BINDIR}

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






clean: clean_solps

clean_solps:     clean_carre clean_divgeo clean_b25eirene     clean_uinp clean_triang clean_sonnet-light

clean_solps_mpi: clean_carre clean_divgeo clean_b25eirene_mpi clean_uinp clean_triang clean_sonnet-light


clean_all:       clean_carre clean_divgeo clean_b25     clean_eirene     clean_b25eirene     clean_uinp clean_triang

clean_all_mpi:   clean_carre clean_divgeo clean_b25_mpi clean_eirene_mpi clean_b25eirene_mpi clean_uinp clean_triang



clean_carre:
	cd src/Carre; ${MAKE} clean
#	rm -f ${BINDIR}/{carre,traduit,fcrr}


clean_divgeo:
	cd src/DivGeo;         ${MAKE} clean
	cd src/DivGeo/equtrn;  ${MAKE} clean
	cd src/DivGeo/convert; ${MAKE} clean
#	rm -f ${BINDIR}/{dg,dg.dgc,dg.dgh}
#	rm -f ${BINDIR}/{cropequ,dg2dg,dg2ef,dg2vr,ef2dg,jt2dg,nk2dg,pb2dg,prinequ,pt2dg,risepsi,vr2dg}
#	rm -f ${BINDIR}/{cnveir,cnvtria}


clean_eirene:
	cd src/Eirene; ${MAKE} clean
#	rm -f ${BINDIR}/eirobj
#	rm -f ${BINDIR}/eirobjx


clean_eirene_mpi:
	cd src/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI
#	rm -f ${BINDIR}/eirobj.mpi
#	rm -f ${BINDIR}/eirobjx.mpi


clean_b25:
	cd src/B2.5; ${MAKE} clean


clean_b25_mpi:
	cd src/B2.5; ${MAKE} clean USE_MPI=-DUSE_MPI


clean_b25eirene:
	cd src/Eirene; ${MAKE} clean USE_B25=-DB25_EIRENE
	cd src/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE
#	rm -f ${BINDIR}/*.exe


clean_b25eirene_mpi:
	cd src/Eirene; ${MAKE} clean OUSE_B25=-DB25_EIRENE   USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI
#	rm -f ${BINDIR}/*.exe.mpi


clean_uinp:
	cd src/Uinp; ${MAKE} clean
#	rm -f ${BINDIR}/{uinp,ub2p}


clean_triang:
	cd src/Triang; ${MAKE} clean
#	rm -f ${BINDIR}/{tria,triageom}

clean_sonnet-light:
	cd src/Sonnet-light; ${MAKE} clean
