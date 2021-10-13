function div = div_us(gmtry,flow)
% div = div_us(gmtry,flow)
%
% Computes the divergence of a B2.5 flow field flow. 
% It is assumed that flow is defined on cell faces.
% The output is a cell centered quantity.
%

% Some local variables
nCv = gmtry.nCv;
nFc = gmtry.nFc;

% Initialize output
div = zeros(nCv,1);

% Compute divergence
for ifc = 1:nFc
    icv1 = gmtry.fcCv(ifc,1);
    div(icv1) = div(icv1) + flow(ifc,1) + flow(ifc,2);
    icv2 = gmtry.fcCv(ifc,2);
    div(icv2) = div(icv2) - flow(ifc,1) - flow(ifc,2);
end


end


