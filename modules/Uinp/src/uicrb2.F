      subroutine uicrb2(lin,lout,iret)
      use b2mod_types
      use b2mod_layer
     , , only: ntrack, nalloys
      use eirmod_extrab25
     , , only: msrfclsx
c
c  version : 30.06.2000 21:13
c
c=======================================================================
c*** Corrects the B2 input file.
c*** Reads the file from unit LIN and writes the output into LOUT.
c***
c*** Input parameters: prepared in uinprp and passed through uinpcom.inc
c***
c*** Output parameter
c***
c***  iret:   0 means OK
c=======================================================================
c
#include "uinpcom.inc"
#include "uib2pprm.inc"
c
c*** Logical variables:
c***   uba : opening apostrophe encountered
c***   ubr : left ellipse encountered
c***   urbr: right ellipse encountered
c***   ubt : not the first field of the line
c***   ubs : a section was opened
c***   ubf : the section is to be edited (jblk > 0)
c***   lbb : the section is done
c***   lbv : the variable is to be edited (jvrb>0)
      logical uba,ubr,urbr,ubt,ubs,ubf
      integer jblk,jvrb
c
      character utb, uff*16, ufs*16, ukw*(mxkwln),
     ,          ss*(mxslen), sw*(mxslen), hh*(mxslen),
     ,           s(mxslen),  ssw(mxslen),  h(mxslen)
      equivalence (s,ss),(h,hh),(sw,ssw)
      character hlp_frm*14
      integer len_of_digits
      logical streql
      external len_of_digits, streql, subini, subend
c
c*** Possible forms of the end-of-block line
      integer nfnl
      parameter (nfnl=2)
      character ufnl(nfnl)*4
      data ufnl/'&end','/'/
c=======================================================================
      call subini ('uicrb2')
c      print *,'Starting uicrb2' !###
c*** Initial settings
c
c*** TAB code (must be treated like SPACE):
c
      utb=char(9)

      call uinprpb2
c      print *,'&&& After uinprpb2' !###

c*** jblk labels the blocks from our list, and jvrb the variables
      jblk=0
      ubs=.false.
      jvrb=0
      lbv=.false.

      write(hlp_frm,'(a,i1,a)') '(2h(a,i',len_of_digits(mxslen),',1h))'
      write(uff,hlp_frm) mxslen
      call lefta(uff,16,i)
      write(hlp_frm,'(a,i1,a)') '(1h(,i',len_of_digits(mxslen),',3ha1))'
      write(ufs,hlp_frm) mxslen
      call lefta(ufs,16,i)
c
c*** The main loop starts here: read the next line until end of file
c*** The following assumptions are made during line parsing:
c***  - namelist identifiers and terminators are on separate lines;
c***  - keywords are terminated by either '(' or '=' (disregarding spaces);
c***  - comma outside the ellipses or apostrophes separates the values
c
c      print *,'&&& Before *10' !###
 10   read(lin,uff,end=90) ss
c
c*** and squeeze and lowercase it for the quick analysis
c
      call locase(ss,sw,mxslen)
      do i=1,mxslen !{
        if(streql(ssw(i),utb)) ssw(i)=' '
      end do !}
      call lefta(sw,mxslen,i)
c
c*** If the string is empty, just write it and read the next
c
      if(i.eq.0) then !{
        call uisswr(lout,s,ss,mxslen,ufs)
        go to 10
      end if !}
c
c*** Is it a namelist section terminator?
c
      do i=1,nfnl !{
        if(sw.eq.ufnl(i)) then !{
c          print *,'&&& ',ufnl(i),' ubf,lbb,lbv= ',ubf,lbb,lbv !###
c*** Yes. Are we working on this section?
          if(ubf) then !{
c*** Not done yet?
            if(.not.lbb) then !{
c*** No. Variable in work?
              if(lbv) then !{
                call uimdvr(lout,jblk,jvrb,ufs)
c*** Is the section done now?
                if(lbb) go to 15
              end if !}
            end if !}
c*** Not yet. Proceed with the variables still left to be modified
            do j=1,nkwrd !{
              if(chrpl(j,jblk).ne.' ' .and. .not.lbmdf(j,jblk))
     -         call uimdvr(lout,jblk,j,ufs)
            end do !}
            if(.not.lbb) then !{
              write(0,*) 'Unexpected error in uicrb2: unable to ',
     ,          'complete the block ',jblk,' : ',chrbl(jblk)
              iret =8
              goto 9990
            end if !}
          end if !}
c*** The section is done. Reset the pointer and flags and write the line
 15       jblk=0
          ubs=.false.
          ubf=.false.
          call uisswr(lout,s,ss,mxslen,ufs)
          go to 10  ! -> read the next line
        end if !}
      end do !}
c      print *,'&&& do i=1,nfnl done' !###

