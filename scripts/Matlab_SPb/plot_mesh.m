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
axes('Box','on');
hold all;




% plot EIRENE's triangular mesh
if EIRENE_flag
        for i_tria = 1:N_tria
            plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))],...
                 [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],...
             '-','LineWidth',0.7,'Color',[0.9,0.4,0.1]);
% % %             if i_Neighb_tria_side1(i_tria) == 0
% % %                 plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria))],[Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria))],'-','LineWidth',0.1,'Color',[0.2,0.2,0.2]);
% % %             end;
% % %              if i_Neighb_tria_side2(i_tria) == 0
% % %                 plot([R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria))],[Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria))],'-','LineWidth',0.1,'Color',[0.2,0.2,0.2]);
% % %             end;
% % %             if i_Neighb_tria_side3(i_tria) == 0
% % %                 plot([R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))],[Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],'-','LineWidth',0.1,'Color',[0.2,0.2,0.2]);
% % %             end;
       end;
end;

mesh_color = [0.6,0.6,1.0];

%plot mesh
for i=nsep+3:ny+2
    plot(R0(i,[1:nc2+2]),Z0(i,[1:nc2+2]),'-','LineWidth',0.7,'Color',mesh_color);
    plot(R0(i,[nc3+2:nx+2]),Z0(i,[nc3+2:nx+2]),'-','LineWidth',0.7,'Color',mesh_color);
end;
for i=1:ny+2
    plot([R0(i,[1:nc1+1]) R1(i,nc1+1)],[Z0(i,[1:nc1+1]) Z1(i,nc1+1)],'-','LineWidth',0.7,'Color',mesh_color);
    plot([R0(i,[nc1+2:nc2+2]) R1(i,nc2+2)],[Z0(i,[nc1+2:nc2+2]) Z1(i,nc2+2)],'-','LineWidth',0.7,'Color',mesh_color);
    plot([R0(i,[nc2+3:ntt+2]) R1(i,ntt+2)],[Z0(i,[nc2+3:ntt+2]) Z1(i,ntt+2)],'-','LineWidth',0.7,'Color',mesh_color);
    plot([R0(i,[ntt+3:nc3+1]) R1(i,nc3+1)],[Z0(i,[ntt+3:nc3+1]) Z1(i,nc3+1)],'-','LineWidth',0.7,'Color',mesh_color);
    plot([R0(i,[nc3+2:nc4+2]) R1(i,nc4+2)],[Z0(i,[nc3+2:nc4+2]) Z1(i,nc4+2)],'-','LineWidth',0.7,'Color',mesh_color);
    plot([R0(i,[nc4+3:nx+2]) R1(i,nx+2)],[Z0(i,[nc4+3:nx+2]) Z1(i,nx+2)],'-','LineWidth',0.7,'Color',mesh_color);
end;
 for j=1:nx+2
     plot(R0([1:ny+2],j),Z0([1:ny+2],j),'-','LineWidth',0.7,'Color',[0.8,0.8,0.8]);
 end;
 

% plot inner separatrix
i=nsep+3;
    plot(R0(i,[1:nc2+2 nc3+2:nx+2]),Z0(i,[1:nc2+2 nc3+2:nx+2]),'-','LineWidth',2,'Color',[1,0.25,0.25]); 
    
% plot outer separatrix

if (nsep2 > nsep)
    plot(R0(nsep2+3,[1:ntt+2]),Z0(nsep2+3,[1:ntt+2]),'-','LineWidth',2,'Color',[0.25,0.25,1]);
    plot(R0(nsep2+3,[ntt+3:nx+2]),Z0(nsep2+3,[ntt+3:nx+2]),'-k','LineWidth',2,'Color',[0.25,0.25,1]);
end;

% plot cuts
plot(R0([1:nsep+3],nc1+2),Z0([1:nsep+3],nc1+2),'--','LineWidth',2,'Color',[0.15,0.05,0.5]);
plot(R0([1:nsep+3],nc4+3),Z0([1:nsep+3],nc4+3),'--','LineWidth',2,'Color',[0.15,0.05,0.5]);
if nc2+1 ~= nc3 % case with two X-points
    plot(R0([1:nsep2+3],nc3+2),Z0([1:nsep2+3],nc3+2),'--','LineWidth',2,'Color',[0.15,0.05,0.5]);
    plot(R0([1:nsep2+3],nc2+3),Z0([1:nsep2+3],nc2+3),'--','LineWidth',2,'Color',[0.15,0.05,0.5]);
