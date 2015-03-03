
BINDIR = ${PWD}/bin/${OBJECTCODE}

all: carre divgeo b2eirene uinp triang manual

solps: carre divgeo b2eirene uinp triang manual

.PHONY: all divgeo b2eirene eirene b25 solps manual mpi nompi depend tags clean clean_*

carre:
	cd src/Carre; ${MAKE} OBJDIR=${BINDIR}/Carre
	@ln -sf ${BINDIR}/Carre/carre ${BINDIR}

divgeo:
	cd src/DivGeo;         ${MAKE} OBJDIR=${BINDIR}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${BINDIR}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} OBJDIR=${BINDIR}/DivGeo/convert
	@ln -sf ${BINDIR}/DivGeo/dg ${BINDIR}
	@ln -sf ${BINDIR}/DivGeo/convert/{cnveir,cnvtria} ${BINDIR}
	@ln -sf ${BINDIR}/DivGeo/equtrn/{cropequ,dg2dg,dg2ef,dg2vr,ef2dg,jt2dg,nk2dg,pb2dg,prinequ,pt2dg,risepsi,vr2dg} ${BINDIR}

eirene:
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/Eirene       USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/Eirene.nompi USE_B25=-DUSE_B25

b25:
	cd src/B2.5; ${MAKE} OBJDIR=${BINDIR}/B2.5       OBJDIREIR=${BINDIR}/Eirene       USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI
	cd src/B2.5; ${MAKE} OBJDIR=${BINDIR}/B2.5.nompi OBJDIREIR=${BINDIR}/Eirene.nompi USE_EIRENE=-DUSE_EIRENE

b2eirene:
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/Eirene USE_B25=-DUSE_B25
	cd src/B2.5;   ${MAKE} OBJDIR=${BINDIR}/B2.5 OBJDIREIR=${BINDIR}/Eirene USE_EIRENE=-DUSE_EIRENE

uinp:
	cd src/uinp; ${MAKE} OBJDIR=${BINDIR}/uinp

triang:
	cd src/Triang; ${MAKE} OBJDIR=${BINDIR}/triang

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
#	cd src/Carre;          ${MAKE} OBJDIR=${BINDIR}/Carre listobj
#	cd src/DivGeo;         ${MAKE} OBJDIR=${BINDIR}/DivGeo listobj
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/Eirene.nompi USE_B25=-DUSE_B25 listobj
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI listobj
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/B2.5.nompi OBJDIREIR=${BINDIR}/Eirene USE_EIRENE=-DUSE_EIRENE listobj
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/B2.5 OBJDIREIR=${BINDIR}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI listobj

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
#	cd src/Carre;          ${MAKE} OBJDIR=${BINDIR}/Carre depend
#	cd src/DivGeo;         ${MAKE} OBJDIR=${BINDIR}/DivGeo depend
#	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${BINDIR}/DivGeo/equtrn depend
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/Eirene.nompi USE_B25=-DUSE_B25 depend
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/Eirene USE_B25=-DUSE_B25 USE_MPI=-DUSE_MPI depend
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/B2.5.nompi OBJDIREIR=${BINDIR}/Eirene USE_EIRENE=-DUSE_EIRENE depend
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/B2.5 OBJDIREIR=${BINDIR}/Eirene USE_EIRENE=-DUSE_EIRENE USE_MPI=-DUSE_MPI depend




clean: clean_carre clean_divgeo clean_b2eirene clean_uinp clean_triang

clean_carre:
	cd src/Carre; ${MAKE} clean OBJDIR=${BINDIR}/Carre
#	rm ${BINDIR}/Carre/carre ${BINDIR}

clean_divgeo:
	cd src/DivGeo;         ${MAKE} clean OBJDIR=${BINDIR}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} clean OBJDIR=${BINDIR}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} clean OBJDIR=${BINDIR}/DivGeo/convert
#	rm ${BINDIR}/DivGeo/dg ${BINDIR}
#	rm ${BINDIR}/DivGeo/equtrn/{cropequ,dg2dg,dg2ef,dg2vr,ef2dg,jt2dg,nk2dg,pb2dg,prinequ,pt2dg,risepsi,vr2dg} ${BINDIR}
#	rm ${BINDIR}/DivGeo/convert/{cnveir,cnvtria} ${BINDIR}

clean_b2eirene:
	cd src/Eirene; ${MAKE} clean OBJDIR=${BINDIR}/Eirene.nompi
	cd src/Eirene; ${MAKE} clean OBJDIR=${BINDIR}/Eirene          USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean OBJDIR=${BINDIR}/B2.5.nompi OBJDIREIR=${BINDIR}/Eirene.nompi
	cd src/B2.5;   ${MAKE} clean OBJDIR=${BINDIR}/B2.5       OBJDIREIR=${BINDIR}/Eirene         USE_MPI=-DUSE_MPI

clean_uinp:
	cd src/uinp; ${MAKE} clean OBJDIR=${BINDIR}/uinp

clean_triang:
	cd src/Triang; ${MAKE} clean OBJDIR=${BINDIR}/Triang
