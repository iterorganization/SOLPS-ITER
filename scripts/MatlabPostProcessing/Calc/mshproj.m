function [epx,epy,erx,ery] = mshproj(gmtry)
% [epx,epy,erx,ery] = mshproj(gmtry)
% 
% Compute x (R) and y (Z) components of poloidal and radial unit vectors 
% in the B2 cells.
%
% Based on the corresponding routine EIRENE_MSHPROJ
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Lengths of cell edges
d12 = ((gmtry.crx(:,:,2) - gmtry.crx(:,:,1)).^2 + ...
       (gmtry.cry(:,:,2) - gmtry.cry(:,:,1)).^2).^0.5;
d34 = ((gmtry.crx(:,:,4) - gmtry.crx(:,:,3)).^2 + ...
       (gmtry.cry(:,:,4) - gmtry.cry(:,:,3)).^2).^0.5;
d13 = ((gmtry.crx(:,:,3) - gmtry.crx(:,:,1)).^2 + ...
       (gmtry.cry(:,:,3) - gmtry.cry(:,:,1)).^2).^0.5;
d24 = ((gmtry.crx(:,:,4) - gmtry.crx(:,:,2)).^2 + ...
       (gmtry.cry(:,:,4) - gmtry.cry(:,:,2)).^2).^0.5;

% Bisecting vectors, not normalized
dpx = (gmtry.crx(:,:,2) - gmtry.crx(:,:,1))./d12 + ...
      (gmtry.crx(:,:,4) - gmtry.crx(:,:,3))./d34;
dpy = (gmtry.cry(:,:,2) - gmtry.cry(:,:,1))./d12 + ...
      (gmtry.cry(:,:,4) - gmtry.cry(:,:,3))./d34;
drx = (gmtry.crx(:,:,3) - gmtry.crx(:,:,1))./d13 + ...
      (gmtry.crx(:,:,4) - gmtry.crx(:,:,2))./d24;
dry = (gmtry.cry(:,:,3) - gmtry.cry(:,:,1))./d13 + ...
      (gmtry.cry(:,:,4) - gmtry.cry(:,:,2))./d24;

% R and Z components
epx = dpx./(dpx.^2 + dpy.^2).^0.5;
epy = dpy./(dpx.^2 + dpy.^2).^0.5;
erx = drx./(drx.^2 + dry.^2).^0.5;
ery = dry./(drx.^2 + dry.^2).^0.5;

% Correction for distroted grids
eper = epx.*erx + epy.*ery;
erx  = erx - eper.*epx;
ery  = ery - eper.*epy;
erer = (erx.^2 + ery.^2).^0.5;
erx = erx./erer;
ery = ery./erer;
