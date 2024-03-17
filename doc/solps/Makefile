# make complete

B25DIR=${SOLPSTOP}/modules/B2.5
PATH+=:/usr/bin:/bin
SVN=svn
GIT=`which git`
MAKES = Makefile
LATEX ?= $(shell which_latex)
LATEX_VERSION = $(shell ${LATEX} --version | head -1 | cut -d ' ' -f 5 | cut -c 1-4 )
PDFTOPS ?= $(shell which_pdftops)
PYTHON ?= python
INCLUDES=b2cdca.F b2cdci.F b2cdcn.F b2cdcr.F b2cdcv.F B2_5.Makefile B2_5.config.ITER.ifort64 B2_5.config.common.ifort64 solps-iter_git.log b2plot.commands SOLPS_versions LICENSE.tex CONTRIBUTING.tex Old_packages.tex
ifeq ($(shell [ -s ${B25DIR}/src/modules/b2mod_dimensions.F ] && echo yes || echo no ),yes)
FILE_DIM = b2mod_dimensions.F
TARG_DIM = ${B25DIR}/src/modules/b2mod_dimensions.F
else
FILE_DIM = DIMENSIONS.F
TARG_DIM = ${B25DIR}/src/include/DIMENSIONS.F
endif
INCLUDES += ${FILE_DIM}
BIBFILES=aps.bib aug.bib divgas.bib extern.bib general.bib main.bib mnw.bib model.bib tok.bib WebofScience.bib xpb.bib
STYFILES=fancyvrb.sty fullpage.sty groff.enc microtype.sty microtype-pdftex.def parskip.sty pdftex.def relsize.sty stdclsdv.sty subfigure.sty supertabular.sty times.sty tocbibind.sty
FILES=D/b2ag.dat D/b2ah.dat D/b2ar.dat D/b2ai.dat D/b2mn.dat D+C+He/b2ag.dat D+C+He/b2ah.dat D+C+He/b2ar.dat D+C+He/b2ai.dat D+C+He/b2mn.dat D+C+He/b2.boundary.parameters D+C+He/b2.numerics.parameters D+C+He/b2.transport.parameters D+C+He/b2.neutrals.parameters b2.transport.inputfile b2.sources.profile b2yg.dat b2yh.dat b2yi.dat b2ym.dat b2yn.dat b2yp.dat b2yq.dat b2yr.dat b2ymb.dat b2yrp.dat input_for_refusr_advanced.dat input_for_refusr_minimal.dat MDSPLUS/b2md.dat MDSPLUS/SOLPS_MODEL.TCL.index MDSPLUS/IDENT_MODEL.TCL.index MDSPLUS/SNAPSHOT_MODEL.TCL.index MDSPLUS/TALLIES_MODEL.TCL.index MDSPLUS/TIMEDEP_MODEL.TCL.index MDSPLUS/DIAG_MODEL.TCL.index shots.python_movie compare_shots.py QSUB.shot.python_movie sql_solps.py MacOS/compiler.darwin.gfortran MacOS/date2.c Makefile ${BIBFILES} ${STYFILES}

ifeq ($(shell [ -e Makefile.local ] && echo yes || echo no ),yes)
  include Makefile.local
  FILES += Makefile.local
  MAKES += Makefile.local
endif

# Include dependency on global SOLPS environment settings
ifdef SOLPS_CPP
  MAKES += ${SOLPSTOP}/Makefile
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/setup.csh${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif

all: solps.pdf solps.ps

.PHONY: bibtex thumb update_log complete force

ifeq (${LATEX}, xelatex)
solps.xdv: solps.tex ${INCLUDES} ${FILES} solps.ind solps.bbl
	@echo 'Building XDV manual'
	${LATEX} -no-pdf solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} -no-pdf solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch $@
	[ -e solps.pdf ] && touch solps.pdf

solps.ps: solps.pdf
	${PDFTOPS} solps.pdf solps.ps

else
solps.dvi: solps.tex ${INCLUDES} ${FILES} solps.ind solps.bbl
	@echo 'Building DVI manual'
	${LATEX} -output-format dvi solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} -output-format dvi solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch $@
	[ -e solps.pdf ] && touch solps.pdf

ifeq (${LATEX}, pdflatex)
solps.ps: solps.pdf
	${PDFTOPS} solps.pdf solps.ps
else
solps.ps: solps.dvi
	dvips -o -ta4 solps
endif

endif

solps.ind: solps.idx
	makeindex solps

solps.idx: solps.tex
	@echo 'Building index'
	[ -e solps.ind ] || touch solps.ind
	${LATEX} solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps
	makeindex solps
	${LATEX} solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch solps.pdf

solps.bbl: solps.tex ${BIBFILES}
	@echo 'Building bibliography'
	${LATEX} solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps
	bibtex solps
	${LATEX} solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch solps.pdf

solps.pdf: solps.tex ${INCLUDES} ${FILES} solps.ind solps.bbl
	@echo 'Building PDF manual'
	${LATEX} solps
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps
	touch solps.idx ; sleep 1 ; touch solps.ind ; sleep 1 ; touch $@

thumb: solps.pdf
	@echo 'Building thumbnails'
	thumbpdf solps.pdf
	${LATEX} solps.tex
	-grep 'Label(s) may have changed' solps.log && ${LATEX} solps

bibtex: solps.bbl

b2cdca.F: ${B25DIR}/src/documentation/b2cdca.F
	ln -sf ${B25DIR}/src/documentation/b2cdca.F .

