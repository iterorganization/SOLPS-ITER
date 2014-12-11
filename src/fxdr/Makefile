#  VERSION : 09.05.95 17:02

SHELL=/bin/sh
CPP=/usr/lib/cpp

include config/compiler.${OBJECTCODE}

VPATH=src

OBJS = fxdr.o chkinp.o crrinf.o fxdrnm.o rdeqlh.o

DEST = $(OBJS:%.o=$(OBJECTCODE)/%.o)

$(OBJECTCODE)/%.o : %.F
	${CPP} -P -C $(INCLUDE) $< ${OBJECTCODE}/$*.f
	$(COMPILE) -o ${OBJECTCODE}/$*.o ${OBJECTCODE}/$*.f

all: ${OBJECTCODE}/fxdr

${OBJECTCODE}/fxdr: $(DEST) ${SOLPS_LIB}/libmscl.a Makefile
	${FC} $(FFLAGS) -o ${OBJECTCODE}/fxdr $(DEST) ${LDLIBS} $(LDEXTRA)

clean:
	rm -rf ${OBJECTCODE}/*.o ${OBJECTCODE}/*.f ${OBJECTCODE}/fxdr

depend: ${OBJS:.o=.F}
	makedepend -f ${OBJECTCODE}/dependencies.${OBJECTCODE} ${INCLUDE} $^
	mv ${OBJECTCODE}/dependencies.${OBJECTCODE} ${OBJECTCODE}/dependencies.${OBJECTCODE}.bak
	sed -e '3,$$s/^/${OBJECTCODE}\//' ${OBJECTCODE}/dependencies.${OBJECTCODE}.bak > ${OBJECTCODE}/dependencies.${OBJECTCODE}

listobj:
	cd src ; echo " " *.F | sed -e 's/ [^ /]*\// /g' -e 's/\.F/.o/g'

tags:
	rm -f TAGS ; etags src/*.F

${OBJECTCODE}/dependencies.${OBJECTCODE}:
	-mkdir -p ${OBJECTCODE}
	touch ${OBJECTCODE}/dependencies.${OBJECTCODE}
	${MAKE} depend

include ${OBJECTCODE}/dependencies.${OBJECTCODE}
