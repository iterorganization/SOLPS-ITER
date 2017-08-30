function iout = R_plot_1Darray_Nresults(y2,value,Nresults,nsep,npl,Gtitle,Ylabel,label);
% Plots VALUE versus major radius at outer midplane
% y2 is a distance from separatrix
% value is a value to be plotted
% nx and ny define grid size
% nsep is an index of cell corresponding to separatrix
% npl is a poloidal cell number
% npl=nout for outer midplane
% npl=nin for inner midplane
% npl=ntop for tokamak top
% npl=nbot for tokamak bottom
% title is a graph title

%30 types of line are prescribed
SYMBOL={'-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-+' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v' '-o' '-s' '-*' '-h' '-^' '->' '-<' '-v'};
COLOUR={[1,0,0] [0,0,1] [0.45,0.1,0.05] [0.75,0.2,0.15] [0.15,0.05,0.5] [0.25,0.5,0.25] [1,0.6,0] [1,0.05,0.75] ...
    [0.5,0.5,1] [0.0,0.5,1] [0.5,0.1,0] [0.6,0.05,0.4] [0.35,0.65,0.15] [0.8,0.2,0.8] [0.2,0.2,0.5] [0.4,0.4,0.55] ...
    [0.5,0.5,0.5] [0.2,0.8,0.2] [0.3,0.7,0.3] [0.3,0.9,0.1] [0,1,0] [0.25,0.25,0.85] [0.85,0.2,0.2] [0.3,0,0.9] [0.75,0.75,0.05] ...
    [0.9,0.2,0.2] [0.2,0.9,0.9] [0.15,0.9,0.15] [0.2,0.15,0.9] [0.2,0.2,0.65]};

scrsz = get(0,'ScreenSize');
%figure('Position',[1 scrsz(2) scrsz(3) scrsz(4)]);
figure('Position',[1 900 1250 900]);
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times New Roman','FontSize',12);


for m=1:Nresults
    plot(y2(2:nsep(m)+2,npl(m),m),value(2:nsep(m)+2,m),SYMBOL{m},'Color',COLOUR{m},'LineWidth',3);
    hold all;
end;
set(gca,'FontName','Times','FontSize',20);
xlabel('Distance from separatrix, m','FontSize',36,'FontName','Times');
ylabel(Ylabel,'FontName','Times','FontSize',36,'interpreter', 'latex');
title(Gtitle,'FontName','Times','FontSize',36);
legend(label{1:Nresults});
grid on;
grid minor;

iout = 0;