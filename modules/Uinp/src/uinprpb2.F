      subroutine uinprpb2
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 15.08.2003 18:26
c
c=======================================================================
c*** Prepares the arrays of the B2 parameters to be used for replacement
c=======================================================================
#include "uinput.inc"
#include "uib2pprm.inc"
      integer i,j,k,l,m,n,ii,jj,nbc
      integer ifl(DEF_NFL)
      logical ex
      external xerrab
c=======================================================================
#ifdef DBG
      print *,'Starting uinprpb2'   !###
#endif
c-----------------------------------------------------------------------
c*** Initialization

      lprdckw=.true.
      do k=1,nmxlyr !{
        lprdckw(k,1,16,3)=.false.
      end do !}

      nmdpr(4,1)=nspcpls+nspcncl
      nmdpr(5,1)=nspcpls+nspcncl

c*** nx, ny, ns
      iniprm(1,1,1,1,1)=nx
      iniprm(1,1,1,2,1)=ny
      iniprm(1,1,1,3,1)=nspcpls+nspcncl

c*** Establish species correspondence array
      i=1
      do k=1,nspcncl !{
        ifl(i)=0
        i=i+1
        do j=1,nspcpls !{
          if (k.eq.lkindp(j)) then !{
            ifl(i)=j
            i=i+1
          end if !}
        end do !}
      end do !}

c*** mi, zi
      do i=1,nspcpls+nspcncl !{
        k=ifl(i)
        if (k.eq.0) k=ifl(i+1)
      	iniprm(i,1,1,4,1)=spcscgp(k)
      	iniprm(i,1,1,5,1)=spcsmsp(k)
      end do !}

c-----------------------------------------------------------------------
c*** Boundary

      nbc=0
      do i=1,nbndknd !{
      	nbc=nbc+nznbndt(i)
      end do !}
      do i=2,9 !{
      	nmdpr(i,2)=nbc
      end do !}
      do i=23,24 !{
        nmdpr(i,2)=nbc
      end do !}
      do i=8,9 !{
      	nmdlr(i,2)=2
      end do !}
      nmdlr(24,2)=2
      do i=10,13 !{
      	nmdlr(i,2)=nbc
      	nmdpr(i,2)=nspcpls+nspcncl
      end do !}
      nmdbr(11,2)=2
      nmdbr(13,2)=2
      nmdpr(14,2)=nznbndt(1)
      ltrvr(2,2)=.true.
      lrrvr(8,2)=.true.
      lrrvr(9,2)=.true.
      lrrvr(11,2)=.true.
      lrrvr(13,2)=.true.
      lrrvr(24,2)=.true.

      if(glb2read) then !{
        if(nznbndt(1).eq.1) then !{
c*** simple SN case
          beebnds(1,1,1)=1.e6*pwrcrtte
          beibnds(1,1,1)=1.e6*pwrcrtti
        else if(nznbndt(1).eq.2 .and. nniso.eq.1) then !}{
          beebnds(1,1,1)=1.e6*pwrcrtte*pwrcrfri
          beibnds(1,1,1)=1.e6*pwrcrtti*pwrcrfri
          beebnds(2,1,1)=1.e6*pwrcrtte*(1-pwrcrfri)
          beibnds(2,1,1)=1.e6*pwrcrtti*(1-pwrcrfri)
        else !}{
          write(*,*) 'CEI partitioning in uinp is not yet foreseen !!!'
        end if !}
      end if !}
      
