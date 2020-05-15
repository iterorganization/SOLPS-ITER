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

# Extensions for OBJDIR if mpi and/or debug options are used
ifdef USE_MPI
EXT_MPI = .mpi
endif
ifdef USE_OPENMP
EXT_OPENMP = .openmp
endif
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
endif
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
DEFINES  += -DDBG
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
else
  MAKES += ${SOLPSTOP}/SETUP/setup.csh.${HOST_NAME}.${COMPILER} ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
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

INCLUDE=
LOCAL=no
ifneq ($(strip ${SRCLOCAL}), )
LOCAL=$(shell [ -d ${SRCLOCAL} ] && echo yes || echo no )
endif
ifeq ($(LOCAL),yes)
INCLUDE = -I${SRCLOCAL}
endif
INCLUDE += -I${OBJDIR} -I${B2SRC}/include.local -I${B2SRC}/include

ifeq ($(LOCAL),yes)
ifeq ($(strip ${LD_GR}),)
VPATH =${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src:${SRCEIR}/grsoft-dummy
else
VPATH =${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src
endif
else
ifeq ($(strip ${LD_GR}),)
VPATH =${SRCDIR}/modules:${SRCDIR}/src:${SRCEIR}/grsoft-dummy
else
VPATH =${SRCDIR}/modules:${SRCDIR}/src
endif
endif
FPATH =${SRCDIR}/modules

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif
include ${SRCTRI}/config/compile
MAKES+= ${SRCTRI}/config/compile ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES+= ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
endif

MODULES := ${patsubst ${SRCDIR}/modules/%.f,%,${shell echo ${SRCDIR}/modules/*.f}}
MODULES += ${patsubst ${SRCDIR}/modules/%.F,%,${shell echo ${SRCDIR}/modules/*.F}}
MODLOCASE:=$(shell echo $(MODULES)| tr A-Z a-z)
MODMODS := ${MODLOCASE:%=${OBJDIR}/%.${MOD}}
MODOBJS = ${MODULES:%=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o} ${OBJF:%.o=${OBJDIR}/%.o}
SRCF = ${OBJS:%.o=%.f} ${OBJF:%.o=%.F}

EXCLUDELIS = tria.o triageom.o triainq.o

DEST = ${filter-out $(MODOBJS),$(OBJS:%.o=$(OBJDIR)/%.o)}
MAINLIST = $(EXCLUDELIS:.=\.)

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
${OBJDIR}/tria ${OBJDIR}/.x: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.nox 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${LDLIBS} $(GKS) $(LDEXTRA) && touch ${OBJDIR}/.x

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} ${GKS} $(LDEXTRA)
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} $(LDEXTRA)
endif
else
${OBJDIR}/tria ${OBJDIR}/.nox: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${MAKES}
	rm -f ${OBJDIR}/tria 2> /dev/null; \
	rm -f ${OBJDIR}/.x 2> /dev/null; \
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${OBJDIR}/ioflush.o ${LDLIBS} $(LDEXTRA) && touch ${OBJDIR}/.nox

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} $(LDEXTRA)
endif

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) ${FFLAGSEXTRA} -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o ${OBJDIR}/libtria.a

${OBJDIR}/libtria.a: ${ALLOBJS}
	${BLD} $@ ${ALLOBJS}
	ranlib $@

${OBJDIR}/ioflush.o:
	ln -sf ${EIROBJ}/ioflush.o ${OBJDIR}

clean:
	rm -rf ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/libtria.a ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies
ifneq (${MOD},o)
	rm -rf ${OBJDIR}/*.${MOD}
endif

depend: ${OBJS:.o=.f} ${EXCLUDELIS:.o=.f}
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
          awk '{sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/modules/*.[fF] | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	@echo '# 4b' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.[fF] | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 5b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.[fF] ${SRCDIR}/modules/*.[fF] | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 6b' >> ${OBJDIR}/dependencies
endif
else
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.[fF] | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	@echo '# 3b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.[fF] | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	@echo '# 4b' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.[fF] | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".o:",$$1);sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 5b' >> ${OBJDIR}/dependencies
	@egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.[fF] | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	@echo '# 6b' >> ${OBJDIR}/dependencies
endif
endif

update:
	cd $(SOLPSTOP); gmake update

listobj:
	@rm -f ${OBJDIR}/LISTOBJ ; touch ${OBJDIR}/LISTOBJ ; l="OBJS =" ; \
	for d in `echo "$(VPATH)" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.f)`"; \
	done; \
	E="-e 's/\.f/\.o/g'" ; for f in $(MAINLIST); do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${OBJDIR}/LISTOBJ
	@lf="OBJF =" ; \
	for d in `echo "$(FPATH)" | tr : \ `; do \
		lf="$$lf `(cd $$d > /dev/null; echo *.F)`"; \
	done; \
	E="-e 's/\.F/\.o/g'" ; for f in $(MAINLIST); do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$lf" | eval sed "$$E" >> ${OBJDIR}/LISTOBJ

tags:
ifeq ($(LOCAL),yes)
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCLOCAL}/*.[fF] ${SRCDIR}/*/*.[fF] || touch ${SRCTRI}/TAGS
else
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCDIR}/*/*.[fF] || touch ${SCRTRI}/TAGS
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
#	@echo OBJS=${OBJS}
#	@echo OBJF=${OBJF}
	@echo DEST=${DEST}
	@echo MODULES=${MODULES}
#	@echo MODLOCASE=${MODLOCASE}
	@echo MODMODS=${MODMODS}
#	@echo MODOBJS=${MODOBJS}
#	@echo $(filter-out ${MODOBJS},${ALLOBJS})
	@echo EXCLUDELIS=${EXCLUDELIS}
	@echo MAINLIST=${MAINLIST}
	@echo SRCF=${SRCF}
#	@echo OBJDEST=${OBJDEST}
