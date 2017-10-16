function iout=plot2D_no_guard_cell(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,value,Gtitle,Figname,Levels,label2D,Plot2DSize);


% If Figname input variable ends with 'log10' then use logarythmic scale of
% colorbar. It is assumed that value and Levels have appropriate values.

Figname_length = size(Figname);

LOGPLOT = 0; % plot linear colorbar by default

if (regexp(Figname,'log10')+4 == Figname_length(2)) 
    string_match = regexp(Figname,'log10','match');
    if size(string_match) == 1 
        if string_match{1} == 'log10' 
           LOGPLOT = 1;
        end;
    end;
end;

A=(ny+2:-1:1);

R0=readdatavalue([PATH_PREFIX,'crx0.dat'],nx,ny);
R1=readdatavalue([PATH_PREFIX,'crx1.dat'],nx,ny);
R2=readdatavalue([PATH_PREFIX,'crx2.dat'],nx,ny);
R3=readdatavalue([PATH_PREFIX,'crx3.dat'],nx,ny);

Z0=readdatavalue([PATH_PREFIX,'cry0.dat'],nx,ny);
Z1=readdatavalue([PATH_PREFIX,'cry1.dat'],nx,ny);
Z2=readdatavalue([PATH_PREFIX,'cry2.dat'],nx,ny);
Z3=readdatavalue([PATH_PREFIX,'cry3.dat'],nx,ny);

leftp=readdatavalue([PATH_PREFIX 'leftix.dat'],nx,ny);
rightp=readdatavalue([PATH_PREFIX 'rightix.dat'],nx,ny);
%top=readdatavalue([PATH_PREFIX 'topiy.dat'],nx,ny);
%bottom=readdatavalue([PATH_PREFIX 'bottomiy.dat'],nx,ny);


%value1=value([A],:);

% % % Value=zeros(2*ny,2*nx);
% % % R=zeros(2*ny,2*nx);
% % % Z=zeros(2*ny,2*nx);
% % % for i=1:ny+2
% % %     for j=1:nx+2
% % %         R(2*(i-1)+1,2*(j-1)+1)=R0(i,j)+0.05*(R1(i,j)-R0(i,j));
% % %         Z(2*(i-1)+1,2*(j-1)+1)=Z0(i,j)+0.05*(Z1(i,j)-Z0(i,j));
% % %         Value(2*(i-1)+1,2*(j-1)+1)=value(i,j); 
% % %         R(2*(i-1)+1,2*(j-1)+2)=R1(i,j)-0.05*(R1(i,j)-R0(i,j));
% % %         Z(2*(i-1)+1,2*(j-1)+2)=Z1(i,j)-0.05*(Z1(i,j)-Z0(i,j));
% % %         Value(2*(i-1)+1,2*(j-1)+2)=value(i,j); 
% % %         R(2*(i-1)+2,2*(j-1)+1)=R2(i,j)+0.05*(R3(i,j)-R2(i,j));
% % %         Z(2*(i-1)+2,2*(j-1)+1)=Z2(i,j)+0.05*(Z3(i,j)-Z2(i,j));
% % %         Value(2*(i-1)+2,2*(j-1)+1)=value(i,j);
% % %         R(2*(i-1)+2,2*(j-1)+2)=R3(i,j)-0.05*(R3(i,j)-R2(i,j));
% % %         Z(2*(i-1)+2,2*(j-1)+2)=Z3(i,j)-0.05*(Z3(i,j)-Z2(i,j));
% % %         Value(2*(i-1)+2,2*(j-1)+2)=value(i,j);
% % %     end;
% % % end;
% % % 
% % % RR=zeros(ny+2,nx+2);
% % % ZZ=zeros(ny+2,nx+2);
% % % for i=2:ny+1
% % %     for j=2:nx+1
% % %         dZ20 = Z2(i,j)-Z0(i,j);
% % %         dZ31 = Z3(i,j)-Z1(i,j);
% % %         dR02 = R0(i,j)-R2(i,j);
% % %         dR13 = R1(i,j)-R3(i,j);
% % %         R00=R0(i,j);
% % %         R11=R1(i,j);
% % %         Z00=Z0(i,j);
% % %         Z11=Z1(i,j);
% % %         D=dZ20*dR13-dZ31*dR02;
% % %         BR=dZ20*R00+dR02*Z00;
% % %         BZ=R11*dZ31+Z11*dR13;
% % %         RR(i,j)=(BR*dR13-BZ*dR02)/D;
% % %         ZZ(i,j)=(BZ*dZ20-BR*dZ31)/D;
% % %         RR=0.25*(R0+R1+R2+R3);
% % %         ZZ=0.25*(Z0+Z1+Z2+Z3);
% % %     end;
% % % end;

