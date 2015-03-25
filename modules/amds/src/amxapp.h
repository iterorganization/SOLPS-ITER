/* XApp definitio */

struct _XApp {
  Database db;
  Group views;
  Doc clipboard,config;

  int* pargc;
  char** argv;
  XtAppContext apc;
  Widget wShell;
  Atom wm_del_window;
};

XApp CreateXApp(int* pargc,char** argv);

/* Override the default in vacreate: use Free() instead of free() */
void CbFree(Widget wg,XtPointer p,XtPointer pcbs);
