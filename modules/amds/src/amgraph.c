#include "amds.h"
#include <signal.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/wait.h>

/* Data structures and constants */

#define GD_DENSITIES 10
#define GDL_ALLOCINCR 20

#define ENV_DIR "AMDSGRAPHDIR"
#define ENV_CMD "AMDSGRAPHCMD"

#define V_NONE MAXDOUBLE

#define TEX_LEFT "E-88"
#define TEX_BOTTOM "E-88"
#define TEX_RIGHT "W 8.88E+88"
#define TEX_TOP "ABCDEFGH_H.8_8.88.88w"

#define GLVMCOUNT       4

#define VM0_GRAPHLINE   0
#define VM1_GRAPHLINE   1
#define VM2_GRAPHLINE   2
#define VM3_GRAPHLINE   3
#define VM4_GRAPHLINE   4
#define VM_GRIDLINE     100
#define VM_GRIDTEXT     101
#define VM1_LEGENDTEXT  102
#define VM1_GRAPHSYMS   103
#define VM0_GRAPHSYMS   104
#define VM_BORDER       105
#define VM0_LEGENDTEXT  106

#define DT_ABOVE        0x0001
#define DT_ORAQUE       0x0002
#define DT_CENTERX      0x0004
#define DT_CENTERY      0x0008
#define DT_LEFT         0x0010

#define SYMSIZE_X       3
#define SYMS_PER_LINE   10


typedef struct _GView {

/* Generic structure */

  void* x;

  double width,height,symSize,clipX1,clipY1,clipX2,clipY2;

  void* (*Free)(struct _GView* w);
  void (*SetMode)(struct _GView* w,int mode);
  void (*DrawLine)(struct _GView* w,double x1,double y1,double x2,double y2);
  void (*DrawText)(struct _GView* w,double x,double y,char* text,int type);
  void (*GetTextExtent)(struct _GView* w,char* text,double* px,double* py);
  void (*Clear)(struct _GView* gv,int bExposure);

/* GraphLine extensions */

  struct _GraphDlg* dlg; /* Stores GraphLines */
  double glMinX,glMinY,glMaxX,glMaxY,glW,glH,glLOff,glROff,glTOff,glBOff;
  int bLegendOn;
  
  /* Fix for the font problem */
  Font font;
}* GView;

typedef struct _GraphDlg {
  View w;
  GView gv;
  Group lines;

  pid_t calcPid;
  FILE* calcFile;
  XtIntervalId calcTimer;
  Reaction calcReaction;
  char calcTmpInputFilename[1024];

  GC gc;
  XtIntervalId updateTimer;
  Widget wDlg, wDraw, wDensity[GD_DENSITIES],wT1,wT2,wY1,wY2/*,wSwDebug*/;
  double vT1,vT2,vY1,vY2,vDensity[GD_DENSITIES];

  Pixel pxBackground,pxGrid,pxGridText,pxLegendText,pxSymbol,pxBorder,
    pxGraph1,pxGraph2,pxGraph3,pxGraph4;
  Dimension whGraph,whGrid;
  XmFontList xmfl;
  int tmRepaint,tmKill;
}* GraphDlg;

typedef struct {
  GraphDlg dlg;
  Reaction r;
  double t1,t2,d;
  struct {double x,y;} *xy;
  int numPoints,allocedPoints,dNumber,rNumber;
}* GraphLine;

#define CMT_CMD  1
#define CMT_FILE 2

typedef struct _PrintDlg {
  GraphDlg gDlg;
  Widget wDlg,wCmdType,wCommand,wWidth,wHeight,wMargin,wSwColor;
}* PrintDlg;

typedef struct _PsGViewExt {
  FILE* f;
  double orgWidth,orgHeight,orgMargin;
  double r,g,b,lw;
  int bBW;
}* PsGViewExt;

#define DLG_GRAPH "dlgGraph"
#define DLG_PRINT "dlgGraphPrint"

#define GLX2GV(gv,x) \
  (((x)-(gv)->glMinX)/((gv)->glMaxX-(gv)->glMinX)*(gv)->glW+(gv)->glLOff)
#define GLY2GV(gv,y) \
  (((y)-(gv)->glMaxY)/((gv)->glMinY-(gv)->glMaxY)*(gv)->glH+(gv)->glTOff)

/* Forward declarations */

