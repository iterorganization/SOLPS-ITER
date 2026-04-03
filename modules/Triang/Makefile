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
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif
endif
ifdef SOLPS_OPENMP
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

ifeq ($(LOCAL),yes)
TPATH = ${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src:${SRCDIR}/src_eirene
else
TPATH = ${SRCDIR}/modules:${SRCDIR}/src:${SRCDIR}/src_eirene
endif
ifeq ($(strip ${LD_GR}),)
VPATH = ${TPATH}:${SRCDIR}/gr-dummy
else
VPATH = ${TPATH}
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
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o} ${OBJF:%.o=${OBJDIR}/%.o} ${OBJS90:%.o=${OBJDIR}/%.o} ${OBJF90:%.o=${OBJDIR}/%.o}
EGROBJS = ${GROBJS:%.o=${OBJDIR}/%.o}

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

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} ${GKS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${MAKES} ${OBJDIR}/.x
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${GKS}
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a
endif
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${EGROBJS} ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${EGROBJS} ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${EGROBJS} ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${EGROBJS} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${MAKES} ${OBJDIR}/.nox
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a
endif

${OBJDIR}/libtria.a: ${ALLOBJS}
	${BLD} $@ ${ALLOBJS}
	ranlib $@

clean:
	rm -rf ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/libtria.a ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies
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
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.[fF] | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/modules/*.[fF] ${SRCDIR}/src_eirene/eirmod_*.[fF] ${SRCDIR}/src_eirene/eirmod_*.[fF]90 | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif
else
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.[fF] | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f90:",".o:",$$1);sub("\\.F90:",".o:",$$1);sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.[fF] ${SRCDIR}/src_eirene/eirmod_*.[fF] ${SRCDIR}/src_eirene/eirmod_*.[fF]90 | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f90:",".${MOD}:",$$1);sub("\\.F90:",".${MOD}:",$$1);sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
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
	echo "$$l" | eval sed "$$E" > ${OBJDIR}/LISTOBJ; \
	ll="OBJF =" ; \
	for d in `echo "$(TPATH)" | tr : \ `; do \
		ll="$$ll `(cd $$d > /dev/null; echo *.F)`"; \
	done; \
	F="-e 's/ \*\.F//g' -e 's/\.F/\.o/g' "; \
	echo "$$ll" | eval sed "$$F" >> ${OBJDIR}/LISTOBJ; \
	lll="OBJS90 =" ; \
	for d in `echo "$(TPATH)" | tr : \ `; do \
		lll="$$lll `(cd $$d > /dev/null; echo *.f90)`"; \
	done; \
	G="-e 's/ \*\.f90//g' -e 's/\.f90/\.o/g' " ; \
	echo "$$lll" | eval sed "$$G" >> ${OBJDIR}/LISTOBJ; \
	llll="OBJF90 =" ; \
	for d in `echo "$(TPATH)" | tr : \ `; do \
		llll="$$llll `(cd $$d > /dev/null; echo *.F90)`"; \
	done; \
	H="-e 's/ \*\.F90//g' -e 's/\.F90/\.o/g' " ; \
	echo "$$llll" | eval sed "$$H" >> ${OBJDIR}/LISTOBJ; \
	lg="GROBJS =" ; \
	lg="$$lg `(cd src/gr-dummy > /dev/null; echo *.f)`"; \
	echo "$$lg" | eval sed "$$E" >> ${OBJDIR}/LISTOBJ

tags:
ifeq ($(LOCAL),yes)
	rm -f ${SRCTRI}/TAGS ; ${MAKETAGS} ${SRCTRI}/TAGS ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.f || touch ${SRCTRI}/TAGS
else
	rm -f ${SRCTRI}/TAGS ; ${MAKETAGS} ${SRCTRI}/TAGS ${SRCDIR}/*/*.f || touch ${SRCTRI}/TAGS
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
	@echo TPATH=${TPATH}
	@echo VPATH=${VPATH}
	@echo ALLOBJS=${ALLOBJS}
	@echo EGROBJS=${EGROBJS}
	@echo OBJS=${OBJS}
	@echo OBJF=${OBJF}
	@echo OBJS90=${OBJS90}
	@echo OBJF90=${OBJF90}
	@echo GROBJS=${GROBJS}
	@echo DEST=${DEST}
	@echo MODULES=${MODULES}
#	@echo MODLOCASE=${MODLOCASE}
	@echo MODMODS=${MODMODS}
#	@echo MODOBJS=${MODOBJS}
#	@echo $(filter-out ${MODOBJS},${ALLOBJS})
	@echo MAINLIST=${MAINLIST}
	@echo EXCLUDELIST=${EXCLUDELIST}
#	@echo OBJDEST=${OBJDEST}
