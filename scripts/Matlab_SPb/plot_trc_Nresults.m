function iout = plot_trc_Nresults(time,value,size_of_trc,Nresults,Gtitle,Ylabel,label)

% 30 types of line are prescribed
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
    plot(time(1:size_of_trc(m),m),value(1:size_of_trc(m),m),SYMBOL{m},'Color',COLOUR{m},'LineWidth',0.3)
    hold all;
end;

set(gca,'FontName','Times','FontSize',26);
%axes_handle=axes;
%set(axes_handle,'FontName','Times','FontSize',30);
xlabel('Time, s','FontName','Times','FontSize',30);
ylabel(Ylabel,'FontName','Times','FontSize',30);
title(Gtitle,'FontName','Times','FontSize',30);
hold all;
%set(gca,'FontName','Times','FontSize',20);
legend(label{1:Nresults},'location','best'); %,'FontSize',20

grid on;
grid minor;
iout = 0;