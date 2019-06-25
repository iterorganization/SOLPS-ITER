function make_twopmf_plots(balfile,indrad,comuse,axbal_2pmfpr,axbal_2pmfht,reverse,areauprad,areadownrad)

ev=1.602176565e-19;

% Obtain arrays that aren't in plots:
fna = ncread(balfile,'fna_pinch')+ncread(balfile,'fna_pll')+ncread(balfile,'fna_drift')+...
      ncread(balfile,'fna_ch')+ncread(balfile,'fna_nanom')+...
      ncread(balfile,'fna_panom')+ncread(balfile,'fna_pschused');
fnex = zeros(size(fna,1),size(fna,2));
for is = 1:length(comuse.za)
    fnex = fnex + fna(:,:,1,is)*double(comuse.za(is));
end
ti = ncread(balfile,'ti');
te = ncread(balfile,'te');
ne = ncread(balfile,'ne');
na = ncread(balfile,'na');
z = ne./sum(na(:,:,comuse.za>0),3);
pKR = 1+ti./te./z;
if ~reverse
    Gammaetar = findlr(fnex,indrad,'right',comuse.rightix+1,comuse.rightiy+1)./areadownrad;
    tetar = findlr(te,indrad,'right',comuse.rightix+1,comuse.rightiy+1)/ev;
    netar = findlr(ne,indrad,'right',comuse.rightix+1,comuse.rightiy+1);
    pKRtar = findlr(pKR,indrad,'right',comuse.rightix+1,comuse.rightiy+1);
else
    Gammaetar = findlr(fnex,indrad,'left',comuse.rightix+1,comuse.rightiy+1)./areadownrad;
    tetar = findlr(te,indrad,'left',comuse.rightix+1,comuse.rightiy+1)/ev;
    netar = findlr(ne,indrad,'left',comuse.rightix+1,comuse.rightiy+1);
    pKRtar = findlr(pKR,indrad,'left',comuse.rightix+1,comuse.rightiy+1);
end

% Obtain arrays from plots:
tmp = flipud(findobj(get(axbal_2pmfht(1),'children'),'type','line'));
ymysep = get(tmp(1),'xdata');
qu = 1e6*get(tmp(1),'ydata').*areadownrad./areauprad;
qtar = 1e6*get(tmp(2),'ydata');
fpwr = get(tmp(3),'ydata')./get(tmp(1),'ydata');
tmp2 = flipud(findobj(get(axbal_2pmfht(4),'children'),'type','line'));
fpwrcomps = cell2mat(get(tmp2,'ydata'));
fpwrcomps = fpwrcomps./repmat(get(tmp(1),'ydata'),size(fpwrcomps,1),1);
tmp = flipud(findobj(get(axbal_2pmfpr(1),'children'),'type','line'));
ptotu = -get(tmp(1),'ydata'); %MINUS SIGN HERE IS A HACK - NEEDS FIXING!
fmom = get(tmp(3),'ydata')./get(tmp(1),'ydata');
tmp2 = flipud(findobj(get(axbal_2pmfpr(4),'children'),'type','line'));
fmomcomps = cell2mat(get(tmp2,'ydata'));
fmomcomps = fmomcomps./repmat(get(tmp(1),'ydata'),size(fmomcomps,1),1);
tmp = flipud(findobj(get(axbal_2pmfpr(3),'children'),'type','line'));
pdyntar = -get(tmp(1),'ydata');
pstattar = -get(tmp(2),'ydata');



gamma_sheath = qtar./Gammaetar./tetar/1.602E-19;
M = sqrt(pdyntar./pstattar);
mtar = netar.*pdyntar./Gammaetar.^2;

figure('windowstyle','docked');
subplot(2,3,1); hold on;
plot(ymysep,tetar,'displayname','$T_{et}$ code');
plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2),...
    'displayname','$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]$');
plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2),...
    'displayname','$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]$');
plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4),...
    'displayname','$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]$');
plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4).*((1+fpwr).^2./(1+fmom).^2),...
    'displayname',['$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]',...
                   '\left[\frac{(1+f_{pwr})^2}{(1+f_{mom})^2}\right]$']);
% plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4).*((1+sum(fpwrcomps(22:23,:),1)).^2).*(areauprad./areadownrad).^2,...
%     'displayname',['$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]',...
%                    '\left[\frac{(1+f_{pwr})^2}{(1+f_{mom})^2}\right]\left[\left(\frac{B_t}{B_u}\right)^2\right]$, compression losses only']);
% plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4).*((1+sum(fpwrcomps([1:4,22:23],:),1)).^2./(1+sum(fmomcomps(2:3,:),1)).^2).*(areauprad./areadownrad).^2,...
%     'displayname',['$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]',...
%                    '\left[\frac{(1+f_{pwr})^2}{(1+f_{mom})^2}\right]\left[\left(\frac{B_t}{B_u}\right)^2\right]$, compression and transport losses only']);
% plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4).*((1+sum(fpwrcomps([1:4,7:13,22:23],:),1)).^2./(1+sum(fmomcomps([2:3,5:8],:),1)).^2).*(areauprad./areadownrad).^2,...
%     'displayname',['$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]',...
%                    '\left[\frac{(1+f_{pwr})^2}{(1+f_{mom})^2}\right]\left[\left(\frac{B_t}{B_u}\right)^2\right]$, compression, transport and neutral losses']);
plot(ymysep,8*(mtar./gamma_sheath.^2/ev).*(qu.^2./ptotu.^2).*(pKRtar/2).*((1+M.^2).^2./M.^2/4).*((1+sum(fpwrcomps,1)).^2./(1+sum(fmomcomps,1)).^2).*(areauprad./areadownrad).^2,...
    'displayname',['$\left[\frac{8m}{e\gamma^2}\right]\left[\frac{\tilde q_{\parallel u}^2}{p_{tot,u}^2}\right]\left[\frac{1+\tau_t/z_t}{2}\right]\left[\frac{(1+M_t^2)^2}{4M_t^2}\right]',...
                   '\left[\frac{(1+f_{pwr})^2}{(1+f_{mom})^2}\right]\left[\left(\frac{B_t}{B_u}\right)^2\right]$']);
hl = legend(gca,'show','location','best');
set(hl,'interpreter','latex');
subplot(2,3,2); hold on;
plot(ymysep,netar,'displayname','$n_{et}$ code');
plot(ymysep,(gamma_sheath.^2./mtar/32).*(ptotu.^3./qu.^2),...
    'displayname','$\left[\frac{\gamma^2}{32m}\right]\left[\frac{p_{tot,u}^3}{\tilde q_{\parallel u}^2}\right]$');
plot(ymysep,(gamma_sheath.^2./mtar/32).*(ptotu.^3./qu.^2).*(4./pKRtar.^2),...
    'displayname','$\left[\frac{\gamma^2}{32m}\right]\left[\frac{p_{tot,u}^3}{\tilde q_{\parallel u}^2}\right]\left[\frac{4}{(1+\tau_t/z_t)^2}\right]$');
plot(ymysep,(gamma_sheath.^2./mtar/32).*(ptotu.^3./qu.^2).*(4./pKRtar.^2).*(8*M.^2./(1+M.^2).^3),...
    'displayname','$\left[\frac{\gamma^2}{32m}\right]\left[\frac{p_{tot,u}^3}{\tilde q_{\parallel u}^2}\right]\left[\frac{4}{(1+\tau_t/z_t)^2}\right]\left[\frac{8M_t^2}{(1+M_t^2)^3}\right]$');
plot(ymysep,(gamma_sheath.^2./mtar/32).*(ptotu.^3./qu.^2).*(4./pKRtar.^2).*(8*M.^2./(1+M.^2).^3).*((1+fmom).^3./(1+fpwr).^2),...
    'displayname',['$\left[\frac{\gamma^2}{32m}\right]\left[\frac{p_{tot,u}^3}{\tilde q_{\parallel u}^2}\right]\left[\frac{4}{(1+\tau_t/z_t)^2}\right]\left[\frac{8M_t^2}{(1+M_t^2)^3}\right]',...
                   '\left[\frac{(1+fmom)^3}{(1+fpwr)^2}\right]$']);            
