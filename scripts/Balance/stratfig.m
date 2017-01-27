%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stratfig creates axis handles for strata decomposition plots.                %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function axstrat = stratfig()

figure('windowstyle','docked');
margin = 0.04;
width = (1-5*margin)/4;
height = (1-6*margin)/2;
axstrat(1) = subplot('position',[margin height+4*margin width height]); box on; hold on;
title(axstrat(1),'Due to atom-plasma collisions','interpreter','latex');
axstrat(2) = subplot('position',[width+2*margin height+4*margin width height]); box on; hold on;
title(axstrat(2),'Due to molecule-plasma collisions','interpreter','latex');
axstrat(3) = subplot('position',[2*width+3*margin height+4*margin width height]); box on; hold on;
title(axstrat(3),'Due to test ion-plasma collisions','interpreter','latex');
axstrat(4) = subplot('position',[3*width+4*margin height+4*margin width height]); box on; hold on;
title(axstrat(4),'Due to recombination','interpreter','latex');
axstrat(5) = subplot('position',[margin margin width height]); box on; hold on;
title(axstrat(5),'Due to atom-plasma collisions','interpreter','latex');
axstrat(6) = subplot('position',[width+2*margin margin width height]); box on; hold on;
title(axstrat(6),'Due to molecule-plasma collisions','interpreter','latex');
axstrat(7) = subplot('position',[2*width+3*margin margin width height]); box on; hold on;
title(axstrat(7),'Due to test ion-plasma collisions','interpreter','latex');
axstrat(8) = subplot('position',[3*width+4*margin margin width height]); box on; hold on; 
title(axstrat(8),'Due to recombination','interpreter','latex');
set(axstrat,'ticklabelinterpreter','latex')
axstrat(9) = subplot('position',[0.5 2*height+5*margin 0 0],'visible','off');
axstrat(10) = subplot('position',[0.5 height+2*margin 0 0],'visible','off');

end