static Widget CreateGraphDlg(View w);
static void CbGraphDlgDestroy(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbGraphDlgInput(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void DwGraphDlg(Widget wg,View w,int evt,void* obj,void* userData);
static void UpdateGraphDlg(Widget wDlg);
static void CbClearText(Widget wg,XtPointer xtpText,XtPointer pcbs);
static void CbGraphDlgExpose(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbGraphDlgResize(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbFit(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbPrint(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void RepaintGraph(GView gv);
static void AddGraphDlgUpdate(GraphDlg dlg);
static void CancelGraphDlgUpdate(GraphDlg dlg);
static void DrawGraphLine(GView gv,GraphLine gl,int mode);
static void ToGraphDlgCalc(XtPointer xtpDlg,XtIntervalId* timer);
static void SetGraphArea(GraphDlg dlg,
    double minX,double minY,double maxX,double maxY);
static Group GetDrawnReactions(GraphDlg dlg);

static GraphLine AddGraphLine(GraphDlg dlg,Reaction r,double t1,double t2,
    double d,int dNumber);
static void* DelGraphLine(GraphLine gdl);

static GView CreateGraphDlgGView(GraphDlg dlg);
static int RecalcGViewLayout(GView gv);
static void DrawSymbol(struct _GView* gv,double sx,double sy,int type);

static void CbPrintOk(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
Widget OpenPrintDlg(GraphDlg gDlg);
static GView CreatePsGView(GView gv0,double width,double height,double
    margin,int bBlackWhite);
static int PsGViewOutput(GView gv,char* fName,int fd,char* title);

static void GViewClipTo(GView gv,double x1,double y1,double x2,double y2);
static void GViewNoClip(GView gv);
static void DrawGViewLine(GView gv,double x1,double y1,double x2,double y2);


static XtResource graphDlgRes[]={
  XmNbackground,XmCBackground,XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxBackground),XmRString,"RGBi: 1/1/1",
  "graphColor1","GraphColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGraph1),XmRString,"RGBi: 0/0/0",
  "graphColor2","GraphColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGraph2),XmRString,"RGBi: 0/0/0",
  "graphColor3","GraphColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGraph3),XmRString,"RGBi: 0/0/0",
  "graphColor4","GraphColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGraph4),XmRString,"RGBi: 0/0/0",
  "gridColor","GridColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGrid),XmRString,"RGBi: 0/0/0",
  "gridTextColor","GridColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxGridText),XmRString,"RGBi: 0/0/0",
  "legendTextColor","LegendTextColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxLegendText),XmRString,"RGBi: 0/0/0",
  "symbolColor","SymbolColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxSymbol),XmRString,"RGBi: 0/0/0",
  "gridBorderColor","GridBorderColor",XmRPixel,sizeof(Pixel),
    XtOffset(GraphDlg,pxBorder),XmRString,"RGBi: 0/0/0",

  "graphWidth","GraphWidth",XmRDimension,sizeof(Dimension),
    XtOffset(GraphDlg,whGraph),XmRImmediate,(XtPointer)0,
  "gridWidth","GridWidth",XmRDimension,sizeof(Dimension),
    XtOffset(GraphDlg,whGrid),XmRImmediate,(XtPointer)0,

  "killInterval","KillInterval",XmRInt,sizeof(int),
    XtOffset(GraphDlg,tmKill),XmRImmediate,(XtPointer)100,
  "repaintInterval","RepaintInterval",XmRInt,sizeof(int),
    XtOffset(GraphDlg,tmRepaint),XmRImmediate,(XtPointer)500,

  XmNfontList,XmCFontList,XmRFontList,sizeof(XmFontList),
    XtOffset(GraphDlg,xmfl),XmRImmediate,(XtPointer)NULL,
};

/* Dialog creation */

Widget OpenGraphDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_GRAPH);
  XmString xms;
  String s;

  if (wDlg==NULL) {
    wDlg=CreateGraphDlg(w);
  } else {
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
  UpdateGraphDlg(wDlg);

  return wDlg;
}

static Widget CreateGraphDlg(View w) {
  GraphDlg dlg;
  int i;
  Widget wRC1,wF,wF2,wS0,wS1,wg;
  char s[256];
  XmString xms;

  dlg=Malloc(sizeof(*dlg));
  dlg->w=w;
  dlg->lines=CreateGroup();
  dlg->wDraw=NULL;                      /* Make Create..GView happy */
  dlg->gv=CreateGraphDlgGView(dlg);

  dlg->calcPid=0;
  dlg->calcFile=NULL;
  dlg->calcReaction=NULL;
  dlg->calcTimer=(int) NULL;
  dlg->updateTimer=(int) NULL;
  *dlg->calcTmpInputFilename=0;

  dlg->wDlg=Cw(XmCreateFormDialog,w->wMain,DLG_GRAPH,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    XmNuserData,(XtPointer)dlg,
    NULL);

  XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbGraphDlgDestroy,dlg);

  XmAddWMProtocolCallback(XtParent(dlg->wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);

  wRC1=Cmw(XmCreateRowColumn,dlg->wDlg,"rowcol0",
    XmNorientation,XmHORIZONTAL,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_FORM,
    XmNleftAttachment,XmATTACH_FORM,
    NULL);

  wS0=Cmw(XmCreateSeparator,dlg->wDlg,"sep",
    XmNorientation,XmHORIZONTAL,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wRC1,
    XmNleftAttachment,XmATTACH_FORM,
    NULL);

  CreateMenuSystem(wRC1,
    "bA:print",CbPrint,(XtPointer)dlg,
    "bA:fit",CbFit,(XtPointer)dlg,
    "bA:close",CbUnmap,NULL,
    /*"t?:debug",&dlg->wSwDebug,*/
    NULL);

  wF=Cmw(XmCreateForm,dlg->wDlg,"form1",
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wS0,
/*    XmNbottomAttachment,XmATTACH_FORM, */
    NULL);

  for (i=1;i<=GD_DENSITIES;i++) {
    xms=MakeXmString(GetResourceStringEx(dlg->wDlg,"densityLabel",
      "DensityLabel","$(NUMBER)%d",i));

    Cmw(XmCreateLabel,wF,"densityLabel",
      XmNlabelString,xms,
      XmNuserData,0x100+i,
      NULL);

    XmStringFree(xms);

    dlg->wDensity[i-1]=Cmw(XmCreateText,wF,"density",
      XmNuserData,0x200+i,
      NULL);
    XtAddCallback(dlg->wDensity[i-1],XmNvalueChangedCallback,
	CbGraphDlgInput,(void*)dlg);

    wg=Cmw(XmCreatePushButton,wF,"densityClear",
      XmNuserData,0x300+i,
      NULL);
    XtAddCallback(wg,XmNactivateCallback,CbClearText,
	(XtPointer)dlg->wDensity[i-1]);
  }

  Form2Table(wF);

  wF=Cmw(XmCreateSeparator,dlg->wDlg,"sep",
    XmNorientation,XmVERTICAL,
    XmNrightAttachment,XmATTACH_WIDGET,
    XmNrightWidget,wF,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wS0,
    XmNbottomAttachment,XmATTACH_FORM,
    NULL);

  wF2=Cmw(XmCreateForm,dlg->wDlg,"form2",
    /*XmNpacking,XmPACK_TIGHT,
    XmNorientation,XmHORIZONTAL, */

    XmNrightAttachment,XmATTACH_WIDGET,
    XmNrightWidget,wF,
    XmNbottomAttachment,XmATTACH_FORM,
    XmNleftAttachment,XmATTACH_FORM,
    NULL);

  CreateMenuSystem(wF2,
    "l@:t1Label",0x0101,
    "x@?T:t1",0x0201,&dlg->wT1,CbGraphDlgInput,dlg,
    "l@:t2Label",0x0301,
    "x@?T:t2",0x0401,&dlg->wT2,CbGraphDlgInput,dlg,
    "l@:y1Label",0x0102,
    "x@?T:y1",0x0202,&dlg->wY1,CbGraphDlgInput,dlg,
    "l@:y2Label",0x0302,
    "x@?T:y2",0x0402,&dlg->wY2,CbGraphDlgInput,dlg,
    NULL);

  Form2Table(wF2);

  wS1=Cmw(XmCreateSeparator,dlg->wDlg,"rowcol",
    XmNpacking,XmPACK_TIGHT,
    XmNorientation,XmHORIZONTAL,

    XmNrightAttachment,XmATTACH_WIDGET,
    XmNrightWidget,wF,
    XmNbottomAttachment,XmATTACH_WIDGET,
    XmNbottomWidget,wF2,
    XmNleftAttachment,XmATTACH_FORM,
    NULL);

  wg=Cmw(XmCreateFrame,dlg->wDlg,"drawFrame",
    XmNrightAttachment,XmATTACH_WIDGET,
    XmNrightWidget,wF,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wS0,
    XmNbottomAttachment,XmATTACH_WIDGET,
    XmNbottomWidget,wS1,
    XmNleftAttachment,XmATTACH_FORM,
    NULL);

  dlg->wDraw=Cmw(XmCreateDrawingArea,wg,"draw",
    NULL);

  XtGetApplicationResources(dlg->wDraw,dlg,
    graphDlgRes,XtNumber(graphDlgRes),NULL,0);

  XtAddCallback(dlg->wDraw,XmNresizeCallback,CbGraphDlgResize,dlg);
  XtAddCallback(dlg->wDlg,XmNmapCallback,CbGraphDlgResize,dlg);
  XtAddCallback(dlg->wDraw,XmNexposeCallback,CbGraphDlgExpose,dlg);
  XtManageChild(dlg->wDlg);

  dlg->gc=XCreateGC(XtDisplay(dlg->wDraw),XtWindow(dlg->wDraw),0L,NULL);

  AddDependentWidget(w,dlg->wDlg,N_NOW|N_SEL|N_ALT,DwGraphDlg,(void*)dlg);

  /* if (dlg->xmfl==NULL) */ /* - Why did I cmnt that out? Was it an attempt
                                  to fix the problem with fonts? $$$ */
    GetValues(XtParent(dlg->wDlg),XmNlabelFontList,&dlg->xmfl,NULL);
  assert(dlg->xmfl!=NULL);

  return dlg->wDlg;
}

/* Callbacks/Dependencies/Timeouts */

static void CbGraphDlgResize(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  Dimension wh,h;
  GraphDlg dlg=(GraphDlg)xtpDlg;

  GetValues(dlg->wDraw,
    XmNwidth,&wh,
    XmNheight,&h,
    NULL);

  dlg->gv->width=wh;
  dlg->gv->height=h;

  if (!XtIsRealized(dlg->wDraw)) return;

  dlg->gv->Clear(dlg->gv,True);
}

static void CbGraphDlgExpose(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  GraphDlg dlg=(GraphDlg)xtpDlg;

  CancelGraphDlgUpdate(dlg);
  RepaintGraph(dlg->gv);
}

static void CbClearText(Widget wg,XtPointer xtpText,XtPointer pcbs) {
  Widget wText=(Widget)xtpText;

  XmTextSetString(wText,"");
}

static void CbGraphDlgDestroy(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  GraphDlg dlg=(GraphDlg)xtpDlg;
  GraphLine gl;
  Index ix;

  /* 2000-12-07 Fix for the font problem */
  if (dlg->gv->font!=(Font)NULL) {
    XUnloadFont(XtDisplay(dlg->wDlg),dlg->gv->font);
    dlg->gv->font=(int) NULL;
  }
  
  for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix))
    DelGraphLine(gl);

  if (dlg->calcFile!=NULL) fclose(dlg->calcFile);
  if (dlg->calcTimer!=(int) NULL) XtRemoveTimeOut(dlg->calcTimer);
  if (dlg->updateTimer!=(int) NULL) XtRemoveTimeOut(dlg->updateTimer);

  XFreeGC(XtDisplay(dlg->wDraw),dlg->gc);

  FreeGroup(dlg->lines);

  dlg->gv->Free(dlg->gv);

  Free(dlg);
}

static void CbGraphDlgInput(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  GraphDlg dlg=(GraphDlg)xtpDlg;

  if (IsMapped(dlg->wDlg)) UpdateGraphDlg(dlg->wDlg);
}

void DwGraphDlg(Widget wg,View w,int evt,void* obj,void* userData) {
  GraphDlg dlg=(GraphDlg)userData;

  if (IsMapped(dlg->wDlg)) UpdateGraphDlg(dlg->wDlg);
}

static void ToGraphDlgCalc(XtPointer xtpDlg,XtIntervalId* timer) {
  GraphDlg dlg=(GraphDlg)xtpDlg;
  int statusLocation;

  waitpid(dlg->calcPid,&statusLocation,WNOHANG);

  if (kill(dlg->calcPid,0)==-1) {
    dlg->calcTimer=(XtIntervalId)NULL;
    dlg->calcPid=0;
    UpdateGraphDlg(dlg->wDlg);
    return;
  }

  dlg->calcTimer=XtAppAddTimeOut(XtWidgetToApplicationContext(dlg->wDraw),
      dlg->tmKill,ToGraphDlgCalc,(XtPointer)dlg);
}

static void ToRepaintGraphDlg(XtPointer xtpDlg,XtIntervalId* timer) {
  GraphDlg dlg=(GraphDlg)xtpDlg;

  dlg->updateTimer=(int) NULL;
  if (!dlg->calcPid) RepaintGraph(dlg->gv); else AddGraphDlgUpdate(dlg);
}

/* Repaint procedures */

static void AddGraphDlgUpdate(GraphDlg dlg) {
  CancelGraphDlgUpdate(dlg);

  dlg->updateTimer=XtAppAddTimeOut(XtWidgetToApplicationContext(dlg->wDraw),
      dlg->tmRepaint,ToRepaintGraphDlg,(XtPointer)dlg);
}

static void CancelGraphDlgUpdate(GraphDlg dlg) {
  if (dlg->updateTimer!=(int) NULL) {
    XtRemoveTimeOut(dlg->updateTimer);
    dlg->updateTimer=(int) NULL;
  }
}

static void DrawLegend(GView gv,int bDraw) {
  Group g;
  GraphLine gl;
  Reaction r;
  double tw,th,ty0;
  char s[255];
  Index ix;
  int i,j;

  if (!bDraw && !gv->bLegendOn) return;
  gv->bLegendOn=bDraw;

  g=GetDrawnReactions(gv->dlg);
  gv->GetTextExtent(gv,"X",&tw,&th);
  ty0=max(0,(gv->height-th*GD_DENSITIES)/2);

  /* Display densities */

  for (j=i=0;i<GD_DENSITIES;i++) {
    for (gl=Group1st(gv->dlg->lines,&ix);gl!=NULL;gl=Next(&ix))
      if (gl->dNumber==i) goto found;
    continue;

    found:

    gv->SetMode(gv,bDraw? VM1_GRAPHSYMS : VM0_GRAPHSYMS);
    DrawSymbol(gv,GLX2GV(gv,gv->glMaxX)+tw/2,
      ty0+th*j+th/2,i);

    sprintf(s,"%1.2E",gl->d);
    gv->SetMode(gv,bDraw? VM1_LEGENDTEXT:VM0_LEGENDTEXT);
    gv->DrawText(gv,GLX2GV(gv,gv->glMaxX)+tw,
	ty0+th*j,s,
	0/*DT_ORAQUE*/);
    j++;
  }

  /* Display reactions */

  for (i=0;i<GroupCount(g);i++) {
    r=GroupAt(g,i);
    gv->SetMode(gv,bDraw? VM1_GRAPHLINE+i%GLVMCOUNT : VM0_GRAPHLINE);
    gv->DrawText(gv,GLX2GV(gv,gv->glMinX),i*th,r->name,0);
  }

  FreeGroup(g);
}

static void RepaintGraph(GView gv) {
  GraphLine gl;
  Index ix;
  double f;
  char s[255];

  if (RecalcGViewLayout(gv)) gv->Clear(gv,False);

  for (f=ceil(gv->glMinX);f<gv->glMaxX;f+=1) {
    gv->SetMode(gv,VM_GRIDLINE);
    DrawGViewLine(gv,GLX2GV(gv,f),GLY2GV(gv,gv->glMinY),
	GLX2GV(gv,f),GLY2GV(gv,gv->glMaxY));
  }

  for (f=ceil(gv->glMinY);f<gv->glMaxY;f+=1) {
    gv->SetMode(gv,VM_GRIDLINE);
    DrawGViewLine(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,f),
	GLX2GV(gv,gv->glMaxX),GLY2GV(gv,f));
  }

  gv->SetMode(gv,VM_BORDER);

  DrawGViewLine(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,gv->glMinY),
      GLX2GV(gv,gv->glMinX),GLY2GV(gv,gv->glMaxY));
  DrawGViewLine(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,gv->glMinY),
      GLX2GV(gv,gv->glMaxX),GLY2GV(gv,gv->glMinY));
  DrawGViewLine(gv,GLX2GV(gv,gv->glMaxX),GLY2GV(gv,gv->glMinY),
      GLX2GV(gv,gv->glMaxX),GLY2GV(gv,gv->glMaxY));
  DrawGViewLine(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,gv->glMaxY),
      GLX2GV(gv,gv->glMaxX),GLY2GV(gv,gv->glMaxY));

  for (gl=Group1st(gv->dlg->lines,&ix);gl!=NULL;gl=Next(&ix))
    DrawGraphLine(gv,gl,True);

  for (f=floor(gv->glMinX+1);f<gv->glMaxX;f+=1) {
    sprintf(s,"E%g",f);
    gv->SetMode(gv,VM_GRIDTEXT);
    gv->DrawText(gv,GLX2GV(gv,f),GLY2GV(gv,gv->glMinY),s,
	DT_CENTERX/*|DT_ORAQUE*/);
  }

  for (f=floor(gv->glMinY+1);f<gv->glMaxY;f+=1) {
    sprintf(s,"E%g",f);
    gv->SetMode(gv,VM_GRIDTEXT);
    gv->DrawText(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,f),s,
	DT_CENTERY|/*DT_ORAQUE|*/DT_LEFT);
  }

  DrawLegend(gv,True);
}

