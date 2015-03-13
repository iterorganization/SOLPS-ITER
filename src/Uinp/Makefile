#  VERSION : 15.02.99 21:07

SHELL=/bin/sh
CPP=/usr/lib/cpp

SRCDIR = ${SOLPSTOP}/src/Uinp/src
SRCUIN = ${SOLPSTOP}/src/Uinp
OBJDIR = ${SOLPSTOP}/bin/${OBJECTCODE}/Uinp
BASEDIR = ${SOLPSTOP}/src/Uinp
B2DIR = ${SOLPSTOP}/src/B2.5
B2OBJ = ${SOLPSTOP}/bin/${OBJECTCODE}/B25eirene/B2.5
EIRDIR = ${SOLPSTOP}/src/Eirene
EIROBJ = ${SOLPSTOP}/bin/${OBJECTCODE}/B25eirene/Eirene
ifeq ($(shell [ -e ${B2DIR}/src/include.local ] && echo yes || echo no ),yes)
B2INC = ${B2DIR}/src/include.local -I${B2DIR}/src/include -I${B2DIR}/src/common
else
B2INC = ${B2DIR}/src/include -I${B2DIR}/src/common
endif
B2INC += -I${B2OBJ}
ifeq ($(shell [ -e ${EIRDIR}/local ] && echo yes || echo no ),yes)
EIRINC = ${EIRDIR}/local -I${EIRDIR}/src/common
else
EIRINC = ${EIRDIR}/src/common
endif
EIRINC += -I${EIROBJ}

include ${SRCUIN}/config/compiler.${OBJECTCODE}
MAKES = ${BASEDIR}/Makefile ${SRCUIN}/config/compiler.${OBJECTCODE}
ifeq ($(shell [ -e ${SRCUIN}/config.local/compiler.${OBJECTCODE} ] && echo yes || echo no ),yes)
include ${SRCUIN}/config.local/compiler.${OBJECTCODE}
MAKES+= ${SRCUIN}/config.local/compiler.${OBJECTCODE}
endif
MNEXTRA = ${B2OBJ}/open_file.o

VPATH = ${SRCDIR}

ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P -C $(INCLUDE) ${SOLPS_CPP} $< ${OBJDIR}/$*.f
	$(COMPILE) -o $(INCLUDE) ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: ${OBJDIR}/uinp ${OBJDIR}/ub2p

${OBJDIR}/uinp: ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${MNEXTRA} ${B2OBJ}/b2mod_layer.o ${EIROBJ}/eirmod_extrab25.o ${SOLPS_LIB}/libmscl.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/uinp ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${MNEXTRA} ${OBJDIR}/libui.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/ub2p: ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${SOLPS_LIB}/libmscl.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/ub2p ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/libui.a: ${DEST}
	ar r $@ $?
	ranlib $@

${OBJDIR}/uinput.o: ${OBJDIR}/uiblkd.o

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/uinp ${OBJDIR}/libui.a ${OBJDIR}/ub2p

depend: ${OBJS:.o=.F} uiblkd.F uinput.F uiblb2.F ub2p.F
	`which makedepend` -p'$${OBJDIR}/' ${SOLPS_CPP} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' > ${OBJDIR}/dependencies.${OBJECTCODE}

listobj:
	@cd src ; rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; \
	echo "OBJS =" *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g' | \
	sed -e 's/ub2p.o//' -e 's/uinput.o//' -e 's/uiblkd.o//' -e 's/uiblb2.o//' > ${BASEDIR}/LISTOBJ

tags:
	rm -f ${BASEDIR}/TAGS ; etags -o ${BASEDIR}/TAGS ${SRCDIR}/*.F ${SRCDIR}/*.h ${SRCDIR}/*.inc

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies.${OBJECTCODE}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${OBJECTCODE}
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${OBJECTCODE}
