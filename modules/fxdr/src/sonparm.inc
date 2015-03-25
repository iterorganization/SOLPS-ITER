c  VERSION : 18.11.95 14:50

      integer nnpr, nnpz, nnst, npts, nntrg, nnreg, nnzon, nlvl, narc
     ,                                              nmtrg, nmlvl, nmarc
      real delgs, rztg, flvl,  arcln, flxnr

C*** Array dimensions for the plasma equilibrium data
c...        nnpr_max = 200, nnpz_max = 200
C...        typically   80             128

C*** THIS SPECIFICATION WORKS
c      parameter (nnpr = 65,     nnpz = 200)
C*** AND THIS DOES NOT
      parameter (nnpr =200,     nnpz = 200)

C*** Array dimensions for the wall structures
c***      number of structures  max. number of points per structure
c...          nst_max = 30,         npts_max = 500
      parameter (nnst =  4,             npts = 500)

C*** max. number of targets, flux regions, and grid zones
      parameter (nntrg = 2 ,  nnreg = 3  ,    nnzon = 3  )

c*** array dimensions for the grid data input
c*** (max. number of the radial and poloidal mesh points in each zone)
      parameter (    nlvl = 64  ,  narc = 128 )

C*** the guard cell size in units of the size of the next regular cell
      parameter (delgs = 0.02)

      common/inpsnn/nmtrg(nntrg),rztg(2,npts,nntrg),
     ,              nmlvl(nnreg),flvl(nlvl+1,nnreg),
     ,              nmarc(nnzon),arcln(narc+1,nnzon),flxnr
