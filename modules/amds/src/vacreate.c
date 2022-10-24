/* Vacreate - convenient widget creation routines
 * Uses private part of the Core class to determine popup children
 *
 * Changes:
 *
 * 1998/09/30 IsXmTextEmpty() added
 * 1998/09/23 GetXmListSelPos() added
 *            SetOptionMenuItems() added
 * 1998/04/20 GetResourceString[Ex]: "\rXXX" now returns "XXX".
 * 1997/12/09 CbDebugPrint() added
 * 1997/11/02 SetUserData() macro added to vacreate.h
 * 1997/10/22 CreateFormTable() made public
 * 1997/08/27 XmSTRING_DEFAULT_CHARSET replaced by XmSTRING_FONTLIST_DEF.TAG
 * 1997/08/25 assert() is now used in MakeVaArgList() to check for overflows.
 * 1997/07/15 Unclean type conversion from void* to void9)* eliminated.
 * 1997/04/22 GetStaticString() made public
 * 1997/04/21 '&' option added to CreateWidgetSystem
 * 1997/04/09 CDLG_NOSTDCANCEL flag removed instead of a bugfix
 * 1997/04/08 CreateDialogEx() added
 *            CreateOkCancelDialog() re-routed to CreateDialog()
 *            SetLabelString(), SetMessageString() macros added
 * 1997/04/03 Uses Xm/Protocols.h instead of X11/Protocols.h
 * 1997/04/01 CreateOkCancelDialog() added
 * 1997/03/18 Removed extra arg from Get/SetValues() in order to eliminate
 *            problems on Sun's
 * 1997/03/13 SetSensitiveEx() added
 * 1997/03/12 GetUserData() added
 *            NULL class argument now possible in GetResource...()
 *            NULL default argument now possible in GetResourceStr()
 * 1997/03/11 CreateWidgetSystem() allows multiple '5'-style attachments
 */


#define _vacreate_c

/* #define DEBUG_TABLES */
/* #define DEBUG_CWS */
/* #define DEBUG_SETVALUES */

/* Include files //////////////////////////////////////////////////// */

#include <Xm/PushB.h>
#include <Xm/ToggleB.h>
#include <Xm/CascadeB.h>
#include <Xm/Separator.h>
#include <Xm/RowColumn.h>
#include <Xm/MessageB.h>
#include <Xm/PushB.h>
#include <Xm/Label.h>
#include <Xm/Text.h>
#include <Xm/TextF.h>
#include <Xm/Form.h>
#include <Xm/Frame.h>
#include <Xm/Protocols.h>
#include <Xm/List.h>

#include <X11/IntrinsicP.h>
#include <X11/Core.h>
#include <X11/CoreP.h>

#include <stdarg.h>
#include <assert.h>
#include <ctype.h>
#include <limits.h>
#include <float.h>
#include <stdio.h>
#include <stdlib.h>

#include "vacreate.h"

/* Defines/typedefs/internal declarations /////////////////////////// */

#define MAXDOUBLE DBL_MAX
#define MAXINT INT_MAX
#define DLG_ERROR_BOX "errorBox"

#define MAKESTREX_BUF 3000
#define MAKESTREX_CHR '\x1'
#define STATICSTR_LEN 1024
#define STATICSTR_CNT 20

#define CWS_MAX 200

#ifndef min
#define min(x,y) ((x)<(y) ? (x) : (y))
#endif
#ifndef max
#define max(x,y) ((x)>(y) ? (x) : (y))
#endif

typedef Widget (*CreateWidgetFn)(Widget,String,ArgList,Cardinal);

/*typedef void(*_vmsFunc_)(Widget,XtPointer,XtPointer);*/

typedef void(*vmsFunc0)(Widget);
typedef void(*vmsFunc1)(Widget,XtPointer);
typedef void(*vmsFunc2)(Widget,XtPointer,XtPointer);
typedef void(*vmsFunc3)(Widget,XtPointer,XtPointer,XtPointer);
typedef void(*vmsFunc4)(Widget,XtPointer,XtPointer,XtPointer,XtPointer);
typedef void(*vmsFunc5)(Widget,XtPointer,XtPointer,XtPointer,XtPointer,
    XtPointer);

/* Utilities //////////////////////////////////////////////////////// */

static void FatalError(char* s) {
  fprintf(stderr,"%s\n",s);
  fflush(stderr);
  fflush(stdout);
  assert(0);
}

static ArgList MakeVaArgList(va_list* pvl,int* pN) {
  static Arg a[100];
  String p0;
  XtArgVal p1;

#ifdef DEBUG_SETVALUES
  puts("MakeVaArgList");                /* relcheck_ignore_line */
#endif

  *pN=0;

  while(1) {
    p0=va_arg(*pvl,String);
    if (p0==NULL) break;
    p1=va_arg(*pvl,XtArgVal);
    XtSetArg(a[*pN],p0,p1);(*pN)++;
    assert(*pN<=sizeof(a)/sizeof(*a));
  }

  return a;
}

