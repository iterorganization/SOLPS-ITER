#include <string.h>
#include <stdlib.h>
#include "vars.h"

Vars CreateVars() {
  Vars v;

  #ifdef __APPLE__
    v=malloc(sizeof(*v));
  #else
    v=Malloc(sizeof(*v));
  #endif
  v->count=v->dataLen=0;
  v->data=NULL;

  return v;
}

void* FreeVars(Vars v) {
  #ifdef __APPLE__
    if (v->data!=NULL) free(v->data);
    free(v);
  #else
    if (v->data!=NULL) Free(v->data);
    Free(v);
  #endif

  return NULL;
}

void SetVar(Vars v,char* name,char* value) {
  size_t p,oldLen,newLen;

for (p=0;p<v->dataLen;) {
//  printf("%s:",v->data+p);
  p+=strlen(v->data+p)+1;
}
//printf("\n");
//printf("%d %d | %x %s <- %s\n",p,v->dataLen,v,name,value);

  if (value==NULL) value="";

  for (p=0;p<v->dataLen;) {
    if (!strcmp(v->data+p,name)) {
      p+=strlen(v->data+p)+1;
      goto found;
    }
    p+=strlen(v->data+p)+1;
    p+=strlen(v->data+p)+1;
  }
  #ifdef __APPLE__
    v->data=realloc(v->data,v->dataLen+=strlen(name)+strlen(value)+2);
  #else
    v->data=Realloc(v->data,v->dataLen+=strlen(name)+strlen(value)+2);
  #endif
  strcpy(v->data+p,name);
  strcpy(v->data+p+strlen(name)+1,value);

  return;

//  puts("B");
  found:
//  printf("found %d %d %s\n",oldLen,newLen,v->data+p);
  oldLen=strlen(v->data+p);
//  printf("found1 %d %d %s\n",oldLen,newLen,v->data+p);
  newLen=strlen(value);
//  printf("found2 %d %d %s\n",oldLen,newLen,v->data+p);

  #ifdef __APPLE__
    if (newLen>oldLen) v->data=realloc(v->data,v->dataLen+=newLen-oldLen);
  #else
    if (newLen>oldLen) v->data=Realloc(v->data,v->dataLen+=newLen-oldLen);
  #endif
//  printf("found3 %d %d %s\n",oldLen,newLen,v->data+p);

  memmove(v->data+p+newLen+1,v->data+p+oldLen+1,
    v->dataLen-p-oldLen-1);
  strcpy(v->data+p,value);

  #ifdef __APPLE__
    if (newLen<oldLen) v->data=realloc(v->data,v->dataLen+=newLen-oldLen);
  #else
    if (newLen<oldLen) v->data=Realloc(v->data,v->dataLen+=newLen-oldLen);
  #endif
//  puts("B");
}

char* GetVar2(Vars v,char* name,char* defVal) {
  size_t p;

  for (p=0;p<v->dataLen;) {
    if (!strcmp(v->data+p,name)) return v->data+p+strlen(name)+1;
    p+=strlen(v->data+p)+1;
    p+=strlen(v->data+p)+1;
  }
  return defVal;
}

void CopyVars(Vars src,Vars dest) {
  #ifdef __APPLE__
    free(dest->data);
  #else
    Free(dest->data);
  #endif
  dest->count=src->count;
  dest->dataLen=src->dataLen;
  #ifdef __APPLE__
    dest->data=malloc(dest->dataLen);
  #else
    dest->data=Malloc(dest->dataLen);
  #endif
  memmove(dest->data,src->data,dest->dataLen);
}