c*** Not a section terminator. Namelist identifier?

      if(ssw(1).eq.'&') then !{
c        print *,'&&& ',sw(1:len_trim(sw)),':  ubs= ',ubs !###
c*** Is a section still open?
        if(ubs) then !{
          write(0,*) 'Error in the input file: ',
     ,                 'no section terminator before  ',sw
          iret=1
          goto 9990
        end if !}

        ubs=.true.

c*** Should we look at this section? If yes, then set the flags
        ubf=.false.
        do i=1,nblck !{
          if(chrbl(i).ne.' ' .and. sw.eq.chrbl(i)) then !{
            jblk=i
            ubf=.true.
            lbb=.false.
c            print *,'&&&  ==> check it' !###
            go to 20
          end if !}
        end do !}
 20     call uisswr(lout,s,ss,mxslen,ufs)
        go to 10  ! -> read the next line
      end if !}

c*** Just a regular line. Are we not editing the block?
      if(.not.ubf) then !{
        call uisswr(lout,s,ss,mxslen,ufs)
        go to 10  ! -> read the next line
      end if !}
c      print *,'&&& regular line' !###

c*** Unfortunately, we are.
c*** Parse the string, looking for the specified keywords and separators
c*** like ' ' ( ) = ,

c*** Below, k counts bytes in the current field,
c***        kb keeps the position of the last delimiter,
c***        hh accumulates the potential keywords
 40   k=0
      kb=0
      hh=' '
      uba=.false.
      ubr=.false.
      urbr=.false.
      ubt=.false.
      do 100 i=1,mxslen !{

c*** Skip spaces and text variables
        if(s(i).eq.'''') then !{
          if(urbr) then !{
          end if !}
          uba=.not.uba
          go to 100 ! -> fetch the next character
        end if !}
        if(streql(s(i),' ') .or. streql(s(i),utb) .or. uba) go to 100

c*** Look for a delimiter

        if(streql(s(i),'=')) then !{

c*** The equal sign closes a keyword. Is any modification pending?

          urbr=.false.
          if(lbv) then !{
            call uimdvr(lout,jblk,jvrb,ufs)
c*** Is it the first field of the line?
            if(kb.gt.0) then !{
c*** No. Split the line and recurse
              call bsend(s(kb+1),s(2),mxslen-kb)
              call bfill(s(mxslen-kb+2),kb-1,' ')
              s(1)=' '
              if(streql(ss,' ')) go to 10 ! line empty -> read the next (?)
              go to 40 ! -> restart parsing the line
            end if !}
          end if !}

c*** Consider the new found keyword. Should we edit this variable?
          call locase(hh,hh,mxkwln)
          jvrb=0
          do j=1,nkwrd !{
            call locase(chrpl(j,jblk),ukw,mxkwln)
            lbv = .not.streql(ukw,' ') .and. streql(ukw,hh)
            if(lbv) then !{
c*** Yes. Set the pointer 
              jvrb=j

c              kp=0
c              nprm=nmdpr(j,jblk)

              if(ubt) then !{
c*** split the line before the keyword
                call uisswr(lout,s,ss,kb,ufs)
              end if !}
              go to 50
            end if !}
          end do !}
c*** Reset the field
 50       hh=' '
          k=0
          go to 100 ! -> fetch the next character

        else if(streql(s(i),'(')) then !}{

          if(urbr) go to 92 ! -> error

c*** Left ellipse - array definition?
          if(ubr) then !{
            write(0,*) 'Error in the input file: double left ellipse'
            write(0,*) ss
            iret=2
            goto 9990
          end if !}
          ubr=.true.

        else if(streql(s(i),')')) then !}{

c*** Right ellipse - array definition?
          if(.not.ubr) then !{
            write(0,*) 'Error in the input file: unmatched ellipse'
            write(0,*) ss
            iret=2
            goto 9990
          end if !}
          ubr=.false.
          urbr=.true.

        else if(.not.ubr .and. streql(s(i),',')) then !}{

          if(urbr) go to 92 ! -> error

c*** The comma closes a value. 
          kb=i
          ubt=.true.
          hh=' '
          k=0
c          if(lbv) then !{
c            kp=kp+1
c            if(kp.ge.nprm) then !{
c              ubt=.false.
c              call uimdvr(lout,jblk,jvrb,ufs)
cc
cc*** Split the line and recurse
cc
c              call bsend(s(kb+1),s(2),mxslen-kb)
c              s(1)=' '
c              call bfill(s(mxslen-kb+2),kb-1,' ')
c              if(streql(ss,' ')) go to 10
c              go to 40
c            end if !}
c          end if !}

        else !}{

c*** Some other symbol

          if(urbr) go to 92 ! -> error

          if(.not.ubr) then !{
            k=k+1
            h(k)=s(i)
          end if !}
        end if !}
 100  continue !}
 
c*** Line is over. Write it if not in work and go for the next one.
 
      if(.not.lbv) call uisswr(lout,s,ss,mxslen,ufs)
      go to 10
c-----------------------------------------------------------------------
c*** The input file is over
c
 90   iret=0
c      print *,'*90: leaving uicrb2' !###
 9990 call subend ()
      return
c=======================================================================
 92   write(0,*) 'Error in the input file: a symbol between ) and ='
      write(0,*) ss
      iret=2
      return
c=======================================================================
      end
