%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT MESH
%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

Rc=0.25*(R0+R1+R2+R3);
Zc=0.25*(Z0+Z1+Z2+Z3);


% scrsz = get(0,'ScreenSize');
% figure('Position',[1 scrsz(2) scrsz(3) scrsz(4)])

figure('Position',[1 900 1200 900])

hold all;

%plot mesh
for i=nsep+3:ny+2
    plot(R0(i,[1:nc2+2]),Z0(i,[1:nc2+2]),'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
    plot(R0(i,[nc3+2:nx+2]),Z0(i,[nc3+2:nx+2]),'-k','LineWidth',0.3,'Color',[0.8,0.8,0.8]);
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
 

% plot inner separatrix
i=nsep+3;
    plot(R0(i,[1:nc2+2 nc3+2:nx+2]),Z0(i,[1:nc2+2 nc3+2:nx+2]),'-k','LineWidth',2,'Color',[1,0.25,0.25]); 
    
%plot outer separatrix

if (nsep2 > nsep)
    plot(R0(nsep2+3,[1:ntt+2]),Z0(nsep2+3,[1:ntt+2]),'-k','LineWidth',2,'Color',[0.25,0.25,1]);
    plot(R0(nsep2+3,[ntt+3:nx+2]),Z0(nsep2+3,[ntt+3:nx+2]),'-k','LineWidth',2,'Color',[0.25,0.25,1]);
end;

axis equal;
set(gca,'FontName','Times','FontSize',30);

xlabel('R, m','FontSize',36,'FontName','Times');
ylabel('Z, m','FontSize',36,'FontName','Times');
