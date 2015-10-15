function iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,value,Gtitle,Figname,Levels,label2D,Plot2DSize);
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

Value=zeros(2*ny,2*nx);
R=zeros(2*ny,2*nx);
Z=zeros(2*ny,2*nx);
for i=1:ny+2
    for j=1:nx+2
        R(2*(i-1)+1,2*(j-1)+1)=R0(i,j)+0.05*(R1(i,j)-R0(i,j));
        Z(2*(i-1)+1,2*(j-1)+1)=Z0(i,j)+0.05*(Z1(i,j)-Z0(i,j));
        Value(2*(i-1)+1,2*(j-1)+1)=value(i,j); 
        R(2*(i-1)+1,2*(j-1)+2)=R1(i,j)-0.05*(R1(i,j)-R0(i,j));
        Z(2*(i-1)+1,2*(j-1)+2)=Z1(i,j)-0.05*(Z1(i,j)-Z0(i,j));
        Value(2*(i-1)+1,2*(j-1)+2)=value(i,j); 
        R(2*(i-1)+2,2*(j-1)+1)=R2(i,j)+0.05*(R3(i,j)-R2(i,j));
        Z(2*(i-1)+2,2*(j-1)+1)=Z2(i,j)+0.05*(Z3(i,j)-Z2(i,j));
        Value(2*(i-1)+2,2*(j-1)+1)=value(i,j);
        R(2*(i-1)+2,2*(j-1)+2)=R3(i,j)-0.05*(R3(i,j)-R2(i,j));
        Z(2*(i-1)+2,2*(j-1)+2)=Z3(i,j)-0.05*(Z3(i,j)-Z2(i,j));
        Value(2*(i-1)+2,2*(j-1)+2)=value(i,j);
    end;
end;

RR=zeros(ny+2,nx+2);
ZZ=zeros(ny+2,nx+2);
for i=2:ny+1
    for j=2:nx+1
        dZ20 = Z2(i,j)-Z0(i,j);
        dZ31 = Z3(i,j)-Z1(i,j);
        dR02 = R0(i,j)-R2(i,j);
        dR13 = R1(i,j)-R3(i,j);
        R00=R0(i,j);
        R11=R1(i,j);
        Z00=Z0(i,j);
        Z11=Z1(i,j);
        D=dZ20*dR13-dZ31*dR02;
        BR=dZ20*R00+dR02*Z00;
        BZ=R11*dZ31+Z11*dR13;
        RR(i,j)=(BR*dR13-BZ*dR02)/D;
        ZZ(i,j)=(BZ*dZ20-BR*dZ31)/D;
        RR=0.25*(R0+R1+R2+R3);
        ZZ=0.25*(Z0+Z1+Z2+Z3);
    end;
end;

Rc=0.25*(R0+R1+R2+R3);
Zc=0.25*(Z0+Z1+Z2+Z3);


global PlotSize;
figure('Position',PlotSize);


%axes('FontName','Times','FontSize',24);
%[C,h]=contourf(R,Z,Value,Levels,'LineStyle','none');
%[C,h]=contourf(Rc(1:ny+1,1:nc1+1),Zc(1:ny+1,1:nc1+1),value(1:ny+1,1:nc1+1),Levels,'LineStyle','none');
%hold all;


%plot inner part of bottom PFR
%================================================================================
Rcp=zeros(ny+2,nc1+2);
Zcp=zeros(ny+2,nc1+2);
value1=zeros(ny+2,nc1+2);
Rcp(:,1:nc1+1)=Rc(:,1:nc1+1);
Zcp(:,1:nc1+1)=Zc(:,1:nc1+1);
value1(:,1:nc1+1)=value(:,1:nc1+1);
for i=1:ny+2
    Rcp(i,nc1+2)=Rc(i,rightp(i,nc1+1)+2);
    Zcp(i,nc1+2)=Zc(i,rightp(i,nc1+1)+2);
    value1(i,nc1+2)=value(i,rightp(i,nc1+1)+2);