plot(ymysep,(gamma_sheath.^2./mtar/32).*(ptotu.^3./qu.^2).*(4./pKRtar.^2).*(8*M.^2./(1+M.^2).^3).*((1+sum(fmomcomps,1)).^3./(1+sum(fpwrcomps,1)).^2).*(areadownrad./areauprad).^2,...
    'displayname',['$\left[\frac{\gamma^2}{32m}\right]\left[\frac{p_{tot,u}^3}{\tilde q_{\parallel u}^2}\right]\left[\frac{4}{(1+\tau_t/z_t)^2}\right]\left[\frac{8M_t^2}{(1+M_t^2)^3}\right]',...
                   '\left[\frac{(1+fmom)^3}{(1+fpwr)^2}\right]\left[\left(\frac{B_u}{B_t}\right)^2\right]$']);
hl = legend(gca,'show','location','best');
set(hl,'interpreter','latex');
subplot(2,3,3); hold on;
plot(ymysep,Gammaetar,'displayname','$\Gamma_{et}$ code');
plot(ymysep,(gamma_sheath./mtar/8).*(ptotu.^2./qu),...
    'displayname','$\left[\frac{\gamma}{8m}\right]\left[\frac{p_{tot,u}^2}{q_{\parallel u}}\right]$');
plot(ymysep,(gamma_sheath./mtar/8).*(ptotu.^2./qu).*(2./pKRtar),...
    'displayname','$\left[\frac{\gamma}{8m}\right]\left[\frac{p_{tot,u}^2}{q_{\parallel u}}\right]\left[\frac{2}{1+\tau_t/z_t}\right]$');
plot(ymysep,(gamma_sheath./mtar/8).*(ptotu.^2./qu).*(2./pKRtar).*(4*M.^2./(1+M.^2).^2),...
    'displayname','$\left[\frac{\gamma}{8m}\right]\left[\frac{p_{tot,u}^2}{q_{\parallel u}}\right]\left[\frac{2}{1+\tau_t/z_t}\right]\left[\frac{4M_t^2}{(1+M_t^2)^2}\right]$');
plot(ymysep,(gamma_sheath./mtar/8).*(ptotu.^2./qu).*(2./pKRtar).*(4*M.^2./(1+M.^2).^2).*((1+sum(fmomcomps,1)).^2./(1+sum(fpwrcomps,1))),...
    'displayname',['$\left[\frac{\gamma}{8m}\right]\left[\frac{p_{tot,u}^2}{q_{\parallel u}}\right]\left[\frac{2}{1+\tau_t/z_t}\right]\left[\frac{4M_t^2}{(1+M_t^2)^2}\right]',...
                   '\left[\frac{(1+fmom)^2}{1+fpwr}\right]$']);
plot(ymysep,(gamma_sheath./mtar/8).*(ptotu.^2./qu).*(2./pKRtar).*(4*M.^2./(1+M.^2).^2).*((1+sum(fmomcomps,1)).^2./(1+sum(fpwrcomps,1))).*(areadownrad./areauprad),...
    'displayname',['$\left[\frac{\gamma}{8m}\right]\left[\frac{p_{tot,u}^2}{q_{\parallel u}}\right]\left[\frac{2}{1+\tau_t/z_t}\right]\left[\frac{4M_t^2}{(1+M_t^2)^2}\right]',...
                   '\left[\frac{(1+fmom)^2}{1+fpwr}\right]\left[\frac{B_u}{B_t}\right]$']);
hl = legend(gca,'show','location','best');
set(hl,'interpreter','latex');               
subplot(2,3,4); hold on;
dispnames = get(flipud(findobj(get(axbal_2pmfpr(4),'children'),'type','line')),'displayname');
for i=1:size(fmomcomps,1)
    plot(ymysep,fmomcomps(i,:),'displayname',dispnames{i});
end
hl = legend(gca,'show','location','best');
subplot(2,3,5); hold on;
dispnames = get(flipud(findobj(get(axbal_2pmfht(4),'children'),'type','line')),'displayname');
for i=1:size(fpwrcomps,1)
    plot(ymysep,fpwrcomps(i,:),'displayname',dispnames{i});
end
hl = legend(gca,'show','location','best');


