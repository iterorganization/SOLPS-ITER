# GNU Makefile for B2.5; part 2--execution.
# Please see the general comments in the companion Makefile, part 1,
# which controls compile and load.
#-----------------------------------------------------------------------
# Variables.

SHELL = /bin/bash
TIME ?= time
RUN_OPTIONS =
BLANK =

# Default debugger
DBX ?= dbx

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
B2OBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
EIROBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}.debug
EDBOBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ} -I ${EDBOBJ}
endif
else
B2OBJ = ${SOLPSTOP}/modules/B2.5/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ}
endif
endif


prints = b2ag.prt b2ah.prt b2ai.prt b2ar.prt b2mn.prt \
 b2ye.prt b2yg.prt b2yh.prt b2yi.prt b2ym.prt b2yn.prt b2yp.prt b2yq.prt \
 b2yr.prt b2yt.prt b2yi_gnuplot.prt

target_ag = b2ag.prt b2fgmtry
ifneq (${COMPILER},HP)
target_ag += fort.30
else
target_ag += ftn30
endif
target_ah = b2ah.prt b2fpardf
target_ai = b2ai.prt b2fstati
target_ar = b2ar.prt b2frates
target_mn = b2mn.prt b2fparam b2fstate b2fmovie b2ftrace b2ftrack b2fplasma
ifdef USE_IMPGYRO
target_mn += restart_ext
endif
target_uf = b2uf.prt
target_fu = b2fu.prt
target_co = b2co.prt b2co.files
target_pl = b2pl.prt b2plot.ps
target_ts = b2ts.prt
target_ye = b2ye.prt
target_yg = b2yg.prt b2yg.plt
target_yh = b2yh.prt
target_yi = b2yi.prt b2yi.plt
target_yi_gnuplot = b2yi_gnuplot.prt
target_ym = b2ym.prt b2ym.plt
target_yn = b2yn.prt b2yn.plt
target_yp = b2yp.prt b2yp.plt b2specp
target_yq = b2yq.prt b2yq.plt
target_yr = b2yr.prt b2yr.plt
target_yt = b2yt.prt b2fstatt b2mn.dat.2 b2ah.dat.2 b2ai.dat.2 b2yt.files
target_xd = B2SXDR
target_rd = b2rd.prt
target_ual = b2_ual_write.prt
target_rew = b2_ual_rewrite.prt

scandir := $(shell cd .. ; pwd)
projdir := $(shell cd ../.. ; pwd)
ifeq ($(shell [ -d ${scandir}/TRIANG ] && echo yes || echo no ),yes)
triangdir := $(shell cd $(scandir)/TRIANG ; pwd)
else
triangdir := $(shell cd $(scandir)/baserun ; pwd)
endif
baserundir := $(shell cd $(scandir)/baserun ; pwd)
savefiles := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.*_save.parameters:')
ifneq (${COMPILER},HP)
fort13file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:fort.13:')
else
fort13file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:ftn13:')
endif
ifneq (${COMPILER},HP)
fort15file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:fort.15:')
else
fort15file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:ftn15:')
endif
ifneq (${COMPILER},HP)
fort44file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:fort.44:')
else
fort44file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:ftn44:')
endif
ifneq (${COMPILER},HP)
fort46file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:fort.46:')
else
fort46file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:ftn46:')
endif
ifeq ($(shell [ -e $(fort13file) ] && echo yes || echo no ),yes)
savefiles += $(fort13file)
endif
ifeq ($(shell [ -e $(fort15file) ] && echo yes || echo no ),yes)
savefiles += $(fort15file)
endif
ifeq ($(shell [ -e $(fort44file) ] && echo yes || echo no ),yes)
savefiles += $(fort44file)
endif
ifeq ($(shell [ -e $(fort46file) ] && echo yes || echo no ),yes)
savefiles += $(fort46file)
endif

echo:
	@echo scandir=${scandir}
	@echo projdir=${projdir}
	@echo baserundir=${baserundir}
	@echo savefiles=${savefiles}
	@echo triangdir=${triangdir}

#-----------------------------------------------------------------------
# Directives.

vpath %.dat .:$(baserundir)
vpath b2fgmtry .:$(baserundir)
vpath b2fpardf .:$(baserundir)
vpath b2fstati .:$(baserundir)
ifneq (${COMPILER},HP)
vpath fort.30  .:$(baserundir)
vpath fort.33  .:$(baserundir):$(triangdir)
vpath fort.34  .:$(baserundir):$(triangdir)
vpath fort.35  .:$(baserundir):$(triangdir)
else
vpath ftn30    .:$(baserundir)
vpath ftn33    .:$(baserundir):$(triangdir)
vpath ftn34    .:$(baserundir):$(triangdir)
vpath ftn35    .:$(baserundir):$(triangdir)
endif
vpath stra.dat .:$(baserundir)
vpath weis.dat .:$(baserundir)
vpath b2frates .:$(baserundir)

#-----------------------------------------------------------------------
# Rules.

default : b2mn.prt
all : $(prints)
prt : $(prints)

.PHONY : default all prt clean realclean testvars fetch
.PRECIOUS : $(prints)
.SUFFIXES : $(nil)


fetch:
	make -C examples

$(target_xd) : b2fgmtry b2fparam b2fstate b2fplasma
	rm -rf b2xd.exe.dir >& /dev/null ; mkdir b2xd.exe.dir ; cp $^ b2xd.exe.dir
	rm -f $(target_xd)
	cd b2xd.exe.dir ; ${TIME} ${B2OBJ}/b2xd.exe ${RUN_OPTIONS} ; mv $(target_xd) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2xd.exe.dir

$(target_ag) : b2ag.dat
	rm -rf b2ag.exe.dir >& /dev/null ; mkdir b2ag.exe.dir ; cp $^ b2ag.exe.dir
	rm -f $(target_ag)
	cd b2ag.exe.dir ; ${TIME} ${B2OBJ}/b2ag.exe ${RUN_OPTIONS} ; mv $(target_ag) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ag.exe.dir

$(target_ah) : b2ah.dat b2fgmtry
	rm -rf b2ah.exe.dir >& /dev/null ; mkdir b2ah.exe.dir ; cp $^ b2ah.exe.dir
	rm -f $(target_ah)
	cd b2ah.exe.dir ; ${TIME} ${B2OBJ}/b2ah.exe ${RUN_OPTIONS} ; mv $(target_ah) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ah.exe.dir

$(target_ai) : b2ag.dat b2ai.dat b2fgmtry
	rm -rf b2ai.exe.dir >& /dev/null ; mkdir b2ai.exe.dir ; cp $^ b2ai.exe.dir
	rm -f $(target_ai)
	cd b2ai.exe.dir ; ${TIME} ${B2OBJ}/b2ai.exe ${RUN_OPTIONS} ; mv $(target_ai) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ai.exe.dir

$(target_ar) : b2ar.dat stra.dat weis.dat b2fpardf b2fgmtry
	rm -rf b2ar.exe.dir >& /dev/null ; mkdir b2ar.exe.dir ; cp $^ b2ar.exe.dir
	rm -f $(target_ar)
	cd b2ar.exe.dir ; ${TIME} ${B2OBJ}/b2ar.exe ${RUN_OPTIONS} ; mv $(target_ar) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ar.exe.dir

