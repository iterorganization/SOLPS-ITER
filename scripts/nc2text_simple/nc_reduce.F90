! Simple program to reduce the size of NetCDF files
! by only keeping every m-th element or the last l elements
!
! Variables in all caps should be from netcdf.inc
!
program nc_reduce
  use b2mod_types
  use b2mod_subsys
  implicit none
#ifndef NO_CDF
#  include <netcdf.inc>
#endif

#ifndef NO_CDF
  integer :: ncid, varid, ndims, nvars, natts, unlimid
  integer :: dimids(NF_MAX_VAR_DIMS), dimsize(NF_MAX_VAR_DIMS)
  integer :: start(NF_MAX_VAR_DIMS), count(NF_MAX_VAR_DIMS), varids(NF_MAX_VAR_DIMS)
  integer :: i, j, ivar, idim, iatt, len, xtype
  integer :: status, timedim, timedim2, ncid2
  logical, allocatable :: lsave(:)
  real (kind=R8) :: scale(1)
  real (kind=R8), allocatable :: data1(:), data2(:,:), data3(:,:,:), data4(:,:,:,:)
  real (kind=R8), allocatable :: rata1(:), rata2(:,:), rata3(:,:,:), rata4(:,:,:,:)
  character(len = NF_MAX_NAME) :: varname, dimname, attname
  character(len = 264) :: fredname, message
  character(len = 24) :: units, hlp_frm
#endif
  integer :: modulus, last
  character(len = 256) :: filename, argName, argName2
  integer :: narg, cptArg
  logical :: exists, verbose
  logical :: streql, isadigit
  external streql, isadigit, xertst

  call prgini('nc_reduce')
  ! Check for command line arguments
  last = 0
  modulus = 1
  exists = .false.
  verbose = .false.
  narg = command_argument_count()
  if(narg.eq.0) call print_help()
  do cptArg = 1, narg
    call get_command_argument( cptArg, argName )
    select case( adjustl( argName ) )
      case("-l")
        call get_command_argument( cptArg + 1, argName2 )
        !! Transform dummy string variable to integer
        read( argName2, *) last
      case("-m")
        call get_command_argument( cptArg + 1, argName2 )
        !! Transform dummy string variable to integer
        read( argName2, *) modulus
      case("-h")
        call print_help()
      case("-v")
        verbose = .true.
      case default
        if (argName(1:1).eq.'-') write(*,*) &
          &  'Unrecognized argument '//trim(argName)//' : Ignored !'
    end select
    if(argName(1:1).ne."-".and..not.isadigit(argName(1:1))) filename = trim(argName)
  end do

  call xertst( 0.le.last, 'Invalid "-l" parameter!')
  call xertst( 1.le.modulus, 'Invalid "-m" parameter!')
  if (.not.streql(filename,' ')) then
    call find_file(filename,exists)
    call xertst( exists, 'File to be reduced not found!')
  end if

  if (exists.and.(last.gt.0 .or. modulus.gt.1)) then
    write(*,'(a,a)') 'Reducing ', trim(filename)
    if (last.gt.0.and.modulus.gt.0) then
      write(*,'(a,i5,a,i5,a)') &
        &  'Will keep the last ',last,' (modulo ',modulus,') time slices'
    else if (last.gt.1) then
      write(*,'(a,i5,a)') 'Will keep the last ',last,' time slices'
    else if (last.eq.1) then
      write(*,'(a)') 'Will keep the last time slice only'
    else if (mod(modulus, 10).gt. 3.or.mod(modulus, 10).eq. 0.or. &
      &      mod(modulus,100).eq.12.or.mod(modulus,100).eq.13.or. &
      &      mod(modulus,100).eq.11) then
      write(*,'(a,i5,a)') 'Will keep every ', modulus,'-th time slice'
    else if (mod(modulus,10).eq.3) then
      write(*,'(a,i5,a)') 'Will keep every ', modulus,'-rd time slice'
    else if (mod(modulus,10).eq.2) then
      write(*,'(a,i5,a)') 'Will keep every ', modulus,'-nd time slice'
    else if (mod(modulus,10).eq.1.and.modulus.gt.1) then
      write(*,'(a,i5,a)') 'Will keep every ', modulus,'-st time slice'
    end if
  else if (exists) then
    write(*,*) 'No reduction requested !'
  else if (verbose) then
    write(*,*) 'No filename argument: nothing to do!'
  end if

  if (exists) then
