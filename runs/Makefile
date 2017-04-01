# GNU Makefile for B2.5; part 2--execution.
# Please see the general comments in the companion Makefile, part 1,
# which controls compile and load.
#-----------------------------------------------------------------------
# Variables.

SHELL = /usr/bin/env sh
TIME = time

# Default debugger
DBX ?= dbx

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
B2OBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
EIROBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}.debug
EDBOBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ} -I ${EDBOBJ}
endif
else
B2OBJ = ${SOLPSTOP}/modules/B2.5/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
DBGOBJ = ${SOLPSTOP}/modules/B2.5/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}.debug
ifneq (${DBX},totalview)
INC = -I ${DBGOBJ}
endif
endif


prints = b2ag.prt b2ah.prt b2ai.prt b2ar.prt b2mn.prt \
 b2yg.prt b2yh.prt b2yi.prt b2ym.prt b2yn.prt b2yp.prt b2yq.prt \
 b2yr.prt b2yt.prt b2yi_gnuplot.prt

target_ag = b2ag.prt b2fgmtry fort.30
target_ah = b2ah.prt b2fpardf
target_ai = b2ai.prt b2fstati
target_ar = b2ar.prt b2frates
target_mn = b2mn.prt b2fparam b2fstate b2fmovie b2ftrace b2ftrack b2fplasma
ifdef USE_IMPGYRO
target_mn += restart_ext
endif
target_uf = b2uf.prt
target_fu = b2fu.prt
target_co = b2co.prt
target_pl = b2pl.prt b2plot.ps
target_ts = b2ts.prt
target_yg = b2yg.prt b2yg.plt
target_yh = b2yh.prt
target_yi = b2yi.prt b2yi.plt
target_yi_gnuplot = b2yi_gnuplot.prt
target_ym = b2ym.prt b2ym.plt
target_yn = b2yn.prt b2yn.plt
target_yp = b2yp.prt b2yp.plt b2specp
target_yq = b2yq.prt b2yq.plt
target_yr = b2yr.prt b2yr.plt
target_yt = b2yt.prt b2fstatt b2yt.files
target_xd = B2SXDR
target_rd = b2rd.prt
target_ual = b2_ual_write.prt

scandir := $(shell cd .. ; pwd)
projdir := $(shell cd ../.. ; pwd)
ifeq ($(shell [ -d ${scandir}/TRIANG ] && echo yes || echo no ),yes)
triangdir := $(shell cd $(scandir)/TRIANG ; pwd)
else
triangdir := $(shell cd $(scandir)/baserun ; pwd)
endif
baserundir := $(shell cd $(scandir)/baserun ; pwd)
savefiles := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.*_save.parameters:')
fort44file := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:fort.44:')
ifeq ($(shell [ -e $(fort44file) ] && echo yes || echo no ),yes)
savefiles += $(fort44file)
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
vpath fort.30  .:$(baserundir)
vpath fort.33  .:$(baserundir):$(triangdir)
vpath fort.34  .:$(baserundir):$(triangdir)
vpath fort.35  .:$(baserundir):$(triangdir)
vpath stra.dat .:$(baserundir)
vpath weis.dat .:$(baserundir)
vpath b2frates .:$(baserundir)

#-----------------------------------------------------------------------
# Rules.

default : b2mn.prt
all : $(prints)
prt : $(prints)

.PHONY : default all prt clean realclean testvars
.PRECIOUS : $(prints)
.SUFFIXES : $(nil)

$(target_xd) : b2fgmtry b2fparam b2fstate b2fplasma
	rm -rf b2xd.exe.dir >& /dev/null ; mkdir b2xd.exe.dir ; cp $^ b2xd.exe.dir
	rm -f $(target_xd)
	cd b2xd.exe.dir ; ${TIME} ${B2OBJ}/b2xd.exe ; mv $(target_xd) .. ; rm -f $(notdir $^)
	-rmdir b2xd.exe.dir