c*** nbc
      iniprm(1,1,1,1,2)=nbc

      k=0
      do j=1,nbndknd !{
      	do i=1,nznbndt(j) !{
	  k=k+1
c*** bcchar, bcpos, bcstart, bcend, bcene, bceni, enepar, enipar
	  cniprm(k,1,1,2,2)=cznbndt(i,j)
	  iniprm(k,1,1,3,2)=lcpbnds(i,j)-1
	  iniprm(k,1,1,4,2)=lc1bnds(i,j)-1
	  iniprm(k,1,1,5,2)=lc2bnds(i,j)-1
	  iniprm(k,1,1,6,2)=leebnds(i,j)
	  iniprm(k,1,1,7,2)=leibnds(i,j)
	  rniprm(k,1,1,8,2)=beebnds(i,1,j)
	  rniprm(k,1,1,9,2)=beibnds(i,1,j)
	  rniprm(k,2,1,8,2)=beebnds(i,2,j)
	  rniprm(k,2,1,9,2)=beibnds(i,2,j)
c*** bcpot, potpar
          iniprm(k,1,1,23,2)=lpobnds(i,j)
          rniprm(k,1,1,24,2)=bpobnds(i,1,j)
          rniprm(k,2,1,24,2)=bpobnds(i,2,j)
c*** bccon, conpar, bcmom, mompar
	  do l=1,nspcpls+nspcncl !{
            if (ifl(l).eq.0) cycle
	    iniprm(l,k,1,10,2)=lcobnds(ifl(l),i,j)
	    rniprm(l,k,1,11,2)=bcobnds(ifl(l),i,1,j)
	    rniprm(l,k,2,11,2)=bcobnds(ifl(l),i,2,j)
	    iniprm(l,k,1,12,2)=lmobnds(ifl(l),i,j)
	    rniprm(l,k,1,13,2)=bmobnds(ifl(l),i,1,j)
	    rniprm(l,k,2,13,2)=bmobnds(ifl(l),i,2,j)
      	  end do !}
      	end do !}
      end do !}
c*** lcbs
      do i=1,nznbndt(1) !{
      	iniprm(i,1,1,14,2)=i
      end do !}
c*** nniso
      iniprm(1,1,1,15,2)=nniso
c*** ntiso, nxiso1, nxiso2, nyiso1, nyiso2
      do i=1,nniso !{
      	iniprm(i,1,1,16,2)=nxiso1(i)
      	iniprm(i,1,1,17,2)=nxiso2(i)
      	iniprm(i,1,1,18,2)=nyiso1(i)
      	iniprm(i,1,1,19,2)=nyiso2(i)
      end do !}
c*** niiso, tiiso, teiso
      do i=1,nspcpls+nspcncl !{
      	rniprm(i,1,1,20,2)=1.e5
      end do !}
      rniprm(1,1,1,21,2)=0.1
      rniprm(1,1,1,22,2)=0.1
      nmdpr(20,2)=nspcpls+nspcncl
      lrrvr(20,2)=.true.
      lrrvr(21,2)=.true.
      lrrvr(22,2)=.true.

#ifdef DBG
      print *,'Boundary: nbc,k = ',nbc,k !###
#endif

c*** Redundancy check      

