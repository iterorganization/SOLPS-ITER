%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_region sets the inrad and indpol logical grids for default region names. %
% facesup and facesdown contain the face indices of the upstream and           %
% downstream boundaries of indrad, respectively.                               %
% facesup_pol and facesdown_pol contain the face indices of the upstream and   %
% downstream boundaries of indpol, respectively.                               %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024.  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse,facesup,facesdown,facesup_pol,facesdown_pol] = set_region(region_name,comuse)

indrad = false(comuse.nCv,1);
indpol = false(comuse.nCv,1);

% Determine the geometry type based on the nuumber of X-points
if comuse.nXpt==1
    display('Assuming single null case');
    display('Assuming that face labels of targets are 1, 2, -13 or -34');
    switch region_name(1:2)
        case {'li','ui'}
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 3) || (comuse.cvReg(iCv) == 7)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2) || ...
                                any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
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
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2) || ...
                                any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
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
    display('Assuming that face labels of targets are 1, 2, 3, 4, -13, -34, -17, or -38');
    switch region_name(1:2)
        case 'li'
            for iCv = 1:comuse.nCi
                if (comuse.cvReg(iCv) == 3)
                    if (region_name(3)=='s')
                        iFt = comuse.cvFt(iCv);
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2))
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
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 2))
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
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
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
                        iFt1 = comuse.ftCvP(iFt,1);
                        iFt2 = iFt1 + comuse.ftCvP(iFt,2) - 1;
                        if (any(comuse.cvReg(comuse.ftCv(iFt1:iFt2)) == 6))
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

% Determine the faces of the upstream and downstream boundary of indrad
facesup = []; % list of faces at the upstream boundary
facesdown = []; % list of faces at the downstream boundary
for iFc = 1:comuse.nFc
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if (indrad(iCv1) && ~indrad(iCv2)) || (~indrad(iCv1) && indrad(iCv2))
        if comuse.cvReg(iCv1) ~= comuse.cvReg(iCv2)
            facesup = [facesup,iFc];
        elseif comuse.nXpt < 2
            if (comuse.fcLbl(iFc) == 1) || (comuse.fcLbl(iFc) == 2) || ...
                    (comuse.fcLbl(iFc) == -13) || (comuse.fcLbl(iFc) == -34)
                facesdown = [facesdown,iFc];
            end
        elseif comuse.nXpt == 2
            if (comuse.fcLbl(iFc) == 1) || (comuse.fcLbl(iFc) == 2) || ...
                    (comuse.fcLbl(iFc) == 3) || (comuse.fcLbl(iFc) == 4) || ...
                    (comuse.fcLbl(iFc) == -13) || (comuse.fcLbl(iFc) == -34) || ...
                    (comuse.fcLbl(iFc) == -17) || (comuse.fcLbl(iFc) == -38)
                facesdown = [facesdown,iFc];
            end  
        end
    end
end

% Determine the faces of the upstream and downstream boundary of indpol
facesup_pol = [];
for i = 1:length(facesup)
    iFc = facesup(i);
    if indpol(comuse.fcCv(iFc,1)) || indpol(comuse.fcCv(iFc,2))
        facesup_pol = [facesup_pol,iFc];
    end
end
facesdown_pol = [];
for i = 1:length(facesdown)
    iFc = facesdown(i);
    if indpol(comuse.fcCv(iFc,1)) || indpol(comuse.fcCv(iFc,2))
        facesdown_pol = [facesdown_pol,iFc];
    end
end


end