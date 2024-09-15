# GNU Makefile for B2plot and other postprocessors; part 2--execution.
# Please see the general comments in the companion Makefile, part 1,
# which controls compile and load.
#-----------------------------------------------------------------------
# Variables.

SHELL = /bin/bash
TIME = time
RUN_OPTIONS =
nil =

# Default debugger
DBX ?= dbx

# Extensions for object directories when various options are used
ifdef SOLPS_OPENMP
EXT_OPENMP = .openmp
endif
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
endif
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif

ifndef STAND_ALONE
B2OBJ  = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
EIROBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}.debug
EDBOBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ} -I ${EDBOBJ}
endif
else
B2OBJ  = ${SOLPSTOP}/modules/B2.5/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ}
endif
endif
ifneq (${COMPILER},HP)
fort_lc = fort.
else
fort_lc = ftn
endif

prints = b2uf.prt b2fu.prt b2pl.prt b2yi.prt b2yn.prt b2md.prt b2rd.prt b2yi_gnuplot.prt

target_uf = b2uf.prt
target_fu = b2fu.prt
target_pl = b2pl.prt
target_pl.dbx = b2pl.dbx
target_yi = b2yi.prt b2yi.plt
target_yi_gnuplot = b2yi_gnuplot.prt
target_yn = b2yn.prt b2yn.plt
target_md = b2md.prt
target_md.dbx = b2md.dbx
target_rd = b2rd.prt
target_ymb = b2ymb.prt
target_yrp = b2yrp.prt
target_ydm = b2ydm.prt

scandir := $(shell cd .. ; pwd)
projdir := $(shell cd ../.. ; pwd)
ifeq ($(shell [ -d ${scandir}/TRIANG ] && echo yes || echo no ),yes)
triangdir := $(shell cd $(scandir)/TRIANG ; pwd)
else
triangdir := $(shell cd $(scandir)/baserun ; pwd)
endif
baserundir := $(shell cd $(scandir)/baserun ; pwd)


echo:
	@echo scandir=${scandir}
	@echo projdir=${projdir}
	@echo baserundir=${baserundir}
	@echo triangdir=${triangdir}

#-----------------------------------------------------------------------
# Directives.

vpath %.dat .:$(baserundir)
vpath b2md.dat .:$(baserundir):$(SOLPSTOP)/data.local/mdsplus:$(SOLPSTOP)/data/mdsplus
vpath b2fgmtry .:$(baserundir)
vpath b2fpardf .:$(baserundir)
vpath b2fstati .:$(baserundir)
vpath b2frates .:$(baserundir)
vpath ${fort_lc}33  .:$(baserundir):$(triangdir)
vpath ${fort_lc}34  .:$(baserundir):$(triangdir)
vpath ${fort_lc}35  .:$(baserundir):$(triangdir)

#-----------------------------------------------------------------------
# Rules.

default : b2pl.prt
all : $(prints)
prt : $(prints)

.PHONY : default all prt clean realclean testvars
.PRECIOUS : $(prints)
.SUFFIXES : $(nil)

$(target_uf) : b2fgmtry b2fparam b2fstate b2fplasma
	rm -rf b2uf.exe.dir >& /dev/null ; mkdir b2uf.exe.dir ; cp $^ b2uf.exe.dir
	rm -f $(target_uf)
	cd b2uf.exe.dir ; ${TIME} ${B2OBJ}/b2uf.exe ${RUN_OPTIONS} ; mv $(target_uf) b2fplasmf .. ; rm -f $(notdir $^) .quit >& /dev/null
	-rmdir b2uf.exe.dir

$(target_fu) : b2fgmtry b2fparam b2fstate b2fplasmf
	rm -rf b2fu.exe.dir >& /dev/null ; mkdir b2fu.exe.dir ; cp $^ b2fu.exe.dir
	rm -f $(target_fu)
	cd b2fu.exe.dir ; ${TIME} ${B2OBJ}/b2fu.exe ${RUN_OPTIONS} ; mv $(target_fu) b2fplasma .. ; rm -f $(notdir $^) .quit >& /dev/null
	-rmdir b2fu.exe.dir

ifndef STAND_ALONE
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates b2ftrack AMJUEL ${fort_lc}33 ${fort_lc}34 ${fort_lc}35
else
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates b2ftrack AMJUEL
endif
	rm -rf b2pl.exe.dir >& /dev/null ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
	[ -e param.dg ] && cp param.dg b2pl.exe.dir/ || ( [ -e ../baserun/param.dg ] && cp ../baserun/param.dg b2pl.exe.dir/ || echo > /dev/null )
ifndef STAND_ALONE
	-cp ${fort_lc}44 ${fort_lc}46 b2pl.exe.dir/
	-cd b2pl.exe.dir
