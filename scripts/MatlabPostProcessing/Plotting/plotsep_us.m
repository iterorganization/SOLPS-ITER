function [sep] = plotsep_us(gmtry,icsep,omp,varargin)
% [sep] = plotsep_us(gmtry,icsep,omp,varargin)
%
% Identifies and plots separatrix flux tube.
%

[sep1] = find_flux_surfaces(gmtry,omp(icsep));
[sep2] = find_flux_surfaces(gmtry,omp(icsep-1));
sep = intersect(sep1,sep2);
for jj=1:gmtry.fsFcP(sep,2)     
        ifc = gmtry.fsFc(gmtry.fsFcP(sep,1)+jj-1);
        vx1 = gmtry.fcVx(ifc,1); vx2 = gmtry.fcVx(ifc,2);
        plot([gmtry.vxX(vx1) gmtry.vxX(vx2)],[gmtry.vxY(vx1) gmtry.vxY(vx2)],varargin{:}) 
end
end