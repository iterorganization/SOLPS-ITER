#include "amds.h"

#define DLG_VALIDATE "dlgValidate"

typedef struct _ValidateDlg {
  View w;
  Widget wDlg,wList,wList2;
  Group /*particles,*/missingParticles;
}* ValidateDlg;

static Widget CreateValidateDlg(View w);
static void SelectParticles(ValidateDlg dlg,Group g);
static Group GetSelectedParticles(Widget wList,Group gAllParticles);
static void UpdateValidateDlg(Widget wDlg);
static void CbValidateDlgDestroy(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbAddParticle(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbSelectParticle(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbRemoveParticles(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbAddMissingParticles(Widget wg,XtPointer xtpDlg,XtPointer pcbs);
static void CbCascadeAddParticle(Widget wg,XtPointer xtpDlg,XtPointer p);
static void CbCascadeSelectParticle(Widget wg,XtPointer xtpDlg,
    XtPointer pbcs);
static void DwValidateDlg(Widget wg,View w,int evt,void* obj,void* uData);

Widget OpenValidateDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_VALIDATE);

  if (wDlg==NULL) {
    wDlg=CreateValidateDlg(w);
  } else {
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
  UpdateValidateDlg(wDlg);

  return wDlg;
}

static Widget CreateValidateDlg(View w) {
  ValidateDlg dlg;
  int i;
  Widget wF,wRC,wPaned,wg,wAr;

  dlg=Malloc(sizeof(*dlg));
  dlg->w=w;
  /*dlg->particles=CreateGroup();*/
  dlg->missingParticles=CreateGroup();

  dlg->wDlg=Cw(XmCreateFormDialog,w->wMain,DLG_VALIDATE,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNautoUnmanage,False,
    XmNuserData,(XtPointer)dlg,
    NULL);

  XtAddCallback(dlg->wDlg,XmNdestroyCallback,CbValidateDlgDestroy,dlg);

  XmAddWMProtocolCallback(XtParent(dlg->wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);

  wRC=Cmw(XmCreateRowColumn,dlg->wDlg,"rowcol",
    XmNorientation,XmHORIZONTAL,
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_FORM,
    NULL);

  wg=Cmw(XmCreateFrame,wRC,"frame",
    NULL);
  wg=Cmw(XmCreateMenuBar,wg,"menu",
    NULL);
  wg=Cmw(XmCreateCascadeButton,wg,"add",
    NULL);
  CreateParticleMenu(dlg->w,wg,NULL,CbCascadeAddParticle,
      CbAddParticle,(XtPointer)dlg);

  wg=Cmw(XmCreateFrame,wRC,"frame",
    NULL);
  wg=Cmw(XmCreateMenuBar,wg,"menu",
    XmNtraversalOn,True,
    NULL);
  wg=Cmw(XmCreateCascadeButton,wg,"select",
    NULL);
  CreateParticleMenu(dlg->w,wg,NULL,CbCascadeSelectParticle,
      CbSelectParticle,(XtPointer)dlg);

  CreateMenuSystem(wRC,
    "bA:remove",CbRemoveParticles,dlg,
    "bA:close",CbUnmap,NULL,
    NULL);

  wPaned=Cmw(XmCreatePanedWindow,dlg->wDlg,"paned",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wRC,
    NULL);

  wF=Cmw(XmCreateForm,wPaned,"form1",
    NULL);

  wg=Cmw(XmCreateLabel,wF,"startupLabel",
    XmNleftAttachment,XmATTACH_FORM,
   /* XmNrightAttachment,XmATTACH_FORM, */
    XmNtopAttachment,XmATTACH_FORM,
    NULL);

  dlg->wList=Cmw(XmCreateScrolledList,wF,"startupList",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wg,
    NULL);

  wF=Cmw(XmCreateForm,wPaned,"form2",
    NULL);

  wg=Cmw(XmCreateRowColumn,wF,"missingHdr",
    XmNorientation,XmHORIZONTAL,
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_FORM,
    NULL);

  Cmw(XmCreateLabel,wg,"missingLabel",
    NULL);

  wAr=Cmw(XmCreateArrowButton,wg,"copy",
    XmNarrowDirection,XmARROW_UP,
    NULL);
  XtAddCallback(wAr,XmNactivateCallback,CbAddMissingParticles,dlg);

  dlg->wList2=Cmw(XmCreateScrolledList,wF,"missingList",
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    XmNtopAttachment,XmATTACH_WIDGET,
    XmNtopWidget,wg,
    NULL);

  XtAddCallback(dlg->wList2,XmNextendedSelectionCallback,
      CbSensitiveIfListSel,(XtPointer)wAr);
  XtManageChild(dlg->wDlg);

  AddDependentWidget(w,dlg->wDlg,N_NOW|N_SEL|N_ALT,DwValidateDlg,(void*)dlg);

  return dlg->wDlg;
}

static void CbValidateDlgDestroy(Widget wg,XtPointer xtpDlg,XtPointer pcbs){
  ValidateDlg dlg=(ValidateDlg)xtpDlg;

  FreeGroup(dlg->missingParticles);
  Free(dlg);
}

static void CbAddParticle(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Reaction r;
  Particle p,p0;
  Index ix;
  int i,bSubclass;

  XtPointer xtpParticle;

  GetValues(wg,XmNuserData,&xtpParticle,NULL);
  p0=(Particle)xtpParticle;
  if (p0==NULL) return;
  bSubclass=!strcmp(XtName(wg),PB_MASK);

  if (bSubclass) {
    for (p=Group1st(dlg->w->db->particles,&ix);p!=NULL;p=Next(&ix))
      if (IsSubclassedParticle(p,p0,False))
	 SetStartupParticle(dlg->w->subset,p,True);
  } else {
    SetStartupParticle(dlg->w->subset,p0,True);
  }

  UndoMark(dlg->w->subset);
  /*UpdateValidateDlg(dlg->wDlg);*/
}

static void CbSelectParticle(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Reaction r;
  Particle p,p0;
  Group g;
  Index ix;
  int i,bSubclass;

  XtPointer xtpParticle;

  GetValues(wg,XmNuserData,&xtpParticle,NULL);
  p0=(Particle)xtpParticle;
  if (p0==NULL) return;
  bSubclass=!strcmp(XtName(wg),PB_MASK);

  g=CreateGroup();

  if (bSubclass) {
    for (p=Group1st(dlg->w->db->particles,&ix);p!=NULL;p=Next(&ix))
      if (IsSubclassedParticle(p,p0,False) &&
	 IsStartupParticle(dlg->w->subset,p))
       GroupAdd(g,p);
  } else {
    if (IsStartupParticle(dlg->w->subset,p0)) GroupAdd(g,p0);
  }

  SelectParticles(dlg,g);
  FreeGroup(g);
}

static void UpdateValidateDlg(Widget wDlg) {
  ValidateDlg dlg;
  Particle p;
  char s[2000];
  Group g,gR;
  XmStringTable xmst;
  XmString xms;
  int i,k;
  Index ix;
  XtPointer xtpDlg;
  XtCallbackList cbl;

  GetValues(wDlg,XmNuserData,&xtpDlg,NULL);
  dlg=(ValidateDlg)xtpDlg;

/*  XmListDeleteAllItems(dlg->wList); */

  xmst=Malloc(sizeof(*xmst)*GroupCount(dlg->w->subset->startupParticles));

  for (k=0,p=Group1st(dlg->w->subset->startupParticles,&ix);p!=NULL;
      p=Next(&ix)) {
    sprintf(s,"%s",p->name);
    xmst[k++]=MakeXmString(s);
  }

  /*XmListAddItems(dlg->wList,xmst,k,0);*/
  SetXmListItems(dlg->wList,xmst,k);
  for (i=0;i<k;i++) XmStringFree(xmst[i]);
  Free(xmst);

  gR=GetActiveReactions(dlg->w->subset);
  g=ValidateReactions(gR,dlg->w->subset->startupParticles);
  gR=FreeGroup(gR);

  XmListDeleteAllItems(dlg->wList2);

  xmst=Malloc(sizeof(*xmst)*GroupCount(g));

  for (k=0,p=Group1st(g,&ix);p!=NULL;p=Next(&ix)) {
    sprintf(s,"%s",p->name);
    xmst[k++]=MakeXmString(s);
  }

  XmListAddItems(dlg->wList2,xmst,k,0);
  for (i=0;i<k;i++) XmStringFree(xmst[i]);
  Free(xmst);

  XtCallCallbacks(dlg->wList2,XmNextendedSelectionCallback,NULL);

  FreeGroup(dlg->missingParticles);
  dlg->missingParticles=g;
}

void DwValidateDlg(Widget wg,View w,int evt,void* obj,void* userData) {
  ValidateDlg dlg=(ValidateDlg)userData;

  if (IsMapped(dlg->wDlg)) UpdateValidateDlg(dlg->wDlg);
}

static void SelectParticles(ValidateDlg dlg,Group g) {
  int i;

  for (i=0;i<GroupCount(dlg->w->subset->startupParticles);i++) {
    if (InGroup(g,GroupAt(dlg->w->subset->startupParticles,i)))
      XmListSelectPos(dlg->wList,i+1,False);
    else XmListDeselectPos(dlg->wList,i+1);
  }
}

static Group GetSelectedParticles(Widget wList,Group gAllParticles) {
  Group g;
  Particle p;
  int i,j,k;
  int positionCount,* positionList;

  g=CreateGroup();

  if (!XmListGetSelectedPos(wList,&positionList,&positionCount))
    return g;

  for (i=0;i<positionCount;i++) {
    GroupAdd(g,GroupAt(gAllParticles,positionList[i]-1));
  }

  XtFree((XtPointer)positionList);

  return g;
}

static void CbRemoveParticles(Widget wg,XtPointer xtpDlg,XtPointer pcbs) {
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Group g;
  Particle p;
  Index ix;

  g=GetSelectedParticles(dlg->wList,dlg->w->subset->startupParticles);

  for (p=Group1st(g,&ix);p!=NULL;p=Next(&ix))
    SetStartupParticle(dlg->w->subset,p,False);

  UndoMark(dlg->w->subset);
  /*UpdateValidateDlg(dlg->wDlg);*/
}

static void CbAddMissingParticles(Widget wg,XtPointer xtpDlg,XtPointer pcbs){
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Group g;
  Particle p;
  Index ix;

  g=GetSelectedParticles(dlg->wList2,dlg->missingParticles);

  for (p=Group1st(g,&ix);p!=NULL;p=Next(&ix))
    SetStartupParticle(dlg->w->subset,p,True);

  UndoMark(dlg->w->subset);
  /*UpdateValidateDlg(dlg->wDlg);*/
}

static void CbCascadeAddParticle(Widget wg,XtPointer xtpDlg,XtPointer pbcs){
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Particle p,p0;
  int k;
  Index ix;

  Widget wMenu;
  Cardinal numChildren;
  WidgetList children;
  XtPointer xtpParticle;

  GetValues(wg,XmNsubMenuId,&wMenu,NULL);
  if (wMenu==NULL) return;

  GetValues(wMenu,
    XmNnumChildren,&numChildren,
    XmNchildren,&children,
    NULL);

  for (k=0;k<numChildren;k++) {
    if (children[k]==NULL) continue;

    GetValues(children[k],XmNuserData,&xtpParticle,NULL);
    p0=(Particle)xtpParticle;
    if (p0==NULL) continue;

    if (XmIsCascadeButton(children[k]) ||
	!strcmp(XtName(children[k]),PB_MASK)) {
      XtSetSensitive(children[k],False);
      for (p=Group1st(dlg->w->db->particles,&ix);p!=NULL;p=Next(&ix))
	if (IsSubclassedParticle(p,p0,False) &&
	    !IsStartupParticle(dlg->w->subset,p)) {
	  XtSetSensitive(children[k],True);
	  break;
	}
    } else XtSetSensitive(children[k],
	!IsStartupParticle(dlg->w->subset,p0));
  }
}

static void CbCascadeSelectParticle(Widget wg,XtPointer xtpDlg,
    XtPointer pbcs){
  ValidateDlg dlg=(ValidateDlg)xtpDlg;
  Particle p,p0;
  int k;
  Index ix;

  Widget wMenu;
  Cardinal numChildren;
  WidgetList children;
  XtPointer xtpParticle;

  GetValues(wg,XmNsubMenuId,&wMenu,NULL);
  if (wMenu==NULL) return;

  GetValues(wMenu,
    XmNnumChildren,&numChildren,
    XmNchildren,&children,
    NULL);

  for (k=0;k<numChildren;k++) {
    if (children[k]==NULL) continue;

    GetValues(children[k],XmNuserData,&xtpParticle,NULL);
    p0=(Particle)xtpParticle;
    if (p0==NULL) continue;

    if (XmIsCascadeButton(children[k]) ||
	!strcmp(XtName(children[k]),PB_MASK)) {
      XtSetSensitive(children[k],False);
      for (p=Group1st(dlg->w->subset->startupParticles,&ix);p!=NULL;
	  p=Next(&ix))
	if (IsSubclassedParticle(p,p0,False)) {
	  XtSetSensitive(children[k],True);
	  break;
	}
    } else XtSetSensitive(children[k],
	IsStartupParticle(dlg->w->subset,p0));
  }
}


