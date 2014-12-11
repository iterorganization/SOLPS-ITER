/*  NGroups - convenient memory allocation & container class functions
 *  Shared between DivGeo, amds and misc.
 *
 *  Changes:
 *
 *  19990329    Realloc(NULL) now works as Malloc instead of aborting
 *
 *  19990322    "Free() pattern" now used in GATHER_STATISTICS mode.
 *
 *  1998/09/30  Memory leak in GroupQSort fixed
 *              Difference between Malloc/Free count now shown in stats
 *              GetEmptyStaticGroup() added
 *  ????/??/??  GroupQSort added
 *
 *  970430  MergeGroup(), ClearGroup() added
 *
 *  970410  Malloc() fingerprint feature added
 *
 *  970325  Statistics feature added
 *
 *  970324  Removed references to PC_VERSION, DivGeo
 *          ValidatePtr() now uses assert() to produce memory dump
 *
 */

/* Compile-time settings //////////////////////////////////////////// */

/*#define GATHER_STATISTICS*/

#define NGROUP_ALLOCINCR   20

/* Standard header files //////////////////////////////////////////// */

#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <string.h>

#define _ngroups_c
#include "ngroups.h"

/* Utility macros /////////////////////////////////////////////////// */

#ifndef swap
#define swap(x,y) ((x)+=(y),(y)=(x)-(y),(x)-=(y))
#endif


/* Statistics stuff ///////////////////////////////////////////////// */

#ifdef GATHER_STATISTICS

static long
  mallocStats=0,
  reallocStats=0,
  freeStats=0,
  findCacheHits=0,
  findCacheMisses=0,
  findNotFound=0,
  groupCreates=0,
  groupFrees=0,
  group1stOps=0,
  groupNextOps=0,
  groupPrevOps=0;
static int statInitialized=0;

#define INCR_STATS(n) ((n)++)
#define INIT_STATS InitGroupStatistics

#define MALLOC_TRACE
#else

#define INCR_STATS(n)
#define INIT_STATS()

#endif

#ifdef GATHER_STATISTICS

static void PrintGroupStatistics(void) {
  fprintf(stderr,
      "NGroup statistics\n"
      "-----------------\n"
      "Malloc's        %d\n"
      "Realloc's       %d\n"
      "Free's          %d\n"
      "FindCacheHits   %d\n"
      "FindCacheMisses %d\n"
      "FindNotFounds   %d\n"
      "GroupCreate's   %d\n"
      "GroupFree's     %d\n"
      "Group1st's      %d\n"
      "GroupNext's     %d\n"
      "GroupPrev's     %d\n"
      ,mallocStats,reallocStats,freeStats,findCacheHits,findCacheMisses,
      findNotFound,
      groupCreates,groupFrees,group1stOps,groupNextOps,groupPrevOps);
  if (mallocStats-freeStats || groupCreates-groupFrees)
    fprintf(stderr,
      "\n*** MEMORY LEAK ***\n"
      "#Malloc's-#Free's:           %d\n"
      "#GroupCreate's-#GroupFree's: %d\n",
      mallocStats-freeStats,groupCreates-groupFrees);
}

static void InitGroupStatistics(void) {
  if (!statInitialized) {
    atexit(PrintGroupStatistics);
    statInitialized++;
  }
}

#endif

/* Diagnostics ////////////////////////////////////////////////////// */

void FatalError(char* format,...) {
  va_list vl;

  va_start(vl,format);
  vfprintf(stderr,format,vl);
  va_end(vl);

  fprintf(stderr,"\n");
  if (*format=='\r') exit(1);
  assert(0);
}

void ValidatePtr(void* p,char* s) {
  assert(p!=NULL);
}

/* Utilities //////////////////////////////////////////////////////// */

int zfprintf(FILE* f,char* format,...) {
  va_list vl;
  int i=0;

  va_start(vl,format);
  if (f!=NULL) i=vfprintf(f,format,vl);
  va_end(vl);

  return i;
}

/* Memory allocation //////////////////////////////////////////////// */

#ifdef MALLOC_TRACE

