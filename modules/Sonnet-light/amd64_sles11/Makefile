
FORTRANPRG = vectors
FORTRANPRG = string_main

INSTALL = /usr/bin/install -c -m 644
INSTALL_DIR = ../
LIBS = -L${INSTALL_DIR} -lsonnet -lstdc++

INSTALL_USERAREA = ${SOLPSLIB}
LIBS_USERAREA = -L${INSTALL_DIR_USERAREA} -lsonnet -lstdc++

include ../sonnet.src

VPATH = ../
CPL = g++
## CXX = g++
CXXFLAGS = -g
FC = gfortran

.PHONY: all test clean install local_install

all: ${INSTALL_USERAREA}/libsonnet.a

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CPL) -M $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

libsonnet.a: $(sources:.cpp=.o)
	ar clq libsonnet.a $(sources:.cpp=.o)
	${INSTALL} libsonnet.a ${INSTALL_DIR}
	${INSTALL} libsonnet.a ${INSTALL_USERAREA}

${INSTALL_USERAREA}/libsonnet.a: libsonnet.a

test: ${FORTRANPRG}.f
	${FC} -c ../${FORTRANPRG}.f
	${FC} ${FORTRANPRG}.o ${LIBS}

-include $(sources:.cpp=.d)

clean:; rm -rf *.[do] *.d.* *.a a.out ../*.xdr

install: ${INSTALL_USERAREA}/libsonnet.a
	${INSTALL} libsonnet.a ${INSTALL_USERAREA}

local_install: libsonnet.a
	-${INSTALL} libsonnet.a ${INSTALL_DIR}

