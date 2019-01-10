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
  Integer(I8) :: i, j, i1=1, i2=0, j1=1, j2=0, itmp
  Logical :: use_index = .false.
  Integer, Allocatable  :: dimlen(:)
  Real(R8), Allocatable :: rdata(:,:)
  Character(Len = 256) :: filename, varname
  Character(Len = MAXNCNAM) :: dimnam
  !-----------------------------------------------------------------------------
  ! Handle command line args
  iret = handle_cmd_arg()
  If (iret .ne. 0) Return

  ! Open
  If (debug) Write(*,*) 'Opening file: ',Trim(filename)
  iret = NF_OPEN(Trim(filename),NCWRITE,ncid)
  If (iret .ne. 0) Then
     Write(*,*) 'Error: Could not open ',Trim(filename)
     Return
  Endif

  ! Inquire varid
  If (debug) Write(*,*) 'Inquiring on variable: ',Trim(varname)
  iret = NF_INQ_VARID(ncid,varname,varid)
  If (iret .ne. 0) Then
     Write(*,*) 'Error: Did not find variable ''',Trim(varname),''' in ',Trim(filename)
     Return
  Endif

  ! Check dim and read lengths
  iret = NF_INQ_VARDIMID(ncid,varid,dimids)
  iret = NF_INQ_VARNDIMS(ncid,varid,nvdims)
  If (debug) Write(*,'(a,i0,a)') ' Variable has ',nvdims,' dimension(s)'
  Allocate(dimlen(nvdims))
  Do i = 1,nvdims
     iret = NF_INQ_DIM(ncid,dimids(i),dimnam,dimlen(i))
  Enddo
  If (debug) Write(*,*) ' Variable dimensions: ', dimlen

  ! Check type (only double supported), allocate and read
  iret = NF_INQ_VARTYPE(ncid,varid,vartyp)
  If (debug) Write(*,*) ' Variable type: ', vartyp
  Select Case (vartyp)
  Case (NCDOUBLE)
     Select Case (nvdims)
     Case (1)
        Allocate(rdata(dimlen(1),1))
     Case (2)
        Allocate(rdata(dimlen(1),dimlen(2)))
     Case Default
        Write(*,*) "Error: Only 1 and 2 dimensional arrays supported"
        Return
     End Select
     iret = NF_GET_VAR(ncid,varid,rdata)
     If (debug) Write(*,*) ' Type is real'
  Case Default
     Write(*,*) 'Error: type does not appear to be double ', vartyp
  End Select
  If (iret .ne. 0) Then
     Write(*,*) 'Error: Could not read variable ''',Trim(varname),''' from ',Trim(filename)
     Return
  Endif

  ! Handle negative indexing
  If (i1 .le. 0) i1 = Size(rdata,1) + i1
  If (i2 .le. 0) i2 = Size(rdata,1) + i2
  If (j1 .le. 0) j1 = Size(rdata,2) + j1
  If (j2 .le. 0) j2 = Size(rdata,2) + j2
  itmp = i1
  i1 = Min(i1,i2)
  i2 = Max(itmp,i2)
  itmp = j1
  j1 = Min(j1,j2)
  j2 = Max(itmp,j2)
  If (debug) Write(*,'(a,i0,a,i0,a,i0,a,i0,a)') ' Subscripts processed to (',i1,':',i2,',',j1,':',j2,')'

  ! Check dimensions
  If( (i2 .gt. Size(rdata,1)) .OR. (j2 .gt. Size(rdata,2)) .OR. &
       (i1 .le. 0) .OR. (j1 .le. 0) ) Then     
     Write(*,*) "Error: index out of bounds"
     Write(*,*) "Size is ",dimlen
     Write(*,'(a,i0,a,i0,a,i0,a,i0,a)') ' Subscripts processed to (',i1,':',i2,',',j1,':',j2,')'
     Return
  Endif

  ! Output
  Do j = j1,j2
     Do i = i1,i2
        Write(*,'(e18.10)',advance="no") rdata(i,j)
     Enddo
     Write(*,*) ' '
  Enddo
  
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
          Write(*,*) 'Error: Must provide filename and variable'
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
          Write(*,*) 'Error: Invalid syntax'
          Call Print_help()
          ierr = 1
          Return 
       End Select
       Call Get_command_argument(3,filename)
       Call Get_command_argument(4,varname)
    Case Default
       Write(*,*) 'Error: Invalid syntax'
       Call Print_help()
       ierr = 1
       Return 
    End Select

    ! Check for subscripts in argument
    If (debug) Write(*,*) "Checking for subscripts"
    If (Index(varname,'(') .ne. 0) Then
       use_index = .true.

       ! Now check if there are multiple dimensions specified (look for comma)
       If (debug) Write(*,*) "--Found a '(', attempting to get subscripts"
       If (Index(varname,',') .eq. 0) Then

          ! There is no comma, get single dimension
          If (debug) Write(*,*) "--Single subscript dimension identified"

          ! Check for semicolon for range
          If (Index(varname,':') .eq. 0) Then
             ! No range, get single value
             If (debug) Write(*,*) "--Single value identified"
             temp = varname(Index(varname,'(')+1:Index(varname,')')-1)
             Read(temp,'(I10)') j1
             j2 = j1
             If (debug) Write(*,*) "--Single subscript found:",j1
          Else
             ! Range found, get two values. 
             If (debug) Write(*,*) "--Range identified"
             temp = varname(Index(varname,'(')+1:Index(varname,':')-1)
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)',iostat=ioerr) j1
             temp = varname(Index(varname,':')+1:Index(varname,')')-1)
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') j2
             If (debug) Write(*,*) "--Range found:",j1,j2
          Endif
          i1 = 1
          i2 = 0
       Else 
          
          ! There is a comma, look for two dimensions
          If (debug) Write(*,*) "--Found a ',', attempting to get two dimensions"

          ! Check for semicolon in first dimension
          temp = varname(Index(varname,'(')+1:Index(varname,',')-1)
          If (Index(temp,':') .eq. 0) Then
             If (debug) Write(*,*) "--Single value identified in dim1"
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') i1
             If (debug) Write(*,*) "--Single subscript found:",i1
             i2 = i1
          Else
             If (debug) Write(*,*) "--Range identified in dim1"
             temp2 = temp(1:Index(temp,':')-1)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i1
             temp2 = temp(Index(temp,':')+1:)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') i2
             If (debug) Write(*,*) "--Range found:",i1,i2
          Endif

          ! Check for semicolon in second dimension
          temp = varname(Index(varname,',')+1:Index(varname,')')-1)
          If (Index(temp,':') .eq. 0) Then
             If (debug) Write(*,*) "--Single value identified in dim2"
             If (Len(Trim(temp)) .ne. 0) Read(temp,'(I10)') j1
             If (debug) Write(*,*) "--Single subscript found:",j1
             j2 = j1
          Else
             If (debug) Write(*,*) "--Range identified in dim2"
             temp2 = temp(1:Index(temp,':')-1)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j1
             temp2 = temp(Index(temp,':')+1:)
             If (Len(Trim(temp2)) .ne. 0) Read(temp2,'(I10)') j2
             If (debug) Write(*,*) "--Range found:",j1,j2
          Endif

       Endif
       varname = varname(1:Index(varname,'(')-1)
    Endif
    ierr = 0
    Return 
  End Function handle_cmd_arg
  !-----------------------------------------------------------------------------
  
  Subroutine Print_help()
    Write(*,*) ' '
    Write(*,*) 'usage: nc2text_simple [OPTIONS] filename variable(i1:i2,j1:j2)'
    Write(*,*) ' '
    Write(*,*) 'Outputs variable from netcdf file'
    Write(*,*) ' '
    Write(*,*) '   OPTION -n #, number of columns to display data in. This arg accepted but ignored for compatibility'
    Write(*,*) ' '
    Write(*,*) "   Optional syntax 'variable(i1:i2,j1:j2)' can return a range"
    Write(*,*) ' '
    Write(*,*) '   Missing i1..j2 will evaluate as array bounds'
    Write(*,*) '   Ranges start from 1'
    Write(*,*) '   Zero or regative subscripts count from end of array'
    Write(*,*) ' '
    Write(*,*) 'Current restrictions: only 1D and 2D arrays of type double supported'
    Write(*,*) ' '
    Write(*,*) 'Examples:'    
    Write(*,*) '   nc2text_simple b2time.nc tesepa'
    Write(*,*) '   nc2text_simple -n 999999 b2time.nc tesepa'
    Write(*,*) "   nc2text_simple b2time.nc 'tesepa(1)'"
    Write(*,*) "   nc2text_simple b2time.nc 'fn3dl(-9:-0,:)'"
    
    Return
  End Subroutine Print_help
  
#endif

  
End Program nc2text_simple