c*** enepar, enipar, potpar
      lprdckw(2,1,8,2)=.false.
      lprdckw(2,1,9,2)=.false.
      lprdckw(2,1,24,2)=.false.
      do k=1,nbc !{
        if(iniprm(k,1,1,6,2).eq.4) lprdckw(2,1,8,2)=.true.
        if(iniprm(k,1,1,7,2).eq.3) lprdckw(2,1,9,2)=.true.
        if(iniprm(k,1,1,7,2).eq.4) lprdckw(2,1,9,2)=.true.
        if((iniprm(k,1,1,6,2).eq.3 .or. iniprm(k,1,1,6,2).eq.15) .and. 
     .     rniprm(k,2,1,24,2).ne.0) lprdckw(2,1,24,2)=.true.
        if((iniprm(k,1,1,23,2).eq.3 .or. iniprm(k,1,1,23,2).eq.11) .and.
     .     rniprm(k,2,1,24,2).ne.0) lprdckw(2,1,24,2)=.true.
        if(iniprm(k,1,1,23,2).eq.4) lprdckw(2,1,24,2)=.true.
        if(iniprm(k,1,1,23,2).eq.21) lprdckw(2,1,24,2)=.true.
c*** conpar, mompar
        lprdckw(k,1,11,2)=.false.
        lprdckw(k,1,13,2)=iniprm(k,1,1,6,2).eq.3 .or.
     .                                            iniprm(k,1,1,7,2).eq.3
        lprdckw(k,2,11,2)=.false.
        lprdckw(k,2,13,2)=.false.
        do l=1,nspcpls+nspcncl !{
          if (ifl(l).eq.0) cycle
          if(iniprm(l,k,1,10,2).ne.3) lprdckw(k,1,11,2)=.true.
          if(iniprm(l,k,1,12,2).ne.8) lprdckw(k,1,13,2)=.true.
          if(iniprm(l,k,1,10,2).eq.4) lprdckw(k,2,11,2)=.true.
          if(iniprm(l,k,1,10,2).eq.7) lprdckw(k,2,11,2)=.true.
          if(iniprm(l,k,1,12,2).eq.3) lprdckw(k,2,13,2)=.true.
          if(iniprm(l,k,1,12,2).eq.4) lprdckw(k,2,13,2)=.true.
          if(iniprm(l,k,1,12,2).eq.6) lprdckw(k,2,13,2)=.true.
          if(iniprm(l,k,1,12,2).eq.7) lprdckw(k,2,13,2)=.true.
        end do !}
      end do !}
c*** niiso, tiiso, teiso
      if(iniprm(1,1,1,15,2).eq.0) then !{
        lprdckw(1,1,16,2)=.false.
        lprdckw(1,1,17,2)=.false.
        lprdckw(1,1,18,2)=.false.
        lprdckw(1,1,19,2)=.false.
        lprdckw(1,1,20,2)=.false.
        lprdckw(1,1,21,2)=.false.
        lprdckw(1,1,22,2)=.false.
      end if !}

c-----------------------------------------------------------------------
c*** Neutrals

c*** k, m, n are the numbers of recycling, specified, and all strata      
      k=0
      do j=1,nbndknd !{
        do i=1,nznbndt(j) !{
          if(nlrbnds(i,j)) k=k+1
        end do !}
      end do !}
      m=k+ngpfstr+nrcmstr
      n=m
      if(usetmstr) n=m+1
      if(n.gt.nmxprm) then !{
      	write(0,*) 'Too many strata found in uinprpb2: ',n
	write(0,*) 'nlrbnds:'
	do jj=1,nbndknd !{
	  if(nznbndt(jj).gt.0) write(0,
     ,    			'(1x,a2,1x,50l2/(4x,50l2))') jj,
     ,    			  (nlrbnds(ii,jj),ii=1,nznbndt(j))
	end do !}
	call xerrab (' == Internal error in UINP')
      end if !}

#ifdef DBG
      print *,'Neutrals: k,m,n = ',k,m,n !###
#endif

      do i=3,6 !{
      	nmdpr(i,3)=n
      end do !}
      nmdpr(7,3)=nspcncl
      nmdpr(8,3)=n
      nmdlr(8,3)=nspcncl
      do i=9,11,2 !{
      	nmdpr(i,3)=k
      end do !}
      nmdpr(10,3)=0
      nmdpr(12,3)=nznbndt(1)
      nmdpr(13,3)=nznbndt(2)
      nmdpr(14,3)=nspcpls+nspcncl
      nmdlr(14,3)=n
      nmdpr(15,3)=m
      nmdlr(15,3)=1
      nmdpr(16,3)=nspcncl
      nmdlr(16,3)=m
      nmdpr(17,3)=nspcpls+nspcncl
      nmdpr(31,3)=nlimi+nstsi+1
      ltrvr(3,3)=.true.
      lrrvr(14,3)=.true.
      lrrvr(15,3)=.true.
      lrrvr(16,3)=.true.
      lrrvr(31,3)=.true.

c*** nstrai

      iniprm(1,1,1,1,3)=n

