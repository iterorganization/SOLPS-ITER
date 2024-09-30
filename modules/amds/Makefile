#  VERSION : 07.12.2000 22:14

TARGET=$(OBJDIR)/amds
RES2FBR=$(OBJDIR)/res2fbr
CALC=$(OBJDIR)/calc_atomic_data
VPATH=src

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif

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

MAKETAGS ?= ctags -e -f

# Extensions for object directories when various options are used
ifdef SOLPS_OPENMP
EXT_OPENMP = .openmp
endif
ifdef SOLPS_DEBUG
EXT_DEBUG = .debug
endif
ifdef USE_IMPGYRO
EXT_IMPGYRO = .ig
else
ifdef SOLPS_MPI
EXT_MPI = .mpi
endif
endif

OBJDIR = ${PWD}/builds/${HOST_NAME}.${COMPILER}${EXT_DEBUG}
B2OBJ = ${SOLPSTOP}/modules/B2.5/builds/couple_SOLPS-ITER.${HOST_NAME}.${COMPILER}${EXT_OPENMP}${EXT_MPI}${EXT_DEBUG}

ifeq ($(shell [ -e config/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
include config/config.${HOST_NAME}.${COMPILER}
MAKES+= config/config.${HOST_NAME}.${COMPILER}
else
$(error config/config.${HOST_NAME}.${COMPILER} not found)
endif

ifeq ($(shell [ -e config/config.common.${COMPILER} ] && echo yes || echo no ),yes)
include config/config.common.${COMPILER}
MAKES+= config/config.common.${COMPILER}
endif

ifeq ($(shell [ -e config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include config/config.${HOST_NAME}.${COMPILER}.local
MAKES+= config/config.${HOST_NAME}.${COMPILER}.local
endif

#OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
#     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o \
#     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
#     xmform2t.o x_~fbr.o

OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o \
     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
     x_~fbr.o

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

all: $(RES2FBR) $(TARGET) $(CALC)

.PHONY: VERSION clean neat all depend listobj force

$(OBJDIR)/vacreate.o:
	$(CC) $(CFLAGS) $(INCLUDES) -DCbFree=CbFree_ignore -c src/vacreate.c -o $(OBJDIR)/vacreate.o

$(OBJDIR)/%.o : %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(TARGET): $(DEST) $(MAKES)
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $(DEST) $(LIBS)

src/x_~fbr.c: src/amds.xrs $(RES2FBR)
	$(RES2FBR) amdsResources < src/amds.xrs > src/x_~fbr.c

$(RES2FBR): $(OBJDIR)/res2fbr.o $(MAKES)
	$(CC) $(CFLAGS) -o $(RES2FBR) $(OBJDIR)/res2fbr.o

$(CALC): ${B2OBJ}/calc_atomic_data.exe $(MAKES)
	cp ${B2OBJ}/calc_atomic_data.exe $(CALC)
	touch $(CALC)

dirs: $(OBJDIR)

neat:
	rm -rf ${OBJDIR}/*.o src/x_~fbr.c

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	/bin/rm -f $(OBJDIR)/*.o src/x_~fbr.c $(TARGET) $(RES2FBR) $(CALC) \
	$(OBJDIR)/dependencies* $(OBJDIR)/LISTOBJ

TAGS:	tags

tags:
	rm -f TAGS ; ${MAKETAGS} TAGS src/*.c src/*.h || touch TAGS

depend: ${OBJS:.o=.c}
	@$(CC) $(INCLUDES) -M $^ | sed '/^[^ ]*.o: / s|^|${OBJDIR}/|' | \
	sed -e 's,^${OBJDIR}/,\$${OBJDIR}/,' | \
	sed 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	@P=${OBJDIR}; cd src ; rm -f $${P}/LISTOBJ; touch $${P}/LISTOBJ; \
	echo "OBJS =" *.c | sed -e 's/ [^ /]*\// /g' -e 's/\.c/.o/g' -e 's/res2fbr\.o//g' > $${P}/LISTOBJ

${OBJDIR}/LISTOBJ: listobj

VERSION: src/git_version.h

src/git_version.h: force
	@echo "#define GIT_VERSION \"`git describe --tags --dirty --always`\"" > src/git_version_new.h
	@if cmp -s src/git_version_new.h src/git_version.h; then rm src/git_version_new.h; else mv src/git_version_new.h src/git_version.h; fi

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} VERSION
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}
