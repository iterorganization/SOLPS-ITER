      integer function igivelun(l0,l1,lex,nl)

c  version : 10.12.2002 23:30

c*** This function returns a free LUN for i/o in the range from l0 to l1
c*** lex contains reserved numbers (nl) to be excluded from search

      integer lex(*)
      logical op

      do i=l0,l1 !{
        inquire(unit=i,opened=op)
        if(.not.op) then !{
          do j=1,nl !{
            op= op .or. i.eq.lex(j)
          end do !}
          if(.not.op) then !{
            igivelun=i
            return
          end if !}
        end if !}
      end do !}
      igivelun=-1

      end
