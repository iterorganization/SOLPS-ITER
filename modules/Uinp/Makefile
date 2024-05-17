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
CRRDIR  = ${SOLPSTOP}/modules/Carre2
B2SRC   = ${B2DIR}/src

MAKES = ${BASEDIR}/Makefile
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

MAKETAGS ?= ctags -e -f

ifdef SOLPS_MPI
  USE_MPI ?= -DUSE_MPI
endif

PROG = uinp.exe

# Extension for OBJDIR if debug or MPI options are used
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
USE_DEBUG = -DDBG
endif
ifdef USE_OPENMP
EXT_OPENMP = .openmp
endif
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
else
ifdef USE_MPI
EXT_MPI = .mpi
endif
endif

OBJDIR  = ${SRCUIN}/builds/${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_DEBUG}
EIROBJ  = ${EIRDIR}/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}
B2OBJ   = ${B2DIR}/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_IMPGYRO}${EXT_DEBUG}

ifeq ($(shell [ -e ${B2DIR}/src/include.local ] && echo yes || echo no ),yes)
B2INC = -I${B2DIR}/src/include.local -I${B2DIR}/src/include -I${B2DIR}/src/common
else
B2INC = -I${B2DIR}/src/include -I${B2DIR}/src/common
endif
B2INC += -I${B2OBJ}
ifeq ($(shell [ -e ${EIRDIR}/src/local ] && echo yes || echo no ),yes)
EIRINC += -I${EIRDIR}/src/local
endif
ifeq ($(shell [ -e ${EIRDIR}/src/common ] && echo yes || echo no ),yes)
EIRINC += -I${EIRDIR}/src/common
endif
EIRINC += -I${EIROBJ}
CRRINC += -I${CRRDIR}/src90/include