/* GraphLine */

static GraphLine AddGraphLine(GraphDlg dlg,Reaction r,double t1,double t2,
    double d,int dNumber) {
  GraphLine gdl;

  gdl=Malloc(sizeof(*gdl));
  gdl->dlg=dlg;
  gdl->r=r;
  gdl->t1=t1;
  gdl->t2=t2;
  gdl->d=d;
  gdl->dNumber=dNumber;
  gdl->rNumber=0;

  gdl->numPoints=0;
  gdl->xy=Malloc(sizeof(*gdl->xy)*(gdl->allocedPoints=1));

  DrawLegend(dlg->gv,False);
  GroupAdd(dlg->lines,gdl);
  AddGraphDlgUpdate(dlg);

  return gdl;
}

static void* DelGraphLine(GraphLine gl) {
  DrawGraphLine(gl->dlg->gv,gl,False);
  DrawLegend(gl->dlg->gv,False);
  AddGraphDlgUpdate(gl->dlg);

  GroupDel(gl->dlg->lines,gl);

  Free(gl->xy);
  Free(gl);

  return NULL;
}

int ReadGraphDlgLines(Group lines,FILE* f) {
  GraphLine gl;
  Index ix;
  char s[256];
  double x,y;

  while (1) {
    if (fgets(s,sizeof(s)-1,f)==NULL) return -1;
    if (!strcasecmp(s,"# start of data\n")) goto found;
  }
  return -1;

  found:

  while (1) {
    if (fscanf(f,"%lf",&x)!=1) break;
    for (gl=Group1st(lines,&ix);gl!=NULL;gl=Next(&ix)) {
      if (fscanf(f,"%lf",&y)!=1) break;

      gl->xy[gl->numPoints].x=log10(x);
      gl->xy[gl->numPoints].y=log10(y);
      
      if (++gl->numPoints>=gl->allocedPoints)
	gl->xy=Realloc(gl->xy,sizeof(*gl->xy)*
	    (gl->allocedPoints+=GDL_ALLOCINCR));
    }
  }

  for (gl=Group1st(lines,&ix);gl!=NULL;gl=Next(&ix))
    DrawGraphLine(gl->dlg->gv,gl,True);

  return 0;
}

