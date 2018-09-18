function iout = plot_by_reg(Trc_Time,Value,Nreg,Gtitle,COLOUR,sum_flag)


if sum_flag
    Ncurves = Nreg+1;
    sum_over_regions=zeros(size(Trc_Time,1),1);
else
    Ncurves = Nreg;
end;
label=cell(Nreg);

figure;
ireg = 1;
while ireg <= Nreg
    plot(Trc_Time,Value(:,ireg),'Color',COLOUR{ireg},'LineWidth',2);
    hold all;
    label{ireg} = ['region ' num2str(ireg)];
    if sum_flag
       sum_over_regions = sum_over_regions + Value(:,ireg);
    end;
    ireg = ireg + 1;
end;

if sum_flag
    plot(Trc_Time,sum_over_regions,'Color',[0.23 0.54 0.87],'LineWidth',2);
    label{Nreg+1} = 'sum';
end;

set(gca,'FontName','Times','FontSize',20);
%axes_handle=axes;

xlabel('Time, s','FontName','Times','FontSize',36);
%ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',36);
title(Gtitle,'FontName','Times','FontSize',36);
%hold all;
%set(gca,'FontName','Times','FontSize',20);
%if not(exp_flag) legend(label{1:Nresults},'location','best');% ,'FontSize',12
%end;
grid on;
grid minor;
legend(label{1:Ncurves},'location','best');
set(gca,'LineWidth',3);

iout = 0;