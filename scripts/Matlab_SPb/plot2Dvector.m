function iout=plot2Dvector(vecX,vecY,nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,Gtitle,PATH_PREFIX,flux_label);
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

%vecX1=vecX([A],:);
%vecY1=vecY([A],:);

vecR=(vecX.*(R1-R0)+vecY.*(Z1-Z0))./sqrt((R1-R0).*(R1-R0)+(Z1-Z0).*(Z1-Z0));
vecZ=(vecX.*(Z1-Z0)+vecY.*(R1-R0))./sqrt((R1-R0).*(R1-R0)+(Z1-Z0).*(Z1-Z0));

Rc=0.25*(R0+R1+R2+R3);
Zc=0.25*(Z0+Z1+Z2+Z3);

% for i=1:ny+2
%     for j=1:nx+2
%         R(2*(i-1)+1,2*(j-1)+1)=R0(i,j)+0.05*(R1(i,j)-R0(i,j));
%         Z(2*(i-1)+1,2*(j-1)+1)=Z0(i,j)+0.05*(Z1(i,j)-Z0(i,j));
%         Value(2*(i-1)+1,2*(j-1)+1)=value(i,j); 
%         R(2*(i-1)+1,2*(j-1)+2)=R1(i,j)-0.05*(R1(i,j)-R0(i,j));
%         Z(2*(i-1)+1,2*(j-1)+2)=Z1(i,j)-0.05*(Z1(i,j)-Z0(i,j));
%         Value(2*(i-1)+1,2*(j-1)+2)=value(i,j); 
%         R(2*(i-1)+2,2*(j-1)+1)=R2(i,j)+0.05*(R3(i,j)-R2(i,j));
%         Z(2*(i-1)+2,2*(j-1)+1)=Z2(i,j)+0.05*(Z3(i,j)-Z2(i,j));
%         Value(2*(i-1)+2,2*(j-1)+1)=value(i,j);
%         R(2*(i-1)+2,2*(j-1)+2)=R3(i,j)-0.05*(R3(i,j)-R2(i,j));
%         Z(2*(i-1)+2,2*(j-1)+2)=Z3(i,j)-0.05*(Z3(i,j)-Z2(i,j));
%         Value(2*(i-1)+2,2*(j-1)+2)=value(i,j);
%     end;
% end;

figure;
axes('FontName','Times','FontSize',24);
%contour(R,Z,flux_label);
hold;
quiver(Rc,Zc,vecR,vecZ,10.0);
%plot inner separatrix
plot(R0(nsep+3,[1:nc2+2 nc3+2:nx+2]),Z0(nsep+3,[1:nc2+2 nc3+2:nx+2]),'-k','LineWidth',1);

axis equal;
title(Gtitle,'FontSize',30,'FontName','Times');
grid on;
grid minor;

iout=0;


