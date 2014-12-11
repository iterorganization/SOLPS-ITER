/* Menu callbacks */

#include "amds.h"

void CbFileNew(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w0=(View) xtpV;
  NewView(w0->xapp);
}

void CbFileOpen(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View) xtpV;

  OpenFileOpenDlg(w);
}

void CbFileSave(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View) xtpV;

  OpenFileSaveDlg(w,False);
}

void CbFileOutput(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View) xtpV;

  OpenFileOutputDlg(w);
}

void CbFileQuit(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View) xtpV;
  Index ix;

  for (w=Group1st(w->xapp->views,&ix);w!=NULL;w=Next(&ix))
    CloseView(w,w->mainView==NULL);
}


void CbRestrictInput(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Reaction r;
  Particle p;
  Index ix;
  int i,bSubclass;

  XtPointer xtpParticle;

  GetValues(wg,XmNuserData,&xtpParticle,NULL);
  p=(Particle)xtpParticle;
  if (p==NULL) return;
  bSubclass=!strcmp(XtName(wg),PB_MASK);

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (!ParticleInReaction(p,r,True,bSubclass)) {
      ActivateReaction(w->subset,r,NULL,False);
    };

  UndoMark(w->subset);
}

void CbRestrictOutput(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Particle p;
  Reaction r;
  Index ix;
  int i,bSubclass;

  XtPointer xtpParticle;

  GetValues(wg,XmNuserData,&xtpParticle,NULL);
  p=(Particle)xtpParticle;
  if (p==NULL) return;
  bSubclass=!strcmp(XtName(wg),PB_MASK);

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (!ParticleInReaction(p,r,False,bSubclass)) {
      ActivateReaction(w->subset,r,NULL,False);
    }

  UndoMark(w->subset);
}

void CbForbidParticle(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Particle p;
  Reaction r;
  Index ix;
  int i,bSubclass;

  XtPointer xtpParticle;

  GetValues(wg,XmNuserData,&xtpParticle,NULL);
  p=(Particle)xtpParticle;
  if (p==NULL) return;
  bSubclass=!strcmp(XtName(wg),PB_MASK);

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (ParticleInReaction(p,r,False,bSubclass) ||
	ParticleInReaction(p,r,True,bSubclass)) {
      ActivateReaction(w->subset,r,NULL,False);
    }

  UndoMark(w->subset);
}

void CbRestrictType(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  int i;
  ReactionType rt;
  Reaction r;
  Index ix;
  XtPointer xtpReactionType;

  GetValues(wg,XmNuserData,&xtpReactionType,NULL);
  rt=(ReactionType)xtpReactionType;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (!InGroup(r->types,rt))
      ActivateReaction(w->subset,r,NULL,False);

  UndoMark(w->subset);
}


void CbEditUndo(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  Undo(w->subset);
}

void CbEditRedo(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  Redo(w->subset);
}

void CbEditRedoAll(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  while (!IsEmptyGroup(w->subset->redoStack)) Redo(w->subset);
}


void CbActivate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Group g;
  Reaction r;
  Index ix;

  assert(w->mainView!=NULL);

  g=GetSelectedReactions(w);

  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix))
    CopyReaction(w->subset,w->mainView->subset,r,True);
  FreeGroup(g);

  UndoMark(w->mainView->subset);
}

void CbDeactivate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Group g;
  Reaction r;
  Index ix;

  assert(w->mainView!=NULL);

  g=GetSelectedReactions(w);

  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix))
    ActivateReaction(w->mainView->subset,r,NULL,False);
  FreeGroup(g);

  UndoMark(w->mainView->subset);
}

void CbCut(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  int positionCount,* positionList;

  Group g;
  Reaction r;
  Index ix;

  ClearDoc(w->xapp->clipboard);

  g=GetSelectedReactions(w);

  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix)) {
    CopyReaction(w->subset,w->xapp->clipboard,r,True);
    ActivateReaction(w->subset,r,NULL,False);
  }
  FreeGroup(g);

  UndoMark(w->subset);
  UndoMark(w->xapp->clipboard);
}