static void DrawGraphLine(GView gv,GraphLine gl,int mode) {
  Pixel pix;
  int i,n;

  GViewClipTo(gv,GLX2GV(gv,gv->glMinX),GLY2GV(gv,gv->glMinY),
      GLX2GV(gv,gv->glMaxX),GLY2GV(gv,gv->glMaxY));

  gv->SetMode(gv,mode? VM1_GRAPHLINE+gl->rNumber%GLVMCOUNT
      : VM0_GRAPHLINE);

  for (i=0;i<gl->numPoints-1;i++)
    DrawGViewLine(gv,GLX2GV(gv,gl->xy[i].x),GLY2GV(gv,gl->xy[i].y),
	GLX2GV(gv,gl->xy[i+1].x),GLY2GV(gv,gl->xy[i+1].y));

  n=gl->numPoints/SYMS_PER_LINE+1;

  gv->SetMode(gv,mode? VM1_GRAPHSYMS : VM0_GRAPHSYMS);

  for (i=0;i<gl->numPoints;i++) if (i%n==n/2)
    DrawSymbol(gv,GLX2GV(gv,gl->xy[i].x),GLY2GV(gv,gl->xy[i].y),
	gl->dNumber);

  GViewNoClip(gv);
}

static Group GetDrawnReactions(GraphDlg dlg) {
  Group g;
  GraphLine gl;
  Index ix;

  g=CreateGroup();
  for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix))
    if (!InGroup(g,gl->r)) GroupAdd(g,gl->r);

  return g;
}

void UpdateGraphDlg(Widget wDlg) {
  GraphLine gl;
  Reaction r;
  Group g;
  ReactionType rt;
  Index ix,ixr;
  GraphDlg dlg;
  XtPointer xtpDlg;
  int i,j;
  char* args[GD_DENSITIES+7], *dirStr,*cmdStr;
  
  FILE* f_tmp;
  Index ixv;
  VarDef vd;


  GetValues(wDlg,XmNuserData,&xtpDlg,NULL);
  dlg=(GraphDlg)xtpDlg;

  /* Calculation running? Exit if so */

  if (dlg->calcPid!=0) return;

  /* Calculation just ended? Display curves */

  if (dlg->calcFile!=NULL) {
    fseek(dlg->calcFile,0,SEEK_SET);

    /*if (XmToggleButtonGetState(dlg->wSwDebug)) {
      puts("*** Child process return");
      while ((i=getc(dlg->calcFile))!=EOF) {
	putchar(i);
       }
      puts("^^^");
    } else */ {
      for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix))
	if (gl->r==dlg->calcReaction) DelGraphLine(gl);

      g=CreateGroup();
      for (i=0;i<GD_DENSITIES;i++) if (dlg->vDensity[i]!=V_NONE) GroupAdd(g,
	  AddGraphLine(dlg,dlg->calcReaction,
	  dlg->vT1,dlg->vT2,dlg->vDensity[i],i));

      ReadGraphDlgLines(g,dlg->calcFile);
      FreeGroup(g);

    }
    fclose(dlg->calcFile);
    dlg->calcFile=NULL;
    dlg->calcReaction=NULL;
  }

  /* Get selected reactions and read values of text widgets */

  dlg->vT1=GetXmTextDouble(dlg->wT1);
  dlg->vT2=GetXmTextDouble(dlg->wT2);
  dlg->vY1=GetXmTextDouble(dlg->wY1);
  dlg->vY2=GetXmTextDouble(dlg->wY2);

  for (i=0;i<GD_DENSITIES;i++)
    dlg->vDensity[i]=GetXmTextDouble(dlg->wDensity[i]);

  g=GetSelectedReactions(dlg->w);

  /* Change area displayed if needed */

  if (dlg->vT1!=V_NONE && dlg->vT1>0 && dlg->vT2!=V_NONE && dlg->vT2>0 &&
      dlg->vY1!=V_NONE && dlg->vY1>0 && dlg->vY2!=V_NONE && dlg->vY2>0)
    SetGraphArea(dlg,log10(dlg->vT1),log10(dlg->vY1),
	log10(dlg->vT2),log10(dlg->vY2));

  /* Remove unneeded GraphLines */

  for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix)) {
    if (!InGroup(g,gl->r) || gl->t1!=dlg->vT1 || gl->t2!=dlg->vT2 ||
	gl->d!=dlg->vDensity[gl->dNumber]) DelGraphLine(gl);
  }

  if (dlg->vT1==V_NONE || dlg->vT2==V_NONE) return;

  /* Look for needed but not present GraphLines */

  for (r=Group1st(g,&ixr);r!=NULL;r=Next(&ixr)) {
    for (i=0;i<GD_DENSITIES;i++) if (dlg->vDensity[i]!=V_NONE) {
      for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix)) {
	if (dlg->vT1==gl->t1 && dlg->vT2==gl->t2 &&
	    dlg->vDensity[i]==gl->d && r==gl->r) goto Found;
      }
      goto CalculateIt;
      Found:;
    }
  }

  return; /* Everything needed is present */

  CalculateIt:

  dlg->calcFile=tmpfile();
  if (dlg->calcFile==NULL) {
    fprintf(stderr,"amds: tmpfile() failed\n");
    return;
  }
  setvbuf(dlg->calcFile,NULL,_IONBF,0);

  dlg->calcReaction=r;

  dlg->calcPid=fork();
  if (dlg->calcPid==-1) {
    fprintf(stderr,"amds: fork() failed\n");
    return;
  }

  dirStr=getenv(ENV_DIR);
  if (dirStr==NULL) dirStr=GetResourceString(dlg->w->xapp->wShell,
      "graphDir","GraphDir",".");
  cmdStr=getenv(ENV_CMD);
  if (cmdStr==NULL) cmdStr=GetResourceString(dlg->w->xapp->wShell,
      "graphCmd","GraphCmd","./calc_atomic_data");

  /*** Code for the CHILD PROCESS */

  if (dlg->calcPid==0) { /* CHILD PROCESS */

    /* Begin 2000-12-07 store reaction vars into the file */
    
    sprintf(dlg->calcTmpInputFilename,"/tmp/amds_%d_graph_input.dat",(int)getpid());
    f_tmp=fopen(dlg->calcTmpInputFilename,"w");
    if (f_tmp==NULL) {
      fprintf(stderr,"amds: Error writing %s. Cannot calculate reaction data\n",
          dlg->calcTmpInputFilename);
      return;
    }

    for (vd=Group1st(dlg->w->subset->varDefs,&ixv);vd!=NULL;vd=Next(&ixv)) {
puts(GetVarDefName(vd));
      if (vd->flags & VDF_REACTIONS) {
        fprintf(f_tmp,"%s\n",GetVarDefName(vd));
	fprintf(f_tmp,"%s\n",GetReactionVar(dlg->w->subset,r,vd));
      }
    }
    fclose(f_tmp);
    
    freopen(dlg->calcTmpInputFilename,"r",stdin);
    unlink(dlg->calcTmpInputFilename);
    
    /* End 2000-12-07 */
    
    for (i=0;i<7;i++) args[i]=Malloc(256);

    j=0;
    strcpy(args[j++],"./calc_atomic_data"); //??? Should be taken from a variable
    strcpy(args[j++],GetReactionDatabase(r));
    strcpy(args[j++],GetReactionSection(r));
    strcpy(args[j++],GetReactionNumber(r));

    rt=Group1st(r->types,NULL);
    strcpy(args[j++],rt==NULL? "??" : rt->name);
    sprintf(args[j++],"%e",dlg->vT1);
    sprintf(args[j++],"%e",dlg->vT2);

    for (i=0;i<GD_DENSITIES;i++) if (dlg->vDensity[i]!=V_NONE) {
      args[j]=Malloc(256);
      sprintf(args[j++],"%e",dlg->vDensity[i]);
    }
    args[j]=NULL;

    assert(dup2(fileno(dlg->calcFile),1)!=-1);

    if (chdir(dirStr)==-1) {
      fprintf(stderr,"amds: Cannot chdir to %s\n",dirStr);
      exit(1);
    }
    execv(cmdStr,args);
    fprintf(stderr,"amds: Cannot execute %s\n",cmdStr);
    exit(1);
  } /* END CHILD PROCESS */

  /*** End of the code for the CHILD PROCESS */

  ToGraphDlgCalc((XtPointer)dlg,NULL);
}