include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
MAKES += ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}
ifeq ($(shell [ -e ${SRCUIN}/config/config.common.${COMPILER} ] && echo yes || echo no ),yes)
include ${SRCUIN}/config/config.common.${COMPILER}
MAKES += ${SRCUIN}/config/config.common.${COMPILER}
endif
ifeq ($(shell [ -e ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
MAKES += ${SRCUIN}/config/config.${HOST_NAME}.${COMPILER}.local
endif
MNEXTRA = ${OBJDIR}/libb25.a ${OBJDIR}/libeirene.a ${OBJDIR}/libgr_dummy.a

VPATH = ${SRCDIR}

ifeq ($(shell [ -e ${OBJDIR}/LISTOBJ ] && echo yes || echo no ),yes)
include ${OBJDIR}/LISTOBJ
endif

ifdef USE_MPI
FFLAGS += ${MPI_CPP}
endif

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

DEFINES =
DIMENSIONS =
ifeq ($(shell [ -s ${B2SRC}/modules/b2mod_dimensions.F ] && echo yes || echo no ),yes)
DIMENSIONS = ${B2OBJ}/b2mod_dimensions.o
DEFINES += -DDIMENSIONS_MODULE
endif

$(OBJDIR)/%.o : %.F
	${CPP} -P ${INCLUDE} ${SOLPS_CPP} ${DEFINES} ${USE_DEBUG} $< ${OBJDIR}/$*.f
	$(COMPILE) ${INCLUDE} ${FFLAGSEXTRA} -o ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: VERSION ${OBJDIR}/${PROG} ${OBJDIR}/ub2p

.PHONY: clean depend listobj tags echo VERSION force

${OBJDIR}/${PROG}: ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${OBJDIR}/ioflush.o ${MNEXTRA} ${MAKES}
	${FC} $(FFLAGS) ${FFLAGSEXTRA} -o ${OBJDIR}/${PROG} ${OBJDIR}/uinput.o ${OBJDIR}/uiblkd.o ${OBJDIR}/uiblb2.o ${OBJDIR}/libui.a ${OBJDIR}/ioflush.o ${MNEXTRA} ${LDLIBS} $(LDEXTRA)

${OBJDIR}/ub2p: ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${OBJDIR}/libb25.a ${MAKES}
	${FC} $(FFLAGS) ${FFLAGSEXTRA} -o ${OBJDIR}/ub2p ${OBJDIR}/ub2p.o ${OBJDIR}/libui.a ${OBJDIR}/libb25.a ${LDLIBS} $(LDEXTRA)

${OBJDIR}/libui.a: ${DEST} ${SRCDIR}/git_version_Uinp.h ${MAKES}
	@ar rucv $@ ${DEST}
	ranlib $@

${OBJDIR}/libb25.a: ${DIMENSIONS} ${B2OBJ}/b2mod_constants.o ${B2OBJ}/b2mod_elements.o ${B2OBJ}/b2mod_types.o ${B2OBJ}/b2mod_layer.o ${B2OBJ}/b2mod_math.o ${B2OBJ}/b2mod_openmp.o ${B2OBJ}/b2mod_solpstop.o ${B2OBJ}/b2mod_version.o ${B2OBJ}/cfvers.o ${B2OBJ}/chcase.o ${B2OBJ}/helper.o ${B2OBJ}/ifill.o ${B2OBJ}/b2mod_ipmain.o ${B2OBJ}/isadigit.o ${B2OBJ}/isplusorminus.o ${B2OBJ}/len_of_digits.o ${B2OBJ}/lower_case.o ${B2OBJ}/b2mod_lwimai.o ${B2OBJ}/b2mod_lwmain.o ${B2OBJ}/machsfr.o ${B2OBJ}/nagsubst.o ${B2OBJ}/open_file.o ${B2OBJ}/prgend.o ${B2OBJ}/prgini.o ${B2OBJ}/prvrt.o ${B2OBJ}/prvrti.o ${B2OBJ}/ratio.o ${B2OBJ}/sfill.o ${B2OBJ}/streql.o ${B2OBJ}/strip_spaces.o ${B2OBJ}/b2mod_subsys.o ${B2OBJ}/sysend.o ${B2OBJ}/sysini.o ${B2OBJ}/xerrab.o ${B2OBJ}/b2mod_xerset.o ${B2OBJ}/xertst.o ${B2OBJ}/xxdata_11.o ${SRCDIR}/.new_routines ${MAKES}
	@ar rucv $@ ${DIMENSIONS} ${B2OBJ}/b2mod_constants.o ${B2OBJ}/b2mod_elements.o ${B2OBJ}/b2mod_types.o ${B2OBJ}/b2mod_layer.o ${B2OBJ}/b2mod_math.o ${B2OBJ}/b2mod_openmp.o ${B2OBJ}/b2mod_solpstop.o ${B2OBJ}/b2mod_version.o ${B2OBJ}/cfvers.o ${B2OBJ}/chcase.o ${B2OBJ}/helper.o ${B2OBJ}/ifill.o ${B2OBJ}/b2mod_ipmain.o ${B2OBJ}/isadigit.o ${B2OBJ}/isplusorminus.o ${B2OBJ}/len_of_digits.o ${B2OBJ}/lower_case.o ${B2OBJ}/b2mod_lwimai.o ${B2OBJ}/b2mod_lwmain.o ${B2OBJ}/machsfr.o ${B2OBJ}/nagsubst.o ${B2OBJ}/open_file.o ${B2OBJ}/prgend.o ${B2OBJ}/prgini.o ${B2OBJ}/prvrt.o ${B2OBJ}/prvrti.o ${B2OBJ}/ratio.o ${B2OBJ}/sfill.o ${B2OBJ}/streql.o ${B2OBJ}/strip_spaces.o ${B2OBJ}/b2mod_subsys.o ${B2OBJ}/sysend.o ${B2OBJ}/sysini.o ${B2OBJ}/xerrab.o ${B2OBJ}/b2mod_xerset.o ${B2OBJ}/xertst.o ${B2OBJ}/xxdata_11.o
	ranlib $@

${OBJDIR}/uinput.o: ${OBJDIR}/uiblkd.o

ifneq (${MOD},o)
${OBJDIR}/b2mod_dimensions.${MOD}:
	ln -sf ${B2OBJ}/b2mod_dimensions.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_types.${MOD}:
	ln -sf ${B2OBJ}/b2mod_types.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_layer.${MOD}:
	ln -sf ${B2OBJ}/b2mod_layer.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_constants.${MOD}:
	ln -sf ${B2OBJ}/b2mod_constants.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_elements.${MOD}:
	ln -sf ${B2OBJ}/b2mod_elements.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_ipmain.${MOD}:
	ln -sf ${B2OBJ}/b2mod_ipmain.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_lwimai.${MOD}:
	ln -sf ${B2OBJ}/b2mod_lwimai.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_lwmain.${MOD}:
	ln -sf ${B2OBJ}/b2mod_lwmain.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_math.${MOD}:
	ln -sf ${B2OBJ}/b2mod_math.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_openmp.${MOD}:
	ln -sf ${B2OBJ}/b2mod_openmp.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_solpstop.${MOD}:
	ln -sf ${B2OBJ}/b2mod_solpstop.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_subsys.${MOD}:
	ln -sf ${B2OBJ}/b2mod_subsys.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_version.${MOD}:
	ln -sf ${B2OBJ}/b2mod_version.${MOD} ${OBJDIR}

${OBJDIR}/b2mod_xerset.${MOD}:
	ln -sf ${B2OBJ}/b2mod_xerset.${MOD} ${OBJDIR}

${OBJDIR}/eirmod_solps.${MOD}:
	ln -sf ${EIROBJ}/eirmod_solps.${MOD} ${OBJDIR}

${OBJDIR}/helper.${MOD}:
	ln -sf ${B2OBJ}/helper.${MOD} ${OBJDIR}
endif

${OBJDIR}/libeirene.a:
	ln -sf ${EIROBJ}/libeirene.a ${OBJDIR}

${OBJDIR}/ioflush.o:
	ln -sf ${EIROBJ}/ioflush.o ${OBJDIR}

${OBJDIR}/libgr_dummy.a:
	ln -sf ${EIROBJ}/libgr_dummy.a ${OBJDIR}

${OBJDIR}/b2mod_dimensions.o:
	ln -sf ${B2OBJ}/b2mod_dimensions.o ${OBJDIR}

${OBJDIR}/b2mod_types.o:
	ln -sf ${B2OBJ}/b2mod_types.o ${OBJDIR}

${OBJDIR}/b2mod_layer.o:
	ln -sf ${B2OBJ}/b2mod_layer.o ${OBJDIR}

${OBJDIR}/b2mod_elements.o:
	ln -sf ${B2OBJ}/b2mod_elements.o ${OBJDIR}

${OBJDIR}/b2mod_constants.o:
	ln -sf ${B2OBJ}/b2mod_constants.o ${OBJDIR}

${OBJDIR}/b2mod_lwimai.o:
	ln -sf ${B2OBJ}/b2mod_lwimai.o ${OBJDIR}

${OBJDIR}/b2mod_lwmain.o:
	ln -sf ${B2OBJ}/b2mod_lwmain.o ${OBJDIR}

${OBJDIR}/b2mod_ipmain.o:
	ln -sf ${B2OBJ}/b2mod_ipmain.o ${OBJDIR}

${OBJDIR}/b2mod_math.o:
	ln -sf ${B2OBJ}/b2mod_math.o ${OBJDIR}

${OBJDIR}/b2mod_openmp.o:
	ln -sf ${B2OBJ}/b2mod_openmp.o ${OBJDIR}

${OBJDIR}/b2mod_solpstop.o:
	ln -sf ${B2OBJ}/b2mod_solpstop.o ${OBJDIR}

${OBJDIR}/b2mod_subsys.o:
	ln -sf ${B2OBJ}/b2mod_subsys.o ${OBJDIR}

${OBJDIR}/b2mod_version.o:
	ln -sf ${B2OBJ}/b2mod_version.o ${OBJDIR}

${OBJDIR}/b2mod_xerset.o:
	ln -sf ${B2OBJ}/b2mod_xerset.o ${OBJDIR}

${OBJDIR}/helper.o:
	ln -sf ${B2OBJ}/helper.o ${OBJDIR}

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/${PROG} ${OBJDIR}/libui.a ${OBJDIR}/libb25.a ${OBJDIR}/ub2p ${OBJDIR}/LISTOBJ ${SRCDIR}/git_version_Uinp.h ${OBJDIR}/dependencies*
ifneq (${MOD},o)
	rm -f ${OBJDIR}/*.${MOD}
endif

depend: ${OBJS:.o=.F} uiblkd.F uinput.F uiblb2.F ub2p.F ${SRCDIR}/git_version_Uinp.h
	@`which makedepend` -p'$${OBJDIR}/' ${SOLPS_CPP} ${USE_DEBUG} ${DEFINES} -f- ${INCLUDE} $^ | \
	sed 's,^$${OBJDIR}/[^ ][^ ]*/,\$${OBJDIR}/,' | \
	sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies.${COMPILER}
	@echo '# 1' >> ${OBJDIR}/dependencies.${COMPILER}
	@egrep -aiH '^ {6,}use ' $^ | grep -v 'IGNORE' | tr , ' ' | awk '{sub("\\.F:",".o:",$$1);sub("^.*/","$${OBJDIR}/",$$1); print $$1,"$${OBJDIR}/"tolower($$3)".${MOD}"}' >> ${OBJDIR}/dependencies.${COMPILER}

listobj:
	@cd ${SRCDIR} ; rm -f ${OBJDIR}/LISTOBJ; touch ${OBJDIR}/LISTOBJ; \
	echo "OBJS =" *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g' | \
	sed -e 's/ub2p\.o//' -e 's/uinput\.o//' -e 's/uiblkd\.o//' -e 's/uiblb2\.o//' > ${OBJDIR}/LISTOBJ

tags:
	rm -f ${BASEDIR}/TAGS ; ${MAKETAGS} ${BASEDIR}/TAGS ${SRCDIR}/*.F ${SRCDIR}/*.h ${SRCDIR}/*.inc || touch ${BASEDIR}/TAGS

${OBJDIR}/LISTOBJ: listobj

VERSION: ${SRCDIR}/git_version_Uinp.h

${SRCDIR}/git_version_Uinp.h: force
	@echo "      character*32 :: git_version_Uinp =" > ${SRCDIR}/git_version_new.h
	@echo "     . '`git describe --tags --dirty --always | cut -c 1-32`'" >> ${SRCDIR}/git_version_new.h
	@if cmp -s ${SRCDIR}/git_version_new.h ${SRCDIR}/git_version_Uinp.h; then rm ${SRCDIR}/git_version_new.h; else mv ${SRCDIR}/git_version_new.h ${SRCDIR}/git_version_Uinp.h; fi

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
ifeq ($(shell [ -e ${SRCUIN}/config/dependencies.local ] && echo yes || echo no ),yes)
include ${SRCUIN}/config/dependencies.local
endif
