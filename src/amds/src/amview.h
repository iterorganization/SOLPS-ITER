#define F_SHOWN 0x0001
#define F_PRESERVED 0x0002

#define PB_MASK "__all__"

struct _View {
  XApp xapp;
  Database db;
  Doc subset;
  View mainView;
  Group dependentWidgets;
  int dirty;

  int rdWidth,rsWidth,rnWidth,riWidth,bGroupParticles;

  Widget wShell,wMain,wList;
};

typedef void (*DwNotifyProc)(Widget,View,int evt,void* obj,void* userData);

#define MakeXmString(s) XmStringCreateLtoR((s),XmFONTLIST_DEFAULT_TAG)
#define DelDependentWidget(w,wg) DelDependentWidgetEx(w,wg,False)

View CreateView(XApp xapp,Doc set,View mainView);
void* FreeView(View w);
void NotifyView(View w,int msg,void* obj);
Group GetSelectedReactions(View w);

void AddDependentWidget(View w,Widget wg,int eventMask,
  DwNotifyProc notifyProc,void* userData);
void DelDependentWidgetEx(View w,Widget wg,int bWidgetDestroyed);

void CreateParticleMenu(View w,Widget wCb,Particle pUp,XtCallbackProc
    cbCascade,XtCallbackProc cbActivate,XtPointer userData);

void DwUndoButton(Widget,View,int evt,void* obj,void* userData);
void DwTrackDelete(Widget,View,int evt,void* obj,void* userData);

#define N_ALT           0x0001
#define N_NOW           0x0002
#define N_SEL           0x0004
#define N_SETVAR        0x0008
#define N_VARDEFS       0x0010
#define N_DEL           0x0020
#define N_ENABLE        0x0040
