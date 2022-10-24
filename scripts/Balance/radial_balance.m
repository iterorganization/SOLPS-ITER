%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% radial_balance make balance plots with radial resolution (integrating in the %
% poloidal direction) in a given region                                        %
% flux:        An (nx*ny*nd) sized matrix, where nd is the number of different %
%              fluxes into which the total flux is decomposed. Comprising      %
%              the flux from each component in the entire grid                 %
% src:         An (nx*ny*nd) sized matrix, where nd is the number of different %
%              sources into which the total source is decomposed. Comprising   %
%              the source from each component in the entire grid               %
% res:         The code residual                                               %
% totname:     A cell of length 4 with strings stating the names of (1) the    %
%              upstream flux, (2) the downstream flux, (3) the integrated      %
%              sources, (4) the integrated residual                            %
% fluxname:    A cell of length nd with strings stating the names of each flux %
%              component                                                       %
% scrname:     A cell of length nd with strings stating the names of each      %
%              source component                                                %
% comuse:      Structure containing commonly-used variables (from get_comuse)  %
% indrad:      Logical matrix of size nx*ny that is true for cells where       %
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
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rb = radial_balance(flux,src,res,totname,fluxname,srcname,comuse,indrad,area,reverse,ismom,axbal,unitstr,makeplot,areaend)

rightix = comuse.rightix+1; % Convert to one-based
rightiy = comuse.rightiy+1;

% Fluxes through the ends:
fluxleft = [];
fluxright = [];
for i=1:size(flux,3)
    fluxleft(:,i) = findlr(flux(:,:,i),indrad,'left');
    fluxright(:,i) = findlr(flux(:,:,i),indrad,'right',rightix,rightiy);
end

% Integrated sources:
srcint = [];
for i=1:size(src,3)
    srcint(:,i) = sumpol(src(:,:,i),indrad,comuse);
end

% Integrated residual:
resint = sumpol(res,indrad,comuse);

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
if ~reverse
    fluxup = fluxleft;
    fluxdown = fluxright;
else
    fluxup = fluxright;
    fluxdown = fluxleft;
end

% Areas at the ends:
switch areaend
    case 'left'
        rb.area_divide = findlr(area,indrad,'left');
    case 'right'
        rb.area_divide = findlr(area,indrad,'right',rightix,rightiy);
    case 'none'
        rb.area_divide = ones(1,size(fluxleft,1));
end

% y - y_sep at outer mid-plane (cm):
yomp = [0,cumsum(sqrt(diff(comuse.cr(comuse.omp,:)).^2+diff(comuse.cz(comuse.omp,:)).^2))];
dys1 = sqrt(diff(comuse.cr_y(comuse.omp,comuse.sep+1:comuse.sep+2))^2+diff(comuse.cz_y(comuse.omp,comuse.sep+1:comuse.sep+2))^2);
yomp = yomp-yomp(comuse.sep+2)+dys1/2;
% psi:
tmp = abs(comuse.dv./comuse.hx.*comuse.bb(:,:,1));
psi = cumsum(tmp,2);
for ix=1:comuse.nx
    psi(ix,:)=psi(ix,:)-0.5*(psi(ix,comuse.sep+1)+psi(ix,comuse.sep+2))+1;
end
% Ensure all SOL psis take outer target value:
psi(:,comuse.sep+2:end)=repmat(psi(end,comuse.sep+2:end),comuse.nx,1);
% psi at outer mid-plane:
psiomp = psi(comuse.omp,:);
% psi downstream:
if ~reverse
    psidown = findlr(psi,indrad,'right',rightix,rightiy);
else
    psidown = findlr(psi,indrad,'left');
end
% Target distances mapped to OMP
ymysep = 100*interp1(psiomp,yomp,psidown,'linear','extrap');