c*** Recycling sources

      k=0
      kk=0
      do j=1,nbndknd !{
      	do i=1,nznbndt(j) !{
	  kk=kk+1
	  if(nlrbnds(i,j)) then !{
	    k=k+1
            if(k.ge.nmxprm) then !{
              write(0,*) 'Too many strata found in uinprpb2: ',k
              write(0,*) 'Recycling loop, j,i,kk = ',j,i,kk
	      write(0,*) 'nlrbnds:'
	      do jj=1,nbndknd !{
	      	if(nznbndt(jj).gt.0) write(0,
     ,  	      	      	      '(1x,a2,1x,50l2/(4x,50l2))') jj,
     ,  	      	      	      	(nlrbnds(ii,jj),ii=1,nznbndt(j))
	      end do !}
      	      call xerrab (' == Internal error in UINP')
            end if !}

c***  	      	crcstra, rcpos, rcstart, rcend
      	    cniprm(k,1,1,3,3)=cznbndt(i,j)
      	    iniprm(k,1,1,4,3)=lcpbnds(i,j)-1
      	    iniprm(k,1,1,5,3)=ls1bnds(i,j)-1
      	    iniprm(k,1,1,6,3)=ls2bnds(i,j)-1

c***  	      	lstrascl
	    do l=1,nspcncl !{
      	      iniprm(k,l,1,8,3)=lscbnds(l,i,j)
	    end do !}

c***  	      	lsns, ksns
      	    iniprm(k,1,1,9,3)=kk
      	    iniprm(k,1,1,11,3)=1

c***  	      	userfluxparm
      	    rniprm(k,1,1,15,3)=0

c***  	      	gpfc
	    do l=1,nspcncl !{
      	      rniprm(l,k,1,16,3)=0
	    end do !}
	  end if !}
      	end do !}
      end do !}

c*** Gas puffing sources

      do i=1,ngpfstr !{
	k=k+1
        if(k.ge.nmxprm) then !{
          write(0,*) 'Too many strata found in uinprpb2: ',k
          write(0,*) 'Gas puffing loop, i = ',i
      	  call xerrab (' == Internal error in UINP')
        end if !}

c***  	    crcstra, rcpos, rcstart, rcend
      	cniprm(k,1,1,3,3)='C'
      	iniprm(k,1,1,4,3)=0
      	iniprm(k,1,1,5,3)=0
      	iniprm(k,1,1,6,3)=0

c***  	    userfluxparm
      	rniprm(k,1,1,15,3)=fgpfstr(i)

c***  	    lstrascl,gpfc
	do l=1,nspcncl !{
      	  iniprm(k,l,1,8,3)=lsgpfstr(l,i)
      	  rniprm(l,k,1,16,3)=igpfstr(l,i)
	end do !}
        lprdckw(k,1,16,3)=.true.
      end do !}

c*** Recombination sources

      do i=1,nrcmstr !{
	k=k+1
        if(k.ge.nmxprm) then !{
          write(0,*) 'Too many strata found in uinprpb2: ',k
          write(0,*) 'Recombination loop, i = ',i
      	  call xerrab (' == Internal error in UINP')
        end if !}

c***  	    crcstra, rcpos, rcstart, rcend
      	cniprm(k,1,1,3,3)='V'
      	iniprm(k,1,1,4,3)=0
      	iniprm(k,1,1,5,3)=0
      	iniprm(k,1,1,6,3)=0

c***  	    userfluxparm
      	rniprm(k,1,1,15,3)=0

c***  	    lstrascl, gpfc
	do l=1,nspcncl !{
      	  iniprm(k,l,1,8,3)=lsrcmstr(l,i)
      	  rniprm(l,k,1,16,3)=0
	end do !}
      end do !}

