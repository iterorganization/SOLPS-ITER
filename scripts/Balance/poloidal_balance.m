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
% areaend:     Either 'left', 'right' or 'none'. Defines the poloidal end      %
%              of the balance region at which areas will be calculated. The    %
%              poloidal fluxes at both ends will then be divided by these      %
%              areas to give flux densities.                                   %
% polbaldist:  Either 'parallel' or 'poloidal'. Defines the distance used      %
%              on the x-axis of the poloidal balance plots. Distances are      %
%              mapped to the first SOL ring.                                   %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function area_divide = poloidal_balance(flux,src,res,totname,fluxname,srcname,comuse,indpol,area,reverse,ismom,axbal,unitstr,areaend,polbaldist)

topix = comuse.topix+1;
topiy = comuse.topiy+1;
bottomix = comuse.bottomix+1;
bottomiy = comuse.bottomiy+1;
rightix = comuse.rightix+1;
rightiy = comuse.rightiy+1;

% Summed fluxes through the cell edges:
fluxedge = [];
for i=1:size(flux,3)
    fluxedge(:,i) = sumradedge(flux(:,:,i),indpol,comuse);
end

% Integrated sources:
srcint = [];
for i=1:size(src,3)
    srcint(:,i) = sumrad(src(:,:,i),indpol,comuse);
end

% Integrated residual:
resint = sumrad(res,indpol,comuse);

% Account for reversal (normally inner-to-outer fluxes are positive but if
% reverse==true then outer-to-inner fluxes become positive):
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
if ismom
    momfac = momfac*-sign(mean(mean(comuse.bb(:,:,3))));
end

% Areas at the ends:
switch areaend
    case 'left'
        area_divide = sum(findlr(area,indpol,'left',rightix,rightiy));
    case 'right'
        area_divide = sum(findlr(area,indpol,'right',rightix,rightiy));
    case 'none'
        area_divide = 1;
end

% Find the poloidal distance along the first SOL ring (for single- or double-
% null cases), or along the first ring in indpol (for slab case)
% Find the left end of the balance region:
[ix0,iy0]=ind2sub(size(indpol),find(indpol,1));
ixsep = ix0;
iysep = iy0;
% Step to the first SOL ring (if not a 1d case):
if ~isempty(find(diff(comuse.leftix(:,1))<1,1))
    if iysep<comuse.sep+2 % Step up
        while iysep~=comuse.sep+2
            ixsep = topix(ixsep,iysep);
            iysep = topiy(ixsep,iysep);
        end
    elseif iysep>comuse.sep+2 % Step down
        while iysep~=comuse.sep+2
            ixsep = bottomix(ixsep,iysep);
            iysep = bottomiy(ixsep,iysep);
        end
    end
end
switch polbaldist
    case 'parallel'
        dist2D = comuse.dspar;
        dist2Dx = comuse.dsparx;
    case 'poloidal'
        dist2D = comuse.dspol;
        dist2Dx = comuse.dspolx;
    otherwise
        error('Poloidal balance distance ''%s'' not supported.',polbaldist);
end
xdata = dist2D(ixsep,iysep);
xdatax = dist2Dx(ixsep,iysep);
while indpol(rightix(ix0,iy0),rightiy(ix0,iy0))
    ixsep = rightix(ixsep,iysep);
    iysep = rightiy(ixsep,iysep);
    ix0 = rightix(ix0,iy0);
    iy0 = rightiy(ix0,iy0);
    xdata = [xdata,dist2D(ixsep,iysep)];
    xdatax = [xdatax,dist2Dx(ixsep,iysep)];
end
xdatax = [xdatax,dist2Dx(rightix(ixsep,iysep),iysep)];

% Total balance with residuals:
cmap = comuse.cmap;
plot(xdatax,momfac*reversefac*sum(fluxedge,2)/area_divide,'marker','.','parent',axbal(1),'displayname',totname{1},'color',cmap(1,:)); cmap=circshift(cmap,-1);
plot(xdata,momfac*sum(srcint,2)/area_divide,'marker','.','parent',axbal(1),'displayname',totname{2},'color',cmap(1,:));
coderes = momfac*(resint/area_divide)';
plot(xdata,coderes,'-m','parent',axbal(1),'displayname',[totname{3},' (code)']);

% Check the level of agreement between post-calculated and code-calculated residuals agree:
postres = momfac*(sum(srcint,2)-diff(sum(fluxedge,2)))/area_divide;
plot(xdata,postres,'-g','parent',axbal(1),'displayname',[totname{3},' (post-cal.)']);
plot(xdata,postres-coderes,'-c','parent',axbal(1),'displayname',[totname{3},' (post-cal.-code)']);
% fprintf('Poloidal balance: the maximum difference between code- and post-calculated residuals is %e%%\n',max(abs((coderes-postres)./coderes)*100));

legend(axbal(1),'show','location','best');
title(axbal(1),'Total poloidal balance','fontweight','normal');
axis(axbal(1),'tight');
xlabel(axbal(1),[polbaldist,' dist. from inn. tar. along 1st SOL ring (m)']);
ylabel(axbal(1),['(',unitstr,')']);
    
% Decompose fluxes:
cmap = comuse.cmap;
for i=1:size(fluxedge,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxedge(:,i))
        plot(xdatax,momfac*reversefac*fluxedge(:,i)./area_divide','marker','.','parent',axbal(2),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    end
end
legend(axbal(2),'show','location','best');
ylabel(axbal(2),['(',unitstr,')']);
xlabel(axbal(2),[polbaldist,' dist. from inn. tar. along 1st SOL ring (m)']);
title(axbal(2),['Decomp. of ',totname{1}],'fontweight','normal');
set(axbal(2),'xlim',get(axbal(1),'xlim'));

% Decompose sources:
cmap = comuse.cmap;
for i=1:size(srcint,2)
    % Only make the plot if the source is non-zero somewhere
    if any(srcint(:,i))
        plot(xdata,momfac*srcint(:,i)./area_divide','marker','.','parent',axbal(3),'displayname',srcname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    end
end
legend(axbal(3),'show','location','best');
set(axbal(3),'xlim',get(axbal(1),'xlim'));
ylabel(axbal(3),['(',unitstr,')']);
xlabel(axbal(3),[polbaldist,' dist. from inn. tar. along 1st SOL ring (m)']);
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

