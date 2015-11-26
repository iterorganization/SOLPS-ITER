      subroutine uinbndfl
       use b2mod_layer
     , , only: ntrack, nalloys
       use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.04.2005 14:27
c
c=======================================================================
c*** Fill in the default boundary data
c=======================================================================
#include "uinpcom.inc"
      integer i,j,k,l,m,n,isp,iknd,izn,igs_hlp(nspdgen)
      logical ex,uex,hlp_fl1,hlp_fl2
      real hlp_f1
      character hlp_c*2
      logical streql
      external streql
c=======================================================================
c*** Determine the default source scaling relations
c#ifdef DBG
c#      print *,'uinbndfl: nspcncl =',nspcncl
c#endif
      do l=1,nspcncl !{
      	j=0
	do i=1,nspdgen !{
	  if(streql(spcsncl(l),spcdgen(i))) j=i
	end do !}
c	print *,'l,j,spcsncl =',l,j,'  ',spcsncl(l)
	ex=.false.
	uex=.false.
	if(j.gt.0) then !{
c          print *,'j.gt.0. dscbndx = ',dscbndx(j)
	  if(streql(dscbndx(j),'-')) then !{
            igs_hlp(l)=0
          else if(streql(dscbndx(j),'?')) then !}{
            igs_hlp(l)=-1
          else if(streql(dscbndx(j),'*')) then !}{
c*** Hydrogen species
            do k=1,3 !{
              do i=1,nspcncl !{
          	if(streql(spcsncl(i),spcdgen(k))) then !{
          	  if(ex) then !{
          	    write(*,*) 'Ambiguous hydrogen species - no ',
     ,    	      'scaling with generic hydrogen !!!'
          	    igs_hlp(l)=0
          	  else !}{
          	    igs_hlp(l)=i
          	    ex=.true.
          	  end if !}
          	end if !}
              end do !}
            end do !}
          else !}{
	    uex=.true.
	  end if !}
	end if !}
c	print *,'l,ex,igs_hlp =',l,ex,igs_hlp(l)
	if(uex) then !{
	  if(j.eq.0) then !{
	    igs_hlp(l)=l
	  else if(streql(dscbndx(j),'=')) then !}{
	    igs_hlp(l)=l
	  else !}{
	    hlp_c=dscbndx(j)
	    ex=.false.
	    do i=1,nspcncl !{
	      if(streql(spcsncl(i),hlp_c)) then !{
	    	igs_hlp(l)=i
	    	ex=.true.
	      end if !}
	    end do !}
	    if(.not.ex) then !{
	      do i=1,nspcncl !{
	    	if(streql(spcsncl(i),hlp_c)) ex=.true.
	      end do !}
	      if(ex) write(*,*) 'No species ',hlp_c,' found - ',
     ,	    	'no scaling for ',spcsncl(j)
	      igs_hlp(l)=0
	    end if !}
	  end if !}
	end if !}
      end do !}
      print *,'Finally, igs_hlp =',(igs_hlp(i),i=1,nspcncl)

