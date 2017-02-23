%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_region sets the inrad and indpol logical grids for default region names. %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse] = set_region(region_name,comuse)

indrad = false(comuse.nx,comuse.ny);
indpol = false(comuse.nx,comuse.ny);

% Find the cuts to discern the geometry type:
xcut = find(diff(comuse.leftix(:,1))<1);
if length(xcut)==2
    display('Assuming single null case');
    switch region_name(1:2)
        case {'li','ui'}
            indrad(2:xcut(1)-1,2:end-1) = true;
            indpol(2:xcut(1)-1,comuse.sep+2) = true;
            reverse = true;
        case {'uo','lo'}
            indrad(xcut(2)+1:end-1,2:end-1) = true;
            indpol(xcut(2)+1:end-1,comuse.sep+2) = true;
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
elseif length(xcut)==5
    display('Assuming connected double null case');
    switch region_name(1:2)
        case 'li'
            indrad(2:xcut(1)-1,2:end-1) = true;
            indpol(2:xcut(1)-1,comuse.sep+2) = true;
            reverse = true;
        case 'ui'
            indrad(xcut(2):xcut(3)-1,2:end-1) = true;
            indpol(xcut(2):xcut(3)-1,comuse.sep+2) = true;
            reverse = false;
        case 'uo'
            indrad(xcut(3)+2:xcut(4),2:end-1) = true;
            indpol(xcut(3)+2:xcut(4),comuse.sep+2) = true;
            reverse = true;
        case 'lo'
            indrad(xcut(5)+1:end-1,2:end-1) = true;
            indpol(xcut(5)+1:end-1,comuse.sep+2) = true;
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
elseif isempty(xcut)
    display('Assuming continuous slab-like case');
    switch region_name(1:2)
        case {'li','ui','uo','lo'}
            indrad(2:end-1,2:end-1) = true;
            indpol(2:end-1,comuse.sep+1) = true;
            reverse = false;
        otherwise
            error('Region name ''%s'' not supported.',region_name);
    end
end

if region_name(3)=='s'
    indrad(:,1:comuse.sep+1) = false;
end