Rc=0.25*(R0+R1+R2+R3);
Zc=0.25*(Z0+Z1+Z2+Z3);


%global PlotSize;
%figure('Position',PlotSize);


%axes('FontName','Times','FontSize',24);
%[C,h]=contourf(R,Z,Value,Levels,'LineStyle','none');
%[C,h]=contourf(Rc(1:ny+1,1:nc1+1),Zc(1:ny+1,1:nc1+1),value(1:ny+1,1:nc1+1),Levels,'LineStyle','none');
%hold all;

colormap(jet);


%plot inner part of bottom PFR
%================================================================================
Rcp=zeros(ny,nc1+1);
Zcp=zeros(ny,nc1+1);
value1=zeros(ny,nc1+1);
Rcp(:,1:nc1)=Rc(2:ny+1,2:nc1+1);
Zcp(:,1:nc1)=Zc(2:ny+1,2:nc1+1);
value1(:,1:nc1)=value(2:ny+1,2:nc1+1);
for i=2:ny+1
    Rcp(i-1,nc1+1)=Rc(i,rightp(i,nc1+1)+2);
    Zcp(i-1,nc1+1)=Zc(i,rightp(i,nc1+1)+2);
    value1(i-1,nc1+1)=value(i,rightp(i,nc1+1)+2);
end;
[C,hcontour]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
hold all;