end;

% plot inner and outer midplanes
plot([R0([1:ny+2],nin+2)' R2(ny+2,nin+2) R1([ny+2:-1:1],nin+2)' R0(1,nin+2)],[Z0([1:ny+2],nin+2)' Z2(ny+2,nin+2) Z1(ny+2:-1:1,nin+2)' Z0(1,nin+2)],'--','LineWidth',2,'Color',[0.2,0.6,0.2]);
plot([R0([1:ny+2],nout+2)' R2(ny+2,nout+2) R1([ny+2:-1:1],nout+2)' R0(1,nout+2)],[Z0([1:ny+2],nout+2)' Z2(ny+2,nout+2) Z1(ny+2:-1:1,nout+2)' Z0(1,nout+2)],'--','LineWidth',2,'Color',[0.2,0.6,0.2]);

% plot EIRENE's triangular mesh
if EIRENE_flag
        for i_tria = 1:N_tria
%             plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))],...
%                  [Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],...
%              '-','LineWidth',0.1,'Color',[0.8,0.6,0.1]);
            if i_Neighb_tria_side1(i_tria) == 0
                plot([R_apex(i_apex1(i_tria)) R_apex(i_apex2(i_tria))],[Z_apex(i_apex1(i_tria)) Z_apex(i_apex2(i_tria))],'-','LineWidth',1.1,'Color',[0.2,0.2,0.2]);
            end;
             if i_Neighb_tria_side2(i_tria) == 0
                plot([R_apex(i_apex2(i_tria)) R_apex(i_apex3(i_tria))],[Z_apex(i_apex2(i_tria)) Z_apex(i_apex3(i_tria))],'-','LineWidth',1.1,'Color',[0.2,0.2,0.2]);
            end;
            if i_Neighb_tria_side3(i_tria) == 0
                plot([R_apex(i_apex3(i_tria)) R_apex(i_apex1(i_tria))],[Z_apex(i_apex3(i_tria)) Z_apex(i_apex1(i_tria))],'-','LineWidth',1.1,'Color',[0.2,0.2,0.2]);
            end;
       end;
end;
 %for j=1:nx+2
      plot([R0(2,[nc1+2:nc2+2,nc3+2:nc4+2]) R1(2,nc4+2)],[Z0(2,[nc1+2:nc2+2,nc3+2:nc4+2]) Z1(2,nc4+2)],'-','LineWidth',1.1,'Color',mesh_color);
  %end;

% Mark pump and puff surfaces for the shot AUG28903
%plot([2.14991E+00 1.99999E+00],[-8.69991E-01 -8.70042E-01],'-b','LineWidth',3.1);
%plot([2.23301E+00 2.23298E+00],[-1.11998E-00 -8.84018E-01],'-b','LineWidth',3.1);
% 2.23301E+02-1.11998E+02-1.00000E+20 2.23298E+02-8.84018E+01 1.00000E+20
%plot([1.38816E+00 1.409998E+00],[-1.06242E-00 -1.06242E-00],'-r','LineWidth',5.1);

set(gca,'FontName','Times','FontSize',30);
axis equal;

xlabel('R, m','FontSize',36,'FontName','Times');
ylabel('Z, m','FontSize',36,'FontName','Times');

set(gcf,'PaperPositionMode','auto');
print('-depsc2','-r600',[PATH_PREFIX,'mesh.eps']);
%print('-dpng','-r600',[PATH_PREFIX,'mesh.png']);

% plot magnetic field in two separated figures

% set levels for ITER
Level_Bpol_ITER=[-1.8 -1.6 -1.4 -1.2 -1.0 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8];
Level_Btor_ITER=[-8.5 -8.0 -7.5 -6.5 -6.0 -5.5 -5 -4.5 -4.0 -3.5 -3.0 -2.5 -2.0 -1.5 -1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0 8.5];


%plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,Bx,'$B_{pol},  \rm T$','Bpol',Level_Bpol_ITER,label2D,Plot2DMargins_whole);
%plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,Bz,'$B_{tor},  \rm T$','Btor',Level_Btor_ITER,label2D,Plot2DMargins_whole);

