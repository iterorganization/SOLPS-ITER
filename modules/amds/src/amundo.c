#include "amds.h"

typedef struct _ChangeGroupRec {
  struct _ActRec ar;
  Group* pGroup;
  void* member;
  int status;
}* ChangeGroupRec;

typedef struct _ChangeStringRec {
  struct _ActRec ar;
  char** pString;
}* ChangeStringRec;

static int ActUndoMark(Doc ss,ActRec ar);
static int ActChangeGroup(Doc ss,ChangeGroupRec ar);
static int ActChangeString(Doc ss,ChangeStringRec ar);

/* Create action record */

ActRec CreateActRec(size_t size,ActProc ap) {
  ActRec ar;

  ar=Malloc(size);
  ar->actProc=ap;
  ar->obj1=ar->obj2=NULL;

  return ar;
}

/* Free action record */

void* FreeActRec(ActRec ar) {
  ValidatePtr(ar,"FreeActRec");

  if (ar->obj1!=NULL) Free(ar->obj1);
  if (ar->obj2!=NULL) Free(ar->obj2);
  Free(ar);

  return NULL;
}

/* Remove undo information */

void FreeUndoInfo(Doc ss) {
  Index ix;
  ActRec ar;

  for (ar=Group1st(ss->undoStack,&ix);ar!=NULL;ar=Next(&ix)) {
    GroupDel(ss->undoStack,ar);
    FreeActRec(ar);
  }
  for (ar=Group1st(ss->redoStack,&ix);ar!=NULL;ar=Next(&ix)) {
    GroupDel(ss->redoStack,ar);
    FreeActRec(ar);
  }

  NotifyAlt(ss);
}

/* Add undo record */

void AddUndoRec(Doc ss,ActRec rec) {
  Group g;

  assert(ss!=NULL);
  assert(rec!=NULL);

/* FreeActRec(rec);return; */

  if (ss->undoMode==UM_NONE || ss->undoMode==UM_REDO) g=ss->undoStack; else
      if (ss->undoMode==UM_UNDO) g=ss->redoStack; else {
    FreeActRec(rec);
    return;
  }

/* Discard redundand UndoMarks */

  if (rec->actProc==(ActProc)ActUndoMark)
    if (((ActRec)Group1st(g,NULL))->actProc==rec->actProc)
       {FreeActRec(rec);return;}

/* Add into undo/redo stack */
  GroupAdd(g,rec);

  if (rec->actProc==(ActProc)ActUndoMark) {
    switch(ss->undoMode) {
      case UM_NONE:
	if (ss->alt<0) ss->alt=GroupCount(ss->undoStack);
	ss->alt++;
	break;
      case UM_REDO:
	ss->alt++;
	break;
      case UM_UNDO:
	ss->alt--;
	break;
    }
    NotifyAlt(ss);
  }
}

void ProcessUndo(Doc ss,int mode) {
  ActRec ar;
  Stack g;
  Index ix;
  int b;

  assert(ss->undoMode==UM_NONE);

  ar=Group1st(g=mode==UM_REDO ? ss->redoStack : ss->undoStack,&ix);
  if (ar==NULL) return;
  b= ar->actProc==(ActProc)ActUndoMark;
  if (b && mode==UM_CANCEL) return;

  ss->undoMode=mode;

  do {
    GroupDel(g,ar);
    if (!b) ss->undoMode=UM_CANCEL;
    if (ar->actProc!=(ActProc)ActUndoMark) ar->actProc(ss,ar);
    if (!b) ss->undoMode=mode;
    FreeActRec(ar);
    ar=Next(&ix);
  } while (ar!=NULL && ((ActRec)ar)->actProc!=ActUndoMark);

  if (b) UndoMark(ss);
  ss->undoMode=UM_NONE;

  NotifyAlt(ss);
}

void UndoMark(Doc ss) {
  struct _ActRec ar;

  assert(ss!=NULL);

  ActUndoMark(ss,&ar);
}

static int ActUndoMark(Doc ss,ActRec ar) {
  ActRec ur;

  ur=CreateActRec(sizeof(*ur),ActUndoMark);
  AddUndoRec(ss,ur);
  NotifyAlt(ss);
  return 0;
}

static int ActChangeString(Doc ss,ChangeStringRec ar) {
  ChangeStringRec ur;

  ur=(ChangeStringRec)CreateActRec(sizeof(*ur),(ActProc)ActChangeString);
  ur->pString=ar->pString;
  ur->ar.obj1=*ar->pString;

  *ar->pString=ar->ar.obj1;
  ar->ar.obj1=NULL;

  AddUndoRec(ss,(ActRec)ur);
  return 0;
}

static int ActChangeGroup(Doc ss,ChangeGroupRec ar) {
  ChangeGroupRec ur;

  ur=(ChangeGroupRec)CreateActRec(sizeof(*ur),(ActProc)ActChangeGroup);
  ur->pGroup=ar->pGroup;
  ur->member=ar->member;
  ur->status=!ar->status;

  if (ar->status) GroupAdd(*ar->pGroup,ar->member);
  else GroupDel(*ar->pGroup,ar->member);

  AddUndoRec(ss,(ActRec)ur);
  return 0;
}

void ChangeGroup(Doc ss,Group* pGroup,void* member,int status) {
  struct _ChangeGroupRec ar;

  ar.pGroup=pGroup;
  ar.member=member;
  ar.status=status;

  ActChangeGroup(ss,&ar);
}

void ChangeString(Doc ss,char** pString,char* newVal) {
  struct _ChangeStringRec ar;

  ar.pString=pString;
  ar.ar.obj1=MallocString(newVal==NULL? "" : newVal);

  ActChangeString(ss,&ar);
}