static void SetGraphArea(GraphDlg dlg,
    double minX,double minY,double maxX,double maxY) {

  if (minX==dlg->gv->glMinX && minY==dlg->gv->glMinY &&
      maxX==dlg->gv->glMaxX && maxY==dlg->gv->glMaxY) return;
  if (minX==maxX) return;
  if (minY==maxY) return;

  dlg->gv->glMinX=minX;
  dlg->gv->glMinY=minY;
  dlg->gv->glMaxX=maxX;
  dlg->gv->glMaxY=maxY;

  if (!XtIsRealized(dlg->wDraw)) return;

  dlg->gv->Clear(dlg->gv,True);
}

static void CbFit(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  GraphDlg dlg=(GraphDlg)xtpDlg;
  GraphLine gl;
  Index ix;
  int i;
  double y1=MAXDOUBLE,y2=-MAXDOUBLE;
  char s[255];

  for (gl=Group1st(dlg->lines,&ix);gl!=NULL;gl=Next(&ix)) {
    for (i=0;i<gl->numPoints;i++) {
      y1=min(y1,gl->xy[i].y);
      y2=max(y2,gl->xy[i].y);
    }
  }

  if (y1>y2) {y1=-20;y2=-10;}
  if (y1==y2) {y1-=1;y2+=1;}

  y1=pow(10,y1);
  y2=pow(10,y2);

  sprintf(s,"%1.2e",y1);XmTextSetString(dlg->wY1,s);
  sprintf(s,"%1.2e",y2);XmTextSetString(dlg->wY2,s);
}

static void CbPrint(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  GraphDlg dlg=(GraphDlg)xtpDlg;

  OpenPrintDlg(dlg);
}

/*** GraphDlgGView */

static void* GDV_Free(struct _GView* w) {
  Free(w);

  return NULL;
}

/* GraphDlgGView */

static void GDV_SetMode(struct _GView* w,int mode) {
  GraphDlg dlg=(GraphDlg)w->x;
  Pixel fg;

  if (!XtIsRealized(dlg->wDraw)) return;

  switch(mode) {
    case VM0_GRAPHLINE:
    case VM0_GRAPHSYMS:
    case VM0_LEGENDTEXT:
      fg=dlg->pxBackground;
      break;
    case VM1_GRAPHLINE:
      fg=dlg->pxGraph1;
      break;
    case VM2_GRAPHLINE:
      fg=dlg->pxGraph2;
      break;
    case VM3_GRAPHLINE:
      fg=dlg->pxGraph3;
      break;
    case VM4_GRAPHLINE:
      fg=dlg->pxGraph4;
      break;
    case VM_GRIDLINE:
      fg=dlg->pxGrid;
      break;
    case VM_GRIDTEXT:
      fg=dlg->pxGridText;
      break;
    case VM1_LEGENDTEXT:
      fg=dlg->pxLegendText;
      break;
    case VM1_GRAPHSYMS:
      fg=dlg->pxSymbol;
      break;
    case VM_BORDER:
      fg=dlg->pxBorder;
      break;
    default:
      assert(0);
      break;
  }
  XSetForeground(XtDisplay(dlg->wDraw),dlg->gc,fg);
}

static void GDV_DrawLine(struct _GView* w,double x1,double y1,
    double x2,double y2) {
  GraphDlg dlg=(GraphDlg)w->x;

  if (!XtIsRealized(dlg->wDraw)) return;

  XDrawLine(XtDisplay(dlg->wDraw),XtWindow(dlg->wDraw),dlg->gc,
     (int)x1,(int)y1,(int)x2,(int)y2);
}

static void GDV_DrawText(struct _GView* w,double x,double y,
    char* text,int flags) {
  GraphDlg dlg=(GraphDlg)w->x;
  XmString xms=NULL;
  Dimension dx,dy;

  if (!XtIsRealized(dlg->wDraw)) return;

  /* 2000-12-07 Fix for the font problem */
  if (w->font==(Font)NULL) {
    w->font=XLoadFont(XtDisplay(dlg->wDraw),
        "-*-*-medium-r-*-*-*-140-*-*-c-*-*-1"); /* $$$ */
    if (w->font!=(Font)NULL) XSetFont(XtDisplay(dlg->wDraw),dlg->gc,w->font);
  }
  
  xms=MakeXmString(text);

  XmStringExtent(dlg->xmfl,xms,&dx,&dy);
  if (flags & DT_CENTERX) dx/=2;
  else if (flags & DT_LEFT);
  else dx=0;

  if (flags & DT_CENTERY) dy/=2;
  else if (!(flags & DT_ABOVE)) dy=0;

  if (flags & DT_ORAQUE) {
    XmStringDrawImage(XtDisplay(dlg->wDraw),XtWindow(dlg->wDraw),dlg->xmfl,
      xms,dlg->gc,(int)x-dx,(int)y-dy,0,XmALIGNMENT_BEGINNING,
      0,NULL);
  } else {
    XmStringDraw(XtDisplay(dlg->wDraw),XtWindow(dlg->wDraw),dlg->xmfl,
      xms,dlg->gc,(int)x-dx,(int)y-dy,0,XmALIGNMENT_BEGINNING,
      0,NULL);
  }

  XmStringFree(xms);xms=NULL;
}

