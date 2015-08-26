c
c  version : 16.11.2003 22:27
c
c*** Common data for b2plot input
c======================================================================
c*** iunoo  : output unit
c*** iunii  : input unit
c*** ufnlen : max. length of the input text (limited by import routine)
      integer iunoo,iunii,ufnlen
      parameter (iunoo=2, iunii=1, ufnlen=32)
#include "COUPLE/KOPPLDIM.F"
c
      integer nubslp, nubsli, nubchrdx
      parameter (nubslp=10, nubsli=10, nubchrdx=500)
      integer nnvsle, nmvsle(nlim), nubchrd,
     ,  nubnpnt(nubslp), nubnpni(nubsli),
     ,  lubchrdp(nubchrdx,nubslp),  lubchrdi(nubchrdx,nubsli),
     ,  nubchrdp(nubslp),  nubchrdi(nubsli),
     ,  lublbli(nubchrdx), lublblp(nubchrdx)
      real ubchrds(4,nubchrdx), pp1(3,DEF_NLIM), pp2(3,DEF_NLIM),
     ,  angchrdp(nubchrdx),  angchrdi(nubchrdx)
      character*(ufnlen) cublbli(nubsli), cublblp(nubslp)
      common/ub2pcom/pp1, pp2, ubchrds, angchrdp, angchrdi,
     i  nnvsle, nmvsle, nubchrd, nubnpnt, nubnpni,
     i  lubchrdp, lubchrdi, nubchrdp, nubchrdi, lublbli, lublblp
      common/ub2pcoma/cublbli, cublblp
c======================================================================
c*** nubslp   : max. number of groups of chords for line profiles
c*** nubsli   : max. number of groups of chords for line integrals
c*** nubchrdx : max. number of chords
c*** nnvsle   : number of segments in the vessel data
c*** nmvsle   : list of segments for the vessel data
c*** nubchrd  : actual number of chords
c*** nubnpnt  : number of points along each line for the line profiles
c*** lubchrdp : lists of chords for each group for the line profiles
c*** lubchrdi : lists of chords for each group for the line integrals
c*** nubchrdp : lengths of the lists of chords for the line profiles
c*** nubchrdi : lengths of the lists of chords for the line integrals
c*** lublbli  : chord labels for the line integrals
c*** lublblp  : chord labels for the line profiles
c*** pp1, pp2 : coordinates of the end points of the segments (R, Z, 0)
c*** ubchrds  : coordinates of the chord ends (R1, Z1, R2, Z2)
c*** cublbli  : set identifiers for the line integrals
c*** cublblp  : set identifiers for the line profiles
