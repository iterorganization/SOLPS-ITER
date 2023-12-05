function h = plotgeo_us(geo_us,type,varargin)

% h = plotgeo_us(geo_us,options)
%
% Routine to plot grid
%
% Input arguments
%
% - geo_us : struct read from traduitoutb2us-file
% - options : list of plot options compatible with Matlab plot command
%
% Output arguments:
%
% -h : struct with vectors of handles to the plot objects

% Check current status of hold
hs = ishold;

if nargin == 2
    color = 'k';
elseif nargin == 3
    color = varargin{1};
end

% Unpack
try
cell = geo_us.cell;
face = geo_us.face;
vert = geo_us.vert;
catch
    cell = struct('face',geo_us.cvFc,'faceP',geo_us.cvFcP,'ntot',geo_us.nCv,...
        'vert',geo_us.cvVx,'vertP',geo_us.cvVxP);
    face = struct('vert',geo_us.fcVx);
    vert = struct('x',geo_us.vxX,'y',geo_us.vxY);
end

if nargin == 1
    type = 'colors';
end

switch type
    case 'colors'

% Init output
h  = struct('h',[]);

for iCv = 1:cell.ntot
    rco = [];
    zco = [];
    s = cell.faceP(iCv,1);
    for iFc = 1:cell.faceP(iCv,2)
        rco    = [rco,[vert.x(face.vert(cell.face(s+iFc-1),1));...
                 vert.x(face.vert(cell.face(s+iFc-1),2))]];
        zco    = [zco,[vert.y(face.vert(cell.face(s+iFc-1),1));...
                 vert.y(face.vert(cell.face(s+iFc-1),2))]];
    end



%    if (cell.cflags(iCv) == 1)
        h(iCv).h = plot(rco,zco,'k');hold on;
%    elseif (geo_us.cflags(iCv) == 3)
%        h(iCv).h = plot(rco,zco,'r');hold on;
%    else
%        h(iCv).h = plot(rco,zco,'k');hold on;
%    end

end

    case 'fast'

        maxnvpc = max(cell.vertP(:,2));
        plotvecx = NaN((maxnvpc+2)*cell.ntot,1); % +2 to account for NaNs and extra vert
        plotvecy = NaN(size(plotvecx));
        k = 0;
        for iC = 1:cell.ntot
            % Add to plotter
            s = cell.vertP(iC,1);
            n = cell.vertP(iC,2);
            tcv = cell.vert(s:s+n-1);
            tcv = [tcv' tcv(1)]; % add first vertex
            plotvecx(k+1:k+n+1) = vert.x(tcv);
            plotvecy(k+1:k+n+1) = vert.y(tcv);
            k = k + n + 2;
        end
        plot(plotvecx, plotvecy,'Color',color),hold on

        plot(vert.x,vert.y,'r.','MarkerSize',3);


    case 'fastk'
        maxnvpc = max(cell.vertP(:,2));
        plotvecx = NaN((maxnvpc+2)*cell.ntot,1); % +2 to account for NaNs and extra vert
        plotvecy = NaN(size(plotvecx));
        k = 0;
        for iC = 1:cell.ntot
            % Add to plotter
            s = cell.vertP(iC,1);
            n = cell.vertP(iC,2);
            tcv = cell.vert(s:s+n-1);
            tcv = [tcv' tcv(1)]; % add first vertex
            plotvecx(k+1:k+n+1) = vert.x(tcv);
            plotvecy(k+1:k+n+1) = vert.y(tcv);
            k = k + n + 2;
        end
        plot(plotvecx, plotvecy,'Color',color),hold on

        %plot(vert.x,vert.y,'r.','MarkerSize',3);

    otherwise
        error('plotgeo_us: type not specified')
end


% Reset status of hold
if ~hs, hold off; end;
