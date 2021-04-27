#include "amds.h"

#define DLG_FILE_OPEN "dlgFileOpen"
#define DLG_FILE_SAVE "dlgFileSave"
#define DLG_FILE_UNSAVED "dlgFileUnsaved"
#define DLG_FILE_TEMPLATE "dlgFileTemplate"
#define DLG_FILE_OUTPUT "dlgFileOutput"

#define ENV_LOADMASK "AMDSLOADMASK"
#define ENV_SAVEMASK "AMDSSAVEMASK"
#define ENV_OUTPUTMASK "AMDSOUTPUTMASK"
#define ENV_TEMPLATEMASK "AMDSTEMPLATEMASK"

static void CbOpen(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbSave(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbOutput(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbUnsavedSave(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbUnsavedDiscard(Widget wg,XtPointer xtpV,XtPointer pcbs);
static void CbTemplate(Widget wg,XtPointer xtpV,XtPointer pcbs);

static void CbOpenTemplate(Widget wg,XtPointer xtpV,XtPointer pcbs);

Widget OpenFileOpenDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_FILE_OPEN);
  XmString xms;
  String s;

  if (wDlg==NULL) {
    wDlg=Cw(XmCreateFileSelectionDialog,w->wMain,DLG_FILE_OPEN,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbOpen,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmFileSelectionBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));
    s=getenv(ENV_LOADMASK);
    if (s!=NULL) {
      xms=XmStringCreateLocalized(s);
      SetValues(wDlg,XmNdirMask,xms,NULL);
      XmStringFree(xms);
    }

    XtManageChild(wDlg);
  } else {
    XmFileSelectionDoSearch(wDlg,NULL);
    XtPopup(XtParent(wDlg),XtGrabNone);
  }

  return wDlg;
}

Widget OpenFileSaveDlg(View w,int bAtExit) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_FILE_SAVE);
  XmString xms;
  String s;

  if (wDlg==NULL) {
    wDlg=Cw(XmCreateFileSelectionDialog,w->wMain,DLG_FILE_SAVE,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbSave,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmFileSelectionBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

    s=getenv(ENV_SAVEMASK);
    if (s!=NULL) {
      xms=XmStringCreateLocalized(s);
      SetValues(wDlg,XmNdirMask,xms,NULL);
      XmStringFree(xms);
    }

    XtManageChild(wDlg);
  } else {
    XmFileSelectionDoSearch(wDlg,NULL);
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
  SetValues(wDlg,XmNuserData,(XtPointer)bAtExit,NULL);
  if (*w->subset->fileName)
    XmTextSetString(XmFileSelectionBoxGetChild(wDlg,XmDIALOG_TEXT),
	w->subset->fileName);
  return wDlg;
}

Widget OpenFileOutputDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_FILE_OUTPUT);
  XmString xms;
  String s,s1;
  char fn[2048];
  XtPointer xtp;

  if (!*w->subset->fileName) {
    ErrorBox(w->wMain,"No filename");
    return NULL;
  }

  strcpy(fn,w->subset->fileName);
  strcpy(GetFileExt(fn),".amo");

  if (wDlg==NULL) {
    wDlg=Cw(XmCreateQuestionDialog,w->wMain,DLG_FILE_OUTPUT,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbOutput,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));
  }

  s=GetResourceStringEx(wDlg,"messageStringEx","MessageString",
    "$(FILENAME)%s",fn);
  xms=MakeXmString(s);
  SetValues(wDlg,XmNmessageString,xms,NULL);
  XmStringFree(xms);

  XtManageChild(wDlg);
  XtPopup(XtParent(wDlg),XtGrabNone);

  GetValues(wDlg,XmNuserData,&xtp,NULL);
  if (xtp!=NULL) Free((void*)xtp);
  xtp=(XtPointer)MallocString(fn);
  SetValues(wDlg,XmNuserData,xtp,NULL);

  return wDlg;
}

Widget OpenFileUnsavedDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_FILE_UNSAVED),
    wg1;

  if (wDlg==NULL) {
    wDlg=Cw(XmCreateQuestionDialog,w->wMain,DLG_FILE_UNSAVED,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbUnsavedSave,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));
    wg1=Cmw(XmCreatePushButton,wDlg,"discard",
      NULL);
    XtAddCallback(wg1,XmNactivateCallback,CbUnsavedDiscard,w);

    XtManageChild(wDlg);
  } else XtPopup(XtParent(wDlg),XtGrabNone);

  return wDlg;
}

