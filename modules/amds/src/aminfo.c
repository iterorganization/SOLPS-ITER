#include "amds.h"

#define DLG_ABOUT "dlgAbout"

Widget ShowAboutDlg(View w) {
  Widget wDlg;

  wDlg=XtNameToWidget(w->wMain,"*"DLG_ABOUT);
  if (wDlg==NULL) {
    wDlg=Cw(XmCreateInformationDialog,w->wMain,DLG_ABOUT,
      XmNautoUnmanage,False,
      XmNdeleteResponse,XmDO_NOTHING,
      NULL);
    XtAddCallback(wDlg,XmNokCallback,CbUnmap,NULL);
    XtAddCallback(wDlg,XmNcancelCallback,CbUnmap,NULL);
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_CANCEL_BUTTON));
    XtUnmanageChild(XmMessageBoxGetChild(wDlg,XmDIALOG_HELP_BUTTON));

    XtManageChild(wDlg);
  } else XtPopup(XtParent(wDlg),XtGrabNone);

  return wDlg;
}
