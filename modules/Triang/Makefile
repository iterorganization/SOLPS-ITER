#  VERSION : 16.12.2004 23:59

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif
ifndef SOLPSTOP
  $(error SOLPSTOP not defined)
endif

MAKETAGS ?= ctags -e -f

# Extensions for OBJDIR if mpi and/or debug options are used
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
else
ifdef USE_MPI
EXT_MPI = .mpi
endif
endif
ifdef USE_OPENMP
EXT_OPENMP = .openmp
endif
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
DEFINES  += -DDBG -DTRACE
endif

SRCTRI   = ${PWD}
SRCDIR   = ${SRCTRI}/src
SRCLOCAL = ${SRCTRI}/local
B2SRC    = ${SOLPSTOP}/modules/B2.5/src
SRCEIR   = ${SOLPSTOP}/modules/Eirene/src

MAKES = ${SRCTRI}/Makefile 
# Include global SOLPS compiler settings
ifndef SOLPS_CPP
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
    MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  else
    $(warning ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} not found.)
  endif
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.common.${COMPILER}
    MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
  endif
else
  MAKES += ${SOLPSTOP}/Makefile ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
    MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
  endif
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER}.local
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
  include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
  MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
endif

# Directory where objectcode/binaries will be created
OBJDIR = ${SRCTRI}/builds/${HOST_NAME}.${COMPILER}${EXT_DEBUG}

INCLUDE =
LOCAL = no
ifneq ($(strip ${SRCLOCAL}), )
LOCAL = $(shell [ -d ${SRCLOCAL} ] && echo yes || echo no )
endif
ifeq ($(LOCAL),yes)
INCLUDE += -I${SRCLOCAL}
endif
INCLUDE += -I${OBJDIR} -I${B2SRC}/include.local -I${B2SRC}/include

ifndef NO_CMAKE
  CMAKE_DIR = CMakeFiles/EIRENE.dir
endif
ifneq ($(strip ${LD_GR}),)
 ifneq ($(strip ${LD_GKS}),)
  EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
  ifeq ($(shell [ -e ${EIROBJ}/${CMAKE_DIR}/plotting/plend.f.o ] && echo yes || echo no ), yes)
    GR_DIR = CMakeFiles/EIRENE.dir/plotting
    PLOT_DIR = plotting
  else
    GR_DIR = CMakeFiles/GR-DUMMY.dir/grsoft-dummy
    PLOT_DIR = plot_dummy
  endif
 else
  EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
  GR_DIR = CMakeFiles/GR-DUMMY.dir/grsoft-dummy
  PLOT_DIR = plot_dummy
 endif
else
  EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
  GR_DIR = CMakeFiles/GR-DUMMY.dir/grsoft-dummy
  PLOT_DIR = plot_dummy
endif

