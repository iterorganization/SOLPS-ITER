C
C VK PETRAS VERSION FROM MAY, 2007. I ADDED SOME AK'S AND MY VARIABLES FROM MY
C OLD PARMMOD AS WELL AS MY EXTRA VARIABLES FOR SPECTRUM
C
      MODULE PARMMOD

      USE PRECISION

      IMPLICIT NONE

      PRIVATE

      PUBLIC :: SET_PARMMOD, COLLECT_PARM, DISTRIB_PARM,
     P          EIRENE_SPECTRUM, SPECT_ARRAY,
     P          ASSIGNMENT(=)

      INTEGER, PUBLIC, PARAMETER ::
     P         NPARTC=12, NPARTT=12,
     P         MPARTC=14, MPARTT=9

      INTEGER, PUBLIC, SAVE ::
     I N1ST,   N2ND,   N3RD,   NADD,   NTOR,
     I NRTAL,  NLIM,   NSTS,
     I NPLG,   NPPART, NKNOT,  NTRI,   NTETRA, NCOORD,
     I NOPTIM, NOPTM1

      INTEGER, PUBLIC, SAVE ::
     I NSTRA,  NSRFS,  NSTEP

      INTEGER, PUBLIC, SAVE ::
     I NATM,   NMOL,   NION,   NPLS,   NPHOT,  NADV,   NADS,
     I NCLV,   NSNV,   NALV,   NALS,   NAIN,   NCOP,   NBGK,  NADSPC,
     I NPLSTI, NPLSV,  NBACK_SPEC,
     I NPLS_TAL !VK NUMBER OF PLASMA SPECIES FOR TALLIES 

      INTEGER, PUBLIC, SAVE ::
     I NSD,    NSDW,   NCV

      INTEGER, PUBLIC, SAVE ::
     I NREAC,  NREC,   NRDS,   NRCX,   NREL,   NRPI,   NROT

      INTEGER, PUBLIC, SAVE ::
     I NHD1,   NHD2,   NHD3,   NHD4,   NHD5,   NHD6

      INTEGER, PUBLIC, SAVE ::
     I NCHOR,  NCHEN

      INTEGER, PUBLIC, SAVE ::
     I NDX,    NDY,    NFL,    NDXP,   NDYP,   NPTRGT

      INTEGER, PUBLIC, SAVE ::
     I NPRNL

      INTEGER, PUBLIC, SAVE ::
     I NTRJ


      INTEGER, PUBLIC, SAVE ::
     I NGEOM_USR, NCOUP_INPUT, NSMSTRA, NSTORAM, NGSTAL, NRPES

      INTEGER, PUBLIC, SAVE ::
     I NRAD,   NSWIT,   N1F,    N2F,    N3F,    NGITT,  NGITTP,
     I NRADS,  N2NDPLG, N1STS,  N2NDS,  NTRIS,  NKNOTS, NRTALS

      INTEGER, PUBLIC, SAVE ::
     I NGTSFT, NLIMPS, NLMPGS

      INTEGER, PUBLIC, SAVE ::
     I NCPV,   NBGV,   NBMAX,   NPTAL,  NCPV_STAT, NSCOP

      INTEGER, PUBLIC, SAVE ::
     I NSTRAP

      INTEGER, PUBLIC, SAVE ::
     I NIONP,  NATMP,  NMOLP,
     I NPLSP,  NPHOTP, NADVP,  NADSP,
     I NCLVP,  NALVP,  NALSP,
     I NSNVP,  NCPVP,  NBGVP,
     I NTALI,  NTALN,  NTALO,  NTALV,
     I NTALA,  NTALC,  NTALT,
     I NTALM,  NTALB,  NTALR,
     I NTALS,  NTLSA,  NTLSR,  NTALW,
     I N1MX,   N2MX,   NSPZ,   NSPZP, NSPZMC, NCOLMC, NSPZTOT

      INTEGER, PUBLIC, SAVE ::
     I NVOLTL, NVLTLP,
     I NSRFTL, NSFTLP

      INTEGER, PUBLIC, SAVE ::
     I NH0,    NH1,    NH2,    NH3

      INTEGER, PUBLIC, SAVE ::
     I NHSTOR, NSTORDT, NSTORDR

      INTEGER, PUBLIC, SAVE ::
     I NPLT

      INTEGER,PUBLIC,PARAMETER :: NIPARM=200 !VK
      INTEGER, PUBLIC, SAVE :: INT_PARM(NIPARM) !VK 200->NIPARM