static void GDV_GetTextExtent(GView w,char* text,double* px,double* py) {
  GraphDlg dlg=(GraphDlg)w->x;
  XmString xms=NULL;
  Dimension dx,dy;

  if (dlg->wDraw==NULL || !XtIsRealized(dlg->wDraw)) {
    dx=dy=1;
  } else {
    xms=MakeXmString(text);
    XmStringExtent(dlg->xmfl,xms,&dx,&dy);
    XmStringFree(xms);xms=NULL;
  }

  if (px!=NULL) *px=(double)dx;
  if (py!=NULL) *py=(double)dy;
}

static void GDV_Clear(struct _GView* gv,int bExpose) {
  GraphDlg dlg=(GraphDlg)gv->dlg;

  if (dlg->wDraw==NULL || !XtIsRealized(dlg->wDraw)) return;

  XClearArea(XtDisplay(dlg->wDraw),XtWindow(dlg->wDraw),0,0,0,0,bExpose);
}

static GView CreateGraphDlgGView(GraphDlg dlg) {
  GView gv;

  gv=Malloc(sizeof(*gv));
  gv->dlg=dlg;

  gv->x=(void*)dlg;
  gv->Free=GDV_Free;
  gv->SetMode=GDV_SetMode;
  gv->DrawLine=GDV_DrawLine;
  gv->DrawText=GDV_DrawText;
  gv->GetTextExtent=GDV_GetTextExtent;
  gv->Clear=GDV_Clear;

  gv->width=gv->height=1;
  gv->symSize=SYMSIZE_X;
  GViewNoClip(gv);

  gv->glMinX=gv->glMinY=gv->glMaxX=gv->glMaxY=0;
  gv->bLegendOn=0;
  
  gv->font=(Font)NULL;

  RecalcGViewLayout(gv);

  return gv;
}

#define GVL_HASH(a,b,c,d,e,f,g,h,i,j) \
(445*a+8450*b+4251*c+8126*d+383*e+849*f+3478*g+11787*h+11727*i+414*j)

static int RecalcGViewLayout(GView gv) { /* Returns 1 if layout changed */
  double w,h,h1,h2;
  GraphLine gl;
  Group g;
  Index ix;

  g=GetDrawnReactions(gv->dlg);
  h1=GVL_HASH(gv->width,gv->height,gv->glLOff,gv->glROff,
      gv->glTOff,gv->glBOff,gv->glMinX,gv->glMinY,gv->glMaxX,gv->glMaxY);

  /* Recalculate colors of GraphLines */

  for (gl=Group1st(gv->dlg->lines,&ix);gl!=NULL;gl=Next(&ix)) {
    gl->rNumber=GroupIndex(g,gl->r);
  }

  /* Recalculate margins etc */

  gv->glTOff=gv->glBOff=gv->glLOff=gv->glROff=0;

  gv->GetTextExtent(gv,TEX_TOP,NULL,&gv->glTOff);
  gv->glTOff*=(0.5+GroupCount(g));

  gv->GetTextExtent(gv,TEX_LEFT,&gv->glLOff,NULL);
  gv->GetTextExtent(gv,TEX_BOTTOM,NULL,&gv->glBOff);
  if (!IsEmptyGroup(g)) gv->GetTextExtent(gv,TEX_RIGHT,&gv->glROff,NULL);

  gv->glW=gv->width-gv->glLOff-gv->glROff;
  gv->glH=gv->height-gv->glTOff-gv->glBOff;

  /* Clean-up */

  g=FreeGroup(g);
  h2=GVL_HASH(gv->width,gv->height,gv->glLOff,gv->glROff,
      gv->glTOff,gv->glBOff,gv->glMinX,gv->glMinY,gv->glMaxX,gv->glMaxY);

  return h1!=h2;
}


/* PostScript */

Widget OpenPrintDlg(GraphDlg gDlg) {
  PrintDlg dlg;
  Widget wDlg,wg;
/*  char s[DG_FNAME_LEN]; */

  wDlg=XtNameToWidget(gDlg->wDlg,"*"DLG_PRINT);
  if (wDlg!=NULL) {
/*    ResetFilePrintDlg(wDlg); */
    XtPopup(XtParent(wDlg),XtGrabNone);
  } else {
    dlg=Malloc(sizeof(*dlg));
    dlg->gDlg=gDlg;

    wDlg=dlg->wDlg=Cw(XmCreateMessageDialog,dlg->gDlg->wDlg,DLG_PRINT,
      XmNautoUnmanage,False,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNuserData,dlg,
      NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

    XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbFree,dlg);
    XtAddCallback(dlg->wDlg,XmNokCallback,CbPrintOk,dlg);
    XtAddCallback(dlg->wDlg,XmNcancelCallback,CbUnmap,NULL);

    XmAddWMProtocolCallback(XtParent(wDlg),gDlg->w->xapp->wm_del_window,
      CbUnmap,NULL);
    /*XtAddCallback(wDlg,XmNhelpCallback,CbHelp,(XtPointer)w);*/

    wg=Cmw(XmCreateForm,dlg->wDlg,"form",
      XmNautoUnmanage,False,
      NULL);

    CreateMenuSystem(wg,
      "*:cmdTypeMenu",
      "O@?:cmdType",0x0101,&dlg->wCmdType,
      "b@:file",CMT_FILE,
      "b@:cmd",CMT_CMD,
      "-:",
      "x@?:command",0x0201,&dlg->wCommand,
      "s@:separator",0x0002,
      "l@:widthLabel",0x0103,
      "x@?:width",0x0203,&dlg->wWidth,
      "l@:heightLabel",0x0104,
      "x@?:height",0x0204,&dlg->wHeight,
      "l@:marginLabel",0x0105,
      "x@?:margin",0x0205,&dlg->wMargin,
      "t@?:color",0x0006,&dlg->wSwColor,
    NULL);

/*    XmTextSetString(dlg->wWidth,"8.5");
    XmTextSetString(dlg->wHeight,"11.5");
    XmTextSetString(dlg->wMargin,"0.5"); */

    XtManageChild(dlg->wDlg);
    Form2Table(wg);
    /*ResetFilePrintDlg(wDlg);*/
  }

  return wDlg;
}

