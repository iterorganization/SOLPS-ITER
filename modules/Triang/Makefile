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

# Include global SOLPS compiler settings
ifndef SOLPS_CPP
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
else
  $(warning ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif
endif

SRCTRI   = ${PWD}
SRCDIR   = ${SRCTRI}/src
SRCLOCAL = ${SRCTRI}/local
B2SRC    = ${SOLPSTOP}/modules/B2.5/src
SRCEIR   = ${SOLPSTOP}/modules/Eirene/src

# Extension for OBJDIR if debug options are used
# uncomment following lines if debug-code needed
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif

# Directory where objectcode/binaries will be created
OBJDIR = ${SRCTRI}/builds/${HOST_NAME}.${COMPILER}${EXT_DEBUG}


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

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif
include ${SRCTRI}/config/compile
MAKES = ${SRCTRI}/Makefile ${SRCTRI}/config/compile ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES+= ${SRCTRI}/config/config.${HOST_NAME}.${COMPILER}.local
endif

#MODULES := ${patsubst ${SRCDIR}/%.f,%,${shell grep -il '^[ \t]*[ \t]module[ \t]' ${SRCDIR}/modules/*.f}}
MODULES := ${patsubst ${SRCDIR}/modules/%.f,%,${shell echo ${SRCDIR}/modules/*.f}}
MODLOCASE:=$(shell echo $(MODULES)| tr A-Z a-z)
MODMODS := ${MODLOCASE:%=${OBJDIR}/%.${MOD}}
MODOBJS = ${MODULES:%=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}
SRCF = ${OBJS:%.o=%.f}

EXCLUDELIS = tria.o triageom.o triainq.o

DEST = ${filter-out $(MODOBJS),$(OBJS:%.o=$(OBJDIR)/%.o)}
MAINLIST = $(EXCLUDELIS:.=\.)

all: ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/triainq

mods: $(MODMODS)

${OBJDIR}/tria: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) -o ${OBJDIR}/tria ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${LDLIBS} $(GKS) $(LDEXTRA)

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES}
	${LD} $(LDOPTS) -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${LDLIBS} $(GKS) $(LDEXTRA)

${OBJDIR}/triainq: ${OBJDIR}/triainq.o ${MAKES}
	${LD} $(LDOPTS) -o ${OBJDIR}/triainq ${OBJDIR}/triainq.o

${OBJDIR}/libtria.a: ${ALLOBJS}
	${BLD} $@ ${ALLOBJS}
	ranlib $@

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/libtria.a ${OBJDIR}/tria ${OBJDIR}/triageom ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies
ifneq (${MOD},o)
	rm -rf ${OBJDIR}/*.${MOD}
endif
ifneq ($(strip $(SED)),)
	rm -rf ${OBJDIR}/*.f
endif

depend: ${OBJS:.o=.f} ${EXCLUDELIS:.o=.f} ${OBJDIR}/dependencies
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' >> ${OBJDIR}/dependencies
endif
ifeq ($(LOCAL),yes)
	egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/modules/*.f | grep -v 'IGNORE'  | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	egrep -ai '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/modules/*.f | grep -v 'IGNORE'  | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
endif
else
	egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -ai '^[ 	]+use ' ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	egrep -ai '^[ 	]+use ' ${SRCDIR}/modules/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
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

tags:
ifeq ($(LOCAL),yes)
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCLOCAL}/*.f ${SRCDIR}/*/*.F
else
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCDIR}/*/*.f
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
	@echo DEST=${DEST}
	@echo MODULES=${MODULES}
#	@echo MODLOCASE=${MODLOCASE}
	@echo MODMODS=${MODMODS}
#	@echo MODOBJS=${MODOBJS}
#	@echo $(filter-out ${MODOBJS},${ALLOBJS})
	@echo EXCLUDELIS=${EXCLUDELIS}
	@echo MAINLIST=${MAINLIST}
#	@echo ${SRCF}
#	@echo ${OBJDEST}
