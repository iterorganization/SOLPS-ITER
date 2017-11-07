function iout = plot_by_spec_and_reg(Trc_Time,Value,Nspec,Nreg,Gtitle,label_spec,COLOUR,sum_flag)

ispec = 1;

if sum_flag 
    Ncurves = Nreg + 1;
    sum_over_regions = zeros(size(Trc_Time,1),Nspec);
else
    Ncurves = Nreg;
end;
label=cell(Ncurves);

while ispec <= Nspec
    figure;
    for ireg=1:Nreg
       plot(Trc_Time,Value(:,(ispec-1)*Nreg+ireg),'Color',COLOUR{(ispec-1)*Nreg+ireg},'LineWidth',2);
       hold all;
       label{ireg} = ['region ' num2str(ireg)];
       set(gca,'FontName','Times','FontSize',20);
       %axes_handle=axes;
       sum_over_regions(:,ispec) = sum_over_regions(:,ispec) + Value(:,(ispec-1)*Nreg+ireg);
    end;
    if sum_flag
        plot(Trc_Time,sum_over_regions(:,ispec),'Color',[0.23 0.54 0.87],'LineWidth',2);
        label{Nreg+1} = 'sum';
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