#ifndef NO_CDF
  !-----------------------------------------------------------------------------
  ! Open
    status =  0
    if (verbose) write(0,*) 'Opening file: ',trim(filename)
    status = NF_OPEN(trim(filename),NF_NOWRITE,ncid)
    call check_cdf_status(status)

    status=nf_inq(ncid,ndims,nvars,natts,unlimid)
    call check_cdf_status(status)

  ! Loop over all variables in the file
    do ivar=1,nvars
      status=nf_inq_var(ncid,ivar,varname,xtype,ndims,dimids,natts)
      call check_cdf_status(status)
      do idim=1,ndims
        status=nf_inq_dim(ncid,dimids(idim),dimname,len)
        call check_cdf_status(status)
        dimsize(idim)=len
      enddo
      units=''
      scale(1)=1.0_R8
      do iatt=1,natts
        status=nf_inq_attname(ncid,ivar,iatt,attname)
        call check_cdf_status(status)
        status=nf_inq_att(ncid,ivar,attname,xtype,len)
        call check_cdf_status(status)
        if(streql(attname,'units')) then
          if(len.le.24) then
            status=nf_get_att_text(ncid,ivar,attname,units)
            call check_cdf_status(status)
          else
            call xerrab ('increase size of units')
          endif
        elseif(streql(attname,'scale')) then
          if(len.le.1) then
            status=nf_get_att_double(ncid,ivar,attname,scale(1))
            call check_cdf_status(status)
          else
            call xerrab ('increase size of scale')
          endif
        endif
      enddo
    enddo

  ! First deal with the time vector
    do ivar=1,nvars
      status=nf_inq_var(ncid,ivar,varname,xtype,ndims,dimids,natts)
      call check_cdf_status(status)
      do idim=1,ndims
        status=nf_inq_dim(ncid,dimids(idim),dimname,len)
        call check_cdf_status(status)
        dimsize(idim)=len
      enddo
      if(streql(varname,'times').or.streql(varname,'timesa').or. &
       & streql(varname,'batchsa')) then
        allocate(data1(dimsize(1)))
        status=nf_get_var_double(ncid,ivar,data1)
        timedim=dimsize(1)
        call check_cdf_status(status)
        if (verbose) then
          if (timedim.ne.1) then
            write(*,*) 'Found ',timedim,' time slices in original file'
          else
            write(*,*) 'Found ',timedim,' time slice in original file'
          end if
        end if
        allocate(lsave(timedim))
        lsave = .false.
        if (last.gt.0) then
          timedim2 = min(last,timedim/modulus)
          lsave(timedim-(timedim2-1)*modulus:timedim:modulus) = .true.
        else
          timedim2 = timedim/modulus
          lsave(modulus:timedim:modulus) = .true.
        end if
        deallocate(data1)
      end if
    end do
    call xertst(allocated(lsave),'Did not find time slice array!')

    fredname = trim(filename)//'.reduced'
    message = 'File '//trim(fredname)//' already present! Please remove first.'
    call find_file(fredname,exists)
    call xertst(.not.exists,message)
    write(*,*) 'Reduced data will be written in ',trim(fredname)
    status=nf_create(trim(fredname),ncnoclob,ncid2)
    call check_cdf_status(status)

    ! Read and rewrite header
    ! Obtain dimensions
    status=nf_inq_dimids(ncid,ndims,dimids)
    call check_cdf_status(status)
    do idim=1,ndims
      status=nf_inq_dim(ncid,dimids(idim),dimname,len)
      call check_cdf_status(status)
      if(verbose) write(*,'(a,a,a,i6)') 'Found dimension ',trim(dimname),' with size ',len
      if(streql(dimname,'time').or.streql(dimname,'batch')) then
        status=nf_def_dim(ncid2,trim(dimname),ncunlim,dimids(idim))
      else
        status=nf_def_dim(ncid2,trim(dimname),len,dimids(idim))
      endif
      call check_cdf_status(status)
    enddo
    ! Obtain variable metadata
    do ivar=1,nvars
      status=nf_inq_var(ncid,ivar,varname,xtype,ndims,dimids,natts)
      call check_cdf_status(status)
      if(verbose) then
        if(ndims.ne.1) then
          write(*,'(a,a,a,i2,a,i2,a)') &
        &   'variable: ',trim(varname),' has type ',xtype,' and ',ndims,' dimensions'
        else
          write(*,'(a,a,a,i2,a,i2,a)') &
        &   'variable: ',trim(varname),' has type ',xtype,' and ',ndims,' dimension'
        endif
      endif
      dimsize=0
      if(ndims.eq.0) dimsize(1)=1
      do idim=1,ndims
        status=nf_inq_dim(ncid,dimids(idim),dimname,len)
        call check_cdf_status(status)
        dimsize(idim)=len
        if(verbose) write(*,'(a,a,a,i6)') &
          &   '    dimension: ',trim(dimname),' of length ',len
      enddo
      status=nf_def_var(ncid2,trim(varname),xtype,ndims,dimids,varid)
      call check_cdf_status(status)
      varids(ivar)=varid
      units=''
      scale(1)=1.0_R8
      do iatt=1,natts
        status=nf_inq_attname(ncid,ivar,iatt,attname)
        call check_cdf_status(status)
        status=nf_inq_att(ncid,ivar,attname,xtype,len)
        call check_cdf_status(status)
        if(verbose) write(*,'(a,a,a,i2,a,i6)') '    attribute: ',trim(attname), &
          &                                    ' of type ',xtype,' and length ',len
        if(streql(attname,'long_name')) then
          status=nf_put_att_text(ncid2,varid,attname,len,varname)
          call check_cdf_status(status)
        elseif(streql(attname,'units')) then
          if(len.le.24) then
            status=nf_get_att_text(ncid,ivar,attname,units)
            call check_cdf_status(status)
          else
            call xerrab ('increase size of units')
          endif
          status=nf_put_att_text(ncid2,varid,attname,len,units)
          call check_cdf_status(status)
        elseif(streql(attname,'scale')) then
          if(len.le.1) then
            status=nf_get_att_double(ncid,ivar,attname,scale(1))
            call check_cdf_status(status)
          else
            call xerrab ('increase size of scale')
          endif
          status=nf_put_att_double(ncid2,varid,attname, NCDOUBLE, 1, scale(1))
          call check_cdf_status(status)
        else
          write(*,*) 'Attribute ',trim(attname),' not coded !'
        endif
      enddo
      if(verbose) then
        if(streql(units,' ')) then
          write(*,*) '  units = None'
        else
          write(*,*) '  units = ',trim(units)
        endif
      endif
      if(verbose) write(*,*) '  scale = ',scale(1)
    end do
    status=nf_enddef(ncid2)
    call check_cdf_status(status)
    status=nf_close(ncid2)
    call check_cdf_status(status)

    ! Read and rewrite data
    status=nf_open(trim(fredname),ncwrite,ncid2)
    call check_cdf_status(status)
    do ivar=1,nvars
      status=nf_inq_var(ncid,ivar,varname,xtype,ndims,dimids,natts)
      call check_cdf_status(status)
      count=0
      do idim=1,ndims
        status=nf_inq_dim(ncid,dimids(idim),dimname,len)
        call check_cdf_status(status)
        dimsize(idim)=len
        count(idim)=len
        start(idim)=1
      enddo
      if (ndims.eq.0) then
        write(message,'(a)') 'Processing '//trim(varname)//' ...'
      elseif (ndims.eq.1) then
        write(message,'(a,i6,a)') 'Processing '//trim(varname)//' with size ',len,' ...'
      else
        write(hlp_frm,'(a,i1,a)') '(3a,',ndims-1,'(i6,'',''),i6,a1)'
        write(message,hlp_frm) 'Processing ',trim(varname), &
         &     ' with dimensions (',(count(idim),idim=1,ndims),')'
      end if
      if(verbose) write(*,'(a)') trim(message)
      if(streql(varname,'times').or.streql(varname,'timesa').or. &
       & streql(varname,'batchsa')) then
        allocate(data1(dimsize(1)))
        allocate(rata1(timedim2))
        status=nf_get_vara_double(ncid,ivar,start,count,data1)
        call check_cdf_status(status)
        count(1) = timedim2
        j = 0
        do i = 1, timedim
          if (lsave(i)) then
            j = j + 1
            rata1(j) = data1(i)
          end if
        end do
        status=nf_put_vara_double(ncid2,varids(ivar),start,count,rata1)
        deallocate(data1)
        deallocate(rata1)
      else
        if(ndims.eq.4) then
          allocate(data4(dimsize(1),dimsize(2),dimsize(3),dimsize(4)))
          allocate(rata4(dimsize(1),dimsize(2),dimsize(3),timedim2))
          status=nf_get_vara_double(ncid,ivar,start,count,data4)
          call check_cdf_status(status)
          if(dimsize(4).eq.timedim) then
            count(4) = timedim2
            j = 0
            do i = 1, timedim
              if (lsave(i)) then
                j = j + 1
                rata4(:,:,:,j) = data4(:,:,:,i)
              end if
            end do
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,rata4)
          else
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,data4)
          end if
          call check_cdf_status(status)
          deallocate(data4)
          deallocate(rata4)
        else if(ndims.eq.3) then
          allocate(data3(dimsize(1),dimsize(2),dimsize(3)))
          allocate(rata3(dimsize(1),dimsize(2),timedim2))
          status=nf_get_vara_double(ncid,ivar,start,count,data3)
          call check_cdf_status(status)
          if (dimsize(3).eq.timedim) then
            count(3) = timedim2
            j = 0
            do i = 1, timedim
              if (lsave(i)) then
                j = j + 1
                rata3(:,:,j) = data3(:,:,i)
              end if
            end do
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,rata3)
          else
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,data3)
          end if
          call check_cdf_status(status)
          deallocate(data3)
          deallocate(rata3)
        else if(ndims.eq.2) then
          allocate(data2(dimsize(1),dimsize(2)))
          allocate(rata2(dimsize(1),timedim2))
          status=nf_get_vara_double(ncid,ivar,start,count,data2)
          call check_cdf_status(status)
          if (dimsize(2).eq.timedim) then
            count(2) = timedim2
            j = 0
            do i = 1, timedim
              if (lsave(i)) then
                j = j + 1
                rata2(:,j) = data2(:,i)
              end if
            end do
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,rata2)
          else
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,data2)
          end if
          call check_cdf_status(status)
          deallocate(data2)
          deallocate(rata2)
        else if(ndims.eq.1) then
          allocate(data1(dimsize(1)))
          allocate(rata1(timedim2))
          status=nf_get_vara_double(ncid,ivar,start,count,data1)
          call check_cdf_status(status)
          if (dimsize(1).eq.timedim) then
            count(1) = timedim2
            j = 0
            do i = 1, timedim
              if (lsave(i)) then
                j = j + 1
                rata1(j) = data1(i)
              end if
            end do
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,rata1)
          else
            status=nf_put_vara_double(ncid2,varids(ivar),start,count,data1)
          end if
          call check_cdf_status(status)
          deallocate(data1)
          deallocate(rata1)
        else if(ndims.eq.0) then
          allocate(data1(1))
          status=nf_get_var_double(ncid,ivar,data1)
          call check_cdf_status(status)
          if (nint(data1(1)).eq.timedim) data1(1) = real(timedim2)
          status=nf_put_var_double(ncid2,varids(ivar),data1)
          call check_cdf_status(status)
          deallocate(data1)
        else
          write(*,'(a,i2,a)') 'Case for ',ndims,' dimensions not yet coded'
        endif
      endif
    enddo

    status=nf_close(ncid)
    call check_cdf_status(status)
    status=nf_close(ncid2)
    call check_cdf_status(status)

    deallocate(lsave)
