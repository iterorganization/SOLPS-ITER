      block data uiblb2
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
c
c  version : 14.08.2003 23:11
c
#ifdef DIMENSIONS_MODULE
      use b2mod_dimensions
#endif
      implicit none
#include "uib2pprm.inc"
      integer i
      common /uiblb2_local/ i
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
     ,  'nyiso2','niiso','teiso','tiiso',19*' '/
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
      end
