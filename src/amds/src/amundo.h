/* Undo structures & functions, generic reversible actions */


#define UM_NONE 0
#define UM_UNDO 1
#define UM_REDO 2
#define UM_CANCEL 3

/* amds - support for reversible operations */

typedef struct _ActRec* ActRec;
typedef struct _DelRec* DelRec;

typedef int (*ActProc)(Doc,ActRec);

struct _ActRec {
  ActProc actProc;
  void* obj1,*obj2;
};

struct _DelRec {
  struct _ActRec ar;
  void* obj;
};

#define Undo(ss)   ProcessUndo(ss,UM_UNDO)
#define Redo(ss)   ProcessUndo(ss,UM_REDO)
#define Cancel(ss) ProcessUndo(ss,UM_CANCEL)

ActRec CreateActRec(size_t size,ActProc ap);
void*  FreeActRec(ActRec ar);
void AddUndoRec(Doc ss,ActRec ar);

void ProcessUndo(Doc ss,int mode);
void FreeUndoInfo(Doc ss);

void UndoMark(Doc ss);
void ChangeGroup(Doc ss,Group* pGroup,void* member,int status);
void ChangeString(Doc ss,char** pString,char* newVal);
