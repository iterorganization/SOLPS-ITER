#include "amds.h"

Database CreateDatabase(char* fName) {
  Database db;
  FILE* f=fopen(fName,"r");
  char s[1000],s1[1000],*ps,*ps1;
  Reaction r;
  Particle p,p1;
  ReactionType rt;
  Index ix;
  int i,j;

  if (f==NULL) {
    perror("Error opening reaction database");
    assert(0);
  }

  db=Malloc(sizeof(*db));

  db->particles=CreateGroup();
  db->reactionTypes=CreateGroup();
  db->reactions=CreateGroup();

  while (fgets(s,sizeof(s)-1,f)!=NULL) {
    if (*s && s[strlen(s)-1]=='\n') s[strlen(s)-1]=0;

    if ((!strcasecmp(StrWord(s,1),"Particle") || !strcasecmp(StrWord(s,1),
	"ParticleClass")) && *StrWord(s,2)) {
      p=Malloc(sizeof(*p));
      p->db=db;
      p->name=MallocString(StrWord(s,2));
      p->superClasses=CreateGroup();
      p->subClasses=CreateGroup();
      p->bIsAbstract=!strcasecmp(StrWord(s,1),"ParticleClass");

      if (!strcmp(StrWord(s,3),":")) {
	for (i=4;*StrWord(s,i);i++) {
	  GroupAdd(p->superClasses,p1=FindParticle(db,StrWord(s,i)));
	  GroupAdd(p1->subClasses,p);
	}
      } else
      if (*StrWord(s,3)) {
	fprintf(stderr,"amds: Invalid statement: %s\n",s);
	assert(0);
      }
      GroupAdd(db->particles,p);
    } else

    if (!strcasecmp(StrWord(s,1),"ReactionType")) {
      rt=Malloc(sizeof(*rt));
      rt->db=db;
      rt->name=MallocString(StrWord(s,2));

      GroupAdd(db->reactionTypes,rt);
    } else

    if (!strcasecmp(StrWord(s,1),"Reaction")) {
      if (strcmp(StrWord(s,5),":")) {
	fprintf(stderr,"amds: Bad statement: %s\n",s);
	assert(0);
      }

      r=Malloc(sizeof(*r));
      r->db=db;
      r->number=GroupCount(db->reactions);
      r->name=Malloc(strlen(StrWord(s,2))+strlen(StrWord(s,3))+
	  strlen(StrWord(s,4))+3);
      sprintf(r->name,"%s_%s_%s",StrWord(s,2),StrWord(s,3),StrWord(s,4));

      r->types=CreateGroup();
      r->input=CreateGroup();
      r->output=CreateGroup();
      r->inputSet=CreateGroup();
      r->outputSet=CreateGroup();

      for (i=6;*(ps=StrWord(s,i));i++) {
	if (!strcmp(StrWord(s,i),":")) {i++;break;}
/*        if (!strcmp(StrWord(s,i),"+")) continue;
	if (!strcmp(StrWord(s,i),"->")) {i++;break;}
	if (!strcmp(StrWord(s,i),"T")) {i++;break;} */

	j=strtol(ps,&ps1,10);
	if (ps1==ps) j=1;

	while (j-->0) GroupAdd(r->input,FindParticle(db,ps1));
      }

      for (;*(ps=StrWord(s,i));i++) {
	if (!strcmp(StrWord(s,i),":")) {i++;break;}
	if (!strcmp(StrWord(s,i),"+")) continue;

	j=strtol(ps,&ps1,10);
	if (ps1==ps) j=1;

	while (j-->0) GroupAdd(r->output,FindParticle(db,ps1));
      }

      for (;*StrWord(s,i);i++) {
	if (!strcmp(StrWord(s,i),":")) {i++;break;}
	GroupAdd(r->types,FindReactionType(db,StrWord(s,i)));
      }
      
      /* Read database variables for the reaction */
      
      r->vars=CreateVars();
      
      if (*StrWord(s,i)) i--;
      for (;*StrWord(s,i);i+=2) {
        if (strcmp(StrWord(s,i),":") || !*StrWord(s,i+1)) {
          FatalError("Bad database entry (variables): %s %d\n",s,i);
          break;
        }
        
        strcpy(s1,StrWord(s,i+1));
        ps=strchr(s1,'=');
        if (ps==NULL) {
          FatalError("Bad database entry (variable %s): %s\n",s1,s);
          break;
        }
        
        *ps=0;
        
/*printf("|%s|=|%s|\n",s1,ps+1); $ */
        SetVar(r->vars,s1,ps+1);
      }
          
      /* Fill in input, output sets */

      for (p=Group1st(r->input,&ix);p!=NULL;p=Next(&ix))
	if (!InGroup(r->inputSet,p)) GroupAdd(r->inputSet,p);

      for (p=Group1st(r->output,&ix);p!=NULL;p=Next(&ix))
	if (!InGroup(r->outputSet,p)) GroupAdd(r->outputSet,p);

      GroupAdd(db->reactions,r);
    }
    /* else {
      fprintf(stderr,"amds: Bad statement: %s\n",s);
      assert(0);
    } */
  }
  fclose(f);

  return db;
}

