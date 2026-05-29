/* Motif interface to variables */

#include "amds.h"

#define DLG_SETUPWARNING "dlgSetupWarning"
#define DLG_SETUP       "dlgSetup"
#define DLG_VARDEFLIST  "dlgVarDefList"
#define WG_LIST         "list"
#define DLG_VARDEFCREATE "dlgVarDefCreate"
#define WG_NAME         "name"
#define DLG_VARDEFEDIT  "dlgVarDefEdit"
#define DLG_RVARSEDIT   "dlgReactionVars"
#define DLG_PVARSEDIT   "dlgParticleVars"

#define VV_NOSEL        NULL
#define VV_DIFF         (char*)-1

typedef struct _VarDefListDlg {
  View w;
  Widget wDlg,wList;
}* VarDefListDlg;

typedef struct _VarDefEditDlg {
  View w;
  VarDef vd;
  Widget wDlg,wType,wUseFor,
    wDescr,wSwNoExport;
}* VarDefEditDlg;

typedef struct _VarsEditField {
  struct _VarsEditDlg *vdeDlg;
  VarDef vd;
  Widget wValue,wSet;
}* VarsEditField;

typedef struct _VarsEditDlg {
  View w;
  int bParticles,fieldCount;

  VarsEditField fields;

  Widget wDlg,wToolbar,wMsg,wScrolledVars,wVarsForm,wParticles,
    wAccept,wReset,wHold;
  Widget wOldForm;
}* VarsEditDlg;

static void CbSetupWarningOk(Widget wg,XtPointer xtpV,XtPointer pcbs);

