
BINDIR = ${PWD}/bin/${OBJECTCODE}


solps: carre divgeo b25eirene uinp triang manual

solps_mpi: carre divgeo b25eirene_mpi uinp triang manual

all: carre divgeo b25 eirene b25eirene uinp triang manual

all_mpi: carre divgeo b25_mpi eirene_mpi b25eirene_mpi uinp triang manual

.PHONY: solps solps_mpi all all_mpi carre divgeo b25 b25_mpi eirene eirene_mpi b25eirene b25eirene_mpi manual depend tags clean clean_* VERSION


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
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/Eirene
	@ln -sf ${BINDIR}/Eirene/eirobj  ${BINDIR}
	@ln -sf ${BINDIR}/Eirene/eirobjx ${BINDIR}

eirene_mpi:
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/Eirene.mpi USE_MPI=-DUSE_MPI
	@ln -sf ${BINDIR}/Eirene.mpi/eirobj  ${BINDIR}/eirobj.mpi
	@ln -sf ${BINDIR}/Eirene.mpi/eirobjx ${BINDIR}/eirobjx.mpi


b25:
	cd src/B2.5; ${MAKE} OBJDIR=${BINDIR}/B2.5 

b25_mpi:
	cd src/B2.5; ${MAKE} OBJDIR=${BINDIR}/B2.5.mpi USE_MPI=-DUSE_MPI


b25eirene:
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/b25eirene/Eirene USE_B25=-DB25_EIRENE
	cd src/B2.5;   ${MAKE} OBJDIR=${BINDIR}/b25eirene/B2.5   USE_EIRENE=-DB25_EIRENE

b25eirene_mpi:
	cd src/Eirene; ${MAKE} OBJDIR=${BINDIR}/b25eirene.mpi/Eirene USE_B25=-DB25_EIRENE    USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} OBJDIR=${BINDIR}/b25eirene.mpi/B2.5   USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI


uinp:
	cd src/uinp; ${MAKE}

triang:
	cd src/Triang; ${MAKE}

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
	rm -f TAGS ; etags -o TAGS src/Carre/src/*/*.F src/Carre/src/include/*.* src/Eirene/*/*.f src/Eirene/interfaces/*/*.f src/Eirene/*/*.[Ff]90 src/B2.5/src.local/*.F src/B2.5/src/*/*.F src/B2.5/src/*/*.[Hh] src/B2.5/src/common/*.* src/B2.5/src/common/COUPLE/*.F src/uinp/src/*.F src/uinp/src/*.inc src/uinp/src/*.h src/Triang/src/*/*.f src/DivGeo/equtrn/src/*.f src/DivGeo/equtrn/src/*.inc src/DivGeo/convert/src/*.f src/DivGeo/src/*.[ch]

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
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/Eirene USE_B25=-DB25_EIRENE listobj
#	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/b25eirene/Eirene USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI listobj
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/b25eirene/B2.5 OBJDIREIR=${BINDIR}/b25eirene/Eirene USE_EIRENE=-DB25_EIRENE listobj
#	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/B2.5 OBJDIREIR=${BINDIR}/b25eirene/Eirene USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI listobj

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
	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/b25eirene/Eirene USE_B25=-DB25_EIRENE depend
	cd src/Eirene;         ${MAKE} OBJDIR=${BINDIR}/b25eirene.mpi/Eirene USE_B25=-DB25_EIRENE USE_MPI=-DUSE_MPI depend
	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/b25eirene/B2.5 OBJDIREIR=${BINDIR}/b25eirene/Eirene USE_EIRENE=-DB25_EIRENE depend
	cd src/B2.5;           ${MAKE} OBJDIR=${BINDIR}/b25eirene.mpi/B2.5 OBJDIREIR=${BINDIR}/b25eirene/Eirene USE_EIRENE=-DB25_EIRENE USE_MPI=-DUSE_MPI depend

VERSION:
	cd src/B2.5;   rm src.local/git_version.h;   ${MAKE} VERSION
	cd src/Eirene; rm local/git_version.h;       ${MAKE} VERSION
	cd src/Carre;  rm src/include/git_version.h; ${MAKE} VERSION
	cd src/DivGeo; rm src/git_version.h;         ${MAKE} VERSION

clean: clean_carre clean_divgeo clean_b25eirene clean_uinp clean_triang

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

clean_b25eirene:
	cd src/Eirene; ${MAKE} clean OBJDIR=${BINDIR}/Eirene.nompi
	cd src/Eirene; ${MAKE} clean OBJDIR=${BINDIR}/Eirene          USE_MPI=-DUSE_MPI
	cd src/B2.5;   ${MAKE} clean OBJDIR=${BINDIR}/B2.5.nompi OBJDIREIR=${BINDIR}/Eirene.nompi
	cd src/B2.5;   ${MAKE} clean OBJDIR=${BINDIR}/B2.5       OBJDIREIR=${BINDIR}/Eirene         USE_MPI=-DUSE_MPI

clean_uinp:
	cd src/uinp; ${MAKE} clean OBJDIR=${BINDIR}/uinp

clean_triang:
	cd src/Triang; ${MAKE} clean OBJDIR=${BINDIR}/Triang