#define MALLOC_PATTERN_OVERHEAD SafeAlignedSize(sizeof(long))
#define MALLOC_PATTERN 0x13243546
#define FREE_PATTERN   0x1324354A

#else

#define MALLOC_PATTERN_OVERHEAD 0

#endif

void* Malloc(size_t size) {
  void* p;

  INIT_STATS();
  INCR_STATS(mallocStats);

  p=malloc(size+MALLOC_PATTERN_OVERHEAD);
  if (p==NULL)
    FatalError("Malloc()-no memory: fatal error 1");

  #ifdef MALLOC_TRACE
    *(long*)p=MALLOC_PATTERN;
    p=(char*)p+MALLOC_PATTERN_OVERHEAD;
  #endif

  return p;
}

void* Realloc(void* p,size_t size) {
  if (p==NULL) return Malloc(size);
  
  ValidatePtr(p,"Realloc");

  INCR_STATS(reallocStats);

  #ifdef MALLOC_TRACE
    p=(char*)p-MALLOC_PATTERN_OVERHEAD;
  #endif

  p=realloc(p,size+MALLOC_PATTERN_OVERHEAD);
  if (p==NULL)
    FatalError("Realloc()-no memory: fatal error 1");

  #ifdef MALLOC_TRACE
    *(long*)p=MALLOC_PATTERN;
    p=(char*)p+MALLOC_PATTERN_OVERHEAD;
  #endif

  return p;
}

void* Free(void* p) {
  ValidatePtr(p,"Free");

  INCR_STATS(freeStats);

  #ifdef MALLOC_TRACE
    p=(char*)p-MALLOC_PATTERN_OVERHEAD;
    if (*(long*)p!=MALLOC_PATTERN) {
      FatalError("Free(): bad malloc pattern: %08x",*(long*)p);
    }
/*    assert(*(long*)p==MALLOC_PATTERN); */
    *(long*)p=FREE_PATTERN;
  #endif

  free(p);

  return NULL;
}

char* MallocString(char* s) {
  ValidatePtr(s,"MallocString");

  return strcpy(Malloc(strlen(s)+1),s);
}

char* ReallocString(char* s,char* s1) {
  size_t l;

  ValidatePtr(s1,"ReallocString_");

  if (s==NULL) return MallocString(s1);

  l=strlen(s);
  s=Realloc(s,l+strlen(s1)+1);
  strcpy(s+l,s1);

  return s;
}

unsigned GetSafeAlignment(void) {
  struct {
    char c;
    double d;
  } s;

  assert(sizeof(double)>=sizeof(long));
  assert(sizeof(double)>=sizeof(void*));

  return ((char*)&s.d)-((char*)&s.c);
}

unsigned SafeAlignedSize(unsigned size) {
  unsigned al=GetSafeAlignment();

  return (size+al-1)/al*al;
}

void* SafeAlignedPointer(void* p,void* base) {
  return ((char*)base)+SafeAlignedSize(((char*)p)-((char*)base));
}


/* Group management ///////////////////////////////////////////////// */

NGroup NGroup_Create(unsigned flags) {
  NGroup g;

  INCR_STATS(groupCreates);

  g=Malloc(sizeof(*g));
  g->flags=flags;
  g->size=g->allocSize=2;
  g->list=Malloc(g->allocSize*sizeof(*g->list));
  g->array=Malloc(g->allocSize*sizeof(*g->array));

  g->array[0]=g->list[0].arrayIndex=0;
  g->array[1]=g->list[1].arrayIndex=1;
  g->list[0].ptr=g->list[1].ptr=NULL;
  g->list[0].prev=g->list[1].prev=0;
  g->list[0].next=g->list[1].next=1;

  g->lastIndex=0;

  return g;
}

void* NGroup_Free(NGroup g) {
  INCR_STATS(groupFrees);

  Free(g->array);
  Free(g->list);
  Free(g);

  return NULL;
}

static void NGroup_UpdateIx(NGroup g,size_t i) {
  if (i<2)
    FatalError("NGroup_UpdateIx: fatal error 1");

  g->array[g->list[i].arrayIndex]=i;
  g->list[g->list[i].prev].next=i;
  g->list[g->list[i].next].prev=i;
}