c*** Time-dependent stratum

      if(usetmstr) then !{

        k=k+1

        if(k.ne.n) then !{
          write(0,*) 'Wrong strata counting in uinprpb2: k,n =',k,n
          call xerrab (' == Internal error in UINP !!')
        end if !}

        if(k.ge.nmxprm) then !{
          write(0,*) 'Too many strata found in uinprpb2: ',k
          write(0,*) 'The last stratum'
          call xerrab (' == Internal error in UINP')
        end if !}

c***          crcstra, rcpos, rcstart, rcend
        cniprm(k,1,1,3,3)='T'
        iniprm(k,1,1,4,3)=0
        iniprm(k,1,1,5,3)=0
        iniprm(k,1,1,6,3)=0

c***          lstrascl
        do l=1,nspcncl !{
          iniprm(k,l,1,8,3)=0
        end do !}
      end if !}
 
c***        lcns, ltns
      do i=1,nznbndt(1) !{
        iniprm(i,1,1,12,3)=i
      end do !}
      do i=1,nznbndt(2) !{
        iniprm(i,1,1,13,3)=nznbndt(1)+i
      end do !}

c***        recyc
      do j=1,n !{
        do i=1,nspcpls+nspcncl !{
          k=ifl(i)
          if (k.eq.0) then !{
            rniprm(i,j,1,14,3)=0
          elseif (ncharp(k).eq.1 .or. ncharp(k).eq.2 .or. 
     .            ncharp(k).eq.7 .or. ncharp(k).eq.8 .or.
     .            ncharp(k).eq.10.or. ncharp(k).eq.18.or.
     .            ncharp(k).eq.36.or. ncharp(k).eq.54.or.
     .            ncharp(k).eq.86) then !}{
            rniprm(i,j,1,14,3)=1
          else !}{
            rniprm(i,j,1,14,3)=0
          end if !}
        end do !}
      end do !}

c*** B2 and Eirene species counter

      do i=1,nspcpls+nspcncl !{
        k=ifl(i)
        if (k.eq.0) k=ifl(i+1)
        iniprm(i,1,1,17,3)=lkindp(k)
      end do !}
      do i=1,nspcncl !{
        if (i.eq.1) then !{
          iniprm(i,1,1,7,3)=0
        else !}{
          k=0
          do j=1,nspcpls !{
            if (lkindp(j).eq.i-1) k=k+1
          end do !}
          iniprm(i,1,1,7,3)=iniprm(i-1,1,1,7,3)+k+1
        end if !}
      end do !}

c*** Eirene surface data input through B2

      if(n_spcsrf.gt.0) then !{
        iniprm(1,1,1,18,3)=n_spcsrf
        k=0
        do i=1,n_spcsrf !{
          i_spcsrf(i)=k+1
          k=k+k_spcsrf(i)
          j_spcsrf(i)=k
          do j=1,k_spcsrf(i) !{
            n=ll_spcsrf(j,i)
            do m=1,i-1 !{
              do l=1,k_spcsrf(m) !{
                if(n.eq.ll_spcsrf(l,m)) then !{
                  write(0,*) '### Surface special: common segment',n,
     ,              ' in two groups: ',sps_id(m),' and ',sps_id(i)            
                end if !}
              end do !}
            end do !}
            if(n.gt.0) then !{
              l_spcsrf(i_spcsrf(i)+j-1)=indasrfe(n)
            else !}{
              l_spcsrf(i_spcsrf(i)+j-1)=0
            end if !}
          end do !}
        end do !}
        nmdpr(19,3)=k           ! l_spcsrf
        do i=1,k !{
          iniprm(i,1,1,19,3)=l_spcsrf(i)
        end do !}
        do i=20,30 !{
          nmdpr(i,3)=n_spcsrf
        end do !}
        lt8rvr(20,3)=.true.     ! sps_id
        do i=23,29 !{
          lrrvr(i,3)=.true.
        end do !}
        do i=1,n_spcsrf !{
          c8niprm(i,1,1,20,3)=sps_id(i)
          iniprm(i,1,1,21,3)=i_spcsrf(i)
          iniprm(i,1,1,22,3)=j_spcsrf(i)
          rniprm(i,1,1,23,3)=sps_absr(i)
          rniprm(i,1,1,24,3)=sps_trno(i)
          rniprm(i,1,1,25,3)=sps_trni(i)
          rniprm(i,1,1,26,3)=sps_mtri(i)
          rniprm(i,1,1,27,3)=sps_tmpr(i)
          rniprm(i,1,1,28,3)=sps_spph(i)
          rniprm(i,1,1,29,3)=sps_spch(i)
          iniprm(i,1,1,30,3)=sps_sgrp(i)
        end do !}
      else !}{
        do i=18,30 !{
          chrpl(i,3)=' '
        end do !}
      end if !}