ifeq ($(LOCAL),yes)
TPATH = ${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src
ifeq ($(strip ${LD_GR}),)
VPATH = ${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src:${SRCEIR}/grsoft-dummy
GPATH = ${SRCEIR}/plot_dummy:${SRCEIR}/grsoft-dummy
GRDIR = ${SRCEIR}/plot_dummy
else
VPATH = ${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src
GPATH = ${SRCEIR}/plotting
GRDIR = ${SRCEIR}/plotting
endif
else
TPATH = ${SRCDIR}/modules:${SRCDIR}/src
ifeq ($(strip ${LD_GR}),)
VPATH = ${SRCDIR}/modules:${SRCDIR}/src:${SRCEIR}/grsoft-dummy
GPATH = ${SRCEIR}/plot_dummy:${SRCEIR}/grsoft-dummy
GRDIR = ${SRCEIR}/plot_dummy
else
VPATH = ${SRCDIR}/modules:${SRCDIR}/src
GPATH = ${SRCEIR}/plotting
GRDIR = ${SRCEIR}/plotting
endif
endif

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif
include ${SRCTRI}/config/compile
MAKES += ${SRCTRI}/config/compile ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/modules/Eirene/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES += ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
endif
ifeq ($(shell [ -e ${SOLPSTOP}/modules/Eirene/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
MAKES += ${SOLPSTOP}/modules/Eirene/config/config.${HOST_NAME}.${COMPILER}.local
endif


MODULES := ${patsubst ${SRCDIR}/modules/%.f,%,${shell echo ${SRCDIR}/modules/*.f}}
MODLOCASE:=$(shell echo $(MODULES)| tr A-Z a-z)
MODMODS := ${MODLOCASE:%=${OBJDIR}/%.${MOD}}
MODOBJS = ${MODULES:%=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}
EIROBJS = ${patsubst %.o,${OBJDIR}/%.o,anpsg.o anpsgl.o bitset.o broadsput.o cofact.o cone.o couple_specific.o ctcirc.o ctell.o ctqua.o deter3x3.o devcsf.o dlsbrr.o dopebe.o eirmod_balanced_strategy.o eirmod_braeir.o eirmod_braspoi.o eirmod_cadgeo.o eirmod_cai.o eirmod_calstr_buffered.o eirmod_ccona.o eirmod_ccoupl.o eirmod_cestim.o eirmod_cfplk.o eirmod_cgeom.o eirmod_cgrid.o eirmod_cinit.o eirmod_clast.o eirmod_clgin.o eirmod_clmsur.o eirmod_clogau.o eirmod_comprt.o eirmod_comsig.o eirmod_comsou.o eirmod_comspl.o eirmod_comusr.o eirmod_comxs.o eirmod_coutau.o eirmod_cpes.o eirmod_cpl3d.o eirmod_cplmsk.o eirmod_cplot.o eirmod_cpolyg.o eirmod_crand.o eirmod_crech.o eirmod_cref.o eirmod_csdvi.o eirmod_cspei.o eirmod_cspez.o eirmod_cstep.o eirmod_ctetra.o eirmod_ctext.o eirmod_ctrcei.o eirmod_ctrig.o eirmod_cupd.o eirmod_czt1.o eirmod_h1rnm.o eirmod_mpi.o eirmod_openmp.o eirmod_parmmod.o eirmod_plt2d.o eirmod_pl3d.o eirmod_ranf.o eirmod_reflec.o eirmod_refusr.o eirmod_sputer.o eirmod_statis.o eirmod_stcoor.o eirmod_tstchm.o eirmod_wneutrals.o ellipsoid.o ello.o ellu.o ellzyl.o exit_own.o fcosin.o fl2o.o fmaxwl.o fmu.o ftcre.o fthomp.o fzrtor.o fzrtra.o fzrtri.o geradx.o gerady.o gsp.o hypm.o hypp.o iexp10.o indtal.o invert.o ioflush_usr.o kegel.o kugel.o learca.o leer.o loctor.o masage.o masj1.o masj1r.o masj2r.o masj3.o masj4.o masj5.o masprm.o masr1.o masr2.o masr3.o masr4.o masr5.o masr6.o ma20a.o ncelln.o para1.o para2o.o para2u.o parebe.o pedist.o pedist_usr.o plane.o plend.o plgell.o plnxtb.o pltadd.o pltaxi.o pltin.o pltka.o pltki.o pltku.o pltlne.o pltmsk.o pltusr.o plt3d.o pl3q.o prllo.o pside.o rdtrim.o refdat.o rotadd.o rotate.o rs.o sarrus.o sccone.o schebe.o secang.o secqua.o setrot.o shnitt.o smach.o sort.o spline.o spoint.o sptusr.o tetra_schnitt.o torloc.o tqlrat.o tql2.o tred1.o tred2.o uppercase.o velocs.o vtkout.o xshadd.o yshadd.o zshadd.o zylind.o zylnd2.o zylpln.o}
EGROBJS = ${patsubst %.o,${OBJDIR}/%.o,graxs.o grdrw.o grend.o grjmp.o grnwpn.o grsclc.o grsclv.o grspts.o grstrt.o gr90dg.o}

MAINLIST = tria.o triageom.o triainq.o

DEST = ${filter-out $(MODOBJS),$(OBJS:%.o=$(OBJDIR)/%.o)}
EXCLUDELIST = $(MAINLIST:.o=\\.o)

ifeq ($(strip ${LD_GR}),)
$(warning Triang graphics are turned off because LD_GR is not defined.)
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/.nox
else
ifeq ($(strip ${LD_GKS}),)
$(warning Triang graphics are turned off because LD_GKS is not defined.)
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/.nox
else
ifeq ($(strip ${GLI_HOME}),)
$(warning Triang graphics may not work because GLI_HOME is not defined.)
endif
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/.x
endif
endif

mods: $(MODMODS)

ifneq ($(strip ${LD_GR}),)
ifneq ($(strip ${LD_GKS}),)
${OBJDIR}/tria ${OBJDIR}/.x: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.nox 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${LDLIBS} $(GKS) $(LDEXTRA) && touch ${OBJDIR}/.x

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${LDLIBS} ${GKS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${GKS}
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a
endif
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${EGROBJS} ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${EGROBJS} ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${EGROBJS} ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${EGROBJS} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a
endif

${OBJDIR}/libtria.a: ${ALLOBJS}
	${BLD} $@ ${ALLOBJS}
	ranlib $@

${OBJDIR}/libeir.a: ${EIROBJS}
	${BLD} $@ ${EIROBJS}
	ranlib $@

${OBJDIR}/anpsg.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/anpsg.f.o $@
else
	ln -sf ${EIROBJ}/anpsg.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/anpsgl.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/anpsgl.f.o $@
else
	ln -sf ${EIROBJ}/anpsgl.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/bitset.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/bitset.f.o $@
else
	ln -sf ${EIROBJ}/bitset.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/broadsput.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/broadcast/broadsput.f.o $@
else
	ln -sf ${EIROBJ}/broadsput.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/cofact.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/cofact.f.o $@
else
	ln -sf ${EIROBJ}/cofact.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/cone.o: ${OBJDIR}/sccone.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/cone.f.o $@
else
	ln -sf ${EIROBJ}/cone.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/couple_specific.o: ${OBJDIR}/eirmod_braspoi.${MOD} ${OBJDIR}/uppercase.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/interfaces/couple_SOLPS-ITER/couple_specific.f.o $@
else
	ln -sf ${EIROBJ}/couple_specific.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ctcirc.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ctcirc.f.o $@
else
	ln -sf ${EIROBJ}/ctcirc.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ctell.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ctell.f.o $@
else
	ln -sf ${EIROBJ}/ctell.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ctqua.o: ${OBJDIR}/ctcirc.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ctqua.f.o $@
else
	ln -sf ${EIROBJ}/ctqua.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/deter3x3.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/deter3x3.f.o $@
else
	ln -sf ${EIROBJ}/deter3x3.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/devcsf.o: ${OBJDIR}/rs.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/devcsf.f.o $@
else
	ln -sf ${EIROBJ}/devcsf.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/dlsbrr.o: ${OBJDIR}/ma20a.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/dlsbrr.f.o $@
else
	ln -sf ${EIROBJ}/dlsbrr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/dopebe.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/dopebe.f.o $@
else
	ln -sf ${EIROBJ}/dopebe.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_balanced_strategy.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_balanced_strategy.f90.o $@
else
	ln -sf ${EIROBJ}/eirmod_balanced_strategy.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_braeir.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/interfaces/couple_SOLPS-ITER/eirmod_braeir.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_braeir.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_braspoi.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/interfaces/couple_SOLPS-ITER/eirmod_braspoi.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_braspoi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cadgeo.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cadgeo.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cadgeo.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cai.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cai.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cai.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_calstr_buffered.o: ${OBJDIR}/eirmod_cestim.o ${OBJDIR}/eirmod_coutau.o ${OBJDIR}/eirmod_csdvi.o ${OBJDIR}/eirmod_cspez.o ${OBJDIR}/eirmod_cstep.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/broadcast/eirmod_calstr_buffered.f90.o $@
else
	ln -sf ${EIROBJ}/eirmod_calstr_buffered.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ccona.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_ccona.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ccona.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ccoupl.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/interfaces/couple_SOLPS-ITER/eirmod_ccoupl.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ccoupl.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cestim.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cestim.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cestim.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cfplk.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cfplk.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cfplk.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cgeom.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cgeom.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cgeom.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cgrid.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cgrid.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cgrid.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cinit.o: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cinit.F.o $@
else
	ln -sf ${EIROBJ}/eirmod_cinit.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_clast.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_clast.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_clast.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_clgin.o: ${OBJDIR}/bitset.o ${OBJDIR}/masprm.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_clgin.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_clgin.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_clmsur.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_clmsur.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_clmsur.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_clogau.o: ${OBJDIR}/eirmod_mpi.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_clogau.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_clogau.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comprt.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comprt.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comprt.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comsig.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comsig.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comsig.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comsou.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comsou.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comsou.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comspl.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comspl.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comspl.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comusr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comusr.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comusr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comxs.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comxs.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comxs.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_coutau.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_coutau.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_coutau.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cpes.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cpes.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cpes.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cpl3d.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cpl3d.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cpl3d.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cplmsk.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cplmsk.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cplmsk.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cplot.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cplot.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cplot.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cpolyg.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cpolyg.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cpolyg.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_crand.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_crand.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_crand.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_crech.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_crech.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_crech.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cref.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cref.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cref.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_csdvi.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_csdvi.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_csdvi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cspei.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cspei.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cspei.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cspez.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cspez.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cspez.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cstep.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cstep.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cstep.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ctetra.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_ctetra.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ctetra.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ctext.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_ctext.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ctext.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ctrcei.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_ctrcei.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ctrcei.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ctrig.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_ctrig.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ctrig.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cupd.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cupd.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cupd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_czt1.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_czt1.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_czt1.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_h1rnm.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/eirmod_h1rnm.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_h1rnm.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_mpi.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_mpi.F90.o $@
else
	ln -sf ${EIROBJ}/eirmod_mpi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_openmp.o: ${OBJDIR}/eirmod_reflec.${MOD} ${OBJDIR}/eirmod_sputer.${MOD} ${OBJDIR}/eirmod_statis.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_openmp.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_openmp.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_parmmod.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_parmmod.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_parmmod.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_plt2d.o: ${OBJDIR}/eirmod_cpl3d.${MOD} ${OBJDIR}/ftcre.o ${OBJDIR}/fzrtor.o ${OBJDIR}/fzrtra.o ${OBJDIR}/fzrtri.o ${OBJDIR}/learca.o ${OBJDIR}/masj1.o ${OBJDIR}/masj3.o ${OBJDIR}/masj4.o ${OBJDIR}/masj5.o ${OBJDIR}/masr1.o ${OBJDIR}/masr2.o ${OBJDIR}/masr5.o ${OBJDIR}/masr6.o ${OBJDIR}/ncelln.o ${OBJDIR}/plgell.o ${OBJDIR}/plnxtb.o ${OBJDIR}/pltadd.o ${OBJDIR}/pltlne.o ${OBJDIR}/pltmsk.o ${OBJDIR}/plt3d.o ${OBJDIR}/rotadd.o ${OBJDIR}/setrot.o ${OBJDIR}/tetra_schnitt.o ${OBJDIR}/xshadd.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/eirmod_plt2d.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_plt2d.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_pl3d.o: ${OBJDIR}/loctor.o ${OBJDIR}/torloc.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/eirmod_pl3d.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_pl3d.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_precision.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_precision.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_precision.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_ranf.o: ${OBJDIR}/eirmod_h1rnm.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/eirmod_ranf.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_ranf.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_reflec.o: ${OBJDIR}/eirmod_cref.${MOD} ${OBJDIR}/eirmod_czt1.${MOD} ${OBJDIR}/eirmod_plt2d.${MOD} ${OBJDIR}/eirmod_tstchm.${MOD} ${OBJDIR}/rdtrim.o ${OBJDIR}/refdat.o ${OBJDIR}/spline.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/surface-processes/eirmod_reflec.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_reflec.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_refusr.o: ${OBJDIR}/eirmod_ccoupl.o ${OBJDIR}/eirmod_wneutrals.o ${OBJDIR}/masr3.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/user-routines/user_iter/eirmod_refusr.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_refusr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_sputer.o: ${OBJDIR}/broadsput.o ${OBJDIR}/eirmod_cadgeo.${MOD} ${OBJDIR}/eirmod_clgin.${MOD} ${OBJDIR}/eirmod_comsig.${MOD} ${OBJDIR}/eirmod_crand.${MOD} ${OBJDIR}/eirmod_ctrcei.${MOD} ${OBJDIR}/eirmod_ctrig.${MOD} ${OBJDIR}/eirmod_ranf.${MOD} ${OBJDIR}/eirmod_refusr.${MOD} ${OBJDIR}/fcosin.o ${OBJDIR}/fthomp.o ${OBJDIR}/rotate.o ${OBJDIR}/velocs.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/surface-processes/eirmod_sputer.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_sputer.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_statis.o: ${OBJDIR}/eirmod_cspei.${MOD} ${OBJDIR}/indtal.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/scoring/eirmod_statis.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_statis.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_stcoor.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/eirmod_stcoor.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_stcoor.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_tstchm.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/eirmod_tstchm.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_tstchm.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_wneutrals.o: ${OBJDIR}/couple_specific.o ${OBJDIR}/eirmod_braeir.${MOD} ${OBJDIR}/eirmod_cgeom.${MOD} ${OBJDIR}/eirmod_cpolyg.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/interfaces/couple_SOLPS-ITER/eirmod_wneutrals.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_wneutrals.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ellipsoid.o: ${OBJDIR}/ctell.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ellipsoid.f.o $@
else
	ln -sf ${EIROBJ}/ellipsoid.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ello.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ello.f.o $@
else
	ln -sf ${EIROBJ}/ello.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ellu.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/ellu.f.o $@
else
	ln -sf ${EIROBJ}/ellu.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ellzyl.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/ellzyl.f.o $@
else
	ln -sf ${EIROBJ}/ellzyl.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/exit_own.o: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_openmp.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/ioflush_usr.o ${OBJDIR}/plend.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/exit_own.f.o $@
else
	ln -sf ${EIROBJ}/exit_own.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fcosin.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/sampling/fcosin.f.o $@
else
	ln -sf ${EIROBJ}/fcosin.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fl2o.o: ${OBJDIR}/dlsbrr.o ${OBJDIR}/devcsf.o ${OBJDIR}/dopebe.o ${OBJDIR}/ellzyl.o ${OBJDIR}/kegel.o ${OBJDIR}/kugel.o ${OBJDIR}/parebe.o ${OBJDIR}/schebe.o ${OBJDIR}/sort.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/fl2o.f.o $@
else
	ln -sf ${EIROBJ}/fl2o.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fmaxwl.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/sampling/fmaxwl.f.o $@
else
	ln -sf ${EIROBJ}/fmaxwl.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fmu.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/fmu.f.o $@
else
	ln -sf ${EIROBJ}/fmu.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ftcre.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/ftcre.f.o $@
else
	ln -sf ${EIROBJ}/ftcre.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fthomp.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/sampling/fthomp.f.o $@
else
	ln -sf ${EIROBJ}/fthomp.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fzrtor.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/fzrtor.f.o $@
else
	ln -sf ${EIROBJ}/fzrtor.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fzrtra.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/fzrtra.f.o $@
else
	ln -sf ${EIROBJ}/fzrtra.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/fzrtri.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/fzrtri.f.o $@
else
	ln -sf ${EIROBJ}/fzrtri.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/geradx.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/geradx.f.o $@
else
	ln -sf ${EIROBJ}/geradx.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/gerady.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/gerady.f.o $@
else
	ln -sf ${EIROBJ}/gerady.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/graxs.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/graxs.f.o $@
else
	ln -sf ${EIROBJ}/graxs.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grdrw.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grdrw.f.o $@
else
	ln -sf ${EIROBJ}/grdrw.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grend.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grend.f.o $@
else
	ln -sf ${EIROBJ}/grend.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grjmp.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grjmp.f.o $@
else
	ln -sf ${EIROBJ}/grjmp.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grnwpn.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grnwpn.f.o $@
else
	ln -sf ${EIROBJ}/grnwpn.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grsclc.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grsclc.f.o $@
else
	ln -sf ${EIROBJ}/grsclc.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grsclv.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grsclv.f.o $@
else
	ln -sf ${EIROBJ}/grsclv.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grspts.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grspts.f.o $@
else
	ln -sf ${EIROBJ}/grspts.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/grstrt.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/grstrt.f.o $@
else
	ln -sf ${EIROBJ}/grstrt.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/gr90dg.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${GR_DIR}/gr90dg.f.o $@
else
	ln -sf ${EIROBJ}/gr90dg.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/gsp.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/gsp.f.o $@
else
	ln -sf ${EIROBJ}/gsp.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/hypm.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/hypm.f.o $@
else
	ln -sf ${EIROBJ}/hypm.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/hypp.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/hypp.f.o $@
else
	ln -sf ${EIROBJ}/hypp.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/iexp10.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/iexp10.f.o $@
else
	ln -sf ${EIROBJ}/iexp10.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/indtal.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/indtal.f.o $@
else
	ln -sf ${EIROBJ}/indtal.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/invert.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/invert.f.o $@
else
	ln -sf ${EIROBJ}/invert.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ioflush_usr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/user-routines/user_iter/ioflush_usr.f.o $@
else
	ln -sf ${EIROBJ}/ioflush_usr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/kugel.o: ${OBJDIR}/cofact.o ${OBJDIR}/sarrus.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/kugel.f.o $@
else
	ln -sf ${EIROBJ}/kugel.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/kegel.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/kegel.f.o $@
else
	ln -sf ${EIROBJ}/kegel.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/learca.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/learca.f.o $@
else
	ln -sf ${EIROBJ}/learca.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/leer.o: ${OBJDIR}/eirmod_comprt.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/leer.f.o $@
else
	ln -sf ${EIROBJ}/leer.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/loctor.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/loctor.f.o $@
else
	ln -sf ${EIROBJ}/loctor.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masage.o: ${OBJDIR}/eirmod_comprt.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masage.f.o $@
else
	ln -sf ${EIROBJ}/masage.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj1r.o: ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj1r.f.o $@
else
	ln -sf ${EIROBJ}/masj1r.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj1.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj1.f.o $@
else
	ln -sf ${EIROBJ}/masj1.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj2r.o: ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj2r.f.o $@
else
	ln -sf ${EIROBJ}/masj2r.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj3.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj3.f.o $@
else
	ln -sf ${EIROBJ}/masj3.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj4.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj4.f.o $@
else
	ln -sf ${EIROBJ}/masj4.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masj5.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj5.f.o $@
else
	ln -sf ${EIROBJ}/masj5.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masprm.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masprm.f.o $@
else
	ln -sf ${EIROBJ}/masprm.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr1.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr1.f.o $@
else
	ln -sf ${EIROBJ}/masr1.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr2.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr2.f.o $@
else
	ln -sf ${EIROBJ}/masr2.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr3.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr3.f.o $@
else
	ln -sf ${EIROBJ}/masr3.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr4.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr4.f.o $@
else
	ln -sf ${EIROBJ}/masr4.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr5.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr5.f.o $@
else
	ln -sf ${EIROBJ}/masr5.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/masr6.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masr6.f.o $@
else
	ln -sf ${EIROBJ}/masr6.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ma20a.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/ma20a.f.o $@
else
	ln -sf ${EIROBJ}/ma20a.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/ncelln.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/ncelln.f.o $@
else
	ln -sf ${EIROBJ}/ncelln.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/para1.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/para1.f.o $@
else
	ln -sf ${EIROBJ}/para1.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/para2o.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/para2o.f.o $@
else
	ln -sf ${EIROBJ}/para2o.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/para2u.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/para2u.f.o $@
else
	ln -sf ${EIROBJ}/para2u.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/parebe.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/parebe.f.o $@
else
	ln -sf ${EIROBJ}/parebe.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pedist.o: ${OBJDIR}/eirmod_cai.${MOD} ${OBJDIR}/eirmod_ccona.${MOD} ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_comsou.${MOD} ${OBJDIR}/eirmod_comusr.${MOD} ${OBJDIR}/eirmod_coutau.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/eirmod_precision.${MOD} ${OBJDIR}/pedist_usr.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/startup-routines/pedist.f.o $@
else
	ln -sf ${EIROBJ}/pedist.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pedist_usr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/user-routines/user_iter/pedist_usr.f.o $@
else
	ln -sf ${EIROBJ}/pedist_usr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plane.o: ${OBJDIR}/pl3q.o ${OBJDIR}/spoint.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plane.f.o $@
else
	ln -sf ${EIROBJ}/plane.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plend.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plend.f.o $@
else
	ln -sf ${EIROBJ}/plend.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plgell.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plgell.f.o $@
else
	ln -sf ${EIROBJ}/plgell.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plnxtb.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plnxtb.f.o $@
else
	ln -sf ${EIROBJ}/plnxtb.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltadd.o: ${OBJDIR}/ello.o ${OBJDIR}/ellu.o ${OBJDIR}/fmu.o ${OBJDIR}/geradx.o ${OBJDIR}/gerady.o ${OBJDIR}/hypm.o ${OBJDIR}/hypp.o ${OBJDIR}/masr4.o ${OBJDIR}/para1.o ${OBJDIR}/para2o.o ${OBJDIR}/para2u.o ${OBJDIR}/pltin.o ${OBJDIR}/pside.o ${OBJDIR}/vtkout.o ${OBJDIR}/yshadd.o ${OBJDIR}/zshadd.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltadd.f.o $@
else
	ln -sf ${EIROBJ}/pltadd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltaxi.o: ${OBJDIR}/anpsg.o ${OBJDIR}/anpsgl.o ${OBJDIR}/iexp10.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltaxi.f.o $@
else
	ln -sf ${EIROBJ}/pltaxi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltin.o: ${OBJDIR}/pltka.o ${OBJDIR}/pltki.o ${OBJDIR}/pltku.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltin.f.o $@
else
	ln -sf ${EIROBJ}/pltin.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltka.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltka.f.o $@
else
	ln -sf ${EIROBJ}/pltka.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltki.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltki.f.o $@
else
	ln -sf ${EIROBJ}/pltki.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltku.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltku.f.o $@
else
	ln -sf ${EIROBJ}/pltku.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltlne.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltlne.f.o $@
else
	ln -sf ${EIROBJ}/pltlne.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltmsk.o: ${OBJDIR}/pltaxi.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pltmsk.f.o $@
else
	ln -sf ${EIROBJ}/pltmsk.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pltusr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/user-routines/user_iter/pltusr.f.o $@
else
	ln -sf ${EIROBJ}/pltusr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plt3d.o: ${OBJDIR}/cone.o ${OBJDIR}/ctqua.o ${OBJDIR}/ellipsoid.o ${OBJDIR}/fl2o.o ${OBJDIR}/plane.o ${OBJDIR}/pltusr.o ${OBJDIR}/prllo.o ${OBJDIR}/secqua.o ${OBJDIR}/zylind.o ${OBJDIR}/zylpln.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plt3d.f.o $@
else
	ln -sf ${EIROBJ}/plt3d.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pl3q.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pl3q.f.o $@
else
	ln -sf ${EIROBJ}/pl3q.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/prllo.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/prllo.f.o $@
else
	ln -sf ${EIROBJ}/prllo.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pside.o: ${OBJDIR}/gsp.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/pside.f.o $@
else
	ln -sf ${EIROBJ}/pside.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/rdtrim.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/file-handling/rdtrim.f.o $@
else
	ln -sf ${EIROBJ}/rdtrim.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/refdat.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/file-handling/refdat.f.o $@
else
	ln -sf ${EIROBJ}/refdat.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/rotadd.o: ${OBJDIR}/deter3x3.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/rotadd.f.o $@
else
	ln -sf ${EIROBJ}/rotadd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/rotate.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/rotate.f.o $@
else
	ln -sf ${EIROBJ}/rotate.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/rs.o: ${OBJDIR}/tqlrat.o ${OBJDIR}/tql2.o ${OBJDIR}/tred1.o ${OBJDIR}/tred2.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/rs.f.o $@
else
	ln -sf ${EIROBJ}/rs.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/sarrus.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/sarrus.f.o $@
else
	ln -sf ${EIROBJ}/sarrus.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/sccone.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/sccone.f.o $@
else
	ln -sf ${EIROBJ}/sccone.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/schebe.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/schebe.f.o $@
else
	ln -sf ${EIROBJ}/schebe.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/secang.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/secang.f.o $@
else
	ln -sf ${EIROBJ}/secang.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/secqua.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/secqua.f.o $@
else
	ln -sf ${EIROBJ}/secqua.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/setrot.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/setrot.f.o $@
else
	ln -sf ${EIROBJ}/setrot.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/shnitt.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/shnitt.f.o $@
else
	ln -sf ${EIROBJ}/shnitt.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/smach.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/smach.f.o $@
else
	ln -sf ${EIROBJ}/smach.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/sort.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/sort.f.o $@
else
	ln -sf ${EIROBJ}/sort.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/spline.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/spline.f.o $@
else
	ln -sf ${EIROBJ}/spline.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/spoint.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/spoint.f.o $@
else
	ln -sf ${EIROBJ}/spoint.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/sptusr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/user-routines/user_iter/sptusr.f.o $@
else
	ln -sf ${EIROBJ}/sptusr.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/tetra_schnitt.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/tetrahedra/tetra_schnitt.f.o $@
else
	ln -sf ${EIROBJ}/tetra_schnitt.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/torloc.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/torloc.f.o $@
else
	ln -sf ${EIROBJ}/torloc.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/tqlrat.o: ${OBJDIR}/smach.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/tqlrat.f.o $@
else
	ln -sf ${EIROBJ}/tqlrat.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/tql2.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/tql2.f.o $@
else
	ln -sf ${EIROBJ}/tql2.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/tred1.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/tred1.f.o $@
else
	ln -sf ${EIROBJ}/tred1.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/tred2.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/mathematics/tred2.f.o $@
else
	ln -sf ${EIROBJ}/tred2.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/uppercase.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/uppercase.f.o $@
else
	ln -sf ${EIROBJ}/uppercase.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/velocs.o: ${OBJDIR}/fmaxwl.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/particle-tracing/velocs.f.o $@
else
	ln -sf ${EIROBJ}/velocs.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/vtkout.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/vtkout.f.o $@
else
	ln -sf ${EIROBJ}/vtkout.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/xshadd.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/xshadd.f.o $@
else
	ln -sf ${EIROBJ}/xshadd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/yshadd.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/yshadd.f.o $@
else
	ln -sf ${EIROBJ}/yshadd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/zshadd.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/geometry/zshadd.f.o $@
else
	ln -sf ${EIROBJ}/zshadd.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/zylind.o: ${OBJDIR}/shnitt.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/zylind.f.o $@
else
	ln -sf ${EIROBJ}/zylind.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/zylnd2.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/zylnd2.f.o $@
else
	ln -sf ${EIROBJ}/zylnd2.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/zylpln.o: ${OBJDIR}/invert.o ${OBJDIR}/secang.o ${OBJDIR}/zylnd2.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/zylpln.f.o $@
else
	ln -sf ${EIROBJ}/zylpln.o ${OBJDIR}
endif
	@gtfl $@

ifneq (${MOD},o)
${OBJDIR}/eirmod_balanced_strategy.${MOD}:
	ln -sf ${EIROBJ}/eirmod_balanced_strategy.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_braeir.${MOD}:
	ln -sf ${EIROBJ}/eirmod_braeir.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_braspoi.${MOD}:
	ln -sf ${EIROBJ}/eirmod_braspoi.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cadgeo.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cadgeo.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cai.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cai.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_calstr_buffered.${MOD}: ${OBJDIR}/eirmod_cestim.${MOD} ${OBJDIR}/eirmod_coutau.${MOD} ${OBJDIR}/eirmod_csdvi.${MOD} ${OBJDIR}/eirmod_cspez.${MOD} ${OBJDIR}/eirmod_cstep.${MOD}
	ln -sf ${EIROBJ}/eirmod_calstr_buffered.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ccona.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ccona.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ccoupl.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ccoupl.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cestim.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cestim.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cfplk.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cfplk.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cgeom.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cgeom.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cgrid.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cgrid.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cinit.${MOD}: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
	ln -sf ${EIROBJ}/eirmod_cinit.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_clast.${MOD}:
	ln -sf ${EIROBJ}/eirmod_clast.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_clgin.${MOD}: ${OBJDIR}/bitset.o
	ln -sf ${EIROBJ}/eirmod_clgin.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_clmsur.${MOD}:
	ln -sf ${EIROBJ}/eirmod_clmsur.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_clogau.${MOD}: ${OBJDIR}/eirmod_mpi.${MOD}
	ln -sf ${EIROBJ}/eirmod_clogau.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comprt.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comprt.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comsig.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comsig.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comsou.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comsou.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comspl.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comspl.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comusr.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comusr.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comxs.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comxs.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_coutau.${MOD}:
	ln -sf ${EIROBJ}/eirmod_coutau.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cpes.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cpes.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cpl3d.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cpl3d.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cplmsk.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cplmsk.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cplot.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cplot.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cpolyg.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cpolyg.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_crand.${MOD}:
	ln -sf ${EIROBJ}/eirmod_crand.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_crech.${MOD}:
	ln -sf ${EIROBJ}/eirmod_crech.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cref.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cref.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_csdvi.${MOD}:
	ln -sf ${EIROBJ}/eirmod_csdvi.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cspei.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cspei.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cspez.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cspez.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ctetra.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ctetra.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ctext.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ctext.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ctrcei.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ctrcei.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ctrig.${MOD}:
	ln -sf ${EIROBJ}/eirmod_ctrig.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cupd.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cupd.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_czt1.${MOD}:
	ln -sf ${EIROBJ}/eirmod_czt1.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_h1rnm.${MOD}:
	ln -sf ${EIROBJ}/eirmod_h1rnm.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_mpi.${MOD}:
	ln -sf ${EIROBJ}/eirmod_mpi.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_openmp.${MOD}: ${OBJDIR}/eirmod_reflec.${MOD} ${OBJDIR}/eirmod_sputer.${MOD} ${OBJDIR}/eirmod_statis.${MOD}
	ln -sf ${EIROBJ}/eirmod_openmp.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_parmmod.${MOD}:
	ln -sf ${EIROBJ}/eirmod_parmmod.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_plt2d.${MOD}: ${OBJDIR}/eirmod_cpl3d.${MOD} ${OBJDIR}/ftcre.o ${OBJDIR}/fzrtra.o ${OBJDIR}/fzrtri.o ${OBJDIR}/fzrtor.o ${OBJDIR}/learca.o ${OBJDIR}/masj1.o ${OBJDIR}/masj3.o ${OBJDIR}/masj4.o ${OBJDIR}/masj5.o ${OBJDIR}/masr1.o ${OBJDIR}/masr2.o ${OBJDIR}/masr5.o ${OBJDIR}/masr6.o ${OBJDIR}/ncelln.o ${OBJDIR}/plgell.o ${OBJDIR}/plnxtb.o ${OBJDIR}/pltadd.o ${OBJDIR}/pltlne.o ${OBJDIR}/pltmsk.o ${OBJDIR}/plt3d.o ${OBJDIR}/rotadd.o ${OBJDIR}/setrot.o ${OBJDIR}/tetra_schnitt.o ${OBJDIR}/xshadd.o
	ln -sf ${EIROBJ}/eirmod_plt2d.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_pl3d.${MOD}: ${OBJDIR}/loctor.o ${OBJDIR}/torloc.o
	ln -sf ${EIROBJ}/eirmod_pl3d.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_precision.${MOD}:
	ln -sf ${EIROBJ}/eirmod_precision.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ranf.${MOD}: ${OBJDIR}/eirmod_h1rnm.${MOD}
	ln -sf ${EIROBJ}/eirmod_ranf.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_reflec.${MOD}: ${OBJDIR}/eirmod_cref.${MOD} ${OBJDIR}/eirmod_czt1.${MOD} ${OBJDIR}/eirmod_plt2d.${MOD} ${OBJDIR}/eirmod_tstchm.${MOD} ${OBJDIR}/rdtrim.o ${OBJDIR}/refdat.o ${OBJDIR}/spline.o
	ln -sf ${EIROBJ}/eirmod_reflec.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_refusr.${MOD}: ${OBJDIR}/eirmod_ccoupl.${MOD} ${OBJDIR}/eirmod_wneutrals.${MOD} ${OBJDIR}/masr3.o
	ln -sf ${EIROBJ}/eirmod_refusr.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_sputer.${MOD}: ${OBJDIR}/broadsput.o ${OBJDIR}/eirmod_clgin.${MOD} ${OBJDIR}/eirmod_comsig.${MOD} ${OBJDIR}/eirmod_crand.${MOD} ${OBJDIR}/eirmod_ctrcei.${MOD} ${OBJDIR}/eirmod_ctrig.${MOD} ${OBJDIR}/eirmod_ranf.${MOD} ${OBJDIR}/eirmod_refusr.${MOD} ${OBJDIR}/fcosin.o ${OBJDIR}/fthomp.o ${OBJDIR}/rotate.o ${OBJDIR}/velocs.o
	ln -sf ${EIROBJ}/eirmod_sputer.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_statis.${MOD}: ${OBJDIR}/eirmod_cspei.${MOD} ${OBJDIR}/indtal.o
	ln -sf ${EIROBJ}/eirmod_statis.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_stcoor.${MOD}:
	ln -sf ${EIROBJ}/eirmod_stcoor.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_tstchm.${MOD}:
	ln -sf ${EIROBJ}/eirmod_tstchm.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_wneutrals.${MOD}: ${OBJDIR}/couple_specific.o ${OBJDIR}/eirmod_braeir.${MOD} ${OBJDIR}/eirmod_cgeom.${MOD} ${OBJDIR}/eirmod_cpolyg.${MOD}
	ln -sf ${EIROBJ}/eirmod_wneutrals.${MOD} ${OBJDIR}
	@gtfl $@
endif

clean:
	rm -rf ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies
ifneq (${MOD},o)
	rm -rf ${OBJDIR}/*.${MOD}
endif

depend: ${OBJS:.o=.f} ${OBJF:.o=.F} ${OBJS90:.o=.f90} ${OBJF90:.o=.F90} ${MAINLIST:.o=.f}
	@`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies
	@echo '# 1' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' >> ${OBJDIR}/dependencies
	@echo '# 2' >> ${OBJDIR}/dependencies
endif
ifeq ($(LOCAL),yes)
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	@echo '# 4b' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 5b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 6b' >> ${OBJDIR}/dependencies
endif
else
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	@echo '# 4b' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 5b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF] ${SRCEIR}/modules/*.[fF]90 ${GRDIR}/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 6b' >> ${OBJDIR}/dependencies
endif
endif

update:
	cd $(SOLPSTOP); gmake update

listobj:
	@rm -f ${OBJDIR}/LISTOBJ ; touch ${OBJDIR}/LISTOBJ ; l="OBJS =" ; \
	for d in `echo "$(TPATH)" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.f)`"; \
	done; \
	E="-e 's/ \*\.f//g' -e 's/\.f/\.o/g'" ; for f in $(EXCLUDELIST); do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${OBJDIR}/LISTOBJ

tags:
ifeq ($(LOCAL),yes)
	rm -f ${SRCTRI}/TAGS ; ${MAKETAGS} ${SRCTRI}/TAGS ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.f || touch ${SRCTRI}/TAGS
else
	rm -f ${SRCTRI}/TAGS ; ${MAKETAGS} ${SRCTRI}/TAGS ${SRCDIR}/*/*.f || touch ${SCRTRI}/TAGS
endif

${OBJDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies: 
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies

${SRCTRI}/TAGS: tags

echo:
	@echo CPP=${CPP}
	@echo LOCAL=${LOCAL}
	@echo VPATH=${VPATH}
	@echo ALLOBJS=${ALLOBJS}
	@echo EIROBJS=${EIROBJS}
	@echo EGROBJS=${EGROBJS}
#	@echo OBJS=${OBJS}
#	@echo OBJF=${OBJF}
	@echo DEST=${DEST}
	@echo MODULES=${MODULES}
#	@echo MODLOCASE=${MODLOCASE}
	@echo MODMODS=${MODMODS}
#	@echo MODOBJS=${MODOBJS}
#	@echo $(filter-out ${MODOBJS},${ALLOBJS})
	@echo MAINLIST=${MAINLIST}
	@echo EXCLUDELIST=${EXCLUDELIST}
#	@echo OBJDEST=${OBJDEST}
