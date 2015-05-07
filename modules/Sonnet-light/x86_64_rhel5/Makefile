
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
CXXFLAGS = -g -tp=amd64

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CPL) -M $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$


all: $(sources:.cpp=.o)
	ar clq libsonnet.a $(sources:.cpp=.o)
	${INSTALL} libsonnet.a ${INSTALL_DIR}
	${FC} -r8 -tp=amd64 -c ../${FORTRANPRG}.f
	${FC} -r8 -tp=amd64 ${FORTRANPRG}.o ${LIBS}

include $(sources:.cpp=.d)

clean:; rm -rf *.[do] *.d.* *.a a.out ../*.xdr

install:
	${INSTALL} libsonnet.a ${INSTALL_USERAREA}

local_install:
	${INSTALL} libsonnet.a ${INSTALL_DIR}

