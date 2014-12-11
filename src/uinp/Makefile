#  VERSION : 15.02.99 21:07

SHELL=/bin/sh
CPP=/usr/lib/cpp

SRCDIR = ${SOLPSTOP}/src/DivGeo/uinp/src
SRCUIN = ${SOLPSTOP}/src/DivGeo/uinp
OBJDIR = ${SOLPSTOP}/base/DivGeo/uinp/${OBJECTCODE}
BASEDIR = ${SOLPSTOP}/base/DivGeo/uinp
B2DIR = ${SOLPSTOP}/base/b2
EIRDIR = ${SOLPSTOP}/base/Eirene
ifeq ($(shell [ -e ${SOLPSTOP}/src/Eirene/local ] && echo yes || echo no ),yes)
EIRINC = ${SOLPSTOP}/src/Eirene/local -I${SOLPSTOP}/src/Eirene/src/common
else
EIRINC = ${SOLPSTOP}/src/Eirene/src/common
endif

include ${SRCUIN}/config/compiler.${OBJECTCODE}
MAKES = ${BASEDIR}/Makefile ${SRCUIN}/config/compiler.${OBJECTCODE}
ifeq ($(shell [ -e ${SRCUIN}/config.local/compiler.${OBJECTCODE} ] && echo yes || echo no ),yes)
include ${SRCUIN}/config.local/compiler.${OBJECTCODE}
MAKES+= ${SRCUIN}/config.local/compiler.${OBJECTCODE}
endif
MNEXTRA = ${OBJDIR}/precision.o ${OBJDIR}/braeir.o ${OBJDIR}/eirdiag.o ${OBJDIR}/ccoupl.o ${OBJDIR}/parmmod.o ${OBJDIR}/comprt.o ${OBJDIR}/clgin.o

# I=-Isrc -I$(EIRINC)

VPATH = ${SRCDIR}

ifeq ($(shell [ -e ${BASEDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${BASEDIR}/LISTOBJ
endif

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P -C $(INCLUDE) ${SOLPS_CPP} $< ${OBJDIR}/$*.f
	$(COMPILE) -o ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: ${OBJDIR}/uinp ${OBJDIR}/ub2p

ifneq (${MOD},o)
${OBJDIR}/parmmod.${MOD}:
	ln -sf ${EIRDIR}/${OBJECTCODE}/parmmod.${MOD} ${OBJDIR}

${OBJDIR}/braeir.${MOD}: ${OBJDIR}/precision.${MOD} ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/comprt.${MOD}
	ln -sf ${EIRDIR}/${OBJECTCODE}/braeir.${MOD} ${OBJDIR}

${OBJDIR}/eirdiag.${MOD}: ${OBJDIR}/precision.${MOD} ${OBJDIR}/parmmod.${MOD} ${OBJDIR}/ccoupl.${MOD}
	ln -sf ${EIRDIR}/${OBJECTCODE}/eirdiag.${MOD} ${OBJDIR}

${OBJDIR}/ccoupl.${MOD}:
	ln -sf ${EIRDIR}/${OBJECTCODE}/ccoupl.${MOD} ${OBJDIR}

${OBJDIR}/comprt.${MOD}:
	ln -sf ${EIRDIR}/${OBJECTCODE}/comprt.${MOD} ${OBJDIR}

${OBJDIR}/precision.${MOD}:
	ln -sf ${EIRDIR}/${OBJECTCODE}/precision.${MOD} ${OBJDIR}
endif

${OBJDIR}/parmmod.o:
	ln -sf ${EIRDIR}/${OBJECTCODE}/parmmod.o ${OBJDIR}

${OBJDIR}/braeir.o: ${OBJDIR}/precision.o ${OBJDIR}/parmmod.o ${OBJDIR}/comprt.o
	ln -sf ${EIRDIR}/${OBJECTCODE}/braeir.o ${OBJDIR}

${OBJDIR}/eirdiag.o: ${OBJDIR}/precision.o ${OBJDIR}/parmmod.o ${OBJDIR}/ccoupl.o
	ln -sf ${EIRDIR}/${OBJECTCODE}/eirdiag.o ${OBJDIR}

${OBJDIR}/ccoupl.o:
	ln -sf ${EIRDIR}/${OBJECTCODE}/ccoupl.o ${OBJDIR}

${OBJDIR}/clgin.o:
	ln -sf ${EIRDIR}/${OBJECTCODE}/clgin.o ${OBJDIR}

${OBJDIR}/comprt.o:
	ln -sf ${EIRDIR}/${OBJECTCODE}/comprt.o ${OBJDIR}

${OBJDIR}/precision.o:
	ln -sf ${EIRDIR}/${OBJECTCODE}/precision.o ${OBJDIR}

${OBJDIR}/uinp: ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${B2DIR}/${OBJECTCODE}/libb2.a ${SOLPS_LIB}/libmscl.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/uinp ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${MNEXTRA} ${OBJDIR}/libui.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/ub2p: ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${B2DIR}/${OBJECTCODE}/libb2.a ${SOLPS_LIB}/libmscl.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/ub2p ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/libui.a: ${DEST}
	ar r $@ $?
	ranlib $@

${OBJDIR}/uinput.o: ${OBJDIR}/uiblkd.o

1.42:
	cd ../uinp.1.42 && gmake
	ln -sf ../../uinp.1.42/${OBJECTCODE}/uinp ${OBJECTCODE}/uinp.1.42
	ln -sf ../../uinp.1.42/${OBJECTCODE}/ub2p ${OBJECTCODE}/ub2p.1.42

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/uinp ${OBJDIR}/libui.a

depend: ${OBJS:.o=.F} uiblkd.F uinput.F uiblb2.F ub2p.F
	`which makedepend` -p'$${OBJDIR}/' ${SOLPS_CPP} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' > ${OBJDIR}/dependencies.${OBJECTCODE}

listobj:
	@cd src ; rm -f ${BASEDIR}/LISTOBJ; touch ${BASEDIR}/LISTOBJ; \
		echo "OBJS =" *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g' | \
		sed -e 's/ub2p.o//' -e 's/uinput.o//' -e 's/uiblkd.o//' -e 's/uiblb2.o//' > ${BASEDIR}/LISTOBJ

tags:
	rm -f ${BASEDIR}/TAGS ; etags -o ${BASEDIR}/TAGS ${SRCDIR}/*.F ${SRCDIR}/*.h ${SRCDIR}/*.inc ${SRCDIR}/PARMMOD ${SRCDIR}/PARMUSR

${BASEDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies.${OBJECTCODE}:
	-mkdir -p ${OBJDIR}
	ln -s ${OBJDIR} ${SRCUIN}/${OBJECTCODE}
	touch ${OBJDIR}/dependencies.${OBJECTCODE}
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${OBJECTCODE}
