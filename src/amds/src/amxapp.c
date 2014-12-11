#include "amds.h"

#define ENV_DBFILE "AMDSDATABASEFILE"
#define ENV_CFGFILE "AMDSCONFIGFILE"

extern char* amdsResources[];

XrmOptionDescRec commandLineOptions[]={
  "-help","displayHelp",XrmoptionNoArg,"1",
  "/help","displayHelp",XrmoptionNoArg,"1",
  "-h","displayHelp",XrmoptionNoArg,"1",
  "/h","displayHelp",XrmoptionNoArg,"1",
  "-?","displayHelp",XrmoptionNoArg,"1",
  "/?","displayHelp",XrmoptionNoArg,"1",
  "?","displayHelp",XrmoptionNoArg,"1",

  "-nocfg","loadConfig",XrmoptionNoArg,"0",
  "-cfg","configFile",XrmoptionSepArg,NULL,
  "-nores","checkResources",XrmoptionNoArg,"0",
  "-nohelp","checkHelpFile",XrmoptionNoArg,"0",
};

/* XApp */

XApp CreateXApp(int* pargc,char** argv) {
  XApp xap;
  char s[2048],*ps;
  int i;

  xap=Malloc(sizeof(*xap));
  xap->wShell=XtAppInitialize(&xap->apc,"AMDS",
    commandLineOptions,XtNumber(commandLineOptions),
    pargc,argv,amdsResources,NULL,0);
  xap->wm_del_window=XmInternAtom(XtDisplay(xap->wShell),
    "WM_DELETE_WINDOW",False);

  if (GetResourceInt(xap->wShell,"displayHelp","DisplayHelp",0)) {
    printf(
      "Atomic & Molecular Data Selector v%g\n"
      "Syntax: amds [-help] [-nocfg] [<file.amd>] [<file.amd>] ...\n"
      "  -help          Display this help text\n"
      "  -nocfg         Do not load configuration\n"
      "  <file.amd>     AMD files to load. If none specified, a new document\n"
      "                 will be displayed.\n"
      "amds is an X Windows application. A proper DISPLAY setting may be needed\n"
      ,GetVersion()/100.);
    exit(10);
  }

  xap->pargc=pargc;
  xap->argv=argv;
  xap->views=CreateGroup();

  if (GetResourceInt(xap->wShell,"checkResources","CheckResources",1)) {
    i=GetResourceInt(xap->wShell,"resourceFileVersion",
	"ResourceFileVersion",0);
    if (i!=GetVersion()) {
      fprintf(stderr,"amds: Bad resource file version\n"
	"amds version:           %g\n"
	"Resource file version: %g\n",GetVersion()/100.,i/100.);
      exit(1);
    }
  }

  if (getenv(ENV_DBFILE)!=NULL) strcpy(s,getenv(ENV_DBFILE)); else *s=0;
  if (!*s) strcpy(s,GetResourceString(xap->wShell,"databaseFile",
      "DatabaseFile",""));
  if (!*s) {
    strcpy(s,xap->argv[0]);
    strcat(s,".rpd");
  }
  xap->db=CreateDatabase(s);

  if (GetResourceInt(xap->wShell,"loadConfig","LoadConfig",1)) {
    ps=getenv(ENV_CFGFILE);

    if (ps==NULL) {
      ps=GetResourceString(xap->wShell,"configFile","ConfigFile","");

      if (!*ps) {
	strcpy(s,argv[0]);
	strcat(s,".rpc");
	ps=s;
      }
    }
    xap->config=CreateDoc(xap->db);
    i=LoadDoc(xap->config,ps);
    if (i) {
      fprintf(stderr,"amds: Error reading configuration from %s\n",ps);
      exit(1);
    }
  } else xap->config=NULL;

  xap->clipboard=CreateDoc(xap->db);

  return xap;
}

void CbFree(Widget wg,XtPointer p,XtPointer pcbs) {
  Free((void*)p);
}
