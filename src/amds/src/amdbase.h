/* Reactions database implementatio */

struct _Particle {
  Database db;
  String name;
  int bIsAbstract;
  Group superClasses,subClasses;
};

struct _ReactionType {
  Database db;
  String name;
};

struct _Reaction {
  Database db;
  int number;
  String name;
  Group types,input,output,inputSet,outputSet;
  Vars vars; /* Defaults from the database */
};

struct _Database {
  Group particles,reactions,reactionTypes;
};

Database CreateDatabase(char* fName);

#define FRX_NOASSERT 0x0001

Particle FindParticle(Database db,String name);
Reaction FindReaction(Database db,String name);
Reaction FindReactionEx(Database db,String name,int flags);
ReactionType FindReactionType(Database db,String name);

int IsSubclassedParticle(Particle p,Particle superClass,int bDirect);
int ParticleInReaction(Particle p,Reaction r,int bInput,int bSubclass);

char* GetReactionDatabase(Reaction r);
char* GetReactionSection(Reaction r);
char* GetReactionNumber(Reaction r);

Group ValidateReactions(Group reactions,Group particles);
