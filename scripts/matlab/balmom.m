function balmom(MDSno,indbal,iyplot,geomb2,axbal,reverse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balmom  plots the total pressure balance for a given MDSPlus-catalogued      %
% SOLPS run.                                                                   %
% MDSno:   MDSPlus shotnumber for this catalogued case                         %
% indbal:  Logical matrix of size nx*ny that is true for cells where balance   %
%          should be performed                                                 %
% iyplot:  Array of y indices along which poloidal balance will be plotted     %
%          (within the volume specified by indbal)                             %
% geomb2:  Geometry structure created by b2getgeom                             %
% axbal:   Array of axes into which balance plots will be placed               %
% reverse: True if the right-most end of the balance volume is upstream of the %
%          left-most, otherwise false                                          %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) August 2015. Based on the balances  %
% presented in Kotov and Reiter, PPCF 51 (2009) 115002.                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constants:
constants.ECHARGE = 1.602176565e-19; % Electron charge
constants.MP=1.672621777e-27; % Proton mass

% Shorthand for geometry variables:
nx = geomb2.nx;
ny = geomb2.ny;
ns = geomb2.ns;
leftix = geomb2.leftix+1;  % Convert to one-based
leftiy = geomb2.leftiy+1;
rightix = geomb2.rightix+1;
rightiy = geomb2.rightiy+1;
bottomix = geomb2.bottomix+1;
bottomiy = geomb2.bottomiy+1;
topix = geomb2.topix+1;
topiy = geomb2.topiy+1;

%% Obtain required arrays from server...
% Open the required MDSPlus case:
mdsopen('solps-mdsplus.aug.ipp.mpg.de:8001::solps',MDSno);
% Momentum sources:
smo = mdsvalue('\SOLPS::TOP.SNAPSHOT:SMO');
smq = mdsvalue('\SOLPS::TOP.SNAPSHOT:SMQ');
smav = mdsvalue('\SOLPS::TOP.SNAPSHOT:SMAV');
% Total momentum fluxes on left and bottom faces:
fmox = cat(1,zeros(1,ny,ns),mdsvalue('\SOLPS::TOP.SNAPSHOT:FMOX'));
fmoy = cat(2,zeros(nx,1,ns),mdsvalue('\SOLPS::TOP.SNAPSHOT:FMOY'));
% Other things needed:
ua = mdsvalue('\SOLPS::TOP.SNAPSHOT:UA'); %  Ion parallel velocity
za = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:ZA'); % Species charge
dv = mdsvalue('\SOLPS::TOP.SNAPSHOT:VOL'); % Cell volume
am = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:AM'); % Species mass
B = mdsvalue('\SOLPS::TOP.SNAPSHOT:B'); % B field
ne = mdsvalue('\SOLPS::TOP.SNAPSHOT:NE'); % Electron density
na = mdsvalue('\SOLPS::TOP.SNAPSHOT:NA'); % Ion density
% Ion flux on left and bottom faces:
fnax = cat(1,zeros(1,ny,ns),mdsvalue('\SOLPS::TOP.SNAPSHOT:FNAX'));
fnay = cat(2,zeros(nx,1,ns),mdsvalue('\SOLPS::TOP.SNAPSHOT:FNAY'));
te = mdsvalue('\SOLPS::TOP.SNAPSHOT:TE'); % Electron temperature
ti = mdsvalue('\SOLPS::TOP.SNAPSHOT:TI'); % Ion temperature
hx = mdsvalue('\SOLPS::TOP.SNAPSHOT:HX'); % hx
% residual:
resmo = mdsvalue('\SOLPS::TOP.SNAPSHOT:RESMO');
mdsclose;
%%

%% Calculate the total sources from their linearised components (see b2cdcv.F):
rob = constants.MP*repmat(reshape(am,[1 1 ns]),[nx ny 1]).*na;
smo = squeeze(smo(:,:,1,:)) + ...
             squeeze(smo(:,:,2,:)).*ua +...
             squeeze(smo(:,:,3,:)).*rob +...
             squeeze(smo(:,:,4,:)).*rob.*ua;
smq = squeeze(smq(:,:,1,:)) + ...
             squeeze(smq(:,:,2,:)).*ua +...
             squeeze(smq(:,:,3,:)).*rob +...
             squeeze(smq(:,:,4,:)).*rob.*ua;
smav = squeeze(smav(:,:,1,:)) + ...
              squeeze(smav(:,:,2,:)).*ua +...
              squeeze(smav(:,:,3,:)).*rob +...
              squeeze(smav(:,:,4,:)).*rob.*ua;         
smotot = sum(smo(:,:,za>0),3);
smqtot = sum(smq(:,:,za>0),3);
smavtot = sum(smav(:,:,za>0),3);
%%

