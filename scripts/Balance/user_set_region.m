%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% user_set_region allows the user to set their own logical grids for indrad    %
% and indpol in order to plot balance in any region.                           %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [indrad,indpol,reverse] = user_set_region(comuse)

indrad = false(comuse.nx,comuse.ny);
indpol = false(comuse.nx,comuse.ny);

% indrad(3:end-1,2:end-1) = true;
% indpol(3:end-1,12) = true;
% reverse = false;

xcut = find(diff(comuse.leftix(:,1))<1);
indrad(xcut(5)+1:end-4,2:end-1) = true;
indpol(xcut(5)+1:end-4,comuse.sep-4) = true;
reverse = false;