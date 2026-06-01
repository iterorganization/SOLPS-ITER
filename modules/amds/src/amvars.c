#include "amds.h"

typedef struct _ChangeVarDefRec {
  struct _ActRec ar;
  VarDef vd;
  int type,flags;
}* ChangeVarDefRec;

typedef struct _ChangeVarDefStrRec {
  struct _ActRec ar;
  VarDef vd;
  char* var;
}* ChangeVarDefStrRec;

typedef struct _SetVarRec {
  struct _ActRec ar;
  VarDef vd;
  Reaction r;
  Particle p;
}* SetVarRec;

static int ActAddVarDef(Doc ss,ActRec ar);
static int ActChangeVarDef(Doc ss,ChangeVarDefRec ar);
static int ActChangeVarDefStr(Doc ss,ChangeVarDefStrRec ar);
static int ActDelVarDef(Doc ss,DelRec dr);
static int ActSetVar(Doc ss,SetVarRec ar);

VarDef AddVarDef(Doc ss,char* name) {
  struct _ActRec ar;
  VarDef vd;

  vd=Malloc(sizeof(*vd));
  vd->v=NULL;
  vd->type=VDT_INT;
  vd->flags=VDF_REACTIONS;

  ar.obj1=vd;
  ActAddVarDef(ss,&ar);

  SetVarDefName(ss,vd,name);

  return vd;
}

int ChangeVarDef(Doc ss,VarDef vd,int type,int flags) {
  struct _ChangeVarDefRec ar;

  ar.vd=vd;
  ar.type=type;
  ar.flags=flags;
  ActChangeVarDef(ss,&ar);

  return 0;
}

int SetVarDefStr(Doc ss,VarDef vd,char* var,char* newVal) {
  struct _ChangeVarDefStrRec ar;

  ar.vd=vd;
  ar.var=var;
  ar.ar.obj1= newVal==NULL? NULL : MallocString(newVal);

  ActChangeVarDefStr(ss,&ar);

  return 0;
}

void* DelVarDef(Doc ss,VarDef vd) {
  struct _DelRec ar;

  SetVarDefName(ss,vd,NULL);
  SetVarDefDescr(ss,vd,NULL);
  SetVarDefHelp(ss,vd,NULL);
  SetVarDefMenu(ss,vd,NULL);

  ar.obj=vd;
  ActDelVarDef(ss,&ar);

  return NULL;
}

char* GetParticleVar(Doc ss,Reaction r,Particle p,VarDef vd) {
  Vars v;
  char* s;

  v= p==NULL ? ss->data[r->number].reactionVars :
    GroupAt(ss->data[r->number].particleVars,GroupIndex(r->inputSet,p));

  s=GetVar2(v,GetVar(vd->v,VDS_NAME),NULL);
  if (s==NULL) s=GetVar(r->vars,GetVar(vd->v,VDS_NAME));
  return s;
}

void SetParticleVar(Doc ss,Reaction r,Particle p,VarDef vd,char* val) {
  struct _SetVarRec ar;

  ar.ar.obj1=MallocString(GetVar(vd->v,VDS_NAME));
  ar.ar.obj2= val==NULL? val : MallocString(val);
  ar.r=r;
  ar.p=p;

  ActSetVar(ss,&ar);
}

static int ActAddVarDef(Doc ss,ActRec ar) {
  DelRec ur;
  VarDef vd=ar->obj1;

  ur=(void*)CreateActRec(sizeof(*ur),(ActProc)ActDelVarDef);
  ur->obj=vd;

  vd->v=CreateVars();
  GroupAdd(ss->varDefs,vd);

  ar->obj1=NULL;
  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_VARDEFS,NULL);
  return 0;
}