%% Calculate the static and total pressure forces...
% Static pressure force at cell centres:
psf = dv./hx.*abs(B(:,:,1)./B(:,:,4)).*...
      (ne.*te+sum(na(:,:,za>0),3).*ti)*constants.ECHARGE;
% Parallel area at cell centres:
apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
% Map to left cell face (N.B. this mapping is not exact! Do not expect to
% exactly recover the calculated residual using this mapping):
psfx = zeros(nx,ny);
apllx = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if leftix(ix,iy)<1
            continue;
        end
        psfx(ix,iy) = (psf(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
                       psf(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
                      (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
        apllx(ix,iy) = (apll(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
                        apll(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
                       (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
    end
end
% Ion dynamic pressure force at left faces (see b2urmo.F, line 104):
flo = constants.MP*repmat(reshape(am,[1 1 ns]),[nx ny 1]).*fnax;
fmodx = zeros(nx,ny,ns);
for is=1:ns
    for iy=1:ny
        for ix=1:nx
            if leftix(ix,iy)<1
                continue;
            end
            fmodx(ix,iy,is) = flo(ix,iy,is)*...
                              (ua(ix,iy,is)+...
                               ua(leftix(ix,iy),leftiy(ix,iy),is))/2;
        end
    end
end
% Viscous component at left faces:
fmovx = fmox-fmodx;
% Total pressure force at left cell faces:
ptotx = sum(fmodx(:,:,za>0),3)+psfx;
pvisx = sum(fmovx(:,:,za>0),3);
%%

%% Calculate the geometric term (again this is not exact. One would need to 
 %  exactly decompose smag, as calculated in b2sigp.F)...
pstot = ne.*te*constants.ECHARGE + sum(na(:,:,za>0),3).*ti*constants.ECHARGE;
wrk = dv./hx.*abs(B(:,:,1)./B(:,:,4));
pgm = zeros(nx,ny);
for iy=1:ny
    for ix=1:nx
        if rightix(ix,iy)>nx || leftix(ix,iy)<1
            continue;
        end
        pgm(ix,iy) = pstot(ix,iy)*dv(ix,iy)*...
                     ((wrk(ix,iy)-wrk(leftix(ix,iy),leftiy(ix,iy)))/...
                      (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)))+...
                      (wrk(rightix(ix,iy),rightiy(ix,iy))-wrk(ix,iy))/...
                      (dv(ix,iy)+dv(rightix(ix,iy),rightiy(ix,iy))));
    end
end
%%

%% Calculate the radial divergences...
% Dynamic force on bottom cell faces (see b2urmo.F, line 118):
flo = constants.MP*repmat(reshape(am,[1 1 ns]),[nx ny 1]).*fnay;
fmody = zeros(nx,ny,ns);
for is=1:ns
    for iy=1:ny
        for ix=1:nx
            if bottomiy(ix,iy)<1
                continue;
            end
            fmody(ix,iy,is) = flo(ix,iy,is)*...
                              (ua(ix,iy,is)+...
                               ua(bottomix(ix,iy),bottomiy(ix,iy),is))/2;
        end
    end
end
% Viscous force on bottom cell faces:
fmovy = fmoy-fmody;
raddivv = zeros(nx,ny); % total radial divergence (viscous)
raddivd = zeros(nx,ny); % total radial divergence (dynamic)
fmodytot = sum(fmody,3);
fmovytot = sum(fmovy,3);
for iy=1:ny
    for ix=1:nx
        if topiy(ix,iy)>ny
            continue;
        end
        raddivv(ix,iy) = fmovytot(ix,iy)-fmovytot(topix(ix,iy),topiy(ix,iy));
        raddivd(ix,iy) = fmodytot(ix,iy)-fmodytot(topix(ix,iy),topiy(ix,iy));
    end
end
%%

%% Calculate quantities for plotting integrated balance...
resmotot = sum(resmo(:,:,za>0),3);
ptotleft = []; % Total pressure force on left-most face of balance volume
ptotright = []; % Total pressure force on right-most face of balance volume
psleft = []; % Static pressure force on left-most face of balance volume
psright = []; % Static pressure force on right-most face of balance volume
neutint = []; % Integral of neutral source
raddivvint = []; % Integral of radial divergence of radial viscosity force
raddivdint = []; % Integral of radial divergence of dynamic force
visleft = [];
visright = [];
geomint = [];
smqsmavint = []; % Integral of smq and smav (should be zero I think)
resint = []; % Integral of residual
iyvol = []; % y indeces in volume
apllleft = []; % Parallel areas at left-most face of balance volume
apllright = []; % Parallel areas at right-most face of balance volume
for iy=1:ny
    inds = find(indbal(:,iy));
    if ~isempty(inds)
        ptotleft = [ptotleft,ptotx(inds(1),iy)];
        ptotright = [ptotright,...
                     ptotx(rightix(inds(end),iy),rightiy(inds(end),iy))];
        psleft = [psleft,psfx(inds(1),iy)];
        psright = [psright,psfx(rightix(inds(end),iy),rightiy(inds(end),iy))];
        neutint = [neutint,sum(smotot(inds,iy))];
        raddivvint = [raddivvint,sum(raddivv(inds,iy))];
        raddivdint = [raddivdint,sum(raddivd(inds,iy))];
        visleft = [visleft,pvisx(inds(1),iy)];
        visright = [visright,pvisx(rightix(inds(end),iy),rightiy(inds(end),iy))];
        geomint = [geomint,sum(pgm(inds,iy))];
        smqsmavint = [smqsmavint,sum(smqtot(inds,iy))+...
                                 sum(smavtot(inds,iy))];
        resint = [resint,sum(resmotot(inds,iy))];
        iyvol = [iyvol,iy];
        apllleft = [apllleft,apllx(inds(1),iy)];
        apllright = [apllright,...
                     apllx(rightix(inds(end),iy),rightiy(inds(end),iy))];
    end
end
othsource = visleft - visright + raddivvint + raddivdint + geomint + smqsmavint;
%%

%% Make plots...
% Account for balance in -x direction:
if ~reverse
    ptotup = ptotleft;
    ptotdown = ptotright;
    psup = psleft;
    psdown = psright;
    visup = visleft;
    visdown = visright;
    aplldown = apllright;
    sourcefac = 1;
else
    ptotup = ptotright;
    ptotdown = ptotleft;
    psup = psright;
    psdown = psleft;
    visup = visright;
    visdown = visleft;
    aplldown = apllleft;
    sourcefac = -1;
end
% R - R_sep at outer mid-plane (cm):
rmrsep = 100*(geomb2.cr(geomb2.omp,iyvol)-geomb2.cr_y(geomb2.omp,geomb2.sep+1));
% Integrated balance:
h1 = plot(rmrsep,ptotup./aplldown,'-b','marker','.',...
          'parent',axbal(1),'displayname','Effective upstream');
plot(rmrsep,psup./aplldown,'-g','marker','.',...
     'parent',axbal(1),'displayname','Static upstream');
h2 = plot(rmrsep,ptotdown./aplldown,'-r','marker','.',...
          'parent',axbal(1),'displayname','Effective downstream');
h3 = plot(rmrsep,sourcefac*neutint./aplldown,'-k','marker','.',...
          'parent',axbal(1),'displayname','Neutral source');
h4 = plot(rmrsep,sourcefac*othsource./aplldown,'-c','marker','.',...
          'parent',axbal(1),'displayname','Other sources');
tmp = cell2mat(get([h1 h2 h3 h4],'ydata'));
plot(rmrsep,tmp(1,:)-tmp(2,:)+tmp(3,:)+tmp(4,:),...
     '-m','parent',axbal(1),'displayname','Error');
plot(rmrsep,sourcefac*resint./aplldown,...
     '-m','parent',axbal(1),'displayname','Residual');
hl = legend(axbal(1),'show','location','best');
set(hl,'box','off');
title(axbal(1),'Integrated balance','fontweight','normal');
axis(axbal(1),'tight');
xlabel(axbal(1),'R-R_{sep} at OMP (cm)');
ylabel(axbal(1),'Pressure (Pa)');
% Decompose source terms:
plot(rmrsep,sourcefac*neutint./aplldown,'-r','marker','.',...
     'parent',axbal(2),'displayname','Neutral source');
plot(rmrsep,sourcefac*(visleft-visright)./aplldown,'-g','marker','.',...
     'parent',axbal(2),'displayname','Par. viscosity');
plot(rmrsep,sourcefac*raddivvint./aplldown,'-b','marker','.',...
     'parent',axbal(2),'displayname','Perp. viscosity');
plot(rmrsep,sourcefac*raddivdint./aplldown,'-c','marker','.',...
     'parent',axbal(2),'displayname','div(mnu_{par}u_{perp})');
plot(rmrsep,sourcefac*geomint./aplldown,'-k','marker','.',...
     'parent',axbal(2),'displayname','Geom. term');
plot(rmrsep,sourcefac*smqsmavint./aplldown,'-m','marker','.',...
     'parent',axbal(2),'displayname','smq+smav');
hl = legend(axbal(2),'show','location','best');
set(hl,'box','off');
title(axbal(2),'Other sources','fontweight','normal');
axis(axbal(2),'tight');
xlabel(axbal(2),'R-R_{sep} at OMP (cm)');
ylabel(axbal(2),'Pressure (Pa)');

% Poloidal balance:
axextra = axes;
hold(axextra,'on');           
for iy=iyplot
    inds = find(indbal(:,iy));
    if ~isempty(inds)
        dspolface = [0.5*(geomb2.dspol(leftix(inds,iy),iy)+...
                          geomb2.dspol(inds,iy));...
                     0.5*(geomb2.dspol(inds(end),iy)+...
                          geomb2.dspol(rightix(inds(end),iy),iy))];
        if ~reverse
            aplldown = apllx(rightix(inds(end),iy),rightiy(inds(end),iy));
        else
            aplldown = apllx(inds(1),iy);
        end
        h1 = plot(dspolface,...
                  [ptotx(inds,iy);...
                   ptotx(rightix(inds(end),iy),iy)]/aplldown,...
                  '-b','marker','.','parent',axbal(3),...
                  'displayname',...
                           [num2str(iy),': Effective pressure on cell face']);
        plot(dspolface,...
             [psfx(inds,iy);psfx(rightix(inds(end),iy),iy)]/aplldown,...
             '-g','marker','.','parent',axbal(3),...
             'displayname',[num2str(iy),': Static pressure on cell face']);
        h2 = plot(geomb2.dspol(inds,iy),smotot(inds,iy)/aplldown,...
                  '-k','marker','.','parent',axextra,...
                  'displayname',[num2str(iy),': Neutral source']);
        h3 = plot(geomb2.dspol(inds,iy),...
                  (-diff([pvisx(inds,iy);pvisx(rightix(inds(end),iy),iy)])+...
                   raddivv(inds,iy)+...
                   raddivd(inds,iy)+...
                   smqtot(inds,iy)+...
                   smavtot(inds,iy)+...
                   pgm(inds,iy))/aplldown,...
                  '-c','marker','.','parent',axextra,...
                  'displayname',[num2str(iy),': Other sources']);
        plot(geomb2.dspol(inds,iy),...
             diff(get(h1,'ydata'))-(get(h2,'ydata')+get(h3,'ydata')),...
             '-m','parent',axextra,...
             'displayname',[num2str(iy),': Error']);
        plot(geomb2.dspol(inds,iy),resmotot(inds,iy)/aplldown,...
             '-m','parent',axextra,...
             'displayname',[num2str(iy),': Residual']);
    end
end
hl = legend(axbal(3),'show','location','northwest');
set(hl,'box','off');
ylabel(axbal(3),'Pressure (Pa)');
xlabel(axbal(3),'Poloidal distance (m)');
title(axbal(3),'Poloidal balance','fontweight','normal');
ylabel(axextra,'sources (Pa)');
hl = legend(axextra,'show','location','southeast');
set(hl,'box','off');
axis([axbal(3) axextra],'tight');
set([axbal(3) axextra],'box','off');
xlim = get(axextra,'xlim');
if ~reverse
    set(axextra,'xtick',xlim,'xticklabel',{'up','down'});
else
    set(axextra,'xtick',xlim,'xticklabel',{'down','up'});
end
set(axextra,'yaxislocation','right','xaxislocation','top',...
           'position',get(axbal(3),'position'),'color','none');
% Decompose source terms:
for iy=iyplot
    inds = find(indbal(:,iy));
    if ~isempty(inds)
        if ~reverse
            aplldown = apllx(rightix(inds(end),iy),rightiy(inds(end),iy));
        else
            aplldown = apllx(inds(1),iy);
        end
        plot(geomb2.dspol(inds,iy),smotot(inds,iy)/aplldown,...
             '-r','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': Neutral source']);
        plot(geomb2.dspol(inds,iy),...
             -diff([pvisx(inds,iy);pvisx(rightix(inds(end),iy),iy)])/...
             aplldown,...
             '-g','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': Par. viscosity']);
        plot(geomb2.dspol(inds,iy),raddivv(inds,iy)/aplldown,...
             '-b','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': Perp. viscosity']);
        plot(geomb2.dspol(inds,iy),raddivd(inds,iy)/aplldown,...
             '-c','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': div(mnu_{par}u_{perp})']);
        plot(geomb2.dspol(inds,iy),pgm(inds,iy)/aplldown,...
             '-k','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': Geom. term']);
        plot(geomb2.dspol(inds,iy),...
             (smqtot(inds,iy)+smavtot(inds,iy))/aplldown,...
             '-m','marker','.','parent',axbal(4),...
             'displayname',[num2str(iy),': smq+smav']);
    end
end
hl = legend(axbal(4),'show','location','best');
set(hl,'box','off');
title(axbal(4),'Other sources','fontweight','normal');
ylabel(axbal(4),'Pressure (Pa)');
xlabel(axbal(4),'Poloidal distance (m)');
axis(axbal(4),'tight');
%%
end




