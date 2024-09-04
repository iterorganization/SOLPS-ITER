%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate the radial divergence in each cell                                 %
% Fluxes through facesup and facesdown are already taken into account by       %
% the fluxes and are omitted (except for the radial component if               %
% areatype = 'parallel'                                                        %
%                                                                              %
% Niels Horsten (niels.horsten@kuleuven.be) July 2024.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function raddiv = raddiv(fluxx,fluxy,comuse,facesup,facesdown,areatype)

nCv = comuse.nCv;

% Initialization
raddiv = zeros(nCv,1);

for iCv = 1:nCv
    iFc1 = comuse.cvFcP(iCv,1);
    iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
    for i = iFc1:iFc2 % Loop over all faces of the cell
        iFc = comuse.cvFc(i);
        % Check if face is part of upstream or downstream boundary
        if any(facesup == iFc) || any(facesdown == iFc)
            switch areatype
                case 'parallel' % Add radial component 
                    if iCv == comuse.fcCv(iFc,1)
                        raddiv(iCv) = raddiv(iCv) - fluxy(iFc);
                    else
                        raddiv(iCv) = raddiv(iCv) + fluxy(iFc);
                    end
            end
        else
            if iCv == comuse.fcCv(iFc,1)
                raddiv(iCv) = raddiv(iCv) - fluxx(iFc) - fluxy(iFc);
            else
                raddiv(iCv) = raddiv(iCv) + fluxx(iFc) + fluxy(iFc);
            end
        end
    end
end

end

