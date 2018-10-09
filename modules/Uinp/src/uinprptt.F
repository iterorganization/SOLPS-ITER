      subroutine uinprptt(lc)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx, mgwtiesx
c
c  version : 01.04.2005 00:25
c
c=======================================================================
c*** Prepare the data for the test Eirene run
c=======================================================================
      implicit none
      logical lc
#include "uinput.inc"
      integer :: i,k,ntcpu_b,nfile_b,i1trc_b,i2trc_b,npts_b(nstra),
     ,  mpts_b(nstra),isyplt_b(8),nptc_b(nstep),nptcm_b(nstep)
      real alloc_b
      logical trchst_b,trcint_b,trcamd_b,trcsou_b,trcbla_b,trcblm_b,
     ,  trcbli_b,trcblp_b,trcble_b,trcblph_b,trctal_b,trcdbg2_b,
     ,  trcdbge_b,trcdbgm_b,trcdbgf_b,trcdbgl_b,trcdbgs_b,
     ,  trcdbgg_b,trcdbgmpi_b,trcdbgc_b,trcsrc_b,trcsur_b,
     ,  pl1st_b,pl2nd_b,pladd_b,plhst_b,plcut_b(3),plnums_b,nltest_b
      save
c=======================================================================
      if(lc) then !{
        ntcpu_b=ntcpu
        nfile_b=nfile
        alloc_b=alloc
        i1trc_b=i1trc
        i2trc_b=i2trc
        do i=1,nstrai !{
          npts_b(i)=npts(i)
          mpts_b(i)=nminpts(i)
        end do !}
        do i=1,ntargi !{
          nptc_b(i)=nptc(i,1)
          nptcm_b(i)=nptcm(i,1)
        end do !}
        do i=1,8 !{
          isyplt_b(i)=isyplt(i)
        end do !}
        trchst_b=trchst
        trcint_b=trcint
        trcamd_b=trcamd
        trcsou_b=trcsou
        trcsur_b=trcsur
        trcbla_b=trcbla
        trcblm_b=trcblm
        trcbli_b=trcbli
        trcblp_b=trcblp
        trcble_b=trcble
        trcblph_b=trcblph
        trctal_b=trctal
        trcdbg2_b=trcdbg2
        trcdbge_b=trcdbge
        trcdbgm_b=trcdbgm
        trcdbgf_b=trcdbgf
        trcdbgl_b=trcdbgl
        trcdbgs_b=trcdbgs
        trcdbgg_b=trcdbgg
        trcdbgmpi_b=trcdbgmpi
        trcdbgc_b=trcdbgc
        trcsrc_b=trcsrc(0)
        pl1st_b=pl1st
        pl2nd_b=pl2nd
        pladd_b=pladd
        plhst_b=plhst
        plcut_b(1:3)=plcut(1:3)
        plnums_b=plnums
        nltest_b=nltest

        ntcpu=ttntcpu
        nfile=ttnfile
        alloc=ttalloc
        i1trc=1
        i2trc=0
        do i=1,nstrai !{
          npts(i)=ttnpts(i)
          nminpts(i)=0
          i2trc=i2trc+npts(i)
        end do !}
        do i=1,ntargi !{
          nptc(i,1)=ttnpts(i)
          nptcm(i,1)=0
        end do !}
        isyplt(1)=1
        isyplt(2)=2
        isyplt(3)=3
        isyplt(4)=5
        isyplt(5)=6
        isyplt(6)=8
        isyplt(7)=11
        isyplt(8)=18
        trchst=ttchst
        trcint=ttcint
        trcamd=ttcint
        trcsou=ttcsou
        trcsur=ttcsur
        trcbla=ttcbla
        trcblm=ttcblm
        trcbli=ttcbli
        trcblp=ttcblp
        trcble=ttcble
        trcblph=ttcblph
        trctal=ttctal
        trcdbg2=ttcdbg2
        trcdbge=ttcdbge
        trcdbgm=ttcdbgm
        trcdbgf=ttcdbgf
        trcdbgl=ttcdbgl
        trcdbgs=ttcdbgs
        trcdbgg=ttcdbgg
        trcdbgmpi=ttcdbgmpi
        trcdbgc=ttcdbgc
        trcsrc(0)=ttcsrc
        pl1st=ttpl1st
        pl2nd=ttpl2nd
        pladd=ttpladd
        plhst=ttplhst
        plcut(1:3)=ttplcut(1:3)
        plnums=ttplnums
        nltest=tttest

c*** Set the VSP data for test.eir

        nsrfcls=nsrfclu(2)
        do k=1,abs(nsrfcls) !{
          msrfcls(k)=msrfclu(k,2)
          do i=1,msrfcls(k) !{
            lsrfcls(i,k)=lsrfclu(i,k,2)
          end do !}
        end do !}

      else !}{
        nsrfcls=0
        ntcpu=ntcpu_b
        nfile=nfile_b
        alloc=alloc_b
        i1trc=i1trc_b
        i2trc=i2trc_b
        do i=1,nstrai !{
          npts(i)=npts_b(i)
          nminpts(i)=mpts_b(i)
        end do !}
        do i=1,ntargi !{
          nptc(i,1)=nptc_b(i)
          nptcm(i,1)=nptcm_b(i)
        end do !}
        do i=1,8 !{
          isyplt(i)=isyplt_b(i)
        end do !}
        trchst=trchst_b
        trcint=trcint_b
        trcamd=trcamd_b
        trcsou=trcsou_b
        trcsur=trcsur_b
        trcbla=trcbla_b
        trcblm=trcblm_b
        trcbli=trcbli_b
        trcblp=trcblp_b
        trcble=trcble_b
        trcblph=trcblph_b
        trctal=trctal_b
        trcdbg2=trcdbg2_b
        trcdbge=trcdbge_b
        trcdbgm=trcdbgm_b
        trcdbgf=trcdbgf_b
        trcdbgl=trcdbgl_b
        trcdbgs=trcdbgs_b
        trcdbgg=trcdbgg_b
        trcdbgmpi=trcdbgmpi_b
        trcdbgc=trcdbgc_b
        trcsrc(0)=trcsrc_b
        pl1st=pl1st_b
        pl2nd=pl2nd_b
        pladd=pladd_b
        plhst=plhst_b
        plcut(1:3)=plcut_b(1:3)
        plnums=plnums_b
        nltest=nltest_b
      end if !}
c=======================================================================
      end