endif
ifeq (${NCAR_VERSION},3)
	rm -f $(target_pl) gmeta
	cd b2pl.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${TIME} ${B2OBJ}/b2pl.exe ${RUN_OPTIONS} ; ( [ -e gmeta ] && mv -f gmeta .. ) ; rm -f $(target_pl) $(notdir $^) .quit param.dg >& /dev/null
else
	rm -f $(target_pl) b2plot.ps
	cd b2pl.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${TIME} ${B2OBJ}/b2pl.exe ${RUN_OPTIONS} ; ( [ -e b2plot.ps ] && mv -f b2plot.ps .. ) ; rm -f $(target_pl) $(notdir $^) .quit param.dg >& /dev/null
endif
ifndef STAND_ALONE
	-rm b2pl.exe.dir/${fort_lc}44 b2pl.exe.dir/${fort_lc}46 b2pl.exe.dir/${fort_lc}85
endif
	-cd b2pl.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ${fort_lc}21 ${fort_lc}22 ${fort_lc}1
	-rmdir b2pl.exe.dir

ifndef STAND_ALONE
$(target_pl.dbx) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates b2ftrack AMJUEL ${fort_lc}33 ${fort_lc}34 ${fort_lc}35
else
$(target_pl.dbx) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates b2ftrack AMJUEL
endif
	rm -rf b2pl.exe.dir >& /dev/null ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
	[ -e param.dg ] && cp param.dg b2pl.exe.dir/ || ( [ -e ../baserun/param.dg ] && cp ../baserun/param.dg b2pl.exe.dir/ || echo > /dev/null )
ifndef STAND_ALONE
	-cp ${fort_lc}44 ${fort_lc}46 b2pl.exe.dir/
	-cd b2pl.exe.dir
endif
ifeq (${NCAR_VERSION},3)
	rm -f $(target_pl) gmeta
	cd b2pl.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${DBX} ${INC} ${DBGOBJ}/b2pl.exe ${RUN_OPTIONS} ; ( [ -e gmeta ] && mv -f gmeta .. ) ; rm -f $(target_pl) $(notdir $^) .quit param.dg >& /dev/null
else
	rm -f $(target_pl) b2plot.ps
	cd b2pl.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${DBX} ${INC} ${DBGOBJ}/b2pl.exe ${RUN_OPTIONS} ; ( [ -e b2plot.ps ] && mv -f b2plot.ps .. ) ; rm -f $(target_pl) $(notdir $^) .quit param.dg >& /dev/null
endif
ifndef STAND_ALONE
	-rm b2pl.exe.dir/${fort_lc}44 b2pl.exe.dir/${fort_lc}46 b2pl.exe.dir/${fort_lc}85
endif
	-cd b2pl.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ${fort_lc}21 ${fort_lc}22 ${fort_lc}1
	-rmdir b2pl.exe.dir

ifndef STAND_ALONE
$(target_md) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat AMJUEL ${fort_lc}33 ${fort_lc}34 ${fort_lc}35 # b2fplasma b2time.nc
else
$(target_md) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat # b2fplasma b2time.nc
endif
	rm -rf b2md.exe.dir >& /dev/null ; mkdir b2md.exe.dir ; cp $^ ds* b2md.exe.dir
ifndef STAND_ALONE
	-cp ${fort_lc}44 b2md.exe.dir/ >& /dev/null
	-cd b2md.exe.dir
endif
	[ -e shotnumber.history ] && cp shotnumber.history b2md.exe.dir/ || echo > /dev/null
	rm -f $(target_md)
	cd b2md.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${SOLPSTOP}/scripts/mds_id | ${TIME} ${B2OBJ}/b2md.exe ${RUN_OPTIONS} ; mv $(target_md) .. ; rm -f $(notdir $^) .quit ds* >& /dev/null
ifndef STAND_ALONE
	-rm b2md.exe.dir/${fort_lc}44 b2md.exe.dir/${fort_lc}85 >& /dev/null
endif
	-cd b2md.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ${fort_lc}21 ${fort_lc}22 ${fort_lc}1
	-[ -s b2md.exe.dir/shotnumber.history ] && mv b2md.exe.dir/shotnumber.history . || echo > /dev/null
	-rmdir b2md.exe.dir

ifndef STAND_ALONE
$(target_md.dbx) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat AMJUEL ${fort_lc}33 ${fort_lc}34 ${fort_lc}35 # b2fplasma b2time.nc
else
$(target_md.dbx) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat # b2fplasma b2time.nc
endif
	rm -rf b2md.exe.dir >& /dev/null ; mkdir b2md.exe.dir ; cp $^ ds* b2md.exe.dir
ifndef STAND_ALONE
	-cp ${fort_lc}44 b2md.exe.dir/ >& /dev/null
	-cd b2md.exe.dir