static void NGroup_AddAt(NGroup g,size_t i,void* p) {
  if (i==1)
    FatalError("NGroup_AddAt: fatal error 1");

  g->size++;
  g->flags &=~ NGROUP_FSORTED;
  if (g->size>g->allocSize) {
    g->allocSize=g->size+NGROUP_ALLOCINCR;
    g->list=Realloc(g->list,sizeof(*g->list)*g->allocSize);
    g->array=Realloc(g->array,sizeof(*g->array)*g->allocSize);
  }
  g->list[g->size-1].ptr=p;
  g->list[g->size-1].arrayIndex=g->size-1;

  g->list[g->size-1].next=g->list[i].next;
  g->list[g->size-1].prev=i;
  NGroup_UpdateIx(g,g->size-1);
}

static void NGroup_DelAt(NGroup g,size_t i) {
  if (i<2)
    FatalError("NGroup_DelAt: fatal error 1");

  g->flags &=~ NGROUP_FSORTED;
  g->list[g->list[i].prev].next=g->list[i].next;
  g->list[g->list[i].next].prev=g->list[i].prev;
  g->size--;

  if (g->size!=g->list[i].arrayIndex) {
    g->list[g->array[g->size]].arrayIndex=g->list[i].arrayIndex;
    g->array[g->list[i].arrayIndex]=g->array[g->size];
  }

  if (g->size!=i) {
    g->list[i].ptr=g->list[g->size].ptr;
    g->list[i].next=g->list[g->size].next;
    g->list[i].prev=g->list[g->size].prev;
    g->list[i].arrayIndex=g->list[g->size].arrayIndex;
    NGroup_UpdateIx(g,i);
  }
}

static NGroup ngCurrent;

static int NGroup_QSortProc(const void* v1,const void* v2) {
  if (ngCurrent->list[*(size_t*)v1].ptr<ngCurrent->list[*(size_t*)v2].ptr)
    return -1;
  if (ngCurrent->list[*(size_t*)v1].ptr>ngCurrent->list[*(size_t*)v2].ptr)
    return 1;
  return 0;
}

static void NGroup_Sort(NGroup g) {
  size_t i;

  g->flags |= NGROUP_FSORTED;
  if (g->size) {
    ngCurrent=g;
    qsort(g->array,g->size,sizeof(*g->array),NGroup_QSortProc);
    for (i=0;i<g->size;i++) g->list[g->array[i]].arrayIndex=i;
    ngCurrent=NULL;
  }
}

/* *** better,but slow
*/
static size_t NGroup_Find(NGroup g,void* p,size_t index) {
  size_t i;

  ValidatePtr(g,"NGroup_Find");
  ValidatePtr(p,"NGroup_Find_");

  if (index>1 && index<g->size && g->list[index].ptr==p) {
    INCR_STATS(findCacheHits);
    return index;
  }

  for (i=0;i<g->size;i++) if (g->list[i].ptr==p) {
    INCR_STATS(findCacheMisses);
    return i;
  }

  INCR_STATS(findNotFound);

  return 0;
}

/* *** BAD: consecutive DelGroup commands work awful
static size_t NGroup_Find(NGroup g,void* p,size_t index) {
  size_t ix0,*pix;

  ValidatePtr(g,"NGroup_Find");
  ValidatePtr(p,"NGroup_Find_");

  if (index>1 && index<g->size && g->list[index].ptr==p) return index;
  if (~g->flags & NGROUP_FSORTED) NGroup_Sort(g);
  ix0=0;
  g->list[0].ptr=p;
  ngCurrent=g;
  pix=bsearch(&ix0,g->array+1,g->size-1,sizeof(*g->array),NGroup_QSortProc);
  ngCurrent=NULL;
  g->list[0].ptr=NULL;

  return pix==NULL ? 0 : *pix;
}
*/

void* NGroup1st(NGroup g,NGroupIndex* pi) {
  NGroupIndex ix;

  ValidatePtr(g,"NGroup1st");
  if (pi==NULL) pi=&ix;

  INCR_STATS(group1stOps);

  pi->g=g;
  pi->iCur=g->list[0].next;
  pi->iPrev=0;
  pi->iNext=g->list[pi->iCur].next;
  pi->cur=g->list[pi->iCur].ptr;
  pi->next=g->list[pi->iNext].ptr;
  pi->prev=g->list[pi->iPrev].ptr;

  g->lastIndex=pi->iCur;

  return pi->cur;
}

