function h = plotsep(gmtry,varargin)
% h = plotsep(gmtry,options)
%
% Routine to plot separatrix.
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
        
        % No sep in this case...
        disp('plotsep: no separatrix in case gmtry.nncut = 0.');
    
    case 1
        
        % Collect separatrix coordinates
        sep.r = [gmtry.crx(:,gmtry.topcut(1)+2,1);gmtry.crx(end,gmtry.topcut(1)+2,2)];
        sep.z = [gmtry.cry(:,gmtry.topcut(1)+2,1);gmtry.cry(end,gmtry.topcut(1)+2,2)];
        
        % Plot
        h = plot(sep.r,sep.z,varargin{:});
        
    otherwise
        
        disp(['plotsep: not implemented for gmtry.nncut = ',gmtry.nncut,'.']);
        
end

