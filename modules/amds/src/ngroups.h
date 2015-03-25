/* NGROUPS.C definitions
*/

#ifndef _ngroups_h
#define _ngroups_h

#define NGROUP_FSORTED     0x0001
#define NGROUP_STACK       0x0002

typedef struct _NGroup* NGroup;
typedef struct _NGroupIndex NGroupIndex;

typedef NGroup Group;
typedef NGroup Stack;
typedef NGroupIndex Index;

typedef int (*GroupSortProc)(void*,void*,void*);

struct _NGroup {
  unsigned flags;
  size_t size,allocSize;
  struct NGroupListEntry* list;
  size_t* array;
  size_t lastIndex;
};

struct _NGroupIndex {
  NGroup g;
  size_t iCur,iNext,iPrev;
  void* cur,*prev,*next;
};

struct NGroupListEntry {
  void* ptr;
  size_t prev,next,arrayIndex;
};

#define CreateGroup()      NGroup_Create(0)
#define CreateStack()      NGroup_Create(NGROUP_STACK)
#define FreeGroup(g)       NGroup_Free(g)
#define Group1st           NGroup1st
#define Next               NGroupNext
#define Prev               NGroupPrev

#define IsEmptyGroup(g) (((NGroup)(g))->size==2)
#define GroupCount(g) (((NGroup)(g))->size-2)

void FatalError(char* format,...) ;
int zfprintf(FILE* f,char* format,...);

void ValidatePtr(void* p,char* s) ;

void* Malloc(size_t size) ;
void* Realloc(void* p,size_t size) ;
void* Free(void* p) ;
char* MallocString(char* str);
char* ReallocString(char* s,char* s1);

unsigned GetSafeAlignment(void);
unsigned SafeAlignedSize(unsigned size);
void* SafeAlignedPointer(void* p,void* base);

NGroup NGroup_Create(unsigned flags) ;
void* NGroup_Free(NGroup g) ;
void* NGroup1st(NGroup g,NGroupIndex* pi) ;
void* NGroupNext(NGroupIndex* pi) ;
void* NGroupPrev(NGroupIndex* pi) ;
int InGroup(Group g,void* p) ;
void GroupAdd(Group g,void* p) ;
void GroupAddAt(Group g,void* after,void* p);
void GroupDel(Group g,void* p) ;
void RevertGroup(Group g);
void* FreeMallocedGroup(Group g);
Group CopyGroup(Group g,Group dest);
void MergeGroup(Group dest,Group src);
void MergeGroupOfGroups(Group dest,Group src);
void ClearGroup(Group g);
size_t GroupIndex(Group g,void* p);
void* GroupAt(Group g,size_t index);
int GroupInGroup(Group g,Group in);
int InGroupCount(Group g,void* p);
void GroupQSort(Group g,GroupSortProc gsp,void* userData);

Group GetEmptyStaticGroup(void);

#endif
