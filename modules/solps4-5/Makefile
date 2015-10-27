# Test whether necessary environment variables are defined; if not, exit
ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif

# Extension for OBJDIR if debug option is used
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif

TOOL_CHAIN = ${HOST_NAME}.${COMPILER}${EXT_DEBUG}

SRCDIR = ${SOLPSTOP}/modules/solps4-5/src
S45DIR = ${SOLPSTOP}/modules/solps4-5
EIRDIR = ${SOLPSTOP}/modules/Eirene/builds/couple_SOLPS-ITER.${TOOL_CHAIN}
B2BDIR = ${SOLPSTOP}/modules/B2.5/builds/couple_Eirene.${TOOL_CHAIN}
OBJDIR = ${SOLPSTOP}/modules/solps4-5/builds/${TOOL_CHAIN}
BASEDIR = ${SOLPSTOP}/modules/solps4-5
SOLPS4 = ${SOLPSTOP}/../SOLPS/solps4.3
DEFINES += -DSOLPS4_3 -DB25_EIRENE -DUSE_ARRAYS
ifeq ($(shell [ -d ${SOLPS4} ] && echo yes || echo no ),no)
  $(error Invalid SOLPS4 directory address)
endif
SRC4LOCAL = ${SOLPSTOP}/modules/solps4-5/src/local_4
SRC5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/local_5
INC4LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2_include.local
INC5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2.5_include.local
B2M5LOCAL = ${SOLPSTOP}/modules/solps4-5/src/B2.5_modules.local
EIRMLOCAL = ${SOLPSTOP}/modules/solps4-5/src/Eirene_modules.local
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
INCLUDE = -I${SRC4LOCAL}
TAGSLIST = ${SRC4LOCAL}/*.F
VPATH = ${SRC4LOCAL}:
else
INCLUDE =
TAGSLIST =
VPATH = 
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${SRC5LOCAL}
TAGSLIST += ${SRC5LOCAL}/*.F
VPATH += ${SRC5LOCAL}:
endif
ifeq ($(shell [ -d ${INC4LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${INC4LOCAL}
TAGSLIST += ${INC4LOCAL}/*.h
VPATH += ${INC4LOCAL}:
endif
ifeq ($(shell [ -d ${INC5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${INC5LOCAL}
TAGSLIST += ${INC5LOCAL}/*.h
VPATH += ${INC5LOCAL}:
endif
ifeq ($(shell [ -d ${B2M5LOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${B2M5LOCAL}
TAGSLIST += ${B2M5LOCAL}/*.F
VPATH += ${B2M5LOCAL}:
endif
ifeq ($(shell [ -d ${EIRMLOCAL} ] && echo yes || echo no ),yes)
INCLUDE += -I${EIRMLOCAL}
TAGSLIST += ${EIRMLOCAL}/*.F
VPATH += ${EIRMLOCAL}:
endif
INCLUDE += -I${SRCDIR}/B2.5_include -I${SRCDIR}/B2.5_commons -I${SRCDIR}/B2_include -I${SRCDIR}/Eirene_commons -I${MDSPLUS_DIR}/include
TAGSLIST += ${SRCDIR}/*_commons/*.[hH] ${SRCDIR}/*/*.F ${SRCDIR}/*.F
VPATH += ${SRCDIR}/B2.5_modules:${SRCDIR}:${SRCDIR}/solps4_B2:${SRCDIR}/solps4_Eirene:${SRCDIR}/solps5

include ${S45DIR}/config/compile
ifeq ($(shell [ -e ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${S45DIR}/config/config.${HOST_NAME}.${COMPILER}.local
endif

ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

PROG_XR = b2sxdr.exe
MOD4LES = ${patsubst ${SRCDIR}/Eirene_modules/%.f,%.o,${shell echo ${SRCDIR}/Eirene_modules/*.f}}
MOD5LES = ${patsubst ${SRCDIR}/B2.5_modules/%.F,%.o,${shell echo ${SRCDIR}/B2.5_modules/*.F}}
MODULES	= ${MOD4LES} ${MOD5LES}
SOURCB4 = ${patsubst ${SRCDIR}/solps4_B2/%.F,%.o,${shell echo ${SRCDIR}/solps4_B2/*.F}}
SOURCE4 = ${patsubst ${SRCDIR}/solps4_Eirene/%.F,%.o,${shell echo ${SRCDIR}/solps4_Eirene/*.F}}
SOURCE5 = ${patsubst ${SRCDIR}/solps5/%.F,%.o,${shell echo ${SRCDIR}/solps5/*.F}}
SOURCF4 = ${shell echo ${SRCDIR}/solps4_*/*.F}
SOURCF5 = ${shell echo ${SRCDIR}/solps5/*.F}
MODMODS = ${MODULES:%.o=${OBJDIR}/%.${MOD}}
MD4OBJS = ${MOD4LES:%.o=${OBJDIR}/%.o}
MD5OBJS = ${MOD5LES:%.o=${OBJDIR}/%.o}
MODOBJS = ${MODULES:%.o=${OBJDIR}/%.o}
SB4OBJS = ${SOURCB4:%.o=${OBJDIR}/%.o}
SE4OBJS = ${SOURCE4:%.o=${OBJDIR}/%.o}
SR5OBJS = ${SOURCE5:%.o=${OBJDIR}/%.o}
ALLOBJS = ${OBJS:%.o=${OBJDIR}/%.o}
FFLIST  = ${SRC5LOCAL}/*.F ${SRC4LOCAL}/*.F 
FFLIST  = ${shell echo ${SRCDIR}/*/*.H ${SRCDIR}/*.F ${SRCDIR}/solps5/*.F ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/solps4_B2/*.F}
ifeq ($(shell [ -d ${SRC4LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC4LOCAL}/*.F}
endif
ifeq ($(shell [ -d ${SRC5LOCAL} ] && echo yes || echo no ),yes)
FFLIST  += ${shell echo ${SRC5LOCAL}/*.F}
endif
MODLIST += ${shell echo ${SRCDIR}/B2.5_modules/*.F ${SRCDIR}/b2_4to5.F}

EXCLUDELIST = ${patsubst %.exe, %.o, ${PROG_XR}}
XREXE = ${patsubst %.exe, ${OBJDIR}/%.exe, ${PROG_XR}}
XROBJ = ${patsubst %.exe, ${OBJDIR}/%.o, ${PROG_XR}}

XREXTRA=${OBJDIR}/b2_4to5.o ${OBJDIR}/xerset_5.o
MNEXTRA=

.PHONY: DEFAULT ALL clean depend listobj tags

ALL: ${XREXE}

DEFAULT: ${XREXE}

${XREXE}: ${XROBJ} ${XREXTRA} ${OBJDIR}/libb2_solps5.a ${OBJDIR}/libb2_solps4.a ${MNEXTRA} 
	${LD} ${LDOPTS} $^ -o $@ ${LDLIBES} ${LCPP} ${LDOPTSend}

${OBJDIR}/b2sxdr.o: ${OBJDIR}/eirmod_parmmod.${MOD} 

${OBJDIR}/b2_4to5.o: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2_4to5.${MOD}: ${OBJDIR}/eirmod_parmmod.${MOD} ${OBJDIR}/braeir.${MOD} ${OBJDIR}/eirdiag.${MOD}

${OBJDIR}/b2_neutrals_namelist.o: ${OBJDIR}/eirmod_parmmod.${MOD} 

${OBJDIR}/default.o: ${OBJDIR}/ceirsrt.${MOD}

${OBJDIR}/find_param.o: ${OBJDIR}/ccrm.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comprt.${MOD}

${OBJDIR}/if0prm.o: ${OBJDIR}/cinit.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comprt.${MOD}

${OBJDIR}/init.o: ${OBJDIR}/ceirsrt.${MOD} ${OBJDIR}/eirdiag.${MOD} 

${OBJDIR}/leer.o: ${OBJDIR}/comprt.${MOD}

${OBJDIR}/eirmod_braeir.${MOD}: 
	ln -sf ${EIRDIR}/eirmod_braeir.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_extrab25.${MOD}: 
	ln -sf ${EIRDIR}/eirmod_extrab25.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_parmmod.${MOD}: ${OBJDIR}/parmmod.${MOD} 
	ln -sf ${OBJDIR}/parmmod.${MOD} $@

ifneq (${MOD},o)
${OBJDIR}/b2_neutrals_namelist.${MOD}: ${OBJDIR}/eirmod_parmmod.${MOD} 

${OBJDIR}/eirmod_parmmod.o: 
	ln -sf ${OBJDIR}/parmmod.o $@

${OBJDIR}/parmmod.o: ${OBJDIR}/precision.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/braeir.o: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/caprmc.o: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.o: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccrm.o: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/cgrid.o: ${OBJDIR}/comprt.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/comprt.o: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comusr.o: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.o: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/cupd.o: ${OBJDIR}/comsig.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/eirdiag.o: ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/photon.o: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F
endif

${OBJDIR}/parmmod.${MOD}: ${OBJDIR}/precision.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/parmmod.o -c ${SRCDIR}/Eirene_modules/parmmod.F

${OBJDIR}/precision.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/precision.o -c ${SRCDIR}/Eirene_modules/precision.F

${OBJDIR}/braeir.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/braeir.o -c ${SRCDIR}/Eirene_modules/braeir.F

${OBJDIR}/caprmc.${MOD}: ${OBJDIR}/cgrid.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/comusr.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/caprmc.o -c ${SRCDIR}/Eirene_modules/caprmc.F

${OBJDIR}/ccflux.${MOD}: ${OBJDIR}/ctrig.${MOD} ${OBJDIR}/cgeom.${MOD} ${OBJDIR}/ccona.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccflux.o -c ${SRCDIR}/Eirene_modules/ccflux.F

${OBJDIR}/ccona.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccona.o -c ${SRCDIR}/Eirene_modules/ccona.F

${OBJDIR}/ccoupl.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccoupl.o -c ${SRCDIR}/Eirene_modules/ccoupl.F

${OBJDIR}/ccrm.${MOD}: ${OBJDIR}/ccona.${MOD} ${OBJDIR}/comxs.${MOD} ${OBJDIR}/ctrcei.${MOD} ${OBJDIR}/clogau.${MOD} ${OBJDIR}/cestim.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comsou.${MOD} ${OBJDIR}/caprmc.${MOD} ${OBJDIR}/photon.${MOD} ${OBJDIR}/csdvi.${MOD} ${OBJDIR}/ccflux.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ccrm.o -c ${SRCDIR}/Eirene_modules/ccrm.F

${OBJDIR}/ceirsrt.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ceirsrt.o -c ${SRCDIR}/Eirene_modules/ceirsrt.F

${OBJDIR}/cestim.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cestim.o -c ${SRCDIR}/Eirene_modules/cestim.F

${OBJDIR}/cgeom.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgeom.o -c ${SRCDIR}/Eirene_modules/cgeom.F

${OBJDIR}/cgrid.${MOD}: ${OBJDIR}/comprt.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cgrid.o -c ${SRCDIR}/Eirene_modules/cgrid.F

${OBJDIR}/cinit.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cinit.o -c ${SRCDIR}/Eirene_modules/cinit.F

${OBJDIR}/clgin.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clgin.o -c ${SRCDIR}/Eirene_modules/clgin.F

${OBJDIR}/clogau.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/clogau.o -c ${SRCDIR}/Eirene_modules/clogau.F

${OBJDIR}/comprt.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comprt.o -c ${SRCDIR}/Eirene_modules/comprt.F

${OBJDIR}/comsig.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsig.o -c ${SRCDIR}/Eirene_modules/comsig.F

${OBJDIR}/comsou.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comsou.o -c ${SRCDIR}/Eirene_modules/comsou.F

${OBJDIR}/comusr.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comusr.o -c ${SRCDIR}/Eirene_modules/comusr.F

${OBJDIR}/comxs.${MOD}: ${OBJDIR}/cupd.${MOD} ${OBJDIR}/comprt.${MOD} 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/comxs.o -c ${SRCDIR}/Eirene_modules/comxs.F

${OBJDIR}/csdvi.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/csdvi.o -c ${SRCDIR}/Eirene_modules/csdvi.F

${OBJDIR}/ctrcei.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrcei.o -c ${SRCDIR}/Eirene_modules/ctrcei.F

${OBJDIR}/ctrig.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/ctrig.o -c ${SRCDIR}/Eirene_modules/ctrig.F

${OBJDIR}/cupd.${MOD}: ${OBJDIR}/comsig.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/cupd.o -c ${SRCDIR}/Eirene_modules/cupd.F

${OBJDIR}/czt1.${MOD}: 
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/czt1.o -c ${SRCDIR}/Eirene_modules/czt1.F

${OBJDIR}/eirdiag.${MOD}: ${OBJDIR}/clgin.${MOD} ${OBJDIR}/ccoupl.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/eirdiag.o -c ${SRCDIR}/Eirene_modules/eirdiag.F

${OBJDIR}/photon.${MOD}: ${OBJDIR}/clogau.${MOD} ${OBJDIR}/czt1.${MOD} ${OBJDIR}/comusr.${MOD}
	${DBLFC} ${DDBLOPTION} ${FCOPTS} ${DEFINES} ${EQUIV4} ${INCLUDE} ${INCMOD}${OBJDIR} ${OBJDEST} -o ${OBJDIR}/photon.o -c ${SRCDIR}/Eirene_modules/photon.F

${OBJDIR}/libb2_solps4.a: ${MD4OBJS} ${SB4OBJS} ${SE4OBJS}
	${BLD} $@ $?

${OBJDIR}/libb2_solps5.a: ${MD5OBJS} ${SR5OBJS}
	${BLD} $@ $?

depend: ${BASEDIR}/LISTOBJ ${OBJS:.o=.F} ${EXCLUDELIST:.o=.F}
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies
ifneq (${MOD},o)
	`which makedepend` -p'$${OBJDIR}/' ${DEFINES} -f- ${INCLUDE} $^ -o.${MOD} | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
        sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' >> ${OBJDIR}/dependencies
endif
	egrep -ai '^ {6,}use ' ${FFLIST} | grep -v 'IGNORE' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
ifneq (${MOD},o)
	egrep -ai '^ {6,}use ' ${MODLIST} | grep -v 'IGNORE' | awk '{sub("\\.F:",".${MOD}:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies
endif

${BASEDIR}/TAGS: tags

tags:
	rm -f ${BASEDIR}/TAGS ; etags ${TAGSLIST}

clean:
	rm -f ${OBJDIR}/*.f ${OBJDIR}/*.o ${OBJDIR}/*.${MOD} ${OBJDIR}/*.a ${OBJDIR}/*.exe

listobj:
	@rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; l="OBJS ="; \
	for d in `echo "${VPATH}" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.[Ff])`"; \
	done; \
	E="-e 's/\.[Ff]/\.o/g'" ; for f in ${EXCLUDELIST}; do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${BASEDIR}/LISTOBJ

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies: ${SRCDIR}/B2.5_modules/.new_modules
ifeq ($(shell [ -d ${OBJDIR} ] && echo yes || echo no ),no)
	-mkdir -p ${OBJDIR}
endif
	touch ${OBJDIR}/dependencies
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies

echo:
	@echo VPATH=${VPATH}
#	@echo MOD4LES=${MOD4LES}
#	@echo MODOBJS=${MODOBJS}
#	@echo MD5OBJS=${MD5OBJS}
	@echo MD4OBJS=${MD5OBJS}
	@echo SB4OBJS=${SB4OBJS}
	@echo SE4OBJS=${SE4OBJS}
#	@echo SR5OBJS=${SR5OBJS}

