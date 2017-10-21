%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRODUCES 2D PLOTS OF EIRENE PROFILES ON TRIANGULAR MESH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

function iout=plot_Eirene_profiles2(PATH_PREFIX,value,Gtitle,Figname,Levels,label2D,Plot2DSize);

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

Colours=jet(128);
min_Levels=min(Levels);
max_Levels=max(Levels);

 for i_tria=1:N_tria
%    i_tria =  neighb_tria(i,iapex)
    plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))], [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))], '-','LineWidth',0.1,'Color',[0.8,0.6,0.1]);
    if value(i_tria) > max_Levels
        fill([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))], [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],Colours(128,:));
    elseif value(i_tria) < min_Levels
        fill([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))], [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],'w');
    else
        icolour=floor( (value(i_tria) - min_Levels) / (max_Levels - min_Levels) * size(Colours,1) ) + 1;
        fill([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))], [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],Colours(icolour,:));        
    end;
 end;





axis(Plot2DSize);
axis equal;

%legend(hcontour,label2D,'Location','SouthWest');
%legend('boxoff');

set(gca,'FontName','Times','FontSize',20);
%clabel(C,h);
title(Gtitle,'FontSize',36,'FontName','Times','interpreter','latex');
grid on;
grid minor;

legend(label2D);

caxis([min_Levels max_Levels]);
colormap(Colours);
colorbar('FontName','Times','FontSize',30);

Figname_pl=[PATH_PREFIX, Figname, '.eps'];

print('-depsc2',[PATH_PREFIX,Figname,'.eps']);