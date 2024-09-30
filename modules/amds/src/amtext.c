#include "amds.h"
#include "ctype.h"

#define DLG_REACTION_TEXT "dlgReactionText_"
#define WG_TEXT "text"

#define STR_BEGIN "##BEGIN DATA HERE##"
#define STR_HEADER "H."
#define STR_REACTION "Reaction "

#define ENV_DBPATH "AMDSDATABASEDIR"

static Widget CreateReactionTextDlg(View w,char* fName);

int DisplayReactionText(View w,Reaction r) {
  Widget wSh,wDlg,wg,wg1,wText;
  char s[2048],s0[2048],s1[2048],s2[2048],strSectionPrefix[120];
  int i;
  FILE* f;
  String str,str2,str3;
  long l;
  Widget wGotoMenu,wHeaderMenu;

  if (w->mainView!=NULL) w=w->mainView;

  strcpy(s0,GetReactionDatabase(r));

  strcpy(s,"*"DLG_REACTION_TEXT);
  strcat(s,s0);

  wDlg=XtNameToWidget(w->wMain,s);
  if (wDlg==NULL) {
    str=getenv(ENV_DBPATH);
    strcpy(s1,str==NULL? "" : str);
    if (!*s1) strcpy(s1,GetResourceString(w->xapp->wShell,"databaseDir",
	"DatabaseDir",""));
    if (!*s1) GetFilePath(strcpy(s1,w->xapp->argv[0]));
    if (*s1 && s1[strlen(s1)-1]!='/') strcat(s1,"/");
    strcat(s1,s0);
    wDlg=CreateReactionTextDlg(w,s1);
    if (wDlg==NULL) return -1;
    XtPopup(XtParent(wDlg),XtGrabNone);
  }

  wText=XtNameToWidget(wDlg,"*"WG_TEXT);
  assert(wText!=NULL);
  str=XmTextGetString(wText);
  if (*str=='\\') strcpy(strSectionPrefix,"\\section{");
  else *strSectionPrefix=0;

  str2=strstr(str,STR_BEGIN);
  if (str2==NULL) return -1;

  sprintf(s,"\n%s%s",strSectionPrefix,GetReactionSection(r));
  while(1) {
    str2=strstr(str2,s);
    if (str2==NULL) return -1;
    if (isspace(str2[strlen(s)])) break;
  }

  sprintf(s,"Reaction %s",GetReactionNumber(r));
  sprintf(s0,"\n%sH.",strSectionPrefix);
  while(1) {
    str3=strstr(str2+1,s0);
    str2=strstr(str2,s);
    if (str2==NULL || ( str3!=NULL && str2>str3 )) return -1;
    if (isspace(str2[strlen(s)])) break;
  }

  XmTextSetTopCharacter(wText,str2-str+1);
  XtFree(str);

  XtPopup(XtParent(wDlg),XtGrabNone);

  return 0;
}


static Widget CreateReactionTextDlg(View w,char* fName) {
  FILE* f;
  Widget wSh,wDlg,wText,wg;
  char s[2048];
  String str;
  long l;

  sprintf(s,"%s%s",DLG_REACTION_TEXT,GetShortFName(fName));

  f=fopen(fName,"r");
  if (f==NULL) return NULL;

  fseek(f,0,SEEK_END);
  l=ftell(f);
  fseek(f,0,SEEK_SET);

  str=XtMalloc(l+1);
  str[l]=0;
  fread(str,l,1,f);
  fclose(f);

  wSh=XtCreatePopupShell(DLG_REACTION_TEXT"shell",topLevelShellWidgetClass,
    w->wMain,NULL,0);
  SetValues(wSh,
    XmNdeleteResponse,XmDO_NOTHING,
    XmNtitle,fName,
    NULL);
  XmAddWMProtocolCallback(wSh,w->xapp->wm_del_window,CbUnmap,NULL);

  wDlg=Cmw(XmCreateMainWindow,wSh,s,
    NULL);

  wg=Cmw(XmCreateMenuBar,wDlg,"textMenuBar",
    NULL);
  SetValues(wDlg,XmNmenuBar,wg,NULL);

  CreateMenuSystem(wg,
    "c:window",
    "+:textWindowMenu",
    "bA:close",CbUnmap,(XtPointer)wSh,
    "-:",
    NULL);

  wText=Cmw(XmCreateScrolledText,wDlg,WG_TEXT,
    XmNeditMode,XmMULTI_LINE_EDIT,
    XmNeditable,False,
    XmNtraversalOn,False,
    NULL);
  XmTextSetString(wText,str);
  XtFree(str);

  XtRealizeWidget(wSh);
  XtManageChild(wSh);

  return wDlg;
}
