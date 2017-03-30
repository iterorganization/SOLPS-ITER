#  VERSION : 15.02.99 21:07

SHELL=/bin/sh

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif
ifndef SOLPSTOP
  $(error SOLPSTOP not defined)
endif

SRCUIN  = ${SOLPSTOP}/modules/Uinp
SRCDIR  = ${SRCUIN}/src
BASEDIR = ${SRCUIN}
B2DIR   = ${SOLPSTOP}/modules/B2.5
EIRDIR  = ${SOLPSTOP}/modules/Eirene

MAKES = ${BASEDIR}/Makefile
# Include global SOLPS compiler settings
ifndef SOLPS_CPP
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
    MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
  endif
else
  $(warning ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif
else
  MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
    include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
    MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}.local
  endif
endif

ifdef SOLPS_MPI
  ifndef USE_MPI
    USE_MPI = -DUSE_MPI
  endif
endif

PROG = uinp.exe

# Extension for OBJDIR if debug or MPI options are used
# uncomment following lines if debug-code needed
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
USE_DEBUG = -DDBG
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
EIRINC += ${EIRDIR}/src/local
endif
ifeq ($(shell [ -e ${EIRDIR}/src/common ] && echo yes || echo no ),yes)
EIRINC += -I${EIRDIR}/src/common
endif
EIRINC += -I${EIROBJ}

include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
MAKES+= ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES+= ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
endif
MNEXTRA = ${OBJDIR}/libb25.a

VPATH = ${SRCDIR}

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif

ifdef USE_MPI
LDLIBS += ${LD_MPI}
FFLAGS += ${MPI_CPP}
endif

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P $(INCLUDE) ${SOLPS_CPP} ${USE_DEBUG} $< ${OBJDIR}/$*.f
	$(COMPILE) ${INCLUDE} -o ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: VERSION ${OBJDIR}/${PROG} ${OBJDIR}/ub2p

.PHONY: clean depend listobj tags echo VERSION force

${OBJDIR}/${PROG}: ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${MNEXTRA} ${OBJDIR}/b2mod_layer.o ${OBJDIR}/b2mod_elements.o ${OBJDIR}/b2mod_constants.o ${OBJDIR}/libeirene.a ${OBJDIR}/ioflush.o ${OBJDIR}/libgr_dummy.a ${MAKES}
	${FC} $(FFLAGS) -o ${OBJDIR}/${PROG} ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${OBJDIR}/libeirene.a ${OBJDIR}/ioflush.o ${OBJDIR}/libgr_dummy.a ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/ub2p: ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MAKES} ${MNEXTRA}
	${FC} $(FFLAGS) -o ${OBJDIR}/ub2p ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/libui.a: ${DEST} ${SRCDIR}/git_version_Uinp.h
	@ar rucv $@ ${DEST}
	ranlib $@

${OBJDIR}/libb25.a: ${B2OBJ}/b2mod_constants.o ${OBJDIR}/b2mod_elements.o ${B2OBJ}/b2mod_types.o ${B2OBJ}/b2mod_layer.o ${B2OBJ}/chcase.o ${B2OBJ}/ifill.o ${B2OBJ}/ipmain.o ${B2OBJ}/isadigit.o ${B2OBJ}/isplusorminus.o ${B2OBJ}/len_of_digits.o ${B2OBJ}/lnblnk.o ${B2OBJ}/lower_case.o ${B2OBJ}/lwimai.o ${B2OBJ}/lwmain.o ${B2OBJ}/open_file.o ${B2OBJ}/prgend.o ${B2OBJ}/prgini.o ${B2OBJ}/prvrt.o ${B2OBJ}/prvrti.o ${B2OBJ}/ratio.o ${B2OBJ}/sfill.o ${B2OBJ}/streql.o ${B2OBJ}/strip_spaces.o ${B2OBJ}/subsys.o ${B2OBJ}/sysend.o ${B2OBJ}/sysini.o ${B2OBJ}/xerrab.o ${B2OBJ}/xerset.o ${B2OBJ}/xertst.o ${B2OBJ}/xxdata_11.o ${SRCDIR}/.new_routines
	@ar rucv $@ ${B2OBJ}/b2mod_constants.o ${OBJDIR}/b2mod_elements.o ${B2OBJ}/b2mod_types.o ${B2OBJ}/b2mod_layer.o ${B2OBJ}/chcase.o ${B2OBJ}/ifill.o ${B2OBJ}/ipmain.o ${B2OBJ}/isadigit.o ${B2OBJ}/isplusorminus.o ${B2OBJ}/len_of_digits.o ${B2OBJ}/lnblnk.o ${B2OBJ}/lower_case.o ${B2OBJ}/lwimai.o ${B2OBJ}/lwmain.o ${B2OBJ}/open_file.o ${B2OBJ}/prgend.o ${B2OBJ}/prgini.o ${B2OBJ}/prvrt.o ${B2OBJ}/prvrti.o ${B2OBJ}/ratio.o ${B2OBJ}/sfill.o ${B2OBJ}/streql.o ${B2OBJ}/strip_spaces.o ${B2OBJ}/subsys.o ${B2OBJ}/sysend.o ${B2OBJ}/sysini.o ${B2OBJ}/xerrab.o ${B2OBJ}/xerset.o ${B2OBJ}/xertst.o ${B2OBJ}/xxdata_11.o
	ranlib $@