end;
[C,hcontour]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
hold all;

%plot outer part of bottom PFR
%================================================================================
Rcp=zeros(ny+2,nx-nc4+1);
Zcp=zeros(ny+2,nx-nc4+1);
value1=zeros(ny+2,nx-nc4+1);
Rcp(:,2:nx-nc4+1)=Rc(:,nc4+3:nx+2);
Zcp(:,2:nx-nc4+1)=Zc(:,nc4+3:nx+2);
value1(:,2:nx-nc4+1)=value(:,nc4+3:nx+2);
for i=1:ny+2
Rcp(i,1)=Rc(i,leftp(i,nc4+3)+2);
Zcp(i,1)=Zc(i,leftp(i,nc4+3)+2);
value1(i,1)=value(i,leftp(i,nc4+3)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');


%plot inner part of top PFR
%================================================================================
if (ntt-nc2 > 1)  % plot this region for DND topology only and do not plot for SND
Rcp=zeros(ny+2,ntt-nc2+1);
Zcp=zeros(ny+2,ntt-nc2+1);
value1=zeros(ny+2,ntt-nc2+1);
Rcp(:,2:ntt-nc2+1)=Rc(:,nc2+3:ntt+2);
Zcp(:,2:ntt-nc2+1)=Zc(:,nc2+3:ntt+2);
value1(:,2:ntt-nc2+1)=value(:,nc2+3:ntt+2);
for i=1:ny+2
    Rcp(i,1)=Rc(i,leftp(i,nc2+3)+2);
    Zcp(i,1)=Zc(i,leftp(i,nc2+3)+2);
    value1(i,1)=value(i,leftp(i,nc2+3)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
end;

%plot outer part of top PFR
%================================================================================
if (nc3-ntt > 1) % plot this region for DND topology only and do not plot for SND
Rcp=zeros(ny+2,nc3-ntt);
Zcp=zeros(ny+2,nc3-ntt);
value1=zeros(ny+2,nc3-ntt);
Rcp(:,1:nc3-ntt-1)=Rc(:,ntt+3:nc3+1);
Zcp(:,1:nc3-ntt-1)=Zc(:,ntt+3:nc3+1);
value1(:,1:nc3-ntt-1)=value(:,ntt+3:nc3+1);
for i=1:ny+2
    Rcp(i,nc3-ntt)=Rc(i,rightp(i,nc3+1)+2);
    Zcp(i,nc3-ntt)=Zc(i,rightp(i,nc3+1)+2);
    value1(i,nc3-ntt)=value(i,rightp(i,nc3+1)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');
end;

%plot HFS part of core and SOL 
%================================================================================
Rcp=zeros(ny+2,nc2-nc1+3);
Zcp=zeros(ny+2,nc2-nc1+3);
value1=zeros(ny+2,nc2-nc1+3);
Rcp(:,2:nc2-nc1+2)=Rc(:,nc1+2:nc2+2);
Zcp(:,2:nc2-nc1+2)=Zc(:,nc1+2:nc2+2);
value1(:,2:nc2-nc1+2)=value(:,nc1+2:nc2+2);
for i=1:ny+2
    Rcp(i,1)=Rc(i,leftp(i,nc1+2)+2);
    Zcp(i,1)=Zc(i,leftp(i,nc1+2)+2);
    value1(i,1)=value(i,leftp(i,nc1+2)+2);
    Rcp(i,nc2-nc1+3)=Rc(i,rightp(i,nc2+2)+2);
    Zcp(i,nc2-nc1+3)=Zc(i,rightp(i,nc2+2)+2);
    value1(i,nc2-nc1+3)=value(i,rightp(i,nc2+2)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');

%plot LFS part of core and SOL 
%================================================================================
Rcp=zeros(ny+2,nc4-nc3+3);
Zcp=zeros(ny+2,nc4-nc3+3);
value1=zeros(ny+2,nc4-nc3+3);
Rcp(:,2:nc4-nc3+2)=Rc(:,nc3+2:nc4+2);
Zcp(:,2:nc4-nc3+2)=Zc(:,nc3+2:nc4+2);
value1(:,2:nc4-nc3+2)=value(:,nc3+2:nc4+2);
for i=1:ny+2
    Rcp(i,1)=Rc(i,leftp(i,nc3+2)+2);
    Zcp(i,1)=Zc(i,leftp(i,nc3+2)+2);
    value1(i,1)=value(i,leftp(i,nc3+2)+2);
    Rcp(i,nc4-nc3+3)=Rc(i,rightp(i,nc4+2)+2);
    Zcp(i,nc4-nc3+3)=Zc(i,rightp(i,nc4+2)+2);
    value1(i,nc4-nc3+3)=value(i,rightp(i,nc4+2)+2);
end;
[C,h]=contourf(Rcp,Zcp,value1,Levels,'LineStyle','none');
%[C,h]=contourf(Rcp,Zcp,value1,Levels);
%clabel(C,h,'manual');

%axis([1.1 1.7  -1.25 -0.65]);
axis(Plot2DSize);
axis equal;

legend(hcontour,label2D,'Location','SouthWest');
legend('boxoff');

% %plot flux surfaces
for i=nsep+3:ny+2
    plot(R0(i,[1:nc2+2]),Z0(i,[1:nc2+2]),'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot(R0(i,[nc3+2:nx+2]),Z0(i,[nc3+2:nx+2]),'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
end;
for i=1:ny+2
    plot([R0(i,[1:nc1+1]) R1(i,nc1+1)],[Z0(i,[1:nc1+1]) Z1(i,nc1+1)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc1+2:nc2+2]) R1(i,nc2+2)],[Z0(i,[nc1+2:nc2+2]) Z1(i,nc2+2)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc2+3:ntt+2]) R1(i,ntt+2)],[Z0(i,[nc2+3:ntt+2]) Z1(i,ntt+2)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[ntt+3:nc3+1]) R1(i,nc3+1)],[Z0(i,[ntt+3:nc3+1]) Z1(i,nc3+1)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc3+2:nc4+2]) R1(i,nc4+2)],[Z0(i,[nc3+2:nc4+2]) Z1(i,nc4+2)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
    plot([R0(i,[nc4+3:nx+2]) R1(i,nx+2)],[Z0(i,[nc4+3:nx+2]) Z1(i,nx+2)],'-k','LineWidth',0.3,'Color',[0.25,0.25,0.25]);
end;% for j=1:nx
%     plot(R0([1:ny],j),Z0([1:ny],j),'-k','LineWidth',0.3);
% end;

%plot(R0(nsep+3,[1:ntt+2 ntt+3:nx+2]),Z0(nsep+3,:),'-k','LineWidth',0.1,'Color',[0.1,0.1,0.1]);

%plot outer separatrix

if (nsep2 > nsep)
plot(R0(nsep2+3,[1:ntt+2]),Z0(nsep2+3,[1:ntt+2]),'-k','LineWidth',0.1,'Color',[0.5,0.5,0.5]);
plot(R0(nsep2+3,[ntt+3:nx+2]),Z0(nsep2+3,[ntt+3:nx+2]),'-k','LineWidth',0.1,'Color',[0.5,0.5,0.5]);
end;

%plot(R0(nsep+2,nc3+2:nx+2),Z0(nsep+2,nc3+2:nx+2),'-k','LineWidth',2);



set(gca,'FontName','Times','FontSize',30);
%clabel(C,h);
title(Gtitle,'FontSize',36,'FontName','Times','interpreter','latex');
grid on;
grid minor;
colorbar('FontName','Times','FontSize',30);

Figname_pl=[PATH_PREFIX, Figname, '.eps'];

print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
iout=0;


