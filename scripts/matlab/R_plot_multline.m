function iout=R_plot_multline(y2,value,nx,ny,npl,nlines,Gtitle,Ylabel);

figure;
set(figure(gcf), 'name', Gtitle);
axes('FontName','Times','FontSize',24);
npli=0;
if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-o','LineWidth',2,'Color',[1,0,0]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-h','LineWidth',2,'Color',[0,0,0]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-^','LineWidth',2,'Color',[0.15,0.05,0.5]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-<','LineWidth',2,'Color',[1,0.6,0]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-v','LineWidth',2,'Color',[1,0.05,0.75]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-+','LineWidth',2,'Color',[0,0,1]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-o','LineWidth',2,'Color',[0.5,0.5,1]);
  hold all;
end;
npli=npli+1;


if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-s','LineWidth',2,'Color',[0.0,0.5,1]);
  hold all;
end;
npli=npli+1;


if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-*','LineWidth',2,'Color',[0.5,0.1,0]);
  hold all;
end;
npli=npli+1;

%%%%%%%%

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-o','LineWidth',2,'Color',[0.6,0.05,0.4]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-s','LineWidth',2,'Color',[0.35,0.65,0.15]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-h','LineWidth',2,'Color',[0.8,0.2,0.8]);
  hold all;
end;
npli=npli+1;

if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-*','LineWidth',2,'Color',[0.2,0.2,0.5]);
  hold all;
end;
npli=npli+1;


if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-+','LineWidth',2,'Color',[0.4,0.4,0.55]);
  hold all;
end;
npli=npli+1;


if npl + npli <= nx && npli <= nlines - 1
  plot(y2(1:ny+2,npl+npli+2),value(1:ny+2,npl+npli+2),'-<','LineWidth',2,'Color',[0.5,0.5,0.5]);
  hold all;
end;
npli=npli+1;

%plot(x2(npl+1,nc1+2:nc2+2),value(npl+1,nc1+2:nc2+2),'-s','LineWidth',2,'Color',[0,0,1]);
%hold all;
%plot(x2(npl,nc1+2:nc2+2),value(npl,nc1+2:nc2+2),'-*','LineWidth',2,'Color',[0.45,0.1,0.05]);
%hold all;
%plot(x2(npl-1,nc1+2:nc2+2),value(npl-1,nc1+2:nc2+2),'-h','LineWidth',2,'Color',[0.75,0.2,0.15]);
%hold all;
%plot(x2(npl-2,nc1+2:nc2+2),value(npl-2,nc1+2:nc2+2),'-^','LineWidth',2,'Color',[0,0,0]);
%hold all;
%plot(x2(npl-3,nc1+2:nc2+2),value(npl-3,nc1+2:nc2+2),'->','LineWidth',2,'Color',[0.15,0.05,0.5]);
%hold all;
%plot(x2(npl-4,nc1+2:nc2+2),value(npl-4,nc1+2:nc2+2),'-<','LineWidth',2,'Color',[0.25,0.5,0.25]);
%hold all;
%plot(x2(npl-5,nc1+2:nc2+2),value(npl-5,nc1+2:nc2+2),'-v','LineWidth',2,'Color',[1,0.6,0]);
%hold all;
%plot(x2(npl-6,nc1+2:nc2+2),value(npl-6,nc1+2:nc2+2),'-+','LineWidth',2,'Color',[1,0.05,0.75]);
%hold all;

xlabel('Distance from separatrix, m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter', 'latex','FontSize',30,'FontName','Times');
title(Gtitle,'FontName','Times','FontSize',30);
legend(sprintf('x=%3i',npl),sprintf('x=%3i',npl+1),sprintf('x=%3i',npl+2),sprintf('x=%3i',npl+3),sprintf('x=%3i',npl+4),sprintf('x=%3i',npl+5),sprintf('x=%3i',npl+6),sprintf('x=%3i',npl+7),sprintf('x=%3i',npl+8),sprintf('x=%3i',npl+9),sprintf('x=%3i',npl+10),sprintf('x=%3i',npl+11),sprintf('x=%3i',npl+12),sprintf('x=%3i',npl+13),sprintf('x=%3i',npl+14),sprintf('x=%3i',npl+15),sprintf('x=%3i',npl+16),sprintf('x=%3i',npl+17),'Location','NorthEastOutside');
grid on
grid minor;
iout=0;