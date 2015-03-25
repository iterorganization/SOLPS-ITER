      subroutine crrinf(lin,lout)
c
c  version : 09.05.95 16:29
c
c=====================================================
c*** Corrects the SONNET input file.
c*** Reads the file from unit LIN and writes the output into LOUT.
c***
c*** Presently, corrects only the target geometry and grid spacing
c
#include "sonparm.inc"
c
c*** the number of keywords to be worked on
      parameter (nrpl=7)
c
c*** and the number of columns in the grid data
      parameter (ngclm=3)
      character urpl(nrpl)*80, ss*80, hh*80, s(80), h(80), utb
      logical ubf,ubs
      equivalence (s,ss),(h,hh)
c
c*** the list of keywords to be worked on:
c
      data urpl / 'leftLowerFace', 'rightLowerFace', 'outerFlux',
     ,    'centeredFlux', 'targetToLowerXPoint', 'lowerXPointToXPoint',
     ,    'lowerXPointToTarget' /
c=====================================================
c*** TAB code (must be treated like SPACE):
      utb=char(9)
c*** ubs=.TRUE. means "skip this old line" (after replacement)
      ubs=.false.
c
c*** read the next line
c
 10   read(lin,'(a80)',end=90) ss
c*** ubf = .TRUE. means that no keyword has yet been opened
      ubf=.true.
      if(ubs) then
          if(ss.eq.' ') then
              ubs=.false.
              go to 85
          end if
          go to 10
      end if
      if(ss.eq.' ') go to 85
c
c*** parse the string, looking for the specified keywords
c
      k=0
      hh=' '
      do 100 i=1,80
          if(s(i).eq.' ' .or. s(i).eq.utb) go to 100
          if(ubf) then
              if(s(i).eq.'(') then
c*** the left ellipse opens a keyword...
                  ubf=.false.
                  go to 100
              else
                  go to 85
              end if
          else if(s(i).eq.')') then
c*** and the rigth one closes it
              go to 20
          end if
          k=k+1
          h(k)=s(i)
 100  continue
c
c*** Something is wrong: no right ellipse (a keyword left open)
c
      go to 95
c
c*** Look whether the keyword we found needs an action
c
 20   continue
      do 1000 i=1,nrpl
          if(hh.eq.urpl(i)) go to (210,220,230,240,250,260,270),i
 1000 continue
c*** ... no!
      go to 85
c-----------------------------------------------------
c*** Target surfaces:
c
c*** Inner target
c
 210  l=1
 212  n=nmtrg(l)
      if(n.gt.0) then
          write(lout,*) '  (',(h(i),i=1,k),')   ',(rztg(i,1,l),i=1,2)
          do 216 j=2,nmtrg(l)
              write(lout,*) '               ',(rztg(i,j,l),i=1,2)
 216      continue
          ubs=.true.
          go to 10
      else
          go to 85
      end if
c
c*** Outer target
c
 220  l=2
      go to 212
c-----------------------------------------------------
c*** Flux values for the radial mesh:
c
c*** Outer SOL
c
 230  l=2
c
 232  n=nmlvl(l)
      if(n.le.0) go to 85
c
c*** there is some data to replace the data in the template
c
      m=min0(2,n)
      write(lout,*) '  (',(h(i),i=1,k),')   ',(flvl(i,l),i=1,m)
      ib=m+1
 234  do 236 j=1,n
          if(ib.gt.n) go to 238
          ie=min0(ib+ngclm-1,n)
          write(lout,*) '     ',(flvl(i,l),i=ib,ie)
 236  ib=ie+1
c
c*** the centered flux in the main plasma and private flux go together
c
 238  if(l.le.2) then
          ubs=.true.
          go to 10
      end if
c
c*** we have just finished with the private flux region and must now
c*** repeat the same with the main plasma
c
      l=1
      ib=1
      n=nmlvl(l)
      if(n.le.0) go to 85
      go to 234
c
c*** Centered flux - the private flux region goes first
c
 240  l=3
      go to 232
c-----------------------------------------------------
c*** Relative arclengths for the poloidal mesh
c
c*** The inner divertor leg
 250  l=2
 252  n=nmarc(l)
      if(n.gt.0) then
c
c*** there is some data to replace the data in the template
c
          m=min0(2,n)
          write(lout,*) '  (',(h(i),i=1,k),')   ',(arcln(i,l),i=1,m)
          ib=m+1
          do 256 j=1,n
              if(ib.gt.n) go to 258
              ie=min0(ib+ngclm-1,n)
              write(lout,*) '          ',(arcln(i,l),i=ib,ie)
 256      ib=ie+1
c
 258      ubs=.true.
          go to 10
      else
c
c*** We have nothing to do...
c
          go to 85
      end if
c
c*** SOL around the main plasma
c
 260  l=1
      go to 252
c
c*** outer divertor leg
c
 270  l=3
      go to 252
c-----------------------------------------------------
c*** write the line as it is
c
 85   if(ss.eq.' ') then
          write(lout,*)
      else
          do 185 k=80,1,-1
              if(s(k).ne.' ') go to 88
 185      continue
 88       write(lout,'(80a1)') (s(i),i=1,k)
      end if
      go to 10
c-----------------------------------------------------
c*** the template file is over
c
 90   return
c-----------------------------------------------------
c*** Bad template
c
 95   print *,' Wrong format of SONNET input file: no right parenthesis'
      print *,hh
      return
c=====================================================
      end
