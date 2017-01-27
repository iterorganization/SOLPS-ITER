function make_strata_plots(eirene_atom,eirene_mol,eirene_tion,eirene_rc,titlestr,namestr,geomb2,indrad,indpol,nstra,axstrat,axbal,areadownrad,areadownpol,reverse,ismom)

if ~reverse
    momfac = 1;
elseif ismom
    momfac = -1;
else
    momfac = 1;
end

% Titles:
axes(axstrat(9));
text(0.5,0.5,titlestr{1},'interpreter','latex','horizontalalignment','center','fontsize',14);
axes(axstrat(10));
text(0.5,0.5,titlestr{2},'interpreter','latex','horizontalalignment','center','fontsize',14);

% Poloidally integrated sources with radial resolution:
tmp = get(axbal(2),'children');
xplot = get(tmp(1),'xdata');
cmap = colormap(lines(nstra));
tot_atom = repmat({zeros(size(xplot))},1,length(eirene_atom));
tot_mol = repmat({zeros(size(xplot))},1,length(eirene_mol));
tot_tion = repmat({zeros(size(xplot))},1,length(eirene_tion));
tot_rc = repmat({zeros(size(xplot))},1,length(eirene_rc));
for istra = 1:nstra
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_atom));
    for ie = 1:length(eirene_atom)
        tmp = momfac*sumpol(eirene_atom{ie}(:,:,istra),indrad,geomb2)./areadownrad;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(1),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_atom{ie} = tot_atom{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_mol));
    for ie = 1:length(eirene_mol)
        tmp = momfac*sumpol(eirene_mol{ie}(:,:,istra),indrad,geomb2)./areadownrad;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(2),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_mol{ie} = tot_mol{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_tion));
    for ie = 1:length(eirene_tion)
        tmp = momfac*sumpol(eirene_tion{ie}(:,:,istra),indrad,geomb2)./areadownrad;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(3),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_tion{ie} - tot_tion{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_rc));
    for ie = 1:length(eirene_rc)
        tmp = momfac*sumpol(eirene_rc{ie}(:,:,istra),indrad,geomb2)./areadownrad;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(4),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_rc{ie} = tot_rc{ie}+tmp;
        end
    end
end
for ie = 1:length(eirene_atom)
    plot(xplot,tot_atom{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(1),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_mol{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(2),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_tion{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(3),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_rc{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(4),'displayname',['stratum total ',namestr{ie}]);
end
hl = legend(axstrat(1),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(2),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(3),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(4),'show','location','best'); set(hl,'interpreter','latex');
ylabel(axstrat(1),get(get(axbal(3),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(2),get(get(axbal(3),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(3),get(get(axbal(3),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(4),get(get(axbal(3),'ylabel'),'string'),'interpreter','latex');
xlabel(axstrat(1),get(get(axbal(3),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(2),get(get(axbal(3),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(3),get(get(axbal(3),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(4),get(get(axbal(3),'xlabel'),'string'),'interpreter','latex');
set(axstrat(1:4),'xlim',get(axbal(3),'xlim'));

% Set the same axes limits for all radial source plots:
ymin = 1E40;
ymax = -1E40;
for iax=1:4
    a = findobj(get(axstrat(iax),'children'),'type','line');
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
    set(axstrat(1:4),'ylim',[ymin ymax]);
end

% Sources along the poloidal direction:
tmp = get(axbal(end),'children');
xplot = get(tmp(1),'xdata');
cmap = colormap(lines(nstra));
tot_atom = repmat({zeros(size(xplot))},1,length(eirene_atom));
tot_mol = repmat({zeros(size(xplot))},1,length(eirene_mol));
tot_tion = repmat({zeros(size(xplot))},1,length(eirene_tion));
tot_rc = repmat({zeros(size(xplot))},1,length(eirene_rc));
for istra = 1:nstra
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_atom));
    for ie = 1:length(eirene_atom)
        tmp = momfac*sumrad(eirene_atom{ie}(:,:,istra),indpol,geomb2)/areadownpol;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(5),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_atom{ie} = tot_atom{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_mol));
    for ie = 1:length(eirene_mol)
        tmp = momfac*sumrad(eirene_mol{ie}(:,:,istra),indpol,geomb2)/areadownpol;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(6),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_mol{ie} = tot_mol{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_tion));
    for ie = 1:length(eirene_tion)
        tmp = momfac*sumrad(eirene_tion{ie}(:,:,istra),indpol,geomb2)/areadownpol;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(7),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_tion{ie} = tot_tion{ie}+tmp;
        end
    end
    linestyle = repmat({'-','--',':','-.'},1,length(eirene_rc));
    for ie = 1:length(eirene_rc)
        tmp = momfac*sumrad(eirene_rc{ie}(:,:,istra),indpol,geomb2)/areadownpol;
        if any(tmp)
            plot(xplot,tmp,'parent',axstrat(8),'color',cmap(istra,:),'linestyle',linestyle{ie},'displayname',['stratum ',num2str(istra),' ',namestr{ie}]);
            tot_rc{ie} = tot_rc{ie}+tmp;
        end
    end
end
for ie = 1:length(eirene_atom)
    plot(xplot,tot_atom{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(5),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_mol{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(6),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_tion{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(7),'displayname',['stratum total ',namestr{ie}]);
    plot(xplot,tot_rc{ie},'color','k','linestyle',linestyle{ie},'parent',axstrat(8),'displayname',['stratum total ',namestr{ie}]);
end
hl = legend(axstrat(5),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(6),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(7),'show','location','best'); set(hl,'interpreter','latex');
hl = legend(axstrat(8),'show','location','best'); set(hl,'interpreter','latex');
ylabel(axstrat(5),get(get(axbal(end),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(6),get(get(axbal(end),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(7),get(get(axbal(end),'ylabel'),'string'),'interpreter','latex');
ylabel(axstrat(8),get(get(axbal(end),'ylabel'),'string'),'interpreter','latex');
xlabel(axstrat(5),get(get(axbal(end),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(6),get(get(axbal(end),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(7),get(get(axbal(end),'xlabel'),'string'),'interpreter','latex');
xlabel(axstrat(8),get(get(axbal(end),'xlabel'),'string'),'interpreter','latex');
set(axstrat(5:8),'xlim',get(axbal(end),'xlim'));

% Set the same axes limits for all radial source plots:
ymin = 1E40;
ymax = -1E40;
for iax=5:8
    a = findobj(get(axstrat(iax),'children'),'type','line');
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
    set(axstrat(5:8),'ylim',[ymin ymax]);
end

end