#  VERSION : 09.05.95 17:02

SHELL=/bin/sh
CPP=/usr/lib/cpp

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif

MAKETAGS ?= ctags -e -f

MAKES = Makefile
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

include config/config.${HOST_NAME}.${COMPILER}

ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif
OBJDIR = builds/${HOST_NAME}.${COMPILER}${EXT_DEBUG}

VPATH=src

OBJS = fxdr.o chkinp.o crrinf.o fxdrnm.o rdeqlh.o

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P ${INCLUDE} $< ${OBJDIR}/$*.f
	$(COMPILE) ${FFLAGSEXTRA} -o ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: dirs ${OBJDIR}/fxdr

${OBJDIR}/fxdr: $(DEST) $(MAKES)
	${FC} $(FFLAGS) ${FFLAGSEXTRA} -o ${OBJDIR}/fxdr $(DEST) ${LDLIBS} $(LDEXTRA)

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/fxdr

depend: ${OBJS:.o=.F}
	makedepend -f- ${INCLUDE} $^ | \
	sed -e '3,$$s|src/|${OBJDIR}/|' | \
	sed -e 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	cd src ; echo " " *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g'

tags:
	rm -f TAGS ; ${MAKETAGS} TAGS src/*.F || touch TAGS

dirs: ${OBJDIR}

${OBJDIR}:
	-mkdir -p ${OBJDIR}

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
