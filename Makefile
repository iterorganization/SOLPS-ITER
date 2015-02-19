
pwd = ${PWD}

all: carre divgeo eirene b25 uinp triang solps manual

.PHONY: divgeo eirene b25 solps manual

carre:
	cd src/Carre; ${MAKE} 

divgeo:
	cd src/DivGeo;         ${MAKE}
	cd src/DivGeo/equtrn;  ${MAKE}
	cd src/DivGeo/convert; ${MAKE}

eirene:
	cd src/Eirene; ${MAKE} 

b25:
	cd src/B2.5; ${MAKE} 

uinp:
	cd src/uinp; ${MAKE}

triang:
	cd src/Triang; ${MAKE}

solps: uinp triang
	cd src/Carre;          ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert
	cd src/Eirene;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_B25=-DUSE_B25
	cd src/B2.5;           ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene USE_EIRENE=-DUSE_EIRENE

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

depend:
	cd src/Carre;          ${MAKE} depend
	cd src/Eirene;         ${MAKE} depend
	cd src/B2.5;           ${MAKE} depend
	cd src/uinp;           ${MAKE} depend
	cd src/Triang;         ${MAKE} depend
	cd src/DivGeo;         ${MAKE} depend
	cd src/DivGeo/equtrn;  ${MAKE} depend

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
	cd src/Eirene; ${MAKE} clean
	cd src/B2.5;   ${MAKE} clean
	cd src/Eirene; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene
	cd src/B2.5;   ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene

clean_uinp:
	cd src/uinp; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/uinp

clean_triang:
	cd src/Triang; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Triang