c-----------------------------------------------------------------------
c*** Diagnostics

c*** jxi, jxa
      iniprm(1,1,1,1,4)=jxi
      iniprm(1,1,1,2,4)=jxa

c-----------------------------------------------------------------------
c*** Cut

      do i=3,6 !{
      	nmdpr(i,5)=nncut
      end do !}
      do i=8,12 !{
      	nmdpr(i,5)=nniso
      end do !}
c*** nncut, ntcut
      iniprm(1,1,1,1,5)=nncut
      iniprm(1,1,1,2,5)=3
c*** nxcut1, nxcut2, nycut1, nycut2
      do i=1,nncut !{
      	iniprm(i,1,1,3,5)=nxcut1(i)
      	iniprm(i,1,1,4,5)=nxcut1(nncut+1-i)+1
      	iniprm(i,1,1,5,5)=0
      	iniprm(i,1,1,6,5)=nycut2(i)
      end do !}
c*** nniso
      iniprm(1,1,1,7,5)=nniso
c*** ntiso, nxiso1, nxiso2, nyiso1, nyiso2
      do i=1,nniso !{
        iniprm(1,1,1,8,5)=ntiso(i)
      	iniprm(i,1,1,9,5)=nxiso1(i)
      	iniprm(i,1,1,10,5)=nxiso2(i)
      	iniprm(i,1,1,11,5)=nyiso1(i)
      	iniprm(i,1,1,12,5)=nyiso2(i)
      end do !}
c*** niiso, tiiso, teiso
      do i=1,nspcpls+nspcncl !{
      	rniprm(i,1,1,13,5)=1.e5
      end do !}
      rniprm(1,1,1,14,5)=0.1
      rniprm(1,1,1,15,5)=0.1
      nmdpr(13,5)=nspcpls+nspcncl
      lrrvr(13,5)=.true.
      lrrvr(14,5)=.true.
      lrrvr(15,5)=.true.

c*** Redundancy check      

c*** niiso, tiiso, teiso
      if(iniprm(1,1,1,7,5).eq.0) then !{
        lprdckw(1,1,13,5)=.false.
        lprdckw(1,1,14,5)=.false.
        lprdckw(1,1,15,5)=.false.
      end if !}
c-----------------------------------------------------------------------
c*** Impurities

c*** impflag, nspecies, nfluids
      if(nspcpls.eq.1) then !{
      	iniprm(1,1,1,1,6)=0
	nmdpr(2,6)=0
      else !}{
      	iniprm(1,1,1,1,6)=-1
      	iniprm(1,1,1,2,6)=nspcncl
	nmdpr(3,6)=nspcncl
	j=0
	k=0
	do i=1,nspcpls !{
	  if(spcsrnp(i).ne.j) then !{
	    if(j.gt.0) then !{
	      iniprm(j,1,1,3,6)=k
	    end if !}
	    k=1
	    j=spcsrnp(i)
	  else !}{
	    k=k+1
	  end if !}
	end do !}
	iniprm(j,1,1,3,6)=k
	if(j.ne.nspcncl) then !{
	  write(0,*) 'Ill-sorted plasma species in uinprpb2. nspcncl, ',
     ,	    'nspcpls, spcsrnp: ',nspcncl,nspcpls
	  write(0,*) (spcsrnp(i),i=1,nspcpls)
	  call xerrab ('== Internal error in UINP !!')
	end if !}
       end if !}

