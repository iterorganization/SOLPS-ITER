#include "amds.h"
#include "git_version.h"

#define FILE_VERSION 2
#define OUTPUT_VERSION 1

#define STR_AMDS_FILE "<amds subset file>\n"
#define STR_DATA "<amdsData>\n"
#define STR_ENDDATA "<amdsEndData>\n"

typedef struct _FlagsRec {unsigned long mask;char c;}* FlagsRec;
typedef struct _NameRec {int val;char* s;}* NameRec;
static void Str2Flags(char* s,unsigned long* flags,FlagsRec fr);
static char* Flags2Str(unsigned long flags,FlagsRec fr);
static char* Int2Name(int val,NameRec nr);
static int Name2Int(char* name,NameRec nr);

struct _FlagsRec vdFlags[]={
  VDF_REACTIONS,'r',
  VDF_PARTICLES,'p',
  VDF_NOEXPORT,'n',
  0,0};

struct _NameRec vdTypes[]={
  VDT_INT,"int",
  VDT_FLOAT,"float",
  VDT_STRING,"string",
  0,NULL};

int SaveDoc(Doc ss,char* fileName) {
  FILE* f;
  int i,j,k,l;
  VarDef vd;
  Particle p;
  Index ix,ix1;

  f=fopen(fileName,"w");
  if (f==NULL) return -1;

  fprintf(f,STR_AMDS_FILE);
  fprintf(f,"Reaction subset file produced by amds version %g\n\n",
    (double)GetVersion()/100);


  fprintf(f,STR_DATA);
  fprintf(f,"FileVersion %d\n",FILE_VERSION);

  fprintf(f,"VarDefs1 %u\n",(unsigned)GroupCount(ss->varDefs));
  for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
    fprintf(f,"%s %s\n",Flags2Str(vd->flags,vdFlags),
      Int2Name(vd->type,vdTypes));
    fprintf(f,"%s\n%s\n",GetVarDefName(vd),GetVarDefDescr(vd));
  }

  fprintf(f,"EnabledParticles1 %d\n",ss->reactionCount);
  for (i=0;i<ss->reactionCount;i++) {
    fprintf(f,"Reaction %s %u\n",ss->data[i].r->name,
      (unsigned)GroupCount(ss->data[i].enabled));
    for (p=Group1st(ss->data[i].enabled,&ix);p!=NULL;p=Next(&ix))
      fprintf(f,"%s\n",p->name);
  }

  fprintf(f,"Vars1 %d\n",ss->reactionCount);
  for (i=0;i<ss->reactionCount;i++) {
    fprintf(f,"Reaction %s %u\n",ss->data[i].r->name,
      (unsigned)GroupCount(ss->data[i].r->inputSet));
    for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
      if (~vd->flags & VDF_REACTIONS) continue;
      fprintf(f,"%s\n",GetReactionVar(ss,ss->data[i].r,vd));
    }
    for (p=Group1st(ss->data[i].r->inputSet,&ix1);p!=NULL;p=Next(&ix1)) {
      fprintf(f,"Particle %s\n",p->name);
      for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
	if (~vd->flags & VDF_PARTICLES) continue;
	fprintf(f,"%s\n",GetParticleVar(ss,ss->data[i].r,p,vd));
      }
    }
  }

  fprintf(f,"StartupParticles2 %u\n",(unsigned)GroupCount(ss->startupParticles));
  for (p=Group1st(ss->startupParticles,&ix);p!=NULL;p=Next(&ix))
    fprintf(f,"%s\n",p->name);

  fputs(STR_ENDDATA,f);
  fclose(f);

  SetDocFilename(ss,fileName);
  UndoMark(ss);
  ss->alt=0;

  return 0;
}

