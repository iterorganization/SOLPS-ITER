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
EIRDIR   = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}

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
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
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
EIROBJ = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_DEBUG}

INCLUDE =
LOCAL = no
ifneq ($(strip ${SRCLOCAL}), )
LOCAL = $(shell [ -d ${SRCLOCAL} ] && echo yes || echo no )
endif
ifeq ($(LOCAL),yes)
INCLUDE += -I${SRCLOCAL}
endif
INCLUDE += -I${OBJDIR} -I${B2SRC}/include.local -I${B2SRC}/include

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
EIROBJS = ${patsubst %.o,${OBJDIR}/%.o,eirmod_balanced_strategy.o eirmod_cai.o eirmod_calstr_buffered.o eirmod_ccona.o eirmod_cestim.o eirmod_cinit.o eirmod_comprt.o eirmod_comsou.o eirmod_comusr.o eirmod_coutau.o eirmod_cpes.o eirmod_csdvi.o eirmod_cspez.o eirmod_cstep.o eirmod_mpi.o eirmod_parmmod.o exit_own.o leer.o masage.o masj1r.o masj2r.o pedist.o plend.o}
EGROBJS = ${patsubst %.o,${OBJDIR}/%.o,graxs.o grdrw.o grend.o grjmp.o grnwpn.o grsclc.o grsclv.o grspts.o grstrt.o gr90dg.o}

MAINLIST = tria.o triageom.o triainq.o triainp.o

DEST = ${filter-out $(MODOBJS),$(OBJS:%.o=$(OBJDIR)/%.o)}
EXCLUDELIST = $(MAINLIST:.o=\\.o)

ifeq ($(strip ${LD_GR}),)
$(warning Triang graphics are turned off because LD_GR is not defined.)
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/triainp ${OBJDIR}/.nox
else
ifeq ($(strip ${LD_GKS}),)
$(warning Triang graphics are turned off because LD_GKS is not defined.)
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/triainp ${OBJDIR}/.nox
else
ifeq ($(strip ${GLI_HOME}),)
$(warning Triang graphics may not work because GLI_HOME is not defined.)
endif
all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/triainp ${OBJDIR}/.x
endif
endif

mods: $(MODMODS)

ifneq ($(strip ${LD_GR}),)
ifneq ($(strip ${LD_GKS}),)
${OBJDIR}/tria ${OBJDIR}/.x: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.nox 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${LDLIBS} $(GKS) $(LDEXTRA) && touch ${OBJDIR}/.x

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${LDLIBS} ${GKS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${GKS}

${OBJDIR}/triainp: ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainp ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${GKS}

else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a

${OBJDIR}/triainp: ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainp ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a

endif
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${EGROBJS} ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${EGROBJS} ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${EGROBJS} ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${EGROBJS} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a

${OBJDIR}/triainp: ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainp ${OBJDIR}/triainp.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a

endif

${OBJDIR}/libtria.a: ${ALLOBJS}
	${BLD} $@ ${ALLOBJS}
	ranlib $@

${OBJDIR}/libeir.a: ${EIROBJS}
	${BLD} $@ ${EIROBJS}
	ranlib $@

${OBJDIR}/ioflush.o:
	ln -sf ${EIROBJ}/ioflush.o ${OBJDIR}

${OBJDIR}/eirmod_balanced_strategy.o:
	ln -sf ${EIROBJ}/eirmod_balanced_strategy.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cai.o:
	ln -sf ${EIROBJ}/eirmod_cai.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_calstr_buffered.o: ${OBJDIR}/eirmod_cestim.o ${OBJDIR}/eirmod_coutau.o ${OBJDIR}/eirmod_csdvi.o ${OBJDIR}/eirmod_cspez.o ${OBJDIR}/eirmod_cstep.o
	ln -sf ${EIROBJ}/eirmod_calstr_buffered.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_ccona.o:
	ln -sf ${EIROBJ}/eirmod_ccona.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cestim.o:
	ln -sf ${EIROBJ}/eirmod_cestim.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cinit.o:
	ln -sf ${EIROBJ}/eirmod_cinit.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comprt.o:
	ln -sf ${EIROBJ}/eirmod_comprt.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comsou.o:
	ln -sf ${EIROBJ}/eirmod_comsou.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_comusr.o:
	ln -sf ${EIROBJ}/eirmod_comusr.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_coutau.o:
	ln -sf ${EIROBJ}/eirmod_coutau.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cpes.o:
	ln -sf ${EIROBJ}/eirmod_cpes.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_csdvi.o:
	ln -sf ${EIROBJ}/eirmod_csdvi.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cspez.o:
	ln -sf ${EIROBJ}/eirmod_cspez.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_cstep.o:
	ln -sf ${EIROBJ}/eirmod_cstep.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_mpi.o:
	ln -sf ${EIROBJ}/eirmod_mpi.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_parmmod.o:
	ln -sf ${EIROBJ}/eirmod_parmmod.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/eirmod_precision.o:
	ln -sf ${EIROBJ}/eirmod_precision.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/exit_own.o: ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_comprt.${MOD}
	ln -sf ${EIROBJ}/exit_own.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/graxs.o:
	ln -sf ${EIROBJ}/graxs.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grdrw.o:
	ln -sf ${EIROBJ}/grdrw.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grend.o:
	ln -sf ${EIROBJ}/grend.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grjmp.o:
	ln -sf ${EIROBJ}/grjmp.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grnwpn.o:
	ln -sf ${EIROBJ}/grnwpn.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grsclc.o:
	ln -sf ${EIROBJ}/grsclc.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grsclv.o:
	ln -sf ${EIROBJ}/grsclv.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grspts.o:
	ln -sf ${EIROBJ}/grspts.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/grstrt.o:
	ln -sf ${EIROBJ}/grstrt.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/gr90dg.o:
	ln -sf ${EIROBJ}/gr90dg.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/leer.o: ${OBJDIR}/eirmod_comprt.${MOD}
	ln -sf ${EIROBJ}/leer.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/masage.o: ${OBJDIR}/eirmod_comprt.${MOD}
	ln -sf ${EIROBJ}/masage.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/masj1r.o: ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
	ln -sf ${EIROBJ}/masj1r.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/masj2r.o: ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
	ln -sf ${EIROBJ}/masj2r.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/pedist.o: ${OBJDIR}/eirmod_cai.${MOD} ${OBJDIR}/eirmod_ccona.${MOD} ${OBJDIR}/eirmod_comprt.${MOD} ${OBJDIR}/eirmod_comsou.${MOD} ${OBJDIR}/eirmod_comusr.${MOD} ${OBJDIR}/eirmod_coutau.${MOD} ${OBJDIR}/eirmod_cpes.${MOD} ${OBJDIR}/eirmod_mpi.${MOD} ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/eirmod_precision.${MOD}
	ln -sf ${EIROBJ}/pedist.o ${OBJDIR}
	@gtfl $@

${OBJDIR}/plend.o:
	ln -sf ${EIROBJ}/plend.o ${OBJDIR}
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

${OBJDIR}/eirmod_cinit.${MOD}:
	ln -sf ${EIROBJ}/eirmod_cinit.${MOD} ${OBJDIR}
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
	rm -rf ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/libtria.a ${OBJDIR}/libeir.a ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/triainp ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies
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