$(target_ag) : b2ag.dat
	rm -rf b2ag.exe.dir >& /dev/null ; mkdir b2ag.exe.dir ; cp $^ b2ag.exe.dir
	rm -f $(target_ag)
	cd b2ag.exe.dir ; ${TIME} ${B2OBJ}/b2ag.exe ; mv $(target_ag) .. ; rm -f $(notdir $^)
	-rmdir b2ag.exe.dir

$(target_ah) : b2ah.dat b2fgmtry
	rm -rf b2ah.exe.dir >& /dev/null ; mkdir b2ah.exe.dir ; cp $^ b2ah.exe.dir
	rm -f $(target_ah)
	cd b2ah.exe.dir ; ${TIME} ${B2OBJ}/b2ah.exe ; mv $(target_ah) .. ; rm -f $(notdir $^)
	-rmdir b2ah.exe.dir

$(target_ai) : b2ag.dat b2ai.dat b2fgmtry
	rm -rf b2ai.exe.dir >& /dev/null ; mkdir b2ai.exe.dir ; cp $^ b2ai.exe.dir
	rm -f $(target_ai)
	cd b2ai.exe.dir ; ${TIME} ${B2OBJ}/b2ai.exe ; mv $(target_ai) .. ; rm -f $(notdir $^)
	-rmdir b2ai.exe.dir

$(target_ar) : b2ar.dat stra.dat weis.dat b2fpardf b2fgmtry
	rm -rf b2ar.exe.dir >& /dev/null ; mkdir b2ar.exe.dir ; cp $^ b2ar.exe.dir
	rm -f $(target_ar)
	cd b2ar.exe.dir ; ${TIME} ${B2OBJ}/b2ar.exe ; mv $(target_ar) .. ; rm -f $(notdir $^)
	-rmdir b2ar.exe.dir

$(target_mn) : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates fort.30 AMJUEL
	-rm -rf b2mn.exe.dir >& /dev/null ; mkdir b2mn.exe.dir ; cp $^ b2mn.exe.dir
	-rm -f $(target_mn) fort.31 b2time.nc b2wall.nc b2tallies.nc balance.nc b2movies.nc b2_to_astra.dat >& /dev/null
ifndef STAND_ALONE
ifdef SOLPS_MPI
	-rm -f output.* >& /dev/null
endif
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../fort.21 ../fort.22 ../graphite_ext.dat ../mo_ext.dat . ; ln -s ../input.dat fort.1 ; [ -e ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; [ -e ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; [ -e ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; [ -e ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; [ -e ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; [ -e ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; [ -e ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; [ -e ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
endif
ifdef USE_IMPGYRO
	-cd b2mn.exe.dir ; touch b2ig.conf ; echo "-n ${NPE_B2} : ${B2OBJ}/b2mn.exe" >> b2ig.conf ; echo "-n ${NPE_EXT} : ${EXE_EXT}" >> b2ig.conf ; ln -s ../config ../pre . ; mkdir tracing ;\
	touch use_impgyro ; [ -e ../restart_ext ] && cp ../restart_ext . || echo > /dev/null ; [ -e ../restart ] && cp ../restart . && cp ${WD_EXT}/.st.?* . || echo > /dev/null ;\
	mpiexec -verbose -config b2ig.conf;\
	mv $(target_mn) .. >& /dev/null ; [ -d ../tracing ] || mkdir ../tracing ; mv -f tracing/* ../tracing ; [ -e ../fort.30 ] || mv fort.30 .. ; \
	rm -f $(notdir $^) .quit ; rm -f b2ig.conf use_impgyro config pre ; [ -e restart_ext ] && cp restart_ext ../. || echo > /dev/null ;\
	mv .*.?* ${WD_EXT}/. ; mv fort.150 ${WD_EXT}/. ;\
	mv impgyro.* ${WD_EXT}/. ; mv preg ${WD_EXT}/. ; cp restart ${WD_EXT}/. ; mv restart ../. ; mv d?? ds?? ds??? b2.*.parameters .. >& /dev/null
else
	-cd b2mn.exe.dir ; mkdir tracing ; ${TIME} ${B2OBJ}/b2mn.exe ; mv $(target_mn) .. >& /dev/null ; [ -d ../tracing ] || mkdir ../tracing ; mv -f tracing/* ../tracing ; [ -e ../fort.30 ] || mv fort.30 .. ; rm -f $(notdir $^) .quit ; mv d?? ds?? ds??? b2.*.parameters .. >& /dev/null
endif
ifndef STAND_ALONE
	-[ -e b2mn.exe.dir/fort.10 ] && mv b2mn.exe.dir/fort.10 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.11 ] && mv b2mn.exe.dir/fort.11 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.12 ] && mv b2mn.exe.dir/fort.12 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.13 ] && mv b2mn.exe.dir/fort.13 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.14 ] && mv b2mn.exe.dir/fort.14 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.15 ] && mv b2mn.exe.dir/fort.15 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.44 ] && mv b2mn.exe.dir/fort.44 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.46 ] && mv b2mn.exe.dir/fort.46 . || echo > /dev/null
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR fort.21 fort.22 graphite_ext.dat mo_ext.dat fort.75 fort.78 fort.1 fort.29 fort.37 fort.55 vtk.out
	-[ -e b2mn.exe.dir/fort.33 ] && rm b2mn.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.34 ] && rm b2mn.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.35 ] && rm b2mn.exe.dir/fort.35 || echo > /dev/null
ifdef SOLPS_MPI
	-[ -e b2mn.exe.dir/output.0001 ] && mv b2mn.exe.dir/output.* . || echo > /dev/null
endif
endif
	-[ -e fort.30 ] && echo > /dev/null || mv b2mn.exe.dir/fort.30 .
	-[ -e b2mn.exe.dir/fort.31 ] && mv b2mn.exe.dir/fort.31 . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2time.nc ] && mv b2mn.exe.dir/b2time.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2wall.nc ] && mv b2mn.exe.dir/b2wall.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2movies.nc ] && mv b2mn.exe.dir/b2movies.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2tallies.nc ] && mv b2mn.exe.dir/b2tallies.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/balance.nc ] && mv b2mn.exe.dir/balance.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2_to_astra.dat ] && mv b2mn.exe.dir/b2_to_astra.dat . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2fstate_add ] && mv b2mn.exe.dir/b2fstate_add . || echo > /dev/null
	-[ -e b2mn.exe.dir/tran ] && mv b2mn.exe.dir/tran b2mn.exe.dir/tran?? . || echo > /dev/null
	-[ -e b2mn.exe.dir/tracing ] && rmdir b2mn.exe.dir/tracing || echo > /dev/null
	-[ -e b2mn.exe.dir/b2fstati_with-ua ] && ( mv b2fstati b2fstati_with+ua ; mv b2mn.exe.dir/b2fstati_with-ua . ; cp -up b2fstati_with-ua b2fstati ; touch b2fstate ) || echo > /dev/null
	-rmdir b2mn.exe.dir

dbx.b2mn : b2mn.dat b2fgmtry b2fpardf b2fstati b2frates fort.30 AMJUEL
	-rm -rf b2mn.exe.dir >& /dev/null ; mkdir b2mn.exe.dir ; cp $^ b2mn.exe.dir
	-rm -f $(target_mn) fort.31 b2time.nc b2wall.nc b2tallies.nc balance.nc b2movies.nc b2_to_astra.dat >& /dev/null
ifndef STAND_ALONE
ifdef SOLPS_MPI
	-rm -f output.* >& /dev/null
endif
	[ -s fort.33 ] || ( [ -s $(baserundir)/fort.33 ] && ln -sf $(baserundir)/fort.33 . || ( [ -s $(triangdir)/fort.33 ] && ln -sf $(triangdir)/fort.33 . || echo > /dev/null ) )
	[ -s fort.34 ] || ( [ -s $(baserundir)/fort.34 ] && ln -sf $(baserundir)/fort.34 . || ( [ -s $(triangdir)/fort.34 ] && ln -sf $(triangdir)/fort.34 . || echo > /dev/null ) )
	[ -s fort.35 ] || ( [ -s $(baserundir)/fort.35 ] && ln -sf $(baserundir)/fort.35 . || ( [ -s $(triangdir)/fort.35 ] && ln -sf $(triangdir)/fort.35 . || echo > /dev/null ) )
	-cd b2mn.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../fort.21 ../fort.22 ../graphite_ext.dat ../mo_ext.dat . ; ln -s ../input.dat fort.1 ; [ -e ../fort.15 ] && cp -p ../fort.15 . || echo > /dev/null ; [ -e ../fort.14 ] && cp -p ../fort.14 . || echo > /dev/null ; [ -e ../fort.13 ] && cp -p ../fort.13 . || echo > /dev/null ; [ -e ../fort.12 ] && cp -p ../fort.12 . || echo > /dev/null ; [ -e ../fort.11 ] && cp -p ../fort.11 . || echo > /dev/null ; [ -e ../fort.10 ] && cp -p ../fort.10 . || echo > /dev/null ; [ -e ../fort.44 ] && cp -p ../fort.44 . || echo > /dev/null ; [ -e ../fort.33 ] && cp -p ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && cp -p ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && cp -p ../fort.35 . || echo > /dev/null
	cd b2mn.exe.dir ; mkdir tracing ; ${DBX} ${INC} ${DBGOBJ}/b2mn.exe ; mv $(target_mn) .. >& /dev/null ; [ -d ../tracing ] || mkdir ../tracing ; mv -f tracing/* ../tracing ; [ -e ../fort.30 ] || mv fort.30 .. ; rm -f $(notdir $^) .quit ; mv d?? ds?? ds??? b2.*.parameters .. >& /dev/null
	-[ -e b2mn.exe.dir/fort.10 ] && mv b2mn.exe.dir/fort.10 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.11 ] && mv b2mn.exe.dir/fort.11 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.12 ] && mv b2mn.exe.dir/fort.12 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.13 ] && mv b2mn.exe.dir/fort.13 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.14 ] && mv b2mn.exe.dir/fort.14 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.15 ] && mv b2mn.exe.dir/fort.15 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.44 ] && mv b2mn.exe.dir/fort.44 . || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.46 ] && mv b2mn.exe.dir/fort.46 . || echo > /dev/null
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR fort.21 fort.22 graphite_ext.dat mo_ext.dat fort.75 fort.78 fort.1 fort.29 fort.37 fort.55 vtk.out
	-[ -e b2mn.exe.dir/fort.33 ] && rm b2mn.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.34 ] && rm b2mn.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2mn.exe.dir/fort.35 ] && rm b2mn.exe.dir/fort.35 || echo > /dev/null
ifdef SOLPS_MPI
	-[ -e b2mn.exe.dir/output.0001 ] && mv b2mn.exe.dir/output.* . || echo > /dev/null
endif
else
	cd b2mn.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2mn.exe ; rm -f $(notdir $^) .quit ; mv d?? ds?? ds??? b2.*.parameters .. >& /dev/null
endif
	-[ -e fort.30 ] && echo > /dev/null || mv b2mn.exe.dir/fort.30 .
	-cd b2mn.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR fort.21 fort.22 graphite_ext.dat mo_ext.dat
	-[ -e b2mn.exe.dir/fort.31 ] && mv b2mn.exe.dir/fort.31 . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2time.nc ] && mv b2mn.exe.dir/b2time.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2wall.nc ] && mv b2mn.exe.dir/b2wall.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2movies.nc ] && mv b2mn.exe.dir/b2movies.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2tallies.nc ] && mv b2mn.exe.dir/b2tallies.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/balance.nc ] && mv b2mn.exe.dir/balance.nc . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2_to_astra.dat ] && mv b2mn.exe.dir/b2_to_astra.dat . || echo > /dev/null
	-[ -e b2mn.exe.dir/b2fstate_add ] && mv b2mn.exe.dir/b2fstate_add . || echo > /dev/null
	-[ -e b2mn.exe.dir/tran ] && mv b2mn.exe.dir/tran b2mn.exe.dir/tran?? . || echo > /dev/null
	-[ -e b2mn.exe.dir/tracing ] && rmdir b2mn.exe.dir/tracing || echo > /dev/null
	-[ -e b2mn.exe.dir/b2fstati_with-ua ] && ( mv b2fstati b2fstati_with+ua ; mv b2mn.exe.dir/b2fstati_with-ua b2fstati ) || echo > /dev/null
	-rmdir b2mn.exe.dir

ifndef STAND_ALONE
$(target_co) : b2mn.dat b2fgmtry b2fpardf b2fstati ${PLASMASTATE} ${savefiles} fort.33 fort.34 fort.35
else
$(target_co) : b2mn.dat b2fgmtry b2fpardf b2fstati ${PLASMASTATE} ${savefiles}
endif
	-rm -rf b2co.exe.dir >& /dev/null ; mkdir b2co.exe.dir ; cp $^ b2co.exe.dir
	rm -f $(target_co)
ifndef STAND_ALONE
	-cd b2co.exe.dir ; ln -s ../input.dat .
endif
	cd b2co.exe.dir ; ${TIME} ${B2OBJ}/b2co.exe `basename ${PLASMASTATE}` ; mv $(target_co) b2fstate .. ; move_save_files ; rm -f $(notdir $^) .quit
ifndef STAND_ALONE
	-[ -e b2co.exe.dir/input.dat ] && rm b2co.exe.dir/input.dat
endif
	-rmdir b2co.exe.dir

$(target_uf) : b2fgmtry b2fparam b2fstate b2fplasma
	rm -rf b2uf.exe.dir >& /dev/null ; mkdir b2uf.exe.dir ; cp $^ b2uf.exe.dir
	rm -f $(target_uf)
	cd b2uf.exe.dir ; ${TIME} ${B2OBJ}/b2uf.exe ; mv $(target_uf) b2fplasmf .. ; rm -f $(notdir $^) .quit
	-rmdir b2uf.exe.dir

$(target_fu) : b2fgmtry b2fparam b2fstate b2fplasmf
	rm -rf b2fu.exe.dir >& /dev/null ; mkdir b2fu.exe.dir ; cp $^ b2fu.exe.dir
	rm -f $(target_fu)
	cd b2fu.exe.dir ; ${TIME} ${B2OBJ}/b2fu.exe ; mv $(target_fu) b2fplasma .. ; rm -f $(notdir $^) .quit
	-rmdir b2fu.exe.dir

ifndef STAND_ALONE
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates AMJUEL fort.44 fort.46
else
$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates AMJUEL
endif
	rm -rf b2pl.exe.dir >& /dev/null ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
	rm -f $(target_pl)
	cd b2pl.exe.dir ; ${TIME} ${B2OBJ}/b2pl.exe ; mv $(target_pl) .. ; rm -f $(notdir $^) .quit
	-rmdir b2pl.exe.dir

$(target_rd) : shotnumber.history
	rm -rf b2rd.exe.dir >& /dev/null ; mkdir b2rd.exe.dir ; cp $^ b2rd.exe.dir
	rm -f $(target_rd)
	cd b2rd.exe.dir ; ${TIME} ${B2OBJ}/b2rd.exe ; mv $(target_rd) b2fstate b2fgmtrt .. ; rm -f $(notdir $^)
	-[ -e b2rd.exe.dir/*.txt ] && mv b2rd.exe.dir/*.txt . || echo > /dev/null
	-rmdir b2rd.exe.dir

$(target_ts) : b2fparam b2fgmtry b2fstate b2fplasma
	rm -rf b2ts.exe.dir >& /dev/null ; mkdir b2ts.exe.dir ; cp $^ b2ts.exe.dir
	rm -f $(target_ts)
	cd b2ts.exe.dir ; ${TIME} ${B2OBJ}/b2ts.exe ; mv $(target_ts) b2fstate .. ; rm -f $(notdir $^) .quit
	-rmdir b2ts.exe.dir

$(target_yg) : b2yg.dat b2fgmtry
	rm -rf b2yg.exe.dir >& /dev/null ; mkdir b2yg.exe.dir ; cp $^ b2yg.exe.dir
	rm -f $(target_yg)
	NCARG_GKS_OUTPUT=b2yg.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yg.exe.dir ; ${TIME} ${B2OBJ}/b2yg.exe ; mv $(target_yg) .. ; rm -f $(notdir $^)
	-rmdir b2yg.exe.dir

$(target_yh) : b2yh.dat b2fpardf b2fgmtry
	rm -rf b2yh.exe.dir >& /dev/null ; mkdir b2yh.exe.dir ; cp $^ b2yh.exe.dir
	-[ -e b2fparam ] && cp b2fparam b2yh.exe.dir || echo > /dev/null
	rm -f $(target_yh)
	NCARG_GKS_OUTPUT=b2yh.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yh.exe.dir ; ${TIME} ${B2OBJ}/b2yh.exe ; mv $(target_yh) .. ; rm -f $(notdir $^)
	-[ -e b2yh.exe.dir/b2fparam ] && rm b2yh.exe.dir/b2fparam || echo > /dev/null
	-rmdir b2yh.exe.dir

$(target_yi) : b2yi.dat b2fstati b2frates b2fgmtry
	rm -rf b2yi.exe.dir >& /dev/null ; mkdir b2yi.exe.dir ; cp $^ b2yi.exe.dir
	-[ -e b2fstate ] && cp b2fstate b2yi.exe.dir || echo > /dev/null
	-[ -e b2mn.dat ] && cp b2mn.dat b2yi.exe.dir || echo > /dev/null
	rm -f $(target_yi)
	NCARG_GKS_OUTPUT=b2yi.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yi.exe.dir ; ${TIME} ${B2OBJ}/b2yi.exe ; mv $(target_yi) .. ; rm -f $(notdir $^)
	-[ -e b2yi.exe.dir/b2fstate ] && rm b2yi.exe.dir/b2fstate || echo > /dev/null
	-[ -e b2yi.exe.dir/b2mn.dat ] && rm b2yi.exe.dir/b2mn.dat || echo > /dev/null
	-rmdir b2yi.exe.dir

$(target_yi_gnuplot) : b2fstati b2frates b2fgmtry
	rm -rf b2yi_gnuplot.exe.dir >& /dev/null ; mkdir b2yi_gnuplot.exe.dir ; cp $^ b2yi_gnuplot.exe.dir
	-[ -e b2fstate ] && cp b2fstate b2yi_gnuplot.exe.dir || echo > /dev/null
	-[ -e b2mn.dat ] && cp b2mn.dat b2yi_gnuplot.exe.dir || echo > /dev/null
	rm -f $(target_yi_gnuplot)
	cd b2yi_gnuplot.exe.dir ; ${TIME} ${B2OBJ}/b2yi_gnuplot.exe ; mv $(target_yi_gnuplot) .. ; rm -f $(notdir $^)
	-[ -e b2yi_gnuplot.exe.dir/b2fstate ] && rm b2yi_gnuplot.exe.dir/b2fstate || echo > /dev/null
	-[ -e b2yi_gnuplot.exe.dir/b2mn.dat ] && rm b2yi_gnuplot.exe.dir/b2mn.dat || echo > /dev/null
	-rmdir b2yi_gnuplot.exe.dir

$(target_ym) : b2ym.dat b2fmovie
	rm -rf b2ym.exe.dir >& /dev/null ; mkdir b2ym.exe.dir ; cp $^ b2ym.exe.dir
	rm -f $(target_ym)
	NCARG_GKS_OUTPUT=b2ym.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2ym.exe.dir ; ${TIME} ${B2OBJ}/b2ym.exe ; mv $(target_ym) .. ; rm -f $(notdir $^)
	-rmdir b2ym.exe.dir

$(target_yn) : b2yn.dat b2mn.dat b2ftrack b2frates b2fstate
	rm -rf b2yn.exe.dir >& /dev/null ; mkdir b2yn.exe.dir ; cp $^ b2yn.exe.dir
	rm -f $(target_yn)
	NCARG_GKS_OUTPUT=b2yn.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yn.exe.dir ; ${TIME} ${B2OBJ}/b2yn.exe ; mv $(target_yn) .. ; rm -f $(notdir $^)
	-rmdir b2yn.exe.dir

$(target_yp) : b2yp.dat b2mn.dat b2fgmtry b2fparam b2fstate b2frates
	rm -rf b2yp.exe.dir >& /dev/null ; mkdir b2yp.exe.dir ; cp $^ b2yp.exe.dir
	rm -f $(target_yp)
	NCARG_GKS_OUTPUT=b2yp.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yp.exe.dir ; ${TIME} ${B2OBJ}/b2yp.exe ; mv $(target_yp) .. ; rm -f $(notdir $^)
	-rmdir b2yp.exe.dir

$(target_yq) : b2yq.dat b2ftrace
	rm -rf b2yq.exe.dir >& /dev/null ; mkdir b2yq.exe.dir ; cp $^ b2yq.exe.dir
	rm -f $(target_yq)
	NCARG_GKS_OUTPUT=b2yq.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yq.exe.dir ; ${TIME} ${B2OBJ}/b2yq.exe ; mv $(target_yq) .. ; rm -f $(notdir $^)
	-rmdir b2yq.exe.dir

$(target_yr) : b2yr.dat b2frates b2fpardf b2fgmtry
	rm -rf b2yr.exe.dir >& /dev/null ; mkdir b2yr.exe.dir ; cp $^ b2yr.exe.dir
	rm -f $(target_yr)
	NCARG_GKS_OUTPUT=b2yr.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yr.exe.dir ; ${TIME} ${B2OBJ}/b2yr.exe ; mv $(target_yr) .. ; rm -f $(notdir $^)
	-rmdir b2yr.exe.dir

$(target_yt) : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf AMJUEL
	rm -rf b2yt.exe.dir >& /dev/null ; mkdir b2yt.exe.dir ; cp $^ b2yt.exe.dir
	rm -f $(target_yt)
ifndef STAND_ALONE
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../fort.21 ../fort.22 ../graphite_ext.dat ../mo_ext.dat . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../fort.44 ] && ln -s ../fort.44 . || echo > /dev/null ; [ -e ../fort.33 ] && ln -s ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && ln -s ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && ln -s ../fort.35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${TIME} ${B2OBJ}/b2yt.exe ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat fort.44 fort.75 ; mv *.2 ..
else
	cd b2yt.exe.dir ; ${TIME} ${B2OBJ}/b2yt.exe ; mv $(target_yt) .. ; rm -f $(notdir $^); mv *.2 ..
endif
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR fort.21 fort.22 graphite_ext.dat mo_ext.dat
	-[ -e b2yt.exe.dir/fort.33 ] && rm b2yt.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.34 ] && rm b2yt.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.35 ] && rm b2yt.exe.dir/fort.35 || echo > /dev/null
	-rmdir b2yt.exe.dir

dbx.b2yt : b2yt.dat b2fstate b2mn.dat b2ah.dat b2ai.dat b2ag.dat b2fgmtry b2frates b2fpardf AMJUEL
	rm -rf b2yt.exe.dir >& /dev/null ; mkdir b2yt.exe.dir ; cp $^ b2yt.exe.dir
	rm -f $(target_yt)
ifndef STAND_ALONE
	-cd b2yt.exe.dir ; ln -s ../HYDHEL ../METHANE ../SPUTER ../H2VIBR ../fort.21 ../fort.22 ../graphite_ext.dat ../mo_ext.dat . ; [ -e ../input.dat ] && ln -s ../input.dat . || echo > /dev/null ; [ -e ../fort.44 ] && ln -s ../fort.44 . || echo > /dev/null ; [ -e ../fort.33 ] && ln -s ../fort.33 . || echo > /dev/null ; [ -e ../fort.34 ] && ln -s ../fort.34 . || echo > /dev/null ; [ -e ../fort.35 ] && ln -s ../fort.35 . || echo > /dev/null
	cd b2yt.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2yt.exe ; mv $(target_yt) .. ; rm -f $(notdir $^) input.dat fort.44 fort.75 ; mv *.2 ..
else
	cd b2yt.exe.dir ; ${DBX} ${INC} ${DBGOBJ}/b2yt.exe ; mv $(target_yt) .. ; rm -f $(notdir $^); mv *.2 ..
endif
	-cd b2yt.exe.dir ; rm -f HYDHEL METHANE SPUTER H2VIBR fort.21 fort.22 graphite_ext.dat mo_ext.dat
	-[ -e b2yt.exe.dir/fort.33 ] && rm b2yt.exe.dir/fort.33 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.34 ] && rm b2yt.exe.dir/fort.34 || echo > /dev/null
	-[ -e b2yt.exe.dir/fort.35 ] && rm b2yt.exe.dir/fort.35 || echo > /dev/null
	-rmdir b2yt.exe.dir

$(target_ual) : b2fgmtry b2fstate
	rm -rf b2_ual_write.exe.dir ; mkdir b2_ual_write.exe.dir ; cp $^ b2_ual_write.exe.dir
	rm -f $(target_ual)
	cd b2_ual_write.exe.dir ; ${TIME} ${B2OBJ}/b2_ual_write.exe ; mv $(target_ual) .. ; rm -f $(notdir $^)
	-rmdir b2_ual_write.exe.dir

stra.dat :
	ln -s ${SOLPSTOP}/modules/B2.5/Database/stra.dat .

weis.dat :
	ln -s ${SOLPSTOP}/modules/B2.5/Database/weis.dat .

AMJUEL:
	ln -s ${SOLPSTOP}/modules/Eirene/Database/AMJUEL .

$(savefiles):
	touch $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.dummy_save.parameters:')
	$(eval savefiles := $(shell echo ${PLASMASTATE} | sed -e 's:plasmastate:b2.dummy_save.parameters:'))

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
	@echo "     prepares a b2fstate file from a plasmastate file"
	@echo "  ${target_rd} : "
	@echo "     prepares a b2fstate file from a saved MDSPLUS archive"
	@echo "  ${target_uf} : "
	@echo "     converts an unformatted b2fplasma file to a formatted version"
	@echo "  ${target_fu} : "
	@echo "     converts a formatted b2fplasma file to an unformatted version"
	@echo "  ${target_pl} : "
	@echo "     runs b2plot"
	@echo "  ${target_ts} : "
	@echo "     runs a dummy example of a post-processor"
	@echo "  ${target_yg} : "
	@echo "     displays geometry and magnetic field"
	@echo "  ${target_yh} : "
	@echo "     displays the physics parameters"
	@echo "  ${target_yi} : "
	@echo "     displays the plasma state"
	@echo "  ${target_yi_gnuplot} : "
	@echo "     displays the plasma state vis gnuplot"
	@echo "  ${target_ym} : "
	@echo "     displays a movie [not tested]"
	@echo "  ${target_yn} : "
	@echo "     displays the progress of the inner b2 iterations"
	@echo "  ${target_yp} : "
	@echo "     displays the plasma state"
	@echo "  ${target_yq} : "
	@echo "     displays a quick display of the evolution data"
	@echo "  ${target_yr} : "
	@echo "     displays the atomic physics rates"
	@echo "  ${target_yt} : "
	@echo "     transfers the plasma state to a mesh of a different size"
	@echo "  ${target_xd} : "
	@echo "     converts the plasma state to a SOLPS4.0 B2SXDR file [no longer functional]"
