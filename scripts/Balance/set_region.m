%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_region sets the inrad and indpol logical grids for default region names. %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.      
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse] = set_region(region_name,comuse)

indrad = false(comuse.nCv,1);
indpol = false(comuse.nCv,1);

% Determine the geometry type based on the nuumber of X-points
if comuse.nXpt==1
    display('Assuming single null case');
    switch region_name(1:2)
        case {'li','ui'}
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 3)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 2) || ...
                                any(comuse.cvReg(comuse.ftCv(iFt)) == 6))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep)
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = true;
        case {'uo','lo'}
            for iCv = 1:comuse.nCi
                if ((comuse.cvReg(iCv) == 4) || (comuse.cvReg(iCv) == 8))
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 2) || ...
                                any(comuse.cvReg(comuse.ftCv(iFt)) == 6))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep)
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
elseif comuse.nXpt==2
    display('Assuming connected double null case');
    switch region_name(1:2)
        case 'li'
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 3)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 2))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep(1))
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = true;
        case 'ui'
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 4)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 2))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep(1))
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = false;
        case 'uo'
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 7)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 6))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep(2))
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = true;
        case 'lo'
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 8)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        if (any(comuse.cvReg(comuse.ftCv(iFt)) == 6))
                            indrad(iCv) = true;
                        end
                    else
                        indrad(iCv) = true;
                    end
                    if (comuse.cvFt(iCv) == comuse.ftSep(2))
                        indpol(iCv) = true;
                    end
                end
            end
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
elseif comuse.nXpt == 0
    display('Assuming continuous slab-like case');
    switch region_name(1:2)
        case {'li','ui','uo','lo'}
            indrad(1:nCi) = true;
            if (region_name(3)=='s')
                indrad(gmtry.cvReg == 1) = false;
            end
            indpol(comuse.cvFt == comuse.ftSep) = true;
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
end
