
pwd = ${PWD}
OBJDIR = 

all: carre divgeo eirene b25 uinp triang solps manual

.PHONY: divgeo eirene b25 solps manual mpi nompi depend tags clean clean_*

carre:
	cd src/Carre; ${MAKE} 

divgeo:
	cd src/DivGeo;         ${MAKE}
	cd src/DivGeo/equtrn;  ${MAKE}
	cd src/DivGeo/convert; ${MAKE}

eirene:
	cd src/Eirene; ${MAKE} USE_MPI=-DUSE_MPI
	cd src/Eirene; ${MAKE} 

b25:
	cd src/B2.5; ${MAKE} 

uinp:
	cd src/uinp; ${MAKE}

triang:
	cd src/Triang; ${MAKE}

nompi: triang
	cd src/Carre;          ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/equtrn/cropequ bin/${OBJECTCODE}/cropequ
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/equtrn/dg2dg bin/${OBJECTCODE}/dg2dg
	cd src/DivGeo/convert; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/convert/cnveir bin/${OBJECTCODE}/cnveir
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_B25=-DUSE_B25
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5.nompi OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_EIRENE=-DUSE_EIRENE
	cd src/uinp;           ${MAKE}

mpi: 
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI

solps: triang
	cd src/Carre;          ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/equtrn/cropequ bin/${OBJECTCODE}/cropequ
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/equtrn/dg2dg bin/${OBJECTCODE}/dg2dg
	cd src/DivGeo/convert; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert
	@ln -sf ${SOLPSTOP}/bin/${OBJECTCODE}/DivGeo/convert/cnveir bin/${OBJECTCODE}/cnveir
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_B25=-DUSE_B25
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5.nompi OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_EIRENE=-DUSE_EIRENE
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI
	cd src/uinp;           ${MAKE}

manual:
	cd doc/solps; ${MAKE}

tags:
	cd src/Carre;          ${MAKE} tags
	cd src/Eirene;         ${MAKE} tags
	cd src/B2.5;           ${MAKE} tags
	cd src/uinp;           ${MAKE} tags
	cd src/Triang;         ${MAKE} tags
	cd src/DivGeo;         ${MAKE} tags
	cd src/DivGeo/equtrn;  ${MAKE} tags

listobj:
	cd src/Carre;          ${MAKE} listobj
	cd src/Eirene;         ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd src/Eirene;         ${MAKE} listobj
	cd src/B2.5;           ${MAKE} listobj USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} listobj
	cd src/uinp;           ${MAKE} listobj
	cd src/Triang;         ${MAKE} listobj
	cd src/DivGeo;         ${MAKE} listobj
	cd src/Carre;          ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre listobj
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo listobj
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_B25=-DUSE_B25 listobj
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI listobj
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5.nompi OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE listobj
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI listobj

depend:
	cd src/Carre;          ${MAKE} depend
	cd src/Eirene;         ${MAKE} depend USE_MPI=-DUSE_MPI
	cd src/Eirene;         ${MAKE} depend
	cd src/B2.5;           ${MAKE} depend USE_MPI=-DUSE_MPI
	cd src/B2.5;           ${MAKE} depend
	cd src/uinp;           ${MAKE} depend
	cd src/Triang;         ${MAKE} depend
	cd src/DivGeo;         ${MAKE} depend
	cd src/DivGeo/equtrn;  ${MAKE} depend
	cd src/Carre;          ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre depend
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo depend
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn depend
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi USE_B25=-DUSE_B25 depend
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI depend
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5.nompi OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE depend
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI depend

clean: clean_carre clean_divgeo clean_b2eirene clean_uinp clean_triang

clean_carre:
	cd src/Carre; ${MAKE} clean
	cd src/Carre; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre

clean_divgeo:
	cd src/DivGeo;         ${MAKE} clean
	cd src/DivGeo/equtrn;  ${MAKE} clean
	cd src/DivGeo/convert; ${MAKE} clean
	cd src/DivGeo;         ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert

clean_b2eirene:
	cd src/Eirene; ${MAKE} clean USE_MPI=-DUSE_MPI
	cd src/Eirene; ${MAKE} clean 
	cd src/B2.5;   ${MAKE} clean USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean
	cd src/Eirene; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi
	cd src/Eirene; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5.nompi OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene.nompi
	cd src/B2.5;   ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_MPI=-DUSE_MPI

clean_uinp:
	cd src/uinp; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/uinp

clean_triang:
	cd src/Triang; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Triang

