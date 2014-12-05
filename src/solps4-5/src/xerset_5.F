      subroutine xerset_5 (nprt)
      use b2mod_types
      implicit none
      integer nprt, nprt1
*     ------------------------------------------------------------------
*     XERSET_5 sets the unit number for error messages.
*     XERGET_5 gets the unit number for error messages.
*     ------------------------------------------------------------------
      integer npdflt, npsave
      parameter (npdflt=0)
      save npsave
*     npdflt is the default unit number.
*     npsave is the designated unit number.
      data npsave/npdflt/
*     ------------------------------------------------------------------
*     This routine is used to specify a unit number for output from the
*     routine xerrab and from other error handling routines. If xerset
*     is called with a zero or positive argument nprt, then the error
*     handling routines will use unit number nprt.
*     If xerset_5 is never called, or is called with a negative argument,
*     then a default unit number will be used.
*     A call to the alternate entry xerget_5 returns the unit number to
*     be used for output by the error handling routines.
*     ------------------------------------------------------------------
      if (0.le.nprt) then
       npsave = nprt
      else
       npsave = npdflt
      endif
      return
*     ------------------------------------------------------------------
      entry xerget_5 (nprt1)
      nprt1 = npsave
      return
*     ------------------------------------------------------------------
      end
