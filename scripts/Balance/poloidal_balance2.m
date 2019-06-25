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
% totname:     A cell of length 3 with strings stating the names of (1) the    %
%              flux, (2) the source, (3) the residual                          %
% fluxname:    A cell of length nd with strings stating the names of each flux %
%              component                                                       %
% scrname:     A cell of length nd with strings stating the names of each      %
%              source component                                                %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
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
function areadown = poloidal_balance2(flux,src,res,totname,fluxname,srcname,comuse,indpol,area,reverse,ismom,axbal,unitstr)

topix = comuse.topix+1;
topiy = comuse.topiy+1;
bottomix = comuse.bottomix+1;
bottomiy = comuse.bottomiy+1;
leftix = comuse.leftix+1;
leftiy = comuse.leftiy+1;
rightix = comuse.rightix+1;
rightiy = comuse.rightiy+1;
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
    fluxedge(:,i) = sumradedge(flux(:,:,i),indpol,comuse);
    
end
areaedge = sumradedge(area,indpol,comuse)';
areadown = areaedge;

% Integrated sources:
srcint = [];
for i=1:size(src,3)
    srcint(:,i) = sumrad(src(:,:,i),indpol,comuse);
end
volint = sumrad(comuse.dv,indpol,comuse)';

% Integrated residual:
resint = sumrad(res,indpol,comuse);

% Find the radial-averaged distance along the region where poloidal balance is
% to be performed:
hxav = sumrad(comuse.hx.*comuse.dv,indpol,comuse)'./volint;
bxav = sumrad(comuse.bb(:,:,1).*comuse.dv,indpol,comuse)'./volint;
bzav = sumrad(comuse.bb(:,:,3).*comuse.dv,indpol,comuse)'./volint;
dsx = zeros(length(volint)+1,1);
for ix=2:length(hxav)+1
%     dsx(ix)=dsx(ix-1)+hxav(ix);
    dsx(ix)=dsx(ix-1)+hxav(ix-1)*abs(bzav(ix-1)/bxav(ix-1));
end
ds = 0.5*(dsx(1:end-1)+dsx(2:end));

% Total balance with residuals:
cmap = comuse.cmap;
% Plot the parallel flux density:
plot(dsx,momfac*reversefac*sum(fluxedge,2)./areaedge,'marker','.','parent',axbal(1),'displayname',totname{1},'color',cmap(1,:)); cmap=circshift(cmap,-1);
% Plot the source density:
bh = axes('position',get(axbal(1),'position'));
plot(ds,momfac*sum(srcint,2)./volint,'marker','.','parent',bh,'displayname',totname{2},'color',cmap(1,:));
set(bh,'color','none','xcolor','none','yaxislocation','right','ycolor',cmap(1,:)); cmap=circshift(cmap,-1);
linkaxes([bh,axbal(1)],'x');
% Plot the parallel area at cell interfaces:
paxbal = get(axbal(1),'position');
gh1 = axes('position',get(axbal(1),'position'));
plot(dsx,areaedge,'parent',gh1,'color',cmap(1,:));
set(gh1,'color','none','xcolor','none','ycolor','none');
gh2 = axes('position',[paxbal(1)+0.15*paxbal(3),paxbal(2),paxbal(3),paxbal(4)],'yaxislocation','right','color','none','xcolor','none','ycolor',cmap(1,:)); cmap=circshift(cmap,-1);
linkaxes([gh1,axbal(1)],'x');
linkaxes([gh1,gh2],'y');
% Plot the cell volume:
gh1 = axes('position',get(axbal(1),'position'));
plot(ds,volint,'parent',gh1,'color',cmap(1,:));
set(gh1,'color','none','xcolor','none','ycolor','none');
gh2 = axes('position',[paxbal(1)+0.3*paxbal(3),paxbal(2),paxbal(3),paxbal(4)],'yaxislocation','right','color','none','xcolor','none','ycolor',cmap(1,:));
linkaxes([gh1,axbal(1)],'x');
linkaxes([gh1,gh2],'y');

coderes = momfac*(resint)';
plot(ds,coderes,'-m','parent',axbal(1),'displayname',[totname{3},' (code)']);

% Check the level of agreement between post-calculated and code-calculated residuals agree:
postres = momfac*(sum(srcint,2)-diff(sum(fluxedge,2)));
plot(ds,postres,'-g','parent',axbal(1),'displayname',[totname{3},' (post-cal.)']);
fprintf('Poloidal balance: the maximum difference between code- and post-calculated residuals is %e%%\n',max(abs((coderes-postres)./coderes)*100));

hl = legend(axbal(1),'show','location','best');
title(axbal(1),'Total poloidal balance','fontweight','normal');
axis(axbal(1),'tight');
xlabel(axbal(1),'Poloidal dist. from downstream face + 0.001m. (m)');
ylabel(axbal(1),['(',unitstr,')']);
    
% Decompose fluxes:
cmap = comuse.cmap;
for i=1:size(fluxedge,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxedge(:,i))
        plot(dsx,momfac*reversefac*fluxedge(:,i)./areaedge,'marker','.','parent',axbal(2),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    end
end
hl = legend(axbal(2),'show','location','best');
ylabel(axbal(2),['(',unitstr,')']);
xlabel(axbal(2),'Poloidal dist. from downstream face + 0.001m. (m)');
title(axbal(2),['Decomp. of ',totname{1}],'fontweight','normal');
set(axbal(2),'xlim',get(axbal(1),'xlim'));

% Decompose sources:
cmap = comuse.cmap;
for i=1:size(srcint,2)
    % Only make the plot if the source is non-zero somewhere
    if any(srcint(:,i))
        plot(ds,momfac*srcint(:,i)./volint,'marker','.','parent',axbal(3),'displayname',srcname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    end
end
hl = legend(axbal(3),'show','location','best');
set(axbal(3),'xlim',get(axbal(1),'xlim'));
ylabel(axbal(3),['(',unitstr,')']);
xlabel(axbal(3),'Poloidal dist. from downstream face + 0.001m. (m)');
title(axbal(3),['Decomp. of ',totname{2}],'fontweight','normal');
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

