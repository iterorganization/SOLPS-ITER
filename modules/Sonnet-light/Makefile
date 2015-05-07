
#SYSNAME should be the output of the 'fs sysname' command
SYSNAME = amd64_sles11
all:
	@echo "Sysname is "${SYSNAME}
	cd ${SYSNAME}; make

clean:
	cd ${SYSNAME}; make clean

install:
	cd ${SYSNAME}; make install

test:
	cd ${SYSNAME}; make test
