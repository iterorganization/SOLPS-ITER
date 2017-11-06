function iout=plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,value,Gtitle,Figname,Plot2DSize);
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


Rc=0.25*(R0+R1+R2+R3);
Zc=0.25*(Z0+Z1+Z2+Z3);


% scrsz = get(0,'ScreenSize');
% figure('Position',[1 scrsz(2) scrsz(3) scrsz(4)])


figure('Position',[1 900 1200 900])


% axes('FontName','Times','FontSize',24);
%[C,h]=contourf(R,Z,Value,Levels,'LineStyle','none');
%[C,h]=contourf(Rc(1:ny+1,1:nc1+1),Zc(1:ny+1,1:nc1+1),value(1:ny+1,1:nc1+1),Levels,'LineStyle','none');

hold all;


%plot mesh
for i=nsep+3:ny+2
    plot(R0(i,[1:nc2+2 nc3+2:nx+2]),Z0(i,[1:nc2+2 nc3+2:nx+2]),'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
end;
for i=1:ny+2
    plot([R0(i,[1:nc1+1]) R1(i,nc1+1)],[Z0(i,[1:nc1+1]) Z1(i,nc1+1)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot([R0(i,[nc1+2:nc2+2]) R1(i,nc2+2)],[Z0(i,[nc1+2:nc2+2]) Z1(i,nc2+2)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot([R0(i,[nc2+3:ntt+2]) R1(i,ntt+2)],[Z0(i,[nc2+3:ntt+2]) Z1(i,ntt+2)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot([R0(i,[ntt+3:nc3+1]) R1(i,nc3+1)],[Z0(i,[ntt+3:nc3+1]) Z1(i,nc3+1)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot([R0(i,[nc3+2:nc4+2]) R1(i,nc4+2)],[Z0(i,[nc3+2:nc4+2]) Z1(i,nc4+2)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot([R0(i,[nc4+3:nx+2]) R1(i,nx+2)],[Z0(i,[nc4+3:nx+2]) Z1(i,nx+2)],'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
end;
 for j=1:nx+2
     plot(R0([1:ny+2],j),Z0([1:ny+2],j),'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
 end;


i=ny+1;
j=1;
%for i=1:ny+2
while i>=1
    while rightp(i,j)<=nx % j<nx
        jbeg=j; 
        jend=j;    
        jcount=0;    
        while (value(i,jbeg)*value(i,jend) > 0 & rightp(i,jend) <= nx)              
            jend = rightp(i,jend) + 2;        
            jcount = jcount + 1;    
        end;
%    jend = jend - 1; 
        if jcount > 1 
             %jbeg < jend - 1
%        clear(length1);
%        clear(points);
            length1=zeros(1,2*(jcount)-1);        
            points=zeros(2,2*(jcount)-1);        
            length1(1,1) = 0.0;        
            points(1,1)=Rc(i,jbeg);        
            points(2,1)=Zc(i,jbeg);        
            jj=2;        
            j1=jbeg;       
            while jj <= jcount %jj=2:jend-jbeg
%               length1(1,2*jj-2)=length1(1,2*jj-3)+sqrt( ( 0.5*( R2(i,jj+jbeg-1) + R0(i,jj+jbeg-1) ) - Rc(i,jj+jbeg-2) )^2 + ...
%                      ( 0.5*( Z2(i,jj+jbeg-1) + Z0(i,jj+jbeg-1) ) - Zc(i,jj+jbeg-2) )^2);           
                length1(1,2*jj-2)=length1(1,2*jj-3)+sqrt( ( 0.5*( R2(i,rightp(i,j1)+2) + R0(i,rightp(i,j1)+2) ) - Rc(i,j1) )^2 + ...
                    ( 0.5*( Z2(i,rightp(i,j1)+2) + Z0(i,rightp(i,j1)+2) ) - Zc(i,j1) )^2);            
                points(1,2*jj-2)=0.5*( R2(i,rightp(i,j1)+2) + R0(i,rightp(i,j1)+2) );            
                points(2,2*jj-2)= 0.5*( Z2(i,rightp(i,j1)+2) + Z0(i,rightp(i,j1)+2) );            
                length1(1,2*jj-1)=length1(1,2*jj-2)+sqrt( ( Rc(i,rightp(i,j1)+2)  - 0.5*( R2(i,rightp(i,j1)+2) + R0(i,rightp(i,j1)+2) ) )^2 + ...
                    (  Zc(i,rightp(i,j1)+2)  - 0.5*( Z2(i,rightp(i,j1)+2) + Z0(i,rightp(i,j1)+2) ) )^2);            
%               length1(1,2*jj-1)=length1(1,2*jj-2)+sqrt( ( Rc(i,jj+jbeg-1)  - 0.5*( R2(i,jj+jbeg-1) + R0(i,jj+jbeg-1) ) )^2 + ...
%                 (  Zc(i,jj+jbeg-1)  - 0.5*( Z2(i,jj+jbeg-1) + Z0(i,jj+jbeg-1) ) )^2);                        
                points(1,2*jj-1)=Rc(i,rightp(i,j1)+2);            
                points(2,2*jj-1)=Zc(i,rightp(i,j1)+2);            
                jj=jj+1;            
                j1=rightp(i,j1)+2;        
            end;        
            pp = spline(length1,points);
%               yy = ppval(pp,linspace(length1(1,1),length1(1,2*(jend-jbeg)-1),2*(jend-jbeg)-1));
            yy = ppval(pp,length1);
        
            if value(i,jbeg) > 0             
                plot(yy(1,:),yy(2,:),'-r','LineWidth',1.0);            
                line([Rc(i,leftp(i,jend)+2) R0(i,leftp(i,jend)+2)], [Zc(i,leftp(i,jend)+2) Z0(i,leftp(i,jend)+2)],'LineStyle','-','Color','r','LineWidth',1.0);            
                line([Rc(i,leftp(i,jend)+2) R2(i,leftp(i,jend)+2)], [Zc(i,leftp(i,jend)+2) Z2(i,leftp(i,jend)+2)],'LineStyle','-','Color','r','LineWidth',1.0);       
            else              
                plot(yy(1,:),yy(2,:),'Color',[0.5,0.0,1.0],'LineWidth',1.0);            
                line([Rc(i,jbeg) R1(i,jbeg)], [Zc(i,jbeg) Z1(i,jbeg)],'LineStyle','-','Color',[0.5,0.0,1.0],'LineWidth',1.0);            
                line([Rc(i,jbeg) R3(i,jbeg)], [Zc(i,jbeg) Z3(i,jbeg)],'LineStyle','-','Color',[0.5,0.0,1.0],'LineWidth',1.0);                    
            end;        
            hold all;        
            j=jend;    
        else            
            j=rightp(i,jend) + 2;
            if j > nx+2
                break;
            end;
        end;
    end;
    if ntt > nc2 % Double null
        if (j == ntt+2 & i > nsep2+2) || (j == nx+2 & i <= nsep2+2)
            j = ntt+3;
            continue
        end 
    end;
%    if i>=nsep    
        i=i-1;
        j=1;
%    else        
%        i=i-4;
%    end;
end;



%plot inner separatrix
%for i=nsep+3:ny+2
i=nsep+3;
    plot(R0(i,[1:nc2+2]),Z0(i,[1:nc2+2]),'-k','LineWidth',0.5,'Color',[0.25,0.25,0.25]);
    plot(R0(i,[nc3+2:nx+2]),Z0(i,[nc3+2:nx+2]),'-k','LineWidth',0.5,'Color',[0.25,0.25,0.25]);

%end;
%plot outer separatrix

if (nsep2 > nsep)
plot(R0(nsep2+3,[1:ntt+2]),Z0(nsep2+3,[1:ntt+2]),'-k','LineWidth',0.5);
plot(R0(nsep2+3,[ntt+3:nx+2]),Z0(nsep2+3,[ntt+3:nx+2]),'-k','LineWidth',0.5);
end;

%return;

%plot(R0(nsep+2,nc3+2:nx+2),Z0(nsep+2,nc3+2:nx+2),'-k','LineWidth',2);

set(gca,'FontName','Times','FontSize',30);
%axis([1.1 1.7  -1.25 -0.65]);
axis(Plot2DSize);
axis equal;

%clabel(C,h);
title(Gtitle,'FontSize',30,'FontName','Times','interpreter','latex');
grid on;
grid minor;
%colorbar('FontName','Times','FontSize',24);

Figname_pl=[PATH_PREFIX, Figname, '.eps'];

print('-depsc2','-r600',[PATH_PREFIX,Figname,'.eps']);
iout=0;


