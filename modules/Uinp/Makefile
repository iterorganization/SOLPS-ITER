#  VERSION : 15.02.99 21:07

SHELL=/bin/sh
CPP=/usr/lib/cpp

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif
ifndef SOLPSTOP
  $(error SOLPSTOP not defined)
endif

PROG = uinp.exe

SRCUIN  = ${SOLPSTOP}/modules/Uinp
SRCDIR  = ${SRCUIN}/src
BASEDIR = ${SRCUIN}
B2DIR   = ${SOLPSTOP}/modules/B2.5
EIRDIR  = ${SOLPSTOP}/modules/Eirene



# Extension for OBJDIR if debug or MPI options are used
# uncomment following lines if debug-code needed
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif
ifdef USE_MPI
EXT_MPI = .mpi
endif
OBJDIR  = ${SRCUIN}/builds/${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_DEBUG}
EIROBJ  = ${EIRDIR}/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_DEBUG}
B2OBJ   = ${B2DIR}/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_DEBUG}

ifeq ($(shell [ -e ${B2DIR}/src/include.local ] && echo yes || echo no ),yes)
B2INC = ${B2DIR}/src/include.local -I${B2DIR}/src/include -I${B2DIR}/src/common
else
B2INC = ${B2DIR}/src/include -I${B2DIR}/src/common
endif
B2INC += -I${B2OBJ}
ifeq ($(shell [ -e ${EIRDIR}/src/local ] && echo yes || echo no ),yes)
EIRINC = ${EIRDIR}/src/local -I${EIRDIR}/src/common
else
EIRINC = ${EIRDIR}/src/common
endif
EIRINC += -I${EIROBJ}

include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
MAKES = ${BASEDIR}/Makefile ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES+= ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
endif
MNEXTRA = ${B2OBJ}/open_file.o

VPATH = ${SRCDIR}

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P -C $(INCLUDE) ${SOLPS_CPP} $< ${OBJDIR}/$*.f
	$(COMPILE) -o $(INCLUDE) ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: ${OBJDIR}/${PROG} ${OBJDIR}/ub2p

${OBJDIR}/${PROG}: ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${MNEXTRA} ${B2OBJ}/b2mod_layer.o ${EIROBJ}/eirmod_extrab25.o ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/${PROG} ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${MNEXTRA} ${OBJDIR}/libui.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/ub2p: ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/ub2p ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/libui.a: ${DEST}
	ar r $@ $?
	ranlib $@

${OBJDIR}/uinput.o: ${OBJDIR}/uiblkd.o

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/${PROG} ${OBJDIR}/libui.a ${OBJDIR}/ub2p ${OBJDIR}/LISTOBJ ${OBJDIR}/dependencies*

depend: ${OBJS:.o=.F} uiblkd.F uinput.F uiblb2.F ub2p.F
	`which makedepend` -p'$${OBJDIR}/' ${SOLPS_CPP} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	@cd ${SRCDIR} ; rm -f ${OBJDIR}/LISTOBJ; touch ${OBJDIR}/LISTOBJ; \
	echo "OBJS =" *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g' | \
	sed -e 's/ub2p.o//' -e 's/uinput.o//' -e 's/uiblkd.o//' -e 's/uiblb2.o//' > ${OBJDIR}/LISTOBJ

tags:
	rm -f ${BASEDIR}/TAGS ; etags -o ${BASEDIR}/TAGS ${SRCDIR}/*.F ${SRCDIR}/*.h ${SRCDIR}/*.inc

${OBJDIR}/LISTOBJ: listobj

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
