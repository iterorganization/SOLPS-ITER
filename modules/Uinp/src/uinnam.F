      subroutine uinnam(unn)
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.04.2005 01:23
c
c=======================================================================
c*** Data input from the DG file
c=======================================================================
      character*8 unn
#include "uinput.inc"
#include "impcon.inc"
      integer lunm,i,j,l,lusgm,luswch,luskel,lugpf,lupfr,luvsp
      parameter (lunm=163)
      character*8 unm(lunm),uun,ubs*1,uam*52
c...  	      	      	      	      	      	      52=48+4
      integer luwrk(nlim),luind(nlim),lurefls
      logical hlp_spc,hlp_imm
c*** lusgm: segment number for the list of invisibles;
c*** luswch: switch for the input of element lists (obsolete)
c***          	    1: jedgi1, 2: jedgo1, 3: jedgi2, 4: jedgo2
c***         or switch for the target data (clockwise from bottom left)
c*** luskel: counter for the segments to be skipped
c*** lugpf:  counter for the puffing sources
c*** lugwt:  counter for the grid-wall ties
cvk  lpol: counter for the closed polygon number (for Triang)
cvk  lnpol: counter for the 'negative' closed polygon number (for Triang)
      data lusgm, luswch, luskel, lugpf, lugwt, luvsp /6*0/
      data lpol,lnpol /2*0/ 
      data hlp_spc / .true. /
      data lurefls / 0 /  
      data unm /
     1    'p1'      ,'p2'      ,'misselem','srfinvsb','jliin'   ,
     2    'jlside'  ,'jadksw'  ,'jadjsw'  ,'jlcol   ','jlacll  ',
     3    'material','ewall   ','absorptn','trnsprnf','trnsprnb',
     4    'segment ','userdata','jedgi1  ','jedgo1  ','jedgi2  ',
     5    'jedgo2  ','elemlist','jlref   ','main    ','sources ',
     6    'sprtrs  ','vessel  ','b2plot  ','jlsptp  ','jlsptc'  ,
     7    'jsrss   ','jsrsg   ','rcycsa  ','rcycca  ','skipelem',
     8    'edgetrg ','edge_sol','edge_pfr','trg_spcf','sol_edge',
     9	  'pfr_edge','made_of ','tgabsrp ','tgewall ','tgtrnsf ',
     a	  'tgtrnsb ','tgspcsw ','tgspcgr ','tgspcff ','tgsppsw ',
     1	  'tgsppsp ','tgsppff ','tgrefsw ','divides ','species ',
     2	  'spcs_gen','gas_puff','gpf_slot','gpf_cell','gpf_spcs',
     3	  'gpf_flux','gpf_temp','gpf_angl','gpf_angp','gpf_nhst',
     4	  'gpf_nini','jxi'     ,'jxa'     ,'laddsrfs','rmajor'	,
     5	  'nlscl'   ,'ntime'   ,'nfile'   ,'lfrm15'  ,'nprnli' 	,
     6	  'dtimv'   ,'xlpcntr' ,'do_hepdt','locphep' ,'pwrhepdt',
     7	  'pmphepdt','lstclhep','lhetrgts','tgnhst'  ,'tgnini'	,
     8	  'amd_file','ref_amds','chem_spt','chs_prj' ,'chs_yld' ,
     9	  'chs_prd' ,'chs_tgc' ,'chs_enr' ,'chs_prc' ,'sps_srfs',
     b    'sps_absr','sps_trno','sps_trni','sps_mtrl','sps_tmpr',
     1    'sps_spph','sps_spch','sps_sgrp','sps_list','sps_id  ',
     2    'pfr_nflx','surfc_id','surfc_ll','lm_cnfg ','lm_vhst ',
     3	  'lm_whst ','roator  ','nttrator','side_spc','ref_wall',
     4    'edgemark','trgtmark','nmcsptu ','emnspc  ','emxspc  ',
     5    'npspcen ','npspctt ','npspcfi ','listmtmp','ersmtaux',
     6    'dgntime ','dgnptsfc','listaddi','gwties  ','grdtie  ',
     7    'wlltie  ','vsp_inp ','run_rglr','run_test','run_diag',
     8    'c_xmlim ','c_isrsg ','c_ilspt ','c_ilref ','c_recycc',
     9    'c_recycs','c_iliin ','c_ilside','c_absrp ','c_trnspo',
     c    'c_trnspi','c_ewall ','trimark' ,'trisize' ,'trirect' ,
     1    'triref'  ,'trirflis','glb2dat ','glb_pwri','glb_pwre',
     2    'glb_pwrf','glb_tmst','spcs_crk','spcs_crp','spcs_crf',
     3    'spcs_scn','tgminhst','gpf_mhst'/
