function h = plotsurf(gmtry,iysurf,varargin)
% h = plotsurf(gmtry,iysurf,options)
%
% Routine to plot a flux surface with index iysurf.
% 
% Input arguments:
%
% - gmtry   : struct read from b2fgmtry-file
% - iysurf  : radial index of surface to be plotted
% - options : list of plot options compatible with Matlab plot command
%
% Output arguments:
%
% - h       : handle to the surface line
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Init empty output
h = [];

switch gmtry.nncut
    
    case 0
        
        % Surface coordinates
        surf.r = [gmtry.crx(:,iysurf,1);gmtry.crx(end,iysurf,2)];
        surf.z = [gmtry.cry(:,iysurf,1);gmtry.cry(end,iysurf,2)];
        
        % Plot
        h = plot(surf.r,surf.z,varargin{:});
        
    case 1
        
        % Collect surface coordinates
        if iysurf > gmtry.topcut+2           % in SOL
            surf.r = [gmtry.crx(:,iysurf,1);gmtry.crx(end,iysurf,2)];
            surf.z = [gmtry.cry(:,iysurf,1);gmtry.cry(end,iysurf,2)];
        elseif iysurf == gmtry.topcut+2      % separatrix
            surf.r = [gmtry.crx(:,gmtry.topcut(1)+2,1);gmtry.crx(end,gmtry.topcut(1)+2,2)];
            surf.z = [gmtry.cry(:,gmtry.topcut(1)+2,1);gmtry.cry(end,gmtry.topcut(1)+2,2)];
        else                                 % in PFR and core
            surf.r = [gmtry.crx(1:gmtry.leftcut+1,iysurf,1);...
                      gmtry.crx(gmtry.rightcut+2:end,iysurf,1);...
                      gmtry.crx(end,iysurf,2);...
                      NaN;...
                      gmtry.crx(gmtry.leftcut+2:gmtry.rightcut+1,iysurf,1);...
                      gmtry.crx(gmtry.leftcut+2,iysurf,1)];
            surf.z = [gmtry.cry(1:gmtry.leftcut+1,iysurf,1);...
                      gmtry.cry(gmtry.rightcut+2:end,iysurf,1);...
                      gmtry.cry(end,iysurf,2);...
                      NaN;...
                      gmtry.cry(gmtry.leftcut+2:gmtry.rightcut+1,iysurf,1);...
                      gmtry.cry(gmtry.leftcut+2,iysurf,1)];
            
        end
        
        
        % Plot
        h = plot(surf.r,surf.z,varargin{:});
        
    otherwise
        
        disp(['plotsep: not implemented for gmtry.nncut = ',gmtry.nncut,'.']);
        
end

