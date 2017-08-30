function iout = R_plot_targets(y,value,flux_flug,nx,ny,ntt,nc2,nc3,Ylabel,Gtitle,plot_legend);

% R_plot_targets plots VALUE along all targets on the same graph, defining the topology
% automatically

% y           is a distance from separatrix
% value       is a value to be plotted
%
% flux_flug   controls whether to plot value at guard cell or first
%             physical cell. flux_flug may be 0,1 or 2, see below
%
% nx and ny   define grid size
% ntt         is a poloidal position of top target on computational grid
% nc2         number of the last cell in the core at HFS (for DND topology
%             with lower active active X-point)
%             Condition nc2==ntt should be true for SND topology
% nc3         number of the first cell in the core at LFS (for DND topology
%             with lower active active X-point)
%             Condition nc3==nc2+1 should be true for SND topology
% 
% Gtitle     is a graph title
% Ylabel     is a label for ordinate axis

%figure;
global PlotSize;
figure('Position',PlotSize);
set(figure(gcf), 'name', Gtitle);

axes('FontName','Times','FontSize',24);
if flux_flug==0
% plot the value in narrow (guard) cells at all 2(4) targets
    npl_ib=-1;
    npl_it=ntt;
    npl_ot=ntt+1;
    npl_ob=nx;
elseif flux_flug==2
% plot the value in first normal cell at all 2((4) targets
    npl_ib=0;
    npl_it=ntt-1;
    npl_ot=ntt+2;
    npl_ob=nx-1;
elseif flux_flug==1
% plot the value in guard cell cell at east target(s) and in first normal
% cell at west target(s)
    npl_ib=0;
    npl_it=ntt;
    npl_ot=ntt+2;
    npl_ob=nx;
else    
end;

plot(y(2:ny+1,npl_ib+2),value(2:ny+1,npl_ib+2),'-o','LineWidth',2,'Color',[1,0,0]);
hold all;
plot(y(2:ny+1,npl_ob+2),value(2:ny+1,npl_ob+2),'-s','LineWidth',2,'Color',[0,0,1]);
hold all;
set(gca,'FontName','Times','FontSize',30);
if ntt==nc2 || ntt==nc3
    if plot_legend
        legend('inner bottom target','outer bottom target','FontName','Times','Location','best');%,'FontSize',22
    end;
else
    plot(y(2:ny+1,npl_ot+2),value(2:ny+1,npl_ot+2),'-+','LineWidth',2,'Color',[0.75,0,1]);
    hold all;
    plot(y(2:ny+1,npl_it+2),value(2:ny+1,npl_it+2),'-*','LineWidth',2,'Color',[0.45,0.1,0.05]);
    hold all;
    if plot_legend
        legend('inner bottom target','outer bottom target','outer top target','inner top target','FontName','Times','Location','best');%,'FontSize',22
    end;
end;

xlabel('Distance from separatrix, m','FontSize',30,'FontName','Times');
ylabel(Ylabel,'interpreter', 'latex','FontSize',30,'FontName','Times');
title('Targets','FontSize',30,'FontName','Times');
%legend('inner bottom target','outer bottom target','outer top target','inner top target','FontName','Times','FontSize',22,'Location','NorthEast');
grid on;
grid minor;

iout = 0;