#  VERSION : 07.12.2000 22:14

TARGET=$(OBJDIR)/amds
RES2FBR=$(OBJDIR)/res2fbr
VPATH=src

ifndef HOST_NAME
  $(error HOST_NAME not defined)
endif
ifndef COMPILER
  $(error COMPILER not defined)
endif

OBJDIR = builds/${HOST_NAME}.${COMPILER}

ifeq ($(shell [ -e config/config.${HOST_NAME}.${COMPILER} ] && echo yes || echo no ),yes)
include config/config.${HOST_NAME}.${COMPILER}
else
$(error config/config.${HOST_NAME}.${COMPILER} not found)
endif

ifeq ($(shell [ -e config/config.${HOST_NAME}.${COMPILER}.local ] && echo yes || echo no ),yes)
include config/config.${HOST_NAME}.${COMPILER}.local
endif



#OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
#     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o\
#     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
#     xmform2t.o x_~fbr.o

OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o\
     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
     x_~fbr.o

DEST = $(OBJS:%.o=$(OBJDIR)/%.o)

$(OBJDIR)/%.o : %.c
	 $(CC) -c $< -o $@

all: dirs $(RES2FBR) $(TARGET)

.PHONY: VERSION clean neat all depend listobj force

$(TARGET): $(DEST)
	$(CC) -DCbFree=CbFree_ignore -c src/vacreate.c -o $(OBJDIR)/vacreate.o
	$(CC) $(CFLAGS) -o $@ $(DEST) $(LIBS)

$(DEST): src/*.h

src/x_~fbr.c: src/amds.xrs $(RES2FBR)
	 $(RES2FBR) amdsResources <src/amds.xrs >src/x_~fbr.c

$(RES2FBR):  $(OBJDIR)/res2fbr.o
	  cc -o $(RES2FBR) $(OBJDIR)/res2fbr.o

dirs: $(OBJDIR)

neat:
	rm -rf ${OBJDIR}/*.o ${OBJDIR}/*.f

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	 /bin/rm -f $(OBJDIR)/*.o $(OBJDIR)/res2fbr src/x_~fbr.c

TAGS:	tags

tags:
	rm -f TAGS ; etags src/*/*.F

depend: ${OBJS:.o=.F} ${EXCLUDELIS:.o=.F}
	makedepend -f- ${INCLUDE} $^ | \
	sed -e 's|src/[^ ]*/|${OBJDIR}/|' | \
	sed -e 's,^${OBJDIR}/,\$${OBJDIR}/,' | \
	sed -e 's,: ${SOLPSTOP},: $${SOLPSTOP},' > ${OBJDIR}/dependencies.${COMPILER}

listobj:
	@rm -f ${OBJDIR}/LISTOBJ; touch ${OBJDIR}/LISTOBJ; l="OBJS ="; \
	for d in `echo "$(VPATH)" | tr : \ `; do \
		l="$$l `(cd $$d > /dev/null; echo *.F)`"; \
	done; \
	E="-e 's/\.F/\.o/g'" ; for f in $(MAINLIST); do \
		E="$$E -e 's/ $$f//'"; \
	done; \
	echo "$$l" | eval sed "$$E" > ${OBJDIR}/LISTOBJ

${OBJDIR}/LISTOBJ: listobj

VERSION: src/git_version.h

src/git_version.h: force
	@echo "      character*27 :: gitversion ='`git describe --dirty --always`'" > src/git_version_new.h
	@if cmp -s src/git_version_new.h src/git_version.h; then rm src/git_version_new.h; else mv src/git_version_new.h src/git_version.h; fi

${OBJDIR}/dependencies.${COMPILER}:
	-mkdir -p ${OBJDIR}
	touch ${OBJDIR}/dependencies.${COMPILER}
	${MAKE} VERSION
	${MAKE} tags
	${MAKE} listobj
	${MAKE} depend

include ${OBJDIR}/dependencies.${COMPILER}