static int ActChangeVarDef(Doc ss,ChangeVarDefRec ar) {
  ChangeVarDefRec ur;

  ur=(void*)CreateActRec(sizeof(*ur),(ActProc)ActChangeVarDef);
  ur->vd=ar->vd;
  ur->type=ar->vd->type;
  ur->flags=ar->vd->flags;

  ar->vd->type=ar->type;
  ar->vd->flags=ar->flags;

  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_VARDEFS,NULL);
  return 0;
}

static int ActChangeVarDefStr(Doc ss,ChangeVarDefStrRec ar) {
  ChangeVarDefStrRec ur;

  ur=(void*)CreateActRec(sizeof(*ur),(ActProc)ActChangeVarDefStr);
  ur->vd=ar->vd;
  ur->var=ar->var;
  ur->ar.obj1=MallocString(GetVar(ar->vd->v,ar->var));

  SetVar(ar->vd->v,ar->var,ar->ar.obj1);

  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_VARDEFS,NULL);
  return 0;
}

static int ActDelVarDef(Doc ss,DelRec ar) {
  ActRec ur;
  VarDef vd=ar->obj;

  ur=CreateActRec(sizeof(*ur),(ActProc)ActAddVarDef);
  ur->obj1=vd;

  GroupDel(ss->varDefs,vd);
  vd->v=FreeVars(vd->v);

  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_DEL,vd);
  NotifyDoc(ss,N_VARDEFS,NULL);
  return 0;
}

static int ActSetVar(Doc ss,SetVarRec ar) {
  SetVarRec ur;
  Vars v;

  v= ar->p!=NULL? GroupAt(ss->data[ar->r->number].particleVars,
      GroupIndex(ar->r->inputSet,ar->p)) :
    ss->data[ar->r->number].reactionVars;

  ur=(void*)CreateActRec(sizeof(*ur),(ActProc)ActSetVar);
  ur->ar.obj1=ar->ar.obj1;
  ur->ar.obj2=MallocString(GetVar(v,ar->ar.obj1));
  ur->r=ar->r;
  ur->p=ar->p;

  SetVar(v,ar->ar.obj1,ar->ar.obj2);

  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_SETVAR,NULL);
  return 0;
}


VarDef FindVarDef(Doc ss,char* name) {
  VarDef vd;
  Index ix;
  
  for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix))
    if (!strcmp(GetVarDefName(vd),name)) return vd;
    
  return NULL;
}

void UpdateVarDefs(Doc ss,Doc cfg) {
  VarDef vd,vd1;
  Index ix;
  
  
  
  /* Delete vardefs first */
  
  for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix)) {
    vd1=FindVarDef(cfg,GetVarDefName(vd));
    if (vd1==NULL) {
 printf("dvd: %s\n",GetVarDefName(vd));
      DelVarDef(ss,vd);
    } else {
      if (vd1->type!=vd->type || vd1->flags!=vd->flags) {
 printf("cvd: %s\n",GetVarDefName(vd)); 
        ChangeVarDef(ss,vd,vd1->type,vd1->flags);
      }
      SetVarDefDescr(ss,vd,GetVarDefDescr(vd1));
      SetVarDefHelp(ss,vd,GetVarDefHelp(vd1));
      SetVarDefMenu(ss,vd,GetVarDefMenu(vd1));
    }
  }

  for (vd1=Group1st(cfg->varDefs,&ix);vd1!=NULL;vd1=Next(&ix)) {
    vd=FindVarDef(ss,GetVarDefName(vd1));
    if (vd==NULL) {
 printf("crvd: %s\n",GetVarDefName(vd1)); 
      vd=AddVarDef(ss,GetVarDefName(vd1));
      if (vd1->type!=vd->type || vd1->flags!=vd->flags) {
 printf("cvd: %s\n",GetVarDefName(vd));
        ChangeVarDef(ss,vd,vd1->type,vd1->flags);
      }
      SetVarDefDescr(ss,vd,GetVarDefDescr(vd1));
      SetVarDefHelp(ss,vd,GetVarDefHelp(vd1));
      SetVarDefMenu(ss,vd,GetVarDefMenu(vd1));
    }
  }
}