c-----------------------------------------------------------------------
c*** User

      ex=.true.
      if(do_hepdt) then !{
c*** Helium pumping data

      	ex=.false.
        lrrvr(1,7)=.true.
      	lrrvr(2,7)=.true.

c*** location, fusion_power, ratio of pumping speeds, j_he_at, j_h_at 
	iniprm(1,1,1,11,7)=locphep
	rniprm(1,1,1,1,7)=pwrhepdt
	rniprm(1,1,1,2,7)=pmphepdt
	iniprm(1,1,1,8,7)=j_he_at
	iniprm(1,1,1,9,7)=j_h_at
c*** lpfrb, lpfrt
      	if(locphep.eq.1) then !{
	  iniprm(1,1,1,4,7)=lstclhep(1)
	  iniprm(1,1,1,6,7)=lstclhep(2)
	end if !}
	iniprm(1,1,1,5,7)=lstclhep(4)
	iniprm(1,1,1,7,7)=lstclhep(3)
c*** lhetrgts
      	if(nhetrgts.lt.nlim) then !{
	  lhetrgts(nhetrgts+1)=0
	  nmdpr(3,7)=nhetrgts+1
      	else !}{
	  nmdpr(3,7)=nhetrgts
      	end if !}
	do i=1,nmdpr(3,7) !{
	  l=lhetrgts(i)
          if(l.gt.0) then !{
            iniprm(i,1,1,3,7)=indasrfe(l)
          else !}{
            iniprm(i,1,1,3,7)=0
          end if !}
	end do !}
c*** l_h_mol
	nmdpr(10,7)=nmoli
	do i=1,nmoli !{
	  iniprm(i,1,1,10,7)=l_h_mol(i)
	end do !}
      end if !}
      if(npfrgrp.gt.0) then !{
c#ifdef DBG
c        print *,'uinprpb2: PFR fluxes',npfrgrp
c        if(npfrgrp.gt.0) then !{
c          print '(1x,a8,3h : ,10a10)','gpfrgrp',
c     ,                                         (gpfrgrp(i),i=1,npfrgrp)
c          print '(1x,a8,3h : ,i6,9i10)','ipfrgrp',
c     ,                                         (ipfrgrp(i),i=1,npfrgrp)
c          print '(1x,a8,3h : ,i6,9i10)','jpfrgrp',
c     ,                                         (jpfrgrp(i),i=1,npfrgrp)
c          if(jpfrgrp(npfrgrp).gt.0) print '(1x,a8,20i4/(9x,20i4))',
c     ,                      'lpfrgrp',(lpfrgrp(i),i=1,jpfrgrp(npfrgrp))
c        end if !}
c#endif 
        iniprm(1,1,1,12,7)=npfrgrp
        nmdpr(13,7)=jpfrgrp(npfrgrp)
        do i=1,jpfrgrp(npfrgrp) !{
          iniprm(i,1,1,13,7)=indasrfe(lpfrgrp(i))
        end do !}
        nmdpr(14,7)=npfrgrp
        nmdpr(15,7)=npfrgrp
        nmdpr(16,7)=npfrgrp
        lt8rvr(16,7)=.true.
        do i=1,npfrgrp !{
          iniprm(i,1,1,14,7)=ipfrgrp(i)
          iniprm(i,1,1,15,7)=jpfrgrp(i)
          c8niprm(i,1,1,16,7)=gpfrgrp(i)
        end do !}
      else !}{
        do i=12,16 !{
          chrpl(i,7)=' '
        end do !}
      end if !}
      if(ex) chrbl(7)=' '

#ifdef DBG
      print *,'Leaving uinprpb2'   !###
#endif 
c=======================================================================
      end
