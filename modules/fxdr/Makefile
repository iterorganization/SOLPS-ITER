#  VERSION : 09.05.95 17:02

SHELL=/bin/sh
CPP=/usr/lib/cpp


ifndef HOST
  $(error HOST not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif


include config/config.${HOST}.${COMPILER}


OBJDIR = builds/${HOST}.${COMPILER}

VPATH=src

OBJS = fxdr.o chkinp.o crrinf.o fxdrnm.o rdeqlh.o

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.F
	${CPP} -P -C $(INCLUDE) $< ${OBJDIR}/$*.f
	$(COMPILE) -o ${OBJDIR}/$*.o ${OBJDIR}/$*.f

all: dirs ${OBJDIR}/fxdr

${OBJDIR}/fxdr: $(DEST) Makefile
	${FC} $(FFLAGS) -o ${OBJDIR}/fxdr $(DEST) ${LDLIBS} $(LDEXTRA)

clean:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f ${OBJDIR}/fxdr

depend: ${OBJS:.o=.F}
	makedepend -f ${OBJDIR}/dependencies.${COMPILER} ${INCLUDE} $^
	mv ${OBJDIR}/dependencies.${COMPILER} ${OBJDIR}/dependencies.${COMPILER}.bak
	sed -e '3,$$s|src/|${OBJDIR}/|' ${OBJDIR}/dependencies.${COMPILER}.bak > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	cd src ; echo " " *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g'

tags:
	rm -f TAGS ; etags src/*.F

dirs: ${OBJDIR}

${OBJDIR}:
	-mkdir -p ${OBJDIR}

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