ifndef STAND_ALONE
ifneq (${COMPILER},HP)
$(target_mn) : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates fort.30 AMJUEL
else
$(target_mn) : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates ftn30 AMJUEL
endif
else
$(target_mn) : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates
endif
	-rm -rf b2mn.exe.dir >& /dev/null ; mkdir b2mn.exe.dir ; cp $^ b2mn.exe.dir
ifneq (${COMPILER},HP)
	-rm -f $(target_mn) fort.31 balance.nc b2_to_astra.dat >& /dev/null
else
	-rm -f $(target_mn) ftn31 balance.nc b2_to_astra.dat >& /dev/null
endif
	save_initial_files
	-cd b2mn.exe.dir ; [ -e ../b2faveri ] && cp -p ../b2faveri . || echo > /dev/null
ifndef STAND_ALONE
ifdef SOLPS_MPI
	-rm -f output.* >& /dev/null
endif
ifneq (${COMPILER},HP)
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; ln -s ../input.dat fort.1 ; \
	[ -s ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; \
	[ -s ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; \
	[ -s ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; \
	[ -s ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; \
	[ -s ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; \
	[ -s ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; \
	[ -s ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; \
	[ -s ../fort.46 ] && cp -p ../fort.46 . || echo > /dev/null ; \
	[ -s ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; \
	[ -s ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; \
	[ -s ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
else
	[ -s ftn33 ] || ( [ -s $(baserundir)/ftn33 ] && ln -sf $(baserundir)/ftn33 . || ( [ -s $(triangdir)/ftn33 ] && ln -sf $(triangdir)/ftn33 . || echo > /dev/null ) )
	[ -s ftn34 ] || ( [ -s $(baserundir)/ftn34 ] && ln -sf $(baserundir)/ftn34 . || ( [ -s $(triangdir)/ftn34 ] && ln -sf $(triangdir)/ftn34 . || echo > /dev/null ) )
	[ -s ftn35 ] || ( [ -s $(baserundir)/ftn35 ] && ln -sf $(baserundir)/ftn35 . || ( [ -s $(triangdir)/ftn35 ] && ln -sf $(triangdir)/ftn35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; ln -s ../input.dat ftn1 ; \
	[ -s ../ftn15 ] && cp -p ../ftn15 . || echo > /dev/null ; \
	[ -s ../ftn14 ] && cp -p ../ftn14 . || echo > /dev/null ; \
	[ -s ../ftn13 ] && cp -p ../ftn13 . || echo > /dev/null ; \
	[ -s ../ftn12 ] && cp -p ../ftn12 . || echo > /dev/null ; \
	[ -s ../ftn11 ] && cp -p ../ftn11 . || echo > /dev/null ; \
	[ -s ../ftn10 ] && cp -p ../ftn10 . || echo > /dev/null ; \
	[ -s ../ftn44 ] && cp -p ../ftn44 . || echo > /dev/null ; \
	[ -s ../ftn46 ] && cp -p ../ftn46 . || echo > /dev/null ; \
	[ -s ../ftn33 ] && cp -p ../ftn33 . || echo > /dev/null ; \
	[ -s ../ftn34 ] && cp -p ../ftn34 . || echo > /dev/null ; \
	[ -s ../ftn35 ] && cp -p ../ftn35 . || echo > /dev/null
endif
endif
ifdef USE_IMPGYRO
ifneq (${COMPILER},HP)
	-cd b2mn.exe.dir ; touch b2ig.conf ; echo "-n ${NPE_B2} : ${B2OBJ}/b2mn.exe" >> b2ig.conf ; echo "-n ${NPE_EXT} : ${EXE_EXT}" >> b2ig.conf ; ln -s ../config ../pre . ; mkdir tracing ; mkdir output ; copy_tracing_files ; mkdir batch_av ; mkdir run_av ; \
	touch use_impgyro ; [ -e ../restart_ext ] && cp ../restart_ext . || echo > /dev/null ; [ -e ../restart ] && cp ../restart . && cp ${WD_EXT}/.st.?* . || echo > /dev/null ; \
	mpiexec -verbose -config b2ig.conf ; \
	move_optional_files ; \
	mv $(target_mn) .. >& /dev/null ; \
	rm -f b2ig.conf use_impgyro config pre ; [ -e restart_ext ] && cp restart_ext ../. || echo > /dev/null ; \
	mv .*.?* ${WD_EXT}/. ; mv fort.150 ${WD_EXT}/. ; \
	mv impgyro.* ${WD_EXT}/. ; mv preg ${WD_EXT}/. ; cp restart ${WD_EXT}/. ; mv restart ../.
else
	-cd b2mn.exe.dir ; touch b2ig.conf ; echo "-n ${NPE_B2} : ${B2OBJ}/b2mn.exe" >> b2ig.conf ; echo "-n ${NPE_EXT} : ${EXE_EXT}" >> b2ig.conf ; ln -s ../config ../pre . ; mkdir tracing ; mkdir output ; copy_tracing_files ; mkdir batch_av ; mkdir run_av ; \
	touch use_impgyro ; [ -e ../restart_ext ] && cp ../restart_ext . || echo > /dev/null ; [ -e ../restart ] && cp ../restart . && cp ${WD_EXT}/.st.?* . || echo > /dev/null ; \
	mpiexec -verbose -config b2ig.conf ; \
	move_optional_files ; \
	mv $(target_mn) .. >& /dev/null ; \
	rm -f b2ig.conf use_impgyro config pre ; [ -e restart_ext ] && cp restart_ext ../. || echo > /dev/null ; \
	mv .*.?* ${WD_EXT}/. ; mv ftn150 ${WD_EXT}/. ; \
	mv impgyro.* ${WD_EXT}/. ; mv preg ${WD_EXT}/. ; cp restart ${WD_EXT}/. ; mv restart ../.
endif
else
	-cd b2mn.exe.dir ; mkdir tracing ; mkdir output ; copy_tracing_files ; mkdir batch_av ; mkdir run_av ; ${TIME} ${B2OBJ}/b2mn.exe ${RUN_OPTIONS} ; move_optional_files ; mv $(target_mn) .. >& /dev/null
endif
ifneq (${COMPILER},HP)
	-[ -s fort.30 ] || ( [ -s ../baserun/fort.30 ] || ( [ -s b2mn.exe.dir/fort.30 ] && mv b2mn.exe.dir/fort.30 . || ( [ -e b2mn.exe.dir/fort.30 ] && rm b2mn.exe.dir/fort.30 || echo > /dev/null ) ) )
else
	-[ -s ftn30 ] || ( [ -s ../baserun/ftn30 ] || ( [ -s b2mn.exe.dir/ftn30 ] && mv b2mn.exe.dir/ftn30 . || ( [ -e b2mn.exe.dir/ftn30 ] && rm b2mn.exe.dir/ftn30 || echo > /dev/null ) ) )
endif
	-[ -s b2mn.exe.dir/b2faveri ] && mv b2mn.exe.dir/b2faveri . || ( [ -e b2mn.exe.dir/b2faveri ] && rm b2mn.exe.dir/b2faveri || echo > /dev/null )
ifdef NCDIR
	-cd b2mn.exe.dir ; rm .netcdf4 >& /dev/null
endif
	-cd b2mn.exe.dir ; rm -f $(notdir $^) .quit >& /dev/null
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	-[ -s b2mn.exe.dir/fort.10 ] && mv b2mn.exe.dir/fort.10 . || ( [ -e b2mn.exe.dir/fort.10 ] && rm b2mn.exe.dir/fort.10 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.11 ] && mv b2mn.exe.dir/fort.11 . || ( [ -e b2mn.exe.dir/fort.11 ] && rm b2mn.exe.dir/fort.11 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.12 ] && mv b2mn.exe.dir/fort.12 . || ( [ -e b2mn.exe.dir/fort.12 ] && rm b2mn.exe.dir/fort.12 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.13 ] && mv b2mn.exe.dir/fort.13 . || ( [ -e b2mn.exe.dir/fort.13 ] && rm b2mn.exe.dir/fort.13 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.14 ] && mv b2mn.exe.dir/fort.14 . || ( [ -e b2mn.exe.dir/fort.14 ] && rm b2mn.exe.dir/fort.14 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.15 ] && mv b2mn.exe.dir/fort.15 . || ( [ -e b2mn.exe.dir/fort.15 ] && rm b2mn.exe.dir/fort.15 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.44 ] && mv b2mn.exe.dir/fort.44 . || ( [ -e b2mn.exe.dir/fort.44 ] && rm b2mn.exe.dir/fort.44 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.46 ] && mv b2mn.exe.dir/fort.46 . || ( [ -e b2mn.exe.dir/fort.46 ] && rm b2mn.exe.dir/fort.46 || echo > /dev/null )
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX fort.21 fort.22 graphite_ext.dat mo_ext.dat fort.85 fort.78 fort.1 fort.29 fort.37 fort.55 vtk.out
	-[ -e b2mn.exe.dir/fort.33 ] && rm b2mn.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.34 ] && rm b2mn.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.35 ] && rm b2mn.exe.dir/fort.35 || echo > /dev/null
else
	-[ -s b2mn.exe.dir/ftn10 ] && mv b2mn.exe.dir/ftn10 . || ( [ -e b2mn.exe.dir/ftn10 ] && rm b2mn.exe.dir/ftn10 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn11 ] && mv b2mn.exe.dir/ftn11 . || ( [ -e b2mn.exe.dir/ftn11 ] && rm b2mn.exe.dir/ftn11 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn12 ] && mv b2mn.exe.dir/ftn12 . || ( [ -e b2mn.exe.dir/ftn12 ] && rm b2mn.exe.dir/ftn12 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn13 ] && mv b2mn.exe.dir/ftn13 . || ( [ -e b2mn.exe.dir/ftn13 ] && rm b2mn.exe.dir/ftn13 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn14 ] && mv b2mn.exe.dir/ftn14 . || ( [ -e b2mn.exe.dir/ftn14 ] && rm b2mn.exe.dir/ftn14 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn15 ] && mv b2mn.exe.dir/ftn15 . || ( [ -e b2mn.exe.dir/ftn15 ] && rm b2mn.exe.dir/ftn15 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn44 ] && mv b2mn.exe.dir/ftn44 . || ( [ -e b2mn.exe.dir/ftn44 ] && rm b2mn.exe.dir/ftn44 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn46 ] && mv b2mn.exe.dir/ftn46 . || ( [ -e b2mn.exe.dir/ftn46 ] && rm b2mn.exe.dir/ftn46 || echo > /dev/null )
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ftn21 ftn22 graphite_ext.dat mo_ext.dat ftn85 ftn78 ftn1 ftn29 ftn37 ftn55 vtk.out
	-[ -e b2mn.exe.dir/ftn33 ] && rm b2mn.exe.dir/ftn33 || echo > /dev/null
	-[ -e b2mn.exe.dir/ftn34 ] && rm b2mn.exe.dir/ftn34 || echo > /dev/null
	-[ -e b2mn.exe.dir/ftn35 ] && rm b2mn.exe.dir/ftn35 || echo > /dev/null
endif
ifdef SOLPS_MPI
	-[ -e b2mn.exe.dir/output.0001 ] && mv b2mn.exe.dir/output.* . || echo > /dev/null
endif
endif
ifneq (${COMPILER},HP)
	-[ -s b2mn.exe.dir/fort.31 ] && mv b2mn.exe.dir/fort.31 . || echo > /dev/null
else
	-[ -s b2mn.exe.dir/ftn31 ] && mv b2mn.exe.dir/ftn31 . || echo > /dev/null
endif
	-[ -s b2mn.exe.dir/b2time.nc ] && mv b2mn.exe.dir/b2time.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2batch.nc ] && mv b2mn.exe.dir/b2batch.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2wall.nc ] && mv b2mn.exe.dir/b2wall.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2movies.nc ] && mv b2mn.exe.dir/b2movies.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2tallies.nc ] && mv b2mn.exe.dir/b2tallies.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/balance.nc ] && mv b2mn.exe.dir/balance.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2_to_astra.dat ] && mv b2mn.exe.dir/b2_to_astra.dat . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fstate_add ] && mv b2mn.exe.dir/b2fstate_add . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2favere ] && mv b2mn.exe.dir/b2favere . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fplasmf.0000 ] && mv b2mn.exe.dir/b2fplasmf.* . || echo > /dev/null
	-[ -s b2mn.exe.dir/tran ] && mv b2mn.exe.dir/tran b2mn.exe.dir/tran?? . || echo > /dev/null
	-[ -e b2mn.exe.dir/tracing ] && rmdir b2mn.exe.dir/tracing || echo > /dev/null
	-[ -e b2mn.exe.dir/output/__1__.dat ] && rm b2mn.exe.dir/output/__1__.dat || echo > /dev/null
	-[ -e b2mn.exe.dir/output ] && rmdir b2mn.exe.dir/output || echo > /dev/null
	-[ -e b2mn.exe.dir/batch_av ] && rmdir b2mn.exe.dir/batch_av || echo > /dev/null
	-[ -e b2mn.exe.dir/run_av ] && rmdir b2mn.exe.dir/run_av || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fstati_with-ua ] && ( mv b2fstati b2fstati_with+ua ; mv b2mn.exe.dir/b2fstati_with-ua . ; cp -up b2fstati_with-ua b2fstati ; touch b2fstate ) || echo > /dev/null
	-rmdir b2mn.exe.dir

