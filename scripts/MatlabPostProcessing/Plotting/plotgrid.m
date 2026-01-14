function h = plotgrid(gmtry,varargin)
% h = plotgrid(gmtry,options)
%
% Routine to plot grid.
%
% Input arguments:
%
% - gmtry   : struct read from b2fgmtry-file
% - options : list of plot options compatible with Matlab plot command
%
% Output arguments:
%
% - h       : struct with vectors of handles to the plot objects,
%             case gmtry.nncut = 0:
%                 h(1): poloidal surfaces
%                 h(2): radial surfaces
%             case gmtry.nncut = 1:
%                 h(1): poloidal surfaces, core
%                 h(2): poloidal surfaces, SOL
%                 h(3): poloidal surfaces, PFR
%                 h(4): separatrix
%                 h(5): radial surfaces, all
%             general case:
%                 h(...) per cell face segment...
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

% Check current status of hold
hs = ishold;

% Init output
h  = struct('h',[]);

% For speed, special treatment for nncut = 0 and nncut = 1
% General cases treated as well, but leads to a heavy plot!
if isfield(gmtry,'nCv')

    % Old code
    % % Plot all internal cells as set of faces
    % nInt = gmtry.nCi;
    % R_all = [];
    % Z_all = [];
    % 
    % for iCv = 1:nInt
    %     startIdx = gmtry.cvFcP(iCv,1);
    %     nFc      = gmtry.cvFcP(iCv,2);
    %     fcIdx    = gmtry.cvFc(startIdx:startIdx+nFc-1);
    % 
    %     vx1 = gmtry.fcVx(fcIdx,1);
    %     vx2 = gmtry.fcVx(fcIdx,2);
    % 
    %     rco = [gmtry.vxX(vx1) gmtry.vxX(vx2)]';
    %     zco = [gmtry.vxY(vx1) gmtry.vxY(vx2)]';
    % 
    %     R_all = [R_all; rco(:); NaN];
    %     Z_all = [Z_all; zco(:); NaN];
    % end
    % 
    % % Plot all internal faces in one go
    % hInt = plot(R_all, Z_all, varargin{:});
    % hold on;

    figure()
    hold on
    for iFc = 1:gmtry.nFc
        vx1 = gmtry.fcVx(iFc,1); % first vertex of face
        vx2 = gmtry.fcVx(iFc,2); % second vertex of face
        x1 = gmtry.vxX(vx1); % x-coord of first vertex
        y1 = gmtry.vxY(vx1); % y-coord of first vertex
        x2 = gmtry.vxX(vx2); % x-coord of second vertex
        y2 = gmtry.vxY(vx2); % y-coord of second vertex
        plot([x1 x2],[y1 y2],'k','LineWidth',0.5)
    end

    % --- Guard cells (black lines) ---
    % Actually not needed -- commented out
    % nGuard = gmtry.nCv - gmtry.nCi;
    % R_guard = zeros(3 * nGuard, 1); % 2 pts + NaN per line
    % Z_guard = zeros(3 * nGuard, 1);
    % 
    % for k = 1:nGuard
    %     iCv = gmtry.nCi + k;
    %     iFc = gmtry.cvFc(gmtry.cvFcP(iCv,1)); % single face
    %     vx  = gmtry.fcVx(iFc,:);
    %     idx = (k-1)*3 + (1:3);
    %     R_guard(idx) = [gmtry.vxX(vx(1)); gmtry.vxX(vx(2)); NaN];
    %     Z_guard(idx) = [gmtry.vxY(vx(1)); gmtry.vxY(vx(2)); NaN];
    % end
    % 
    % % Single plot call for all guard cells
    % hGuard = plot(R_guard, Z_guard, 'k', varargin{:});
    % axis equal
        
else
    switch gmtry.nncut
        
        case 0 % no cuts
            
            rco  = [gmtry.crx(:,:,1),gmtry.crx(:,end,3);...
                gmtry.crx(end,:,2),gmtry.crx(end,end,4)];
            zco  = [gmtry.cry(:,:,1),gmtry.cry(:,end,3);...
                gmtry.cry(end,:,2),gmtry.cry(end,end,4)];
            
            h(1).h = plot(rco ,zco ,varargin{:}); hold on; % poloidal surfaces
            h(2).h = plot(rco',zco',varargin{:});          % radial surfaces
            
        case 1 % standard single null configuration
            
            
            % SOL, poloidal
            polfr  = [gmtry.crx(1:end,gmtry.topcut(1)+3:end,1),gmtry.crx(1:end,end,3);...
                gmtry.crx(end,gmtry.topcut(1)+3:end,2),gmtry.crx(end,end,4)];
            polfz  = [gmtry.cry(1:end,gmtry.topcut(1)+3:end,1),gmtry.cry(1:end,end,3);...
                gmtry.cry(end,gmtry.topcut(1)+3:end,2),gmtry.cry(end,end,4)];
            h(2).h = plot(polfr,polfz,varargin{:});
            
            hold on;
            
            
            % Core, poloidal
            polfr  = [gmtry.crx(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1,1);gmtry.crx(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1,1)];
            polfz  = [gmtry.cry(gmtry.leftcut(1)+2:gmtry.rightcut(1)+1,1:gmtry.topcut(1)+1,1);gmtry.cry(gmtry.leftcut(1)+2,1:gmtry.topcut(1)+1,1)];
            h(1).h = plot(polfr,polfz,varargin{:});
            
            
            % PFR, poloidal
            polfr  = [gmtry.crx(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1,1);gmtry.crx(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1,1);gmtry.crx(end,1:gmtry.topcut(1)+1,2)];
            polfz  = [gmtry.cry(1:gmtry.leftcut(1)+1,1:gmtry.topcut(1)+1,1);gmtry.cry(gmtry.rightcut(1)+2:end,1:gmtry.topcut(1)+1,1);gmtry.cry(end,1:gmtry.topcut(1)+1,2)];
            h(3).h = plot(polfr,polfz,varargin{:});
            
            
            % all, radial
            radfr  = [gmtry.crx(:,:,1),gmtry.crx(:,end,3);gmtry.crx(end,:,2),gmtry.crx(end,end,4)]';
            radfz  = [gmtry.cry(:,:,1),gmtry.cry(:,end,3);gmtry.cry(end,:,2),gmtry.cry(end,end,4)]';
            h(5).h = plot(radfr,radfz,varargin{:});
            
            
            % Separatrix
            h(4).h = plotsep(gmtry,varargin{:});
            
        otherwise % general case
            
            % Plot all cells as individual polygons
            nx = size(gmtry.crx,1);
            ny = size(gmtry.crx,2);
            for j = 1:ny
                for i = 1:nx
                    k = i + (j-1)*nx;
                    rco    = [gmtry.crx(i,j,1),gmtry.crx(i,j,2),gmtry.crx(i,j,4),gmtry.crx(i,j,3),gmtry.crx(i,j,1)];
                    zco    = [gmtry.cry(i,j,1),gmtry.cry(i,j,2),gmtry.cry(i,j,4),gmtry.cry(i,j,3),gmtry.cry(i,j,1)];
                    h(k).h = plot(rco,zco,varargin{:});hold on;
                end
            end
            
    end
end