c=======================================================================

c*** Backslash:
      ubs=char(93)

      call locase(unn,uun,8)
      do i=1,lunm !{
        if(uun.eq.unm(i)) then !{
          go to (1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,
     ,          16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,
     ,          31,32,33,34, 3,36,37,38,39,40,41,42,43,44,45,
     ,	      	46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
     ,	      	61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,
     ,	      	76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,
     ,	      	91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,
     ,   106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
     ,   121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,
     ,   147,147,147,147,147,147,147,147,147,147,147,147,148,149,150,
     ,   151,152,153,154,155,156,157,158,159,160,161,162,163),i
#ifdef FLUSH
            call FLUSH(6)
#endif
          write(0,*) 'Switch overflow in uinnam - check the go to(',
     ,                                    'label list) construct there'
          stop
        end if !}
      end do !}
      call skipit
      return
c=======================================================================
    1 call rearre(p1,3*nlim,i)
      call vscale(p1,0.1,p1,i)
      nlimi=i/3
      return
    2 call rearre(p2,3*nlim,i)
      call vscale(p2,0.1,p2,i)
      nlimi=i/3
      return
    3 call vsend(jadch0,luwrk,luskel)
      call rearri(luwrk(luskel+1),nlim-luskel,i)
      luskel=i+luskel
      call sortia(luwrk,luind,luskel)
      call rshffl(luwrk,luind,jadch0,luskel)
      if(luskel.lt.nlim) jadch0(luskel+1)=0
      return
    4 call rearri(luwrk,nlim,i)
      if(lusgm.le.0) then
        print *,'*** Segment undefined, so the data are skipped ***'
        return
      end if
      call sortia(luwrk,luind,i)
      call rshffl(luwrk,luind,jadch1(1,lusgm),i)
      if(i.lt.nlim) jadch1(i+1,lusgm)=0
      return
    5 call rearri(jliin,nlim,i)
      nlimi=i
      return
    6 call rearri(jlside,nlim,i)
      nlimi=i
      return
    7 call rearri(jadksw,nlim,i)
      nlimi=i
      return
    8 call rearri(jadjsw,nlim,i)
      nlimi=i
      return
    9 call rearri(jlcol,nlim,i)
      nlimi=i
      return
   10 call rearri(jlacll,nlim,i)
      nlimi=i
      return
   11 call rearra(umtrl,nlim,i)
      nlimi=i
      i=0
      call uinmtr(umtrl,i,nlimi)
      return
   12 call rearre(ewala,nlim,i)
      nlimi=i
      return
   13 call rearre(rcycta,nlim,i)
      call vscale(rcycta,-1.,rcycta,i)
      call vbias(rcycta,1.,rcycta,i)
      nlimi=i
      return
   14 call rearre(trnspa(1,1),nlim,i)
      nlimi=i
      return
   15 call rearre(trnspa(1,2),nlim,i)
      nlimi=i
      return
   16 call resimi(lusgm)
      return
   17 call resima(luwrk)
      return
   18 call resimi(luwrk)
      luswch=1
      return
   19 call resimi(luwrk)
      luswch=2
      return
   20 call resimi(luwrk)
      luswch=3
      return
   21 call resimi(luwrk)
      luswch=4
      return
   22 call rearri(luwrk,nlim,i)
      if(luswch.ge.1 .and. luswch.le.4) jedgeo(luswch)=luwrk(1)
      return
   23 call rearri(jlref,nlim,i)
      return
   24 call resimi(i)
      return
   25 call skipit
      return
   26 call skipit
      return
   27 call rearri(nmvsle,nlim,nnvsle)
      return
   28 call skipit
      return
   29 call rearri(jlsptp,nlim,i)
      return
   30 call rearri(jlsptc,nlim,i)
      return
   31 call rearri(jsrss,nlim,i)
      return
   32 call rearri(jsrsg,nlim,i)
      return
   33 call rearre(rcycsa,nlim,i)
      return
   34 call rearre(rcycca,nlim,i)
      return
   36 call resimi(luswch)
      if(.not.tgdtinpt) then
   	ntrgte=ntrgte+1
   	ntrgtm=max(ntrgtm,luswch)
      end if
      return
   37 if(.not.tgdtinpt) call resimi(jedgec(luswch))
      return
   38 if(.not.tgdtinpt) call resimi(jedgep(luswch))
      return
   39 call resimi(luswch)
      if(.not.tgdtinpt) then
      	ntrgte=1
	ntrgtm=luswch
      else
        ntrgte=ntrgte+1
        ntrgtm=max(ntrgtm,luswch)
      end if
      tgdtinpt=.true.
      return
   40 call resimi(jedgec(luswch))
      return
   41 call resimi(jedgep(luswch))
      return
   42 i=lena
      lena=8
      call resima(made_of(luswch))
      lena=i
      return
   43 call resime(tgabsrp(luswch))
      return
   44 call resime(tgewall(luswch))
      return
   45 call resime(tgtrnsf(luswch))
      return
   46 call resime(tgtrnsb(luswch))
      return
   47 call resimi(tgspcsw(luswch))
      return
   48 call resimi(tgspcgr(luswch))
      return
   49 call resime(tgspcff(luswch))
      return
   50 call resimi(tgsppsw(luswch))
      return
   51 call resimi(tgsppsp(luswch))
      return
   52 call resime(tgsppff(luswch))
      return
   53 call resimi(tgrefsw(luswch))
      return
   54 call rearri(ldvbndx,nbnddvd+1,i)
      mdvbndx=i-1
      return
   55 if(hlp_spc) nspigen=0
      hlp_spc=.false.
      nspigen=nspigen+1
      if(nspigen.gt.natm) then !{
      	write(0,*) 'Too many species: maximum ',natm
	stop ' ==> Check the DG model and DEF_NATM in DIMENSIONS.F'
      end if !}
      call resimi(i)
      print *,'uinnam: species ',i,nspigen
      if(nspigen.ne.i) then !{
      	write(0,*) '*** uinnam: wrong species order.  nspigen,i = ',
     ,	  nspigen,i
	stop ' ==> Corrupted DG output?'
      end if !}
      return
   56 if(nspigen.le.0 .or. hlp_spc) then !{
      	write(0,*) 'uinnam: species index undefined'
	stop ' ==> Corrupted DG output?'
      end if !}
      l=lena
      lena=2
      call resima(spcigen(nspigen))
      lena=l
      print *,'                          ==> ',spcigen(nspigen)
      return
   57 call resimi(i)
      ngpfstr=ngpfstr+1
      if(ngpfstr.ge.nstra) then !{
      	write(0,*) 'Too many gas-puffing strata specified'
	stop ' ==> Check the DG model and DEF_NSTRA in DIMENSIONS.F'
      end if !}
      return
   58 if(ngpfstr.le.0) then !{
      	write(0,*) 'uinnam: gas-puffing strata index undefined'
	stop ' ==> Corrupted DG output?'
      end if !}
      if(lugpf.ge.nlim) then !{
      	write(0,*) 'uinnam: too many slot surfaces for gas puff'
	stop ' ==> Check the DG model and DEF_NLIM in DIMENSIONS.F'
      end if !}
      call rearri(lgpfstr(lugpf+1),nlim-lugpf,i)
      if(i.eq.0) then !{
      	write(0,*) 'The slot specification is missing for gas-puffing',
     ,	  ' stratum',ngpfstr
	stop ' ==> Check the "Gas puff" variables in the DG model'
      end if !}
      kgpfstr(ngpfstr)=i
      lugpf=lugpf+i
      return
   59 call resimi(mgpfstr(ngpfstr))
      return
   60 l=lena
      lena=12
      call resima(cgpfstrs(ngpfstr))
      lena=l
      return
   61 call resime(fgpfstr(ngpfstr))
      return
   62 call resime(tgpfstr(ngpfstr))
      return
   63 call resimi(jgpfstr(ngpfstr))
      return
   64 call resime(pgpfstr(ngpfstr))
      return
   65 call resimi(npgpfstr(ngpfstr))
      return
   66 call resimi(nigpfstr(ngpfstr))
      return
   67 call resimi(jxi)
      return
   68 call resimi(jxa)
      return
   69 call resimi(laddsrfs)
      return
   70 call resime(u)
      zaa=2*3.1415926535898*u
      return
   71 call resimi(i)
      nlscl=i.ne.0
      return
   72 call resimi(ntime)
      return
   73 call resimi(nfile)
      return
   74 call resimi(lfrm15)
      return
   75 call resimi(nprnli)
      nprnli=min(nprnli,nprnl)
      return
   76 call resime(dtimv)
      return
   77 call rearre(xlpcntr,3,i)
      return
   78 call resimi(i)
      do_hepdt= i.ne.0
      return
   79 call resimi(locphep)
      return
   80 call resime(pwrhepdt)
      return
   81 call resime(pmphepdt)
      return
   82 call rearri(lstclhep,nxd,nstclhep)
      return
   83 call rearri(lhetrgts,nlim,nhetrgts)
      return
   84 call resimi(tgnhst(luswch))
      return
   85 call resimi(tgnini(luswch))
      return
   86 if(namdf.le.0) then !{
      	write(0,*) 'uinnam: AMDS reference index undefined'
	stop ' ==> Corrupted DG output?'
      end if !}
      l=lena
      lena=48
      call resima(amd_file(namdf))
      lena=l
      if(index(amd_file(namdf),'.').eq.0) then !{
      	i=index(amd_file(namdf),ubs)
      	if(i.eq.0) then !{
	  uam=amd_file(namdf)
	  uam(49:52)='.amo' ! xpb: was .amds extension
	  call lefta(uam,52,i)
	  if(i.gt.48) then !{
	    write(0,*) 'Too long name for AMDS reference after ',
     ,	      'expansion: ',uam
	    stop '==> Check the DG model'
	  end if !}
	  amd_file(namdf)=uam
	  write(*,*) 'Filename for AMDS reference expanded: ',uam
      	else !}{
	  amd_file(namdf)(i:i)=' '
	  call lefta(amd_file(namdf),48,i)
	  write(*,*) 'Filename for AMDS reference quoted: ',
     ,	      	      	      	      	      	      	amd_file(namdf)
	end if !}
      end if !}
      return
   87 call resimi(namdf)
      if(namdf.gt.namdfs) then !{
      	write(0,*) 'Too many AMDS models specified - must be no more ',
     ,	  'than',namdfs
      	stop '==> Check the DG model or increase NAMDFS in uimpcon.inc'
      end if !}
      return
