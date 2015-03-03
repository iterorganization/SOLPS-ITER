#  VERSION : 16.12.2004 23:59

SRCDIR = ${SOLPSTOP}/src/Triang/src
SRCTRI = ${SOLPSTOP}/src/Triang
SRCLOCAL =${SOLPSTOP}/src/Triang/local
OBJDIR = ${SOLPSTOP}/bin/${OBJECTCODE}/Triang
B2SRC = ${SOLPSTOP}/src/B2.5/src

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
VPATH =${SRCLOCAL}:${SRCDIR}/modules:${SRCDIR}/src
else
VPATH =${SRCDIR}/modules:${SRCDIR}/src
endif

ifeq ($(shell [ -e ${SRCTRI}/LISTOBJ ] && echo yes || echo no ),yes)
include ${SRCTRI}/LISTOBJ
endif
include ${SRCTRI}/config/compile
MAKES = ${SRCTRI}/Makefile ${SRCTRI}/config/compile ${SRCTRI}/config/compiler.${OBJECTCODE}
ifeq ($(shell [ -e ${SRCTRI}/config.local/compiler.${OBJECTCODE} ] && echo yes || echo no ),yes)
include ${SRCTRI}/config.local/compiler.${OBJECTCODE}
MAKES+= ${SRCTRI}/config.local/compiler.${OBJECTCODE}
endif

#MODULES := ${patsubst ${SRCDIR}/%.f,%,${shell grep -il '^[ \t]*[ \t]module[ \t]' ${SRCDIR}/modules/*.f}}
MODULES := ${patsubst ${SRCDIR}/modules/%.f,%,${shell echo ${SRCDIR}/modules/*.f}}
MODLOCASE:=$(shell echo $(MODULES)| tr A-Z a-z)
MODMODS := ${MODLOCASE:%=${OBJDIR}/%.${MOD}}
MODOBJS = ${MODULES:%=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}
SRCF = ${OBJS:%.o=%.f}

EXCLUDELIS = tria.o triageom.o

DEST = ${filter-out $(MODOBJS),$(OBJS:%.o=$(OBJDIR)/%.o)}
MAINLIST = $(EXCLUDELIS:.=\.)

all: ${OBJDIR}/tria ${OBJDIR}/triageom

mods: $(MODMODS)

${OBJDIR}/tria: ${OBJDIR}/tria.o ${OBJDIR}/libtria.a ${MAKES} $(GRDUMMY)
	${LD} $(LDOPTS) -o ${OBJDIR}/tria ${OBJDIR}/tria.o $(GRDUMMY) ${OBJDIR}/libtria.a ${LDLIBS} $(GKS) $(LDEXTRA)

${OBJDIR}/triageom: ${OBJDIR}/triageom.o ${OBJDIR}/libtria.a ${MAKES} $(GRDUMMY)
	${LD} $(LDOPTS) -o ${OBJDIR}/triageom ${OBJDIR}/triageom.o $(GRDUMMY) ${OBJDIR}/libtria.a ${LDLIBS} $(GKS) $(LDEXTRA)

${OBJDIR}/libtria.a: ${ALLOBJS}
	ar r $@ $?
	ranlib $@

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.${MOD} ${OBJDIR}/libtria.a ${OBJDIR}/tria ${OBJDIR}/triageom

depend: ${OBJS:.o=.f} ${EXCLUDELIS:.o=.f} ${OBJDIR}/dependencies
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' >> ${OBJDIR}/dependencies
endif
ifeq ($(LOCAL),yes)
	egrep -i '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' ' | \
          awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	egrep -i '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/modules/*.f | grep -v 'IGNORE'  | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -i '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	egrep -i '^[ 	]+use ' ${SRCLOCAL}/*.f ${SRCDIR}/modules/*.f | grep -v 'IGNORE'  | tr , ' ' | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
endif
	ls ${SRCDIR}/modules/*.f | tr , ' '  | awk '{sub("\\.f",".${MOD}",$$1);sub("^.*/","$${OBJDIR}/",$$1); m=$$1;sub("\\.${MOD}",".o",m); print $$1":",m}' >> ${OBJDIR}/dependencies
else
	egrep -i '^[ 	]+use ' ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' '  | \
          awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' | sort -u >> ${OBJDIR}/dependencies
	egrep -i '^[ 	]+use ' ${SRCDIR}/modules/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -i '^[ 	]+use ' ${SRCDIR}/*/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
	egrep -i '^[ 	]+use ' ${SRCDIR}/modules/*.f | grep -v 'IGNORE' | tr , ' '  | awk '{sub("\\.f:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".o"}' >> ${OBJDIR}/dependencies
endif
	ls ${SRCDIR}/modules/*.f | tr , ' '  | awk '{sub("\\.f",".${MOD}",$$1);sub("^.*/","$${OBJDIR}/",$$1); m=$$1;sub("\\.${MOD}",".o",m); print $$1":",m}' >> ${OBJDIR}/dependencies
endif

update:
	cd $(SOLPSTOP); gmake update

listobj:
	@rm -f ${SRCTRI}/LISTOBJ ; touch ${SRCTRI}/LISTOBJ ; l="OBJS =" ; \
	for d in `echo "$(VPATH)" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.f)`"; \
	done; \
	E="-e 's/\.f/\.o/g'" ; for f in $(MAINLIST); do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${SRCTRI}/LISTOBJ

tags:
ifeq ($(LOCAL),yes)
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCLOCAL}/*.f ${SRCDIR}/*/*.F
else
	rm -f ${SRCTRI}/TAGS ; etags -o ${SRCTRI}/TAGS ${SRCDIR}/*/*.f
endif

${SRCTRI}/LISTOBJ: listobj

${OBJDIR}/dependencies: 
	-mkdir -p ${OBJDIR}
	ln -s ${OBJDIR} ${SRCTRI}/${OBJECTCODE}
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