static void CbPrintOk(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  PrintDlg dlg=(PrintDlg)xtpDlg;
  GView psGV;
  char buf[1024];
  char* s,*title=NULL;
  double width,height,margin;
  int r,fd[2],bBW;

/* Parse parameters */

  width=GetXmTextDouble(dlg->wWidth);
  if (width==V_NONE) {
    ErrorBox(dlg->wDlg,"Bad width");
    return;
  }

  height=GetXmTextDouble(dlg->wHeight);
  if (height==V_NONE) {
    ErrorBox(dlg->wDlg,"Bad height");
    return;
  }

  margin=GetXmTextDouble(dlg->wMargin);
  if (margin==V_NONE) {
    ErrorBox(dlg->wDlg,"Bad margin");
    return;
  }

  bBW=!XmToggleButtonGetState(dlg->wSwColor);

/* Create a PostScript GView */

  psGV=CreatePsGView(dlg->gDlg->gv,width*72,height*72,margin*72,bBW);
  if (psGV==NULL) {
    ErrorBox(dlg->wDlg,"Invalid size");
    return;
  }


/* Get filename/command */

  s=XmTextGetString(dlg->wCommand);

  switch((int)GetOptionMenuValue(dlg->wCmdType)) {
    case CMT_FILE:
      r=PsGViewOutput(psGV,s,-1,title);
      break;
    case CMT_CMD:
      if (pipe(fd)) {
	r=-1;
	break;
      }

      switch(fork()) { /* Create a child process to receive PS data */
	case -1:       /* fork failed - error */
	  close(fd[0]);
	  close(fd[1]);
	  r=-1;
	  goto break_outer;

	case 0:        /* We are child process now - run command */
	  close(fd[1]);
	  dup2(fd[0],0);
	  system(s);
	  while (getchar()!=EOF); /* Avoid 'broken pipe' errors */
	  exit(0);     /* Exit when the command finishes */
      }

      close(fd[0]);    /* We are still the parent process */

      r=PsGViewOutput(psGV,NULL,fd[1],title);
      if (r) close(fd[1]);
  }

  if (r) {
    ErrorBox(dlg->wDlg,"Output error");
  } else {
    XtPopdown(XtParent(dlg->wDlg));
/*    ViewMsgEx(w,MSG_FILEPRINTED,NULL); */
  }

  break_outer:
  XtFree(s);
  /* SetViewApp(psW,NULL); */
  psGV->Free(psGV);
}

/* PsGView */

static int PsGViewOutput(GView gv,char* fName,int fd,char* title) {
  PsGViewExt x=(PsGViewExt)gv->x;

  assert(x->f==NULL);

  if (fName!=NULL) x->f=fopen(fName,"w");
  else x->f=fdopen(fd,"w");

  if (x->f==NULL) return -1;

  fprintf(x->f,
    "%%!PS-Adobe-3.0\n"
    "%%%%BoundingBox: %g %g %g %g\n"
    "%%%%Creator: amds version %g\n"
    "%%%%Pages: %d\n"
    "%%%%EndComments\n",
    x->orgMargin,x->orgMargin,
    x->orgMargin+gv->width,x->orgMargin+gv->height,
    AMDS_VERSION/100.0,
    1
  );

  fprintf(x->f,
    "%%%%Page: %d %d\n"
    "%%%%BeginPageSetup\n"
    "1 setlinecap\n"
    "%g %g translate\n"
    /*"1 -1 scale\n" */
    "%g %g moveto\n"
    "%g %g lineto\n"
    "%g %g lineto\n"
    "%g %g lineto\n"
    "closepath\n"
/*    "0.8 setgray\n"
    "fill\n"
    "0 setgray\n" */
    "clip\n"
    "newpath\n"

    "%%%%EndPageSetup\n",
    1,1,
    (double)x->orgMargin/*+gv->width*/,
    (double)x->orgMargin/*+gv->height*/,
    0.0,0.0,
    0.0,gv->height,
    gv->width,gv->height,
    gv->width,0.0
  );
/*
  fprintf(w->x->f,
    "0 setgray\n"
    "4 setlinewidth\n"
    "%g %g moveto\n"
    "%g %g lineto\n"
    "%g %g lineto\n"
    "%g %g lineto\n"
    "%g %g lineto\n"
    "%g %g moveto\n"
    "stroke\n"
    "1 setgray\n"
    "/Times-Roman findfont\n"
    "4 scalefont\n"
    "setfont\n"
    "(  XDivGeo  ) show\n"
    "stroke\n",
    (float)w->width,(float)0,
    (float)w->width,(float)w->height,
    (float)0,(float)w->height,
    (float)0,(float)0,
    (float)w->width,(float)0,
    (float)0,(float)0
  );
*/
  RepaintGraph(gv);

  fprintf(x->f,
    "showpage\n"
  );

  fprintf(x->f,
    "%%%%EOF\n"
  );

  fclose(x->f);

  x->f=NULL;

  return 0;
}

static void* PSV_Free(GView gv) {
  PsGViewExt x=(PsGViewExt)gv->x;

  assert(x->f==NULL);
  Free(gv->x);
  Free(gv);

  return NULL;
}

static void ApplyPsGViewMode(GView gv) {
  PsGViewExt x=(PsGViewExt)gv->x;

  assert(x->f!=NULL);

  fprintf(x->f,
/*    "0 setgray\n" */
    "%g %g %g setrgbcolor\n"
    "%g setlinewidth\n",
    x->r,x->g,x->b,
    x->lw
  );
}

static void PSV_Clear(GView gv,int bExpose) {
/*  assert(0); */
}

static void PSV_DrawLine(GView gv,double x1,double y1,double x2,double y2) {
  PsGViewExt x=(PsGViewExt)gv->x;

  assert(x->f!=NULL);

  ApplyPsGViewMode(gv);
  fprintf(x->f,
    "%g %g moveto\n"
    "%g %g lineto\n"
    "stroke\n"
  ,x1,gv->height-y1,x2,gv->height-y2);
}

static void PSV_DrawText(GView gv,double x1,double y1,char* text,int flags){
  PsGViewExt x=(PsGViewExt)gv->x;
  double m1,m2;

  assert(x->f!=NULL);

  if (flags & DT_LEFT) m1=-1;else
  if (flags & DT_CENTERX) m1=-0.5;else
  m1=0;

  if (flags & DT_ABOVE) m2=0;else
  if (flags & DT_CENTERY) m2=-0.5;else
  m2=-1;

  ApplyPsGViewMode(gv);

  fprintf(x->f,
    "/Times-Roman findfont\n"
    "12 scalefont\n"
    "setfont\n"
    "%g %g moveto\n"
    "(%s) dup stringwidth pop 12\n"
    "%g mul exch\n"
    "%g mul exch\n"
    "rmoveto\n"
    "show\n",
    x1,gv->height-y1,text,
    m2,m1
  );
}

static void PSV_GetTextExtent(GView gv,char* text,double* pw,double* ph) {
  if (pw!=NULL) *pw=10*strlen(text);
  if (ph!=NULL) *ph=12;
}

static void PSV_SetMode(GView gv,int mode) {
  PsGViewExt x=(PsGViewExt)gv->x;

  switch(mode) {
    case VM1_GRAPHLINE:
      x->r=0.0;x->g=0.0;x->b=0.0;x->lw=0.2;break;
    case VM2_GRAPHLINE:
      x->r=1.0;x->g=0.0;x->b=0.0;x->lw=0.2;
      if (x->bBW) x->r=x->g=x->b=0.0;break;
    case VM3_GRAPHLINE:
      x->r=0.0;x->g=1.0;x->b=0.0;x->lw=0.2;
      if (x->bBW) x->r=x->g=x->b=0.0;break;
    case VM4_GRAPHLINE:
      x->r=0.4;x->g=0.4;x->b=1.0;x->lw=0.2;
      if (x->bBW) x->r=x->g=x->b=0.0; break;
    case VM_GRIDLINE:
      x->r=0.5;x->g=0.5;x->b=0.5;x->lw=0.0;break;
    case VM_GRIDTEXT:
      x->r=0.0;x->g=0.0;x->b=0.0;x->lw=0.0;break;
    case VM1_LEGENDTEXT:
      x->r=0.0;x->g=0.0;x->b=0.0;x->lw=0.0;break;
    case VM1_GRAPHSYMS:
      x->r=0.0;x->g=0.0;x->b=0.0;x->lw=0.4;break;
    case VM_BORDER:
      x->r=0.0;x->g=0.0;x->b=0.0;x->lw=0.5;break;
    default: assert(0);break;
  }
}

