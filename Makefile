
pwd = ${PWD}



all: carre divgeo b2eirene

carre:
	cd src/Carre; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre

divgeo:
	cd src/DivGeo;         ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert

b2eirene:
	cd src/Eirene; ${MAKE} OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene
	cd src/B2.5;   ${MAKE} b2eirene OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene

b2:
	cd src/B2.5; ${MAKE} b2 OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5

	

clean: clean_carre clean_divgeo clean_b2eirene

clean_carre:
	cd src/Carre; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Carre

clean_divgeo:
	cd src/DivGeo;         ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo
	cd src/DivGeo/equtrn;  ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/equtrn
	cd src/DivGeo/convert; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/DivGeo/convert

clean_b2eirene:
	cd src/Eirene; ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene
	cd src/B2.5;   ${MAKE} clean OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene
