%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% user_set_region allows the user to set their own logical grids for indrad    %
% and indpol in order to plot balance in any region.                           %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse] = user_set_region(comuse)

indrad = false(comuse.nx,comuse.ny);
indpol = false(comuse.nx,comuse.ny);

xcut = find(diff(comuse.leftix(:,1))<1);

indrad(2:end-1,comuse.sep+2:end-1) = true;
% indpol(2:end-1,comuse.sep+10) = true;
indpol([2:xcut(1)-1,xcut(2)+1:end-1],comuse.sep) = true;
reverse = false;