void CbCopy(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  int positionCount,* positionList;

  Group g;
  Reaction r;
  Index ix;

  ClearDoc(w->xapp->clipboard);

  g=GetSelectedReactions(w);

  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix))
    CopyReaction(w->subset,w->xapp->clipboard,r,True);

  FreeGroup(g);

  UndoMark(w->xapp->clipboard);
}

void CbCrop(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  int i,j,k;
  int positionCount,* positionList;

  Group g;
  Reaction r;
  Index ix;

  ClearDoc(w->xapp->clipboard);

  g=GetSelectedReactions(w);

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix))
      if (!InGroup(g,r)) {
    CopyReaction(w->subset,w->xapp->clipboard,r,True);
    ActivateReaction(w->subset,r,NULL,False);
  }
  FreeGroup(g);

  UndoMark(w->subset);
  UndoMark(w->xapp->clipboard);
}

void CbPasteOr(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Reaction r;
  Index ix;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    if (ReactionActive(w->xapp->clipboard,r))
      CopyReaction(w->xapp->clipboard,w->subset,r,True);
  }

  UndoMark(w->subset);
}

void CbPasteAnd(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Reaction r;
  Index ix;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    if (ReactionActive(w->xapp->clipboard,r))
      if (ReactionActive(w->subset,r))
	CopyReaction(w->xapp->clipboard,w->subset,r,True);
      else ActivateReaction(w->subset,r,NULL,False);
  }
  UndoMark(w->subset);
}

void CbPasteAndNot(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Reaction r;
  Index ix;

  for (r=Group1st(w->db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    if (ReactionActive(w->xapp->clipboard,r))
      if (!ReactionActive(w->subset,r))
	CopyReaction(w->xapp->clipboard,w->subset,r,True);
      else ActivateReaction(w->subset,r,NULL,False);
  }
  UndoMark(w->subset);
}

void CbOptionsSetup(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenSetupWarningDlg(w);
}

void CbNewView(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w0=(View)xtpV,w;
  Doc ss;
  Reaction r;
  Index ix;

  ss=CreateDoc(w0->db);
  CopyDoc(w0->subset,ss);
  for (r=Group1st(w0->db->reactions,&ix);r!=NULL;r=Next(&ix))
    ActivateReaction(ss,r,NULL,True);

  w=CreateView(w0->xapp,ss,w0->mainView!=NULL ? w0->mainView:w0);
  FreeUndoInfo(w->subset);
}

void CbCloneView(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w0=(View)xtpV;
  Doc ss;
  View w;

  ss=CreateDoc(w0->db);
  CopyDoc(w0->subset,ss);

  w=CreateView(w0->xapp,ss,w0->mainView!=NULL ? w0->mainView:w0);
  UndoMark(w->subset);
  FreeUndoInfo(w->subset);
}

void CbCloseView(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  CloseView(w,w->mainView==NULL);
}


void CbNewFromTemplate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  XtPointer xtp;

  GetValues(wg,XmNuserData,&xtp,NULL);
  if (xtp!=NULL) return;

  OpenFileTemplateDlg(w);
}

void CbShowReactionText(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  Group g;
  int i,j,k;
  int positionCount,* positionList;

  g=GetSelectedReactions(w);
  if (GroupCount(g)==1) DisplayReactionText(w,Group1st(g,NULL));
  FreeGroup(g);
}

void CbShowReactionGraph(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenGraphDlg(w);
}

void CbValidate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenValidateDlg(w);
}

void CbCloseSubviews(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w0=(View)xtpV;
  View w;
  Index ix;

  for (w=Group1st(w0->xapp->views,&ix);w!=NULL;w=Next(&ix))
    if (w->mainView==w0) CloseView(w,False);
}

void CbAbout(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  ShowAboutDlg(w);
}