Widget Cw(Widget (*CreateFn)(Widget,String,ArgList,Cardinal),Widget parent,
          void* name,...) {
  Widget wg;
  va_list vl;
  ArgList args;
  int argn;

  va_start(vl,name);
  args=MakeVaArgList(&vl,&argn);
  va_end(vl);

  wg=CreateFn(parent,name,args,argn);

  return wg;
}

Widget Cmw(Widget (*CreateFn)(Widget,String,ArgList,Cardinal),Widget parent,
          void* name,...) {
  Widget wg;
  va_list vl;
  ArgList args;
  int argn;

  va_start(vl,name);
  args=MakeVaArgList(&vl,&argn);
  va_end(vl);

  wg=CreateFn(parent,name,args,argn);
  XtManageChild(wg);
  return wg;
}

void SetValues(Widget wg,...) {
  va_list vl;
  ArgList args;
  int argn;

#ifdef DEBUG_SETVALUES
  puts("SetValues");                    /* relcheck_ignore_line */
#endif

  va_start(vl,wg);
  args=MakeVaArgList(&vl,&argn);
  va_end(vl);

  XtSetValues(wg,args,argn);
}

void GetValues(Widget wg,...) {
  va_list vl;
  ArgList args;
  int argn;

  va_start(vl,wg);
  args=MakeVaArgList(&vl,&argn);
  va_end(vl);

  XtGetValues(wg,args,argn);
}

#define XTPA_MAX 5

