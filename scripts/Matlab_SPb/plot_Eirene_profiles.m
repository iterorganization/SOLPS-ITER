%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCES 2D PLOTS OF EIRENE PROFILES ON TRIANGULAR MESH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

function iout=plot_Eirene_profiles(PATH_PREFIX,value,Gtitle,Figname,Levels,label2D,Plot2DSize);

% Global data describing Eirene triangular mesh - see read_geometry.m for more help 
global N_apex
global R_apex
global Z_apex
 global N_tria
 global i_apex1
 global i_apex2
 global i_apex3

global neighb_apex;
global neighb_tria;
global N_neighb_apex;
global N_neighb_tria;

global RC_tria;
global ZC_tria;


global PlotSize;
%figure('Position',PlotSize);
figure;

hold all;

% plot EIRENE's triangular mesh
%if EIRENE_flag
%end;

value_apex=zeros(N_apex,1);
distance_sum = zeros(N_apex,1);

for iapex=1:N_apex
%    iapex
    value_apex(iapex)=0.0;
    distance_sum(iapex) = 0.0;
    for i=1:N_neighb_tria(iapex)
        distance = sqrt((R_apex(iapex)-RC_tria(neighb_tria(i,iapex)))^2+(Z_apex(iapex)-ZC_tria(neighb_tria(i,iapex)))^2);
        value_apex(iapex) = value_apex(iapex) + value(neighb_tria(i,iapex)) * distance;
        distance_sum(iapex) = distance_sum(iapex) + distance;
    end;
    value_apex(iapex) = value_apex(iapex) / distance_sum(iapex);
end;


for iapex = 1:N_apex;
iapex
Rcp = zeros(1+N_neighb_tria(iapex)+N_neighb_apex(iapex),1);
Zcp = zeros(1+N_neighb_tria(iapex)+N_neighb_apex(iapex),1);
value1 = zeros(1+N_neighb_tria(iapex)+N_neighb_apex(iapex),1);


Rcp(1) = R_apex(iapex);
Zcp(1) = Z_apex(iapex);
value1(1) = value_apex(iapex);

for i=1:N_neighb_tria(iapex)
    Rcp(i+1) = RC_tria(neighb_tria(i,iapex));
    Zcp(i+1) = ZC_tria(neighb_tria(i,iapex));
    value1(i+1) = value(neighb_tria(i,iapex));
end;

for i=1:N_neighb_apex(iapex)
    Rcp(i+1+N_neighb_tria(iapex)) = R_apex(neighb_apex(i,iapex));
    Zcp(i+1+N_neighb_tria(iapex)) = Z_apex(neighb_apex(i,iapex));
    value1(i+1+N_neighb_tria(iapex)) = value_apex(neighb_apex(i,iapex));
end;

if rem((1+N_neighb_tria(iapex)+N_neighb_apex(iapex)),2)==0
    Rcp_shaped = reshape(Rcp,(1+N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
    Zcp_shaped = reshape(Zcp,(1+N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
    value1_shaped = reshape(value1,(1+N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
else
    Rcp_shaped = reshape(Rcp(1:N_neighb_tria(iapex)+N_neighb_apex(iapex)),(N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
    Zcp_shaped = reshape(Zcp(1:N_neighb_tria(iapex)+N_neighb_apex(iapex)),(N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
    value1_shaped = reshape(value1(1:N_neighb_tria(iapex)+N_neighb_apex(iapex)),(N_neighb_tria(iapex)+N_neighb_apex(iapex))/2,2);
end;

if 1+N_neighb_tria(iapex)+N_neighb_apex(iapex) >= 4
    [C,h]=contourf(Rcp_shaped,Zcp_shaped,value1_shaped,Levels,'LineStyle','none');
     for i=1:N_neighb_tria(iapex)
            i_tria =  neighb_tria(i,iapex)
            plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))], [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))], '-','LineWidth',0.1,'Color',[0.8,0.6,0.1]);
     end;
end;

end;


axis(Plot2DSize);
axis equal;

legend(hcontour,label2D,'Location','SouthWest');
legend('boxoff');

set(gca,'FontName','Times','FontSize',30);
%clabel(C,h);
title(Gtitle,'FontSize',36,'FontName','Times','interpreter','latex');
grid on;
grid minor;
colorbar('FontName','Times','FontSize',30);

Figname_pl=[PATH_PREFIX, Figname, '.eps'];

print('-depsc2',[PATH_PREFIX,Figname,'.eps']);