%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% MESH CONFIGURATION AND CUTS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%====================================================
% This script may be called from Analysis_B2.m script
% and from Compare_B2.m script
%====================================================


function [nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,nin,nout,ntop,nbot,N_apex,N_tria] = ...
    set_mesh(Mesh);


% ny - number of cells in radial direction
% nx - number of cells in poloidal direction
% 
% nc1 - number of first cell after first cut   = leftcut
% nc2 - number of last cell before the additional cut for DN topology
% nc3 - number of first cell after the additional cut for DN topology
% nc4 - number of last cell before second cut  = rightcut - 1
           
           % For SND topology there is only one cut on physical mesh which
           % corresponds to two cuts on computational mesh. For this case
           % it is recommended to set nc3 = nc2 + 1, since
           % in the core poloidal integrals there are sums from nc1 to nc2 and
           % from nc3 to nc3, and the same rule exists for poloidal plots
           

% ntt - number of cell which corresponds to inner top target for Double
          % Null topology and for tokamak top for Single Null topology. It
          % is recommended for Single Null topology to set nc2 = ntt and nc3 = ntt + 1

           
% nsep - position of separatrix (inner separatrix for Double Null topology)
%      = topcut - 1
% nsep2 -position of outer separatrix for Double Null topology. For Single
          % Null topology it is necessary to set nsep2 = nsep


% ntop - poloidal position of upper X-point
% nbot - poloidal position of lower X-point
          % They both are set automaticaly as 
          % ntop = nc2;
          % nbot = nc4;
          % assuming that nc1 and nc2 are set correctly

% nin - poloidal position of inner midplane
% nout - poloidal position of outer midplane

% N_apex - numeber of apexes in Eirene triangular mesh
% N_tria - number of triangles in Eirene triangular mesh


switch Mesh
    case 'ITER_90x36_D_Ne'
        nx = 90;
        ny = 36;
        nc1 = 20;   
        nc2 = 42;   
        nc3 = 43;   
        nc4 = 69; 
        ntt = 42;
        nsep = 11;   
        nsep2 = 11; 
        nin = 31;
        nout = 55;
    case 'ITER_2410_90x36_D_He_Ne'
        nx = 90;
        ny = 36;
        nc1 = 20;   
        nc2 = 42;   
        nc3 = 43;   
        nc4 = 69; 
        ntt = 42;
        nsep = 11;   
        nsep2 = 11; 
        nin = 31;
        nout = 55;
        N_apex = 4276;
        N_tria = 8007;
   case 'upgrade_96x36'
        nx = 96;
        ny = 36;
        nc1 = 24;   
        nc2 = 45;   
        nc3 = 46;   
        nc4 = 71; 
        ntt = 45;
        nsep = 17;   
        nsep2 = 17; 
        nin = 39;
        nout = 54;
   case 'upgrade_96x36_my_mesh_30.12.2016'
        nx = 96;
        ny = 36;
        nc1 = 24;   
        nc2 = 45;   
        nc3 = 46;   
        nc4 = 71; 
        ntt = 45;
        nsep = 17;   
        nsep2 = 17; 
        nin = 38;
        nout = 55;
        N_apex = 5517;
        N_tria = 10264;
    case 'upgrade_96x36_SOLPSITER_D_N'
        nx = 96;
        ny = 36;
        nc1 = 24;   
        nc2 = 45;   
        nc3 = 46;   
        nc4 = 63; 
        ntt = 45;
        nsep = 13;   
        nsep2 = 13; 
        nin = 34;
        nout = 51;
        N_apex = 4772;
        N_tria = 8874;
    case 'globus_82x24'
        nx = 82;
        ny = 24;
        nc1 = 12;
        nc2 = 27;
        nc3 = 54;
        nc4 = 69;
        ntt = 40;
        nsep = 9;   
        nsep2 = 13; 
        nin = 19;
        nout = 61;
     case 'globus_82x26'
        nx = 82;
        ny = 26;
        nc1 = 12;
        nc2 = 27;
        nc3 = 54;
        nc4 = 69;
        ntt = 40;
        nsep = 9;   
        nsep2 = 15; 
        nin = 20;
        nout = 61;       
        N_apex = 1;
        N_tria = 1;
    case 'globus_76x22'
        nx = 76;
        ny = 22;
        nc1 = 11;
        nc2 = 25;
        nc3 = 50;
        nc4 = 64;
        ntt = 37;
        nsep = 9;   
        nsep2 = 11; 
        nin = 19;
        nout = 57;
     case 'globus_76x24'
        nx = 76;
        ny = 24;
        nc1 = 11;
        nc2 = 25;
        nc3 = 50;
        nc4 = 64;
        ntt = 37;
        nsep = 9;   
        nsep2 = 13; 
        nin = 19;
        nout = 56;
        N_apex = 1;
        N_tria = 1;     
    case 'cmod_160x60'
        nx = 160;
        ny = 60;
        nc1 = 40;   
        nc2 = 75;   
        nc3 = 76;   
        nc4 = 119; 
        ntt = 75;
        nsep = 19;   
        nsep2 = 19; 
        nin = 64;
        nout = 92;
     case 'globus_146x40'
        nx = 146;
        ny = 40;
        nc1 = 24;
        nc2 = 47;
        nc3 = 98;
        nc4 = 121;
        ntt = 72;
        nsep = 15;   
        nsep2 = 23; 
        nin = 37;
        nout = 108;
    otherwise 
        disp('Mesh is not recognized. Stop.');
end;

ntop = nc2;
nbot = nc4;