static int CreateVaWidgetSystem(Widget parent,int nest,va_list* pvl) {
  String s,strName;
  int bGotoChild;
  Widget w=NULL,wg1,wL,wR,wT,wB;
  int i,j,posCount;
  struct _PosInfo pos[CWS_MAX];
  void* callFn;
  XtPointer pt1,pt2,xtpa[XTPA_MAX];
  XtCallbackProc pcb;
  XtEventHandler peh;
  CreateWidgetFn createFn;
  ArgList args;
  int argn,callArgCount;

  wL=wR=wT=wB=NULL;
  posCount=0;

  while ((s=va_arg(*pvl,String))!=NULL) {
    bGotoChild=False;

#ifdef DEBUG_CWS
    printf("%*s%s\n",nest,"",s);        /* relcheck_ignore_line */
#endif

    for (j=0;s[j] !=':';j++)
      if (!s[j])
        FatalError("CreateWidgetSystem()-missing\':\': fatal error1");
    strName=s+j+1;

    i=0;
    switch(s[i]) {
      case 'x':
        w=Cmw(XmCreateText,parent,strName,NULL);
        break;
      case 't':
        w=Cmw(XmCreateToggleButton,parent,strName,NULL);
        break;
      case 'b':
        w=Cmw(XmCreatePushButton,parent,strName,NULL);
        break;
      case 'c':
        w=Cmw(XmCreateCascadeButton,parent,strName,NULL);
        break;
      case 'l':
        w=Cmw(XmCreateLabel,parent,strName,NULL);
        break;
      case 's':
        w=Cmw(XmCreateSeparator,parent,s+j+1,NULL);
        if (s[i+1]=='-') {
          SetValues(w,XmNorientation,XmHORIZONTAL,NULL);i++;
        } else if (s[i+1]=='|') {
          SetValues(w,XmNorientation,XmVERTICAL,NULL);i++;
        }
        break;

      case '$':
#ifdef DEBUG_CWS
printf("creating: %s\n",strName);               /* relcheck_ignore_line */
#endif
        createFn=va_arg(*pvl,CreateWidgetFn);
        args=MakeVaArgList(pvl,&argn);
        w=createFn(parent,strName,args,argn);
        XtManageChild(w);
        if (s[i+1]=='+') {
          i++;
          bGotoChild=True;
        }
        break;

      case 'f':
        w=Cmw(XmCreateFrame,parent,strName,NULL);
        bGotoChild=True;
        break;
      case '#':
        w=Cmw(XmCreateForm,parent,strName,NULL);
        bGotoChild=True;
        break;
      case '+':
        wg1=Cw(XmCreatePulldownMenu,parent,strName,NULL);
        assert(XmIsCascadeButton(w));
        SetValues(w,XmNsubMenuId,wg1,NULL);
        w=wg1;
        bGotoChild=True;
        break;
      case '-':
        if (nest<=0)
          FatalError("CreateMenuSystem()-!parent: fatal error 2");
        if (s[i+1]=='#') {
          i++;
          if (s[i+1]=='!') FatalError(
            "Fatal error - CreateWidgetSystem() - '-#!' is obsolete");
          CreateFormTable(parent,pos,posCount);
        }

        return False;
        break;
      case '*':
        wg1=Cw(XmCreatePulldownMenu,parent,strName,NULL);
        w=wg1;
        bGotoChild=True;
        break;
      case 'O':
        fprintf(stderr,
            "Warning - CreateWidgetSystem() - 'O:' is obsolete\n");
        w=Cmw(XmCreateOptionMenu,XtParent(XtParent(parent)),strName,
          XmNsubMenuId,parent,
          NULL);
        break;
      case 'o':
        w=Cmw(XmCreateOptionMenu,parent,strName,
          XmNsubMenuId,w,
          NULL);
        break;

      default:
        fprintf(stderr,
            "Fatal error: - CreateVaWidgetSystem - Bad type:%s\n",
            s);
        assert(0);
    }

    while (++i<j) switch(s[i]) {
      case '2':
      case '4':
      case '6':
      case '8':
      case '5':

        if (wL!=NULL && wL==wR) {
          fprintf(stderr,"Fatal error - CreateVaWidgetSystem - impossible"
              " attachment for widget %s\n",strName);
          assert(0);
        }

        if (s[i]!='6')
          SetValues(w,
            XmNleftAttachment,/*wL==NULL? XmATTACH_FORM :*/ XmATTACH_WIDGET,
            XmNleftWidget,wL,
            NULL);

        if (s[i]!='4')
          SetValues(w,
            XmNrightAttachment,/*wR==NULL? XmATTACH_FORM :*/ XmATTACH_WIDGET,
            XmNrightWidget,wR,
            NULL);

        if (s[i]!='2')
          SetValues(w,
            XmNtopAttachment,/*wT==NULL? XmATTACH_FORM :*/ XmATTACH_WIDGET,
            XmNtopWidget,wT,
            NULL);

        if (s[i]!='8')
          SetValues(w,
            XmNbottomAttachment,/*wB==NULL? XmATTACH_FORM :*/ XmATTACH_WIDGET,
            XmNbottomWidget,wB,
            NULL);

        switch (s[i]) {
          case '2':wB=w;break;
          case '4':wL=w;break;
          case '6':wR=w;break;
          case '8':wT=w;break;
          case '5':/*wL=wR=wT=wB=w;*/break;
          default: assert(0);
        }
        break;
      case '#':
        pos[posCount].wg=w;
        pos[posCount].x=va_arg(*pvl,int);
        pos[posCount].y=va_arg(*pvl,int);
        if (posCount++>=CWS_MAX) assert(0);
        break;
      case 'A':
        pcb=va_arg(*pvl,XtCallbackProc);
        pt1=va_arg(*pvl,XtPointer);
        XtAddCallback(w,XmNactivateCallback,pcb,pt1);
        break;
      case 'T':
        pcb=va_arg(*pvl,XtCallbackProc);
        pt1=va_arg(*pvl,XtPointer);
        XtAddCallback(w,XmNvalueChangedCallback,pcb,pt1);
        break;
      case 'C':
        pcb=va_arg(*pvl,XtCallbackProc);
        pt1=va_arg(*pvl,XtPointer);
        XtAddCallback(w,XmNcascadingCallback,pcb,pt1);
        break;
      case '0':
        pcb=va_arg(*pvl,XtCallbackProc);
        pt1=va_arg(*pvl,XtPointer);
        XtAddCallback(w,XmNdisarmCallback,pcb,pt1);
        break;
      case '1':
        pcb=va_arg(*pvl,XtCallbackProc);
        pt1=va_arg(*pvl,XtPointer);
        XtAddCallback(w,XmNarmCallback,pcb,pt1);
        break;
      case '!':
        peh=va_arg(*pvl,XtEventHandler);
        pt1=va_arg(*pvl,XtPointer);
        XtAddEventHandler(w,ButtonPressMask|
                            ButtonReleaseMask|
                            EnterWindowMask|
                            LeaveWindowMask|
                            PointerMotionMask,
          False,peh,pt1);
        break;
      case '@':
        pt1=va_arg(*pvl,XtPointer);
        SetValues(w,XmNuserData,pt1,NULL);
        break;
      case '\n':
        SetValues(parent,XmNdefaultButton,w,NULL);
        break;
      case '\b':
        /*SetValues(parent,XmNcancelButton,w,NULL);
        */
        break;
      case '?':
        pt1=va_arg(*pvl,XtPointer);
        *(Widget*)pt1=w;
        break;
      case '>':
        callFn=(void*)va_arg(*pvl,vmsFunc0);
        pt1=va_arg(*pvl,XtPointer);
        pt2=va_arg(*pvl,XtPointer);
        ((vmsFunc2)callFn)(w,pt1,pt2);
        break;
      case '&':
        callFn=(void*)va_arg(*pvl,vmsFunc0);
        callArgCount=va_arg(*pvl,int);
        if (callArgCount>XTPA_MAX) {
          fprintf(stderr,"fatal error: vacreate - CreateWidgetSystem()"
              " - too many args in '&'\n");
          exit(1);
        }
        for (i=0;i<callArgCount;i++) xtpa[i]=va_arg(*pvl,XtPointer);
        switch(callArgCount) {
          case 0:
            ((vmsFunc0)callFn)(w);
            break;
          case 1:
            ((vmsFunc1)callFn)(w,xtpa[0]);
            break;
          case 2:
            ((vmsFunc2)callFn)(w,xtpa[0],xtpa[1]);
            break;
          case 3:
            ((vmsFunc3)callFn)(w,xtpa[0],xtpa[1],xtpa[2]);
            break;
          case 4:
            ((vmsFunc4)callFn)(w,xtpa[0],xtpa[1],xtpa[2],xtpa[3]);
            break;
          case 5:
            ((vmsFunc5)callFn)(w,xtpa[0],xtpa[1],xtpa[2],xtpa[3],xtpa[4]);
            break;
          default:
            assert(0);
        }
        break;
      case '=':
        pt1=va_arg(*pvl,XtPointer);
        if (XmIsToggleButton(w))
          XmToggleButtonSetState(w,(int)pt1,True);
        else if (XmIsText(w))
          XmTextSetString(w,pt1);
        else if (XmIsTextField(w))
          XmTextFieldSetString(w,pt1);
        else FatalError("CreateMenuSystem()-unknown widget type for =");
        break;
      case '_':
        XtUnmanageChild(w);
        break;
      case ' ':
        break;
      default:
        fprintf(stderr,"%s\n",s);
        FatalError("CreateMenuSystem()-syntax %s: fatal error 1");
    }

    if (bGotoChild) if (CreateVaWidgetSystem(w,nest+1,pvl)) return True;
  }
  return True;
}

