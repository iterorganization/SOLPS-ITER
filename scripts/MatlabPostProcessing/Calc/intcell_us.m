function [centre] = intcell_us(nCv,gmtry,wght,face)
% [centre] = intcell_us(nCv,gmtry,wght,face)
%
% Interpolates a face-centered quantity on cell centers using weights
% (suggested weights are gmtry.intcellR and gmtry.intcellP for radial and
% poloidal interpolations).
%

centre=zeros(nCv,1);

for iCv = 1: nCv
    wghtsum = 0.0;
    for iFc = 1:gmtry.cvFcP(iCv,2)
        wghtsum = wghtsum + wght(gmtry.cvFcP(iCv,1) + iFc - 1);
        centre(iCv) = centre(iCv) + ...
        face(gmtry.cvFc(gmtry.cvFcP(iCv,1) + iFc - 1))*...
        wght(gmtry.cvFcP(iCv,1) + iFc - 1);
    end
    centre(iCv) = centre(iCv)/wghtsum;
end

return

end
