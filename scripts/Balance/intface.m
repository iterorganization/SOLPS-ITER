function fieldI = intface(field,comuse)
% fieldI = intface(gmtry,field,dir,meth)
%
% Interpolate a cell centered field to cell faces. Only volume weighted
% interpolation is implemented for now.
%

% Author: Niels Horsten
% E-mail: niels.horsten@kuleuven.be
% August 2024

nFc = comuse.nFc;

fieldI = zeros(nFc,1);

for iFc = 1:nFc
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    
    fieldI(iFc) = (comuse.cvVol(iCv1)*field(iCv2) + ...
        comuse.cvVol(iCv2)*field(iCv1))/(comuse.cvVol(iCv1) + ...
        comuse.cvVol(iCv2));
end