void CreateMenuSystem(Widget wParent,...) {
  va_list vl;

  va_start(vl,wParent);
  CreateVaWidgetSystem(wParent,0,&vl);
  va_end(vl);
}

Widget CreateMessageDialog(Widget wParent,String name,...) {
  Widget wBox;
  va_list vl;

  wBox=Cw(XmCreateTemplateDialog,wParent,name,
    XmNdeleteResponse,XmNONE,
/*
    XmNdefaultButton,NULL,
    XmNcancelButton,NULL,
*/
    NULL);
  /*
  XtUnmanageChild(XmMessageBoxGetChild(wBox,XmDIALOG_OK_BUTTON));
  XtUnmanageChild(XmMessageBoxGetChild(wBox,XmDIALOG_CANCEL_BUTTON));
  XtUnmanageChild(XmMessageBoxGetChild(wBox,XmDIALOG_HELP_BUTTON));
  */
  SetValues(wBox,XmNautoUnmanage,False,NULL);

  va_start(vl,name);
  CreateVaWidgetSystem(wBox,0,&vl);
  va_end(vl);

  return wBox;
}

Widget CreateDialogEx(Widget wParent,String name,va_list* pargs,int flags) {
  Widget wDlg;
  Atom wm_delete_window;
  ArgList args;
  int argn;

  if (flags & CDLG_MESSAGE)
    wDlg=Cw(XmCreateMessageDialog,wParent,name,
      XmNautoUnmanage,False,
      XmNdeleteResponse,XmDO_NOTHING,
      NULL);
  else FatalError("CreateDialogEx(): no information on widget type");

/*  if (!(flags & CDLG_NOSTDCANCEL)) { error } */

  XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
  wm_delete_window=XmInternAtom(XtDisplay(wParent),
    "WM_DELETE_WINDOW",False);
  XmAddWMProtocolCallback(XtParent(wDlg),wm_delete_window,
    CbUnmap,NULL);

  if (flags & CDLG_NOLABEL)
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_MESSAGE_LABEL));
  if (flags & CDLG_NOOK)
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_OK_BUTTON));
  if (flags & CDLG_NOCANCEL)
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_CANCEL_BUTTON));
  if (flags & CDLG_NOHELP)
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

  if (pargs!=NULL) {
    args=MakeVaArgList(pargs,&argn);
    XtSetValues(wDlg,args,argn);
  }

  return wDlg;
}

