c  version : 27.07.2000 22:52
     .	dab2(0:ndxp,0:ndyp,natm,1),    dmb2(0:ndxp,0:ndyp,nmol,1),
     .	dib2(0:ndxp,0:ndyp,nion,1),    tab2(0:ndxp,0:ndyp,natm,1),
     .	tmb2(0:ndxp,0:ndyp,nmol,1),    tib2(0:ndxp,0:ndyp,nion,1),
     .	rfluxa(0:ndxp,0:ndyp,natm,1),  rfluxm(0:ndxp,0:ndyp,nmol,1),
     .	refluxa(0:ndxp,0:ndyp,natm,1), refluxm(0:ndxp,0:ndyp,nmol,1),
     .	pfluxa(0:ndxp,0:ndyp,natm,1),  pfluxm(0:ndxp,0:ndyp,nmol,1),
     .	pefluxa(0:ndxp,0:ndyp,natm,1), pefluxm(0:ndxp,0:ndyp,nmol,1),
     .	emiss(0:ndxp,0:ndyp,1,1),      emissmol(0:ndxp,0:ndyp,1,1),
     .	srcml(0:ndxp,0:ndyp,nmol,1),   edissml(0:ndxp,0:ndyp,nmol,1),
     .	wldnek(nlmpgs,0:nstra),        wldnep(nlmpgs,0:nstra),
     .	wldna(nlmpgs,natm,0:nstra),    ewlda(nlmpgs,natm,0:nstra),
     .	wldnm(nlmpgs,nmol,0:nstra),    ewldm(nlmpgs,nmol,0:nstra),
     .	wldra(nlmpgs,natm,0:nstra),    wldrm(nlmpgs,nmol,0:nstra),
     .	wldpp(nlmpgs,npls,0:nstra),    wldpa(nlmpgs,natm,0:nstra),
     .	wldpm(nlmpgs,nmol,0:nstra),    wldpeb(nlmpgs,0:nstra),
     .	wldspt(nlmpgs,0:nstra)
      integer nnlimi,nnstsi,nnatmi,nnmoli,nnioni,nnplsi,isrftype(nlmpgs)
      logical lhalpha,lvib
c
      common /eirdiag/ dab2,dmb2,dib2,tab2,tmb2,tib2,
     1 rfluxa,rfluxm,refluxa,refluxm,
     2 pfluxa,pfluxm,pefluxa,pefluxm,
     3 emiss,emissmol,
     4 srcml,edissml,wldnek,wldnep,wldna,ewlda,wldnm,ewldm,wldra,wldrm,
     5 wldpp,wldpa,wldpm,wldpeb,wldspt,
     i nnlimi,nnstsi,nnatmi,nnmoli,nnioni,nnplsi,isrftype,
     l lhalpha,lvib
c
#ifndef NO_SAVE
      save /eirdiag/
#endif
c
c*** Volume data:
c***	srcml	:   power loss due to molecules, including
c***	edissml :   power loss due to molecule dissociation
c*** Surface data:
c***	wldnek	:   heat transferred with neutrals
c***	wldnep	:   potential energy released by neutrals
c***	wldna	:   flux of atoms impinging onto the surface
c***	ewlda	:   their average energy
c***	wldnm	:   flux of molecules impinging onto the surface
c***	ewldm	:   their average energy
c***	wldra	:   flux of reflected atoms
c***	wldrm	:   flux of reflected molecules
c***	wldpp	:   flux of plasma ions impinging onto the surface
c***	wldpa	:   flux of resulting atoms
c***	wldpm	:   flux of resulting molecules
c***	wldpeb	:   power carried away by these atoms and molecules
c***	wldspt	:   flux of sputtered wall material
c***	isrftype:   surface type (iliin in Eirene)
