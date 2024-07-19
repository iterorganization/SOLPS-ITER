%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the radial divergence in each flux tube                            %
%                                                                              %
% Niels Horsten (niels.horsten@kuleuven.be) July 2024.                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function raddiv = raddiv(fluxx,fluxy,comuse,indrad,facesup,facesdown,areatype)

nFt = comuse.nFt;

raddiv = zeros(nFt,1);
for iFt = 1:nFt
    iCv1 = comuse.ftCvP(iFt,1);
    iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
    for i=iCv1:iCv2
        iCv = comuse.ftCv(i);
        if ~indrad(iCv)
            continue; % Ignore cells that are not in indrad
        end
        % Loop over faces
        iFc1 = comuse.cvFcP(iCv,1);
        iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
        for j = iFc1:iFc2
            iFc = comuse.cvFc(j);
            if any(facesup == iFc) || any(facesdown == iFc)
                switch areatype
                    case 'parallel' % Radial component has to be added
                        if comuse.fcCv(iFc,1) == iCv
                            raddiv(iFt) = raddiv(iFt) - fluxy(iFc);
                        else
                            raddiv(iFt) = raddiv(iFt) + fluxy(iFc);
                        end
                end
            elseif comuse.cvFt(comuse.fcCv(iFc,1)) ~= comuse.cvFt(comuse.fcCv(iFc,2)) % Face at border of flux tube
                if comuse.fcCv(iFc,1) == iCv
                    raddiv(iFt) = raddiv(iFt) - fluxx(iFc) - fluxy(iFc);
                else
                    raddiv(iFt) = raddiv(iFt) + fluxx(iFc) + fluxy(iFc);
                end
            end
        end
    end
end

end