${OBJDIR}/uinput.o: ${OBJDIR}/uiblkd.o

ifneq (${MOD},o)
${OBJDIR}/b2mod_types.${MOD}:
	ln -sf ${B2OBJ}/b2mod_types.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_layer.${MOD}:
	ln -sf ${B2OBJ}/b2mod_layer.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_constants.${MOD}:
	ln -sf ${B2OBJ}/b2mod_constants.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_elements.${MOD}:
	ln -sf ${B2OBJ}/b2mod_elements.${MOD} ${OBJDIR}
endif

${OBJDIR}/libeirene.a:
	ln -sf ${EIROBJ}/libeirene.a ${OBJDIR}

${OBJDIR}/ioflush.o:
	ln -sf ${EIROBJ}/ioflush.o ${OBJDIR}

${OBJDIR}/libgr_dummy.a:
	ln -sf ${EIROBJ}/libgr_dummy.a ${OBJDIR}

${OBJDIR}/b2mod_types.o:
	ln -sf ${B2OBJ}/b2mod_types.o ${OBJDIR}

${OBJDIR}/b2mod_layer.o:
	ln -sf ${B2OBJ}/b2mod_layer.o ${OBJDIR}

${OBJDIR}/b2mod_elements.o:
	ln -sf ${B2OBJ}/b2mod_elements.o ${OBJDIR}

${OBJDIR}/b2mod_constants.o:
	ln -sf ${B2OBJ}/b2mod_constants.o ${OBJDIR}

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/${PROG} ${OBJDIR}/libui.a ${OBJDIR}/libb25.a ${OBJDIR}/ub2p ${OBJDIR}/LISTOBJ ${SRCDIR}/git_version_Uinp.h ${OBJDIR}/dependencies*
ifneq (${MOD},o)
	rm -f ${OBJDIR}/*.${MOD}
endif

depend: ${OBJS:.o=.F} uiblkd.F uinput.F uiblb2.F ub2p.F ${SRCDIR}/git_version_Uinp.h
	@`which makedepend` -p'$${OBJDIR}/' ${SOLPS_CPP} ${USE_DEBUG} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
	sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	@cd ${SRCDIR} ; rm -f ${OBJDIR}/LISTOBJ; touch ${OBJDIR}/LISTOBJ; \
	echo "OBJS =" *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g' | \
	sed -e 's/ub2p.o//' -e 's/uinput.o//' -e 's/uiblkd.o//' -e 's/uiblb2.o//' > ${OBJDIR}/LISTOBJ

tags:
	rm -f ${BASEDIR}/TAGS ; etags -o ${BASEDIR}/TAGS ${SRCDIR}/*.F ${SRCDIR}/*.h ${SRCDIR}/*.inc

${OBJDIR}/LISTOBJ: listobj

VERSION: ${SRCDIR}/git_version_Uinp.h

${SRCDIR}/git_version_Uinp.h: force
	@echo "      character*27 :: git_version_Uinp = '`git describe --dirty --always`'" > ${SRCDIR}/git_version_new.h
	@if cmp -s ${SRCDIR}/git_version_new.h ${SRCDIR}/git_version_Uinp.h; then rm ${SRCDIR}/git_version_new.h; else mv ${SRCDIR}/git_version_new.h ${SRCDIR}/git_version_Uinp.h; fi

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
