function iout = plot_by_spec(Trc_Time,Value,Nspec,Gtitle,label,COLOUR)

ispec = 1;

figure;
%label=cell(Nspec);

while ispec <= Nspec
    plot(Trc_Time,Value(:,ispec),'Color',COLOUR{ispec},'LineWidth',2);
    hold all;
%    label{ispec} = ['region ' num2str(ispec)];
    ispec = ispec + 1;
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
legend(label{1:Nspec},'location','best');
set(gca,'LineWidth',3);

iout = 0;