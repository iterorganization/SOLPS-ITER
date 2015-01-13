
pwd = ${PWD}



all: carre divgeo b2eirene

carre:
	cd src/Carre; ${MAKE}

divgeo:
	cd src/DivGeo; ${MAKE}
	cd src/DivGeo/equtrn; ${MAKE}

b2eirene:
	cd ${pwd}/src/Eirene; ${MAKE} -f Makefile OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene
	cd src/B2.5; ${MAKE} -f Makefile OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene

	

	

clean: clean_carre clean_divgeo clean_b2eirene

clean_carre:
	cd src/Carre; ${MAKE} clean

clean_divgeo:
	cd src/DivGeo; ${MAKE} clean
	cd src/DivGeo/equtrn; ${MAKE} clean

clean_b2eirene:
	cd src/Eirene; ${MAKE} -f Makefile clean OBJDIR=${pwd}/bin/${OBJECTCODE}/Eirene
	cd src/B2.5;   ${MAKE} -f Makefile clean OBJDIR=${pwd}/bin/${OBJECTCODE}/B2.5 OBJDIREIR=${pwd}/bin/${OBJECTCODE}/Eirene