Widget OpenFileTemplateDlg(View w) {
  Widget wDlg=XtNameToWidget(w->wMain,"*"DLG_FILE_TEMPLATE);
  XmString xms;
  String s;

  if (wDlg==NULL) {
    wDlg=Cw(XmCreateFileSelectionDialog,w->wMain,DLG_FILE_TEMPLATE,
      XmNdeleteResponse,XmDO_NOTHING,
      XmNautoUnmanage,NULL,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbTemplate,w);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XmAddWMProtocolCallback(XtParent(wDlg),w->xapp->wm_del_window,
      CbUnmap,NULL);
    XtUnmanageChild(XmFileSelectionBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

    s=getenv(ENV_TEMPLATEMASK);
    if (s!=NULL) {
      xms=XmStringCreateLocalized(s);
      SetValues(wDlg,XmNdirMask,xms,NULL);
      XmStringFree(xms);
    }

    XtManageChild(wDlg);
  } else {
    XmFileSelectionDoSearch(wDlg,NULL);
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
  return wDlg;
}

void CloseView(View w,int bAskUnsaved) {
  Doc ss;
  XApp xap;

  ss=w->subset;
  xap=w->xapp;

  if (bAskUnsaved && ss->alt && GroupCount(ss->views)<2)
      OpenFileUnsavedDlg(w);
  else {
    FreeView(w);
    if (IsEmptyGroup(ss->views)) FreeDoc(ss);
    if (IsEmptyGroup(xap->views)) exit(0);
  }
}


static void CbOpen(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w0=(View)xtpV;
  Doc ss;
  String s;
  int err;

  s=XmTextGetString(XmFileSelectionBoxGetChild(wg,XmDIALOG_TEXT));
  ss=CreateDoc(w0->db);
  err=LoadDoc(ss,s);
  if (err) {
    ErrorBox(w0->wMain,GetResourceStringEx(w0->wMain,"errFileOpen",
      "error",NULL,NULL));
    FreeDoc(ss);
  } else {
    if (w0->xapp->config!=NULL) UpdateVarDefs(ss,w0->xapp->config);
    CreateView(w0->xapp,ss,w0->mainView);
    XtPopdown(XtParent(wg));
  }
  XtFree(s);
}

static void CbSave(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  String s;
  int err;
  XtPointer userData;

  s=XmTextGetString(XmFileSelectionBoxGetChild(wg,XmDIALOG_TEXT));
  GetValues(wg,XmNuserData,&userData,NULL);

  err=SaveDoc(w->subset,s);
  if (err) ErrorBox(w->wMain,GetResourceStringEx(w->wMain,"errFileSave",
    "error",NULL,NULL));
  else {
    XtPopdown(XtParent(wg));
    if ((int)userData) CloseView(w,True);
  }
  XtFree(s);
}

static void CbUnsavedSave(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  OpenFileSaveDlg(w,True);
  XtPopdown(XtParent(wg));
}

static void CbUnsavedDiscard(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;

  CloseView(w,False);
}

static void CbTemplate(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  Doc ss;
  View w0=(View)xtpV,w;
  String s=XmTextGetString(XmFileSelectionBoxGetChild(wg,XmDIALOG_TEXT));
  int err;

  ss=CreateDoc(w0->xapp->db);
  err=LoadDoc(ss,s);
  if (err) {
    FreeDoc(ss);
    ErrorBox(w0->wMain,GetResourceStringEx(w->wMain,"errFileOpen",
    "error",NULL,NULL));
  }
  else {
    if (w0->xapp->config!=NULL) UpdateVarDefs(ss,w0->xapp->config);
    w=CreateView(w0->xapp,ss,w0);
    XtPopdown(XtParent(wg));
  }
}

static void CbOutput(Widget wg,XtPointer xtpV,XtPointer pcbs) {
  View w=(View)xtpV;
  String s;
  int err;
  XtPointer userData;

  GetValues(wg,XmNuserData,&userData,NULL);
  s=(String)userData;

  err=OutputDoc(w->subset,s);
  if (err) ErrorBox(w->wMain,GetResourceStringEx(w->wMain,"errFileOutput",
    "error",NULL,NULL));
  else {
    XtPopdown(XtParent(wg));
    SetValues(wg,XmNuserData,NULL,NULL);
    XtFree(s);
  }
}

void NewView(XApp xap) {
  Doc d;
  View w;

  d=CreateDoc(xap->db);
  if (xap->config!=NULL) LoadDoc(d,xap->config->fileName);
  SetDocFilename(d,"");
  d->alt=0;
  FreeUndoInfo(d);
  w=CreateView(xap,d,NULL);

}