c*** Set the data

      do iknd=1,nbndknd !{
      	do izn=1,nznbndt(iknd) !{
	  if(.not.bxsbndt(izn,iknd)) then !{
	    if(iknd.eq.2 .and. tgdtinpt) then !{
c*** Take the neutral data from the "whole target" specification
	      k=lrfbndt(izn,iknd)
	      ewmbnds(izn,iknd)=made_of(k)
	      jskbnds(izn,iknd)=1
	      jrfbnds(izn,iknd)=tgrefsw(k)
	      jcsbnds(izn,iknd)=tgspcsw(k)
	      jcgbnds(izn,iknd)=tgspcgr(k)
	      jpsbnds(izn,iknd)=tgsppsw(k)
	      jppbnds(izn,iknd)=tgsppsp(k)
	      jnpbnds(izn,iknd)=tgnhst(k)
	      jmpbnds(izn,iknd)=tgmhst(k)
	      jnibnds(izn,iknd)=tgnini(k)
	      etfbnds(izn,iknd)=tgtrnsf(k)
	      etbbnds(izn,iknd)=tgtrnsb(k)
	      easbnds(izn,iknd)=tgabsrp(k)
	      eewbnds(izn,iknd)=tgewall(k)
	      efpbnds(izn,iknd)=tgsppff(k)
	      efcbnds(izn,iknd)=tgspcff(k)
	    else !}{
c*** Take the data from the boundary default
	      ewmbnds(izn,iknd)=ewmbndx(0,iknd)
	      jskbnds(izn,iknd)=jskbndx(0,iknd)
	      jrfbnds(izn,iknd)=jrfbndx(0,iknd)
	      jcsbnds(izn,iknd)=jcsbndx(0,iknd)
	      jcgbnds(izn,iknd)=jcgbndx(0,iknd)
	      jpsbnds(izn,iknd)=jpsbndx(0,iknd)
	      jnpbnds(izn,iknd)=jnpbndx(0,iknd)
	      jmpbnds(izn,iknd)=jmpbndx(0,iknd)
	      jnibnds(izn,iknd)=jnibndx(0,iknd)
	      etfbnds(izn,iknd)=etfbndx(0,iknd)
	      etbbnds(izn,iknd)=etbbndx(0,iknd)
	      easbnds(izn,iknd)=easbndx(0,iknd)
	      eewbnds(izn,iknd)=eewbndx(0,iknd)
	      efpbnds(izn,iknd)=efpbndx(0,iknd)
	      efcbnds(izn,iknd)=efcbndx(0,iknd)
	    end if !}
	    jclbnds(izn,iknd)=jclbndx(0,iknd)
	    jnebnds(izn,iknd)=jnebndx(0,iknd)
	    esibnds(izn,iknd)=esibndx(0,iknd)
	    esebnds(izn,iknd)=esebndx(0,iknd)
	    leebnds(izn,iknd)=leebndx(0,iknd)
	    leibnds(izn,iknd)=leibndx(0,iknd)
            lpobnds(izn,iknd)=lpobndx(0,iknd)
	    beebnds(izn,1,iknd)=beebndx(0,1,iknd)
	    beibnds(izn,1,iknd)=beibndx(0,1,iknd)
            bpobnds(izn,1,iknd)=bpobndx(0,1,iknd)
	    beebnds(izn,2,iknd)=beebndx(0,2,iknd)
	    beibnds(izn,2,iknd)=beibndx(0,2,iknd)
            bpobnds(izn,2,iknd)=bpobndx(0,2,iknd)
	    do isp=1,nspcpls !{
      	      l=spcsrnp(isp)
	      ex=.true.
	      do k=1,nspdgen !{
	      	if(ex) then !{
		  if(streql(spcsncl(l),spcdgen(k))) then !{
c*** Take the default for the generic species
		    j=1
		    if(isp.eq.nspcpls .or. l.ne.spcsrnp(isp+1)) j=2
		    lcobnds(isp,izn,iknd)=kcobndx(k,iknd,j)
	            lmobnds(isp,izn,iknd)=kmobndx(k,iknd,j)
	            bcobnds(isp,izn,1,iknd)=dcobndx(k,1,iknd,j)
	            bmobnds(isp,izn,1,iknd)=dmobndx(k,1,iknd,j)
	            bcobnds(isp,izn,2,iknd)=dcobndx(k,2,iknd,j)
	            bmobnds(isp,izn,2,iknd)=dmobndx(k,2,iknd,j)
		    ex=.false.
		  end if !}
	      	end if !}
	      end do !}
	      if(ex) then !{
	        lcobnds(isp,izn,iknd)=lcobndx(isp,0,iknd)
	        lmobnds(isp,izn,iknd)=lmobndx(isp,0,iknd)
	        bcobnds(isp,izn,1,iknd)=bcobndx(isp,0,1,iknd)
	        bmobnds(isp,izn,1,iknd)=bmobndx(isp,0,1,iknd)
	        bcobnds(isp,izn,2,iknd)=bcobndx(isp,0,2,iknd)
	        bmobnds(isp,izn,2,iknd)=bmobndx(isp,0,2,iknd)
	      end if !}
	    end do !}
	    nlrbnds(izn,iknd)=nlrbndx(0,iknd).ne.0
	    do i=1,nspcncl !{
	      lscbnds(i,izn,iknd)=igs_hlp(i)*spcsscn(i)
	    end do !}
	  end if !}
	end do !}
      end do !}
c*** Check for input data for generic species
      iknd=1
      n=nznbndt(iknd)
c#ifdef DBG
c      print *,'uinbndfl: nspcpls,n =',nspcpls,n
c#endif
      ex=.true.
      do isp=1,nspcpls !{
        l=spcsrnp(isp)
c#ifdef DBG
c        print *,'ex,isp,l,spcscrk,spcscrf',ex,isp,l,
c     ,                                            spcscrk(l),spcscrf(l)
c#endif
        if(spcscrk(l).ne.0) then !{
          if(spcscrk(l).lt.0 .or. spcscrk(l).gt.3) then !{
            print *,'uinbndfl: wrong value of the core BC kind for ',
     ,          spcsatm(l),'.  Should be between 0 and 3, is',spcscrk(l)
            ex=.false.
          else if(ex) then !}{
            hlp_fl1=spcscrk(l).eq.3
            hlp_fl2=spcscrk(l).ne.2
c#ifdef DBG
c            print *,'spcscrk,hlp_fl1,hlp_fl2',spcscrk(l),hlp_fl1,hlp_fl2
c#endif
            if((hlp_fl1 .or. hlp_fl2) .and. n.gt.1 .and. 
     .                                 (n.gt.2 .or. nniso.ne.1)) then !{
              print*,'uinbndfl: CEI partitioning is not foreseen yet.'
              ex=.false.
            end if !}
            if(ex) then !{
c*** uex: the highest ionisation state for this species
              uex=isp.eq.nspcpls .or. spcsrnp(isp+1).ne.l
c#ifdef DBG
c              print *,'uex,isp,l,spcsrnp',uex,isp,l,spcsrnp(isp+1)
c#endif
              if(n.eq.1) then !{
                hlp_f1=1
              else !}{
                hlp_f1=spcscrf(l)
              end if !}
              do izn=1,nznbndt(iknd) !{
                if(uex) then !{
                  if(hlp_fl1) then !{
                    lcobnds(isp,izn,iknd)=8
                    bcobnds(isp,izn,1,iknd)=hlp_f1*spcscrp(l)
                  else !}{
                    lcobnds(isp,izn,iknd)=1
                    bcobnds(isp,izn,1,iknd)=spcscrp(l)
                  end if !}
                else !}{
                  if(hlp_fl2) then !{
                    lcobnds(isp,izn,iknd)=8
                    bcobnds(isp,izn,1,iknd)=0
                  else !}{
                    lcobnds(isp,izn,iknd)=1
                    bcobnds(isp,izn,1,iknd)=0
                  end if !}
                end if !}
                bcobnds(isp,izn,2,iknd)=0
                hlp_f1=1-hlp_f1
              end do !}
            end if !}
          end if !}
        end if !}
      end do !}
      if(.not.ex) then !{
        print *,'== Error(s) found in uinbndfl - check the DG model'
        stop
      end if !}
c#ifdef DBG
c      print *,' ... leaving uinbndfl'
c#endif
c=======================================================================
      end
