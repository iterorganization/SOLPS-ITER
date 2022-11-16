MAKES = Makefile

# Include global SOLPS compiler settings
ifndef SOLPS_CPP
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
  include ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
  MAKES += ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER}
else
  $(warning ${SOLPSTOP}/SETUP/config.${HOST_NAME}.${COMPILER} not found.)
endif
ifeq ($(shell [ -e ${SOLPSTOP}/SETUP/config.common.${COMPILER} ] && echo yes || echo no ),yes)
  include ${SOLPSTOP}/SETUP/config.common.${COMPILER}
  MAKES += ${SOLPSTOP}/SETUP/config.common.${COMPILER}
endif
endif

#SYSNAME should be the output of the 'fs sysname' command
SYSNAME ?= amd64_sles11
MAKES += ${SYSNAME}/Makefile

.PHONY: all clean install

all:	${MAKES}
	@echo "Sysname is "${SYSNAME}
	cd ${SYSNAME}; make

clean:
	cd ${SYSNAME}; make clean

install:
	cd ${SYSNAME}; make install

test:
	cd ${SYSNAME}; make test
