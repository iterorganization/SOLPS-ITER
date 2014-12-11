


all:
	cd $(SOLPSTOP)/src/Carre; ${MAKE}
	mkdir -p ${BINDIR}/Carre
	mv -f $(SOLPSTOP)/src/Carre/${OBJECTCODE} ${BINDIR}/Carre
	mv -f $(SOLPSTOP)/src/Carre/LISTOBJ ${BINDIR}/Carre
	
	cd $(SOLPSTOP)/src/DivGeo; ${MAKE}
	mkdir -p ${BINDIR}/DivGeo
	mv -f $(SOLPSTOP)/src/DivGeo/${OBJECTCODE} ${BINDIR}/DivGeo
	mv -f $(SOLPSTOP)/src/DivGeo/LISTOBJ ${BINDIR}/DivGeo
	
	

clean:
	rm -f *.a
	cd blas1; ${MAKE} clean
	cd blas2; ${MAKE} clean
	cd blas3; ${MAKE} clean
	cd lapack; ${MAKE} clean
