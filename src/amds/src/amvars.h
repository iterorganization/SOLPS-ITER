/* Variables & definitions for amds */

struct _VarDef {
  Vars v;
  int type,flags;
};

#define GetReactionVar(ss,r,vd) GetParticleVar(ss,r,NULL,vd)
#define SetReactionVar(ss,r,vd,val) SetParticleVar(ss,r,NULL,vd,val)

VarDef AddVarDef(Doc ss,char* name);
int ChangeVarDef(Doc ss,VarDef vd,int type,int flags);
int SetVarDefStr(Doc ss,VarDef vd,char* var,char* newVal);
void* DelVarDef(Doc ss,VarDef vd);

char* GetParticleVar(Doc ss,Reaction r,Particle p,VarDef vd);
void SetParticleVar(Doc ss,Reaction r,Particle p,VarDef vd,char* val);

VarDef FindVarDef(Doc ss,char* name);
void UpdateVarDefs(Doc ss,Doc cfg);

#define VDT_STRING      1
#define VDT_INT         2
#define VDT_FLOAT       3

#define VDF_REACTIONS   0x0001
#define VDF_PARTICLES   0x0002
#define VDF_NOEXPORT    0x0004
#define VDFM_APPLY      (VDF_REACTIONS|VDF_PARTICLES)

#define VDS_NAME        "VDS_NAME"
#define VDS_DESCR       "VDS_DESCR"
#define VDS_HELP        "VDS_HELP"
#define VDS_MENU        "VDS_MENU"

#define GetVarDefName(vd)  GetVar(vd->v,VDS_NAME)
#define GetVarDefDescr(vd) GetVar(vd->v,VDS_DESCR)
#define GetVarDefHelp(vd)  GetVar(vd->v,VDS_HELP)
#define GetVarDefMenu(vd)  GetVar(vd->v,VDS_MENU)

#define SetVarDefName(ss,vd,s)  SetVarDefStr(ss,vd,VDS_NAME,s)
#define SetVarDefDescr(ss,vd,s) SetVarDefStr(ss,vd,VDS_DESCR,s)
#define SetVarDefHelp(ss,vd,s)  SetVarDefStr(ss,vd,VDS_HELP,s)
#define SetVarDefMenu(ss,vd,s)  SetVarDefStr(ss,vd,VDS_MENU,s)
