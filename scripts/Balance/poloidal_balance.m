%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% poloidal_balance make balance plots with poloidal resolution (integrating in %
% the radial direction) in a given region                                      %
% flux:        An (nx*ny*nd) sized matrix, where nd is the number of different %
%              fluxes into which the total flux is decomposed. Comprising      %
%              the flux from each component in the entire grid                 %
% src:         An (nx*ny*nd) sized matrix, where nd is the number of different %
%              sources into which the total source is decomposed. Comprising   %
%              the source from each component in the entire grid               %
% res:         The code residual                                               %
% resaccuracy: The maximum acceptable percentage difference between the code-  %
%              calculated and post-calculated residual that will not throw a   %
%              warning                                                         %
% totname:     A cell of length 3 with strings stating the names of (1) the    %
%              flux, (2) the source, (3) the residual                          %
% fluxname:    A cell of length nd with strings stating the names of each flux %
%              component                                                       %
% scrname:     A cell of length nd with strings stating the names of each      %
%              source component                                                %
% geomb2:      Geometry structure created by b2getgeom                         %
% indpol:      Logical matrix of size nx*ny that is true for cells where       %
%              balance should be performed                                     %
% area:        The area by which each flux should be divided                   %
% reverse:     True if the downstream surface is to the left of the upstream   %
%              surface, otherwise false                                        %
% ismom:       True if we are performing momentum balance                      %
% axbal:       Array of axes into which balance plots will be placed           %
% unitstr:     String for units given on y axes                                %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function areadown = poloidal_balance(flux,src,res,resaccuracy,totname,fluxname,srcname,geomb2,indpol,area,reverse,ismom,axbal,unitstr)

topix = geomb2.topix+1;
topiy = geomb2.topiy+1;
bottomix = geomb2.bottomix+1;
bottomiy = geomb2.bottomiy+1;
leftix = geomb2.leftix+1;
rightix = geomb2.rightix+1;
rightiy = geomb2.rightiy+1;
if ~reverse
    reversefac = 1;
    momfac = 1;
elseif ismom
    reversefac = -1;
    momfac = -1;
else
    reversefac = -1;
    momfac = 1;
end

% Summed fluxes through the cell edges:
fluxedge = [];
for i=1:size(flux,3)
    fluxedge(:,i) = sumradedge(flux(:,:,i),indpol,geomb2);
end

% Integrated sources:
srcint = [];
for i=1:size(src,3)
    srcint(:,i) = sumrad(src(:,:,i),indpol,geomb2);
end

% Integrated residual:
resint = sumrad(res,indpol,geomb2);

% Find the poloidal distance along the first SOL ring (for single- or double-
% null cases), or along the first ring in indpol (for slab case)
% Find the left end of the balance region:
[ix0,iy0]=ind2sub(size(indpol),find(indpol,1));
ixsep = ix0;
iysep = iy0;
% Step to the first SOL ring (if not a 1d case):
if ~isempty(find(diff(geomb2.leftix(:,1))<1))
    if iysep<geomb2.sep+2 % Step up
        while iysep~=geomb2.sep+2
            ixsep = topix(ixsep,iysep);
            iysep = topiy(ixsep,iysep);
        end
    elseif iysep>geomb2.sep+2 % Step down
        while iysep~=geomb2.sep+2
            ixsep = bottomix(ixsep,iysep);
            iysep = bottomiy(ixsep,iysep);
        end
    end
end
ixleftsep = ixsep;
iyleftsep = iysep; 
dspol = geomb2.dspol(ixsep,iysep);
dspolface = 0.5*(geomb2.dspol(leftix(ixsep,iysep),iysep)+geomb2.dspol(ixsep,iysep));
while indpol(rightix(ix0,iy0),rightiy(ix0,iy0))
    ixsep = rightix(ixsep,iysep);
    iysep = rightiy(ixsep,iysep);
    ix0 = rightix(ix0,iy0);
    iy0 = rightiy(ix0,iy0);
    dspol = [dspol,geomb2.dspol(ixsep,iysep)];
    dspolface = [dspolface,0.5*(geomb2.dspol(leftix(ixsep,iysep),iysep)+geomb2.dspol(ixsep,iysep))];
