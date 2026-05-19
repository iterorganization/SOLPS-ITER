      module uib2pprm
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      implicit none

      public

      integer, private :: i

#ifndef DIMENSIONS_MODULE
#include "DIMENSIONS.F"
#endif

c*** The numbers of input blocks and variables to work on in one block
      integer, parameter :: nblck=8, nkwrd=43, nnmdf=nblck*nkwrd

c*** The maximum length of the keyword
      integer, parameter :: mxkwln=22

c*** The maximum number of parameters, layers, and blocks for one keyword
c*** (2D array is considered a set of "layers", and 3D one a set of "blocks")
      integer, parameter :: nmxprm=DEF_NFL+DEF_NSTRA+DEF_NLIM+DEF_NSTS
      integer, parameter :: nmxlyr=DEF_NSTRA+5, nmxblk=2

c*** The maximum length of the input line
      integer, parameter :: mxslen=mxkwln+nmxprm*11

c*** The names of sections and variables to work on
      character chrbl(nblck)*(mxkwln),chrpl(nkwrd,nblck)*(mxkwln)

c*** The number of "blocks", "layers", and values for each variable
      integer nmdbr(nkwrd,nblck),nmdlr(nkwrd,nblck),nmdpr(nkwrd,nblck)

c*** The values of parameters
      integer iniprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)
      real rniprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)
      character cniprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)
      character*2 c2niprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)
      character*8 c8niprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)

c*** Logical variables:
c***  lbb     : the block is done
c***  lbv     : the variable is to be edited
c***  lbmdf   : the corresponding variable is done
c***  lbusr   : the "user" section is to be modified
c***  ltrvr   : the corresponding variable is text
c***  lt2rvr  : the corresponding variable is text*2
c***  lt8rvr  : the corresponding variable is text*8
c***  lrrvr   : the corresponding variable is real
c***  lspvr   : the corresponding variable is species-dependent
c***  lprdckw : produce the corresponding line

      logical lbb,lbv,lbusr,
     ,  lbmdf(nkwrd,nblck),ltrvr(nkwrd,nblck),
     ,  lt2rvr(nkwrd,nblck),lt8rvr(nkwrd,nblck),
     ,  lrrvr(nkwrd,nblck),lprdckw(nmxlyr,nmxblk,nkwrd,nblck),
     ,  lspvr(nkwrd,nblck)

c=======================================================================
c*** The list of keywords to work on:

      data chrbl /
     /  '&initialization','&boundary','&neutrals','&diagnostics','&cut',
     ,  '&impurities','&user','&neutrals_hybrid'/

      data (chrpl(i,1),i=1,nkwrd) / 'nx','ny','ns','zi','mi',38*' '/
      data (chrpl(i,2),i=1,nkwrd) /
     /  'nbc','bcchar','','bcstart','bcend',
     ,  'bcene','bceni','bcpot','enepar','enipar',
     ,  'potpar','bccon','conpar','bcmom','mompar',
     ,  'lcbs','nniso','nxiso1','nxiso2','nyiso1',
     ,  'nyiso2','niiso','teiso','tiiso','bcenk','enkpar',17*' '/
      data (chrpl(i,3),i=1,nkwrd) /
     /  'nstrai','crcstra','','rcstart','rcend',
     ,  'species_start','species_end','eb2spcr','eb2atcr','b2espcr',
     ,  'b2eatcr','lstrascl','lsns','msns','ksns',
     ,  'lcns','ltns','recyc','userfluxparm','gpfc',
     ,  'latmscl','lmolscl','lionscl','mlcmp','chemical_sputter_yield',
     ,  'n_spcsrf','l_spcsrf','sps_id','i_spcsrf','j_spcsrf',
     ,  'sps_absr','sps_trno','sps_trni','sps_mtri','sps_tmpr',
     ,  'sps_spph','sps_spch','sps_sgrp','targsp','surf_mat',
     ,  'accel_ion',2*' '/
      data (chrpl(i,4),i=1,nkwrd) / 'jxi','jxa',41*' '/
      data (chrpl(i,5),i=1,nkwrd) /
     /  'nncut','ntcut','nxcut1','nxcut2','nycut1',
     ,  'nycut2','nniso',' ','nxiso1','nxiso2',
     ,  'nyiso1','nyiso2','niiso','tiiso','teiso',28*' '/
      data (chrpl(i,6),i=1,nkwrd) / 'impflag','nspecies','nfluids',
     ,  40*' '/
      data (chrpl(i,7),i=1,nkwrd) /
     /  'fusion_power','Spmp_He_to_D','lhetrgts','lpfrb_i','lpfrb_o',
     ,  'lpfrt_i','lpfrt_o','j_h_at','j_he_at','j_ne_at',
     ,  'l_h_mol','lpfrs_pmp','npfrgrp','lpfrgrp','ipfrgrp',
     ,  'jpfrgrp','gpfrgrp','rzomp','rzimp',24*' '/
      data (chrpl(i,8),i=1,nkwrd) /
     /  'nstrai','crcstra',' ','rcstart','rcend',
     ,  'species_start','species_end','eb2spcr','eb2atcr','b2espcr',
     ,  'b2eatcr','lstrascl','lsns','msns','ksns',
     ,  'lcns','ltns','recyc','userfluxparm','gpfc',
     ,  'latmscl','lmolscl','lionscl','mlcmp','chemical_sputter_yield',
     ,  'n_spcsrf','l_spcsrf','sps_id','i_spcsrf','j_spcsrf',
     ,  'sps_absr','sps_trno','sps_trni','sps_mtri','sps_tmpr',
     ,  'sps_spph','sps_spch','sps_sgrp','targsp','surf_mat',
     ,  'accel_ion','b2recyc','strasclfl'/

c*** Initialisation of the control data
      data nmdpr, nmdlr, nmdbr / nnmdf*1, nnmdf*0, nnmdf*0 /
      data ltrvr,             lt2rvr,        lt8rvr        /
     ,  nnmdf*.false., nnmdf*.false., nnmdf*.false.        /
      data lrrvr,              lspvr    /
     ,  nnmdf*.false., nnmdf*.false.    /

      data lbmdf / nnmdf*.false. /
      data lbusr, lbb, lbv / 3*.false. /
c=======================================================================

      end module uib2pprm
