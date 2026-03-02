! Simple program to replace nc2text (for the needs of SOLPS-ITER scripts only!)
!
! Variables in all caps should be from netcdf.inc
!
! JDL
Program nc2text_simple
  Implicit None
#ifndef NO_CDF
#  include <netcdf.inc>

  Logical :: debug = .false.

  Integer, Parameter :: R8 = Selected_real_kind(15,307)
  Integer, Parameter :: I8 = Selected_int_kind(8)

  Integer :: ncid, iret, varid, nvdims, vartyp, dimids(MAXVDIMS), numcmdarg
  Integer(I8) :: i, j, k, i1=1, i2=0, j1=1, j2=0, k1=1, k2=0, itmp
  Logical :: use_index = .false.
  Integer, Allocatable  :: dimlen(:)
  Real(R8), Allocatable :: rdata(:,:,:)
  Character(LEN = 20) :: hlp_frm
  Character(Len = 256) :: filename, varname
  Character(Len = MAXNCNAM) :: dimnam
  !-----------------------------------------------------------------------------
  ! Handle command line args
  iret = handle_cmd_arg()
  If (iret .ne. 0) Stop

  ! Open
  If (debug) Write(0,*) 'Opening file: ',Trim(filename)
  iret = NF_OPEN(Trim(filename),NF_NOWRITE,ncid)
  If (iret .ne. 0) Then
     Write(0,*) 'Error: Could not open ',Trim(filename)
     Stop
  Endif

  ! Inquire varid
  If (debug) Write(0,*) 'Inquiring on variable: ',Trim(varname)
  iret = NF_INQ_VARID(ncid,varname,varid)
  If (iret .ne. 0) Then
     Write(0,*) 'Error: Did not find variable ''',Trim(varname),''' in ',Trim(filename)
     Stop
  Endif

  ! Check dim and read lengths
  iret = NF_INQ_VARDIMID(ncid,varid,dimids)
  iret = NF_INQ_VARNDIMS(ncid,varid,nvdims)
  If (debug) Write(0,'(a,i0,a)') ' Variable has ',nvdims,' dimension(s)'
  Allocate(dimlen(nvdims))
  Do i = 1,nvdims
     iret = NF_INQ_DIM(ncid,dimids(i),dimnam,dimlen(i))
  Enddo
  If (debug) Write(0,*) ' Variable dimensions: ', dimlen

  ! Check type (only double currently supported), allocate and read
  iret = NF_INQ_VARTYPE(ncid,varid,vartyp)
  If (debug) Write(0,*) ' Variable type: ', vartyp
  Select Case (vartyp)
  Case (NCDOUBLE)
     Select Case (nvdims)
     Case (0)
        Allocate(rdata(1,1,1))
        i1 = 1
        i2 = 1
        j1 = 1
        j2 = 1
        k1 = 1
        k2 = 1
     Case (1)
        Allocate(rdata(dimlen(1),1,1))
        itmp = i1
        i1 = j1
        j1 = itmp
        itmp = i2
        i2 = j2
        j2 = itmp
        k1 = 1
        k2 = 1
     Case (2)
        Allocate(rdata(dimlen(1),dimlen(2),1))
        k1 = 1
        k2 = 1
     Case (3)
        Allocate(rdata(dimlen(1),dimlen(2),dimlen(3)))
     Case Default
        Write(0,*) "Error: Only scalars, 1-, 2-, or 3-dimensional arrays supported"
        Stop
     End Select
     iret = NF_GET_VAR_DOUBLE(ncid,varid,rdata)
     If (debug) Write(0,*) ' Type is real'
  Case Default
     Write(0,*) 'Error: type does not appear to be double ', vartyp
  End Select
  If (iret .ne. 0) Then
     Write(0,*) 'Error: Could not read variable ''',Trim(varname),''' from ',Trim(filename)
     Stop
  Endif

  ! Handle negative indexing
  If (i1 .le. 0) i1 = Size(rdata,1) + i1
  If (i2 .le. 0) i2 = Size(rdata,1) + i2
  If (j1 .le. 0) j1 = Size(rdata,2) + j1
  If (j2 .le. 0) j2 = Size(rdata,2) + j2
  If (k1 .le. 0) k1 = Size(rdata,3) + k1
  If (k2 .le. 0) k2 = Size(rdata,3) + k2
  itmp = i1
  i1 = Min(i1,i2)
  i2 = Max(itmp,i2)
  itmp = j1
  j1 = Min(j1,j2)
  j2 = Max(itmp,j2)
  itmp = k1
  k1 = Min(k1,k2)
  k2 = Max(itmp,k2)
  If (debug) Write(0,'(a,i0,a,i0,a,i0,a,i0,a,i0,a,i0,a)') ' Subscripts processed to (',i1,':',i2,',',j1,':',j2,',',k1,':',k2,')'

  ! Check dimensions
  If( (i2 .gt. Size(rdata,1)) .OR. (j2 .gt. Size(rdata,2)) .OR. (k2 .gt. Size(rdata,3)) .OR. &
       (i1 .le. 0) .OR. (j1 .le. 0) .OR. (k1 .le. 0) ) Then
     Write(0,*) "Error: index out of bounds"
     Write(0,*) "Size is ",dimlen
     Write(0,'(a,i0,a,i0,a,i0,a,i0,a)') ' Subscripts processed to (',i1,':',i2,',',j1,':',j2,',',k1,':',k2,')'
     Stop
  Endif

  ! Output
  Write(hlp_frm,'(a,i8,a)') '(1p,',i2-i1+1,'e18.10)'
  Do k = k1, k2
     Do j = j1, j2
        Write(*,hlp_frm) (rdata(i,j,k), i=i1, i2)
     End Do
  End Do

  Deallocate(rdata)
  Deallocate(dimlen)
  !-----------------------------------------------------------------------------

Contains

  Function handle_cmd_arg() Result(ierr)
    Integer :: ierr, ioerr
    Character(Len = 32)  :: arg
    Character(Len = 256) :: temp, temp2
    Integer :: numcols = -1 ! This can be set but is ignored
    ierr = -1
    numcmdarg = Command_argument_count()
    Select Case (numcmdarg)
    Case (1)
       Call Get_command_argument(1,arg)
       Select Case (arg)
       Case ('-h','--help')
          Call Print_help()
          ierr = 1
          Return
       Case Default
          Write(0,*) 'Error: Must provide filename and variable'
          ierr = 1
          Return
       End Select
    Case (2)
       Call Get_command_argument(1,filename)
       Call Get_command_argument(2,varname)
    Case (4)
       Call Get_command_argument(1,arg)
       Select Case (arg)
       Case ('-n')
          Call Get_command_argument(2,arg)
          Read(arg,'(I10)') numcols
       Case Default
          Write(0,*) 'Error: Invalid syntax'
          Call Print_help()
          ierr = 1
          Return
       End Select
       Call Get_command_argument(3,filename)
       Call Get_command_argument(4,varname)
    Case Default
       Write(0,*) 'Error: Invalid syntax'
       Call Print_help()
       ierr = 1
       Return
    End Select

    ! Check for subscripts in argument
    If (debug) Write(0,*) "Checking for subscripts"
    If (Index(varname,'(') .ne. 0) Then
       use_index = .true.

       ! Now check if there are multiple dimensions specified (look for comma)
       If (debug) Write(0,*) "--Found a '(', attempting to get subscripts"
       If (Index(varname,',') .eq. 0) Then

          ! There is no comma, get single dimension
          If (debug) Write(0,*) "--Single subscript dimension identified"

          ! Check for semicolon for range
          If (Index(varname,':') .eq. 0) Then
             ! No range, get single value
             If (debug) Write(0,*) "--Single value identified"
             temp = varname(Index(varname,'(')+1:Index(varname,')')-1)
             Read(temp,'(I10)') j1
             j2 = j1
             If (debug) Write(0,*) "--Single subscript found:",j1
          Else
             ! Range found, get two values.
             If (debug) Write(0,*) "--Range identified"
             temp = varname(Index(varname,'(')+1:Index(varname,':')-1)
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)',iostat=ioerr) j1
             temp = varname(Index(varname,':')+1:Index(varname,')')-1)
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') j2
             If (debug) Write(0,*) "--Range found:",j1,j2
          Endif
          i1 = 1
          i2 = 0

       ElseIf (CountOccurrences(varname, ',') == 1) Then

          ! There is one comma, look for two dimensions
          If (debug) Write(0,*) "--Found one ',', attempting to get two dimensions"

          ! Check for semicolon in first dimension
          temp = varname(Index(varname,'(')+1:Index(varname,',')-1)
          If (Index(temp,':') .eq. 0) Then
             If (debug) Write(0,*) "--Single value identified in dim1"
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') i1
             If (debug) Write(0,*) "--Single subscript found:",i1
             i2 = i1
          Else
             If (debug) Write(0,*) "--Range identified in dim1"
             temp2 = temp(1:Index(temp,':')-1)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i1
             temp2 = temp(Index(temp,':')+1:)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i2
             If (debug) Write(0,*) "--Range found:",i1,i2
          Endif

          ! Check for semicolon in second dimension
          temp = varname(Index(varname,',')+1:Index(varname,')')-1)
          If (Index(temp,':') .eq. 0) Then
             If (debug) Write(0,*) "--Single value identified in dim2"
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') j1
             If (debug) Write(0,*) "--Single subscript found:",j1
             j2 = j1
          Else
             If (debug) Write(0,*) "--Range identified in dim2"
             temp2 = temp(1:Index(temp,':')-1)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j1
             temp2 = temp(Index(temp,':')+1:)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j2
             If (debug) Write(0,*) "--Range found:",j1,j2
          Endif

       ElseIf (CountOccurrences(varname, ',') == 2) Then

         ! There are two commas, look for three dimensions
         If (debug) Write(0,*) "--Found two ',', attempting to get three dimensions"

         ! Check for semicolon in first dimension
         temp = varname(Index(varname,'(')+1:Index(varname,',')-1)
         If (Index(temp,':') .eq. 0) Then
            If (debug) Write(0,*) "--Single value identified in dim1"
            If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') i1
            If (debug) Write(0,*) "--Single subscript found:",i1
            i2 = i1
         Else
            If (debug) Write(0,*) "--Range identified in dim1"
            temp2 = temp(1:Index(temp,':')-1)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i1
            temp2 = temp(Index(temp,':')+1:)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i2
            If (debug) Write(0,*) "--Range found:",i1,i2
         Endif

         ! Check for semicolon in second dimension
         temp = varname(Index(varname,',')+1:Index(varname,',')+Index(varname(Index(varname,',')+1:),',')-1)
         If (Index(temp,':') .eq. 0) Then
            If (debug) Write(0,*) "--Single value identified in dim2"
            If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') j1
            If (debug) Write(0,*) "--Single subscript found:",j1
            j2 = j1
         Else
            If (debug) Write(0,*) "--Range identified in dim2"
            temp2 = temp(1:Index(temp,':')-1)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j1
            temp2 = temp(Index(temp,':')+1:)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j2
            If (debug) Write(0,*) "--Range found:",j1,j2
         Endif

         ! Check for semicolon in third dimension
         temp = varname(Index(varname,',')+Index(varname(Index(varname,',')+1:),',')+1:Index(varname,')')-1)
         If (Index(temp,':') .eq. 0) Then
            If (debug) Write(0,*) "--Single value identified in dim3"
            If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') k1
            If (debug) Write(0,*) "--Single subscript found:",k1
            k2 = k1
         Else
            If (debug) Write(0,*) "--Range identified in dim3"
            temp2 = temp(1:Index(temp,':')-1)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') k1
            temp2 = temp(Index(temp,':')+1:)
            If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') k2
            If (debug) Write(0,*) "--Range found:",k1,k2
         Endif

       Endif
       varname = varname(1:Index(varname,'(')-1)
    Endif
    ierr = 0
    Return
  End Function handle_cmd_arg
  !-----------------------------------------------------------------------------

  function CountOccurrences(string, char) result(count)
    character(len=*) :: string
    character(len=1) :: char
    integer :: count, i

    count = 0
    do i = 1, len(string)
        if (string(i:i) == char) then
            count = count + 1
        end if
    end do
   end function CountOccurrences
  !-----------------------------------------------------------------------------

  Subroutine Print_help()
    Write(0,'(a)') ' '
    Write(0,'(a)') 'usage: nc2text_simple [OPTIONS] filename variable(i1:i2,j1:j2,k1:k2)'
    Write(0,'(a)') ' '
    Write(0,'(a)') 'Outputs variable from netcdf file'
    Write(0,'(a)') ' '
    Write(0,'(a)') '   OPTION -n #, number of columns to display data in. This arg accepted but ignored for compatibility'
    Write(0,'(a)') ' '
    Write(0,'(a)') "   Optional syntax 'variable(i1:i2,j1:j2,k1:k2)' can return a range"
    Write(0,'(a)') ' '
    Write(0,'(a)') '   Missing i1..j2 will evaluate as array bounds'
    Write(0,'(a)') '   Ranges start from 1'
    Write(0,'(a)') '   Zero or regative subscripts count from end of array'
    Write(0,'(a)') ' '
    Write(0,'(a)') 'Current restrictions: only scalars, 1D, 2D and 3D arrays of type double supported'
    Write(0,'(a)') ' '
    Write(0,'(a)') 'Examples:'
    Write(0,'(a)') '   nc2text_simple b2time.nc tesepa'
    Write(0,'(a)') '   nc2text_simple -n 999999 b2time.nc tesepa'
    Write(0,'(a)') "   nc2text_simple b2time.nc 'tesepa(1)'"
    Write(0,'(a)') "   nc2text_simple b2time.nc 'ne3da(:,-9:-0)'"
    Write(0,'(a)') "   nc2text_simple b2time.nc 'fn3dl(:,2,-9:-0)'"

    Return
  End Subroutine Print_help

#endif


End Program nc2text_simple
