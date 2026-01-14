function [gmtry] = compute_cvFpsi(gmtry)
% [gmtry] = compute_cvFpsi(gmtry)
%
% Routine to compute the cvFpsi quantity and add it to the gmtry structure.
% This quantity is not automatically written in the b2fgmtry file but it
% can be recomputed from vxFpsi as done in b2us_geo::init_geometry routine.
%
% Input arguments:
%
% - gmtry  : struct read from b2fgmtry-file
%
% Output arguments:
%
% - gmtry  : struct read from b2fgmtry-file with gmtry.cvFpsi added
%

% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% January 2026

for iCv = 1:gmtry.nCv
    verts = gmtry.cvVx(gmtry.cvVxP(iCv,1):gmtry.cvVxP(iCv,1)+gmtry.cvVxP(iCv,2)-1);
    gmtry.cvFpsi(iCv) = 0.5*( max(gmtry.vxFpsi(verts(1:gmtry.cvVxP(iCv,2)))) ...
                              + min(gmtry.vxFpsi(verts(1:gmtry.cvVxP(iCv,2)))) );
end

end