c  VERSION : 14.08.2003 23:15

#include "DIMENSIONS.F"

c*** The numbers of input blocks and variables to work on in one block
      integer, parameter :: nblck=7, nkwrd=38, nnmdf=nblck*nkwrd

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
      character*8 c8niprm(nmxprm,nmxlyr,nmxblk,nkwrd,nblck)
 
c*** Logical variables:
c***  lbb     : the block is done
c***  lbv     : the variable is to be edited
c***  lbmdf   : the corresponding variable is done
c***  lbusr   : the "user" section is to be modified
c***  ltrvr   : the corresponding variable is text
c***  lt8rvr  : the corresponding variable is text*8
c***  lrrvr   : the corresponding variable is real
c***  lspvr   : the corresponding variable is species-dependent
c***  lprdckw : produce the corresponding line 

      logical lbb,lbv,lbusr,
     ,  lbmdf(nkwrd,nblck),ltrvr(nkwrd,nblck),lt8rvr(nkwrd,nblck),
     ,  lrrvr(nkwrd,nblck),lprdckw(nmxlyr,nmxblk,nkwrd,nblck),
     ,  lspvr(nkwrd,nblck)

      common/uib2il/rniprm,iniprm,nmdbr,nmdlr,nmdpr,
     ,  lbb,lbv,lbmdf,lbusr,ltrvr,lt8rvr,lrrvr,lprdckw,lspvr
      common/uib2ch/chrbl,chrpl,cniprm,c8niprm
