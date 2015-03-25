#include "amds.h"

#define xstrwordBUFFERS 10
char* StrWord(char* s,int n) {
  static char buf[xstrwordBUFFERS][1024];
  static int bufn=0;
  int i;

  while (isspace(*s)) s++;
  while (--n) {
    while (*s && !isspace(*s)) switch(*s++) {
      case '\\':
	if (*s) s++;break;
      case '\"':
	while (*s && *s!='\"') if (*s++=='\\') if (*s) s++;
	if (*s) s++;
	break;
      default:
	break;
    }
    while (isspace(*s)) s++;
  }
  if (*s!='\"') for (i=0;s[i] && !isspace(s[i]);i++) buf[bufn][i]=s[i]; else
    for (s++,i=0;s[i] && s[i]!='\"';) {
      if (s[i]=='\\') s++;
      if (s[i]) {buf[bufn][i]=s[i];i++;}
    }
  buf[bufn][i]=0;
  s=buf[bufn];
  bufn=(bufn+1)%xstrwordBUFFERS;

  return s;
}

char* GetShortFName(char* fName) {
  int i;

  for (i=strlen(fName)-1;i>=0;i--)
    if (fName[i]=='/' || fName[i]=='\\' || fName[i]==':') return fName+i+1;
  return fName;
}

char* GetFileExt(char* fName) {
  int i;

  fName=GetShortFName(fName);

  for (i=strlen(fName)-1;i>=0;i--)
    if (fName[i]=='.') return fName+i;

  return fName+strlen(fName);
}

char* GetFilePath(char* fName) {
  *GetShortFName(fName)=0;

  return fName;
}


