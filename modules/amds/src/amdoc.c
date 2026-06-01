#include "amds.h"

typedef struct _ActivateRec {
  struct _ActRec ar;
  Reaction r;
  Particle p;
}* ActivateRec;
static int ActActivateReaction(Doc ss,ActivateRec ar);

Doc CreateDoc(Database db) {
  Doc ss;
  Reaction r;
  Index ix;
  int i;

  ss=Malloc(sizeof(*ss));
  ss->db=db;
  ss->views=CreateGroup();
  ss->alt=0;
  ss->varDefs=CreateGroup();
  ss->reactionCount=GroupCount(db->reactions);
  ss->data=Malloc(sizeof(*ss->data)*ss->reactionCount);

  for (r=Group1st(db->reactions,&ix);r!=NULL;r=Next(&ix)) {
    ss->data[r->number].r=r;
    ss->data[r->number].enabled=CreateGroup();
    ss->data[r->number].reactionVars=CreateVars();
    ss->data[r->number].particleVars=CreateGroup();
    for (i=0;i<GroupCount(r->inputSet);i++)
      GroupAdd(ss->data[r->number].particleVars,CreateVars());
  }

  ss->startupParticles=CreateGroup();
  ss->fileName=MallocString("");

  ss->undoStack=CreateStack();
  ss->redoStack=CreateStack();
  ss->undoMode=UM_NONE;

  return ss;
}

void* FreeDoc(Doc ss) {
  Particle p;
  Vars v;
  VarDef vd;
  Index ix;
  int i;

  assert(!GroupCount(ss->views));

  SetDocFilename(ss,"");

  for (p=Group1st(ss->startupParticles,&ix);p!=NULL;p=Next(&ix))
    SetStartupParticle(ss,p,False);

  for (vd=Group1st(ss->varDefs,&ix);vd!=NULL;vd=Next(&ix))
    DelVarDef(ss,vd);

  for (i=0;i<ss->reactionCount;i++) {
    for(v=Group1st(ss->data[i].particleVars,&ix);v!=NULL;v=Next(&ix))
      FreeVars(v);
    FreeGroup(ss->data[i].enabled);
    FreeGroup(ss->data[i].particleVars);
    FreeVars(ss->data[i].reactionVars);
  }
  Free(ss->data);
  Free(ss->fileName);

  FreeUndoInfo(ss);
  FreeGroup(ss->redoStack);
  FreeGroup(ss->undoStack);

  FreeGroup(ss->startupParticles);
  FreeGroup(ss->varDefs);

  FreeGroup(ss->views);
  Free(ss);

  return NULL;
}

void NotifyDoc(Doc ss,int msg,void* obj) {
  View w;
  Index ix;

  for (w=Group1st(ss->views,&ix);w!=NULL;w=Next(&ix))
    NotifyView(w,msg,obj);
}

void ClearDoc(Doc ss) {
  Reaction r;
  Index ix;

  for (r=Group1st(ss->db->reactions,&ix);r!=NULL;r=Next(&ix))
    ActivateReaction(ss,r,NULL,False);
}

void ActivateReaction(Doc ss,Reaction r,Particle p,int bEnable) {
  Group g;
  Index ix;
  struct _ActivateRec ar;

  g=ss->data[r->number].enabled;

  if (p==NULL) {
    for (p=Group1st(r->inputSet,&ix);p!=NULL;p=Next(&ix))
      ActivateReaction(ss,r,p,bEnable);
  } else {
    if (!bEnable != !InGroup(g,p)) {
      ar.r=r;
      ar.p=p;
      ActActivateReaction(ss,&ar);
    }
  }
}

void SetStartupParticle(Doc d,Particle p,int status) {
  if (!IsStartupParticle(d,p)^status) return;
  ChangeGroup(d,&d->startupParticles,p,status);
}

/*
void SetReactionVar(Doc ss,Reaction r,Particle p,char* name,char* val) {
  Vars v;

  v=(p==NULL) ? ss->data[r->number].reactionVars :
    GroupAt(ss->data[r->number].particleVars,GroupIndex(r->inputSet,p));

  SetVar(v,name,val);
}

char* GetReactionVar(Doc ss,Reaction r,Particle p,char* name) {
  Vars v;

  v=(p==NULL) ? ss->data[r->number].reactionVars :
    GroupAt(ss->data[r->number].particleVars,GroupIndex(r->inputSet,p));

  return GetVar(v,name);
}
  */
void CopyReaction(Doc src,Doc dest,Reaction r,int bVars) {
  Particle p;
  Index ix;
  int i;

  ActivateReaction(dest,r,NULL,False);

  for (p=Group1st(src->data[r->number].enabled,&ix);p!=NULL;p=Next(&ix))
    ActivateReaction(dest,r,p,True);

/*  if (bVars) {
    CopyVars(src->data[r->number].reactionVars,
      dest->data[r->number].reactionVars);
    for (i=0;i<GroupCount(r->inputSet);i++)
      CopyVars(GroupAt(src->data[r->number].particleVars,i),
	GroupAt(dest->data[r->number].particleVars,i));
  } */
}

void CopyDoc(Doc src,Doc dest) {
  Reaction r;
  Index ix;

  for (r=Group1st(src->db->reactions,&ix);r!=NULL;r=Next(&ix))
    CopyReaction(src,dest,r,True);
}

static int ActActivateReaction(Doc ss,ActivateRec ar) {
  ActivateRec ur;

  ur=(ActivateRec)CreateActRec(sizeof(*ur),(ActProc)ActActivateReaction);
  ur->r=ar->r;
  ur->p=ar->p;

  if (InGroup(ss->data[ar->r->number].enabled,ar->p))
    GroupDel(ss->data[ar->r->number].enabled,ar->p);
  else
    GroupAdd(ss->data[ar->r->number].enabled,ar->p);

  AddUndoRec(ss,(ActRec)ur);
  NotifyDoc(ss,N_ENABLE,ar->r);
  return 0;
}

Group GetActiveReactions(Doc d) {
  Group g;
  Reaction r;
  Index ix;

  g=CreateGroup();

  for (r=Group1st(d->db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (ReactionActive(d,r)) GroupAdd(g,r);

  return g;
}

void SetDocFilename(Doc d,char* fName) {
  ChangeString(d,&d->fileName,fName);
}
