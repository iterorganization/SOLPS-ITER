function iout = R_plot_Nresults(y2,value,nx,ny,Nresults,npl,Gtitle,Ylabel,label,exp_flag);
% Plots the same value versus radial coordinate y for Nresults different variants
% y2 is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% npl is a poloidal cell number
% npl=nout for outer midplane
% npl=nin for inner midplane
% npl=ntop for tokamak top
% npl=nbot for tokamak bottom
% Gtitle is a graph title

%30 types of line are prescribed
SYMBOL={'-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v'};
COLOUR={[1,0,0] [0,0,1] [0.45,0.1,0.05] [0.75,0.2,0.15] [0.15,0.05,0.5] [0.25,0.5,0.25] [1,0.6,0] [1,0.05,0.75] ...
    [0.5,0.5,1] [0.0,0.5,1] [0.5,0.1,0] [0.6,0.05,0.4] [0.35,0.65,0.15] [0.8,0.2,0.8] [0.2,0.2,0.5] [0.4,0.4,0.55] ...
    [0.5,0.5,0.5] [0.2,0.8,0.2] [0.3,0.7,0.3] [0.3,0.9,0.1] [0,1,0] [0.25,0.25,0.85] [0.85,0.2,0.2] [0.3,0,0.9] [0.75,0.75,0.05] ...
    [0.9,0.2,0.2] [0.2,0.9,0.9] [0.15,0.9,0.15] [0.2,0.15,0.9] [0.2,0.2,0.65]};

scrsz = get(0,'ScreenSize');
%figure('Position',[1 scrsz(2) scrsz(3) scrsz(4)]);
figure('Position',[1 900 900 900]);
%figure;
set(figure(gcf), 'name', Gtitle);
%axes('FontName','Times','FontSize',20);


for m=1:Nresults
    plot(y2(1:ny(m)+1,npl(m)+2,m),value(1:ny(m)+1,npl(m)+2,m),SYMBOL{m},'Color',COLOUR{m},'LineWidth',3);
    hold all;
end;
set(gca,'FontName','Times','FontSize',30);
%axes_handle=axes;
%set(axes_handle,'FontName','Times','FontSize',30);
xlabel('Distance from separatrix, m','FontName','Times','FontSize',36);
ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',30);
hold all;
%set(gca,'FontName','Times','FontSize',20);
if not(exp_flag) legend(label{1:Nresults},'location','best'); %,'FontSize',20
end;
grid on;
grid minor;
iout = 0;