end
ixrightsep = ixsep;
iyrightsep = iysep;
dspolface = [dspolface,0.5*(geomb2.dspol(ixsep,iysep)+geomb2.dspol(rightix(ixsep,iysep),iysep))];
if ~reverse
    dspol = dspolface(end)-dspol+0.001;
    dspolface = dspolface(end)-dspolface+0.001;
    areadown = area(rightix(ixrightsep,iyrightsep),rightiy(ixrightsep,iyrightsep));
else
    dspol = dspol-dspolface(1)+0.001;
    dspolface = dspolface-dspolface(1)+0.001;
    areadown = area(ixleftsep,iyleftsep);
end

% Total balance with residuals:
plot(dspolface,momfac*reversefac*sum(fluxedge,2)/areadown,'marker','.','parent',axbal(1),'displayname',totname{1});
plot(dspol,momfac*sum(srcint,2)/areadown,'marker','.','parent',axbal(1),'displayname',totname{2});
coderes = momfac*(resint/areadown)';
plot(dspol,coderes,'-m','parent',axbal(1),'displayname',totname{3});

% Check that post-calculated and code-calculated residuals agree:
postres = momfac*(sum(srcint,2)-diff(sum(fluxedge,2)))/areadown;
if any(abs((coderes-postres)./coderes)*100>resaccuracy)
    warning(['The post-calcuated and code-calculated residuals for radial balance differ by more than the\n\t',...
             ' stipulated %.2e%%. Plotting the post-calculated residual. Check before using this balance!'],resaccuracy);
    plot(dspol,postres,'-g','parent',axbal(1),'displayname','Post-cal. residual');
end
hl = legend(axbal(1),'show','location','best');
set(hl,'interpreter','latex');
title(axbal(1),'Total poloidal balance','interpreter','latex');
axis(axbal(1),'tight');
xlabel(axbal(1),'Poloidal dist. from downstream face + 0.001m. (m)','interpreter','latex');
ylabel(axbal(1),['(',unitstr,')'],'interpreter','latex');
    
% Decompose fluxes:
for i=1:size(fluxedge,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxedge(:,i))
        plot(dspolface,momfac*reversefac*fluxedge(:,i)./areadown','marker','.','parent',axbal(2),'displayname',fluxname{i});
    end
end
hl = legend(axbal(2),'show','location','best');
set(hl,'interpreter','latex');
ylabel(axbal(2),['(',unitstr,')'],'interpreter','latex');
xlabel(axbal(2),'Poloidal dist. from downstream face + 0.001m. (m)','interpreter','latex');
title(axbal(2),['Decomp. of ',totname{1}],'interpreter','latex');
set(axbal(2),'xlim',get(axbal(1),'xlim'));

% Decompose sources:
for i=1:size(srcint,2)
    % Only make the plot if the source is non-zero somewhere
    if any(srcint(:,i))
        plot(dspol,momfac*srcint(:,i)./areadown','marker','.','parent',axbal(3),'displayname',srcname{i});
    end
end
hl = legend(axbal(3),'show','location','best');
set(hl,'interpreter','latex');
set(axbal(3),'xlim',get(axbal(1),'xlim'));
ylabel(axbal(3),['(',unitstr,')'],'interpreter','latex');
xlabel(axbal(3),'Poloidal dist. from downstream face + 0.001m. (m)','interpreter','latex');
title(axbal(3),['Decomp. of ',totname{2}],'interpreter','latex');
set(axbal(3),'xlim',get(axbal(1),'xlim'));

% Set the same axes limits for all poloidal balance plots:
ymin = 1E40;
ymax = -1E40;
for iax=1:length(axbal)
    a = findobj(get(axbal(iax),'children'),'type','line');
    for il=1:length(a)
        if min(get(a(il),'ydata'))<ymin
            ymin = min(min(get(a(il),'ydata')));
        end
        if max(get(a(il),'ydata'))>ymax
            ymax = max(get(a(il),'ydata'));
        end
    end
end
if (ymin~=ymax)
    set(axbal,'ylim',[ymin ymax]);
end