c-----------------------------------------------------------------------
c*** Chemical sputtering
   88 call resimi(i)
      nchsppri=nchsppri+1
      if(nchsppri.gt.nchsppr) then !{
      	write(0,*) 'Too many chemical reactions specified.'
      	write(0,*) 'STOP ==> check the DG model and the value of ',
     ,	      	      	      	      	      'nchsppr in KOPPLDIM.F'
      	stop
      end if !}
      return
   89 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      l=lena
      lena=24
      call resima(chsptgt(nchsppri))
c      read(iunii,'(2x,a)',end=9989) chsptgt(nchsppri)
c      immed=hlp_imm
      lena=l
      return
c 9989 write(0,*) 'Unexpected end-of-file encountered in uinnam'
c      stop ' ==> Corrupted DG output?'
   90 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(ychsptg(nchsppri))
      return
   91 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      lena=16
      call resima(chspspt(nchsppri))
      lena=l
      return
   92 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resimi(lchspnwl(nchsppri))
      return
   93 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(echsptg(nchsppri))
      return
   94 if(nchsppri.le.0) then !{
      	write(0,*) 'Chemical sputtering data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(fchsptg(nchsppri))
      return
c-----------------------------------------------------------------------
c*** Surface data transfer from B2 to Eirene
   95 call resimi(i)
      n_spcsrf=n_spcsrf+1
      if(n_spcsrf.gt.DEF_NSPCSRFG) then !{
      	write(0,*) 'Too many "Surface special" groups specified'
      	write(0,*) 'STOP ==> check the DG model and the value of ',
     ,	      	      	      	          'DEF_NSPCSRFG in DIMENSIONS.F'
      	stop
      end if !}
      if(n_spcsrf.ne.i) then !{
      	write(0,*) '### Wrong order of "Surface special" groups - ',
     ,	      	      	      	                  'corrupted DG model?'
      end if !}
      return
   96 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_absr(n_spcsrf))
      return
   97 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_trno(n_spcsrf))
      return
   98 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_trni(n_spcsrf))
      return
   99 if(n_spcsrf.le.0) then !{ ####
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resima(sps_mtrl(n_spcsrf))
      sps_mtri(n_spcsrf)=-1
      if(sps_mtrl(n_spcsrf).ne.'-') 
     -  call uinmtr(sps_mtrl(n_spcsrf),sps_mtri(n_spcsrf),1)
      return
  100 if(n_spcsrf.le.0) then !{
       	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_tmpr(n_spcsrf))
      return
  101 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_spph(n_spcsrf))
      return
  102 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resime(sps_spch(n_spcsrf))
      return
  103 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resimi(sps_sgrp(n_spcsrf))
      return
  104 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call rearri(ll_spcsrf(1,n_spcsrf),nlimps,k_spcsrf(n_spcsrf))
      return
  105 if(n_spcsrf.le.0) then !{
      	write(0,*) '"Surface special" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resima(sps_id(n_spcsrf))
      return
  106 call resimi(i)
      if(npfrgrp.eq.0) luprf=0
      npfrgrp=npfrgrp+1
      if(npfrgrp.gt.npfrgrpd) then !{
      	write(0,*) 'Too many "PFR surface groups" specified'
      	write(0,*) 'STOP ==> check the DG model and the value of ',
     ,	                        'npfrgrpd in uinpcom.inc and COMUSER.F'
      	stop
      end if !}
      if(npfrgrp.ne.i) then !{
      	write(0,*) '### Wrong order of "PFR surface groups" - ',
     ,	      	      	      	                  'corrupted DG model?'
      end if !}
      return
  107 if(npfrgrp.le.0) then !{
      	write(0,*) '"PFR surface group" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      call resima(gpfrgrp(npfrgrp))
      return
  108 if(npfrgrp.le.0) then !{
      	write(0,*) '"PFR surface group" data outside the block - ',unn
	stop ' ==> Corrupted DG output?'
      end if !}
      j=DEF_NLIM-luprf
      if(j.le.0) then !{
        write(0,*) 'Too many elements in "PFR surface groups"'
        stop ' ==> check the DG model'
      end if !}
      call rearri(lpfrgrp(luprf+1),j,i)
      ipfrgrp(npfrgrp)=luprf+1
      jpfrgrp(npfrgrp)=luprf+i
      luprf=luprf+i
      return
c-----------------------------------------------------------------------
c*** Limiter configuration (code cheating)
  109 lm_cnfg=.true.
      call skipit
      return
  110 call resimi(lm_vhst)
      return
  111 call resimi(lm_whst)
      return
c-----------------------------------------------------------------------
c*** Toroidal geometry
  112 call resime(roator)
      return
  113 call resimi(nttrator)
      return
c-----------------------------------------------------------------------
c*** Material properties of the grid edges
  114 nwllmrk=nwllmrk+1
      call skipit
      if(nwllmrk.gt.nwllmrkd) then !{
        write(0,*) 'Too many reference wall segments (spc_side)'
        stop ' ==> Check the DG model or increase nwllmrkd in uinpcom'
      end if !}
      return
  115 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (ref_wall)'
	stop ' ==> Corrupted DG output?'
      else if(nwllmrk.le.nwllmrkd) then !}{
        call resimi(lwllmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        stop ' ==> Check the DG model or increase nwllmrkd in uinpcom'
      end if !}
      return
  116 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (edgemark)'
	stop ' ==> Corrupted DG output?'
      else if(nwllmrk.le.nwllmrkd) then !}{
        call rearri(ledgmrk(1,nwllmrk),nedgmrkd,nedgmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        stop ' ==> Check the DG model or increase nwllmrkd in uinpcom'
      end if !}
      return
  117 if(nwllmrk.le.0) then !{
        write(0,*) 'Grid edge material data outside block (trgtmark)'
	stop ' ==> Corrupted DG output?'
      else if(nwllmrk.le.nwllmrkd) then !}{
        call rearri(ltrgmrk(1,nwllmrk),nedgmrkd,ntrgmrk(nwllmrk))
      else !}{
        write(0,*) 'Too many reference wall segments (spc_side)'
        stop ' ==> Check the DG model or increase nwllmrkd in uinpcom'
      end if !}
      return
c-----------------------------------------------------------------------
c*** Data for diagnostics of wall erosion
  118 call resimi(nmcsptu)
      return
  119 call resime(emnspc)
      return
  120 call resime(emxspc)
      return
  121 call resimi(npspcen)
      return
  122 call resimi(npspctt)
      return
  123 call resimi(npspcfi)
      return
  124 call rearri(listmtmp,lntsputx,lntsptu)
      return
  125 l=lena
      lena=2
      call resima(txtmtra(1))
      lena=l
      return
  126 call resimi(dgntime)
      return
  127 call resimi(dgnptsfc)
      return
  128 call rearri(listaddi,nlim,nlstadu)
      return
  129 call resimi(lugwt)
      ngwtiesi=ngwtiesi+1
      if(ngwtiesi.gt.ngwtiesx) then !{
        write(0,*) 'uinnam: too many ties specified ( > ',ngwtiesx,' )'
        write(0,*) '  ==> Check the DG model'
        stop
      end if !}
      return
  130 call resimi(kgwties(ngwtiesi))
      return
  131 call rearri(lgwties(1,ngwtiesi),mgwtiesx,mgwties(ngwtiesi))
      return
c-----------------------------------------------------------------------
c*** Data for visualisation of the surface properties
  132 call resimi(luvsp)
      if(luvsp.lt.0) then !{
        write(0,*) 'uinnam: negative view identifier - corrupted DG ',
     ,                                                       'output???'
        stop
      else if(luvsp.gt.nsrfclsx) then !}{
        write(0,*) 'uinnam: too many views for surface coloring ',luvsp
        write(0,*) '  ==> Check the DG model or increase the nsrfclsx ',
     ,    'parameter in uinpcom.inc'
        stop
      end if !}
      nsrfcls=max(luvsp,nsrfcls)
      return
  133 if(luvsp.le.0 .or. luvsp.gt.nsrfclsx) then !{
        write(0,*) 'uinnam: undefined view identifier - corrupted DG ',
     ,                                                       'output???'
        stop
      end if !}
      call resimi(isrfclu(luvsp,1))
      return
  134 if(luvsp.le.0 .or. luvsp.gt.nsrfclsx) then !{
        write(0,*) 'uinnam: undefined view identifier - corrupted DG ',
     ,                                                       'output???'
        stop
      end if !}
      call resimi(isrfclu(luvsp,2))
      return
  135 if(luvsp.le.0 .or. luvsp.gt.nsrfclsx) then !{
        write(0,*) 'uinnam: undefined view identifier - corrupted DG ',
     ,                                                       'output???'
        stop
      end if !}
      call resimi(isrfclu(luvsp,3))
      return
  147 l=i-135
 1147 if(luvsp.le.0 .or. luvsp.gt.nsrfclsx) then !{
        write(0,*) 'uinnam: undefined view identifier - corrupted DG ',
     ,                                                       'output???'
        stop
      end if !}
      call resimi(i)
      if(i.gt.0) then !{
        msrfcls(luvsp)=msrfcls(luvsp)+1
        lsrfcls(msrfcls(luvsp),luvsp)=l
      end if !}
      return
c***  input trimark is the marker for TRIA mesh
  148 call rearri(ilplgdg,nlim,i)
      return 
c***  input global mesh size
  149 call resime(trisize(0))
      return
c***  input index of rectangle 
  150 call resimi(ntriref)
      return 
c***  input mesh size for current rectangle
  151 if(ntriref.LE.0.OR.ntriref.GT.ntrimax) then
        write(0,*)  'uinnam: wrong index of TRIA regions -',
     ,              'corrupted DG output???'
        stop
      end if
      call resime(trisize(ntriref))
      return
c***  input elements inexes for current rectangle
  152 call rearri(trirefel(lurefls+1),ntrimax-lurefls,trirefcn(ntriref))
      lurefls=lurefls+trirefcn(ntriref)
      return
  153 glb2read=.true.
      call skipit
      return
  154 call resime(pwrcrtti)
      return
  155 call resime(pwrcrtte)
      return
  156 call resime(pwrcrfri)
      pwrcrfri=max(0.,min(1.,pwrcrfri))
      return
  157 call resimi(i)
      usetmstr=i.ne.0
      return
  158 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        stop ' ==> Corrupted DG output?'
      end if !}
      call resimi(spcicrk(nspigen))
      return
  159 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        stop ' ==> Corrupted DG output?'
      end if !}
      call resime(spcicrp(nspigen))
      return
  160 if(nspigen.le.0 .or. hlp_spc) then !{
        write(0,*) 'uinnam: species index undefined'
        stop ' ==> Corrupted DG output?'
      end if !}
      call resime(spcicrf(nspigen))
      return
  161 if(nspigen.le.0 .or. hlp_spc) then !{
      	write(0,*) 'uinnam: species index undefined'
	stop ' ==> Corrupted DG output?'
      end if !}
      call resimi(spciscn(nspigen))
      if(spciscn(nspigen).ne.0) spciscn(nspigen)=1
      return
  162 call resimi(tgmhst(luswch))
      return
  163 call resimi(mpgpfstr(ngpfstr))
      return
c=======================================================================
      end