Particle FindParticle(Database db,String name) {
  Particle p;
  Index ix;

  for (p=Group1st(db->particles,&ix);p!=NULL;p=Next(&ix))
      if (!strcmp(p->name,name)) {
/*    if (p->bIsAbstract) {
      fprintf(stderr,"amds: Abstract particle class used in a reaction: %s",
	  name);
      assert(0);
    }
*/    return p;
  }

  fprintf(stderr,"FindParticle: unable to find <%s>\n",name);
  assert(0);

  return NULL;
}

Reaction FindReaction(Database db,String name) {
  Reaction r;
  Index ix;

  for (r=Group1st(db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (!strcmp(r->name,name)) return r;

  fprintf(stderr,"FindReaction: unable to find <%s>\n",name);
  assert(0);

  return NULL;
}

Reaction FindReactionEx(Database db,String name,int flags) {
  Reaction r;
  Index ix;

  for (r=Group1st(db->reactions,&ix);r!=NULL;r=Next(&ix))
    if (!strcmp(r->name,name)) return r;

  if (flags & FRX_NOASSERT) return NULL;
  
  fprintf(stderr,"FindReactionEx: unable to find <%s>\n",name);
  assert(0);

  return NULL;
}

ReactionType FindReactionType(Database db,String name) {
  ReactionType rt;
  Index ix;

  for (rt=Group1st(db->reactionTypes,&ix);rt!=NULL;rt=Next(&ix))
    if (!strcmp(rt->name,name)) return rt;

  fprintf(stderr,"FindReactionType: unable to find <%s>\n",name);
  assert(0);

  return NULL;
}

int IsSubclassedParticle(Particle p,Particle superClass,int bDirect) {
  Particle pi;
  Index ix;

  assert(p!=NULL);

  if (bDirect) {
    if (superClass==NULL) return IsEmptyGroup(p->superClasses);
    else {
      for (pi=Group1st(p->superClasses,&ix);pi!=NULL;pi=Next(&ix))
	if (pi==superClass) return 1;
      return 0;
    }
  } else {
    if (p==superClass) return 1;
    for (pi=Group1st(p->superClasses,&ix);pi!=NULL;pi=Next(&ix))
      if (IsSubclassedParticle(pi,superClass,False)) return 1;

    return 0;
  }
}

int ParticleInReaction(Particle p,Reaction r,int bInput,int bSubclass) {
  Particle pi;
  Index ix;

  if (bSubclass) {
    for (pi=Group1st(bInput? r->input:r->output,&ix);pi!=NULL;pi=Next(&ix))
      if (IsSubclassedParticle(pi,p,False)) return 1;
    return 0;
  } else return InGroup(bInput? r->input:r->output,p);
}

char* GetReactionDatabase(Reaction r) {
  static char s[1024];

  strcpy(s,r->name);

  return strtok(s,"_");
}

char* GetReactionSection(Reaction r) {
  static char s[1024];

  strcpy(s,r->name);

  strtok(s,"_");
  return strtok(NULL,"_");
}

char* GetReactionNumber(Reaction r) {
  static char s[1024];

  strcpy(s,r->name);

  strtok(s,"_");
  strtok(NULL,"_");
  return strtok(NULL,"_");
}

Group ValidateReactions(Group reactions,Group particles) {
  Group nR,nP,pP;
  Particle p;
  Reaction r;
  Index ixp,ixr,ixp2;

  nR=CopyGroup(reactions,NULL);
  pP=CopyGroup(particles,NULL);

/* Construct NeededParticles */

  nP=CreateGroup();

  for (r=Group1st(nR,&ixr);r!=NULL;r=Next(&ixr))
    for (p=Group1st(r->inputSet,&ixp);p!=NULL;p=Next(&ixp))
      if (!InGroup(pP,p) && !InGroup(nP,p)) GroupAdd(nP,p);

  for (p=Group1st(nP,&ixp);p!=NULL;p=Next(&ixp)) {
    for (r=Group1st(nR,&ixr);r!=NULL;r=Next(&ixr)) {
      if (InGroup(r->outputSet,p) && !InGroup(r->inputSet,p)) {
	GroupDel(nP,p);
	break;
      }
    }
  }

  FreeGroup(nR);
  FreeGroup(pP);

  return nP;
}

static Group ValidateReactions_NoLoops(Group reactions,Group particles) {
  Group nR,nP,pP;
  Particle p;
  Reaction r;
  Index ixp,ixr;

  nR=CopyGroup(reactions,NULL);
  pP=CopyGroup(particles,NULL);

/* Construct NeededParticles */

  nP=CreateGroup();
  for (r=Group1st(nR,&ixr);r!=NULL;r=Next(&ixr))
    for (p=Group1st(r->inputSet,&ixp);p!=NULL;p=Next(&ixp))
      if (!InGroup(pP,p) && !InGroup(nP,p)) GroupAdd(nP,p);

  while (1) {
    for (r=Group1st(nR,&ixr);r!=NULL;r=Next(&ixr)) {
      for (p=Group1st(r->inputSet,&ixp);p!=NULL;p=Next(&ixp))
	if (!InGroup(pP,p)) break;
      if (p==NULL) break;
    }
    if (r==NULL) break;

    for (p=Group1st(r->outputSet,&ixp);p!=NULL;p=Next(&ixp))
      if (InGroup(nP,p)) {
	GroupDel(nP,p);
	GroupAdd(pP,p);
      }

    GroupDel(nR,r);
  }

  FreeGroup(nR);
  FreeGroup(pP);

  return nP;
}
