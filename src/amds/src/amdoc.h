/* Document implementation */

struct _Doc {
  Database db;
  Group views;
  Stack undoStack,redoStack;
  Group varDefs;
  int undoMode;

  struct {
    Reaction r;
    Group enabled;
    Vars reactionVars;
    Group particleVars;
  }* data;

  Group startupParticles;
  char* fileName;

  int reactionCount,alt;
};

#define ReactionActive(ss,r) \
  (!IsEmptyGroup((ss)->data[(r)->number].enabled))

#define NotifyAlt(ss) NotifyDoc(ss,N_ALT,NULL)

#define IsStartupParticle(d,p) InGroup((d)->startupParticles,(p))

Doc CreateDoc(Database db);
void* FreeDoc(Doc ss);
void NotifyDoc(Doc ss,int msg,void* obj);

void ClearDoc(Doc ss);
void ActivateReaction(Doc ss,Reaction r,Particle p,int bEnable);
void SetStartupParticle(Doc d,Particle p,int status);

void SetReactionVar(Doc ss,Reaction r,Particle p,char* name,char* value);
char* GetReactionVar(Doc ss,Reaction r,Particle p,char* name);

void CopyReaction(Doc src,Doc dest,Reaction r,int bVars);
void CopyDoc(Doc src,Doc dest);

Group GetActiveReactions(Doc d);

void SetDocFilename(Doc d,char* fName);
