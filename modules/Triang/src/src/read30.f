C=======================================================================
C          S U B R O U T I N E  READ30
C=======================================================================
C     READ PHYSICAL COORDINATES FROM FORT.30 FILE TO XCOORD, YCOORD

      SUBROUTINE READ30
      use cdimen
      use ctria
      use ccuts
      IMPLICIT NONE

      DOUBLEPRECISION, allocatable :: BR(:,:,:), BZ(:,:,:)
      doubleprecision  CR, CZ, PIT
      doubleprecision, allocatable :: help3(:,:,:)
      INTEGER I,I0, I0E, I1, I2, I3, I4, IX0, ICELL
      integer dim1, dim2
      CHARACTER*110 ZEILE
      LOGICAL INISO

      character*8 format_string(2)
      integer, save :: new_format

      data new_format/1/
      data format_string/ '(4E15.7)', '(4E16.8)' /

      DOUBLEPRECISION DUMMI(4)

*  READ PHYSICAL COORDINATES FROM FORT.30 FILE
*  ---------------------------------------------------------------------
*  INFORMATION FOR EACH CELL
*                             y ^ 
*     NO. OF CELL    (IX,IY)    |  (BR(3),BZ(3))       (BR(2),BZ(2))
*                               |
*            PITCH              |               (CR,CZ)
*                               |
*                               |  (BR(4),BZ(4))       (BR(1),BZ(1))
*                                 -----------------------------------> x
*
      
      REWIND 30
      READ (30,*)
      READ (30,*)
      read(30,*) nx,ny,nncut
      allocate(br(nx,ny,4))
      allocate(bz(nx,ny,4))
      allocate(nxcut1(0:nncut))
      allocate(nxcut2(0:nncut))
      allocate(nycut1(0:nncut))
      allocate(nycut2(0:nncut))
      if (nncut.ge.1) then
        read(30,*) (nxcut1(i),nxcut2(i),nycut1(i),nycut2(i),i=1,nncut)
      else
        read(30,*)
      endif
      if (nncut.gt.2) then
        read(30,*) nniso
        allocate(nxiso1(0:nniso))
        allocate(nxiso2(0:nniso))
        allocate(nyiso1(0:nniso))
        allocate(nyiso2(0:nniso))
        read(30,*) (nxiso1(i),nxiso2(i),nyiso1(i),nyiso2(i),i=1,nniso)
      else
        nniso = 0
      endif
      read(30,*)
 3    write(*,*) 'Trying reading fort.30 with format_string option ',
     . new_format
      read (30,format_string(new_format),err=4) (DUMMI(i),i=1,4)
      goto 5
 4    continue
      backspace(30)
      new_format = new_format+1
      if (new_format.le.2) then
        goto 3
      else
        stop "Unrecognized format in fort.30 file"
      endif
 5    continue
      backspace(30)
      do ix=1,nx
        do iy=1,ny
         read (30,format_string(new_format)) (br(ix,iy,i),i=1,4)
         read (30,format_string(new_format)) (bz(ix,iy,i),i=1,4)
        end do
      end do
      allocate(ncell(0:nx+1,0:ny+1))
      NCELL(0:nx+1,0:ny+1)=0
      ICELL=0
      DO IY=1,NY
        DO IX=1,NX
          INISO=.FALSE.
          DO IISO=1,NNISO
            INISO = INISO .OR.
     .       (IX.GE.NXISO1(IISO).AND.IX.LE.NXISO2(IISO)+1.AND.
     .        IY.GE.NYISO1(IISO).AND.IY.LE.NYISO2(IISO))
          ENDDO
          IF (.NOT.INISO) THEN
            ICELL=ICELL+1
            NCELL(IX,IY)=ICELL
          ENDIF
        ENDDO
      ENDDO
      N2EFF=ICELL
            
      call realloc_ctria('xycoord',(nx+1)*(ny+1))
      DO IY=1,NY  
        DO IX=1,NX
          XCOORD((IY-1)*(NX+1)+IX+NCOORD)=BR(IX,IY,4)*100.
          YCOORD((IY-1)*(NX+1)+IX+NCOORD)=BZ(IX,IY,4)*100.
        ENDDO
        XCOORD(IY*(NX+1)+NCOORD)=BR(NX,IY,1)*100.
        YCOORD(IY*(NX+1)+NCOORD)=BZ(NX,IY,1)*100.
      ENDDO
      DO IX=1,NX
        XCOORD(NY*(NX+1)+IX+NCOORD)=BR(IX,NY,3)*100.
        YCOORD(NY*(NX+1)+IX+NCOORD)=BZ(IX,NY,3)*100.
      ENDDO
      XCOORD((NY+1)*(NX+1)+NCOORD)=BR(NX,NY,2)*100.
      YCOORD((NY+1)*(NX+1)+NCOORD)=BZ(NX,NY,2)*100.
      deallocate(br,bz)
666   FORMAT(4e16.8)
      END SUBROUTINE READ30