CVK THE INDEX FOR INPUT UNIT
      INTEGER, PUBLIC ::   STANDARD_INPUT !VK

      INTEGER,PUBLIC,SAVE ::  NFULLRUN !VK

      LOGICAL,PUBLIC,SAVE :: LSHORTRUNMODE, !VK TO SWITCH ON/OFF SHORT RUNS FETU
     l                       NINPUT !VK TO SWITCH ON/OFF INPUT IN EIRENE
CDBG
      REAL,PUBLIC,SAVE :: TEMPTAIL, TEMPTAILI(10)
CDBG END

C AK from PARMUSR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
c***  lntsputx  max. number of material template surfaces
c***  mgwtiesx  max. number of wall segments tied to a grid edge segment
      INTEGER,PUBLIC,PARAMETER :: lntsputx=4,mgwtiesx=12 ! AK!

c*** Data for surface properties visualisation (subr. srfprvsl)
c***
c***  nsrfclsx  max. number of views
c***  msrfclsx  max. number of comparison criteria

      INTEGER,PUBLIC,PARAMETER :: nsrfclsx=3, msrfclsx=12

c*** Sputtering data (to be moved to PARMUSR)
c***
c***    nsptpr  max. number of projectiles in the database SPUTER
c***    nspttg  max. number of target materials in the database SPUTER
c***    nchsppr max. number of aux. data entries for wall reactions
c***                                                         (block 6C)
CVK      INTEGER,PUBLIC,PARAMETER :: nsptpr=11, nspttg=28, nchsppr=12
CVK      INTEGER,PUBLIC,PARAMETER :: ndx=DEF_NXD+5*DEF_NCUT, ndy=DEF_NYD,
CVK     .                            nfl=DEF_NFL, ndxp=ndx+1,ndyp=ndy+1

C AK END !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

      PRIVATE :: SPEC_TO_SPEC
      TYPE EIRENE_SPECTRUM
        REAL(DP) :: SPCMIN, SPCMAX, SPCDEL, SPCDELI, SPCINT, ESP_MIN,
     .              ESP_MAX, ESP_00, SPC_XPLT,SPC_YPLT,SPC_SAME,
     .              SPCVX, SPCVY, SPCVZ,
     .              AMIN, AMAX, DA, IDA, EUP !VK
        REAL(DP) :: SGMS, STVS, EES
        INTEGER :: NSPC, ISPCTYP, ISPCSRF, IPRTYP, IPRSP, IMETSP,
     .             ISRFCLL, IDIREC,
     .             NSAN, IA0, IA1  !VK
        REAL(DP), DIMENSION(:,:), POINTER :: SPC, SDV, SGM !VK 2D ARRAYS INSTEAD
CVK ... this is for angular dependence
      END TYPE EIRENE_SPECTRUM

      TYPE SPECT_ARRAY
        TYPE(EIRENE_SPECTRUM), POINTER :: PSPC
      END TYPE SPECT_ARRAY

      INTERFACE ASSIGNMENT(=)  ! DEFINE ASSIGNMENT
        MODULE PROCEDURE SPEC_TO_SPEC
      END INTERFACE

      REAL(DP),PUBLIC :: MYTT(100) !VK TIMEDBG

      CONTAINS


      SUBROUTINE SET_PARMMOD(ICAL)

      INTEGER, INTENT(IN) :: ICAL
      INTEGER :: NGITT0 !VK
 
      NINPUT=.TRUE. !VK

      MYTT=0._DP  !VK

