#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define xstrwordBUFFERS 10
static char* word(char* s,int n) {
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

void Filter1(char* file) {
  char header[2048]="<noHeader>",s0[2048],s[2048],s1[2048],s2[2048];
  char* w;
  int i;

  while (gets(s)!=NULL) if (!strncmp(s,"##BEGIN DATA HERE##",19)) break;

  while (gets(s)!=NULL) {
    if (!strncmp(word(s,1),"H.",2)) strcpy(header,word(s,1)); else
    if (!strcmp(word(s,1),"Reaction")) {
      sprintf(s0,"%s_%s_%s",file,header,word(s,2));
      printf("DefineReaction %s <noType> ",s0);

      if (*word(s,3)) {
	for (i=3;*(w=word(s,i));i++)
 /*         if (!strcmp(w,"T") || !strcmp(w,"->")) printf(" ->"); else
	  if (strcmp(w,"+")) printf(" %s",w); */
	printf(" %s",w);
      } else {
	while (gets(s1)!=NULL) if (*word(s1,1)) break;
	gets(s);
	gets(s2);

	if (strstr(s1," T ")!=NULL) {
	  strcpy(s2,s);
	  strcpy(s,s1);
	} else if (strstr(s," T ")==NULL) {
	  fprintf(stderr,"Bad reaction %s:\n%s\n%s\n%s\n",s0,s1,s,s2);
	  printf("<Bad>\n");
	  continue;
	}

	for (i=0;s[i];i++) {
	  if (!isspace(s[i]) ||
	      (i>=strlen(s2) || isspace(s2[i])) &&
	      (i>=strlen(s1) || isspace(s1[i])))
	    putchar(s[i]);
	  if (i<strlen(s2) && !isspace(s2[i])) putchar(s2[i]);
	  if (i<strlen(s1) && !isspace(s1[i])) putchar(s1[i]);
	}
	for (i=0;i<4;i++) {
	  gets(s);
	  if (strstr(s," T ")!=NULL) {
	    fprintf(stderr,"Unfinished reaction %s :\n%s\n",s0,s);
	    printf("<Bad>\n");
	    continue;
	  }
	}
      }
      printf("\n");
    }
  }
}

main(int argc,char** argv) {
  Filter1(argv[1]);
}