void* NGroupNext(NGroupIndex* pi) {
  ValidatePtr(pi,"NGroupNext");

  if (pi->cur==NULL && pi->next==NULL)
    FatalError("NGroupNext(): fatal error 1");

  INCR_STATS(groupNextOps);

  pi->prev=pi->cur;
  pi->iPrev=pi->iCur;
  pi->cur=pi->next;
  if (pi->cur!=NULL) {
    pi->iCur=NGroup_Find(pi->g,pi->next,pi->iNext);
    if (pi->iCur<2) FatalError("NGroupNext(): fatal error 2");
  } else pi->iCur=1;
  pi->iNext=pi->g->list[pi->iCur].next;
  pi->next=pi->g->list[pi->iNext].ptr;

  pi->g->lastIndex=pi->iCur;

  return pi->cur;
}

void* NGroupPrev(NGroupIndex* pi) {
  ValidatePtr(pi,"NGroupPrev");

  if (pi->cur==NULL && pi->prev==NULL)
    FatalError("NGroupNext(): fatal error 1");

  INCR_STATS(groupPrevOps);

  pi->next=pi->cur;
  pi->iNext=pi->iCur;
  pi->cur=pi->prev;
  if (pi->cur!=NULL) {
    pi->iCur=NGroup_Find(pi->g,pi->prev,pi->iPrev);
    if (pi->iCur<2) FatalError("NGroupPrev(): fatal error 2");
  } else pi->iCur=1;
  pi->iPrev=pi->g->list[pi->iCur].prev;
  pi->prev=pi->g->list[pi->iPrev].ptr;

  pi->g->lastIndex=pi->iCur;

  return pi->cur;
}

int InGroup(Group g,void* p) {
  ValidatePtr(g,"InGroup");
  ValidatePtr(p,"InGroup2");

  return NGroup_Find(g,p,g->lastIndex)!=0;
}

void GroupAdd(Group g,void* p) {
  ValidatePtr(g,"GAdd");
  ValidatePtr(p,"GAdd2");

  if (g->flags & NGROUP_STACK) NGroup_AddAt(g,0,p); else
    NGroup_AddAt(g,g->list[1].prev,p);
}

void GroupAddAt(Group g,void* after,void* p) {
  size_t i;

  ValidatePtr(g,"GroupAddAt");
  ValidatePtr(p,"GroupAddAt__");

  if (after!=NULL) {
    i=NGroup_Find(g,after,g->lastIndex);
    if (i<2) FatalError("GroupAddAt()-notFound: fatal error 1");
  } else i=0;

  NGroup_AddAt(g,i,p);
}

void GroupDel(Group g,void* p) {
  size_t i;

  ValidatePtr(g,"GDel");
  ValidatePtr(p,"GDel2");

  i=NGroup_Find(g,p,g->lastIndex);
  if (i<2)
    FatalError("GDel()-notFound: fatal error 1");
  NGroup_DelAt(g,i);
}

void RevertGroup(Group g) {
  size_t i;

  if (IsEmptyGroup(g)) return;

  swap(g->list[0].next,g->list[1].prev);
  for (i=2;i<g->size;i++) {
    swap(g->list[i].prev,g->list[i].next);
    if (g->list[i].next==0) g->list[i].next=1;
    if (g->list[i].prev==1) g->list[i].prev=0;
  }
}

void* FreeMallocedGroup(Group g) {
  Index ix;
  void* p;

  ValidatePtr(g,"FreeMallocedGroup");

  for (p=Group1st(g,&ix);p!=NULL;p=Next(&ix))
    Free(p);

  return FreeGroup(g);
}