%plot outer part of bottom PFR
%================================================================================
Rcp=zeros(ny,nx-nc4);
Zcp=zeros(ny,nx-nc4);
value1=zeros(ny,nx-nc4);
Rcp(:,2:nx-nc4)=Rc(2:ny+1,nc4+3:nx+1);
Zcp(:,2:nx-nc4)=Zc(2:ny+1,nc4+3:nx+1);
value1(:,2:nx-nc4)=value(2:ny+1,nc4+3:nx+1);
for i=2:ny+1
Rcp(i-1,1)=Rc(i,leftp(i,nc4+3)+2);
Zcp(i-1,1)=Zc(i,leftp(i,nc4+3)+2);
value1(i-1,1)=value(i,leftp(i,nc4+3)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');


%plot inner part of top PFR
%================================================================================
if (ntt-nc2 > 1)  % plot this region for DND topology only and do not plot for SND
Rcp=zeros(ny,ntt-nc2);
Zcp=zeros(ny,ntt-nc2);
value1=zeros(ny,ntt-nc2);
Rcp(:,2:ntt-nc2)=Rc(2:ny+1,nc2+3:ntt+1);
Zcp(:,2:ntt-nc2)=Zc(2:ny+1,nc2+3:ntt+1);
value1(:,2:ntt-nc2)=value(2:ny+1,nc2+3:ntt+1);
for i=2:ny+1
    Rcp(i-1,1)=Rc(i,leftp(i,nc2+3)+2);
    Zcp(i-1,1)=Zc(i,leftp(i,nc2+3)+2);
    value1(i-1,1)=value(i,leftp(i,nc2+3)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
end;

%plot outer part of top PFR
%================================================================================
if (nc3-ntt > 1) % plot this region for DND topology only and do not plot for SND
Rcp=zeros(ny,nc3-ntt-1);
Zcp=zeros(ny,nc3-ntt-1);
value1=zeros(ny,nc3-ntt-1);
Rcp(:,1:nc3-ntt-2)=Rc(2:ny+1,ntt+3:nc3);
Zcp(:,1:nc3-ntt-2)=Zc(2:ny+1,ntt+3:nc3);
value1(:,1:nc3-ntt-2)=value(2:ny+1,ntt+3:nc3);
for i=1:ny+2
    Rcp(i-1,nc3-ntt)=Rc(i,rightp(i,nc3+1)+2);
    Zcp(i-1,nc3-ntt)=Zc(i,rightp(i,nc3+1)+2);
    value1(i-1,nc3-ntt)=value(i,rightp(i,nc3+1)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
end;

%plot HFS part of core and SOL 
%================================================================================
Rcp=zeros(ny,nc2-nc1+3);
Zcp=zeros(ny,nc2-nc1+3);
value1=zeros(ny,nc2-nc1+3);
Rcp(:,2:nc2-nc1+2)=Rc(2:ny+1,nc1+2:nc2+2);
Zcp(:,2:nc2-nc1+2)=Zc(2:ny+1,nc1+2:nc2+2);
value1(:,2:nc2-nc1+2)=value(2:ny+1,nc1+2:nc2+2);
for i=2:ny+1
    Rcp(i-1,1)=Rc(i,leftp(i,nc1+2)+2);
    Zcp(i-1,1)=Zc(i,leftp(i,nc1+2)+2);
    value1(i-1,1)=value(i,leftp(i,nc1+2)+2);
    Rcp(i-1,nc2-nc1+3)=Rc(i,rightp(i,nc2+2)+2);
    Zcp(i-1,nc2-nc1+3)=Zc(i,rightp(i,nc2+2)+2);
    value1(i-1,nc2-nc1+3)=value(i,rightp(i,nc2+2)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');

%plot LFS part of core and SOL 
%================================================================================
Rcp=zeros(ny,nc4-nc3+3);
Zcp=zeros(ny,nc4-nc3+3);
value1=zeros(ny,nc4-nc3+3);
Rcp(:,2:nc4-nc3+2)=Rc(2:ny+1,nc3+2:nc4+2);
Zcp(:,2:nc4-nc3+2)=Zc(2:ny+1,nc3+2:nc4+2);
value1(:,2:nc4-nc3+2)=value(2:ny+1,nc3+2:nc4+2);
for i=2:ny+1
    Rcp(i-1,1)=Rc(i,leftp(i,nc3+2)+2);
    Zcp(i-1,1)=Zc(i,leftp(i,nc3+2)+2);
    value1(i-1,1)=value(i,leftp(i,nc3+2)+2);
    Rcp(i-1,nc4-nc3+3)=Rc(i,rightp(i,nc4+2)+2);
    Zcp(i-1,nc4-nc3+3)=Zc(i,rightp(i,nc4+2)+2);
    value1(i-1,nc4-nc3+3)=value(i,rightp(i,nc4+2)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');

%axis([1.1 1.7  -1.25 -0.65]);
axis(Plot2DSize);
axis equal;

 legend(hcontour,label2D,'Location','SouthWest');
 legend('boxoff');

caxis([min(Levels) max(Levels)]);


%plot flux surfaces
if  Plot2DSize(1) > min(min(min(min(R0,R1),min(R2,R3)))) || Plot2DSize(3) > min(min(min(min(Z0,Z1),min(Z2,Z3)))) || ...
        Plot2DSize(2) < max(max(max(max(R0,R1),max(R2,R3)))) || Plot2DSize(4) < max(max(max(max(Z0,Z1),max(Z2,Z3))))
  for i=nsep+3:ny+2
    plot(R0(i,[1:nc2+2]),Z0(i,[1:nc2+2]),'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot(R0(i,[nc3+2:nx+2]),Z0(i,[nc3+2:nx+2]),'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
  end;
  for i=1:ny+2
    plot([R0(i,[1:nc1+1]) R1(i,nc1+1)],[Z0(i,[1:nc1+1]) Z1(i,nc1+1)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc1+2:nc2+2]) R1(i,nc2+2)],[Z0(i,[nc1+2:nc2+2]) Z1(i,nc2+2)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc2+3:ntt+2]) R1(i,ntt+2)],[Z0(i,[nc2+3:ntt+2]) Z1(i,ntt+2)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[ntt+3:nc3+1]) R1(i,nc3+1)],[Z0(i,[ntt+3:nc3+1]) Z1(i,nc3+1)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc3+2:nc4+2]) R1(i,nc4+2)],[Z0(i,[nc3+2:nc4+2]) Z1(i,nc4+2)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc4+3:nx+2]) R1(i,nx+2)],[Z0(i,[nc4+3:nx+2]) Z1(i,nx+2)],'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
  end;

  for j=1:nx+2
     plot(R0([1:ny+2],j),Z0([1:ny+2],j),'-k','LineWidth',0.05,'Color',[0.25,0.25,0.25]);
  end;
