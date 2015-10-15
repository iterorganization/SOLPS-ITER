function geomstruc = b2getgeom(MDSno)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b2getgeom reads b2 geometry for a SOLPS simulation                           %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) August 2015.                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mdsopen('solps-mdsplus.aug.ipp.mpg.de:8001::solps',MDSno);

geomstruc.nx = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NX');
geomstruc.ny = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NY');
geomstruc.r = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:R');
geomstruc.z = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:Z');
geomstruc.cr=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR');
geomstruc.cz=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ');
geomstruc.cr_x=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR_X');
geomstruc.cr_y=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR_Y');
geomstruc.cz_x=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ_X');
geomstruc.cz_y=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ_Y');
geomstruc.rightix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:RIGHTIX');
geomstruc.leftix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:LEFTIX');
geomstruc.rightiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:RIGHTIY');
geomstruc.leftiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:LEFTIY');
geomstruc.topix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:TOPIX');
geomstruc.bottomix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:BOTTOMIX');
geomstruc.topiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:TOPIY');
geomstruc.bottomiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:BOTTOMIY');
geomstruc.sep = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:SEP');
geomstruc.omp = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:OMP');
geomstruc.ns = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NS');
geomstruc.dspol = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:DSPOL');
geomstruc.dspar = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:DSPAR');

mdsclose;

end