ifndef STAND_ALONE
ifneq (${COMPILER},HP)
dbx.b2mn : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates fort.30 AMJUEL
else
dbx.b2mn : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates ftn30 AMJUEL
endif
else
dbx.b2mn : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates
endif
	-rm -rf b2mn.exe.dir >& /dev/null ; mkdir b2mn.exe.dir ; cp $^ b2mn.exe.dir
ifneq (${COMPILER},HP)
	-rm -f $(target_mn) fort.31 balance.nc b2_to_astra.dat >& /dev/null
else
	-rm -f $(target_mn) ftn31 balance.nc b2_to_astra.dat >& /dev/null
endif
	save_initial_files
	-cd b2mn.exe.dir ; [ -s ../b2faveri ] && cp -p ../b2faveri . || echo > /dev/null
ifndef STAND_ALONE
ifdef SOLPS_MPI
	-rm -f output.* >& /dev/null
endif
ifneq (${COMPILER},HP)
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; ln -s ../input.dat fort.1 ; \
	[ -s ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; \
	[ -s ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; \
	[ -s ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; \
	[ -s ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; \
	[ -s ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; \
	[ -s ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; \
	[ -s ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; \
	[ -s ../fort.46 ] && cp -p ../fort.46 . || echo > /dev/null ; \
	[ -s ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; \
	[ -s ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; \
	[ -s ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
else
	[ -s ftn33 ] || ( [ -s $(baserundir)/ftn33 ] && ln -sf $(baserundir)/ftn33 . || ( [ -s $(triangdir)/ftn33 ] && ln -sf $(triangdir)/ftn33 . || echo > /dev/null ) )
	[ -s ftn34 ] || ( [ -s $(baserundir)/ftn34 ] && ln -sf $(baserundir)/ftn34 . || ( [ -s $(triangdir)/ftn34 ] && ln -sf $(triangdir)/ftn34 . || echo > /dev/null ) )
	[ -s ftn35 ] || ( [ -s $(baserundir)/ftn35 ] && ln -sf $(baserundir)/ftn35 . || ( [ -s $(triangdir)/ftn35 ] && ln -sf $(triangdir)/ftn35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; ln -s ../input.dat ftn1 ; \
	[ -s ../ftn15 ] && cp -p ../ftn15 . || echo > /dev/null ; \
	[ -s ../ftn14 ] && cp -p ../ftn14 . || echo > /dev/null ; \
	[ -s ../ftn13 ] && cp -p ../ftn13 . || echo > /dev/null ; \
	[ -s ../ftn12 ] && cp -p ../ftn12 . || echo > /dev/null ; \
	[ -s ../ftn11 ] && cp -p ../ftn11 . || echo > /dev/null ; \
	[ -s ../ftn10 ] && cp -p ../ftn10 . || echo > /dev/null ; \
	[ -s ../ftn44 ] && cp -p ../ftn44 . || echo > /dev/null ; \
	[ -s ../ftn46 ] && cp -p ../ftn46 . || echo > /dev/null ; \
	[ -s ../ftn33 ] && cp -p ../ftn33 . || echo > /dev/null ; \
	[ -s ../ftn34 ] && cp -p ../ftn34 . || echo > /dev/null ; \
	[ -s ../ftn35 ] && cp -p ../ftn35 . || echo > /dev/null
endif
endif
	cd b2mn.exe.dir ; mkdir tracing ; mkdir output ; copy_tracing_files ; mkdir batch_av ; mkdir run_av ; ${DBX} ${INC} ${DBGOBJ}/b2mn.exe ${RUN_OPTIONS} ; move_optional_files ; mv $(target_mn) .. >& /dev/null
ifneq (${COMPILER},HP)
	-[ -s fort.30 ] || ( [ -s ../baserun/fort.30 ] || ( [ -s b2mn.exe.dir/fort.30 ] && mv b2mn.exe.dir/fort.30 . || ( [ -e b2mn.exe.dir/fort.30 ] && rm b2mn.exe.dir/fort.30 || echo > /dev/null ) ) )
else
	-[ -s ftn30 ] || ( [ -s ../baserun/ftn30 ] || ( [ -s b2mn.exe.dir/ftn30 ] && mv b2mn.exe.dir/ftn30 . || ( [ -e b2mn.exe.dir/ftn30 ] && rm b2mn.exe.dir/ftn30 || echo > /dev/null ) ) )
endif
	-[ -s b2mn.exe.dir/b2faveri ] && mv b2mn.exe.dir/b2faveri . || ( [ -e b2mn.exe.dir/b2faveri ] && rm b2mn.exe.dir/b2faveri || echo > /dev/null )
	-cd b2mn.exe.dir ; rm -f $(notdir $^) .quit >& /dev/null
ifdef NCDIR
	-cd b2mn.exe.dir ; rm .netcdf4 >& /dev/null
endif
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	-[ -s b2mn.exe.dir/fort.10 ] && mv b2mn.exe.dir/fort.10 . || ( [ -e b2mn.exe.dir/fort.10 ] && rm b2mn.exe.dir/fort.10 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.11 ] && mv b2mn.exe.dir/fort.11 . || ( [ -e b2mn.exe.dir/fort.11 ] && rm b2mn.exe.dir/fort.11 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.12 ] && mv b2mn.exe.dir/fort.12 . || ( [ -e b2mn.exe.dir/fort.12 ] && rm b2mn.exe.dir/fort.12 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.13 ] && mv b2mn.exe.dir/fort.13 . || ( [ -e b2mn.exe.dir/fort.13 ] && rm b2mn.exe.dir/fort.13 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.14 ] && mv b2mn.exe.dir/fort.14 . || ( [ -e b2mn.exe.dir/fort.14 ] && rm b2mn.exe.dir/fort.14 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.15 ] && mv b2mn.exe.dir/fort.15 . || ( [ -e b2mn.exe.dir/fort.15 ] && rm b2mn.exe.dir/fort.15 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.44 ] && mv b2mn.exe.dir/fort.44 . || ( [ -e b2mn.exe.dir/fort.44 ] && rm b2mn.exe.dir/fort.44 || echo > /dev/null )
	-[ -s b2mn.exe.dir/fort.46 ] && mv b2mn.exe.dir/fort.46 . || ( [ -e b2mn.exe.dir/fort.46 ] && rm b2mn.exe.dir/fort.46 || echo > /dev/null )
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX fort.21 fort.22 graphite_ext.dat mo_ext.dat fort.85 fort.78 fort.1 fort.29 fort.37 fort.55 vtk.out
	-[ -e b2mn.exe.dir/fort.33 ] && rm b2mn.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.34 ] && rm b2mn.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.35 ] && rm b2mn.exe.dir/fort.35 || echo > /dev/null
else
	-[ -s b2mn.exe.dir/ftn10 ] && mv b2mn.exe.dir/ftn10 . || ( [ -e b2mn.exe.dir/ftn10 ] && rm b2mn.exe.dir/ftn10 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn11 ] && mv b2mn.exe.dir/ftn11 . || ( [ -e b2mn.exe.dir/ftn11 ] && rm b2mn.exe.dir/ftn11 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn12 ] && mv b2mn.exe.dir/ftn12 . || ( [ -e b2mn.exe.dir/ftn12 ] && rm b2mn.exe.dir/ftn12 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn13 ] && mv b2mn.exe.dir/ftn13 . || ( [ -e b2mn.exe.dir/ftn13 ] && rm b2mn.exe.dir/ftn13 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn14 ] && mv b2mn.exe.dir/ftn14 . || ( [ -e b2mn.exe.dir/ftn14 ] && rm b2mn.exe.dir/ftn14 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn15 ] && mv b2mn.exe.dir/ftn15 . || ( [ -e b2mn.exe.dir/ftn15 ] && rm b2mn.exe.dir/ftn15 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn44 ] && mv b2mn.exe.dir/ftn44 . || ( [ -e b2mn.exe.dir/ftn44 ] && rm b2mn.exe.dir/ftn44 || echo > /dev/null )
	-[ -s b2mn.exe.dir/ftn46 ] && mv b2mn.exe.dir/ftn46 . || ( [ -e b2mn.exe.dir/ftn46 ] && rm b2mn.exe.dir/ftn46 || echo > /dev/null )
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ftn21 ftn22 graphite_ext.dat mo_ext.dat ftn85 ftn78 ftn1 ftn29 ftn37 ftn55 vtk.out
	-[ -e b2mn.exe.dir/ftn33 ] && rm b2mn.exe.dir/ftn33 || echo > /dev/null
	-[ -e b2mn.exe.dir/ftn34 ] && rm b2mn.exe.dir/ftn34 || echo > /dev/null
	-[ -e b2mn.exe.dir/ftn35 ] && rm b2mn.exe.dir/ftn35 || echo > /dev/null
endif
ifdef SOLPS_MPI
	-[ -e b2mn.exe.dir/output.0001 ] && mv b2mn.exe.dir/output.* . || echo > /dev/null
endif
endif
ifneq (${COMPILER},HP)
	-[ -s b2mn.exe.dir/fort.31 ] && mv b2mn.exe.dir/fort.31 . || echo > /dev/null
else
	-[ -s b2mn.exe.dir/ftn31 ] && mv b2mn.exe.dir/ftn31 . || echo > /dev/null
endif
	-[ -s b2mn.exe.dir/b2time.nc ] && mv b2mn.exe.dir/b2time.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2batch.nc ] && mv b2mn.exe.dir/b2batch.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2wall.nc ] && mv b2mn.exe.dir/b2wall.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2movies.nc ] && mv b2mn.exe.dir/b2movies.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2tallies.nc ] && mv b2mn.exe.dir/b2tallies.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/balance.nc ] && mv b2mn.exe.dir/balance.nc . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2_to_astra.dat ] && mv b2mn.exe.dir/b2_to_astra.dat . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fstate_add ] && mv b2mn.exe.dir/b2fstate_add . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2favere ] && mv b2mn.exe.dir/b2favere . || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fplasmf.0000 ] && mv b2mn.exe.dir/b2fplasmf.* . || echo > /dev/null
	-[ -s b2mn.exe.dir/tran ] && mv b2mn.exe.dir/tran b2mn.exe.dir/tran?? . || echo > /dev/null
	-[ -e b2mn.exe.dir/tracing ] && rmdir b2mn.exe.dir/tracing || echo > /dev/null
	-[ -e b2mn.exe.dir/output/__1__.dat ] && rm b2mn.exe.dir/output/__1__.dat || echo > /dev/null
	-[ -e b2mn.exe.dir/output ] && rmdir b2mn.exe.dir/output || echo > /dev/null
	-[ -e b2mn.exe.dir/batch_av ] && rmdir b2mn.exe.dir/batch_av || echo > /dev/null
	-[ -e b2mn.exe.dir/run_av ] && rmdir b2mn.exe.dir/run_av || echo > /dev/null
	-[ -s b2mn.exe.dir/b2fstati_with-ua ] && ( mv b2fstati b2fstati_with+ua ; mv b2mn.exe.dir/b2fstati_with-ua b2fstati ) || echo > /dev/null
	-rmdir b2mn.exe.dir

ifndef STAND_ALONE
ifneq (${COMPILER},HP)
$(target_co) : b2mn.dat b2fgmtry b2fpardf b2fstati ${PLASMASTATE} ${savefiles} fort.33 fort.34 fort.35 input.dat AMJUEL
else
$(target_co) : b2mn.dat b2fgmtry b2fpardf b2fstati ${PLASMASTATE} ${savefiles} ftn33 ftn34 ftn35 input.dat AMJUEL
endif
else
$(target_co) : b2mn.dat b2fgmtry b2fpardf b2fstati ${PLASMASTATE} ${savefiles}
endif
	-rm -rf b2co.exe.dir >& /dev/null ; mkdir b2co.exe.dir ; cp $^ b2co.exe.dir
	inspect_plasmastate ${PLASMASTATE}
	-cd b2co.exe.dir ; mkdir tracing
	obtain_tracing_files
	rm -f $(target_co)
	cd b2co.exe.dir ; ${TIME} ${B2OBJ}/b2co.exe ${RUN_OPTIONS} `basename ${PLASMASTATE}` ; truncate_tracing_files ; mv $(target_co) b2fstate .. ; move_save_files ; rm -f $(notdir $^) ds? .quit >& /dev/null
ifndef STAND_ALONE
	cd b2co.exe.dir ; rm -f fort.85 >& /dev/null
endif
	-[ -e b2co.exe.dir/tracing/blne.trc ] && rm b2co.exe.dir/tracing/blne.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/blnm.trc ] && rm b2co.exe.dir/tracing/blnm.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/blnn.trc ] && rm b2co.exe.dir/tracing/blnn.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/integral.trc ] && rm b2co.exe.dir/tracing/integral.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/intshrt.trc ] && rm b2co.exe.dir/tracing/intshrt.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/sepdata.trc ] && rm b2co.exe.dir/tracing/sepdata.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/residuals.trc ] && rm b2co.exe.dir/tracing/residuals.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/sources.trc ] && rm b2co.exe.dir/tracing/sources.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/test.trc ] && rm b2co.exe.dir/tracing/test.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/user.trc ] && rm b2co.exe.dir/tracing/user.trc || echo > /dev/null
	-[ -e b2co.exe.dir/tracing/user.trc.n.01 ] && rm b2co.exe.dir/tracing/user.trc.n.01 || echo > /dev/null
	-[ -e b2co.exe.dir/tracing ] && rmdir b2co.exe.dir/tracing || echo > /dev/null
	-[ -e b2co.exe.dir/b2time.nc ] && rm b2co.exe.dir/b2time.nc || echo > /dev/null
	-[ -e b2co.exe.dir/b2wall.nc ] && rm b2co.exe.dir/b2wall.nc || echo > /dev/null
	-[ -e b2co.exe.dir/b2batch.nc ] && rm b2co.exe.dir/b2batch.nc || echo > /dev/null
	-[ -e b2co.exe.dir/b2movies.nc ] && rm b2co.exe.dir/b2movies.nc || echo > /dev/null
	-[ -e b2co.exe.dir/b2tallies.nc ] && rm b2co.exe.dir/b2tallies.nc || echo > /dev/null
	-rmdir b2co.exe.dir

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
ifneq (${COMPILER},HP)
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates AMJUEL fort.44 fort.46
else
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates AMJUEL ftn44 ftn46
endif
else
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates AMJUEL
endif
	rm -rf b2pl.exe.dir >& /dev/null ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
	rm -f $(target_pl)
	cd b2pl.exe.dir ; ${TIME} ${B2OBJ}/b2pl.exe ${RUN_OPTIONS} ; mv $(target_pl) .. ; rm -f $(notdir $^) .quit >& /dev/null
	-rmdir b2pl.exe.dir