end
 
i=nsep+3;
plot([R0(i,[1:nc1+1]) R1(i,nc1+1)],[Z0(i,[1:nc1+1]) Z1(i,nc1+1)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);
plot([R0(i,[nc1+2:nc2+2]) R1(i,nc2+2)],[Z0(i,[nc1+2:nc2+2]) Z1(i,nc2+2)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);
plot([R0(i,[nc2+3:ntt+2]) R1(i,ntt+2)],[Z0(i,[nc2+3:ntt+2]) Z1(i,ntt+2)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);
plot([R0(i,[ntt+3:nc3+1]) R1(i,nc3+1)],[Z0(i,[ntt+3:nc3+1]) Z1(i,nc3+1)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);
plot([R0(i,[nc3+2:nc4+2]) R1(i,nc4+2)],[Z0(i,[nc3+2:nc4+2]) Z1(i,nc4+2)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);
plot([R0(i,[nc4+3:nx+2]) R1(i,nx+2)],[Z0(i,[nc4+3:nx+2]) Z1(i,nx+2)],'-k','LineWidth',0.1,'Color',[0.25,0.25,0.25]);

%plot(R0(nsep+3,[1:ntt+2 ntt+3:nx+2]),Z0(nsep+3,:),'-k','LineWidth',0.1,'Color',[0.1,0.1,0.1]);

%plot outer separatrix

if (nsep2 > nsep)
plot(R0(nsep2+3,[1:ntt+2]),Z0(nsep2+3,[1:ntt+2]),'-k','LineWidth',0.1,'Color',[0.5,0.5,0.5]);
plot(R0(nsep2+3,[ntt+3:nx+2]),Z0(nsep2+3,[ntt+3:nx+2]),'-k','LineWidth',0.1,'Color',[0.5,0.5,0.5]);
end;

%plot(R0(nsep+2,nc3+2:nx+2),Z0(nsep+2,nc3+2:nx+2),'-k','LineWidth',2);

set(gca,'FontName','Times','FontSize',28);
if LOGPLOT
    labels_log = linspace(min(Levels),max(Levels),(max(Levels)-min(Levels))*4+1);
    labels_log_num = linspace(min(Levels),max(Levels),(max(Levels)-min(Levels))+1);
    cbar_axes = colorbar;
    set(cbar_axes,'YTick', labels_log,'YTickLabel', 1E-3*round(10.^(labels_log+3)), 'FontName','Times','FontSize',24);    
else
    colorbar('FontName','Times','FontSize',24);
end;    
%clabel(C,h);
title(Gtitle,'FontSize',30,'FontName','Times','interpreter','latex');
grid on;
grid minor;


Figname_pl=[PATH_PREFIX, Figname, '.eps'];

%print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
% print('-djpeg',[PATH_PREFIX,'../../',Figname,'.jpg']);
% print('-dpng',[PATH_PREFIX,Figname,'.png']);

iout=0;