endif
	rm -f $(target_md)
	cd b2md.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../${fort_lc}21 ../${fort_lc}22 ../${fort_lc}1 . ; ${SOLPSTOP}/scripts/mds_id | ${DBX} ${INC} ${DBGOBJ}/b2md.exe ${RUN_OPTIONS} ; mv $(target_md) .. ; rm -f $(notdir $^) .quit ds* >& /dev/null
ifndef STAND_ALONE
	-rm b2md.exe.dir/${fort_lc}44 b2md.exe.dir/${fort_lc}85 >& /dev/null
endif
	-cd b2md.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ${fort_lc}21 ${fort_lc}22 ${fort_lc}1
	-rmdir b2md.exe.dir

$(target_rd) : shotnumber.history
	rm -rf b2rd.exe.dir >& /dev/null ; mkdir b2rd.exe.dir ; cp $^ b2rd.exe.dir
	rm -f $(target_rd)
	cd b2rd.exe.dir ; ${TIME} ${B2OBJ}/b2rd.exe ${RUN_OPTIONS} ; mv $(target_rd) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2rd.exe.dir

$(target_yi) : b2yi.dat b2mn.dat b2fstate b2frates b2fgmtry
	rm -rf b2yi.exe.dir >& /dev/null ; mkdir b2yi.exe.dir ; cp $^ b2yi.exe.dir
	rm -f $(target_yi)
	NCARG_GKS_OUTPUT=b2yi.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yi.exe.dir ; ${TIME} ${B2OBJ}/b2yi.exe ${RUN_OPTIONS} ; mv $(target_yi) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yi.exe.dir

$(target_yi_gnuplot) : b2mn.dat b2fstate b2frates b2fgmtry
	rm -rf b2yi_gnuplot.exe.dir >& /dev/null ; mkdir b2yi_gnuplot.exe.dir ; cp $^ b2yi_gnuplot.exe.dir
	rm -f $(target_yi_gnuplot)
	cd b2yi_gnuplot.exe.dir ; ${TIME} ${B2OBJ}/b2yi_gnuplot.exe ${RUN_OPTIONS} ; mv $(target_yi_gnuplot) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yi_gnuplot.exe.dir

$(target_yn) : b2yn.dat b2mn.dat b2ftrack b2frates b2fstate
	rm -rf b2yn.exe.dir >& /dev/null ; mkdir b2yn.exe.dir ; cp $^ b2yn.exe.dir
	rm -f $(target_yn)
	NCARG_GKS_OUTPUT=b2yn.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yn.exe.dir ; ${TIME} ${B2OBJ}/b2yn.exe ${RUN_OPTIONS} ; mv $(target_yn) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yn.exe.dir

$(target_ymb) : b2ymb.dat wlld_trgi.dat wlld_trgo.dat wlly_trgi.dat wlly_trgo.dat
	rm -rf b2ymb.exe.dir ; mkdir b2ymb.exe.dir ; cp $^ b2ymb.exe.dir
	rm -f $(target_ymb)
	cd b2ymb.exe.dir ; ${TIME} ${B2OBJ}/b2ymb.exe ${RUN_OPTIONS} ; touch b2ymb.prt; mv $(target_ymb) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ymb.exe.dir

$(target_yrp) : b2yrp.dat wlld_irp.dat wlld_orp.dat wlly_irp.dat wlly_orp.dat
	rm -rf b2yrp.exe.dir ; mkdir b2yrp.exe.dir ; cp $^ b2yrp.exe.dir
	rm -f $(target_yrp)
	cd b2yrp.exe.dir ; ${TIME} ${B2OBJ}/b2yrp.exe ${RUN_OPTIONS} ; touch b2yrp.prt; mv $(target_yrp) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yrp.exe.dir

$(target_ydm) : b2ydm.dat wlld_dome.dat
	rm -rf b2ydm.exe.dir ; mkdir b2ydm.exe.dir ; cp $^ b2ydm.exe.dir
	rm -f $(target_ydm)
	cd b2ydm.exe.dir ; ${TIME} ${B2OBJ}/b2ydm.exe ${RUN_OPTIONS} ; touch b2ydm.prt; mv $(target_ydm) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ydm.exe.dir

AMJUEL:
	ln -s ${SOLPSTOP}/modules/Eirene/Database/AMJUEL .

clean :
	rm -f *.prt* *.plt* *~
	rm -rf *.exe.dir

realclean : clean
	rm -f b2fgmtry b2fpar* b2frates b2fstat* b2ftra* b2fmovie b2specp

# The target testvars is present only for testing purposes.
testvars :
	@echo scandir: $(scandir)
	@echo projdir: $(projdir)
	@echo baserundir: $(baserundir)
	@echo codedir: $(codedir)

#!!!Local Variables:
#!!! mode: Makefile
#!!! End:
