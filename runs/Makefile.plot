# GNU Makefile for B2plot and other postprocessors; part 2--execution.
# Please see the general comments in the companion Makefile, part 1,
# which controls compile and load.
#-----------------------------------------------------------------------
# Variables.

SHELL = /bin/sh
TIME = time
nil =
ifeq (${OBJECTCODE},linux_nag_f95.debug)
DBX = totalview
INC = 
else
ifeq (${OBJECTCODE},linux.Fujitsu.debug)
DBX = totalview
INC =
else 
ifeq (${OBJECTCODE},linux_pgf90.debug)
DBX = gdb
INC = 
else
DBX = dbx
ifdef USE_EIRENE
INC = -I ${SOLPSTOP}/src/Braams/b2/base/${OBJECTCODE} -I ${SOLPSTOP}/src/Eirene/${OBJECTCODE}
else
INC = -I ${SOLPSTOP}/src/Braams/b2/base/${OBJECTCODE}
endif
endif
endif
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

scandir := $(shell cd .. ; pwd)
projdir := $(shell cd ../.. ; pwd)
baserundir := $(shell cd $(scandir)/baserun ; pwd)

echo:
	@echo scandir=${scandir} projdir=${projdir} baserundir=${baserundir}

#-----------------------------------------------------------------------
# Directives.

vpath %.dat .:$(baserundir)
vpath b2md.dat .:$(baserundir):$(SOLPSTOP)/data.local/mdsplus:$(SOLPSTOP)/data/mdsplus
vpath b2fgmtry .:$(baserundir)
vpath b2fpardf .:$(baserundir)
vpath b2fstati .:$(baserundir)
vpath b2frates .:$(baserundir)

#-----------------------------------------------------------------------
# Rules.

default : b2pl.prt
all : $(prints)
prt : $(prints)

.PHONY : default all prt clean realclean testvars
.PRECIOUS : $(prints)
.SUFFIXES : $(nil)

$(target_uf) : b2fgmtry b2fparam b2fstate b2fplasma
	rm -rf b2uf.exe.dir ; mkdir b2uf.exe.dir ; cp $^ b2uf.exe.dir
	rm -f $(target_uf)
	cd b2uf.exe.dir ; ${TIME} b2uf.exe ; mv $(target_uf) b2fplasmf .. ; rm -f $(notdir $^) .quit
	-rmdir b2uf.exe.dir

$(target_fu) : b2fgmtry b2fparam b2fstate b2fplasmf
	rm -rf b2fu.exe.dir ; mkdir b2fu.exe.dir ; cp $^ b2fu.exe.dir
	rm -f $(target_fu)
	cd b2fu.exe.dir ; ${TIME} b2fu.exe ; mv $(target_fu) b2fplasma .. ; rm -f $(notdir $^) .quit
	-rmdir b2fu.exe.dir

$(target_pl) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates
	rm -rf b2pl.exe.dir ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
ifdef USE_EIRENE
	-cp fort.44 input.dat b2pl.exe.dir/
	-cd b2pl.exe.dir ; ln -s ../fort.33 ../fort.34 ../fort.35 .
endif
ifeq (${NCAR_VERSION},3)
	rm -f $(target_pl) gmeta
	cd b2pl.exe.dir ; ${TIME} b2pl.exe ; mv -f gmeta .. ; rm -f $(target_pl) $(notdir $^) .quit
else
	rm -f $(target_pl) b2plot.ps
	cd b2pl.exe.dir ; ${TIME} b2pl.exe ; mv -f b2plot.ps .. ; rm -f $(target_pl) $(notdir $^) .quit
endif
ifdef USE_EIRENE
	-rm b2pl.exe.dir/fort.44 b2pl.exe.dir/input.dat b2pl.exe.dir/fort.3[3-5]
endif
	-rmdir b2pl.exe.dir

$(target_pl.dbx) : b2mn.dat b2fgmtry b2fparam b2fstate b2fplasma b2frates
	rm -rf b2pl.exe.dir ; mkdir b2pl.exe.dir ; cp $^ b2pl.exe.dir
ifdef USE_EIRENE
	-cp fort.44 input.dat b2pl.exe.dir/
	-cd b2pl.exe.dir ; ln -s ../fort.33 ../fort.34 ../fort.35 .
endif
ifeq (${NCAR_VERSION},3)
	rm -f $(target_pl) gmeta
	cd b2pl.exe.dir ; ${DBX} ${INC} ${SOLPSTOP}/base/b2/${OBJECTCODE}/b2pl.exe ; mv -f gmeta .. ; rm -f $(target_pl) $(notdir $^) .quit
