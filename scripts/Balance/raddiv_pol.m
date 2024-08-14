%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the fluxes required to make the balance in indpol correct          %
% for areatype = 'parallel', the radial fluxes through the upstream and        %
% downstream faces have to be taken into account, because only the poloidal    %
% component is considered for the standard fluxes                              %
% for areatype = 'contact' or 'none', only the fluxes through the radial       %
% boundaries of indpol (faces not part of facesup or facesdown) have to be     % 
% taken into account                                                           %
%                                                                              %
% Niels Horsten (niels.horsten@kuleuven.be) August 2024.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function flux = raddiv_pol(fluxx,fluxy,comuse,indpol,facesup,facesdown,areatype)

    switch areatype
        case 'parallel'
            flux = fluxy; % radial fluxes have to be added
        otherwise
            flux = zeros(size(fluxx));  
    end

    %% Fluxes at boundary of indpol
    for iCv = 1:comuse.nCv
        if indpol(iCv)
            iFc1 = comuse.cvFcP(iCv,1);
            iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
            for i = iFc1:iFc2
                iFc = comuse.cvFc(i);
                if ~any(facesup == iFc) && ~any(facesdown == iFc)
                    if (indpol(comuse.fcCv(iFc,1)) && ~indpol(comuse.fcCv(iFc,2))) || ...
                        (~indpol(comuse.fcCv(iFc,1)) && indpol(comuse.fcCv(iFc,2))) % face at radial boundary of indpol
                        switch areatype
                            case 'parallel'
                                flux(iFc,:) = flux(iFc,:) + fluxx(iFc,:);
                            otherwise
                                flux(iFc,:) = flux(iFc,:) + fluxx(iFc,:) + fluxy(iFc,:);
                        end
                    end
                end
            end
        end
    end
end