void AddCallbackToTree(Widget root,WidgetClass class,String callbackType,
    XtCallbackProc callback,XtPointer userData) {
  WidgetList wl;
  Cardinal wlCount,i;
  CoreRec* cp;


  if (XtIsSubclass(root,class))
    XtAddCallback(root,callbackType,callback,userData);

  if (!XtIsWidget(root)) return;
  cp=(CoreRec*)root;
  if (cp->core.popup_list!=NULL) for (i=0;i<cp->core.num_popups;i++)
    if (cp->core.popup_list[i]!=NULL)
      AddCallbackToTree(cp->core.popup_list[i],class,callbackType,
        callback,userData);

  if (XtIsComposite(root)) {
    GetValues(root,
      XmNchildren,&wl,
      XmNnumChildren,&wlCount,
      NULL);
    for (i=0;i<wlCount;i++)
      AddCallbackToTree(wl[i],class,callbackType,callback,userData);
  }
}

String GetResourceString(Widget wg,char* name,char* class,String def) {
  XtResource xtr={
    NULL,NULL,XtRString,sizeof(String),0,
    XmRImmediate,NULL};
  char* resourceName;
  String str;

  if (name[0]=='\r') return name+1;

  if (class==NULL) class=name;
  if (def==NULL) def=name;

  xtr.resource_name=name;
  xtr.resource_class=class;
  xtr.default_addr=def;
  XtGetApplicationResources(wg,&str,&xtr,1,NULL,0);

  return str;
}

int GetResourceInt(Widget wg,char* name,char* class,int def) {
  XtResource xtr={
    NULL,NULL,XtRInt,sizeof(int),0,
    XmRImmediate,NULL};
  char* resourceName;
  int i;

  if (class==NULL) class=name;
  xtr.resource_name=name;
  xtr.resource_class=class;
  xtr.default_addr=(XtPointer)def;
  XtGetApplicationResources(wg,&i,&xtr,1,NULL,0);

  return i;
}

Pixel GetResourcePixel(Widget wg,char* name,char* class,String def) {
  XtResource xtr={
    NULL,NULL,XmRPixel,sizeof(Pixel),0,
    XtRString,NULL};
  char* resourceName;
  Pixel pixel;

  if (class==NULL) class=name;
  xtr.resource_name=name;
  xtr.resource_class=class;
  xtr.default_addr=(XtPointer)def;
  XtGetApplicationResources(wg,&pixel,&xtr,1,NULL,0);

  return pixel;
}

void CbFree(Widget wg,XtPointer p,XtPointer pcbs) {
  free(p);
}

void CbCancel(Widget wg,XtPointer p,XtPointer pcbs) {
  if (p==NULL) while (!XtIsShell(XtParent(wg))) wg=XtParent(wg);
  else wg=(Widget)p;
  XtUnmanageChild(wg);
}

void CbDestroy(Widget wg,XtPointer p,XtPointer pcbs) {
  if (p==NULL) while (!XtIsShell(XtParent(wg))) wg=XtParent(wg);
  else wg=(Widget)p;
  XtDestroyWidget(wg);
}

void CbUnmap(Widget wg,XtPointer arg,XtPointer pcbs) {
  if (arg==NULL)
    while (!XtIsShell(wg)) wg=XtParent(wg);
  else wg=(Widget)arg;
  XtPopdown(wg);                        /* relcheck_ignore_line */
}

void CbFreeGC(Widget wg,XtPointer xtpGC,XtPointer pcbs) {
  XFreeGC(XtDisplay(wg),(GC)xtpGC);
}

void CbRemovePTimeOut(Widget wg,XtPointer xtppTO,XtPointer pcbs) {
  XtIntervalId* pxtiid=(XtIntervalId*)xtppTO;

  if (*pxtiid!=(int) NULL) {
    XtRemoveTimeOut(*pxtiid);
    *pxtiid=(int) NULL;
  }
}

void CbExitApp(Widget wg,XtPointer xtpExitCode,XtPointer pcbs) {
  exit((int)xtpExitCode);
}

void CbDebugPrint(Widget wg,XtPointer xtpDebugStr,XtPointer pcbs) {
  printf("Debug print (%s): %s\n",XtName(wg),(char*)xtpDebugStr);
}

void ProcessPending(Widget wg) {
  XEvent xev;
  XtAppContext apc;

  apc=XtWidgetToApplicationContext(wg);
  while (XtAppPending(apc)) {
    XtAppNextEvent(apc,&xev);
    XtDispatchEvent(&xev);
  }
}

