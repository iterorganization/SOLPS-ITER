      block data uiblb2
c
c  version : 14.08.2003 23:11
c
      implicit none
#include "uib2pprm.inc"
      integer i
      common /uiblb2_local/ i
c=======================================================================
c*** The list of keywords to work on:

      data chrbl /
     /  '&initialization','&boundary','&neutrals','&diagnostics','&cut',
     ,  '&impurities','&user'/

      data (chrpl(i,1),i=1,nkwrd) / 'nx','ny','ns','zi','mi',33*' '/
      data (chrpl(i,2),i=1,nkwrd) /
     /  'nbc','bcchar','bcpos','bcstart','bcend',
     ,  'bcene','bceni','bcpot','enepar','enipar',
     ,  'potpar','bccon','conpar','bcmom','mompar',
     ,  'lcbs','nniso','nxiso1','nxiso2','nyiso1',
     ,  'nyiso2','niiso','teiso','tiiso',14*' '/
      data (chrpl(i,3),i=1,nkwrd) /
     /  'nstrai','crcstra','rcpos','rcstart','rcend',
     ,  'species_start','species_end','eb2spcr','eb2atcr','b2espcr',
     ,  'b2eatcr','lstrascl','lsns','msns','ksns',
     ,  'lcns','ltns','recyc','userfluxparm','gpfc',
     ,  'latmscl','lmolscl','lionscl','mlcmp','chemical_sputter_yield',
     ,  'n_spcsrf','l_spcsrf','sps_id','i_spcsrf','j_spcsrf',
     ,  'sps_absr','sps_trno','sps_trni','sps_mtri','sps_tmpr',
     ,  'sps_spph','sps_spch','sps_sgrp'/
      data (chrpl(i,4),i=1,nkwrd) / 'jxi','jxa',36*' '/
      data (chrpl(i,5),i=1,nkwrd) /
     /  'nncut','ntcut','nxcut1','nxcut2','nycut1',
     ,  'nycut2','nniso','ntiso','nxiso1','nxiso2',
     ,  'nyiso1','nyiso2','niiso','tiiso','teiso',23*' '/
      data (chrpl(i,6),i=1,nkwrd) / 'impflag','nspecies','nfluids',
     ,  35*' '/
      data (chrpl(i,7),i=1,nkwrd) / 
     /  'fusion_power','Spmp_He_to_D','lhetrgts','lpfrb_i','lpfrb_o',
     ,  'lpfrt_i','lpfrt_o','j_h_at','j_he_at','j_ne_at',
     ,  'l_h_mol','lpfrs_pmp','npfrgrp','lpfrgrp','ipfrgrp',
     ,  'jpfrgrp','gpfrgrp',21*' '/

c*** Initialisation of the control data
      data nmdpr, nmdlr, nmdbr / nnmdf*1, nnmdf*0, nnmdf*0 /
      data ltrvr,       lt8rvr,           lrrvr,        lspvr      /
     ,  nnmdf*.false., nnmdf*.false., nnmdf*.false., nnmdf*.false. /

      data lbmdf / nnmdf*.false. /
      data lbusr, lbb, lbv / 3*.false. /
c=======================================================================
      end
