# make complete

B25DIR=${SOLPSTOP}/modules/B2.5
PATH+=:/usr/bin:/bin
SVN=svn
GIT=git
INCLUDES=b2cdca.F b2cdci.F b2cdcn.F b2cdcr.F b2cdcv.F DIMENSIONS.F B2_5.Makefile B2_5.config.ITER.ifort64 solps-iter_git.log

all: solps.pdf solps.ps 

.PHONY: bibtex thumb update_log complete

solps.dvi: solps.tex ${INCLUDES} solps.ind # DPC: remove 1st # for index dependency
	@echo 'Building DVI manual'
	latex -output-format dvi solps
	-grep 'Label(s) may have changed' solps.log && latex -output-format dvi solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch $@
	[ -e solps.pdf ] && touch solps.pdf

solps.ps: solps.dvi
	dvips -o -ta4 solps

solps.ind: solps.idx
	makeindex solps

solps.idx: solps.tex
	@echo 'Building index'
	[ -e solps.ind ] || touch solps.ind
	pdflatex solps
	-grep 'Label(s) may have changed' solps.log && pdflatex solps
	makeindex solps
	pdflatex solps
	-grep 'Label(s) may have changed' solps.log && pdflatex solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch solps.pdf

bibtex: solps.tex
	@echo 'Building bibliography'
	pdflatex solps
	-grep 'Label(s) may have changed' solps.log && pdflatex solps
	bibtex solps
	pdflatex solps
	-grep 'Label(s) may have changed' solps.log && pdflatex solps

solps.pdf: solps.tex ${INCLUDES} solps.ind # DPC: remove 1st # for index dependency
	@echo 'Building PDF manual'
	pdflatex solps
	-grep 'Label(s) may have changed' solps.log && pdflatex solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch $@

thumb: solps.pdf
	@echo 'Building thumbnails'
	thumbpdf solps.pdf
	pdflatex solps.tex
	-grep 'Label(s) may have changed' solps.log && pdflatex solps

b2cdca.F:
	ln -sf ${B25DIR}/src/documentation/b2cdca.F .

b2cdci.F:
	ln -sf ${B25DIR}/src/documentation/b2cdci.F .

b2cdcn.F:
	ln -sf ${B25DIR}/src/documentation/b2cdcn.F .

b2cdcr.F:
	ln -sf ${B25DIR}/src/documentation/b2cdcr.F .

b2cdcv.F:
	ln -sf ${B25DIR}/src/documentation/b2cdcv.F .

DIMENSIONS.F:
	ln -sf ${B25DIR}/src/include/DIMENSIONS.F .

B2_5.Makefile:
	ln -sf ${B25DIR}/Makefile B2_5.Makefile

B2_5.config.ITER.ifort64:
	ln -sf ${B25DIR}/config/config.ITER.ifort64 B2_5.config.ITER.ifort64

solps-iter_git.log: 
	( cd ${SOLPSTOP} ; ${GIT} log --oneline ) > solps-iter_git.log

update_log: 
	( cd ${SOLPSTOP} ; ${GIT} log --oneline ) > solps-iter_git.log

update: ${INCLUDES}

complete:
	@[ -e solps.ind ] || touch solps.ind
	${MAKE} update
	${MAKE} bibtex
	makeindex solps
	${MAKE} thumb
	${MAKE} solps.ps
	${MAKE} solps.pdf

### WORK
COMPARE_10814_TESEPM=/scratch/dpc/solps5.0_HD+C+He/src/Braams/b2/runs/D+C+He/2MW/compare_10814_tesepm.ps

compare_10814_tesepm_1.ps: ${COMPARE_10814_TESEPM}
	psselect -p1 $< $@
compare_10814_tesepm_2.ps: ${COMPARE_10814_TESEPM}
	psselect -p2 $< $@
compare_10814_tesepm_3.ps: ${COMPARE_10814_TESEPM}
	psselect -p3 $< $@
compare_10814_tesepm_4.ps: ${COMPARE_10814_TESEPM}
	psselect -p4 $< $@
compare_10814_tesepm_5.ps: ${COMPARE_10814_TESEPM}
	psselect -p5 $< $@
compare_10814_tesepm_6.ps: ${COMPARE_10814_TESEPM}
	psselect -p6 $< $@
compare_10814_tesepm_7.ps: ${COMPARE_10814_TESEPM}
	psselect -p7 $< $@
compare_10814_tesepm_8.ps: ${COMPARE_10814_TESEPM}
	psselect -p8 $< $@
compare_10814_tesepm_9.ps: ${COMPARE_10814_TESEPM}
	psselect -p9 $< $@

compare_10814_tesepm_%.pdf: compare_10814_tesepm_%.ps
	epstopdf $<

compare_10814_tesepm: compare_10814_tesepm_1.pdf compare_10814_tesepm_2.pdf compare_10814_tesepm_3.pdf compare_10814_tesepm_4.pdf compare_10814_tesepm_5.pdf compare_10814_tesepm_6.pdf compare_10814_tesepm_7.pdf compare_10814_tesepm_8.pdf compare_10814_tesepm_9.pdf
