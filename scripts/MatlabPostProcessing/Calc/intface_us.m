function [face] = intface_us(gmtry,centre)
% [face] = intface_us(nCv,nFc,fcCv,fcVol,centre,face)
%
% Interpolate a cell centered field to cell faces for unstructured grids.
% Based on utility::intface.
%
% Author: Anthony Piras
% E-mail: anthony.piras@kuleuven.be
% April 2026

fcVol = zeros(gmtry.nFc,2);
for iFc = 1:gmtry.nFc
    % Compute fcVol first, according to b2us_geo::init_geometry
    fcVol(iFc,1) = 0.5*gmtry.cvVol(gmtry.fcCv(iFc,1));
    fcVol(iFc,2) = 0.5*gmtry.cvVol(gmtry.fcCv(iFc,2));
    % Interpolate
    face(iFc) = (fcVol(iFc,1)*centre(gmtry.fcCv(iFc,2))+ ...
        fcVol(iFc,2)*centre(gmtry.fcCv(iFc,1)))/...
        (fcVol(iFc,1)+fcVol(iFc,2));
end

end