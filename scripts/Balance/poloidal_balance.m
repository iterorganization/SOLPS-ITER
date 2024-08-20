%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% poloidal_balance make balance plots with poloidal resolution (integrating in %
% the radial direction) in a given region                                      %
% flux:        An (nCv*nd) sized matrix, where nd is the number of different   %
%              fluxes into which the total flux is decomposed. Comprising      %
%              the flux from each component in the entire grid                 %
% src:         An (nCv*nd) sized matrix, where nd is the number of different   %
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
% facesup_pol: List of faces of the upstream boundary of indpol                %
% facesdown:   List of faces of the downstream boundary of indpol              %
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
% len:         Optional argument to specify the number of fluxes that need     %
%              to be used to correct the radial balance.                       %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) August 2024 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function area_divide = poloidal_balance(flux,src,res,totname,fluxname,srcname,comuse,indpol,facesup_pol,facesdown_pol,area,reverse,ismom,axbal,unitstr,areaend,polbaldist,len)

if nargin <= 17
    len = size(flux,2);
end

% Summed fluxes and integrated sources and residuals:
[fluxedge,srcint,resint,xdata,xdatax] = sumrad(flux,src,res,indpol,facesup_pol,facesdown_pol,comuse,polbaldist);

% Correct the radial divergences for fluxes that are already in fluxedge
for i = 1:size(srcint,1)
    srcint(i,1:len) = srcint(i,1:len) - fluxedge(i,1:len) + fluxedge(i+1,1:len);
end

% Account for reversal (normally inner-to-outer fluxes are positive but if
% reverse==true then outer-to-inner fluxes become positive):
if ~reverse
    momfac = 1;
elseif ismom
    momfac = -1;
else
    momfac = 1;
end
if ismom
    momfac = momfac*-sign(mean(comuse.cvEb(:,3)));
end

% Areas at the ends:
switch areaend
    case 'left'
        if reverse
            faces = facesdown_pol;
        else
            faces = facesup_pol;
        end
    case 'right'
        if reverse
            faces = facesup_pol;
        else
            faces = facesdown_pol;
        end
end
area_divide = sum(area(faces));

% Total balance with residuals:
cmap = comuse.cmap;
plot(xdatax,momfac*sum(fluxedge,2)/area_divide,'marker','.','parent',axbal(1),'displayname',totname{1},'color',cmap(1,:)); cmap=circshift(cmap,-1);
plot(xdata,momfac*sum(srcint,2)/area_divide,'marker','.','parent',axbal(1),'displayname',totname{2},'color',cmap(1,:));
coderes = momfac*(resint/area_divide);
plot(xdata,coderes,'-m','parent',axbal(1),'displayname',[totname{3},' (code)']);

% Check the level of agreement between post-calculated and code-calculated residuals agree:
postres = momfac*(sum(srcint,2)-diff(sum(fluxedge,2)))/area_divide;
plot(xdata,postres,'-g','parent',axbal(1),'displayname',[totname{3},' (post-cal.)']);
plot(xdata,postres-coderes,'-c','parent',axbal(1),'displayname',[totname{3},' (post-cal.-code)']);
% fprintf('Poloidal balance: the maximum difference between code- and post-calculated residuals is %e%%\n',max(abs((coderes-postres)./coderes)*100));

legend(axbal(1),'show','location','best');
title(axbal(1),'Total poloidal balance','fontweight','normal');
axis(axbal(1),'tight');
xlabel(axbal(1),[polbaldist,' dist. from downstream boundary (m)']);
ylabel(axbal(1),['(',unitstr,')']);
    
% Decompose fluxes:
cmap = comuse.cmap;
for i=1:size(fluxedge,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxedge(:,i))
        plot(xdatax,momfac*fluxedge(:,i)./area_divide','marker','.','parent',axbal(2),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    end
end
legend(axbal(2),'show','location','best');
ylabel(axbal(2),['(',unitstr,')']);
xlabel(axbal(2),[polbaldist,' dist. from downstream boundary (m)']);
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
xlabel(axbal(3),[polbaldist,' dist. from downstream boundary (m)']);
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

