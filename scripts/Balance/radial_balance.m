%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% radial_balance make balance plots with radial resolution (integrating in the %
% poloidal direction) in a given region                                        %
% flux:        An (nFc*nd) sized matrix, where nd is the number of different   %
%              fluxes into which the total flux is decomposed. Comprising      %
%              the flux from each component in the entire grid                 %
% src:         An (nCv*nd) sized matrix, where nd is the number of different   %
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
% indrad:      Logical matrix of size nCv that is true for cells where         %
%              balance should be performed                                     %
% facesup:     List of faces of the upstream boundary                          %
% facesdown:   List of faces of the downstream boundary                        %
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
% Widegrid adaptation by Niels Horsten (niels.horsten@kuleuven.be) July 2024   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rb = radial_balance(flux,src,res,totname,fluxname,srcname,comuse,indrad,facesup,facesdown,area,reverse,ismom,axbal,unitstr,makeplot,areaend)

% Fluxes through the ends of each flux tube present in indrad:
fluxup = zeros(comuse.nFt,size(flux,2));
for i = 1:length(facesup)
    iFc = facesup(i);
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if indrad(iCv1)
        iFt = comuse.cvFt(iCv1);
        fluxup(iFt,:) = fluxup(iFt,:) - flux(iFc,:);
    else
        iFt = comuse.cvFt(iCv2);
        fluxup(iFt,:) = fluxup(iFt,:) + flux(iFc,:);
    end
end
fluxdown = zeros(comuse.nFt,size(flux,2));
for i = 1:length(facesdown)
    iFc = facesdown(i);
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if indrad(iCv1)
        iFt = comuse.cvFt(iCv1);
        fluxdown(iFt,:) = fluxdown(iFt,:) + flux(iFc,:);
    else
        iFt = comuse.cvFt(iCv2);
        fluxdown(iFt,:) = fluxdown(iFt,:) - flux(iFc,:);
    end
end

% Integrated sources and residual:
srcint = zeros(comuse.nFt,size(src,2));
resint = zeros(comuse.nFt,1);
for iFt = 1:comuse.nFt % integration in flux tube
    iCv1 = comuse.ftCvP(iFt,1);
    iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
    for i = iCv1:iCv2
        iCv = comuse.ftCv(i);
        if indrad(iCv)
            srcint(iFt,:) = srcint(iFt,:) + src(iCv,:);
            resint(iFt) = resint(iFt) + res(iCv);
        end
    end
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

% Areas at the ends of each flux tube present in indrad:
rb.area_divide = zeros(comuse.nFt,1);
switch areaend
    case 'left'
        if reverse
            faces = facesdown;
        else
            faces = facesup;
        end
    case 'right'
        if reverse
            faces = facesup;
        else
            faces = facesdown;
        end
end
switch areaend
    case 'none'
        for iFt = 1:comuse.nFt
            iCv1 = comuse.ftCvP(iFt,1);
            iCv2 = iCv1 + comuse.ftCvP(iFt,2) - 1;
            if any(indrad(comuse.ftCv(iFt,iCv1:iCv2)))
                rb.area_divide(iFt) = 1;
            end
        end
    otherwise
        for i = 1:length(faces)
            iFc = faces(i);
            iCv1 = comuse.fcCv(iFc,1);
            iCv2 = comuse.fcCv(iFc,2);
            if indrad(iCv1)
                iFt = comuse.cvFt(iCv1);
            else
                iFt = comuse.cvFt(iCv2);
            end
            rb.area_divide(iFt) = rb.area_divide(iFt) + area(iFc);
        end
end

% y - y_sep at outer mid-plane (cm):
yomp = comuse.cvX(comuse.omp);
psiomp = zeros(size(comuse.omp));
for i = 1:length(comuse.omp)
    iCv = comuse.omp(i);
    iVx1 = comuse.cvVxP(iCv,1);
    iVx2 = iVx1 + comuse.cvVxP(iCv,2) - 1;
    psiomp(i) = mean(comuse.vxFpsi(comuse.cvVx(iVx1:iVx2)));
end
for i = 1:length(comuse.omp)
    iCv = comuse.omp(i);
    if comuse.cvFt(iCv) == comuse.ftSep(1)
        break;
    end