#else
    write(*,*) &
      & 'nc_reduce failed because compiled with NO_CDF option'
#endif
  end if

  call prgend ()
  stop
  !-----------------------------------------------------------------------------

  contains

  !-----------------------------------------------------------------------------

  subroutine print_help()
    write(0,'(a)') ' '
    write(0,'(a)') 'Usage: nc_reduce [OPTIONS] filename'
    write(0,'(a)') ' '
    write(0,'(a)') '   OPTIONS: -m #, frequency of data points to keep (default 1).'
    write(0,'(a)') '            -l #, keep the last # points (default all).'
    write(0,'(a)') '            -h, prints this message.'
    write(0,'(a)') '            -v, verbose output.'
    write(0,'(a)') ' '
    write(0,'(a)') 'Examples (for a case with N time slices in b2time.nc):'
    write(0,'(a)') '   nc_reduce -m 100 b2time.nc'
    write(0,'(a)') '    (will keep slices [100, 200, 300, ..., N-mod(N,100)])'
    write(0,'(a)') '   nc_reduce -l 150 b2time.nc'
    write(0,'(a)') '    (will keep slices [N-149, N-148, ..., N])'
    write(0,'(a)') '   nc_reduce -m 10 -l 250 b2time.nc'
    write(0,'(a)') '    (will keep slices [N-2490, N-2480, ..., N])'
    write(0,'(a)') ' '
    return
  end subroutine print_help

end program nc_reduce
