function iout = plot_by_spec_and_stra(Trc_Time,Value,Nspec,Nstra,Gtitle,label_spec,COLOUR,sum_flag)

ispec = 1;

if sum_flag 
    Ncurves = Nstra + 1;
    sum_over_strata = zeros(size(Trc_Time,1),Nspec);
else
    Ncurves = Nstra;
end;
label=cell(Ncurves);

while ispec <= Nspec
    figure;
    for istra=1:Nstra
       plot(Trc_Time,Value(:,(ispec-1)*Nstra+istra),'Color',COLOUR{(ispec-1)*Nstra+istra},'LineWidth',2);
       hold all;
       label{istra} = ['stratum ' num2str(istra)];
       set(gca,'FontName','Times','FontSize',20);
       %axes_handle=axes;
       sum_over_strata(:,ispec) = sum_over_strata(:,ispec) + Value(:,(ispec-1)*Nstra+istra);
    end;
    if sum_flag
        plot(Trc_Time,sum_over_strata(:,ispec),'Color',[0.23 0.54 0.87],'LineWidth',2);
        label{Nstra+1} = 'sum';
    end;
    xlabel('Time, s','FontName','Times','FontSize',36);
    %ylabel(Ylabel,'interpreter', 'latex','FontName','Times','FontSize',36);
    title([Gtitle ', ' label_spec{ispec}],'FontName','Times','FontSize',36);
    %hold all;
    %set(gca,'FontName','Times','FontSize',20);
    %if not(exp_flag) legend(label{1:Nresults},'location','best');% ,'FontSize',12
    %end;
    grid on;
    grid minor;
    legend(label{1:Ncurves},'location','best');
    set(gca,'LineWidth',3);
    ispec = ispec + 1;
end;


iout = 0;