static char* MakeStrVaEx(char* s,char* fmt,va_list params) {
  static char buf[MAKESTREX_BUF]="",b2[MAKESTREX_BUF]="";
  int i,j,k,n;
  char* ps,*ps1;

  strncpy(b2,fmt,sizeof(b2)-1);

  for (i=0;b2[i];i++) if (b2[i]=='$') b2[i]=MAKESTREX_CHR;
  vsprintf(buf,b2,params);
  for (i=0;s[i];i++) if (s[i]=='$' && s[i+1]=='(') {
    s[i]=MAKESTREX_CHR;
    for (j=0;s[j];) if (s[i+j++]==')') break;
    for (ps=buf;ps!=NULL;ps=strchr(ps+1,MAKESTREX_CHR))
      if (!strncmp(s+i,ps,j)) break;
    if (ps==NULL) return NULL;
    ps1=strchr(ps+j,MAKESTREX_CHR);
    k= ps1==NULL ? strlen(ps+j) : (int)(ps1-ps-j);
    memmove(s+i+k,s+i+j,strlen(s+i+j)+1);
    memmove(s+i,ps+j,k);
    i+=k-j;
  }
  return s;
}

char* GetStaticString() {
  static int index=0;
  static char buf[STATICSTR_CNT][STATICSTR_LEN+1];

  index=(index+1)%STATICSTR_CNT;
  return buf[index];
}

char* GetResourceStringEx(Widget wg,char* name,char* class,
    char* fmt, ...) {
  va_list vl;
  char* s;

  s=GetStaticString();
  strcpy(s,GetResourceString(wg,name,class,name));
  va_start(vl,fmt);
  s=MakeStrVaEx(s,fmt==NULL ? "" : fmt,vl);
  va_end(vl);
  return s==NULL ? "(BadString1)" : s;
}

void ErrorBox(Widget w,char* name) {
  Widget wDlg;
  XmString xms,xms1,xms2;
  char s[2048];

  wDlg=XtNameToWidget(w,"*"DLG_ERROR_BOX);
  if (wDlg==NULL) {
    xms=XmStringCreateLtoR(name,XmFONTLIST_DEFAULT_TAG);
    wDlg=Cmw(XmCreateErrorDialog,w,DLG_ERROR_BOX,
      XmNmessageString,xms,
      XmNautoUnmanage,False,
      XmNdeleteResponse,XmDESTROY,
      NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_CANCEL_BUTTON));
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));
    XtAddCallback(wDlg,XmNokCallback,CbDestroy,NULL);
  } else {
    GetValues(wDlg,XmNmessageString,&xms,NULL);
    sprintf(s,"\n---\n%s",name);
    xms1=XmStringCreateLtoR(s,XmFONTLIST_DEFAULT_TAG);
    xms2=XmStringConcat(xms,xms1);
    SetValues(wDlg,XmNmessageString,xms2,NULL);
    XmStringFree(xms);
    XmStringFree(xms1);
    XmStringFree(xms2);
    XtPopup(XtParent(wDlg),XtGrabNone);
  }
}

XtPointer GetUserData(Widget wg) {
  XtPointer xtp=(XtPointer)NULL;

  GetValues(wg,XmNuserData,&xtp,NULL);
  return xtp;
}

void SetXmStringValue(Widget wg,String resource,String value) {
  XmString xms;

  xms=XmStringCreateLtoR(value,XmFONTLIST_DEFAULT_TAG);
  SetValues(wg,resource,xms,NULL);
  XmStringFree(xms);
}

/* Finds a widget in an OptionMenu with XmNuserData==value
   and activates it
   Returns: True==success; False==given value not found
*/
int SetOptionMenuValue(Widget wOptionMenu,XtPointer value) {
  Widget wg;
  WidgetList wl;
  Cardinal wlCount,i;
  XtPointer xtp;

  GetValues(wOptionMenu,XmNsubMenuId,&wg,NULL);
  assert(wg!=NULL);

  GetValues(wg,
    XmNchildren,&wl,
    XmNnumChildren,&wlCount,
    NULL);

  for (i=0;i<wlCount;i++) {
    GetValues(wl[i],XmNuserData,&xtp,NULL);
    if (xtp==value) {
      SetValues(wOptionMenu,XmNmenuHistory,wl[i],NULL);
      return True;
   }
 }

 return False;
}