b2cdci.F: b2input.xml ${B25DIR}/src/documentation/b2cdci.py
	export DO_NOT_RESOLVE_ENTITIES=1; ${PYTHON} ${B25DIR}/src/documentation/b2cdci.py || echo "! Error building b2cdci.F from b2input.xml" > b2cdci.F

b2cdcn.F: b2input.xml ${B25DIR}/src/documentation/b2cdcn.py
	export DO_NOT_RESOLVE_ENTITIES=1; ${PYTHON} ${B25DIR}/src/documentation/b2cdcn.py || echo "! Error building b2cdcn.F from b2input.xml" > b2cdcn.F

b2cdcr.F: ${B25DIR}/src/documentation/b2cdcr.F
	ln -sf ${B25DIR}/src/documentation/b2cdcr.F .

b2cdcv.F: ${B25DIR}/src/documentation/b2cdcv.F
	ln -sf ${B25DIR}/src/documentation/b2cdcv.F .

b2input.xml: ${B25DIR}/src/documentation/b2input.xml
	ln -sf ${B25DIR}/src/documentation/b2input.xml .

b2plot.commands: ${B25DIR}/src/b2plot/b2plot.F
	-[ -e b2plot.commands ] && rm b2plot.commands || echo > /dev/null
	sed 's:^     [^ ]:@@@:' ${B25DIR}/src/b2plot/b2plot.F | awk 'BEGIN{save=""}/^[^@][^@][^@]/&&save!=""{print save}/^[^@][^@][^@]/{save=$$0}/^@@@/{save=save" "$$0}END{print save}' | sed 's; *@@@ *;;g' | grep -v "IGNORE" | egrep "case *\( *'|description *=" | sed -e "s;.*case *('\(.*\)');cmd: \1;" -e "s; *description *= *'\(.*\)';desc: \1;" -e "s;' //';;" -e "s;'//';;" | awk -F: 'BEGIN{save=""}/^cmd/&&save!=""{print save}/^cmd:/{save=$$2}/^desc/{save=save"\t "$$2}END{print save}' | sed 's:\! ::' | sed "s:',':,:g" | sed "s:'':':g" | expand > b2plot.commands

${FILE_DIM}: ${TARG_DIM}
	ln -sf ${TARG_DIM} .

B2_5.Makefile: ${B25DIR}/Makefile
	ln -sf ${B25DIR}/Makefile B2_5.Makefile

B2_5.config.ITER.ifort64: ${B25DIR}/config/config.ITER.ifort64
	ln -sf ${B25DIR}/config/config.ITER.ifort64 B2_5.config.ITER.ifort64

B2_5.config.common.ifort64: ${B25DIR}/config/config.common.ifort64
	ln -sf ${B25DIR}/config/config.common.ifort64 B2_5.config.common.ifort64

LICENSE.tex: ${SOLPSTOP}/LICENSE.md
	pandoc ${SOLPSTOP}/LICENSE.md -o LICENSE.tex || cat ${SOLPSTOP}/LICENSE.md | sed -e "s:#::g" > LICENSE.tex

CONTRIBUTING.tex: ${SOLPSTOP}/CONTRIBUTING.md
	pandoc ${SOLPSTOP}/CONTRIBUTING.md -o CONTRIBUTING.tex || cat ${SOLPSTOP}/CONTRIBUTING.md | sed -e "s:#::g" -e "s:_:\\\_:g" -e 's:$$SOLPSTOP:\\$$SOLPSTOP:g' -e 's:$$:\\\\:' -e 's:\^:\\\^:g' > CONTRIBUTING.tex

Old_packages.tex: ${MAKES}
ifeq ($(shell test ${LATEX_VERSION} -lt 2015; echo $$?),0)
	echo "\usepackage{fixltx2e}" > Old_packages.tex
else
	@- rm -f Old_packages.tex
	touch Old_packages.tex
endif

SOLPS_versions: force
	@( cd ${SOLPSTOP} ; git describe --tags --always | awk '{print "SOLPS-ITER version : ",$$1}' ) > SOLPS_versions_new
	@( cd ${SOLPSTOP}/modules/B2.5 ; git describe --tags --always | awk '{print "B2.5 version : ",$$1}') >> SOLPS_versions_new
	@( cd ${SOLPSTOP}/modules/Eirene ; git describe --tags --always | awk '{print "Eirene version : ",$$1}' ) >> SOLPS_versions_new
	@( cd ${SOLPSTOP}/modules/Carre ; git describe --tags --always | awk '{print "Carre version : ",$$1}' ) >> SOLPS_versions_new
	@( cd ${SOLPSTOP}/modules/DivGeo ; git describe --tags --always | awk '{print "DivGeo version : ",$$1}' ) >> SOLPS_versions_new
	@if cmp -s SOLPS_versions_new SOLPS_versions ; then rm SOLPS_versions_new ; else mv SOLPS_versions_new SOLPS_versions ; fi

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

clean:
	rm -f solps.pdf solps.ps solps.dvi solps.xdv solps.aux solps.ilg solps.ind solps.idx solps.lof solps.log solps.lot solps.out solps.toc b2input.xml b2cdca.F b2cdci.F b2cdcn.F b2cdcr.F b2cdcv.F solps_data_git.log solps-iter_git.log B2_5.config.ITER.ifort64 B2_5.Makefile ${FILE_DIM} SOLPS_versions solps.bbl solps.blg solps.brf solps.tpt Old_packages.tex

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

echo:
	@echo LATEX=${LATEX}
	@echo GIT=${GIT}