static GView CreatePsGView(GView gv0,double width,double height,
    double margin,int bBW) {
  GView gv;
  PsGViewExt x;

  if (width-2*margin<=0 || height-2*margin<=0) return NULL;

  gv=Malloc(sizeof(*gv));
  gv->dlg=gv0->dlg;

  gv->glMinX=gv0->glMinX;
  gv->glMinY=gv0->glMinY;
  gv->glMaxX=gv0->glMaxX;
  gv->glMaxY=gv0->glMaxY;
  gv->glW=gv->glH=-1;

  gv->Free=PSV_Free;
  gv->SetMode=PSV_SetMode;
  gv->DrawLine=PSV_DrawLine;
  gv->DrawText=PSV_DrawText;
  gv->GetTextExtent=PSV_GetTextExtent;
  gv->Clear=PSV_Clear;

  gv->x=x=Malloc(sizeof(*x));

  x->f=NULL;
  x->orgWidth=width;
  x->orgHeight=height;
  x->orgMargin=margin;
  x->bBW=bBW;

  gv->width=x->orgWidth-2*x->orgMargin;
  gv->height=x->orgHeight-2*x->orgMargin;

  gv->symSize=2;
  GViewNoClip(gv);

  return gv;
}

#define DL(a,b,c,d) DrawGViewLine(gv,a,b,c,d)
#define SYMDX gv->symSize
#define SYMDY gv->symSize

static void DrawSymbol(struct _GView* gv,double sx,double sy,int type) {

  switch (type) {
    case 0:             /* Triangle pointing up */
      DL(sx-SYMDX,sy+SYMDY,sx,sy-SYMDY);
      DL(sx,sy-SYMDY,sx+SYMDX,sy+SYMDY);
      DL(sx+SYMDX,sy+SYMDY,sx-SYMDX,sy+SYMDY);
      break;
    case 1:             /* Square */
      DL(sx-SYMDX,sy-SYMDY,sx-SYMDX,sy+SYMDY);
      DL(sx-SYMDX,sy+SYMDY,sx+SYMDX,sy+SYMDY);
      DL(sx+SYMDX,sy+SYMDY,sx+SYMDX,sy-SYMDY);
      DL(sx+SYMDX,sy-SYMDY,sx-SYMDX,sy-SYMDY);
      break;
    case 2:             /* Rhombus */
      DL(sx,sy-SYMDY,sx-SYMDX,sy);
      DL(sx-SYMDX,sy,sx,sy+SYMDY);
      DL(sx,sy+SYMDY,sx+SYMDX,sy);
      DL(sx+SYMDX,sy,sx,sy-SYMDY);
      break;
    case 3:             /* Triangle pointing down */
      DL(sx-SYMDX,sy-SYMDY,sx,sy+SYMDY);
      DL(sx,sy+SYMDY,sx+SYMDX,sy-SYMDY);
      DL(sx+SYMDX,sy-SYMDY,sx-SYMDX,sy-SYMDY);
      break;
    case 4:             /* X */
      DL(sx-SYMDX,sy-SYMDY,sx+SYMDX,sy+SYMDY);
      DL(sx+SYMDX,sy-SYMDY,sx-SYMDX,sy+SYMDY);
      break;
    case 5:             /* + */
      DL(sx,sy-SYMDY,sx,sy+SYMDY);
      DL(sx-SYMDX,sy,sx+SYMDX,sy);
      break;
    case 6:
      DL(sx+SYMDX,sy-SYMDY,sx-SYMDX,sy-SYMDY);
      DL(sx-SYMDX,sy-SYMDY,sx+SYMDX,sy+SYMDY);
      DL(sx+SYMDX,sy+SYMDY,sx-SYMDX,sy+SYMDY);
      break;
    case 7:
      DL(sx-SYMDX,sy+SYMDY,sx-SYMDX,sy-SYMDY);
      DL(sx-SYMDX,sy-SYMDY,sx+SYMDX,sy+SYMDY);
      DL(sx+SYMDX,sy+SYMDY,sx+SYMDX,sy-SYMDY);
      break;
    case 8:
      DL(sx+SYMDX,sy-SYMDY,sx-SYMDX,sy-SYMDY);
      DL(sx,sy-SYMDY,sx,sy+SYMDY);
      DL(sx+SYMDX,sy+SYMDY,sx-SYMDX,sy+SYMDY);
      break;
    case 9:
      DL(sx+SYMDX,sy+SYMDY,sx+SYMDX,sy-SYMDY);
      DL(sx-SYMDX,sy,sx+SYMDX,sy);
      DL(sx-SYMDX,sy+SYMDY,sx-SYMDX,sy-SYMDY);
      break;
    default:assert(0);break;
  }
}
#undef DL
#undef SYMDX
#undef SYMDY


static void GViewClipTo(GView gv,double x1,double y1,double x2,double y2) {
  if (x1>x2) swap(x1,x2);
  if (y1>y2) swap(y1,y2);

  gv->clipX1=x1;
  gv->clipY1=y1;
  gv->clipX2=x2;
  gv->clipY2=y2;
}

static void GViewNoClip(GView gv) {
  GViewClipTo(gv,-MAXDOUBLE,-MAXDOUBLE,MAXDOUBLE,MAXDOUBLE);
}

static void DrawGViewLine(GView gv,double x1,double y1,double x2,double y2){
  if (x1<gv->clipX1 && x2>gv->clipX1)
    y1+=(y2-y1)*(gv->clipX1-x1)/(x2-x1),x1=gv->clipX1; else
  if (x2<gv->clipX1 && x1>gv->clipX1)
    y2+=(y1-y2)*(gv->clipX1-x2)/(x1-x2),x2=gv->clipX1;
  if (x1>gv->clipX2 && x2<gv->clipX2)
    y1+=(y2-y1)*(gv->clipX2-x1)/(x2-x1),x1=gv->clipX2; else
  if (x2>gv->clipX2 && x1<gv->clipX2)
    y2+=(y1-y2)*(gv->clipX2-x2)/(x1-x2),x2=gv->clipX2;

  if (y1<gv->clipY1 && y2>gv->clipY1)
    x1+=(x2-x1)*(gv->clipY1-y1)/(y2-y1),y1=gv->clipY1; else
  if (y2<gv->clipY1 && y1>gv->clipY1)
    x2+=(x1-x2)*(gv->clipY1-y2)/(y1-y2),y2=gv->clipY1;
  if (y1>gv->clipY2 && y2<gv->clipY2)
    x1+=(x2-x1)*(gv->clipY2-y1)/(y2-y1),y1=gv->clipY2; else
  if (y2>gv->clipY2 && y1<gv->clipY2)
    x2+=(x1-x2)*(gv->clipY2-y2)/(y1-y2),y2=gv->clipY2;

  if (x1<gv->clipX1 && x2<gv->clipX1) return;
  if (y1<gv->clipY1 && y2<gv->clipY1) return;
  if (x1>gv->clipX2 && x2>gv->clipX2) return;
  if (y1>gv->clipY2 && y2>gv->clipY2) return;

  gv->DrawLine(gv,x1,y1,x2,y2);
}