static void CbSetupVarDefs(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbSetupReactionVars(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbSetupParticleVars(Widget wg,XtPointer xtpV,XtPointer pcbs);

static Widget CreateVarDefListDlg(View w);
static void DwVarDefList(Widget wList,View w,int msg,void* obj,void* ud);
static void CbVarDefListCreate(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbVarDefListEdit(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbVarDefListDel(Widget wg,XtPointer xtpDlg,XtPointer pcbs);

static Widget CreateVarDefCreateDlg(View w);
static void CbVarDefCreate(Widget wg,XtPointer xtpV,XtPointer pcbs);

static Widget CreateVarDefEditDlg(View w,VarDef vd);
static void CbVarDefEditAccept(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void ResetVarDefEditDlg(Widget wDlg);

static Widget CreateVarsEditDlg(View w,int bParticles);
static Group GetSelectedParticles(Widget wList,Group reactions);
static void DwVarsEditVars(Widget wList,View w,int msg,void* obj,void* ud);
static void DwVarsEditSel(Widget wList,View w,int msg,void* obj,void* ud);
static void CbVarsEditAccept(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbVarsEditReset(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbVarsEditSetHold(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbVarsEditParticleSel(Widget wg,XtPointer xtpDlg,XtPointer ps);
static void CbVarsEditSetField(Widget wg,XtPointer pField,XtPointer pcbs);
static void CbVarsEditFocus(Widget wg,XtPointer pField,XtPointer pcbs);

static char* GetVarEx(View w,VarDef vd,Group reactions,Group particles,
    int bDescr);
static void SetVarEx(View w,VarDef vd,Group reactions,Group particles,
    char* val);
static Group GetAllParticles(Group reactions,int bOutput);

Widget OpenSetupWarningDlg(View w) {
  Widget wDlg;
  XtPointer xtp;

  wDlg=XtNameToWidget(w->wMain,"*"DLG_SETUPWARNING);
  if (wDlg==NULL) {
    wDlg=Cw(XmCreateWarningDialog,w->wMain,DLG_SETUPWARNING,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,False,
      XmNuserData,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbSetupWarningOk,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));
    XtManageChild(wDlg);
  } else {
    GetValues(wDlg,XmNuserData,&xtp,NULL);
    if (xtp!=NULL) CbSetupWarningOk(wDlg,w,NULL);
    else XtPopup(XtParent(wDlg),XtGrabNone);
  }
  return wDlg;
}

Widget OpenSetupDlg(View w) {
  Widget wDlg;
  XtPointer xtp;

  wDlg=XtNameToWidget(w->wMain,"*"DLG_SETUP);
  if (wDlg==NULL) {
    wDlg=Cw(XmCreateFormDialog,w->wMain,DLG_SETUP,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,False,
      XmNrubberPositioning,True,
      NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);

    CreateMenuSystem(wDlg,
      "b@A:close",0x0101,CbUnmap,NULL,
      "s@:separ",0x0103,
      "b@A:varDefs",0x0105,CbSetupVarDefs,w,
      "b@A:reactionVars",0x0107,CbSetupReactionVars,w,
      "b@A:particleVars",0x0109,CbSetupParticleVars,w,
      NULL);
    Form2Table(wDlg);

    XtManageChild(wDlg);
  } else {
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
  return wDlg;
}

Widget OpenVarDefListDlg(View w) {
  Widget wDlg;

  wDlg=XtNameToWidget(w->wMain,"*"DLG_VARDEFLIST);
  if (wDlg==NULL) {
    wDlg=CreateVarDefListDlg(w);
  } else XtPopup(XtParent(wDlg),XtGrabNone);

  return wDlg;
}

Widget OpenVarDefCreateDlg(View w) {
  Widget wDlg;

  wDlg=XtNameToWidget(w->wMain,"*"DLG_VARDEFCREATE);
  if (wDlg==NULL) {
    wDlg=CreateVarDefCreateDlg(w);
  } else XtPopup(XtParent(wDlg),XtGrabNone);

  return wDlg;
}

Widget OpenVarDefEditDlg(View w,VarDef vd) {
  Widget wDlg;
  char s[256];

  sprintf(s,"*"DLG_VARDEFEDIT".%p",vd);
  wDlg=XtNameToWidget(w->wMain,s);
  if (wDlg==NULL) {
    wDlg=CreateVarDefEditDlg(w,vd);
  } else {
    wDlg=XtParent(wDlg);
    ResetVarDefEditDlg(wDlg);
    XtPopup(XtParent(wDlg),XtGrabNone);
  }

  return wDlg;
}

Widget OpenVarsEditDlg(View w,int bParticles) {
  Widget wDlg;

  wDlg=XtNameToWidget(w->wMain,bParticles?
    "*"DLG_PVARSEDIT : "*"DLG_RVARSEDIT);
  if (wDlg==NULL) {
    wDlg=CreateVarsEditDlg(w,bParticles);
  } else {
    XtPopup(XtParent(wDlg),XtGrabNone);
  }

  return wDlg;
}


static void CbSetupWarningOk(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  SetValues(wg,XmNuserData,1,NULL);
  OpenSetupDlg(w);
  XtPopdown(XtParent(wg));
}


static void CbSetupVarDefs(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenVarDefListDlg(w);
}

static void CbSetupReactionVars(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenVarsEditDlg(w,False);
}

static void CbSetupParticleVars(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenVarsEditDlg(w,True);
}

static Widget CreateVarDefListDlg(View w) {
  VarDefListDlg dlg;
  Widget wg;

  dlg=Malloc(sizeof(*dlg));
  dlg->w=w;

  dlg->wDlg=Cw(XmCreateMessageDialog,w->wMain,DLG_VARDEFLIST,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    XmNuserData,dlg,
    NULL);
  XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbFree,dlg);

  XtUnmanageChild(XmMessageBoxGetChild(dlg->wDlg,XmDIALOG_OK_BUTTON));
  XtAddCallback(dlg->wDlg,XmNcancelCallback,CbUnmap,NULL);
  XmAddWMProtocolCallback(XtParent(dlg->wDlg),w->xapp->wm_del_window,
    CbUnmap,NULL);
  XtUnmanageChild(XmMessageBoxGetChild(dlg->wDlg,XmDIALOG_HELP_BUTTON));

  dlg->wList=Cmw(XmCreateScrolledList,dlg->wDlg,WG_LIST,
    XmNselectionPolicy,XmBROWSE_SELECT,
    NULL);
  AddDependentWidget(w,dlg->wList,N_NOW | N_VARDEFS,DwVarDefList,NULL);
  XtAddCallback(dlg->wList,XmNdefaultActionCallback,CbVarDefListEdit,dlg);

  wg=Cmw(XmCreatePushButton,dlg->wDlg,"add",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbVarDefListCreate,w);

  wg=Cmw(XmCreatePushButton,dlg->wDlg,"change",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbVarDefListEdit,dlg);

  wg=Cmw(XmCreatePushButton,dlg->wDlg,"delete",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbVarDefListDel,dlg);

  XtManageChild(dlg->wDlg);

  return dlg->wDlg;
}

static void DwVarDefList(Widget wList,View w,int msg,void* obj,void* ud) {
  VarDef vd;
  Index ix;
  int i,k;
  XmStringTable xmst;

  XmListDeleteAllItems(wList);

  xmst=Malloc(sizeof(*xmst)*GroupCount(w->subset->varDefs)+1);

  for (k=0,vd=Group1st(w->subset->varDefs,&ix);vd!=NULL;vd=Next(&ix))
    xmst[k++]=XmStringCreateLocalized(GetVarDefName(vd));

  XmListAddItems(wList,xmst,k,0);
  for (i=0;i<k;i++) XmStringFree(xmst[i]);
  Free(xmst);
}

static void CbVarDefListCreate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenVarDefCreateDlg(w);
}

static void CbVarDefListEdit(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarDefListDlg dlg=(VarDefListDlg)xtpDlg;
  XmListCallbackStruct* lcbs;
  int positionCount,* positionList;

  if (XmIsList(wg)) {
    lcbs=(XmListCallbackStruct*)pcbs;
    OpenVarDefEditDlg(dlg->w,
      GroupAt(dlg->w->subset->varDefs,lcbs->item_position-1));
  } else {
    if (!XmListGetSelectedPos(dlg->wList,&positionList,&positionCount))
      return;
    if (positionCount==1) OpenVarDefEditDlg(dlg->w,
      GroupAt(dlg->w->subset->varDefs,*positionList-1));
    XtFree((XtPointer)positionList);
  }
}

static void CbVarDefListDel(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarDefListDlg dlg=(VarDefListDlg)xtpDlg;
  int positionCount,* positionList;

  if (!XmListGetSelectedPos(dlg->wList,&positionList,&positionCount))
    return;
  if (positionCount==1) {
    DelVarDef(dlg->w->subset,
      GroupAt(dlg->w->subset->varDefs,*positionList-1));
    UndoMark(dlg->w->subset);
  }
  XtFree((XtPointer)positionList);
}


static Widget CreateVarDefCreateDlg(View w) {
  Widget wDlg,wForm,wg;

  wDlg=Cw(XmCreateMessageDialog,w->wMain,DLG_VARDEFCREATE,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    NULL);
  XtAddCallback(wDlg,XmNokCallback,CbVarDefCreate,w);
  XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
  XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
    CbUnmap,NULL);
  XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

  wForm=Cmw(XmCreateForm,wDlg,"form",
    NULL);

  Cmw(XmCreateLabel,wForm,"nameLabel",
    XmNuserData,0x0101,
    NULL);

  Cmw(XmCreateText,wForm,WG_NAME,
    XmNuserData,0x0201,
    NULL);

  Form2Table(wForm);

  XtManageChild(wDlg);

  return wDlg;
}

static void CbVarDefCreate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Widget wText;
  String s;
  char buf[256],buf1[256];
  VarDef vd;
  Index ix;

  while (!XtIsShell(wg)) wg=XtParent(wg);

  wText=XtNameToWidget(wg,"*"WG_NAME);
  assert(wText!=NULL);

  s=XmTextGetString(wText);

  if (sscanf(s,"%s%s",buf,buf1)!=1) {
    XtFree(s);
    ErrorBox(w->wMain,GetResourceStringEx(w->wMain,"errBadName",
      "error",NULL,NULL));
    return;
  }
  XtFree(s);

  for (vd=Group1st(w->subset->varDefs,&ix);vd!=NULL;vd=Next(&ix))
    if (!strcmp(GetVarDefName(vd),buf)) {
      ErrorBox(w->wMain,GetResourceStringEx(w->wMain,"errDuplicateName",
	"error",NULL,NULL));
      return;
    }

  vd=AddVarDef(w->subset,buf);
  UndoMark(w->subset);
  OpenVarDefEditDlg(w,vd);

  XmTextSetString(wText,"");
  XtPopdown(wg);
}


static Widget CreateVarDefEditDlg(View w,VarDef vd) {
  VarDefEditDlg dlg;
  Widget wForm;
  char s[256];

  dlg=Malloc(sizeof(*dlg));
  dlg->w=w;
  dlg->vd=vd;

  dlg->wDlg=Cw(XmCreateMessageDialog,w->wMain,DLG_VARDEFEDIT,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    XmNuserData,dlg,
    NULL);
  AddDependentWidget(w,XtParent(dlg->wDlg),N_DEL,DwTrackDelete,vd);
  XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbFree,dlg);
  XtAddCallback(dlg->wDlg,XmNokCallback,CbVarDefEditAccept,dlg);
  XtAddCallback(dlg->wDlg,XmNcancelCallback,CbUnmap,NULL);
  XmAddWMProtocolCallback(XtParent(dlg->wDlg),w->xapp->wm_del_window,
    CbUnmap,NULL);
  XtUnmanageChild(XmMessageBoxGetChild(dlg->wDlg,XmDIALOG_HELP_BUTTON));

  sprintf(s,"%p",vd);
  wForm=Cmw(XmCreateForm,dlg->wDlg,s,
    NULL);

  CreateMenuSystem(wForm,
    "l@:descrLabel",0x0101,
    "x@?:descr",0x0201,&dlg->wDescr,
    "l@:typeLabel",0x0102,
    "*:typeMenu",
    "b@:string",VDT_STRING,
    "b@:float",VDT_FLOAT,
    "b@:int",VDT_INT,
    "-:",
    "o@?:type",0x0202,&dlg->wType,
    "l@:useForLabel",0x0103,
    "*:useForMenu",
    "b@:reactions",VDF_REACTIONS,
    "b@:particles",VDF_PARTICLES,
    "-:",
    "o@?:useFor",0x0203,&dlg->wUseFor,
    "t@?:noExport",0x0104,&dlg->wSwNoExport,
    NULL);
  Form2Table(wForm);

  ResetVarDefEditDlg(dlg->wDlg);

  XtManageChild(dlg->wDlg);

  return dlg->wDlg;
}

static void ResetVarDefEditDlg(Widget wDlg) {
  VarDefEditDlg dlg;
  XtPointer xtp;
  XmString xms;

  GetValues(wDlg,XmNuserData,&xtp,NULL);
  dlg=(VarDefEditDlg)xtp;
  assert(dlg!=NULL);

  SetValues(XtParent(dlg->wDlg),XmNtitle,GetVarDefName(dlg->vd),NULL);

  XmTextSetString(dlg->wDescr,GetVarDefDescr(dlg->vd));
  SetOptionMenuValue(dlg->wType,(XtPointer)dlg->vd->type);
  SetOptionMenuValue(dlg->wUseFor,(XtPointer)(dlg->vd->flags & VDFM_APPLY));
  XmToggleButtonSetState(dlg->wSwNoExport,!!(dlg->vd->flags&VDF_NOEXPORT),0);
}

static void CbVarDefEditAccept(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarDefEditDlg dlg=(VarDefEditDlg)xtpDlg;
  String s;
  int f;

  s=XmTextGetString(dlg->wDescr);
  SetVarDefDescr(dlg->w->subset,dlg->vd,s);
  XtFree(s);

  f=(int)GetOptionMenuValue(dlg->wUseFor);
  if (XmToggleButtonGetState(dlg->wSwNoExport)) f|=VDF_NOEXPORT;

  ChangeVarDef(dlg->w->subset,dlg->vd,
    (int)GetOptionMenuValue(dlg->wType),
    f);

  UndoMark(dlg->w->subset);

  XtPopdown(XtParent(dlg->wDlg));
}


static Widget CreateVarsEditDlg(View w,int bParticles) {
  VarsEditDlg dlg;
  Widget wg,wg1;

  dlg=Malloc(sizeof(*dlg));
  dlg->w=w;
  dlg->bParticles=bParticles;
  dlg->wVarsForm=NULL;
  dlg->fields=NULL;

  dlg->wDlg=Cw(XmCreateFormDialog,w->wMain,
    bParticles? DLG_PVARSEDIT : DLG_RVARSEDIT,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    XmNresizePolicy,XmRESIZE_GROW,
    XmNuserData,dlg,
    NULL);
  XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbFree,dlg);
  XmAddWMProtocolCallback(XtParent(dlg->wDlg),w->xapp->wm_del_window,
    CbUnmap,NULL);

  dlg->wToolbar=Cmw(XmCreateRowColumn,dlg->wDlg,"toolbar",
    XmNorientation,XmHORIZONTAL,
    XmNtopAttachment,XmATTACH_FORM,
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    NULL);

  wg=dlg->wAccept=Cmw(XmCreatePushButton,dlg->wToolbar,"accept",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbVarsEditAccept,dlg);

  wg=dlg->wReset=Cmw(XmCreatePushButton,dlg->wToolbar,"reset",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbVarsEditReset,dlg);

  wg=dlg->wHold=Cmw(XmCreateToggleButton,dlg->wToolbar,"hold",
    NULL);

  wg=Cmw(XmCreatePushButton,dlg->wToolbar,"close",
    NULL);
  XtAddCallback(wg,XmNactivateCallback,CbUnmap,NULL);

  wg=Cmw(XmCreateSeparator,dlg->wDlg,"separ",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,dlg->wToolbar,
    NULL);

  if (bParticles) {
    wg=dlg->wParticles=Cmw(XmCreateScrolledList,dlg->wDlg,"particles",
      XmNleftAttachment,XmATTACH_FORM,
      XmNrightAttachment,XmATTACH_FORM,
      XmNtopAttachment,XmATTACH_WIDGET,
      XmNtopWidget,wg,
      NULL);
    XtAddCallback(wg,XmNsingleSelectionCallback,CbVarsEditParticleSel,dlg);
    XtAddCallback(wg,XmNbrowseSelectionCallback,CbVarsEditParticleSel,dlg);
    XtAddCallback(wg,XmNextendedSelectionCallback,CbVarsEditParticleSel,
      dlg);
    XtAddCallback(wg,XmNmultipleSelectionCallback,CbVarsEditParticleSel,
      dlg);

    wg=Cmw(XmCreateSeparator,dlg->wDlg,"separ",
      XmNleftAttachment,XmATTACH_FORM,
      XmNrightAttachment,XmATTACH_FORM,
      XmNtopAttachment,XmATTACH_WIDGET,
      XmNtopWidget,wg,
      NULL);
  } else dlg->wParticles=NULL;


  dlg->wMsg=Cmw(XmCreateLabel,dlg->wDlg,"msg",
    XmNrecomputeSize,False,
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    NULL);

  wg1=Cmw(XmCreateSeparator,dlg->wDlg,"separ",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_WIDGET,
    XmNbottomWidget,dlg->wMsg,
    NULL);

  dlg->wScrolledVars=Cmw(XmCreateForm,dlg->wDlg,"scroll",
    /*XmNscrollingPolicy,XmAUTOMATIC,*/
  /*  XmNresizePolicy,XmRESIZE_GROW, */

    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wg,
    XmNbottomAttachment,XmATTACH_WIDGET,
    XmNbottomWidget,wg1,
    NULL);
  XtManageChild(dlg->wDlg);

  AddDependentWidget(w,dlg->wScrolledVars,N_NOW | N_VARDEFS,
    DwVarsEditVars,dlg);
  AddDependentWidget(w,dlg->wDlg,N_NOW | N_SEL,DwVarsEditSel,dlg);

  return dlg->wDlg;
}

static void DwVarsEditVars(Widget wg,View w,int msg,void* obj,void* ud) {
  VarsEditDlg dlg=(VarsEditDlg)ud;
  VarDef vd;
  Index ix;
  int i;

/*  XtUnmapWidget(XtParent(dlg->wDlg)); */

  if (dlg->wVarsForm!=NULL) {
    XtUnmanageChild(dlg->wVarsForm);  /* Make XmForm happy */
    XtDestroyWidget(dlg->wVarsForm);
  }

/* Old dlg->fields will be freed when old wVarsForm is destroyed */
  dlg->fields=Malloc(sizeof(*dlg->fields)*
    GroupCount(dlg->w->subset->varDefs));

  dlg->wVarsForm=Cw(XmCreateForm,dlg->wScrolledVars,"form",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    NULL);
  XtAddCallback(dlg->wVarsForm,XmNdestroyCallback,CbFree,dlg->fields);

  for (i=0,vd=Group1st(w->subset->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
    if (dlg->bParticles && ~vd->flags & VDF_PARTICLES) continue;
    if (!dlg->bParticles && ~vd->flags & VDF_REACTIONS) continue;

    dlg->fields[i].vdeDlg=dlg;
    dlg->fields[i].vd=vd;
    Cmw(XmCreateLabel,dlg->wVarsForm,GetVarDefDescr(vd),
      XmNuserData,i+1+256*1,
      NULL);
    dlg->fields[i].wValue=Cmw(XmCreateText,dlg->wVarsForm,"value",
      XmNuserData,i+1+256*2,
      NULL);
    XtAddCallback(dlg->fields[i].wValue,XmNfocusCallback,
      CbVarsEditFocus,dlg->fields+i);
    XtAddCallback(dlg->fields[i].wValue,XmNlosingFocusCallback,
      CbVarsEditFocus,dlg->fields+i);
    XtAddCallback(dlg->fields[i].wValue,XmNactivateCallback,
      CbVarsEditSetField,dlg->fields+i);
    XtAddCallback(dlg->fields[i].wValue,XmNvalueChangedCallback,
      CbVarsEditSetHold,dlg);
    dlg->fields[i].wSet=Cmw(XmCreatePushButton,dlg->wVarsForm,"set",
      XmNuserData,i+1+256*3,
      NULL);
    XtAddCallback(dlg->fields[i].wSet,XmNactivateCallback,
      CbVarsEditSetField,dlg->fields+i);
    i++;
  }
  dlg->fieldCount=i++;

  XtUnrealizeWidget(dlg->wVarsForm);
  Form2Table(dlg->wVarsForm);
  XtRealizeWidget(dlg->wVarsForm);
  XtManageChild(dlg->wVarsForm);
  /*XtMapWidget(XtParent(dlg->wDlg));*/
}

static void CbVarsEditFocus(Widget wg,XtPointer pField,XtPointer pcbs) {
  VarsEditField vef=(VarsEditField)pField;
  VarsEditDlg dlg=vef->vdeDlg;
  XmAnyCallbackStruct* cbs=(XmAnyCallbackStruct*)pcbs;
  XmString xms;
  String s;
  Group gr,gp=NULL;

  switch(cbs->reason) {
    case XmCR_FOCUS:
      gr=GetSelectedReactions(dlg->w);
      gp=GetSelectedParticles(dlg->wParticles,gr);
      s=GetVarEx(dlg->w,vef->vd,gr,gp,True);

      if (s==VV_NOSEL)
	s=GetResourceString(dlg->wDlg,"strNoSel","StrNoSel","<NoSel>");
      else if (s==VV_DIFF)
	s=GetResourceString(dlg->wDlg,"strDiff","StrDiff","<Diff>");
      else s=GetResourceStringEx(dlg->wDlg,"strOldVal","StrOldVal",
	"$(VAR)%s$(VALUE)%s",
	GetVarDefDescr(vef->vd),
	s /*GetVarEx(dlg->w,vef->vd,gr,gp,True)*/);

      xms=MakeXmString(s);
      SetValues(dlg->wMsg,XmNlabelString,xms,NULL);
      XmStringFree(xms);

      if (gp!=NULL) FreeGroup(gp);
      FreeGroup(gr);
      break;
    case XmCR_LOSING_FOCUS:
      xms=MakeXmString("");
      SetValues(dlg->wMsg,XmNlabelString,xms,NULL);
      XmStringFree(xms);
      break;
    default:
      assert(0);
  }
}

static void CbVarsEditSetField(Widget wg,XtPointer pField,XtPointer pcbs) {
  VarsEditField vef=(VarsEditField)pField;
  VarsEditDlg dlg=vef->vdeDlg;
  Group gr,gp=NULL;
  String s;
  XmString xms;

  gr=GetSelectedReactions(dlg->w);
  gp=GetSelectedParticles(dlg->wParticles,gr);

  s=XmTextGetString(vef->wValue);

  SetVarEx(dlg->w,vef->vd,gr,gp,s);
  UndoMark(dlg->w->subset);

  xms=MakeXmString(GetResourceStringEx(dlg->wDlg,"strNewVal","StrNewVal",
	"$(VAR)%s$(VALUE)%s",
	GetVarDefDescr(vef->vd),
	GetVarEx(dlg->w,vef->vd,gr,gp,True)));
  SetValues(dlg->wMsg,XmNlabelString,xms,NULL);
  XmStringFree(xms);

  XtFree(s);

  if (gp!=NULL) FreeGroup(gp);
  FreeGroup(gr);
}

static void CbVarsEditAccept(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarsEditDlg dlg=(VarsEditDlg)xtpDlg;
  Group gr,gp=NULL;
  String s;
  XmString xms;
  int i;

  gr=GetSelectedReactions(dlg->w);
  gp=GetSelectedParticles(dlg->wParticles,gr);

  for (i=0;i<dlg->fieldCount;i++) {
    s=XmTextGetString(dlg->fields[i].wValue);
    SetVarEx(dlg->w,dlg->fields[i].vd,gr,gp,s);
    XtFree(s);
  }

  UndoMark(dlg->w->subset);

  xms=MakeXmString(GetResourceString(dlg->wDlg,"strNewVals","StrNewVals",
    "<newVals>"));
  SetValues(dlg->wMsg,XmNlabelString,xms,NULL);
  XmStringFree(xms);

  if (gp!=NULL) FreeGroup(gp);
  FreeGroup(gr);

  XmToggleButtonSetState(dlg->wHold,False,False);
}

static void CbVarsEditReset(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarsEditDlg dlg=(VarsEditDlg)xtpDlg;
  Group gr,gp=NULL;
  String s;
  int i;

  gr=GetSelectedReactions(dlg->w);
  gp=GetSelectedParticles(dlg->wParticles,gr);

  for (i=0;i<dlg->fieldCount;i++) {
    XmTextSetString(dlg->fields[i].wValue,
      GetVarEx(dlg->w,dlg->fields[i].vd,gr,gp,False));
  }

  if (gp!=NULL) FreeGroup(gp);
  FreeGroup(gr);

  if (XmToggleButtonGetState(dlg->wHold))
    XmToggleButtonSetState(dlg->wHold,False,False);
}

static void CbVarsEditParticleSel(Widget wg,XtPointer xtpDlg,XtPointer ps) {
  VarsEditDlg dlg=(VarsEditDlg)xtpDlg;

  if (!XmToggleButtonGetState(dlg->wHold))
    CbVarsEditReset(NULL,(XtPointer)dlg,NULL);
}

static void DwVarsEditSel(Widget wList,View w,int msg,void* obj,void* ud) {
  VarsEditDlg dlg=(VarsEditDlg)ud;
  Group g,g1;
  Particle p;
  Index ix;
  int i;
  XmString* xmst;

  if (dlg->bParticles) {
    g=GetSelectedReactions(dlg->w);
    g1=GetAllParticles(g,False);

    XmListDeleteAllItems(dlg->wParticles);

    xmst=Malloc(sizeof(*xmst)*GroupCount(g1));
    for (i=0,p=Group1st(g1,&ix);p!=NULL;p=Next(&ix),i++)
      xmst[i]=MakeXmString(p->name);

    XmListAddItems(dlg->wParticles,xmst,GroupCount(g1),0);

    for (i=0;i<GroupCount(g1);i++) XmStringFree(xmst[i]);
    Free(xmst);
    FreeGroup(g1);
    FreeGroup(g);
  }

  if (!XmToggleButtonGetState(dlg->wHold))
    CbVarsEditReset(NULL,(XtPointer)dlg,NULL);
}

static void CbVarsEditSetHold(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  VarsEditDlg dlg=(VarsEditDlg)xtpDlg;

  if (!XmToggleButtonGetState(dlg->wHold))
    XmToggleButtonSetState(dlg->wHold,True,False);
}


/* bDetail==True => VV_NOSEL and VV_DIFF are returned instead of blanks */

static char* GetVarEx(View w,VarDef vd,Group reactions,Group particles,
    int bDetail) {
  Reaction r;
  Particle p;
  Index ix,ix1;
  String s,s1;

  s=NULL;

  if (particles==NULL) {
    for (r=Group1st(reactions,&ix);r!=NULL;r=Next(&ix)) {
      s1=GetReactionVar(w->subset,r,vd);
      if (s==NULL) s=s1;
      else if (strcmp(s,s1)) goto diff;
    }
  } else {
    for (p=Group1st(particles,&ix1);p!=NULL;p=Next(&ix1))
      for (r=Group1st(reactions,&ix);r!=NULL;r=Next(&ix)) {
	if (!InGroup(r->inputSet,p)) continue;
	s1=GetParticleVar(w->subset,r,p,vd);
	if (s==NULL) s=s1;
	else if (strcmp(s,s1)) goto diff;
      }
  }

  return s==NULL ? (bDetail ? VV_NOSEL : "")  : s;

  diff:
  return bDetail ? VV_DIFF : "";
}

static void SetVarEx(View w,VarDef vd,Group reactions,Group particles,
    char* val) {
  Reaction r;
  Particle p;
  Index ix,ix1;
  String s,s1;

  s=NULL;

  if (particles==NULL) {
    for (r=Group1st(reactions,&ix);r!=NULL;r=Next(&ix))
      SetReactionVar(w->subset,r,vd,val);
  } else {
    for (p=Group1st(particles,&ix1);p!=NULL;p=Next(&ix1))
      for (r=Group1st(reactions,&ix);r!=NULL;r=Next(&ix)) {
	if (!InGroup(r->inputSet,p)) continue;
	SetParticleVar(w->subset,r,p,vd,val);
      }
  }
}

static Group GetAllParticles(Group reactions,int bOutput) {
  Group g;
  Reaction r;
  Particle p;
  Index ix,ix1;

  g=CreateGroup();

  for (r=Group1st(reactions,&ix);r!=NULL;r=Next(&ix)) {
    for (p=Group1st(r->inputSet,&ix1);p!=NULL;p=Next(&ix1))
      if (!InGroup(g,p)) GroupAdd(g,p);
    if (!bOutput) continue;
    for (p=Group1st(r->outputSet,&ix1);p!=NULL;p=Next(&ix1))
      if (!InGroup(g,p)) GroupAdd(g,p);
  }

  return g;
}

static Group GetSelectedParticles(Widget wList,Group reactions) {
  Group g,g2;
  Particle p;
  int i,k;
  int positionCount,* positionList;
  Index ix;

  if (wList==NULL) return NULL;

  g=CreateGroup();

  if (!XmListGetSelectedPos(wList,&positionList,&positionCount))
    return g;

  g2=GetAllParticles(reactions,False);

  for (i=1,k=0,p=Group1st(g2,&ix);p!=NULL;p=Next(&ix),i++)
    if (k<positionCount && i==positionList[k]) {GroupAdd(g,p);k++;}

  FreeGroup(g2);
  XtFree((XtPointer)positionList);

  return g;
}
