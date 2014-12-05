c  version : 19.02.97 20:49
c
C     EIRENE TO BRAAMS COMMON
c
      COMMON /EIRBRA/
     /    SNI(0:NDXP,0:NDYP,NFL,NSTRA), SMO(0:NDXP,0:NDYP,NFL,NSTRA),
     ,    SEE(0:NDXP,0:NDYP,NSTRA),     SEI(0:NDXP,0:NDYP,NSTRA),
c-dpc     ,    DSNIDNI(0:NDXP,0:NDYP,NFL,NSTRA),
c-dpc     ,    DSMODUP(0:NDXP,0:NDYP,NFL,NSTRA),
c-dpc     ,    DSEEDTE(0:NDXP,0:NDYP,NSTRA), DSEIDTE(0:NDXP,0:NDYP,NSTRA),
c-dpc     ,    DSEEDTI(0:NDXP,0:NDYP,NSTRA), DSEIDTI(0:NDXP,0:NDYP,NSTRA),
     ,    FLUXH(10,NSTRA),  srcstrn(nstra),
     ,    VOLSUMN(nstra), VOLSUMM(nstra),
     ,    VOLSUMEI(nstra), VOLSUMEE(nstra),
     ,    flxspci(npls,nstra),srccrfc(natm,nstra)
c
c*** fluxh  : not used
c*** volsumn: plasma particle source due to volumetric recombination
c*** volsum[m,ee,ei]: the same for momentum and energy
c*** srcstrn: intensities of different neutral sources (fluxt)
c*** flxspci: fluxes of plasma ions to the recycling surfaces
c*** srccrfc: source correction factors (from infcop)
C
#ifndef NO_SAVE
      save /EIRBRA/                      ! dpc
#endif