% Total balance with residuals:
cmap = comuse.cmap;
coderes = momfac*(resint./rb.area_divide)';
if makeplot
    plot(ymysep,momfac*reversefac*sum(fluxup,2)./rb.area_divide','marker','.','parent',axbal(1),'displayname',totname{1},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    plot(ymysep,momfac*reversefac*sum(fluxdown,2)./rb.area_divide','marker','.','parent',axbal(1),'displayname',totname{2},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    plot(ymysep,momfac*sum(srcint,2)./rb.area_divide','marker','.','parent',axbal(1),'displayname',totname{3},'color',cmap(1,:));
    plot(ymysep,coderes,'-m','parent',axbal(1),'displayname',[totname{4},' (code)']);
end
rb.ymysep = ymysep;
rb.totflxu = momfac*reversefac*sum(fluxup,2)./rb.area_divide';
rb.totflxd = momfac*reversefac*sum(fluxdown,2)./rb.area_divide';
rb.totsrc = momfac*sum(srcint,2)./rb.area_divide';
rb.coderes = coderes;

% Check the level of agreement between post-calculated and code-calculated residuals agree:
postres = momfac*(reversefac*(sum(fluxup,2)-sum(fluxdown,2))+sum(srcint,2))./rb.area_divide';
rb.postres = postres;
if makeplot
    plot(ymysep,postres,'-g','parent',axbal(1),'displayname',[totname{4},' (post-cal.)']);
    plot(ymysep,postres-coderes,'-c','parent',axbal(1),'displayname',[totname{4},' (post-cal.-code)']);
end
% fprintf('Radial balance: the maximum difference between code- and post-calculated residuals is %e%%\n',max(abs((coderes-postres)./coderes)*100));
if makeplot
    legend(axbal(1),'show','location','best');
    title(axbal(1),'Total radial balance','fontweight','normal');
    axis(axbal(1),'tight');
    xlabel(axbal(1),'y-y_{sep} (cm)');
    ylabel(axbal(1),['(',unitstr,')']);
end

% Decompose upstream fluxes:
cmap = comuse.cmap;
for i=1:size(fluxup,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxup(:,i))
        if makeplot
            plot(ymysep,momfac*reversefac*fluxup(:,i)./rb.area_divide','marker','.','parent',axbal(2),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.flxu_dcmp{i} = momfac*reversefac*fluxup(:,i)./rb.area_divide';
end
if makeplot
    legend(axbal(2),'show','location','best');
    title(axbal(2),['Decomp. of ',totname{1}],'fontweight','normal');
    axis(axbal(2),'tight');
    xlabel(axbal(2),'y-y_{sep} (cm)');
    ylabel(axbal(2),['(',unitstr,')']);
end

% Decompose downstream fluxes:
cmap = comuse.cmap;
for i=1:size(fluxdown,2)
    % Only make the plot if the flux is non-zero somewhere
    if any(fluxdown(:,i))
        if makeplot
            plot(ymysep,momfac*reversefac*fluxdown(:,i)./rb.area_divide','marker','.','parent',axbal(3),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.flxd_dcmp{i} = momfac*reversefac*fluxdown(:,i)./rb.area_divide';
end
if makeplot
    legend(axbal(3),'show','location','best');
    title(axbal(3),['Decomp. of ',totname{2}],'fontweight','normal');
    axis(axbal(3),'tight');
    xlabel(axbal(3),'y-y_{sep} (cm)');
    ylabel(axbal(3),['(',unitstr,')']);
end

% Decompose sources:
cmap = comuse.cmap;
for i=1:size(srcint,2)
    % Only make the plot if the integrated source is non-zero somewhere
    if any(srcint(:,i))
        if makeplot
            plot(ymysep,momfac*srcint(:,i)./rb.area_divide','marker','.','parent',axbal(4),'displayname',srcname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.src_dcmp{i} = momfac*srcint(:,i)./rb.area_divide';
end
if makeplot
    legend(axbal(4),'show','location','best');
    title(axbal(4),['Decomp. of ',totname{3}],'fontweight','normal');
    axis(axbal(4),'tight');
    xlabel(axbal(4),'y-y_{sep} (cm)');
    ylabel(axbal(4),['(',unitstr,')']);
end

% Set the same axes limits for all radial balance plots:
if makeplot
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
end

rb.src_name = srcname;