int LoadDoc(Doc ss,char* fileName) {
  FILE* f;
  char s[2048],s1[2048],s2[2048];
  int i,j,k,n,bErr=0,nRVars,nPVars;
  unsigned long l1;
  VarDef vd;
  Reaction r;
  Particle p;
  Index ix;

  f=fopen(fileName,"r");
  if (f==NULL) return -1;

  if (fgets(s,sizeof(s)-1,f)==NULL) goto badFormat;

  if (strcmp(s,STR_AMDS_FILE)) goto badFormat;

  while (fgets(s,sizeof(s),f)!=NULL)
    if (!strcmp(s,STR_DATA)) break;

  fgets(s,sizeof(s)-1,f);
  if (sscanf(s,"FileVersion %d",&i)!=1) goto badFile;
  if (i!=1 && i!=2) goto badVersion;

  while (fgets(s,sizeof(s),f)!=NULL) {
    if (!strcmp(s,STR_ENDDATA)) break;

    else if (sscanf(s,"VarDefs1 %d",&n)==1) {
      for (i=0;i<n;i++) {
	fgets(s,sizeof(s),f);                     /* <flags> <type> */
	if (sscanf(s,"%s%s",s1,s2)!=2) {bErr=1;continue;}
	l1=0;
	Str2Flags(s1,&l1,vdFlags);
	j=Name2Int(s2,vdTypes);
	fgets(s,sizeof(s),f);                     /* <name> */
	if (sscanf(s,"%s",s1)!=1) {bErr=2;continue;}
	vd=AddVarDef(ss,s1);
	ChangeVarDef(ss,vd,j,(int)l1);
	fgets(s,sizeof(s),f);                     /* <descr> */
	if (*s && s[strlen(s)-1]=='\n') s[strlen(s)-1]=0;
	SetVarDefDescr(ss,vd,s);
      }
    }

    else if (sscanf(s,"EnabledParticles1 %d",&n)==1) {
      for (i=0;i<n;i++) {
	fgets(s,sizeof(s)-1,f);                   /* Reaction <id> <count>*/
	if (sscanf(s,"Reaction %s %d",s1,&k)!=2) {bErr=3;continue;}
	r=FindReactionEx(ss->db,s1,FRX_NOASSERT);
        if (r!=NULL) for (j=0;j<k;j++) {
	  fgets(s,sizeof(s)-1,f);                 /* <particle id> */
	  if (sscanf(s,"%s",s1)!=1) {bErr=4;continue;}
	  p=FindParticle(ss->db,s1);
	  ActivateReaction(ss,r,p,True);
	}
      }
    }

    else if (sscanf(s,"Vars1 %d",&n)==1) {
      for (i=0;i<n;i++) {
	fgets(s,sizeof(s)-1,f);                   /* Reaction <id> <cnt> */
	if (sscanf(s,"Reaction %s%d",s1,&k)!=2) {bErr=5;continue;}
	r=FindReactionEx(ss->db,s1,FRX_NOASSERT);
	if (r!=NULL) for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
	  if (~vd->flags & VDF_REACTIONS) continue;
	  fgets(s,sizeof(s)-1,f);                 /* <value> */
	  if (*s && s[strlen(s)-1]=='\n') s[strlen(s)-1]=0;
	  SetReactionVar(ss,r,vd,s);
	}
	if (r!=NULL) for (j=0;j<k;j++) {
	  fgets(s,sizeof(s)-1,f);                 /* Particle <id> */
	  if (sscanf(s,"Particle %s",s1)!=1) {bErr=6;continue;}
	  p=FindParticle(ss->db,s1);
	  for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
	    if (~vd->flags & VDF_PARTICLES) continue;
	    fgets(s,sizeof(s)-1,f);               /* <value> */
	    if (*s && s[strlen(s)-1]=='\n') s[strlen(s)-1]=0;
	    SetParticleVar(ss,r,p,vd,s);
	  }
	}
      }
    }

    else if (sscanf(s,"StartupParticles2 %d",&n)==1) {
      for (i=0;i<n;i++) {
	fgets(s,sizeof(s)-1,f);
	if (sscanf(s,"%s",s1)!=1) {bErr=8;continue;}
	p=FindParticle(ss->db,s1);
	SetStartupParticle(ss,p,True);
      }
    }

    else bErr=7;
  }

  fclose(f);
  SetDocFilename(ss,fileName);
  UndoMark(ss);
  FreeUndoInfo(ss);
  ss->alt=0;
  return 0;

  badFormat:
  badFile:
  badVersion:
  fclose(f);
  return -2;
}

static char* Flags2Str(unsigned long flags,FlagsRec fr) {
  static char buf[400];
  int i;

  for (i=0;fr[i].c;i++) {
    buf[2*i]=(flags & fr[i].mask) ? '+' : '-';
    buf[2*i+1]=fr[i].c;
  }
  buf[2*i]=0;

  return buf;
}

static void Str2Flags(char* s,unsigned long* flags,FlagsRec fr) {
  int i,j;

  for (i=0;s[i];i+=2) {
    for (j=0;fr[j].c;j++) if (fr[j].c==s[i+1]) break;
    if (!fr[j].c) assert(0);
    s[i]=='+' ? (*flags |=fr[j].mask) : (*flags &=~ fr[j].mask);
  }
}

static char* Int2Name(int val,NameRec nr) {
  int i;

  for (i=0;nr[i].s!=NULL;i++)
    if (val==nr[i].val) return nr[i].s;
  assert(0);
  /*FatalError("Int2Name()-notFound%d: fatal error 1",val);*/
  return NULL;
}

static int Name2Int(char* name,NameRec nr) {
  int i;

  for (i=0;nr[i].s!=NULL;i++)
    if (!strcmp(name,nr[i].s)) return nr[i].val;
  assert(0);
  /*FatalError("Name2Int()-notFound%s: fatal error 1",name);*/
  return -1;
}

int OutputDoc(Doc d,char* fileName) {
  FILE* f;
  int i,j,k,l;
  VarDef vd;
  Reaction r;
  Particle p;
  Group g;
  Index ix,ix1,ix2;

  f=fopen(fileName,"w");
  if (f==NULL) return -1;

  fprintf(f,"# Output file produced by amds version %g\n",
	  (double)GetVersion()/100);
  fprintf(f,"# within SOLPS-ITER GIT version %s\n\n",
          GIT_VERSION);

  fprintf(f,"filevers %d\n",OUTPUT_VERSION);

  g=GetActiveReactions(d);

  fprintf(f,"reactns %u\n",(unsigned)GroupCount(g));
  for (r=Group1st(g,&ix);r!=NULL;r=Next(&ix))
    fprintf(f,"%s %s %s\n",GetReactionDatabase(r),
	GetReactionSection(r),GetReactionNumber(r));

  for (vd=Group1st(d->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
    if (vd->flags & VDF_NOEXPORT) continue;
    fprintf(f,"%s\n",GetVarDefName(vd));
    for (r=Group1st(g,&ix1);r!=NULL;r=Next(&ix1)) {
      if (vd->flags & VDF_REACTIONS)
	fprintf(f,"%s\n",GetReactionVar(d,r,vd));
      if (vd->flags & VDF_PARTICLES)
	for (p=Group1st(r->inputSet,&ix2);p!=NULL;p=Next(&ix2))
	  fprintf(f,"%s\n",GetParticleVar(d,r,p,vd));
    }
  }

  /*fprintf(f,"startupp %d\n",GroupCount(ss->startupParticles));
  for (p=Group1st(ss->startupParticles,&ix);p!=NULL;p=Next(&ix))
    fprintf(f,"%s\n",p->name);

  */
  fprintf(f,"finish\n");
  fclose(f);

  return 0;
}


