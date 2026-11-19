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
elseif comuse.nXpt == 0 && any(comuse.cvReg(1:comuse.nCi) == 2)
    display('Assuming limiter case');
    % Each flux tube of the SOL (region 2) runs from one side of the limiter
    % to the other and is split at its poloidal middle: li and ui take the
    % half that ends on the side at the smaller major radius, uo and lo the
    % other half (with both sides at about the same radius, the two halves).
    switch region_name(1:2)
        case {'li','ui','uo','lo'}
            inner = any(strcmp(region_name(1:2),{'li','ui'}));
            reverse = false;
            for iFt = 1:comuse.nFt
                iFt1 = comuse.ftCvP(iFt,1);
                cells = comuse.ftCv(iFt1:iFt1+comuse.ftCvP(iFt,2)-1);
                cells = cells(cells <= comuse.nCi);
                if isempty(cells) || comuse.cvReg(cells(1)) ~= 2
                    continue
                end
                n = floor(numel(cells)/2);
                first = (comuse.cvX(cells(1)) < comuse.cvX(cells(end))) == inner;
                if first
                    half = cells(1:n);
                else
                    half = cells(n+1:end);
                end
                indrad(half) = true;
                if iFt == comuse.ftSep
                    indpol(half) = true;
                    reverse = first;
                end
            end
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
elseif comuse.nXpt == 0
    display('Assuming continuous slab-like case');
    switch region_name(1:2)
        case {'li','ui','uo','lo'}
            indrad(1:comuse.nCi) = true;
            if (region_name(3)=='s')
                indrad(comuse.cvReg == 1) = false;
            end
            indpol(comuse.cvFt == comuse.ftSep) = true;
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
end

% Determine the faces of the upstream and downstream boundary of indrad.
% Downstream faces are the ends of the flux tubes: faces between a cell of
% the region and a guard cell that the flux tube passes through (cosine of
% alpha non-zero, as B2.5 itself tells them from radial faces): the targets,
% the limiter, or the walls that the flux tubes end on in extended grids.
% This does not depend on the face labels or on the flux tube of the guard
% cell, which differ between grids.
facesup = []; % list of faces at the upstream boundary
facesdown = []; % list of faces at the downstream boundary
for iFc = 1:comuse.nFc
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if (indrad(iCv1) && ~indrad(iCv2)) || (~indrad(iCv1) && indrad(iCv2))
        if indrad(iCv1)
            iCvin = iCv1;
            iCvout = iCv2;
        else
            iCvin = iCv2;
            iCvout = iCv1;
        end
        if (iCvout > comuse.nCi) && (comuse.fcQalf(iFc,1) ~= 0)
            facesdown = [facesdown,iFc];
        elseif (comuse.cvReg(iCv1) ~= comuse.cvReg(iCv2)) || ...
                ((iCvout <= comuse.nCi) && ...
                (comuse.cvFt(iCvout) == comuse.cvFt(iCvin)))
            facesup = [facesup,iFc];
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