void SetOptionMenuItems(Widget wOptionMenu,int count,
    XmString* items,XtPointer* values) {
  Widget wg,wg1;
  WidgetList wl;
  Cardinal wlCount,i;
  XtPointer xtp;

  /* Check arguments */
  assert(items!=NULL);
  assert(values!=NULL);

  /* Get MenuPane */
  GetValues(wOptionMenu,XmNsubMenuId,&wg,NULL);
  assert(wg!=NULL);

  /* Ensure at least count children, add PushPuttons as necessary */
  GetValues(wg,XmNnumChildren,&wlCount,NULL);
  for (;wlCount<count;wlCount++)
    Cw(XmCreatePushButton,wg,"item",NULL);

  /* Get the list of children */
  GetValues(wg,
    XmNchildren,&wl,
    XmNnumChildren,&wlCount,
    NULL);
  assert(wlCount>=count);

  /* Assign strings and values and manage the first <count> children */
  for (i=0;i<count;i++) {
    SetValues(wl[i],
      XmNlabelString,(XtPointer)items[i],
      XmNuserData,values[i],
      NULL);
    if (!XtIsManaged(wl[i])) XtManageChild(wl[i]);
  }

  /* Unmanage any remaining children */
  for (;i<wlCount;i++)
    if (XtIsManaged(wl[i])) XtUnmanageChild(wl[i]);

  /* Change XmNmenuHistory */
  SetValues(wOptionMenu,XmNmenuHistory,wlCount? wl[0] : (Widget)NULL,NULL);

  /* Done - no need to free XmNchildren */
}

/* Returns XmNuserData of the active widget in an OptionMenu
*/
XtPointer GetOptionMenuValue(Widget wOptionMenu) {
  Widget wg;
  XtPointer value;

  GetValues(wOptionMenu,XmNmenuHistory,&wg,NULL);
  assert(wg!=NULL);
  GetValues(wg,XmNuserData,&value,NULL);

  return value;
}

/* Returns the selected position, counting from 0, or -1 if none or >1 selected
*/

int GetXmListSelPos(Widget wList) {
  int* posList,posCount,r;

  if (!XmListGetSelectedPos(wList,&posList,&posCount)) return -1;

  r= posCount==1? posList[0]-1 : -1;
  XtFree((XtPointer)posList);

  return r;
}

void CbSensitiveIfListSel(Widget wList,XtPointer pWg,XtPointer pcbs) {
  int selCount;

  GetValues(wList,XmNselectedItemCount,&selCount,NULL);
  if (!!selCount != !!XtIsSensitive(pWg))
    XtSetSensitive(pWg,!!selCount);
}

void CbSensitiveIfListSel1(Widget wList,XtPointer pWg,XtPointer pcbs) {
  int selCount;

  GetValues(wList,XmNselectedItemCount,&selCount,NULL);
  if (!!(selCount==1) != !!XtIsSensitive(pWg))
    XtSetSensitive(pWg,selCount==1);
}

int IsMapped(Widget wg) {
  XWindowAttributes xwa;

  if (!XtIsRealized(wg)) return False;

  XGetWindowAttributes(XtDisplay(wg),XtWindow(wg),&xwa);

  return xwa.map_state==IsViewable;
}

static char* TruncStr(char* s) {
  char* s1;

  while (*s && isspace(*s)) s++;

  s1=s+strlen(s)-1;

  while (s1>s && isspace(*s1)) *(s1--)=0;

  return s;
}

int IsXmTextEmpty(Widget wText) {
  char* s,*s1,*s2;
  double r;

  s=XmTextGetString(wText);
  s1=TruncStr(s);

  r=!*s1;

  XtFree(s);

  return r;
}

double GetXmTextDouble(Widget wText) {
  char* s,*s1,*s2;
  double r;

  s=XmTextGetString(wText);
  s1=TruncStr(s);

  r=strtod(s1,&s2);
  if (!*s1 || *s2) r=MAXDOUBLE;

  XtFree(s);

  return r;
}

int GetXmTextInt(Widget wText) {
  char* s,*s1,*s2;
  int i;

  s=XmTextGetString(wText);
  s1=TruncStr(s);

  i=(int)strtod(s1,&s2);
  if (!*s1 || *s2) i=MAXINT;

  XtFree(s);

  return i;
}

void SetXmListItems(Widget wList,XmString* items,int count) {
  XmStringTable xmst0,xmst;
  int i,selCount;

  GetValues(wList,
    XmNselectedItems,&xmst0,
    XmNselectedItemCount,&selCount,
    NULL);

  xmst=malloc(sizeof(*xmst)*selCount);

  for (i=0;i<selCount;i++) xmst[i]=XmStringCopy(xmst0[i]);

  XmListDeleteAllItems(wList);
  XmListAddItems(wList,items,count,0);

  for (i=0;i<selCount;i++) {
    XmListSelectItem(wList,xmst[i],False);
    XmStringFree(xmst[i]);
  }
  free(xmst);
}