end
ysep = 0.5*(yomp(i-1) + yomp(i));
yomp = yomp - ysep;
psidown = zeros(comuse.nFt,1);
ytot = zeros(comuse.nFt,1);
for i = 1:length(facesdown)
    iFc = facesdown(i);
    iVx1 = comuse.fcVx(iFc,1);
    iVx2 = comuse.fcVx(iFc,2);
    iCv1 = comuse.fcCv(iFc,1);
    iCv2 = comuse.fcCv(iFc,2);
    if indrad(iCv1)
        iFt = comuse.cvFt(iCv1);
    else
        iFt = comuse.cvFt(iCv2);
    end
    psidown(iFt) = psidown(iFt) + 0.5*(comuse.vxFpsi(iVx1) + ...
        comuse.vxFpsi(iVx2))*abs(comuse.vxX(iVx2) - comuse.vxX(iVx1));
    ytot(iFt) = ytot(iFt) + abs(comuse.vxX(iVx2) - comuse.vxX(iVx1));
end
psidown = psidown./(ytot + 1.0e-30);

% Target distances mapped to OMP:
ymysep = 100*interp1(psiomp,yomp,psidown,'linear','extrap');

% Eliminate the flux tubes that are absent in indrad:
fluxup_old = fluxup;
fluxdown_old = fluxdown;
srcint_old = srcint;
resint_old = resint;
ymysep_old = ymysep;
fluxup = zeros(sum(rb.area_divide ~= 0),size(fluxup_old,2));
fluxdown = zeros(sum(rb.area_divide ~= 0),size(fluxdown_old,2));
srcint = zeros(sum(rb.area_divide ~= 0),size(srcint_old,2));
resint = zeros(sum(rb.area_divide ~= 0),1);
ymysep = zeros(sum(rb.area_divide ~= 0),1);
index = 0;
for iFt = 1:comuse.nFt
    if rb.area_divide(iFt) == 0
        continue;
    else
        index = index + 1;
        fluxup(index,:) = fluxup_old(iFt,:);
        fluxdown(index,:) = fluxdown_old(iFt,:);
        srcint(index,:) = srcint_old(iFt,:);
        resint(index,1) = resint_old(iFt,1);
        ymysep(index,1) = ymysep_old(iFt,1);
    end
end
rb.area_divide = rb.area_divide(rb.area_divide ~= 0);

% Sort the data according to increasing ymysep:
[~,rb.index] = sort(ymysep);
fluxup = fluxup(rb.index,:);
fluxdown = fluxdown(rb.index,:);
srcint = srcint(rb.index,:);
resint = resint(rb.index,1);
ymysep = ymysep(rb.index,1);

% Total balance with residuals:
cmap = comuse.cmap;
coderes = momfac*resint./rb.area_divide;
if makeplot
    plot(ymysep,momfac*sum(fluxup,2)./rb.area_divide,'marker','.','parent',axbal(1),'displayname',totname{1},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    plot(ymysep,momfac*sum(fluxdown,2)./rb.area_divide,'marker','.','parent',axbal(1),'displayname',totname{2},'color',cmap(1,:)); cmap=circshift(cmap,-1);
    plot(ymysep,momfac*sum(srcint,2)./rb.area_divide,'marker','.','parent',axbal(1),'displayname',totname{3},'color',cmap(1,:));
    plot(ymysep,coderes,'-m','parent',axbal(1),'displayname',[totname{4},' (code)']);
end
rb.ymysep = ymysep;
rb.totflxu = momfac*sum(fluxup,2)./rb.area_divide;
rb.totflxd = momfac*sum(fluxdown,2)./rb.area_divide;
rb.totsrc = momfac*sum(srcint,2)./rb.area_divide;
rb.coderes = coderes;

% Check the level of agreement between post-calculated and code-calculated residuals agree:
postres = momfac*((sum(fluxup,2)-sum(fluxdown,2))+sum(srcint,2))./rb.area_divide;
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
            plot(ymysep,momfac*fluxup(:,i)./rb.area_divide,'marker','.','parent',axbal(2),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.flxu_dcmp{i} = momfac*fluxup(:,i)./rb.area_divide;
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
            plot(ymysep,momfac*fluxdown(:,i)./rb.area_divide,'marker','.','parent',axbal(3),'displayname',fluxname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.flxd_dcmp{i} = momfac*fluxdown(:,i)./rb.area_divide;
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
            plot(ymysep,momfac*srcint(:,i)./rb.area_divide,'marker','.','parent',axbal(4),'displayname',srcname{i},'color',cmap(1,:)); cmap=circshift(cmap,-1);
        end
    end
    rb.src_dcmp{i} = momfac*srcint(:,i)./rb.area_divide;
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
