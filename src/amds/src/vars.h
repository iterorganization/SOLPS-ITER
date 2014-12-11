/* Variables */

typedef struct _Vars {
  size_t count,dataLen;
  char* data;
}* Vars;

Vars CreateVars();
void* FreeVars(Vars v);

void SetVar(Vars v,char* name,char* value);

#define GetVar(v,name) GetVar2((v),(name),"")
char* GetVar2(Vars v,char* name,char* defVal);

void CopyVars(Vars src,Vars dest);