void CreateFormTable(Widget form,struct _PosInfo* pos,int posCount) {
  int numRows,numCols,*rows,*cols;
  XtPointer xtp;
  int i,j,bRealized;
  Dimension width,height,borderWidth;
  XtWidgetGeometry xtwg;
  unsigned char uc;
  Widget wg1;
  WidgetList wl;

#ifdef DEBUG_TABLES
  /* relcheck_ignore_line */ for (i=0;i<posCount;i++) printf("Widget name=%s  x=%d  y=%d\n",
      XtName(pos[i].wg),pos[i].x,pos[i].y);
#endif

/* Check for a valid XmForm widget */

  assert(XtIsSubclass(form,xmFormWidgetClass));

  bRealized=XtIsRealized(form);

  numRows=numCols=0;

/* Calculate total number of rows and columns */

  for (i=0;i<posCount;i++) {
    numRows=max(numRows,pos[i].y);
    numCols=max(numCols,pos[i].x);
  }

  if (!numRows || !numCols) FatalError("CreateFormTable: zero size");

/* Allocate storage for rows & columns */

  rows=malloc(sizeof(*rows)*(numRows+=2));
  cols=malloc(sizeof(*cols)*(numCols+=2));

  for (i=0;i<numRows;i++) rows[i]=0;
  for (i=0;i<numCols;i++) cols[i]=0;

/* Compute height of each row and width of each column */

  for (i=0;i<posCount;i++) {
    XtQueryGeometry(pos[i].wg,NULL,&xtwg);
    width=xtwg.width;
    height=xtwg.height;

#ifdef DEBUG_TABLES
    /* relcheck_ignore_line */ printf("%s: %dx%d\n",XtName(pos[i]),(int)width,(int)height);
#endif

    if (pos[i].x) cols[pos[i].x]=max(cols[pos[i].x],width);
    if (pos[i].y) rows[pos[i].y]=max(rows[pos[i].y],height);
  }

/* Compute coordinates of each row & column */

  for (i=1;i<numRows;i++) rows[i]+=rows[i-1];
  for (i=1;i<numCols;i++) cols[i]+=cols[i-1];

  for (i=numRows-1;i>0;i--) rows[i]=rows[i-1];
  for (i=numCols-1;i>0;i--) cols[i]=cols[i-1];
  rows[0]=cols[0]=0;

#ifdef DEBUG_TABLES
  /* relcheck_ignore_line */ for (i=0;i<numRows;i++) printf("rows[%d]=%d\n",i,rows[i]);
  /* relcheck_ignore_line */ for (i=0;i<numCols;i++) printf("cols[%d]=%d\n",i,cols[i]);
#endif

/* Hide widget to prevent displaying garbage while moving widgets */
  if (bRealized) {
/*    XtUnrealizeWidget(XtParent(w)); */
  }

/* Resize the Form widget  - BAD
  GetValues(w,XmNborderWidth,&borderWidth,NULL);
  XtResizeWidget(w,cols[numCols-1],rows[numRows-1],borderWidth);
*/

/* Set widget positions proportional to row/column heights/widths */

  SetValues(form,XmNfractionBase,10000,NULL);
  for (i=0;i<posCount;i++) {
    j=pos[i].y;
    SetValues(pos[i].wg,
      XmNtopAttachment,j? XmATTACH_POSITION : XmATTACH_FORM,
      XmNtopPosition,(int)((float)rows[j]*10000/rows[numRows-1]),
      XmNbottomAttachment,j? XmATTACH_POSITION : XmATTACH_FORM,
      XmNbottomPosition,(int)((float)rows[j+1]*10000/rows[numRows-1]),
      NULL);

    j=pos[i].x;
    SetValues(pos[i].wg,
      XmNleftAttachment,j? XmATTACH_POSITION : XmATTACH_FORM,
      XmNleftPosition,(int)((float)cols[j]*10000/cols[numCols-1]),
      XmNrightAttachment,j? XmATTACH_POSITION : XmATTACH_FORM,
      XmNrightPosition,(int)((float)cols[j+1]*10000/cols[numCols-1]),
      NULL);
  }

/* Re-display form widget */

  if (bRealized) {
/*    XtRealizeWidget(XtParent(w)); */
  }

/* Free storage */

  free(rows);
  free(cols);
}

void Form2Table(Widget form) {
  WidgetList children;
  Cardinal numChildren;
  struct _PosInfo* pos;
  int i;
  XtPointer xtp;

/* Check for a valid XmForm widget */

  assert(XtIsSubclass(form,xmFormWidgetClass));

  GetValues(form,
    XmNchildren,&children,
    XmNnumChildren,&numChildren,
    NULL);
  if (!numChildren) return;

  pos=malloc(sizeof(*pos)*numChildren);

/* Calculate total number of rows and columns */

  for (i=0;i<numChildren;i++) {
    pos[i].wg=children[i];
    GetValues(children[i],XmNuserData,&xtp,NULL);
    pos[i].x=(int)xtp/256;
    pos[i].y=(int)xtp%256;
  }

  CreateFormTable(form,pos,numChildren);

  free(pos);
}