$(target_rd) : shotnumber.history
	rm -rf b2rd.exe.dir >& /dev/null ; mkdir b2rd.exe.dir ; cp $^ b2rd.exe.dir
	rm -f $(target_rd)
	cd b2rd.exe.dir ; ${TIME} ${B2OBJ}/b2rd.exe ${RUN_OPTIONS} ; mv $(target_rd) b2fstate b2fgmtrt .. ; rm -f $(notdir $^) >& /dev/null
	-[ -e b2rd.exe.dir/*.txt ] && mv b2rd.exe.dir/*.txt . || echo > /dev/null
	-rmdir b2rd.exe.dir

$(target_ts) : b2fparam b2fgmtry b2fstate b2fplasma
	rm -rf b2ts.exe.dir >& /dev/null ; mkdir b2ts.exe.dir ; cp $^ b2ts.exe.dir
	rm -f $(target_ts)
	cd b2ts.exe.dir ; ${TIME} ${B2OBJ}/b2ts.exe ${RUN_OPTIONS} ; mv $(target_ts) b2fstate .. ; rm -f $(notdir $^) .quit >& /dev/null
	-rmdir b2ts.exe.dir

$(target_ye) : b2favere
	rm -rf b2ye.exe.dir >& /dev/null ; mkdir b2ye.exe.dir
	-[ -e b2favere ] && cp b2favere b2ye.exe.dir || echo > /dev/null
	-[ -e b2batch.nc ] && cp b2batch.nc b2ye.exe.dir || echo > /dev/null
	-[ -e b2time.nc ] && cp b2time.nc b2ye.exe.dir || echo > /dev/null
	echo "B2OBJ=" ${B2OBJ}
	cd b2ye.exe.dir ; ${TIME} ${B2OBJ}/b2ye.exe ${RUN_OPTIONS} ; mv b2ye.prt .. ; rm b2favere b2batch.nc b2time.nc
	-rmdir b2ye.exe.dir

$(target_yg) : b2yg.dat b2fgmtry
	rm -rf b2yg.exe.dir >& /dev/null ; mkdir b2yg.exe.dir ; cp $^ b2yg.exe.dir
	rm -f $(target_yg)
	NCARG_GKS_OUTPUT=b2yg.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yg.exe.dir ; ${TIME} ${B2OBJ}/b2yg.exe ${RUN_OPTIONS} ; mv $(target_yg) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yg.exe.dir

$(target_yh) : b2yh.dat b2fpardf b2fgmtry
	rm -rf b2yh.exe.dir >& /dev/null ; mkdir b2yh.exe.dir ; cp $^ b2yh.exe.dir
	-[ -e b2fparam ] && cp b2fparam b2yh.exe.dir || echo > /dev/null
	rm -f $(target_yh)
	NCARG_GKS_OUTPUT=b2yh.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yh.exe.dir ; ${TIME} ${B2OBJ}/b2yh.exe ${RUN_OPTIONS} ; mv $(target_yh) .. ; rm -f $(notdir $^) >& /dev/null
	-[ -e b2yh.exe.dir/b2fparam ] && rm b2yh.exe.dir/b2fparam || echo > /dev/null
	-rmdir b2yh.exe.dir

$(target_yi) : b2yi.dat b2fstati b2frates b2fgmtry
	rm -rf b2yi.exe.dir >& /dev/null ; mkdir b2yi.exe.dir ; cp $^ b2yi.exe.dir
	-[ -e b2fstate ] && cp b2fstate b2yi.exe.dir || echo > /dev/null
	-[ -e b2mn.dat ] && cp b2mn.dat b2yi.exe.dir || echo > /dev/null
	rm -f $(target_yi)
	NCARG_GKS_OUTPUT=b2yi.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yi.exe.dir ; ${TIME} ${B2OBJ}/b2yi.exe ${RUN_OPTIONS} ; mv $(target_yi) .. ; rm -f $(notdir $^) >& /dev/null
	-[ -e b2yi.exe.dir/b2fstate ] && rm b2yi.exe.dir/b2fstate || echo > /dev/null
	-[ -e b2yi.exe.dir/b2mn.dat ] && rm b2yi.exe.dir/b2mn.dat || echo > /dev/null
	-rmdir b2yi.exe.dir

$(target_yi_gnuplot) : b2fstati b2frates b2fgmtry
	rm -rf b2yi_gnuplot.exe.dir >& /dev/null ; mkdir b2yi_gnuplot.exe.dir ; cp $^ b2yi_gnuplot.exe.dir
	-[ -e b2fstate ] && cp b2fstate b2yi_gnuplot.exe.dir || echo > /dev/null
	-[ -e b2mn.dat ] && cp b2mn.dat b2yi_gnuplot.exe.dir || echo > /dev/null
	rm -f $(target_yi_gnuplot)
	cd b2yi_gnuplot.exe.dir ; ${TIME} ${B2OBJ}/b2yi_gnuplot.exe ${RUN_OPTIONS} ; mv $(target_yi_gnuplot) .. ; rm -f $(notdir $^) >& /dev/null
	-[ -e b2yi_gnuplot.exe.dir/b2fstate ] && rm b2yi_gnuplot.exe.dir/b2fstate || echo > /dev/null
	-[ -e b2yi_gnuplot.exe.dir/b2mn.dat ] && rm b2yi_gnuplot.exe.dir/b2mn.dat || echo > /dev/null
	-rmdir b2yi_gnuplot.exe.dir

$(target_ym) : b2ym.dat b2fmovie
	rm -rf b2ym.exe.dir >& /dev/null ; mkdir b2ym.exe.dir ; cp $^ b2ym.exe.dir
	rm -f $(target_ym)
	NCARG_GKS_OUTPUT=b2ym.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2ym.exe.dir ; ${TIME} ${B2OBJ}/b2ym.exe ${RUN_OPTIONS} ; mv $(target_ym) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2ym.exe.dir

$(target_yn) : b2yn.dat b2mn.dat b2ftrack b2frates b2fstate
	rm -rf b2yn.exe.dir >& /dev/null ; mkdir b2yn.exe.dir ; cp $^ b2yn.exe.dir
	rm -f $(target_yn)
	NCARG_GKS_OUTPUT=b2yn.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yn.exe.dir ; ${TIME} ${B2OBJ}/b2yn.exe ${RUN_OPTIONS} ; mv $(target_yn) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yn.exe.dir

$(target_yp) : b2yp.dat b2mn.dat b2fgmtry b2fparam b2fstate b2frates
	rm -rf b2yp.exe.dir >& /dev/null ; mkdir b2yp.exe.dir ; cp $^ b2yp.exe.dir
	rm -f $(target_yp)
	NCARG_GKS_OUTPUT=b2yp.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yp.exe.dir ; ${TIME} ${B2OBJ}/b2yp.exe ${RUN_OPTIONS} ; mv $(target_yp) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yp.exe.dir

$(target_yq) : b2yq.dat b2ftrace
	rm -rf b2yq.exe.dir >& /dev/null ; mkdir b2yq.exe.dir ; cp $^ b2yq.exe.dir
	rm -f $(target_yq)
	NCARG_GKS_OUTPUT=b2yq.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yq.exe.dir ; ${TIME} ${B2OBJ}/b2yq.exe ${RUN_OPTIONS} ; mv $(target_yq) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yq.exe.dir

$(target_yr) : b2yr.dat b2frates b2fpardf b2fgmtry
	rm -rf b2yr.exe.dir >& /dev/null ; mkdir b2yr.exe.dir ; cp $^ b2yr.exe.dir
	rm -f $(target_yr)
	NCARG_GKS_OUTPUT=b2yr.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yr.exe.dir ; ${TIME} ${B2OBJ}/b2yr.exe ${RUN_OPTIONS} ; mv $(target_yr) .. ; rm -f $(notdir $^) >& /dev/null
	-rmdir b2yr.exe.dir

ifndef STAND_ALONE
$(target_yt) : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf AMJUEL
else
$(target_yt) : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf
endif
	rm -rf b2yt.exe.dir >& /dev/null ; mkdir b2yt.exe.dir ; cp $^ b2yt.exe.dir
	rm -f $(target_yt)
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../fort.44 ] && ln -s ../fort.44 . || echo > /dev/null ; [ -e ../fort.46 ] && ln -s ../fort.46 . || echo > /dev/null ; [ -e ../fort.33 ] && ln -s ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && ln -s ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && ln -s ../fort.35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${TIME} ${B2OBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat fort.44 fort.46 fort.85 >& /dev/null ; mv *.2 ..
else
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../ftn44 ] && ln -s ../ftn44 . || echo > /dev/null ; [ -e ../ftn46 ] && ln -s ../ftn46 . || echo > /dev/null ; [ -e ../ftn33 ] && ln -s ../ftn33 . || echo > /dev/null ; [ -e ../ftn34 ] && ln -s ../ftn34 . || echo > /dev/null ; [ -e ../ftn35 ] && ln -s ../ftn35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${TIME} ${B2OBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat ftn44 ftn46 ftn85 >& /dev/null ; mv *.2 ..
endif
else
	cd b2yt.exe.dir ; ${TIME} ${B2OBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) >& /dev/null ; mv *.2 ..
endif
ifneq (${COMPILER},HP)
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX fort.21 fort.22
	-[ -e b2yt.exe.dir/fort.33 ] && rm b2yt.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.34 ] && rm b2yt.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.35 ] && rm b2yt.exe.dir/fort.35 || echo > /dev/null
else
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ftn21 fort.22
	-[ -e b2yt.exe.dir/ftn33 ] && rm b2yt.exe.dir/ftn33 || echo > /dev/null
	-[ -e b2yt.exe.dir/ftn34 ] && rm b2yt.exe.dir/ftn34 || echo > /dev/null
	-[ -e b2yt.exe.dir/ftn35 ] && rm b2yt.exe.dir/ftn35 || echo > /dev/null
endif
	-rmdir b2yt.exe.dir

ifndef STAND_ALONE
dbx.b2yt : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf AMJUEL
else
dbx.b2yt : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf
endif
	rm -rf b2yt.exe.dir >& /dev/null ; mkdir b2yt.exe.dir ; cp $^ b2yt.exe.dir
	rm -f $(target_yt)
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../fort.44 ] && ln -s ../fort.44 . || echo > /dev/null ; [ -e ../fort.46 ] && ln -s ../fort.46 . || echo > /dev/null ; [ -e ../fort.33 ] && ln -s ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && ln -s ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && ln -s ../fort.35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat fort.44 fort.46 fort.85 >& /dev/null ; mv *.2 ..
else
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../ftn44 ] && ln -s ../ftn44 . || echo > /dev/null ; [ -e ../ftn46 ] && ln -s ../ftn46 . || echo > /dev/null ; [ -e ../ftn33 ] && ln -s ../ftn33 . || echo > /dev/null ; [ -e ../ftn34 ] && ln -s ../ftn34 . || echo > /dev/null ; [ -e ../ftn35 ] && ln -s ../ftn35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat ftn44 ftn46 ftn85 >& /dev/null ; mv *.2 ..
endif
else
	cd b2yt.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2yt.exe ${RUN_OPTIONS} ; mv $(target_yt) .. ; rm -f $(notdir $^) >& /dev/null ; mv *.2 ..
endif
ifneq (${COMPILER},HP)
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX fort.21 fort.22
	-[ -e b2yt.exe.dir/fort.33 ] && rm b2yt.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.34 ] && rm b2yt.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.35 ] && rm b2yt.exe.dir/fort.35 || echo > /dev/null
else
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR AMMONX ftn21 ftn22
	-[ -e b2yt.exe.dir/ftn33 ] && rm b2yt.exe.dir/ftn33 || echo > /dev/null
	-[ -e b2yt.exe.dir/ftn34 ] && rm b2yt.exe.dir/ftn34 || echo > /dev/null
	-[ -e b2yt.exe.dir/ftn35 ] && rm b2yt.exe.dir/ftn35 || echo > /dev/null
endif
	-rmdir b2yt.exe.dir

ifndef STAND_ALONE
$(target_ual) : input.dat AMJUEL
else
$(target_ual) :
endif
	rm -rf b2_ual_write.exe.dir ; mkdir b2_ual_write.exe.dir
	cp b2fstate b2_ual_write.exe.dir/b2fstati
	cp b2fparam b2_ual_write.exe.dir/b2fpardf
	cp b2mn.dat b2_ual_write.exe.dir/
	[ -s b2fgmtry ] && cp b2fgmtry b2_ual_write.exe.dir/ || ( [ -s $(baserundir)/b2fgmtry ] && cp $(baserundir)/b2fgmtry b2_ual_write.exe.dir/ )
	[ -s b2frates ] && cp b2frates b2_ual_write.exe.dir/ || ( [ -s $(baserundir)/b2frates ] && cp $(baserundir)/b2frates b2_ual_write.exe.dir/ )
	cp b2fplasma b2_ual_write.exe.dir/
ifndef STAND_ALONE
	cp input.dat b2_ual_write.exe.dir/
	cp AMJUEL b2_ual_write.exe.dir/
endif
	-cd b2_ual_write.exe.dir ; [ -e ../b2faveri ] && cp -p ../b2faveri . || echo > /dev/null
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2_ual_write.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; ln -s ../input.dat fort.1 ; \
	[ -s ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; \
	[ -s ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; \
	[ -s ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; \
	[ -s ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; \
	[ -s ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; \
	[ -s ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; \
	[ -s ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; \
	[ -s ../fort.46 ] && cp -p ../fort.46 . || echo > /dev/null ; \
	[ -s ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; \
	[ -s ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; \
	[ -s ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
else
	[ -s ftn33 ] || ( [ -s $(baserundir)/ftn33 ] && ln -sf $(baserundir)/ftn33 . || ( [ -s $(triangdir)/ftn33 ] && ln -sf $(triangdir)/ftn33 . || echo > /dev/null ) )
	[ -s ftn34 ] || ( [ -s $(baserundir)/ftn34 ] && ln -sf $(baserundir)/ftn34 . || ( [ -s $(triangdir)/ftn34 ] && ln -sf $(triangdir)/ftn34 . || echo > /dev/null ) )
	[ -s ftn35 ] || ( [ -s $(baserundir)/ftn35 ] && ln -sf $(baserundir)/ftn35 . || ( [ -s $(triangdir)/ftn35 ] && ln -sf $(triangdir)/ftn35 . || echo > /dev/null ) )
	-cd b2_ual_write.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; ln -s ../input.dat ftn1 ; \
	[ -s ../ftn15 ] && cp -p ../ftn15 . || echo > /dev/null ; \
	[ -s ../ftn14 ] && cp -p ../ftn14 . || echo > /dev/null ; \
	[ -s ../ftn13 ] && cp -p ../ftn13 . || echo > /dev/null ; \
	[ -s ../ftn12 ] && cp -p ../ftn12 . || echo > /dev/null ; \
	[ -s ../ftn11 ] && cp -p ../ftn11 . || echo > /dev/null ; \
	[ -s ../ftn10 ] && cp -p ../ftn10 . || echo > /dev/null ; \
	[ -s ../ftn44 ] && cp -p ../ftn44 . || echo > /dev/null ; \
	[ -s ../ftn46 ] && cp -p ../ftn46 . || echo > /dev/null ; \
	[ -s ../ftn33 ] && cp -p ../ftn33 . || echo > /dev/null ; \
	[ -s ../ftn34 ] && cp -p ../ftn34 . || echo > /dev/null ; \
	[ -s ../ftn35 ] && cp -p ../ftn35 . || echo > /dev/null
endif
endif
	cd b2_ual_write.exe.dir ; ${TIME} ${B2OBJ}/b2_ual_write.exe ${RUN_OPTIONS}
	rm -rf b2_ual_write.exe.dir

ifndef STAND_ALONE
$(target_rew) : input.dat AMJUEL
else
$(target_rew) :
endif
	rm -rf b2_ual_rewrite.exe.dir ; mkdir b2_ual_rewrite.exe.dir
	cp b2fstate b2_ual_rewrite.exe.dir/b2fstati
	cp b2fparam b2_ual_rewrite.exe.dir/b2fpardf
	cp b2mn.dat b2_ual_rewrite.exe.dir/
	[ -s b2fgmtry ] && cp b2fgmtry b2_ual_rewrite.exe.dir/ || ( [ -s $(baserundir)/b2fgmtry ] && cp $(baserundir)/b2fgmtry b2_ual_rewrite.exe.dir/ )
	[ -s b2frates ] && cp b2frates b2_ual_rewrite.exe.dir/ || ( [ -s $(baserundir)/b2frates ] && cp $(baserundir)/b2frates b2_ual_rewrite.exe.dir/ )
	cp b2fplasma b2_ual_rewrite.exe.dir/
ifndef STAND_ALONE
	cp input.dat b2_ual_rewrite.exe.dir/
	cp AMJUEL b2_ual_rewrite.exe.dir/
endif
	-cd b2_ual_rewrite.exe.dir ; [ -e ../b2faveri ] && cp -p ../b2faveri . || echo > /dev/null
ifndef STAND_ALONE
ifneq (${COMPILER},HP)
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2_ual_rewrite.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../fort.21 ../fort.22 . ; ln -s ../input.dat fort.1 ; \
	[ -s ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; \
	[ -s ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; \
	[ -s ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; \
	[ -s ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; \
	[ -s ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; \
	[ -s ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; \
	[ -s ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; \
	[ -s ../fort.46 ] && cp -p ../fort.46 . || echo > /dev/null ; \
	[ -s ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; \
	[ -s ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; \
	[ -s ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
else
	[ -s ftn33 ] || ( [ -s $(baserundir)/ftn33 ] && ln -sf $(baserundir)/ftn33 . || ( [ -s $(triangdir)/ftn33 ] && ln -sf $(triangdir)/ftn33 . || echo > /dev/null ) )
	[ -s ftn34 ] || ( [ -s $(baserundir)/ftn34 ] && ln -sf $(baserundir)/ftn34 . || ( [ -s $(triangdir)/ftn34 ] && ln -sf $(triangdir)/ftn34 . || echo > /dev/null ) )
	[ -s ftn35 ] || ( [ -s $(baserundir)/ftn35 ] && ln -sf $(baserundir)/ftn35 . || ( [ -s $(triangdir)/ftn35 ] && ln -sf $(triangdir)/ftn35 . || echo > /dev/null ) )
	-cd b2_ual_rewrite.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../AMMONX ../ftn21 ../ftn22 . ; ln -s ../input.dat ftn1 ; \
	[ -s ../ftn15 ] && cp -p ../ftn15 . || echo > /dev/null ; \
	[ -s ../ftn14 ] && cp -p ../ftn14 . || echo > /dev/null ; \
	[ -s ../ftn13 ] && cp -p ../ftn13 . || echo > /dev/null ; \
	[ -s ../ftn12 ] && cp -p ../ftn12 . || echo > /dev/null ; \
	[ -s ../ftn11 ] && cp -p ../ftn11 . || echo > /dev/null ; \
	[ -s ../ftn10 ] && cp -p ../ftn10 . || echo > /dev/null ; \
	[ -s ../ftn44 ] && cp -p ../ftn44 . || echo > /dev/null ; \
	[ -s ../ftn46 ] && cp -p ../ftn46 . || echo > /dev/null ; \
	[ -s ../ftn33 ] && cp -p ../ftn33 . || echo > /dev/null ; \
	[ -s ../ftn34 ] && cp -p ../ftn34 . || echo > /dev/null ; \
	[ -s ../ftn35 ] && cp -p ../ftn35 . || echo > /dev/null
endif
endif
	cd b2_ual_rewrite.exe.dir ; ${TIME} ${B2OBJ}/b2_ual_rewrite.exe ${RUN_OPTIONS}
	-[ -s b2_ual_rewrite.exe.dir/ids_*.yaml ] && mv b2_ual_rewrite.exe.dir/ids_*.yaml . || ( [ -e b2_ual_rewrite.exe.dir/ids_*.yaml ] && rm b2_ual_rewrite.exe.dir/ids_*.yaml || echo > /dev/null )
	-[ -s b2_ual_rewrite.exe.dir/ids_*.watcher ] && mv b2_ual_rewrite.exe.dir/ids_*.watcher . || ( [ -e b2_ual_rewrite.exe.dir/ids_*.watcher ] && rm b2_ual_rewrite.exe.dir/ids_*.watcher || echo > /dev/null )
	rm -rf b2_ual_rewrite.exe.dir

stra.dat :
	ln -sf ${SOLPSTOP}/modules/B2.5/Database/stra.dat .

weis.dat :
	ln -sf ${SOLPSTOP}/modules/B2.5/Database/weis.dat .

AMJUEL:
	ln -sf ${SOLPSTOP}/modules/Eirene/Database/AMJUEL .

$(savefiles):
	touch $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.dummy_save.parameters:')
	$(eval savefiles := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.dummy_save.parameters:'))

clean :
	rm -f *.prt* *.plt* *~
	rm -rf *.exe.dir

realclean : clean
	rm -f b2fgmtry b2fpar* b2frates b2fstat* b2ftra* b2fmovie b2specp b2faver* *.nc

# The target testvars is present only for testing purposes.
testvars :
	@echo scandir: $(scandir)
	@echo projdir: $(projdir)
	@echo baserundir: $(baserundir)
	@echo codedir: $(codedir)

help help.prt:
	@echo "Available targets are:"
	@echo "  ${target_ag} : "
	@echo "     produce the geometry information"
	@echo "  ${target_ah} : "
	@echo "     produce the default physics information"
	@echo "  ${target_ai} : "
	@echo "     produce the initial plasma state"
	@echo "  ${target_ar} : "
	@echo "     produce the atomic physics rate information"
	@echo "  ${target_mn} : "
	@echo "     run the main code"
	@echo "  ${target_co} : "
	@echo "     prepare a b2fstate file from a plasmastate file"
	@echo "  ${target_rd} : "
	@echo "     prepare a b2fstate file from a saved MDSPLUS archive"
	@echo "  ${target_uf} : "
	@echo "     convert an unformatted b2fplasma file to a formatted b2fplasmf file"
	@echo "  ${target_fu} : "
	@echo "     convert a formatted b2fplasmf file to an unformatted b2fplasma file"
	@echo "  ${target_pl} : "
	@echo "     run b2plot"
	@echo "  ${target_ts} : "
	@echo "     run a dummy example of a post-processor"
	@echo "  ${target_ye} : "
	@echo "     provide an error assessment for a coupled run"
	@echo "  ${target_yg} : "
	@echo "     display geometry and magnetic field"
	@echo "  ${target_yh} : "
	@echo "     display the physics parameters"
	@echo "  ${target_yi} : "
	@echo "     display the initial plasma state"
	@echo "  ${target_yi_gnuplot} : "
	@echo "     display the plasma state via gnuplot"
	@echo "  ${target_ym} : "
	@echo "     display a movie [not tested]"
	@echo "  ${target_yn} : "
	@echo "     display the progress of the inner b2 iterations"
	@echo "  ${target_yp} : "
	@echo "     display the final plasma state"
	@echo "  ${target_yq} : "
	@echo "     display a quick view of the evolution data"
	@echo "  ${target_yr} : "
	@echo "     display the atomic physics rates"
	@echo "  ${target_yt} : "
	@echo "     transfer the plasma state to a mesh of a different size and/or re-order or remove species"
	@echo "  ${target_xd} : "
	@echo "     convert the plasma state to a SOLPS4.0 B2SXDR file [obsolete]"