Group CopyGroup(Group g,Group dest) {
  Group g1;

  if (dest==NULL) {
    g1=Malloc(sizeof(*g1));
    memmove(g1,g,sizeof(*g1));
    g1->list=Malloc(sizeof(*g1->list)*g1->allocSize);
    g1->array=Malloc(sizeof(*g1->array)*g1->allocSize);
    INCR_STATS(groupCreates);
  } else {
    g1=dest;
    g1->size=2;
    g1->array[0]=0;
    g1->array[1]=1;
    g1->flags=g->flags;
    g1->size=g1->allocSize=g->size;
    g1->list=Realloc(g1->list,g1->allocSize*sizeof(*g1->list));
    g1->array=Realloc(g1->array,g1->allocSize*sizeof(*g1->array));
  }
  memmove(g1->list,g->list,sizeof(*g1->list)*g1->allocSize);
  memmove(g1->array,g->array,sizeof(*g1->array)*g1->allocSize);

  return g1;
}

size_t GroupIndex(Group g,void* p) {
  Index ix;
  size_t index;
  void* cur;

  ValidatePtr(g,"GroupIndex");
  ValidatePtr(p,"GroupIndex_");

  for (index=0,cur=Group1st(g,&ix);cur!=NULL&&cur!=p;cur=Next(&ix)) index++;
  if (cur==NULL) FatalError("GroupIndex()-notFound: fatal error 1");

  return index;
}

void* GroupAt(Group g,size_t index) {
  Index ix;
  void* p;

  ValidatePtr(g,"GroupAt");

  for (p=Group1st(g,&ix);index && p!=NULL;p=Next(&ix)) index--;
  if (p==NULL) FatalError("GroupAt()-notFound: fatal error 1");

  return p;
}

int GroupInGroup(Group g,Group in) {
  void* p;
  Index ix;

  for (p=Group1st(g,&ix);p!=NULL;p=Next(&ix)) if (!InGroup(in,p)) return 0;

  return 1;
}

int InGroupCount(Group g,void* p) {
  int n=0;
  void* t;
  Index ix;

  for (t=Group1st(g,&ix);t!=NULL;t=Next(&ix)) if (t==p) n++;

  return n;
}

static GroupSortProc groupQSort_proc;
static void* groupQSort_userData;
static int volatile groupQSort_locks=0;

static int GroupQSort_Compare(const void* p1,const void* p2) {
  return groupQSort_proc(*(void**)p1,*(void**)p2,groupQSort_userData);
}

void GroupQSort(Group g,GroupSortProc proc,void* userData) {
  void** array;
  void* p;
  Index ix;
  int i,n;

  if (GroupCount(g)<2) return;
  assert(!(g->flags & NGROUP_STACK));

  array=Malloc(sizeof(*array)*(n=GroupCount(g)));
  for (i=0,p=Group1st(g,&ix);p!=NULL;p=Next(&ix)) {
    array[i++]=p;
    GroupDel(g,p);
  }

  groupQSort_locks++;
  while (groupQSort_locks>1);    /* Prevent problems with multithreading */

  groupQSort_proc=proc;
  groupQSort_userData=userData;
  qsort(array,n,sizeof(*array),GroupQSort_Compare);

  groupQSort_locks--;

  for (i=0;i<n;i++) GroupAdd(g,array[i]);

  Free(array);
}

void MergeGroup(Group dest,Group src) {
  void* p;
  Index ix;

  for (p=Group1st(src,&ix);p!=NULL;p=Next(&ix))
    GroupAdd(dest,p);
}

void MergeGroupOfGroups(Group dest,Group src) {
  Group g;
  void* p;
  Index ix,ixg;

  for (g=Group1st(src,&ixg);g!=NULL;g=Next(&ixg))
    for (p=Group1st(g,&ix);p!=NULL;p=Next(&ix))
      GroupAdd(dest,p);
}

void ClearGroup(Group g) {
   while (!IsEmptyGroup(g)) GroupDel(g,Group1st(g,NULL));
}

static Group _emptyStaticGroup=NULL;

static void atexit_FreeEmptyStaticGroup(void) {
  FreeGroup(_emptyStaticGroup);
}

Group GetEmptyStaticGroup(void) {
  if (_emptyStaticGroup==NULL) {
    _emptyStaticGroup=CreateGroup();
    atexit(atexit_FreeEmptyStaticGroup);
  }

  return _emptyStaticGroup;
}
