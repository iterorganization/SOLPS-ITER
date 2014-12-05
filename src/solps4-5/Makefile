SRCDIR = ${SOLPSTOP}/src/solps4-5/src
S45DIR = ${SOLPSTOP}/src/solps4-5
EIRDIR = ${SOLPSTOP}/base/Eirene
B2BDIR = ${SOLPSTOP}/base/b2
OBJDIR = ${SOLPSTOP}/base/solps4-5/${OBJECTCODE}
BASEDIR = ${SOLPSTOP}/base/solps4-5
SOLPS4 = ${SOLPSTOP}/../solps4.3_trunk
SRC4LOCAL = ${SOLPSTOP}/src/solps4-5/local_4
SRC5LOCAL = ${SOLPSTOP}/src/solps4-5/local_5
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
INCLUDE = -I${SRC4LOCAL}
else
INCLUDE =
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${SRC5LOCAL}
endif
INCLUDE += -I${SRCDIR}/B2.5_commons -I${SRCDIR}/B2_commons -I${SRCDIR}/Eirene_commons -I${SOLPSTOP}/include.local -I${SOLPSTOP}/include -I${MDSPLUS_DIR}/include
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
VPATH+=${SRC5LOCAL}:${SRC4LOCAL}:${SRCDIR}/Eirene_modules:${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4:${SRCDIR}/solps5
else
VPATH+=${SRC4LOCAL}:${SRCDIR}/Eirene_modules:${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4:${SRCDIR}/solps5
endif
else
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
VPATH+=${SRC5LOCAL}:${SRCDIR}/Eirene_modules:${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4:${SRCDIR}/solps5
else
VPATH+=${SRCDIR}/Eirene_modules:${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4:${SRCDIR}/solps5
endif
endif
ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

PROG_XR = b2sxdr.exe
MOD4LES = ${patsubst ${SRCDIR}/Eirene_modules/%.F,%.o,${shell echo ${SRCDIR}/Eirene_modules/*.F}}
MOD5LES = ${patsubst ${SRCDIR}/B2.5_modules/%.F,%.o,${shell echo ${SRCDIR}/B2.5_modules/*.F}}
MODULES	= ${MOD4LES} ${MOD5LES}
SOURCE4 = ${patsubst ${SRCDIR}/solps4/%.F,%.o,${shell echo ${SRCDIR}/solps4/*.F}}
SOURCE5 = ${patsubst ${SRCDIR}/solps5/%.F,%.o,${shell echo ${SRCDIR}/solps5/*.F}}
SOURCF4 = ${shell echo ${SRCDIR}/solps4/*.F}
SOURCF5 = ${shell echo ${SRCDIR}/solps5/*.F}
MODMODS = ${MODULES:%.o=${OBJDIR}/%.${MOD}}
MD4OBJS = ${MOD4LES:%.o=${OBJDIR}/%.o}
MD5OBJS = ${MOD5LES:%.o=${OBJDIR}/%.o}
MODOBJS = ${MODULES:%.o=${OBJDIR}/%.o}
SR4OBJS = ${SOURCE4:%.o=${OBJDIR}/%.o}
SR5OBJS = ${SOURCE5:%.o=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}

EXCLUDELIST = ${patsubst %.exe, %.o, ${PROG_XR}}
XREXE = ${patsubst %.exe, ${OBJDIR}/%.exe, ${PROG_XR}}
XROBJ = ${patsubst %.exe, ${OBJDIR}/%.o, ${PROG_XR}}

XREXTRA=${OBJDIR}/b2_4to5.o ${OBJDIR}/xerset_5.o
ifdef USE_EIRENE
MNEXTRA=${OBJDIR}/libeirene.a ${OBJDIR}/libgr_dummy.a
endif
DEFAULT: ${XREXE}

include ${S45DIR}/config/compile
ifeq ($(shell [ -e ${S45DIR}/config.local/compiler.${OBJECTCODE} ] && echo yes || echo no ),yes)
include ${S45DIR}/config.local/compiler.${OBJECTCODE}
endif

${XREXE}: ${OBJDIR}/%.exe: ${OBJDIR}/%.o ${XREXTRA} ${OBJDIR}/libb2_solps5.a ${OBJDIR}/libb2_solps4.a ${MNEXTRA}
	${LD} ${LDOPTS} $^ -o $@ ${LDLIBES} ${LCPP} ${LDOPTSend}

ifdef USE_EIRENE
${OBJDIR}/libb2_solps4.a: ${SR4OBJS}
else
${OBJDIR}/libb2_solps4.a: ${MD4OBJS} ${SR4OBJS}
endif
	${BLD} $@ $?

${OBJDIR}/libb2_solps5.a: ${MD5OBJS} ${SR5OBJS}
	${BLD} $@ $?

${OBJDIR}/libeirene.a:
	ln -sf ${EIRDIR}/${OBJECTCODE}/libeirene.a ${OBJDIR}/

${OBJDIR}/libgr_dummy.a:
	ln -sf ${EIRDIR}/${OBJECTCODE}/libgr_dummy.a ${OBJDIR}/

depend: ${BASEDIR}/LISTOBJ ${OBJS:.o=.F} ${EXCLUDELIST:.o=.F}
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' >> ${OBJDIR}/dependencies
endif
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
	egrep -i '^ {6,}use ' ${SRC5LOCAL}/*.F ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	egrep -i '^ {6,}use ' ${SRC5LOCAL}/*.F ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
else
	egrep -i '^ {6,}use ' ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	egrep -i '^ {6,}use ' ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif
else
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
	egrep -i '^ {6,}use ' ${SRC5LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	egrep -i '^ {6,}use ' ${SRC5LOCAL}/*.F ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
else
	egrep -i '^ {6,}use ' ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
	egrep -i '^ {6,}use ' ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/*/*.F | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif
endif

${BASEDIR}/TAGS: tags

tags:
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
	rm -f ${BASEDIR}/TAGS ; etags ${SRC5LOCAL}/*.h ${SRC4LOCAL}/*.h ${SRCDIR}/*_commons/*.[hH] ${SRC5LOCAL}/*.F ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.F ${SRCDIR}/*.F
else
	rm -f ${BASEDIR}/TAGS ; etags ${SRC4LOCAL}/*.h ${SRCDIR}/*_commons/*.[hH] ${SRC4LOCAL}/*.F ${SRCDIR}/*/*.F ${SRCDIR}/*.F
endif
else
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
	rm -f ${BASEDIR}/TAGS ; etags ${SRC5LOCAL}/*.h ${SRCDIR}/*_commons/*.[hH] ${SRC5LOCAL}/*.F ${SRCDIR}/*/*.F ${SRCDIR}/*.F
else
	rm -f ${BASEDIR}/TAGS ; etags ${SRCDIR}/*_commons/*.[hH] ${SRCDIR}/*/*.F ${SRCDIR}/*.F
endif
endif

clean:
	rm -f ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/*.${MOD} ${OBJDIR}/*.a ${OBJDIR}/*.exe

listobj:
	@rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; l="OBJS ="; \
	for d in `echo "${VPATH}" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.F)`"; \
	done; \
	E="-e 's/\.F/\.o/g'" ; for f in ${EXCLUDELIST}; do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${BASEDIR}/LISTOBJ

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies: ${SRCDIR}/B2.5_modules/.new_modules ${SRCDIR}/Eirene_modules/.new_modules
ifeq ($(shell [ -d ${OBJDIR} ] && echo yes || echo no ),no)
	-mkdir -p ${OBJDIR}
endif
ifeq ($(shell [ -d ${S45DIR}/${OBJECTCODE} ] && echo yes || echo no ),no)
	ln -s ${OBJDIR} ${S45DIR}/${OBJECTCODE}
endif
	touch ${OBJDIR}/dependencies
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies

echo:
	@echo MODOBJS=${MODOBJS}
	@echo MD5OBJS=${MD5OBJS}
	@echo SR5OBJS=${SR5OBJS}

