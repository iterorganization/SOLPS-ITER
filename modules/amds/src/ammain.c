#include "amds.h"

int main(int argc,char** argv) {
  XApp xapp;
  Database db;
  Doc d;
  int i;

  xapp=CreateXApp(&argc,argv);

  for (i=1;i<argc;i++) {
    d=CreateDoc(xapp->db);
    if (LoadDoc(d,argv[i])) {
      FreeDoc(d);
      fprintf(stderr,"amds: Error loading %s\n",argv[i]);
      exit(1);
    }
    if (xapp->config!=NULL) UpdateVarDefs(d,xapp->config);
    CreateView(xapp,d,NULL);
  }
  if (i<=1) NewView(xapp);

  XtAppMainLoop(xapp->apc);

  return 0;
}


