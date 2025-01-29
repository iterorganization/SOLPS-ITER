%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the divergence of the fluxes in each cell                          %
%                                                                              %
% Niels Horsten (niels.horsten@kuleuven.be) July 2024.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function divout = div(fluxx,fluxy,comuse,facesup,facesdown)

% Unpack some variables
nCv = comuse.nCv;

% Initialize 
divout = zeros(nCv,1);

for iCv = 1:nCv
    iFc1 = comuse.cvFcP(iCv,1);
    iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
    for i = iFc1:iFc2 % loop over faces of each cell
        iFc = comuse.cvFc(i);
        if any(facesup == iFc) || any(facesdown == iFc)
            flux = fluxy(iFc);
        else
            flux = fluxx(iFc) + fluxy(iFc);
        end
        if iCv == comuse.fcCv(iFc,1)
            divout(iCv) = divout(iCv) - flux;
        else
            divout(iCv) = divout(iCv) + flux;
        end
    end
end
    

end

