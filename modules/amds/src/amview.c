#include "amds.h"

#define R_XOFFSET "xOffset"
#define R_YOFFSET "yOffset"

#define SH_PRIMARY "primaryShell"
#define SH_SECONDARY "secondaryShell"

typedef struct _DependentWidget {
  Widget widget;
  int eventMask;
  DwNotifyProc notifyProc;
  void* userData;
}* DependentWidget;

static void CreateReactionTypeMenu(View w,Widget wCb,XtCallbackProc
    cbCascade,XtCallbackProc cbActivate);
static void CbCascadeRestrictInput(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbCascadeRestrictOutput(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbCascadeExpandInput(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbCascadeExpandOutput(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbCascadeForbidParticle(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbCascadeRestrictType(Widget,XtPointer xtpV,XtPointer pcbs);
static void CbDestroyView(Widget wg,XtPointer xtpView,XtPointer pcbs);
static void CbDisplayText(Widget wg,XtPointer xtpView,XtPointer pcbs);
static void CbListSelection(Widget wg,XtPointer xtpView,XtPointer pcbs);
static void CbGoto(Widget wg,XtPointer xtpView,XtPointer pcbs);
static void CbGotoCascade(Widget wg,XtPointer xtpView,XtPointer pcbs);

static void CbDestroyDependentWidget(Widget wg,XtPointer arg,XtPointer pcbs);
static void AddDwUndoButton(Widget wg,XtPointer w,XtPointer bRedo);
static void AddDwTrackDelete(Widget wg,XtPointer w,XtPointer obj);

static void DwListUpdate(Widget wg,View w,int evt,void* obj,void* userData);
static void DwViewUpdate(Widget wg,View w,int evt,void* obj,void* userData);

View CreateView(XApp xapp,Doc ss,View mainView) {
  View w;
  Widget wMenu,wHelpMenu,wMainParent,wGotoMenu,
    wRestrictInput,wRestrictOutput,wRestrictType,wForbidParticle;
  Position x,y;
  int i;

  w=Malloc(sizeof(*w));
  w->xapp=xapp;
  w->db=ss->db;
  w->subset=ss;
  w->mainView=mainView;
  w->dependentWidgets=CreateGroup();
  w->dirty=1;

  if (mainView==NULL) {
    wMainParent=w->wShell=XtCreatePopupShell(SH_PRIMARY,
      applicationShellWidgetClass,xapp->wShell,NULL,0);
  } else {
    wMainParent=Cw(XmCreateFormDialog,mainView->wShell /*wMain*/,SH_SECONDARY,
      XmNresizePolicy,XmRESIZE_NONE,
      NULL);
    w->wShell=XtParent(wMainParent);

    /*w->wShell=XtCreatePopupShell(SH_SECONDARY,
      xmDialogShellWidgetClass,w->mainView->wShell,NULL,0);*/
/*    SetValues(w->wShell,XmNtransient,True,NULL);*/

/*    GetValues(mainView->wShell,
      XmNx,&x,
      XmNy,&y,
      NULL); */

/*    w->wShell=Cw(XmCreateDialogShell,w->mainView->wShell,SH_SECONDARY, */
      /*XmNtransient,False,*/
      /* XmNwindowGroup,XtWindow(mainView->wShell), */
/*      XmNx,x+GetResourceInt(w->mainView->wShell,R_XOFFSET,R_XOFFSET,10),
      XmNy,y+GetResourceInt(w->mainView->wShell,R_YOFFSET,R_YOFFSET,10),
*/    /*    NULL); */
  }

  SetValues(w->wShell,XmNdeleteResponse,XmDO_NOTHING,NULL);
  XmAddWMProtocolCallback(w->wShell,w->xapp->wm_del_window,
    CbCloseView,w);

  w->wMain=Cmw(XmCreateMainWindow,wMainParent,"main",
    XmNtopAttachment,XmATTACH_FORM,
    XmNbottomAttachment,XmATTACH_FORM,
    XmNleftAttachment,XmATTACH_FORM,
    XmNrightAttachment,XmATTACH_FORM,
    NULL);

  wMenu=Cmw(XmCreateMenuBar,w->wMain,"menu",
    NULL);
  SetValues(w->wMain,XmNmenuBar,wMenu,NULL);

  if (mainView==NULL) {
    CreateMenuSystem(wMenu,
      "c:file",
      "+:fileMenu",
      "bA:new",CbFileNew,w,
      "bA:open",CbFileOpen,w,
      "bA:saveAs",CbFileSave,w,
      "s:separ",
      "bA:output",CbFileOutput,w,
      "s:separ",
/*      "c:template",
      "+:templateMenu",
      "bA:templateFile",CbNewFromTemplate,w,
      "-:", */

      "bA:newSubset",CbNewView,w,
      "bA:cloneSubset",CbCloneView,w,
      "s:separ",
      "bA:close",CbCloseView,w,
      "s:separ",
      "bA:quit",CbFileQuit,w,
      "-:",
      "c:edit",
      "+:editMenu",
      "bA>:undo",CbEditUndo,w,AddDwUndoButton,w,NULL,
      "bA>:redo",CbEditRedo,w,AddDwUndoButton,w,(void*)1,
      "bA>:redoAll",CbEditRedoAll,w,AddDwUndoButton,w,(void*)1,
      "s:separ",
      "bA:cut",CbCut,w,
      "bA:copy",CbCopy,w,
      "bA:crop",CbCrop,w,
/*      "c:paste",
      "+:pasteMenu", */
      "bA:paste",CbPasteOr,w,
/*      "bA:and",CbPasteAnd,w,
      "bA:andNot",CbPasteAndNot,w,
      "-:", */
      "s:separ",
      "cC:goto",CbGotoCascade,w,
      "+:gotoMenu",
      "-:",
      "-:",
      "c:reaction",
      "+:reactionMenu",
      "bA:displayText",CbShowReactionText,w,
      "bA:displayGraph",CbShowReactionGraph,w,
      "bA:validate",CbValidate,w,
/*      "s:separ",
      "bA:variables",CbEditVars,w, */
      "-:",
      "c:options",
      "+:optionsMenu",
      "bA:setup",CbOptionsSetup,w,
      "-:",
/*      "c:window",
      "+:windowMenu",
      "-:", */
      "c?:help",&wHelpMenu,
      "+:helpMenu",
      "bA:about",CbAbout,w,
      "-:",
      NULL);
    SetValues(wMenu,XmNmenuHelpWidget,wHelpMenu,NULL);
  } else {
    CreateMenuSystem(wMenu,
      "c:subset",
      "+:subsetMenu",
/*      "bA:newSubset",CbNewView,w, */
      "bA:cloneSubset",CbCloneView,w,
      "bA:close",CbCloseView,w,
      "-:",
      "c:edit",
      "+:editMenu",
      "bA>:undo",CbEditUndo,w,AddDwUndoButton,w,NULL,
      "bA>:redo",CbEditRedo,w,AddDwUndoButton,w,(void*)1,
      "bA>:redoAll",CbEditRedoAll,w,AddDwUndoButton,w,(void*)1,
      "s:separ",
      "bA:enable",CbActivate,w,
      "bA:disable",CbDeactivate,w,
      "s:separ",
      "bA:cut",CbCut,w,
      "bA:copy",CbCopy,w,
      "bA:crop",CbCrop,w,
/*      "c:paste",
      "+:pasteMenu", */
      "bA:paste",CbPasteOr,w,
/*      "bA:and",CbPasteAnd,w,
      "bA:andNot",CbPasteAndNot,w,
      "-:",                        */
      "s:separ",
      "cC:goto",CbGotoCascade,w,
      "+:gotoMenu",
      "-:",
      "-:",
      "c:restrict",
      "+:restrictMenu",
      "c?:restrictInput",&wRestrictInput,
      "c?:restrictOutput",&wRestrictOutput,
      "c?:restrictType",&wRestrictType,
      "s:separ",
      "c?:forbidParticle",&wForbidParticle,
      "-:",
      "c:reaction",
      "+:reactionMenu",
      "bA:displayText",CbShowReactionText,w,
      "bA:displayGraph",CbShowReactionGraph,w,
      "-:",
  /*    "c?:help",&wHelpMenu,
      "+:helpMenu",
      "bA:about",CbAbout,w,
      "-:", */
      NULL);
    CreateParticleMenu(w,wRestrictInput,NULL,CbCascadeRestrictInput,
      CbRestrictInput,(XtPointer)w);
    CreateParticleMenu(w,wRestrictOutput,NULL,CbCascadeRestrictOutput,
      CbRestrictOutput,(XtPointer)w);
    CreateParticleMenu(w,wForbidParticle,NULL,CbCascadeForbidParticle,
      CbForbidParticle,(XtPointer)w);
    CreateReactionTypeMenu(w,wRestrictType,CbCascadeRestrictType,
      CbRestrictType);
  }

  w->wList=Cmw(XmCreateScrolledList,w->wMain,"list",
    NULL);
  XtAddCallback(w->wList,XmNdefaultActionCallback,CbDisplayText,w);
  XtAddCallback(w->wList,XmNsingleSelectionCallback,CbListSelection,w);
  XtAddCallback(w->wList,XmNbrowseSelectionCallback,CbListSelection,w);
  XtAddCallback(w->wList,XmNmultipleSelectionCallback,CbListSelection,w);
  XtAddCallback(w->wList,XmNextendedSelectionCallback,CbListSelection,w);

  w->rdWidth=GetResourceInt(w->wMain,"databaseWidth","Width",0);
  w->rsWidth=GetResourceInt(w->wMain,"sectionWidth","Width",0);
  w->rnWidth=GetResourceInt(w->wMain,"numberWidth","Width",0);
  w->riWidth=GetResourceInt(w->wMain,"inputWidth","Width",0);
  w->bGroupParticles=GetResourceInt(w->wMain,"groupParticles","Group",1);

  GroupAdd(w->xapp->views,w);
  GroupAdd(w->subset->views,w);

  AddDependentWidget(w,w->wList,N_NOW | N_ENABLE | N_ALT,DwListUpdate,NULL);
  AddDependentWidget(w,w->wMain,N_NOW | N_ALT,DwViewUpdate,NULL);

  XtManageChild(wMainParent);
  if (mainView==NULL) {
    XtRealizeWidget(w->wShell);
    XtPopup(w->wShell,XtGrabNone);
  }

  return w;
}

void* FreeView(View w) {
  View w1;
  Index ix;

  for (w1=Group1st(w->xapp->views,&ix);w1!=NULL;w1=Next(&ix))
    if (w1->mainView==w) {w1->wShell=NULL;FreeView(w1);}

  while (!IsEmptyGroup(w->dependentWidgets))
    DelDependentWidget(w,((DependentWidget)
	Group1st(w->dependentWidgets,NULL))->widget);
  assert(IsEmptyGroup(w->dependentWidgets));
  w->dependentWidgets=FreeGroup(w->dependentWidgets);

  GroupDel(w->subset->views,w);
  GroupDel(w->xapp->views,w);
  if (w->wShell!=NULL) XtDestroyWidget(w->wShell);

  /*if (IsEmptyGroup(w->xapp->views)) exit(0);*/

  Free(w);
  return NULL;
}

Group GetSelectedReactions(View w) {
  Group g;
  Reaction r;
  int i,j,k;
  int positionCount,* positionList;

  g=CreateGroup();

  if (!XmListGetSelectedPos(w->wList,&positionList,&positionCount))
    return g;

  for (i=j=k=0;i<w->subset->reactionCount;i++) {
    if (ReactionActive(w->subset,r=w->subset->data[i].r)) {
      j++;
      if (k<positionCount && j==positionList[k]) {GroupAdd(g,r);k++;}
    }
  }
  XtFree((XtPointer)positionList);

  return g;
}


void DwUndoButton(Widget wg,View w,int evt,void* obj,void* userData) {
  if (userData==NULL)
    XtSetSensitive(wg,!!GroupCount(w->subset->undoStack));
  else
    XtSetSensitive(wg,!!GroupCount(w->subset->redoStack));
}

void DwTrackDelete(Widget wg,View w,int evt,void* obj,void* userData) {
  if (evt==N_DEL && obj==userData)
    XtDestroyWidget(wg);
}

static void UpdateViewList(View w) {
  int i,j,k,l0;
  Reaction r;
  Particle p;
  Index ix,ix1;

  char s[2000],s1[100];
  XmString xms;
  XmStringTable xmst;

  assert(w->wList!=NULL);

  /*XmListDeleteAllItems(w->wList);*/

  xmst=Malloc(sizeof(*xmst)*w->subset->reactionCount);

  for (k=0,r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
      if (ReactionActive(w->subset,r)) {

    *s=0;

    sprintf(s,"%-*s %-*s %-*s : ",
      w->rdWidth,GetReactionDatabase(r),
      w->rsWidth,GetReactionSection(r),
      w->rnWidth,GetReactionNumber(r));

    l0=strlen(s);

    for (j=0,p=Group1st(w->bGroupParticles? r->inputSet : r->input,&ix1);
	p!=NULL;p=Next(&ix1)) {
      if (j++) strcat(s," + ");

      if (w->bGroupParticles) {
	i=InGroupCount(r->input,p);
	if (i>1) {
	  sprintf(s1,"%d",i);
	  strcat(s,s1);
	}
      }

      if (!InGroup(w->subset->data[r->number].enabled,p)) {
	strcat(s,"[");
	strcat(s,p->name);
	strcat(s,"]");
      } else
	strcat(s,p->name);
    }

    for (l0=strlen(s)-l0;l0<w->riWidth;l0++) strcat(s," ");

    strcat(s," -> ");

    for (j=0,p=Group1st(w->bGroupParticles? r->outputSet : r->output,&ix1);
	p!=NULL;p=Next(&ix1)) {
      if (j++) strcat(s," + ");

      if (w->bGroupParticles) {
	i=InGroupCount(r->output,p);
	if (i>1) {
	  sprintf(s1,"%d",i);
	  strcat(s,s1);
	}
      }

      strcat(s,p->name);
    }
    xmst[k++]=XmStringCreateLocalized(s);
  }

  /*XmListAddItems(w->wList,xmst,k,0);*/
  SetXmListItems(w->wList,xmst,k);
  for (i=0;i<k;i++) XmStringFree(xmst[i]);
  Free(xmst);
}

void NotifyView(View w,int msg,void* obj) {
  DependentWidget dw;
  Index ix;

  for (dw=Group1st(w->dependentWidgets,&ix);dw!=NULL;dw=Next(&ix)) {
    if (~dw->eventMask & msg) continue;
    dw->notifyProc(dw->widget,w,msg,obj,dw->userData);
  }
}


void AddDependentWidget(View w,Widget wg,int eventMask,
    DwNotifyProc notifyProc,void* userData) {
  DependentWidget dw;

  dw=Malloc(sizeof(*dw));
  dw->widget=wg;
  dw->eventMask=eventMask;
  dw->notifyProc=notifyProc;
  dw->userData=userData;
  XtAddCallback(wg,XmNdestroyCallback,CbDestroyDependentWidget,w);
  GroupAdd(w->dependentWidgets,dw);

  if (eventMask & N_NOW) notifyProc(wg,w,N_NOW,NULL,userData);
}

void DelDependentWidgetEx(View w,Widget wg,int bWidgetDestroyed) {
  DependentWidget dw;
  Index ix;

  for (dw=Group1st(w->dependentWidgets,&ix);dw!=NULL;dw=Next(&ix)) {
    if (dw->widget==wg) {
      GroupDel(w->dependentWidgets,dw);
      dw=Free(dw);
    }
  }
  if (!bWidgetDestroyed)
    XtRemoveCallback(wg,XmNdestroyCallback,CbDestroyDependentWidget,w);
}

static void AddParticleButton(Widget wParent,Particle p,int bAll,
    XtCallbackProc cbActivate,XtPointer userData) {
  Widget wg=Cmw(XmCreatePushButton,wParent,bAll? PB_MASK : p->name,
    XmNuserData,(XtPointer)p,
    NULL);
  XtAddCallback(wg,XmNactivateCallback,cbActivate,userData);
}


void CreateParticleMenu(View w,Widget wCb,Particle pUp,XtCallbackProc
    cbCascade,XtCallbackProc cbActivate,XtPointer userData) {
  int i,j,k;
  Particle p;
  Index ix;
  Widget wMenu=NULL,wg1;

  wMenu=Cw(XmCreatePulldownMenu,XtParent(wCb),"subClasses",
    NULL);
  SetValues(wCb,XmNsubMenuId,wMenu,NULL);
  if (cbCascade!=NULL)
      XtAddCallback(wCb,XmNcascadingCallback,cbCascade,userData);

  if (pUp!=NULL) {
    AddParticleButton(wMenu,pUp,True,cbActivate,userData);
    Cmw(XmCreateSeparator,wMenu,"separ",NULL);
    AddParticleButton(wMenu,pUp,False,cbActivate,userData);
  }

  for (p=Group1st(w->db->particles,&ix);p!=NULL;p=Next(&ix)) {
    if (!IsSubclassedParticle(p,pUp,True)) continue;

    if (!IsEmptyGroup(p->subClasses)) {
      wg1=Cmw(XmCreateCascadeButton,wMenu,p->name,
	XmNuserData,(XtPointer)p,
	NULL);
      CreateParticleMenu(w,wg1,p,cbCascade,cbActivate,userData);
    } else AddParticleButton(wMenu,p,False,cbActivate,userData);
  }
}

static void CascadeParticleMenu(Widget wg,View w,int bShown,int bInput) {
  Particle p;
  int i,j,k;

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
    p=(Particle)xtpParticle;
    if (p==NULL) continue;

    XtSetSensitive(children[k],False);
    for (i=0;i<w->subset->reactionCount;i++)
      if (!!(ReactionActive(w->subset,w->subset->data[i].r))==!!bShown
	  && ParticleInReaction(p,
	  w->subset->data[i].r,bInput,
	  !strcmp(XtName(children[k]),PB_MASK) ||
	  XmIsCascadeButton(children[k]))) {
	XtSetSensitive(children[k],True);
	break;
      }
  }
}

static void CbCascadeRestrictInput(Widget wg,XtPointer xtpV,XtPointer p) {
  CascadeParticleMenu(wg,(View)xtpV,True,True);
}

static void CbCascadeRestrictOutput(Widget wg,XtPointer xtpV,XtPointer p) {
  CascadeParticleMenu(wg,(View)xtpV,True,False);
}

static void CbCascadeExpandInput(Widget wg,XtPointer xtpV,XtPointer p) {
  CascadeParticleMenu(wg,(View)xtpV,False,True);
}

static void CbCascadeExpandOutput(Widget wg,XtPointer xtpV,XtPointer p) {
  CascadeParticleMenu(wg,(View)xtpV,False,False);
}

static void CbCascadeForbidParticle(Widget wg,XtPointer xtpV,
    XtPointer pcbs) {
  View w=(View)xtpV;
  Reaction r;
  Particle p;
  int i,j,k;

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
    p=(Particle)xtpParticle;
    if (p==NULL) continue;

    XtSetSensitive(children[k],False);
    for (i=0;i<w->subset->reactionCount;i++) {
      if (!ReactionActive(w->subset,w->subset->data[i].r)) continue;
      r=w->subset->data[i].r;
      if (ParticleInReaction(p,
	  r,True,!strcmp(XtName(children[k]),PB_MASK) ||
	  XmIsCascadeButton(children[k])) || ParticleInReaction(p,
	  r,False,!strcmp(XtName(children[k]),PB_MASK) ||
	  XmIsCascadeButton(children[k]))) {
	XtSetSensitive(children[k],True);
	break;
      }
    }
  }
}

static void CreateReactionTypeMenu(View w,Widget wCb,XtCallbackProc
    cbCascade,XtCallbackProc cbActivate) {
  int i,j,k;
  ReactionType rt;
  Index ix;
  Widget wMenu=NULL,wg1;

  wMenu=Cw(XmCreatePulldownMenu,XtParent(wCb),"reactionTypesMenu",
    NULL);
  SetValues(wCb,XmNsubMenuId,wMenu,NULL);
  XtAddCallback(wCb,XmNcascadingCallback,cbCascade,w);

  for (rt=Group1st(w->db->reactionTypes,&ix);rt!=NULL;rt=Next(&ix)) {
    wg1=Cmw(XmCreatePushButton,wMenu,rt->name,
      XmNuserData,rt,
      NULL);
    XtAddCallback(wg1,XmNactivateCallback,cbActivate,w);
  }
}

static void CbCascadeRestrictType(Widget wg,XtPointer xtpV,XtPointer p) {
  View w=(View)xtpV;
  int i,j,k;
  ReactionType rt;

  Widget wMenu;
  Cardinal numChildren;
  WidgetList children;
  XtPointer xtpReactionType;

  GetValues(wg,XmNsubMenuId,&wMenu,NULL);
  if (wMenu==NULL) return;

  GetValues(wMenu,
    XmNnumChildren,&numChildren,
    XmNchildren,&children,
    NULL);

  for (k=0;k<numChildren;k++) {
    if (children[k]==NULL) continue;

    GetValues(children[k],XmNuserData,&xtpReactionType,NULL);
    rt=(ReactionType)xtpReactionType;
    if (rt==NULL) continue;

    XtSetSensitive(children[k],False);
    for (i=0;i<w->subset->reactionCount;i++)
      if (ReactionActive(w->subset,w->subset->data[i].r) &&
	  InGroup(w->subset->data[i].r->types,rt)) {
	XtSetSensitive(children[k],True);
	break;
      }
  }
}

static void CbDisplayText(Widget wg,XtPointer xtpView,XtPointer pcbs) {
  View w=(View)xtpView;
  XmListCallbackStruct* lcbs=(XmListCallbackStruct*)pcbs;
  int i,j;

  for (j=i=0;i<w->subset->reactionCount;i++)
      if (ReactionActive(w->subset,w->subset->data[i].r)) {
    if (++j==lcbs->item_position) {
      DisplayReactionText(w,w->subset->data[i].r);
      return;
    }
  }
}

static void AddDwUndoButton(Widget wg,XtPointer w,XtPointer bRedo) {
  AddDependentWidget((View)w,wg,N_NOW | N_ALT,DwUndoButton,bRedo);
}

static void AddDwTrackDelete(Widget wg,XtPointer w,XtPointer obj) {
  AddDependentWidget((View)w,wg,N_DEL,DwTrackDelete,obj);
}

static void CbDestroyDependentWidget(Widget wg,XtPointer arg,XtPointer pcbs){
  View w=(View)arg;

  DelDependentWidgetEx(w,wg,True);
}

static void DwListUpdate(Widget wg,View w,int evt,void* obj,void* ud) {
  switch(evt) {
    case N_ALT:
      if (!w->dirty) return;
    case N_NOW:
      w->dirty=0;
      UpdateViewList(w);
      break;
    case N_ENABLE:
      w->dirty++;
      break;
    default:
      assert(0);
  }
}

static void DwViewUpdate(Widget wg,View w,int evt,void* obj,void* uD) {
  char* s;

  if (w->mainView!=NULL) return;

  if (w->subset->fileName==NULL || !*w->subset->fileName)
    s=GetResourceString(w->wMain,"dialogTitle","DialogTitle","");
  else s=GetResourceStringEx(w->wMain,"dialogTitleEx","DialogTitle",
    "$(FILENAME)%s",GetShortFName(w->subset->fileName));

  SetValues(w->wShell,XmNtitle,s,NULL);
  SetValues(w->wShell,XmNiconName,s,NULL);
}

static void CbListSelection(Widget wg,XtPointer xtpView,XtPointer pcbs) {
  View w=(View)xtpView;

  NotifyView(w,N_SEL,NULL);
}


static char* AltReactionName(Reaction r) {
  static char s[256];
  char* s1,*s2;

  strcpy(s,GetReactionDatabase(r));
  strcat(s," ");
  strcat(s,GetReactionSection(r));
  strcat(s," ");
  for (s1=GetReactionNumber(r),s2=s+strlen(s);*s1;)
    if ((*s2++=*s1++)=='.') *s2++=' ';
  *s2++=' ';
  *s2++=0;

  return s;
}

static void AddGotoLevel(View w,Widget wMenu,Reaction r,char* rStr) {
  char s[256];
  char* s1,*s2;
  Widget wg,wM;
  XmString xms;

  s1=strtok(rStr," ");
  strcpy(s,s1);
  for (s2=s;*s2;s2++) if (*s2=='.') *s2='_';
  s2=strtok(NULL,"");

  wg=XtNameToWidget(wMenu,s);
  if (wg==NULL) {
    if (s2!=NULL) {
      wg=Cmw(XmCreateCascadeButton,wMenu,s,NULL);
      wM=Cw(XmCreatePulldownMenu,wMenu,"gotoSubmenu",NULL);
      xms=MakeXmString(s1);
      SetValues(wg,
	XmNsubMenuId,wM,
	XmNlabelString,xms,
      NULL);
      XmStringFree(xms);
      AddGotoLevel(w,wM,r,s2);
    } else {
      xms=MakeXmString(s1);
      wg=Cmw(XmCreatePushButton,wMenu,s,
	XmNlabelString,xms,
	XmNuserData,(XtPointer)r,
	NULL);
      XmStringFree(xms);
      XtAddCallback(wg,XmNactivateCallback,CbGoto,w);
    }
  } else {
    if (XmIsCascadeButton(wg)) {
      GetValues(wg,XmNsubMenuId,&wM,NULL);
      assert(wM!=NULL);
      AddGotoLevel(w,wM,r,s2);
    }
  }
}

static void CreateGotoMenu(View w,Widget wMenu) {
  Reaction r;
  Index ix;
  Widget wg,wM1;
  char s[2048],*s1,*s2;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    strcpy(s,GetReactionDatabase(r));
    strcat(s," ");
    strcat(s,GetReactionSection(r));
    strcat(s," ");
    for (s1=GetReactionNumber(r),s2=s+strlen(s);*s1;)
      if ((*s2++=*s1++)=='.') *s2++=' ';
    *s2++=0;
    AddGotoLevel(w,wMenu,r,s);
  }
}

static void CbGoto(Widget wg,XtPointer xtpView,XtPointer pcbs) {
  View w=(View)xtpView;
  Reaction r;
  XtPointer xtp;
  Group g;
  int i;

  GetValues(wg,XmNuserData,&xtp,NULL);
  r=(Reaction)xtp;

  g=GetActiveReactions(w->subset);
  if (!InGroup(g,r)) i=-1; else
  i=GroupIndex(g,r);
  FreeGroup(g);
  if (i<0) return;

  XmListSetPos(w->wList,i+1);
  XmListSetKbdItemPos(w->wList,i+1);
}

static void CbGotoCascade(Widget wg,XtPointer xtpView,XtPointer pcbs) {
  View w=(View)xtpView;
  char* baseName,*s,*s1,s2[256],*ps2;
  Widget wM,wM1,wg1;
  Reaction r;
  XmString xms;
  WidgetList children;
  Cardinal numChildren;
  Group g;
  Index ix;
  int i;
  XtPointer xtp;

  GetValues(wg,
    XmNuserData,&xtp,
    XmNsubMenuId,&wM,
    NULL);
  baseName=xtp==NULL? "" : (char*)xtp;
  assert(wM!=NULL);

  GetValues(wM,
    XmNnumChildren,&numChildren,
  NULL);
  if (numChildren) goto setSensitive;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    s=AltReactionName(r);
    if (strncmp(baseName,s,strlen(baseName))) continue;

    s=strtok(s+strlen(baseName)," ");
    assert(s!=NULL && *s);
    s1=strtok(NULL," ");

    strcpy(s2,s);
    for (i=0;s2[i];i++) if (s2[i]=='.') s2[i]='_';

    if ((wg1=XtNameToWidget(wM,s2))!=NULL) continue;

    xms=MakeXmString(s);

    if (s1==NULL || !*s1) {
      wg1=Cmw(XmCreatePushButton,wM,s2,
	XmNlabelString,xms,
	XmNuserData,(XtPointer)r,
	NULL);
      XtAddCallback(wg1,XmNactivateCallback,CbGoto,(XtPointer)w);
    } else {
      wM1=Cw(XmCreatePulldownMenu,wM,"gotoSubmenu",NULL);
      wg1=Cmw(XmCreateCascadeButton,wM,s2,
	XmNlabelString,xms,
	XmNsubMenuId,wM1,
	NULL);
      XtAddCallback(wg1,XmNcascadingCallback,CbGotoCascade,(XtPointer)w);

      if (*baseName) {
	strcpy(s2,baseName);
      } else strcpy(s2,"");
      strcat(s2,s);
      strcat(s2," ");
      ps2=MallocString(s2);
      SetValues(wg1,XmNuserData,(XtPointer)ps2,NULL);
      XtAddCallback(wg1,XmNdestroyCallback,CbFree,ps2);
    }
    XmStringFree(xms);
  }

  setSensitive:

  GetValues(wM,
    XmNchildren,&children,
    XmNnumChildren,&numChildren,
  NULL);
  for (i=0;i<numChildren;i++) XtSetSensitive(children[i],False);
  g=GetActiveReactions(w->subset);
  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix)) {
    s=AltReactionName(r);
    for (i=0;i<numChildren;i++) {
      GetValues(children[i],XmNuserData,&xtp,NULL);
      if (XmIsCascadeButton(children[i])) {
	s1=(char*)xtp;
	if (!strncmp(s,s1,strlen(s1)) && !XtIsSensitive(children[i]))
	  XtSetSensitive(children[i],True);
      } else {
	if ((Reaction)xtp==r && !XtIsSensitive(children[i]))
	  XtSetSensitive(children[i],True);
      }
    }
  }
  FreeGroup(g);
}
