/**********************************************************************/

#ifndef _vacreate_h
#define _vacreate_h

/* Widget creation and management functions ***************************/

Widget Cw(Widget (*CreateFn)(Widget,String,ArgList,Cardinal),Widget parent,
          void* arg0,...);
Widget Cmw(Widget (*CreateFn)(Widget,String,ArgList,Cardinal),Widget parent,
          void* arg0,...);
void SetValues(Widget wg,...);
void GetValues(Widget wg,...);

void CreateMenuSystem(Widget wParent,...);
#define CreateWidgetSystem CreateMenuSystem

Widget CreateDialogEx(Widget wParent,String name,va_list* pargs,int flags);
#define CDLG_MESSAGE     0x0001
#define CDLG_NOLABEL     0x0002
#define CDLG_NOOK        0x0004
#define CDLG_NOCANCEL    0x0008
#define CDLG_NOHELP      0x0010
/*#define CDLG_NOSTDCANCEL 0x0020*/

Widget CreateMessageDialog(Widget wParent,String name,...);

#define CreateOkCancelDialog(wParent,name) \
  CreateDialogEx((wParent),(name),NULL,CDLG_MESSAGE|CDLG_NOLABEL);

void AddCallbackToTree(Widget root,WidgetClass class,String callbackType,
    XtCallbackProc callback,XtPointer userData);

/* Resource management functions **************************************/

String GetResourceString(Widget wg,char* name,char* class,String def);
int GetResourceInt(Widget wg,char* name,char* class,int def);
Pixel GetResourcePixel(Widget wg,char* name,char* class,String def);
char* GetResourceStringEx(Widget wg,char* name,char* class,
    char* fmt, ...);

/* Standard callbacks *************************************************/

void CbFree(Widget wg,XtPointer p,XtPointer pcbs);
void CbDestroy(Widget wg,XtPointer p,XtPointer pcbs);
void CbCancel(Widget wg,XtPointer p,XtPointer pcbs);
void CbUnmap(Widget wg,XtPointer p,XtPointer pcbs);
void CbFreeGC(Widget wg,XtPointer xtpGC,XtPointer pcbs);
void CbRemovePTimeOut(Widget wg,XtPointer xtppTO,XtPointer pcbs);
void CbExitApp(Widget wg,XtPointer xtpExitCode,XtPointer pcbs);
void CbDebugPrint(Widget wg,XtPointer xtpDebugStr,XtPointer pcbs);

void CbSensitiveIfListSel1(Widget wList,XtPointer pWg,XtPointer pcbs);
void CbSensitiveIfListSel(Widget wList,XtPointer pWg,XtPointer pcbs);

/* Query/set widget values ********************************************/

XtPointer GetUserData(Widget wg);
#define SetUserData(wg,data) SetValues((wg),XmNuserData,(XtPointer)(data),NULL)

#define SetSensitiveEx(w,s) if(XtIsSensitive(w)!=!!(s)) XtSetSensitive(w,(s))

int SetOptionMenuValue(Widget wOptionMenu,XtPointer value);
XtPointer GetOptionMenuValue(Widget wOptionMenu);
void SetOptionMenuItems(Widget wMenu,int count,XmString* items,XtPointer* vals);

void SetXmStringValue(Widget wg,String resource,String value);
#define SetMessageString(wg,value)\
SetXmStringValue((wg),XmNmessageString,(value))
#define SetLabelString(wg,value)\
SetXmStringValue((wg),XmNlabelString,(value))

int IsXmTextEmpty(Widget wText);
int GetXmTextInt(Widget wText);       /* Returns MAXINT on error */
double GetXmTextDouble(Widget wText); /* Returns MAXDOUBLE on error */

int GetXmListSelPos(Widget wList);

/* Formatting *********************************************************/

struct _PosInfo {
  Widget wg;
  int x,y;
};

void CreateFormTable(Widget form,struct _PosInfo* pos,int posCount);

/* Misc ***************************************************************/

char* GetStaticString();

void ProcessPending(Widget wg);

void ErrorBox(Widget w,char* name);
int IsMapped(Widget wg);

void SetXmListItems(Widget wList,XmString* items,int count);
void Form2Table(Widget form);

#endif
