c  version : 19.02.97 21:51
c
C  PLASMA DATA: NI,TE,TI,PO,VV,UU,PR,UP,RR,FNIX,FNIY (BRAAMS ---> EIRENE)
c
#define CELL_CENTRED
      COMMON /BRAEIR/
     R  DNIB(0:NDXP,0:NDYP,NFL),TEB(0:NDXP,0:NDYP),
     R  TIB(0:NDXP,0:NDYP),POB(0:NDXP,0:NDYP),
     R  VVB(0:NDXP,0:NDYP,NFL),UUB(0:NDXP,0:NDYP,NFL),
     R  PRB(0:NDXP,0:NDYP),
     R  UPB(0:NDXP,0:NDYP,NFL),RRB(0:NDXP,0:NDYP),
     R  FNIXB(0:NDXP,0:NDYP,NFL),FNIYB(0:NDXP,0:NDYP,NFL),
     R  FEIXB(0:NDXP,0:NDYP),FEIYB(0:NDXP,0:NDYP),
     R  FEEXB(0:NDXP,0:NDYP),FEEYB(0:NDXP,0:NDYP),
     R  UUDIAB(0:NDXP,0:NDYP,NFL),VVDIAB(0:NDXP,0:NDYP,NFL),
     R  VOLB(0:NDXP,0:NDYP),BFELDB(0:NDXP,0:NDYP)
#ifndef NO_B2_CHEM_SPUT
c
c*** Data for chemical sputtering input from B2 - for compatibility!
c
      common /chemical_sputter_data/ chemical_sputter_yield(0:NLIMPS),
     1 fchar_chemical,igass_chemical,itsput_chemical,issput_chemical
#endif
#ifndef NO_SAVE
      save /BRAEIR/                      ! dpc
#endif
