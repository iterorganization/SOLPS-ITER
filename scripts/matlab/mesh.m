%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% MESH CONFIGURATION AND CUTS %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================


% ny - number of cells in radial direction
% nx - number of cells in poloidal direction
% 
% nc1 - number of first cell after first cut
% nc2 - number of last cell before second cut
% nc3 - number of first cell after first cut
% nc4 - number of last cell before second cut
           
           % For SND topology there is only one cut on physical mesh which
           % corresponds to two cuts on computational mesh. For this case
           % it is recommended to set nc3 = nc2 + 1, since
           % in the core poloidal integrals there are sums from nc1 to nc2 and
           % from nc3 to nc3, and the same rule exists for poloidal plots
           

% ntt - number of cell which corresponds to inner top target for Double
          % Null topology and for tokamak top for Single Null topology. It
          % is recommended for Single Null topology to set nc2 = ntt and nc3 = ntt + 1

           
% nsep - position of separatrix (inner separatrix for Double Null topology)
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


switch Mesh
    case 'upgrade_48x18'
        nx = 48;
        ny = 18;
        nc1 = 12;   
        nc2 = 22;   
        nc3 = 23;   
        nc4 = 35; 
        ntt = 22;
        nsep = 8;   
        nsep2 = 8; 
        nin = 19;
        nout = 28;
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
        nin = 33;
        nout = 51;
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
        nin = 35;
        nout = 55;        
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
    otherwise 
        disp('Mesh is not recognized. Stop.');
end;

ntop = nc2;
nbot = nc4;
