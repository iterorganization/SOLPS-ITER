
FORTRANPRG = vectors
FORTRANPRG = string_main

INSTALL = /usr/bin/install -c -m 644
INSTALL_DIR = ../
LIBS = -L${INSTALL_DIR} -lsonnet -lstdc++

INSTALL_USERAREA = ${SOLPS_LIB}
LIBS_USERAREA = -L${INSTALL_DIR_USERAREA} -lsonnet -lstdc++
 
include ../sonnet.src
 
VPATH = ../
CPL = g++
## CXX = g++
CXXFLAGS = -g

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CPL) -M $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$


all: $(sources:.cpp=.o)
	ar clq libsonnet.a $(sources:.cpp=.o)
	${INSTALL} libsonnet.a ${INSTALL_DIR}
	ifort -r8 -c ../${FORTRANPRG}.f
	ifort -r8 ${FORTRANPRG}.o ${LIBS}

include $(sources:.cpp=.d)

clean:; rm -rf *.[do] *.d.* *.a a.out ../*.xdr

install:
	${INSTALL} libsonnet.a ${INSTALL_USERAREA}

local_install:
	-${INSTALL} libsonnet.a ${INSTALL_DIR}

