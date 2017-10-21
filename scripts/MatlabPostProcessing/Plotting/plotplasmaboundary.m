function h = plotplasmaboundary(gmtry,varargin)
% h = plotboundary(gmtry,options)
%
% Routine to plot boundary of simulated plasma domain.
% 
% Input arguments:
%
% - gmtry   : struct read from b2fgmtry-file
% - options : list of plot options compatible with Matlab plot command
%
% Output arguments:
%
% - h       : handle to the separatrix line
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Init empty output
h = [];

switch gmtry.nncut
    
    case 0
        
        % Coordinates of the boundary
        bound.r = [gmtry.crx(2:end-1,2,1);gmtry.crx(end-1,2:end-1,2)';...
                   gmtry.crx(end-1:-1,end-1,4);gmtry.crx(2,end-1:-1:2,3)';...
                   gmtry.crx(2,2,1)];
        bound.z = [gmtry.cry(2:end-1,2,1);gmtry.cry(end-1,2:end-1,2)';...
                   gmtry.cry(end-1:-1,end-1,4);gmtry.cry(2,end-1:-1:2,3)';...
                   gmtry.cry(2,2,1)];
               
        h = plot(bound.r,bound.z,varargin{:});
    case 1
        
        % Coordinates of the outer boundary
        bound.r = [gmtry.crx(2:gmtry.leftcut+1,2,1);gmtry.crx(gmtry.rightcut+2:end-1,2,1);...
                   gmtry.crx(end-1,2:end-1,2)';gmtry.crx(end-1:-1:2,end-1,4);...
                   gmtry.crx(2,end-1:-1:2,3)';gmtry.crx(2,2,1)];
        bound.z = [gmtry.cry(2:gmtry.leftcut+1,2,1);gmtry.cry(gmtry.rightcut+2:end-1,2,1);...
                   gmtry.cry(end-1,2:end-1,2)';gmtry.cry(end-1:-1:2,end-1,4);...
                   gmtry.cry(2,end-1:-1:2,3)';gmtry.cry(2,2,1)];
        
        % Coordinates of core boundary       
        core.r = [gmtry.crx(gmtry.leftcut+2:gmtry.rightcut+1,2,1);gmtry.crx(gmtry.leftcut+2,2,1)];
        core.z = [gmtry.cry(gmtry.leftcut+2:gmtry.rightcut+1,2,1);gmtry.cry(gmtry.leftcut+2,2,1)];
        
        hs = ishold;
        
        h = plot(bound.r,bound.z,varargin{:});hold on;
        plot(core.r,core.z,varargin{:});
        
        if ~hs, hold off; end
        
    otherwise
        
        disp(['plotsep: not implemented for gmtry.nncut = ',gmtry.nncut,'.']);
        
end