!PB   INCLUDE 'PARMUSR'

      IF (ICAL == 1) THEN
C
C  GEOMETRY
C
        NRAD=MAX(N1ST*N2ND*N3RD,NTRI,NTETRA)+NADD+1
        IF (NRTAL==0) NRTAL=NRAD

C  ELIMINATE SOME ARRAYS IN CASE OF LEVGEO=5 OPTION (GEOMETRY OUTSIDE EIRENE-COD
        NSWIT=1-NGEOM_USR

C  IDENTIFY: WHICH GRIDS ARE THERE? N1F=0 OR N1F=1, IF N1ST=1, OR GT 1, RESP.
        N1F=1-1/N1ST
        N2F=1-1/N2ND
        N3F=1-1/N3RD
C
        NGITT0=NGITT !VK
        IF (NGITT <= 1) NGITT=N1ST*N2ND*N3F+N1ST*N3RD*N2F+N2ND*N3RD*N1F
        NGITTP=NGITT+1
C
        NRADS=NSWIT*NRAD+(1-NSWIT)*1
        NRTALS=NSWIT*NRTAL+(1-NSWIT)*1
        N2NDPLG=NSWIT*(N2ND*N2F+NPLG*(1-N2F))+(1-NSWIT)*1
        N1STS=NSWIT*N1ST+(1-NSWIT)*1
        N2NDS=NSWIT*N2ND+(1-NSWIT)*1
        NTRIS=NSWIT*NTRI+(1-NSWIT)*1
        NKNOTS=NSWIT*NKNOT+(1-NSWIT)*1
C
C TALLIES
C
C  SPATIALLY RESOLVED SURFACE TALLIES?
        NGTSFT=NGSTAL*NGITT
        NLIMPS=NLIM+NSTS
        IF(NGITT0 <= 1) THEN !VK
          NLMPGS=NLIM+NSTS+NGTSFT*NSTS
        ELSE
          NLMPGS=NLIM+NSTS+NGTSFT
        END IF
C
C  GENERATION LIMIT TALLIES
C
        NBMAX=10
        NPTAL=30

C  PRIMARY SOURCE
        NSTRAP=NSTRA+1

C  SPECIES AND TALLIES  NTALV: TOTAL NUMBER OF VOLUME TALLIES
C                           NTALA: INDEX OF THE ADDITIONAL TRACKLENGTH
C                                  ESTIMATED TALLY
C                           NTALC: INDEX OF THE ADDITIONAL COLLISION
C                                  ESTIMATED TALLY
C                           NTALT: INDEX OF THE TIME DEP. TALLY
C                                  (SNAPSHOT ESTIMATOR)
C                           NTALM: INDEX OF THE TALLIES FOR COUPLING,
C                                  (E.G. MOMENTUM SOURCES)
C                           NTALB: INDEX OF THE BGK TALLY
C                           NTALR: INDEX OF THE ALGEBRAIC TALLY
C                       NTALS: TOTAL NUMBER OF SURFACE TALLIES
C                           NTLSA: INDEX OF THE ADDITIONAL TALLY
C                                  (TRACKLENGTH AND COLLISION ESTIMATORS
C                                   ARE IDENTICAL FOR SURFACE AVERAGES)
C                           NTLSR: INDEX OF THE ALGEBRAIC TALLY
C                       NTALI: TOTAL NUMBER OF INPUT TALLIES
C                           NTALN: INDEX OF THE ADDITIONAL INPUT TALLIES
C                           NTALO: INDEX OF THE CELL VOLUME TALLIES
C                       NTALW: TOTAL NUMBER OF SURFACE TALLIES
        NIONP=NION+1
        NATMP=NATM+1
        NMOLP=NMOL+1
        NPLSP=NPLS+1
        NPHOTP=NPHOT+1
        NADVP=NADV+1
        NADSP=NADS+1
        NCLVP=NCLV+1
        NALVP=NALV+1
        NALSP=NALS+1
        NSNVP=NSNV+1

        NTALI=17
        NTALN=12
        NTALO=14
        NTALV=100
        NTALA=57   ! NTALV-27, WITH NTALV=84
        NTALC=58   ! NTALV-26, WITH NTALV=84
        NTALT=59   ! NTALV-25, WITH NTALV=84
        NTALM=60   ! NTALV-24, WITH NTALV=84
        NTALB=61   ! NTALV-23, WITH NTALV=84
        NTALR=62   ! NTALV-22, WITH NTALV=84
        NTALS=59
        NTLSA=NTALS-2
        NTLSR=NTALS-1
        N2MX=MAX(NPHOT,NATM,NMOL,NION,NPLS,NADS,NALS)
        NSPZ=NPHOT+NATM+NMOL+NION+NPLS
        NSPZP=NSPZ+1
        NSPZMC=NPHOT+NATM+NMOL+NION


C  TOTAL NUMBER OF SURFACE AVERAGED TALLIES
C  SET IN SETPRM ACCORDING TO THE LIVING TALLIES SPECIFIED IN LIVTALS
        NSFTLP=13*NATMP+13*NMOLP+13*NIONP+13*NPHOTP+3*NPLSP+1+
     P        1*NADSP+1*NALSP+1*NSPZP

C  SURFACE REFLECTION DATA
        NHD1=12
        NHD2=7
        NHD3=5
        NHD4=5
        NHD5=5

C  ATOMIC DATA STORAGE
C  NSTORAM=0     : --> NHSTOR=0 --> NSTORDT=1,      NSTORDR=1
C  NSTORAM=1,...9: --> NHSTOR=1 --> NSTORDT=NSTORAM,NSTORDR=NRAD
        NHSTOR=1-1/(NSTORAM+1)
        NSTORDT=NHSTOR*NSTORAM+(1-NHSTOR)*1
        NSTORDR=NHSTOR*NRAD+   (1-NHSTOR)*1

! NUMBER OF TRAJECTORIES THAT CAN BE STORED
        NTRJ = 1

C
      ELSE IF (ICAL == 2) THEN

!pb        NCPV=NCOP*NPLS
        NBGV=NBGK*3
        NCPVP=NCPV+1
        NBGVP=NBGV+1
        NCOLMC=NPLS+NRDS+NREC
        N1MX=NPHOT+NATM+NMOL+NION+NPLS+NADV+NALV+NCLV+NCPV+NBGV
!PB        N1MX=MAX(NPHOT,NATM,NMOL,NION,NPLS,NADV,NALV,NCLV,NCPV,NBGV)
        NSPZTOT=NPHOT+NATM+NMOL+NION+NPLS+NADV+NALV+NCLV+NCPV+NBGV
C  TOTAL NUMBER OF VOLUME AVERAGED TALLIES
C  SET IN SETPRM ACCORDING TO LIVING TALLIES SPECIFIED IN LIVTALV
!pb        NVOLTL=6*NATM+6*NMOL+6*NION+6*NPHOT+1*NADV+1*NCLV+
!pb     P         1*NSNV+1*NCPV+1*NALV+1*NBGV+
!pb     P         4*NPLS+3*(NATM+NMOL+NION+NPHOT)+
!pb     P         NATM+NMOL+NION+NPHOT
!pb        IF (NATM > 0) NVOLTL = NVOLTL + 8
!pb        IF (NMOL > 0) NVOLTL = NVOLTL + 8
!pb        IF (NION > 0) NVOLTL = NVOLTL + 8
!pb        IF (NPHOT > 0) NVOLTL = NVOLTL + 8
        NVLTLP=6*NATMP+6*NMOLP+6*NIONP+6*NPHOTP+1*NADVP+1*NCLVP+
     P         1*NSNVP+1*NCPVP+1*NALVP+1*NBGVP+
     P         4*NPLSP+28+3*(NATMP+NMOLP+NIONP+NPHOTP)+
     P         NATMP+NMOLP+NIONP+NPHOTP+NPLSP+5+
     P         3*(NATMP+NMOLP+NIONP+NPHOTP)+4*NPLSP
CVK       NCPV_STAT=(NCPV+NPLS+2)*NSWIT+1
        NCPV_STAT=(NCPV+NPLS_TAL+2)*NSWIT+1 !VK
        NSCOP=NCPV_STAT*NRTALS
      END IF

      RETURN
      END SUBROUTINE SET_PARMMOD


      SUBROUTINE COLLECT_PARM

      INT_PARM = 0

      INT_PARM(  1) = N1ST
      INT_PARM(  2) = N2ND
      INT_PARM(  3) = N3RD
      INT_PARM(  4) = NADD
      INT_PARM(  5) = NTOR
      INT_PARM(  6) = NRTAL
      INT_PARM(  7) = NLIM
      INT_PARM(  8) = NSTS
      INT_PARM(  9) = NPLG
      INT_PARM( 10) = NPPART
      INT_PARM( 11) = NKNOT
      INT_PARM( 12) = NTRI
      INT_PARM( 13) = NTETRA
      INT_PARM( 14) = NCOORD
      INT_PARM( 15) = NOPTIM
      INT_PARM( 16) = NOPTM1

      INT_PARM( 17) = NSTRA
      INT_PARM( 18) = NSRFS
      INT_PARM( 19) = NSTEP

      INT_PARM( 20) = NATM
      INT_PARM( 21) = NMOL
      INT_PARM( 22) = NION
      INT_PARM( 23) = NPLS
      INT_PARM( 24) = NPHOT
      INT_PARM( 25) = NADV
      INT_PARM( 26) = NADS
      INT_PARM( 27) = NCLV
      INT_PARM( 28) = NSNV
      INT_PARM( 29) = NALV
      INT_PARM( 30) = NALS
      INT_PARM( 31) = NAIN
      INT_PARM( 32) = NCOP
      INT_PARM( 33) = nbgk

      INT_PARM( 34) = NSD
      INT_PARM( 35) = NSDW
      INT_PARM( 36) = NCV

      INT_PARM( 37) = NREAC
      INT_PARM( 38) = NREC
      INT_PARM( 39) = NRDS
      INT_PARM( 40) = NRCX
      INT_PARM( 41) = NREL
      INT_PARM( 42) = NRPI

      INT_PARM( 43) = NHD1
      INT_PARM( 44) = NHD2
      INT_PARM( 45) = NHD3
      INT_PARM( 46) = NHD4
      INT_PARM( 47) = NHD5
      INT_PARM( 48) = NHD6

      INT_PARM( 49) = NCHOR
      INT_PARM( 50) = NCHEN

      INT_PARM( 51) = NDX
      INT_PARM( 52) = NDY
      INT_PARM( 53) = NFL
      INT_PARM( 54) = NDXP
      INT_PARM( 55) = NDYP
      INT_PARM( 56) = NPTRGT

      INT_PARM( 57) = NPRNL


      INT_PARM( 58) = NGEOM_USR
      INT_PARM( 59) = NCOUP_INPUT
      INT_PARM( 60) = NSMSTRA
      INT_PARM( 61) = NSTORAM
      INT_PARM( 62) = NGSTAL
      INT_PARM( 63) = NRPES

      INT_PARM( 64) = NRAD
      INT_PARM( 65) = NSWIT
      INT_PARM( 66) = N1F
      INT_PARM( 67) = N2F
      INT_PARM( 68) = N3F
      INT_PARM( 69) = NGITT
      INT_PARM( 70) = NGITTP
      INT_PARM( 71) = NRADS
      INT_PARM( 72) = N2NDPLG
      INT_PARM( 73) = N1STS
      INT_PARM( 74) = N2NDS
      INT_PARM( 75) = NTRIS
      INT_PARM( 76) = NKNOTS
      INT_PARM( 77) = NRTALS

      INT_PARM( 78) = NGTSFT
      INT_PARM( 79) = NLIMPS
      INT_PARM( 80) = NLMPGS

      INT_PARM( 81) = NCPV
      INT_PARM( 82) = NBGV
      INT_PARM( 83) = NBMAX
      INT_PARM( 84) = NPTAL
      INT_PARM( 85) = NCPV_STAT
      INT_PARM( 86) = NSCOP

      INT_PARM( 87) = NSTRAP

      INT_PARM( 88) = NIONP
      INT_PARM( 89) = NATMP
      INT_PARM( 90) = NMOLP
      INT_PARM( 91) = NPLSP
      INT_PARM( 92) = NPHOTP
      INT_PARM( 93) = NADVP
      INT_PARM( 94) = NADSP
      INT_PARM( 95) = NCLVP
      INT_PARM( 96) = NALVP
      INT_PARM( 97) = NALSP
      INT_PARM( 98) = NSNVP
      INT_PARM( 99) = NCPVP
      INT_PARM(100) = NBGVP
      INT_PARM(101) = NTALI
      INT_PARM(102) = NTALN
      INT_PARM(103) = NTALO
      INT_PARM(104) = NTALV
      INT_PARM(105) = NTALA
      INT_PARM(106) = NTALC
      INT_PARM(107) = NTALT
      INT_PARM(108) = NTALM
      INT_PARM(109) = NTALB
      INT_PARM(110) = NTALR
      INT_PARM(111) = NTALS
      INT_PARM(112) = NTLSA
      INT_PARM(113) = NTLSR
      INT_PARM(114) = NTALW
      INT_PARM(115) = N1MX
      INT_PARM(116) = N2MX
      INT_PARM(117) = NSPZ
      INT_PARM(118) = NSPZP
      INT_PARM(119) = NSPZMC
      INT_PARM(120) = NCOLMC
      INT_PARM(121) = NSPZTOT

      INT_PARM(122) = NVOLTL
      INT_PARM(123) = NVLTLP
      INT_PARM(124) = NSRFTL
      INT_PARM(125) = NSFTLP


      INT_PARM(126) = NH0
      INT_PARM(127) = NH1
      INT_PARM(128) = NH2
      INT_PARM(129) = NH3

      INT_PARM(130) = NHSTOR
      INT_PARM(131) = NSTORDT
      INT_PARM(132) = NSTORDR

      INT_PARM(133) = NPLT

      INT_PARM(134) = NROT
      INT_PARM(135) = NADSPC

      INT_PARM(136) = NPLSTI
      INT_PARM(137) = NPLSV
      INT_PARM(138) = NTRJ
      INT_PARM(139) = NBACK_SPEC

      INT_PARM(140) = NPLS_TAL !VK

      RETURN
      END SUBROUTINE COLLECT_PARM


      SUBROUTINE DISTRIB_PARM

      N1ST        = INT_PARM(  1)
      N2ND        = INT_PARM(  2)
      N3RD        = INT_PARM(  3)
      NADD        = INT_PARM(  4)
      NTOR        = INT_PARM(  5)
      NRTAL       = INT_PARM(  6)
      NLIM        = INT_PARM(  7)
      NSTS        = INT_PARM(  8)
      NPLG        = INT_PARM(  9)
      NPPART      = INT_PARM( 10)
      NKNOT       = INT_PARM( 11)
      NTRI        = INT_PARM( 12)
      NTETRA      = INT_PARM( 13)
      NCOORD      = INT_PARM( 14)
      NOPTIM      = INT_PARM( 15)
      NOPTM1      = INT_PARM( 16)

      NSTRA       = INT_PARM( 17)
      NSRFS       = INT_PARM( 18)
      NSTEP       = INT_PARM( 19)

      NATM        = INT_PARM( 20)
      NMOL        = INT_PARM( 21)
      NION        = INT_PARM( 22)
      NPLS        = INT_PARM( 23)
      NPHOT       = INT_PARM( 24)
      NADV        = INT_PARM( 25)
      NADS        = INT_PARM( 26)
      NCLV        = INT_PARM( 27)
      NSNV        = INT_PARM( 28)
      NALV        = INT_PARM( 29)
      NALS        = INT_PARM( 30)
      NAIN        = INT_PARM( 31)
      NCOP        = INT_PARM( 32)
      NBGK        = INT_PARM( 33)

      NSD         = INT_PARM( 34)
      NSDW        = INT_PARM( 35)
      NCV         = INT_PARM( 36)

      NREAC       = INT_PARM( 37)
      NREC        = INT_PARM( 38)
      NRDS        = INT_PARM( 39)
      NRCX        = INT_PARM( 40)
      NREL        = INT_PARM( 41)
      NRPI        = INT_PARM( 42)

      NHD1        = INT_PARM( 43)
      NHD2        = INT_PARM( 44)
      NHD3        = INT_PARM( 45)
      NHD4        = INT_PARM( 46)
      NHD5        = INT_PARM( 47)
      NHD6        = INT_PARM( 48)

      NCHOR       = INT_PARM( 49)
      NCHEN       = INT_PARM( 50)

      NDX         = INT_PARM( 51)
      NDY         = INT_PARM( 52)
      NFL         = INT_PARM( 53)
      NDXP        = INT_PARM( 54)
      NDYP        = INT_PARM( 55)
      NPTRGT      = INT_PARM( 56)

      NPRNL       = INT_PARM( 57)


      NGEOM_USR   = INT_PARM( 58)
      NCOUP_INPUT = INT_PARM( 59)
      NSMSTRA     = INT_PARM( 60)
      NSTORAM     = INT_PARM( 61)
      NGSTAL      = INT_PARM( 62)
      NRPES       = INT_PARM( 63)

      NRAD        = INT_PARM( 64)
      NSWIT       = INT_PARM( 65)
      N1F         = INT_PARM( 66)
      N2F         = INT_PARM( 67)
      N3F         = INT_PARM( 68)
      NGITT       = INT_PARM( 69)
      NGITTP      = INT_PARM( 70)
      NRADS       = INT_PARM( 71)
      N2NDPLG     = INT_PARM( 72)
      N1STS       = INT_PARM( 73)
      N2NDS       = INT_PARM( 74)
      NTRIS       = INT_PARM( 75)
      NKNOTS      = INT_PARM( 76)
      NRTALS      = INT_PARM( 77)

      NGTSFT      = INT_PARM( 78)
      NLIMPS      = INT_PARM( 79)
      NLMPGS      = INT_PARM( 80)

      NCPV        = INT_PARM( 81)
      NBGV        = INT_PARM( 82)
      NBMAX       = INT_PARM( 83)
      NPTAL       = INT_PARM( 84)
      NCPV_STAT   = INT_PARM( 85)
      NSCOP       = INT_PARM( 86)

      NSTRAP      = INT_PARM( 87)

      NIONP       = INT_PARM( 88)
      NATMP       = INT_PARM( 89)
      NMOLP       = INT_PARM( 90)
      NPLSP       = INT_PARM( 91)
      NPHOTP      = INT_PARM( 92)
      NADVP       = INT_PARM( 93)
      NADSP       = INT_PARM( 94)
      NCLVP       = INT_PARM( 95)
      NALVP       = INT_PARM( 96)
      NALSP       = INT_PARM( 97)
      NSNVP       = INT_PARM( 98)
      NCPVP       = INT_PARM( 99)
      NBGVP       = INT_PARM(100)
      NTALI       = INT_PARM(101)
      NTALN       = INT_PARM(102)
      NTALO       = INT_PARM(103)
      NTALV       = INT_PARM(104)
      NTALA       = INT_PARM(105)
      NTALC       = INT_PARM(106)
      NTALT       = INT_PARM(107)
      NTALM       = INT_PARM(108)
      NTALB       = INT_PARM(109)
      NTALR       = INT_PARM(110)
      NTALS       = INT_PARM(111)
      NTLSA       = INT_PARM(112)
      NTLSR       = INT_PARM(113)
      NTALW       = INT_PARM(114)
      N1MX        = INT_PARM(115)
      N2MX        = INT_PARM(116)
      NSPZ        = INT_PARM(117)
      NSPZP       = INT_PARM(118)
      NSPZMC      = INT_PARM(119)
      NCOLMC      = INT_PARM(120)
      NSPZTOT     = INT_PARM(121)

      NVOLTL      = INT_PARM(122)
      NVLTLP      = INT_PARM(123)
      NSRFTL      = INT_PARM(124)
      NSFTLP      = INT_PARM(125)


      NH0         = INT_PARM(126)
      NH1         = INT_PARM(127)
      NH2         = INT_PARM(128)
      NH3         = INT_PARM(129)

      NHSTOR      = INT_PARM(130)
      NSTORDT     = INT_PARM(131)
      NSTORDR     = INT_PARM(132)

      NPLT        = INT_PARM(133)

      NROT        = INT_PARM(134)
      NADSPC      = INT_PARM(135)

      NPLSTI      = INT_PARM(136)
      NPLSV       = INT_PARM(137)
      NTRJ        = INT_PARM(138)
      NBACK_SPEC  = INT_PARM(139)


      NPLS_TAL    = INT_PARM(140) !VK

      RETURN
      END SUBROUTINE DISTRIB_PARM


      SUBROUTINE SPEC_TO_SPEC (SPECA, SPECB)

      TYPE(EIRENE_SPECTRUM), INTENT(OUT) :: SPECA
      TYPE(EIRENE_SPECTRUM), INTENT(IN) :: SPECB

      SPECA%SPCMIN  = SPECB%SPCMIN
      SPECA%SPCMAX  = SPECB%SPCMAX
      SPECA%SPCDEL  = SPECB%SPCDEL
      SPECA%SPCDELI = SPECB%SPCDELI
      SPECA%SPCINT  = SPECB%SPCINT
      SPECA%ESP_MIN = SPECB%ESP_MIN
      SPECA%ESP_MAX = SPECB%ESP_MAX
      SPECA%ESP_00  = SPECB%ESP_00
      SPECA%SPC_XPLT= SPECB%SPC_XPLT
      SPECA%SPC_YPLT= SPECB%SPC_YPLT
      SPECA%SPC_SAME= SPECB%SPC_SAME
      SPECA%SPCVX   = SPECB%SPCVX
      SPECA%SPCVY   = SPECB%SPCVY
      SPECA%SPCVZ   = SPECB%SPCVZ
      SPECA%AMIN    = SPECB%AMIN   !VK
      SPECA%AMAX    = SPECB%AMAX   !VK
      SPECA%DA    = SPECB%DA       !VK
      SPECA%IDA    = SPECB%IDA     !VK
      SPECA%SGMS    = SPECB%SGMS
      SPECA%STVS    = SPECB%STVS
      SPECA%EES     = SPECB%EES
      SPECA%NSPC    = SPECB%NSPC
      SPECA%ISPCTYP = SPECB%ISPCTYP
      SPECA%ISPCSRF = SPECB%ISPCSRF
      SPECA%IPRTYP  = SPECB%IPRTYP
      SPECA%IPRSP   = SPECB%IPRSP
      SPECA%IMETSP  = SPECB%IMETSP
      SPECA%ISRFCLL = SPECB%ISRFCLL
      SPECA%IDIREC  = SPECB%IDIREC
      SPECA%NSAN  = SPECB%NSAN     !VK
      SPECA%IA0  = SPECB%IA0       !VK
      SPECA%IA1  = SPECB%IA1       !VK
      SPECA%SPC     = SPECB%SPC
      IF (ASSOCIATED(SPECA%SDV)) THEN
        SPECA%SDV     = SPECB%SDV
        SPECA%SGM     = SPECB%SGM
      END IF
      END SUBROUTINE SPEC_TO_SPEC

      END MODULE PARMMOD
