#define AMDS_VERSION 104
#define MAXDOUBLE DBL_MAX

#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <stdarg.h>
#include <math.h>
#include <limits.h>
#include <float.h>

#include <Xm/Xm.h>
#include <X11/Shell.h>
#include <Xm/Protocols.h>
#include <Xm/MainW.h>
#include <Xm/RowColumn.h>
#include <Xm/Separator.h>
#include <Xm/ToggleB.h>
#include <Xm/CascadeB.h>
#include <Xm/Text.h>
#include <Xm/Form.h>
#include <Xm/PushB.h>
#include <Xm/DrawingA.h>
#include <Xm/DialogS.h>
#include <Xm/MessageB.h>
#include <Xm/ArrowB.h>
#include <Xm/Label.h>
#include <Xm/FileSB.h>
#include <Xm/List.h>
#include <Xm/TextF.h>
#include <Xm/Frame.h>
#include <Xm/ScrolledW.h>
#include <Xm/PanedW.h>

typedef struct _Database* Database;
typedef struct _XApp* XApp;
typedef struct _Doc* Doc;
typedef struct _View* View;

typedef struct _Particle* Particle;
typedef struct _Reaction* Reaction;
typedef struct _ReactionType* ReactionType;

typedef struct _VarDef* VarDef;

#include "minmax.h"
#include "vacreate.h"
#include "calc.h"
#include "ngroups.h"
#include "vars.h"

#include "amundo.h"
#include "amview.h"
#include "amdoc.h"
#include "amxapp.h"
#include "amdbase.h"
#include "ammenu.h"
#include "aminfo.h"
#include "amfile.h"
#include "amfio.h"
#include "amtext.h"
#include "amvars.h"
#include "amxvars.h"
#include "amgraph.h"
#include "amvald.h"

#define GetVersion() AMDS_VERSION
