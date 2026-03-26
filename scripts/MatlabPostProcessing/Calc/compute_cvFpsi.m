function [gmtry] = compute_cvFpsi(gmtry)
% [gmtry] = compute_cvFpsi(gmtry)
%
% Routine to compute the cvFpsi quantity and add it to the gmtry structure.
% This quantity is not automatically written in the b2fgmtry file but it
% can be recomputed from vxFpsi as done in b2agmt routine.
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
    nv = gmtry.cvVxP(iCv,2);
    verts = gmtry.cvVx(gmtry.cvVxP(iCv,1):gmtry.cvVxP(iCv,1)+nv-1);
    gmtry.cvFpsi(iCv) = sum(gmtry.vxFpsi(verts)) / nv;
end

end
