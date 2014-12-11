#  VERSION : 07.12.2000 22:14

#LIBS= -L/usr/X11/lib -lXm -lXt -lX11 -lm
LIBS= -Wl,-Bstatic -lXm -Wl,-Bdynamic -lXt -lX11 -lm -L/usr/X11R6/lib
# CFLAGS= -g -qflag=i:w
CFLAGS= -g
CC=cc

TARGET=$(OBJECTCODE)/amds
RES2FBR=$(OBJECTCODE)/res2fbr
VPATH=src

#OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
#     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o\
#     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
#     xmform2t.o x_~fbr.o

OBJS=amvald.o amview.o amgraph.o amxvars.o amvars.o amundo.o \
     amfio.o amdbase.o ammenu.o aminfo.o ammain.o vacreate.o\
     amfile.o amtext.o calc.o vars.o ngroups.o amdoc.o amxapp.o \
     x_~fbr.o

DEST = $(OBJS:%.o=$(OBJECTCODE)/%.o)

$(OBJECTCODE)/%.o : %.c
	 $(CC) -c $< -o $@

all: $(RES2FBR) $(TARGET)

$(TARGET): $(DEST)
	$(CC) -DCbFree=CbFree_ignore -c src/vacreate.c -o $(OBJECTCODE)/vacreate.o
	$(CC) $(CFLAGS) -o $@ $(DEST) $(LIBS)

$(DEST): src/*.h

src/x_~fbr.c: src/amds.xrs $(RES2FBR)
	 $(RES2FBR) amdsResources <src/amds.xrs >src/x_~fbr.c

$(RES2FBR):  $(OBJECTCODE)/res2fbr.o
	  cc -o $(RES2FBR) $(OBJECTCODE)/res2fbr.o

clean:
	 /bin/rm -f $(OBJECTCODE)/*.o $(OBJECTCODE)/res2fbr src/x_~fbr.c
