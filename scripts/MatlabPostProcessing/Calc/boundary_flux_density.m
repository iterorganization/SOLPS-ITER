function bFlux = boundary_flux_density(gmtry,fcList,flux)
%
% function to compute the flux normal to the boundary:
% project flux vector onto surface normal pointing away from plasma;
% positive boundary_flux if out of the plasma domain
%


fcOr = zeros(size(fcList));
for iFc = 1:length(fcList)
    if gmtry.fcCv(fcList(iFc),1) > gmtry.nCi
        fcOr(iFc) = -1;
    elseif gmtry.fcCv(fcList(iFc),2) > gmtry.nCi
        fcOr(iFc) = 1;
    else
        disp(fcList(iFc))
        error('Not a boundary face?');
    end
end

for is = 1:size(flux,3)
    bFlux(:,is) = squeeze(sum(flux(fcList,1:2,is),2)).*fcOr./...
        gmtry.fcS(fcList);
end