else
	rm -f $(target_pl) b2plot.ps
	cd b2pl.exe.dir ; ${DBX} ${INC} ${SOLPSTOP}/base/b2/${OBJECTCODE}/b2pl.exe ; mv -f b2plot.ps .. ; rm -f $(target_pl) $(notdir $^) .quit
endif
ifdef USE_EIRENE
	-rm b2pl.exe.dir/fort.44 b2pl.exe.dir/input.dat b2pl.exe.dir/fort.3[3-5]
endif
	-rmdir b2pl.exe.dir

$(target_md) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat # b2fplasma b2time.nc 
	rm -rf b2md.exe.dir ; mkdir b2md.exe.dir ; cp $^ ds* b2md.exe.dir
ifdef USE_EIRENE
	-cp fort.44 input.dat b2md.exe.dir/
	-cd b2md.exe.dir ; ln -s ../fort.33 ../fort.34 ../fort.35 .
endif
	rm -f $(target_md)
	cd b2md.exe.dir ; ${SOLPSTOP}/bin/common/mds_id | ${TIME} b2md.exe ; mv $(target_md) .. ; rm -f $(notdir $^) .quit ds*
ifdef USE_EIRENE
	-rm b2md.exe.dir/fort.44 b2md.exe.dir/input.dat b2md.exe.dir/fort.3[3-5]
endif
	-rmdir b2md.exe.dir

$(target_md.dbx) : b2mn.dat b2fgmtry b2fparam b2frates b2fstati b2fstate mesh.extra b2md.dat # b2fplasma b2time.nc 
	rm -rf b2md.exe.dir ; mkdir b2md.exe.dir ; cp $^ ds* b2md.exe.dir
ifdef USE_EIRENE
	-cp fort.44 input.dat b2md.exe.dir/
	-cd b2md.exe.dir ; ln -s ../fort.33 ../fort.34 ../fort.35 .
endif
	rm -f $(target_md)
	cd b2md.exe.dir ; ${SOLPSTOP}/bin/common/mds_id | ${DBX} ${INC} ${SOLPSTOP}/base/b2/${OBJECTCODE}/b2md.exe ; mv $(target_md) .. ; rm -f $(notdir $^) .quit ds*
ifdef USE_EIRENE
	-rm b2md.exe.dir/fort.44 b2md.exe.dir/input.dat b2md.exe.dir/fort.3[3-5]
endif
	-rmdir b2md.exe.dir

$(target_rd) : shotnumber.history
	rm -rf b2rd.exe.dir ; mkdir b2rd.exe.dir ; cp $^ b2rd.exe.dir
	rm -f $(target_rd)
	cd b2rd.exe.dir ; ${TIME} b2rd.exe ; mv $(target_rd) .. ; rm -f $(notdir $^)
	-rmdir b2rd.exe.dir

$(target_yi) : b2yi.dat b2mn.dat b2fstate b2frates b2fgmtry
	rm -rf b2yi.exe.dir ; mkdir b2yi.exe.dir ; cp $^ b2yi.exe.dir
	rm -f $(target_yi)
	NCARG_GKS_OUTPUT=b2yi.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yi.exe.dir ; ${TIME} b2yi.exe ; mv $(target_yi) .. ; rm -f $(notdir $^)
	-rmdir b2yi.exe.dir

$(target_yi_gnuplot) : b2mn.dat b2fstate b2frates b2fgmtry
	rm -rf b2yi_gnuplot.exe.dir ; mkdir b2yi_gnuplot.exe.dir ; cp $^ b2yi_gnuplot.exe.dir
	rm -f $(target_yi_gnuplot)
	cd b2yi_gnuplot.exe.dir ; ${TIME} b2yi_gnuplot.exe ; mv $(target_yi_gnuplot) .. ; rm -f $(notdir $^)
	-rmdir b2yi_gnuplot.exe.dir

$(target_yn) : b2yn.dat b2mn.dat b2ftrack b2frates b2fstate
	rm -rf b2yn.exe.dir ; mkdir b2yn.exe.dir ; cp $^ b2yn.exe.dir
	rm -f $(target_yn)
	NCARG_GKS_OUTPUT=b2yn.plt ; export NCARG_GKS_OUTPUT ;\
	cd b2yn.exe.dir ; ${TIME} b2yn.exe ; mv $(target_yn) .. ; rm -f $(notdir $^)
	-rmdir b2yn.exe.dir

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
