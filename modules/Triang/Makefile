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

ifneq ($(strip ${LD_GR}),)
ifneq ($(strip ${LD_GKS}),)
EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/standalone.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
PLOT_DIR = plotting
else
EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
PLOT_DIR = plot_dummy
endif
else
EIROBJ   = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
PLOT_DIR = plot_dummy
endif
ifndef NO_CMAKE
CMAKE_DIR = CMakeFiles/EIRENE.dir
ifneq ($(strip ${LD_GR}),)
ifneq ($(strip ${LD_GKS}),)
GR_DIR = CMakeFiles/EIRENE.dir/plotting
else
GR_DIR = CMakeFiles/GR-DUMMY.dir/grsoft-dummy
endif
else
GR_DIR = CMakeFiles/GR-DUMMY.dir/grsoft-dummy
endif
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
EIROBJS = ${patsubst %.o,${OBJDIR}/%.o,eirmod_balanced_strategy.o eirmod_cai.o eirmod_calstr_buffered.o eirmod_ccona.o eirmod_cestim.o eirmod_cinit.o eirmod_clogau.o eirmod_comprt.o eirmod_comsou.o eirmod_comusr.o eirmod_coutau.o eirmod_cpes.o eirmod_csdvi.o eirmod_cspez.o eirmod_cstep.o eirmod_mpi.o eirmod_parmmod.o exit_own.o leer.o masage.o masj1r.o masj2r.o pedist.o plend.o}
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

${OBJDIR}/eirmod_balanced_strategy.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_balanced_strategy.f90.o $@
else
	ln -sf ${EIROBJ}/eirmod_balanced_strategy.o ${OBJDIR}
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

${OBJDIR}/eirmod_cestim.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cestim.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_cestim.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cinit.o: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cinit.F.o $@
else
	ln -sf ${EIROBJ}/eirmod_cinit.o ${OBJDIR}
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

${OBJDIR}/eirmod_comsou.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comsou.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comsou.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_comusr.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_comusr.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_comusr.o ${OBJDIR}
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
	ln -sf ${EIROBJ}eirmod_cpes.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_csdvi.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_csdvi.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_csdvi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cspez.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cspez.f.o $@
else
	ln -sf ${EIROBJ}eirmod_cspez.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_cstep.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_cstep.f.o $@
else
	ln -sf ${EIROBJ}eirmod_cstep.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_mpi.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_mpi.F90.o $@
else
	ln -sf ${EIROBJ}eirmod_mpi.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_parmmod.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_parmmod.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_parmmod.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/eirmod_precision.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/modules/eirmod_precision.f.o $@
else
	ln -sf ${EIROBJ}/eirmod_precision.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/exit_own.o: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/plend.o
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/exit_own.f.o $@
else
	ln -sf ${EIROBJ}/exit_own.o ${OBJDIR}
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

${OBJDIR}/leer.o: ${OBJDIR}/eirmod_comprt.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/leer.f.o $@
else
	ln -sf ${EIROBJ}/leer.o ${OBJDIR}
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

${OBJDIR}/masj2r.o: ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/assistant/masj2r.f.o $@
else
	ln -sf ${EIROBJ}/masj2r.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/pedist.o: ${OBJDIR}/eirmod_cai.${MOD} ${OBJDIR}/eirmod_ccona.${MOD} ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_comsou.${MOD} ${OBJDIR}/eirmod_comusr.${MOD} ${OBJDIR}/eirmod_coutau.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/startup-routines/pedist.f.o $@
else
	ln -sf ${EIROBJ}/pedist.o ${OBJDIR}
endif
	@gtfl $@

${OBJDIR}/plend.o:
ifndef NO_CMAKE
	ln -sf ${EIROBJ}/${CMAKE_DIR}/${PLOT_DIR}/plend.f.o $@
else
	ln -sf ${EIROBJ}/plend.o ${OBJDIR}
endif
	@gtfl $@

ifneq (${MOD},o)
${OBJDIR}/eirmod_balanced_strategy.${MOD}:
	ln -sf ${EIROBJ}/eirmod_balanced_strategy.${MOD} ${OBJDIR}
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

${OBJDIR}/eirmod_cestim.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cestim.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cinit.${MOD}: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
	ln -sf ${EIROBJ}/eirmod_cinit.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_clogau.${MOD}: ${OBJDIR}/eirmod_mpi.${MOD}
	ln -sf ${EIROBJ}/eirmod_clogau.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comprt.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comprt.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comsou.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comsou.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comusr.${MOD}:
	ln -sf ${EIROBJ}/eirmod_comusr.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_coutau.${MOD}:
	ln -sf ${EIROBJ}/eirmod_coutau.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cpes.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cpes.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_csdvi.${MOD}:
	ln -sf ${EIROBJ}/eirmod_csdvi.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cspez.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cspez.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cstep.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cstep.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_mpi.${MOD}:
	ln -sf ${EIROBJ}/eirmod_mpi.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_parmmod.${MOD}:
	ln -sf ${EIROBJ}/eirmod_parmmod.${MOD} ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_precision.${MOD}:
	ln -sf ${EIROBJ}/eirmod_precision.${MOD} ${OBJDIR}
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
