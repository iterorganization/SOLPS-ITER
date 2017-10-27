% Single Null multifluid case (like ASDEX 17151)
clear all;

% Number of variants to compare
Nresults=11;


SOLPS_ITER = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];

Mesh = cell(Nresults);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  PLASMA COMPOSITION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Plasma_Composition = 'D_C_He';
    Plasma_Composition = 'D_C';
    Plasma_Composition = 'D_N';
%    Plasma_Composition = 'D';
%    Plasma_Composition = 'D_He_Ne';

plasma_composition


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  SET MESH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nx=zeros(Nresults,1);
ny=zeros(Nresults,1);
nc1=zeros(Nresults,1);
nc2=zeros(Nresults,1);
nc3=zeros(Nresults,1);
nc4=zeros(Nresults,1);
ntt=zeros(Nresults,1);
nsep=zeros(Nresults,1);
nsep2=zeros(Nresults,1);
nin=zeros(Nresults,1);
nout=zeros(Nresults,1);
ntop=zeros(Nresults,1);
nbot=zeros(Nresults,1);
N_apex=zeros(Nresults,1);
N_tria=zeros(Nresults,1);

%Mesh{1} = 'globus_76x24';
%Mesh{2} = 'globus_82x26';

for i=1:Nresults
   Mesh{i} = 'upgrade_96x36_SOLPSITER_D_N';
%   Mesh{i} = 'upgrade_96x36_my_mesh_30.12.2016'; 
%   Mesh{i} = 'ITER_2410_90x36_D_He_Ne';
   [nx(i),ny(i),nc1(i),nc2(i),nc3(i),nc4(i),ntt(i),nsep(i),nsep2(i),nin(i),nout(i),ntop(i),nbot(i),N_apex(i),N_tria(i)] = set_mesh(Mesh{i});
end;

 
npl = [-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1  -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
npl_flux = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%  PHYSICAL CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

qe=1.602e-19;
mp=1.67e-27;
me=9.11e-31;
epsilon_0=8.8542e-12;

Lambda_Coulomb = 12;

%%%%%%% END OF PHYSICAL CONSTANTS DECLARATION

% Main ion mass number
Amain = 2.0;

%%%%%%% END OF PHYSICAL CONSTANTS DECLARATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EIRENE_flag=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% CHOOSE WHETHER TO READ EXPERIMENTAL DATA
%%%%%% FOR EACH CASE A SEPARATE ROUTINE IS REQUIRED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exp_data_flag=1;
global exp_data_flag;

%exp_data_flag=0; No experimetal data are available or theya re not desired
%                 to be plotted
%exp_data_flag=1; plot the experimental data

EXP_DATA_PREFIX='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903/130603/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




PATH_PREFIX=cell(Nresults);
label=cell(Nresults);
Parameter=cell(Nresults);


% % % PATH_PREFIX{1}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_01.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{2}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff5e19_watch_01.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{3}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e18_watch_01.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{4}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_lowPrec_watch_01.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{5}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_highPrec_watch_01.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{6}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_02.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{7}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff5e19_watch_02.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{8}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e18_watch_02.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{9}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_03.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{10}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff5e19_watch_03.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{11}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e18_watch_03.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{12}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e19_watch_03.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{13}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_highPrec_watch_03.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{14}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{15}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff5e19_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{16}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e18_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{17}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e19_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{18}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_highPrec_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{19}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_D2.25_watch_06.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{20}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{21}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff5e19_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{22}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e18_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{23}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff8e19_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{24}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_highPrec_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{25}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.81_D2.25_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{26}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.87_Npuff2e19_watch_08.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{27}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.87_Npuff2e19_ThF_watch_08.06.2016/b2mn.exe.dir/';
% % % %PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_lowNinit_lowNflux/watch_20.05.2016/';


% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_27.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff5e19_drift1.0_BCCON27_ThF_watch_25.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff8e19_drift1.0_BCCON27_ThF_watch_27.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff12e19_drift1.0_BCCON27_ThF_watch_27.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/alb0.87_Dpuff2e22_Npuff12e19_drift1.0_BCCON27_ThF_watch_27.06.2016/b2mn.exe.dir/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/June_results/Npuff_12e19_watch_26.08.2016/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/test_Release_mpi_1node/watch_15.08.2016/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_27.08.2016/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_27.08.2016/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_27.08.2016/';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_27.08.2016/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_29.08.2016/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_2e19/watch_30.08.2016/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_5e19/watch_30.08.2016/';
% % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_8e19/watch_30.08.2016/';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_2e19/watch_30.08.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_5e19/watch_30.08.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_8e19/watch_30.08.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_2e19/watch_01.09.2016/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_5e19/watch_01.09.2016/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_8e19/watch_01.09.2016/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/barrier_rotation_alpha/Npuff_12e19/watch_01.09.2016/';
% % % 
% % % label{1}='Npuff 2e19 rot alpha 30.08';
% % % label{2}='Npuff 5e19 rot alpha 30.08';
% % % label{3}='Npuff 8e19 rot alpha 30.08';
% % % label{4}='Npuff 2e19 rot alpha 01.09';
% % % label{5}='Npuff 5e19 rot alpha 01.09';
% % % label{6}='Npuff 8e19 rot alpha 01.09';
% % % label{7}='Npuff 12e19 rot alpha 01.09';





% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e18/watch_07.09.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e18/watch_09.09.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e18/watch_12.09.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_02.09.2016/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_05.09.2016/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_07.09.2016/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_09.09.2016/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e18/watch_12.09.2016/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_02.09.2016/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_05.09.2016/';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_07.09.2016/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_09.09.2016/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e19/watch_12.09.2016/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_02.09.2016/';
% % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_05.09.2016/';
% % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_07.09.2016/';
% % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_09.09.2016/';
% % % PATH_PREFIX{18}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e19/watch_12.09.2016/';
% % % 
% % % label{1}='Npuff 2e18 07.09';
% % % label{2}='Npuff 2e18 09.09';
% % % label{3}='Npuff 2e18 12.09';
% % % label{4}='Npuff 8e18 02.09';
% % % label{5}='Npuff 8e18 05.09';
% % % label{6}='Npuff 8e18 07.09';
% % % label{7}='Npuff 8e18 09.09';
% % % label{8}='Npuff 8e18 12.09';
% % % label{9}='Npuff 2e19 02.09';
% % % label{10}='Npuff 2e19 05.09';
% % % label{11}='Npuff 2e19 07.09';
% % % label{12}='Npuff 2e19 09.09';
% % % label{13}='Npuff 2e19 12.09';
% % % label{14}='Npuff 5e19 02.09';
% % % label{15}='Npuff 5e19 05.09';
% % % label{16}='Npuff 5e19 07.09';
% % % label{17}='Npuff 5e19 09.09';
% % % label{18}='Npuff 5e19 12.09';


% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e18/watch_13.10.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_11.10.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e19/watch_12.10.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e19/watch_11.10.2016/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e19/watch_11.10.2016/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e19/watch_11.10.2016/';
% % % %PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_16e19/watch_10.10.2016/';
% % % %PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20/watch_10.10.2016/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20_visc_red/watch_13.10.2016/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20/watch_13.10.2016/';
% % % %PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt5e-8/watch_06.10.2016/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e20/watch_13.10.2016/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e20_visc/watch_13.10.2016/';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e20/watch_13.10.2016/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e20_visc/watch_13.10.2016/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_18e20/watch_13.10.2016/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_18e20_visc/watch_13.10.2016/';
% % % %PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_25e20_dt1e-8/watch_05.10.2016/';
% % % 
% % % label{1}='Npuff 2e18';
% % % label{2}='Npuff 8e18 11';
% % % label{3}='Npuff 2e19 12';
% % % label{4}='Npuff 5e19 11';
% % % label{5}='Npuff 8e19 11';
% % % label{6}='Npuff 12e19 11';
% % % %label{7}='Npuff 16e19';
% % % %label{8}='Npuff 2e20';
% % % label{7}='Npuff 2e20 visc red';
% % % label{8}='Npuff 5e20';
% % % %label{11}='Npuff 5e20 visc 5e-8';
% % % label{9}='Npuff 8e20';
% % % label{10}='Npuff 8e20 visc';
% % % label{11}='Npuff 12e20';
% % % label{12}='Npuff 12e20 visc';
% % % label{13}='Npuff 18e20';
% % % label{14}='Npuff 18e20 visc';
% % % %label{14}='Npuff 25e20 dt1e-8';
% % % %label{12}='Npuff 36e20';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_26.09.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_28.09.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_29.09.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_03.10.2016/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_05.10.2016/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_06.10.2016/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_10.10.2016/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_11.10.2016/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_18.10.2016/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_24.10.2016/';
% % % label{1}='Npuff 8e18 26.09';
% % % label{2}='Npuff 8e18 28.09';
% % % label{3}='Npuff 8e18 29.09';
% % % label{4}='Npuff 8e18 03.10';
% % % label{5}='Npuff 8e18 05.10';
% % % label{6}='Npuff 8e18 06.10';
% % % label{7}='Npuff 8e18 10.10';
% % % label{8}='Npuff 8e18 11.10';
% % % label{9}='Npuff 8e18 18.10';
% % % label{10}='Npuff 8e18 24.10';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_28.10.2016/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_31.10.2016/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_03.11.2016/';
% % % %PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_15.11.2016/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_16.11.2016/';
% % % %PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_21.11.2016/';
% % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_19.12.2016/';
% % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_30.12.2016/';
% % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_09.01.2017/';
% % % 
% % % label{11}='Npuff 8e18 28.10';
% % % label{12}='Npuff 8e18 31.10';
% % % label{13}='Npuff 8e18 03.11';
% % % label{14}='Npuff 8e18 16.11';
% % % label{15}='Npuff 8e18 19.12';
% % % label{16}='Npuff 8e18 30.12';
% % % label{17}='Npuff 8e18 09.01';
% % % %label{16}='Npuff 8e18 21.11';

% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_18.11.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_24.11.2016/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_07.12.2016/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_12.12.2016/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_19.12.2016/';
% % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_27.12.2016/';
% % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_28.12.2016/';
% % % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_30.12.2016/';
% % % % % 
% % % % % label{1}='Npuff 5e19 18.11';
% % % % % label{2}='Npuff 5e19 24.11';
% % % % % label{3}='Npuff 5e19 07.12';
% % % % % label{4}='Npuff 5e19 12.12';
% % % % % label{5}='Npuff 5e19 19.12';
% % % % % label{6}='Npuff 5e19 27.12';
% % % % % label{7}='Npuff 5e19 28.12';
% % % % % label{8}='Npuff 5e19 30.12';
% % % % % 
% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_30.11.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_05.12.2016/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_08.12.2016/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_12.12.2016/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_19.12.2016/';
% % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_30.12.2016/';
% % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_09.01.2017/';
% % % % % 
% % % % % label{1}='Npuff 12e19 20.11';
% % % % % label{2}='Npuff 12e19 05.11';
% % % % % label{3}='Npuff 12e19 08.12';
% % % % % label{4}='Npuff 12e19 12.12';
% % % % % label{5}='Npuff 12e19 19.12';
% % % % % label{6}='Npuff 12e19 30.12';
% % % % % label{7}='Npuff 12e19 09.01';
% % % % % 
% % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_16e19/watch_26.12.2016/';
% % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_16e19/watch_30.12.2016/';
% % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_16e19/watch_09.01.2017/';
% % 
% % label{1}='Npuff 16e19 26.12';
% % label{2}='Npuff 16e19 30.12';
% % label{3}='Npuff 16e19 09.01';


% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_19.12.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_19.12.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e19/watch_19.12.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_19.12.2016/';
% % % 
% % % label{1}='Npuff 8e18';
% % % label{2}='Npuff 5e19';
% % % label{3}='Npuff 8e19';
% % % label{4}='Npuff 12e19';


% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt4e-8/watch_18.10.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt4e-8/watch_24.10.2016/';
% % % % % label{1}='Npuff 5e20_visc 03.11';
% % % % % label{2}='Npuff 5e20_visc 15.11';
% % % % % 
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e20/watch_03.11.2016/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e20/watch_15.11.2016/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e20/watch_16.11.2016/';
% % % % % 
% % % % % label{3}='Npuff 5e20_visc 03.11';
% % % % % label{4}='Npuff 5e20_visc 15.11';
% % % % % label{5}='Npuff 5e20_visc 16.11';

% % % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e18/watch_09.01.2017/';
% % % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_2e19/watch_09.01.2017/';
% % % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_5e19/watch_09.01.2017/';
% % % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_8e19/watch_09.01.2017/';
% % % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_1e20/watch_09.01.2017/';
% % % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_12e19/watch_09.01.2017/';
% % % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_16e19/watch_09.01.2017/';
% % % % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_November/Npuff_2e20/watch_09.01.2017/';
% % % % % % 
% % % % % % label{1}='Npuff 8e18';
% % % % % % label{2}='Npuff 2e19';
% % % % % % label{3}='Npuff 5e19';
% % % % % % label{4}='Npuff 8e19';
% % % % % % label{5}='Npuff 1e20';
% % % % % % label{6}='Npuff 12e19';
% % % % % % label{7}='Npuff 16e19';
% % % % % % label{8}='Npuff 2e20';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e18/watch_28.03.2017/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e18/watch_28.03.2017/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e19/watch_28.03.2017/';
% % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e18_reduced_alfa4_2times/watch_28.03.2017/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_5e19/watch_28.03.2017/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e19/watch_28.03.2017/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_1e20/watch_28.03.2017/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_12e19/watch_28.03.2017/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_16e19/watch_28.03.2017/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e20/watch_28.03.2017/';
% %PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_25e19/watch_02.03.2017/';
% PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_28.03.2017/';
% PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_28.03.2017/';
% PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_4e20/watch_28.03.2017/';
% % % % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e18_reduced_alfa4_2times/watch_28.03.2017/';
% % % % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e19_reduced_alfa4_2times/watch_28.03.2017/';
% % % % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19_reduced_alfa4_2times/watch_28.03.2017/';
% % % % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20_reduced_alfa4_2times/watch_28.03.2017/';
% % % % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_4e20_reduced_alfa4_2times/watch_28.03.2017/';
% % % % % 
% Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_seeding_scan/scan_28.03.2017/'];
% 
% label{1}='Npuff 2e18';
% label{2}='Npuff 8e18';
% label{3}='Npuff 2e19';
% % label{4}='Npuff 8e18 red. D';
% label{4}='Npuff 5e19';
% label{5}='Npuff 8e19';
% label{6}='Npuff 1e20';
% label{7}='Npuff 12e19';
% label{8}='Npuff 16e19';
% label{9}='Npuff 2e20';
% %label{10}='Npuff 25e19 wr';
% label{10}='Npuff 3e20';
% label{11}='Npuff 35e19';
% label{12}='Npuff 4e20';
% % % % % label{13}='Npuff 8e18 red. D';
% % % % % label{14}='Npuff 8e19 red. D';
% % % % % label{15}='Npuff 3e20 red. D';
% % % % % label{16}='Npuff 35e19 red. D';
% % % % % label{17}='Npuff 4e20 red. D';
% % % % % 
% % % % % Parameter{1}=2.0e18;
% % % % % Parameter{2}=8.0e18;
% % % % % Parameter{3}=2.0e19;
% % % % % Parameter{4}=5.0e19;
% % % % % Parameter{5}=8.0e19;
% % % % % Parameter{6}=1.0e20;
% % % % % Parameter{7}=1.2e20;
% % % % % Parameter{8}=1.6e20;
% % % % % Parameter{9}=2.0e20;
% % % % % Parameter{10}=2.5e20;
% % % % % Parameter{11}=3.0e20;
% % % % % Parameter{12}=3.5e20;
% % % % % Parameter{13}=4.0e20;
% % % % % Parameter{14}=3.0e20;
% % % % % Parameter{15}=3.5e20;
% % % % % Parameter{16}=1.2e20;
% % % % % 
% % % % % 
% % % % % Parameter_label = 'Seeding rate, N atoms per second';

% % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_35e19_red_transport/watch_12.04.2017/';
% % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_35e19_red_transport/watch_20.04.2017/';
% % label{1}='12.04';
% % label{2}='20.04';
% % Figure_Store_PATH = [PATH_PREFIX{1}, '../Figures_seeding_scan/scan_20.04.2017/'];

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e17_alb0.81_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e18_alb0.81_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e18_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_8e18_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e19_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_5e19_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_8e19_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_12e19_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_16e19_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e20_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_3e20_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_5e20_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
% % % 
% % % 
% % % Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_seeding_scan/scan_20.04.2017/'];
% % % 
% % % label{1}='Npuff 2e17 a0.81';
% % % label{2}='Npuff 2e18 a0.81';
% % % label{3}='Npuff 2e18 a0.87';
% % % label{4}='Npuff 8e18 a0.87';
% % % label{5}='Npuff 2e19 a0.87';
% % % label{6}='Npuff 5e19 a0.87';
% % % label{7}='Npuff 8e19 a0.87';
% % % label{8}='Npuff 12e19 a0.87';
% % % label{9}='Npuff 16e19 a0.87';
% % % label{10}='Npuff 2e20 a0.87';
% % % label{11}='Npuff 3e20 a0.87';
% % % label{12}='Npuff 5e20 a0.87';

 PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Deuterium/alb0.81_watch_20.04.2017/b2mn.exe.dir/';
 PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Deuterium/alb0.87_watch_20.04.2017/b2mn.exe.dir/';
 Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_seeding_scan/scan_20.04.2017/'];
 label{1}='a0.81';
 label{2}='a0.87';
 
 

 PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e20_red_transport_watch_10.04.2017/b2mn.exe.dir/';
 PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e20_alb0.87_red_transport_watch_20.04.2017/b2mn.exe.dir/';
 Figure_Store_PATH = [PATH_PREFIX{1}, '../evolution_20.04.2017/'];
 label{1}='10.04';
 label{2}='20.04';
 
 
 PATH_PREFIX{1}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport/watch_30.05.2017/';
 PATH_PREFIX{2}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e18_red_transport/watch_30.05.2017/';
 PATH_PREFIX{3}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e19_red_transport/watch_30.05.2017/';
 PATH_PREFIX{4}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_5e19_red_transport/watch_30.05.2017/';
 PATH_PREFIX{5}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e19_red_transport/watch_30.05.2017/';
 PATH_PREFIX{6}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_12e19_red_transport/watch_30.05.2017/';
 PATH_PREFIX{7}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_16e19_red_transport/watch_30.05.2017/';
 PATH_PREFIX{8}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e20_red_transport/watch_30.05.2017/';
 PATH_PREFIX{9}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_5e20_red_transport/watch_30.05.2017/';
 PATH_PREFIX{10}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e20_red_transport/watch_30.05.2017/';
 PATH_PREFIX{11}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e21_red_transport/watch_30.05.2017/';
% PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_36e20_red_transport/watch_16.05.2017/';
Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_seeding_scan/scan_24.05.2017/'];
 label{1}='2e18';
 label{2}='8e18'; 
 label{3}='2e19';
 label{4}='5e19';
 label{5}='8e19';
 label{6}='12e19';
 label{7}='16e19'; 
 label{8}='2e20';
 label{9}='5e20'; 
 label{10}='8e20'; 
 label{11}='2e21'; 
% label{10}='36e20 16.05';


 PATH_PREFIX{1}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport/watch_06.06.2017/';
 PATH_PREFIX{2}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport_alb0.90/watch_06.06.2017/';
 PATH_PREFIX{3}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport_noalfa4/watch_06.06.2017/';
 PATH_PREFIX{4}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18_red_transport_speedUP/watch_06.06.2017/';
 PATH_PREFIX{5}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e19_red_transport/watch_06.06.2017/';
 PATH_PREFIX{6}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e19_red_transport_speedUP/watch_06.06.2017/';
 PATH_PREFIX{7}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e20_red_transport/watch_06.06.2017/';
 PATH_PREFIX{8}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e20_red_transport_speedUP/watch_06.06.2017/';
 PATH_PREFIX{9}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e20_red_transport/watch_06.06.2017/';
 PATH_PREFIX{10}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e20_red_transport_noalfa4/watch_06.06.2017/';
 PATH_PREFIX{11}='/home_ilya_copy/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e20_red_transport_noalfa4_speedUP/watch_06.06.2017/';
% PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_36e20_red_transport/watch_16.05.2017/';
Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_seeding_scan/scan_06.06.2017/'];
 label{1}='2e18';
 label{2}='2e18 alb0.90'; 
 label{3}='2e18 NO alfa4';
 label{4}='2e18 speedUP';
 label{5}='8e19';
 label{6}='8e19 speedUP';
 label{7}='2e20'; 
 label{8}='2e20 speedUP';
 label{9}='8e20'; 
 label{10}='8e20 NO alfa4'; 
 label{11}='8e20  NO alfa4 speedUP'; 



% % 
% % 
% % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e17_alb0.81_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e18_alb0.81_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e18_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_8e18_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e19_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_5e19_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_8e19_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_12e19_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_16e19_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e20_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_3e20_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_5e20_alb0.87_red_transport_watch_05.05.2017/b2mn.exe.dir/';
% % % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Neon/Ne_puff_2e18_alb0.81_red_transport_watch_17.04.2017/b2mn.exe.dir/';
% % % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Neon/Ne_puff_2e18_alb0.87_red_transport_watch_17.04.2017/b2mn.exe.dir/';
% % % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Neon/Ne_puff_2e17_alb0.81_red_transport_watch_17.04.2017/b2mn.exe.dir/';
% % % % % % 
% % % % label{1}='D+N 2e17 alb0.81';
% % % % label{2}='D+N 2e18 alb0.81';
% % % % label{3}='D+N 2e18 alb0.87';
% % % % label{4}='D+N 8e18 alb0.87';
% % % % label{5}='D+N 2e19 alb0.87';
% % % % label{6}='D+N 5e19 alb0.87';
% % % % label{7}='D+N 8e19 alb0.87';
% % % % label{8}='D+N 12e19 alb0.87';
% % % % label{9}='D+N 16e19 alb0.87';
% % % % label{10}='D+N 2e20 alb0.87';
% % % % label{11}='D+N 3e20 alb0.87';
% % % % label{12}='D+N 5e20 alb0.87';
% % % % % % label{1}='D+Ne 2e18 alb0.81';
% % % % % % label{2}='D+Ne 2e18 alb0.87';
% % % % % % label{3}='D+Ne 2e17 alb0.81';
% % % % Figure_Store_PATH = [PATH_PREFIX{1}, '../Figures_seeding_scan/scan_05.05.2017/'];

% % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e18/watch_28.03.2017/';
% % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_8e19/watch_28.03.2017/';
% % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e18_red_alfa4_2times/watch_14.04.2017/';
% % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_8e19_red_alfa4_2times/watch_14.04.2017/';
% % Figure_Store_PATH = [PATH_PREFIX{1}, '../../Figures_transport_scan/scan_14.04.2017/'];
% % 
% % label{1}='8e18 high';
% % label{2}='8e19 high';
% % label{3}='8e18 low';
% % label{4}='8e19 low';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_20.02.2017/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_02.03.2017/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_10.03.2017/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_14.03.2017/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_3e20/watch_21.03.2017/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_2e20/watch_07.02.2017/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_2e20/watch_14.02.2017/';
% % % %PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_5e19/watch_14.02.2017/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e20/watch_20.02.2017/';
% label{1}='20.02';
% label{2}='02.03';
% label{3}='10.03';
% label{4}='14.03';
% label{5}='21.03';
% % % label{5}='03.02';
% % % label{6}='07.02';
% % % label{7}='14.02';
% % % %label{8}='14.02 2';
%PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_20.02.2017/';
% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_02.03.2017/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_10.03.2017/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_14.03.2017/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_35e19/watch_21.03.2017/';
% % % % % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_2e20/watch_07.02.2017/';
% % % % % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_2e20/watch_14.02.2017/';
% % % % % % % % %PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_5e19/watch_14.02.2017/';
% % % % % % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e20/watch_20.02.2017/';
% % % % % %label{1}='20.02';
% % % % % label{1}='02.03';
% % % % % label{2}='10.03';
% % % % % label{3}='14.03';
% % % % % label{4}='21.03';
% % % label{8}='20.02 2';
%Figure_Store_PATH = [PATH_PREFIX{1}, '../scan_21.03.2017/'];


% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Neon/Ne_puff_2e18/Ne_puff_2e18_watch_22.03.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Mar2017/Nitrogen/Npuff_2e18/Npuff_2e18_watch_22.03.2017/b2mn.exe.dir/';
% % % label{2}='Neon';
% % % label{1}='Nitrogen';
% % % Figure_Store_PATH = [PATH_PREFIX{1}, '../../Compare_22.02.2017/'];

% % % % % 
% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_11.01.2017/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_20.01.2017/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_25.01.2017/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_30.01.2017/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_03.02.2017/';
% % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_07.02.2017/';
% % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_12e19/watch_14.02.2017/';
% % % % % %PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e20/watch_14.02.2017/';
% % % % % %PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e18_exp_Diffx/watch_14.02.2017/';
% % % % % label{1}='11.01';
% % % % % label{2}='20.01';
% % % % % label{3}='25.01';
% % % % % label{4}='30.01';
% % % % % label{5}='03.02';
% % % % % label{6}='07.02';
% % % % % label{7}='14.02';
% % % % % %label{8}='14.02 2';
% % % % % %label{9}='14.02 2 D_x';
% % % % % Figure_Store_PATH = [PATH_PREFIX{1}, '../scan_14.02.2017/'];



% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_45e19/watch_03.02.2017/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_45e19/watch_07.02.2017/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_45e19/watch_14.02.2017/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_5e20/watch_14.02.2017/';
% % % %PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Feb2017/Npuff_2e18_exp_Diffx/watch_14.02.2017/';
% % % 
% % % label{1}='03.02';
% % % label{2}='07.02';
% % % label{3}='14.02';
% % % label{4}='5e20 2';
% % % %label{9}='14.02 2 D_x';
% % % Figure_Store_PATH = [PATH_PREFIX{1}, '../scan_14.02.2017/'];


% PATH_PREFIX{1}='/tokp/work/iys/B2runs/tests_Iter_D+Ne/output_our/';
% PATH_PREFIX{2}='/tokp/work/iys/B2runs/tests_Iter_D+Ne/output_Kuk/';

%PATH_PREFIX{1}='/tokp/scratch/iys/tmp_SOLPS_ITER/solps-iter/runs/AUG16151/from_srv_pureD/Copy_of_1_5.2_v88_no_drifts_SPb_bc_2_dt=1e-3_50000/run/output/';
%PATH_PREFIX{2}='/tokp/scratch/iys/tmp_SOLPS_ITER/solps-iter/runs/AUG16151/pure_D/run000/b2mn.exe.dir/';

% label{1}='our';
% label{2}='Kuk';
% Figure_Store_PATH = [PATH_PREFIX{1}, '../../Compare_08.02.2017/'];


% FOR IAEA Poster and Presentation
% % % % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e18/watch_10.10.2016/';
% % % % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e18/watch_10.10.2016/';
% % % % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e19/watch_10.10.2016/';
% % % % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e19/watch_06.10.2016/';
% % % % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_8e19/watch_06.10.2016/';
% % % % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_12e19/watch_06.10.2016/';
% % % % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_5e20_visc_dt2e-8/watch_10.10.2016/';
% % % % % % % 
% % % % % % % label{1}='Npuff 2e18';
% % % % % % % label{2}='Npuff 8e18';
% % % % % % % label{3}='Npuff 2e19';
% % % % % % % label{4}='Npuff 5e19';
% % % % % % % label{5}='Npuff 8e19';
% % % % % % % label{6}='Npuff 12e19';
% % % % % % % label{7}='Npuff 5e20';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20/watch_06.10.2016/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20/watch_10.10.2016/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20_visc_red/watch_06.10.2016/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_September/Npuff_2e20_visc_red/watch_10.10.2016/';
% % % label{1}='Npuff 2e20 06';
% % % label{2}='Npuff 2e20 10';
% % % label{3}='Npuff 2e20 visc 06';
% % % label{4}='Npuff 2e20 visc 10';
% FOR IAEA Poster and Presentation


% % % 
% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_01.09.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_05.09.2016/';
% % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_07.09.2016/';
% % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_09.09.2016/';
% % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_12.09.2016/';
% % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_14.09.2016/';
% % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_02.09.2016/';
% % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_05.09.2016/';
% % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_07.09.2016/';
% % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_09.09.2016/';
% % % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_12.09.2016/';
% % % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_14.09.2016/';
% % % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_02.09.2016/';
% % % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_05.09.2016/';
% % % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_07.09.2016/';
% % % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_09.09.2016/';
% % % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_12.09.2016/';
% % % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_14.09.2016/';
% % % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19_incr_core_Nflux/watch_14.09.2016/';
% % % % PATH_PREFIX{18}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_02.09.2016/';
% % % % PATH_PREFIX{19}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_05.09.2016/';
% % % % PATH_PREFIX{20}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_07.09.2016/';
% % % % PATH_PREFIX{21}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_09.09.2016/';
% % % % PATH_PREFIX{22}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_14.09.2016/';
% % % % PATH_PREFIX{23}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_07.09.2016/';
% % % % PATH_PREFIX{24}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_09.09.2016/';
% % % % PATH_PREFIX{25}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_12.09.2016/';
% % % % PATH_PREFIX{26}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_14.09.2016/';
% % % % PATH_PREFIX{27}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_09.09.2016/';
% % % % PATH_PREFIX{28}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_14.09.2016/';
% % % % 
% % % % % label{1}='Npuff 8e19 01.09';
% % % % % label{2}='Npuff 8e19 05.09';
% % % % label{1}='Npuff 8e19 07.09 sb';
% % % % label{2}='Npuff 8e19 09.09 sb';
% % % % label{3}='Npuff 8e19 12.09 sb';
% % % % label{4}='Npuff 8e19 14.09 sb';
% % % % label{5}='Npuff 12e19 02.09 sb';
% % % % label{6}='Npuff 12e19 05.09 sb';
% % % % label{7}='Npuff 12e19 07.09 sb';
% % % % label{8}='Npuff 12e19 09.09 sb';
% % % % label{9}='Npuff 12e19 12.09 sb';
% % % % label{10}='Npuff 12e19 14.09 sb';
% % % % label{11}='Npuff 16e19 02.09 sb';
% % % % label{12}='Npuff 16e19 05.09 sb';
% % % % label{13}='Npuff 16e19 07.09 sb';
% % % % label{14}='Npuff 16e19 09.09 sb';
% % % % label{15}='Npuff 16e19 12.09 sb';
% % % % label{16}='Npuff 16e19 14.09 sb';
% % % % label{17}='Npuff 16e19 14.09 sbNfl';
% % % % label{18}='Npuff 2e20 02.09 sb';
% % % % label{19}='Npuff 2e20 05.09 sb';
% % % % label{20}='Npuff 2e20 07.09 sb';
% % % % label{21}='Npuff 2e20 09.09 sb';
% % % % label{22}='Npuff 2e20 14.09 sb';
% % % % label{23}='Npuff 2e20 07.09 sbNfl';
% % % % label{24}='Npuff 2e20 09.09 sbNfl';
% % % % label{25}='Npuff 2e20 12.09 sbNfl';
% % % % label{26}='Npuff 2e20 14.09 sbNfl';
% % % % label{27}='Npuff 2e20 09.09 sbNfl fr5';
% % % % label{28}='Npuff 2e20 14.09 sbNfl fr5';

%%%%%%%%%%%%%%%%%%%%%%/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_2e18
% % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_1e20/watch_11.01.2017/';
% % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_1e20/watch_20.01.2017/';
% % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_1e20/watch_25.01.2017/';
% % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_1e20/watch_30.01.2017/';
% % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_Jan2017/Npuff_1e20/watch_03.02.2017/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_07.09.2016/';
% % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_09.09.2016/';
% % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_14.09.2016/';
% % % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_16.09.2016/';
% % % % % PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_07.09.2016/';
% % % % % PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_09.09.2016/';
% % % % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_12.09.2016/';
% % % % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_14.09.2016/';
% % % % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_16.09.2016/';
% % % % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_19.09.2016/';
% % % % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_09.09.2016/';
% % % % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_14.09.2016/';
% % % % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_16.09.2016/';
% % % % % PATH_PREFIX{18}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_19.09.2016/';
% % % % % PATH_PREFIX{19}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_22.09.2016/';
% % label{1}='Npuff 1e20 11.01';
% % label{2}='Npuff 1e20 20.01';
% % label{3}='Npuff 1e20 25.01';
% % label{4}='Npuff 1e20 30.01';
% % label{5}='Npuff 1e20 03.02';
% % % % % label{5}='Npuff 2e20 07.09 sb';
% % % % % label{6}='Npuff 2e20 09.09 sb';
% % % % % label{7}='Npuff 2e20 14.09 sb';
% % % % % label{8}='Npuff 2e20 16.09 sb';
% % % % % label{9}='Npuff 2e20 07.09 sbNfl';
% % % % % label{10}='Npuff 2e20 09.09 sbNfl';
% % % % % label{11}='Npuff 2e20 12.09 sbNfl';
% % % % % label{12}='Npuff 2e20 14.09 sbNfl';
% % % % % label{13}='Npuff 2e20 16.09 sbNfl';
% % % % % label{14}='Npuff 2e20 19.09 sbNfl';
% % % % % label{15}='Npuff 2e20 09.09 sbNfl fr5';
% % % % % label{16}='Npuff 2e20 14.09 sbNfl fr5';
% % % % % label{17}='Npuff 2e20 16.09 sbNfl fr5';
% % % % % label{18}='Npuff 2e20 19.09 sbNfl fr5';
% % % % % label{19}='Npuff 2e20 22.09 sbNfl fr5';

%Figure_Store_PATH = [PATH_PREFIX{1}, '../scan_30.01.2017/'];


% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_09.09.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_14.09.2016/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_16.09.2016/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_19.09.2016/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_from_5e20/watch_22.09.2016/';
% % % % % 
% % % % % label{1}='Npuff 2e20 09.09 sbNfl fr5';
% % % % % label{2}='Npuff 2e20 14.09 sbNfl fr5';
% % % % % label{3}='Npuff 2e20 16.09 sbNfl fr5';
% % % % % label{4}='Npuff 2e20 19.09 sbNfl fr5';
% % % % % label{5}='Npuff 2e20 22.09 sbNfl fr5';

% % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_07.09.2016/';
% % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_09.09.2016/';
% % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_12.09.2016/';
% % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_14.09.2016/';
% % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_16.09.2016/';
% % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_19.09.2016/';
% % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_22.09.2016/';
% % % % label{1}='Npuff 2e20 07.09 sbNfl';
% % % % label{2}='Npuff 2e20 09.09 sbNfl';
% % % % label{31}='Npuff 2e20 12.09 sbNfl';
% % % % label{4}='Npuff 2e20 14.09 sbNfl';
% % % % label{5}='Npuff 2e20 16.09 sbNfl';
% % % % label{6}='Npuff 2e20 19.09 sbNfl';
% % % % label{7}='Npuff 2e20 22.09 sbNfl';


% % % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_02.09.2016/';
% % % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_05.09.2016/';
% % % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_07.09.2016/';
% % % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_09.09.2016/';
% % % % % PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_12.09.2016/';
% % % % % PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_14.09.2016/';
% % % % % PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_16.09.2016/';
% % % % % PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_19.09.2016/';
% % % % % label{1}='Npuff 12e19 02.09 sb';
% % % % % label{2}='Npuff 12e19 05.09 sb';
% % % % % label{3}='Npuff 12e19 07.09 sb';
% % % % % label{4}='Npuff 12e19 09.09 sb';
% % % % % label{5}='Npuff 12e19 12.09 sb';
% % % % % label{6}='Npuff 12e19 14.09 sb';
% % % % % label{7}='Npuff 12e19 16.09 sb';
% % % % % label{8}='Npuff 12e19 19.09 sb';



% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_01.09.2016/';
% % % %PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_05.09.2016/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_8e19/watch_07.09.2016/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_02.09.2016/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_05.09.2016/';
% % % PATH_PREFIX{15}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e19/watch_07.09.2016/';
% % % PATH_PREFIX{16}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_02.09.2016/';
% % % PATH_PREFIX{17}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_05.09.2016/';
% % % PATH_PREFIX{18}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_16e19/watch_07.09.2016/';
% % % PATH_PREFIX{19}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_02.09.2016/';
% % % PATH_PREFIX{20}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_05.09.2016/';
% % % PATH_PREFIX{21}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20/watch_07.09.2016/';
% % % PATH_PREFIX{22}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_2e20_incr_core_Nflux/watch_07.09.2016/';
% % % PATH_PREFIX{23}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20/watch_02.09.2016/';
% % % %PATH_PREFIX{24}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20/watch_05.09.2016/';
% % % PATH_PREFIX{24}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20/watch_07.09.2016/';
% % % PATH_PREFIX{25}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20_incr_core_Nflux/watch_07.09.2016/';
% % % PATH_PREFIX{26}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e20/watch_07.09.2016/';
% % % PATH_PREFIX{27}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_25e20/watch_07.09.2016/';
% % % PATH_PREFIX{28}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_36e20/watch_07.09.2016/';



% % % 
% % % label{11}='Npuff 8e19 01.09';
% % % %label{12}='Npuff 8e19 05.09';
% % % label{12}='Npuff 8e19 07.09 sb';
% % % label{13}='Npuff 12e19 02.09 sb';
% % % label{14}='Npuff 12e19 05.09 sb';
% % % label{15}='Npuff 12e19 07.09 sb';
% % % label{16}='Npuff 16e19 02.09 sb';
% % % label{17}='Npuff 16e19 05.09 sb';
% % % label{18}='Npuff 16e19 07.09 sb';
% % % label{19}='Npuff 2e20 02.09 sb';
% % % label{20}='Npuff 2e20 05.09 sb';
% % % label{21}='Npuff 2e20 07.09 sb';
% % % label{22}='Npuff 2e20 07.09 sbNfl';
% % % label{23}='Npuff 5e20 02.09 sb';
% % % %label{24}='Npuff 5e20 05.09 sb';
% % % label{24}='Npuff 5e20 07.09 sb';
% % % label{25}='Npuff 5e20 07.09 sbNfl';
% % % label{26}='Npuff 12e20 02.09 sBC1';
% % % label{27}='Npuff 25e20 05.09 sBC1';
% % % label{28}='Npuff 36e20 02.09 sBC1';


% % % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_12e20/watch_07.09.2016/';
% % % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_25e20/watch_07.09.2016/';
% % % % PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_36e20/watch_07.09.2016/';
% % % % PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_August/rotation_lk/Npuff_5e20_incr_core_Nflux/watch_07.09.2016/';
% % % % label{1}='Npuff 12e20 02.09 sBC1';
% % % % label{2}='Npuff 25e20 05.09 sBC1';
% % % % label{3}='Npuff 36e20 02.09 sBC1';
% % % % label{4}='Npuff 5e20 07.09 sbNfl';





% PATH_PREFIX{5}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.81_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{6}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{7}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.90_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{8}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.95_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{5}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_08.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{6}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903/alb0.90_Npuff2e19_watch_09.06.2016/b2mn.exe.dir/';

% PATH_PREFIX{1}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{2}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff5e19_drift1.0_BCCON27_ThF_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{3}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff8e19_drift1.0_BCCON27_ThF_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{4}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_RedTransp_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{5}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff5e19_drift1.0_BCCON27_ThF_RedTransp_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{6}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff8e19_drift1.0_BCCON27_ThF_RedTransp_watch_17.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{7}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{8}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff5e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{9}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff8e19_drift1.0_BCCON27_ThF_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{10}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff2e19_drift1.0_BCCON27_ThF_RedTransp_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{11}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff5e19_drift1.0_BCCON27_ThF_RedTransp_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{12}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff8e19_drift1.0_BCCON27_ThF_RedTransp_watch_21.06.2016/b2mn.exe.dir/';
% PATH_PREFIX{13}='/home/senichenkov/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_June2016/alb0.87_Dpuff2e22_Npuff12e19_drift1.0_BCCON27_ThF_watch_22.06.2016/b2mn.exe.dir/';

% % %  label{1}='a0.90 D2e22 N2e19 01';
% % %  label{2}='a0.90 D2e22 N5e19 01';
% % %  label{3}='a0.90 D2e22 N8e18 01';
% % %  label{4}='a0.81 D2e22 N2e19 crude';
% % %  label{5}='a0.81 D2e22 N2e19 prec 01';
% % %  label{6}='a0.90 D2e22 N2e19 02';
% % %  label{7}='a0.90 D2e22 N5e19 02';
% % %  label{8}='a0.90 D2e22 N8e18 02';
% % %  label{9}='a0.90 D2e22 N2e19 03';
% % %  label{10}='a0.90 D2e22 N5e19 03';
% % %  label{11}='a0.90 D2e22 N8e18 03';
% % %  label{12}='a0.90 D2e22 N8e19 03';
% % %  label{13}='a0.81 D2e22 N2e19 prec 03';
% % %  label{14}='a0.90 D2e22 N2e19 06';
% % %  label{15}='a0.90 D2e22 N5e19 06';
% % %  label{16}='a0.90 D2e22 N8e18 06';
% % %  label{17}='a0.90 D2e22 N8e19 06';
% % %  label{18}='a0.81 D2e22 N2e19 prec 06';
% % %  label{19}='a0.81 D2.25e22 N2e19 06';
% % %  label{20}='a0.90 D2e22 N2e19 08';
% % %  label{21}='a0.90 D2e22 N5e19 08';
% % %  label{22}='a0.90 D2e22 N8e18 08';
% % %  label{23}='a0.90 D2e22 N8e19 08';
% % %  label{24}='a0.81 D2e22 N2e19 prec 08';
% % %  label{25}='a0.81 D2.25e22 N2e19 08';
% % %  label{26}='a0.87 D2e22 N2e19 08';
% % %  label{27}='a0.87 D2e22 N2e19 ThF 08';

% label{4}='a0.81 D2e22 N5e19 Nfl5e18 20.05.16';
% % %  
% % %  label{1}='Npuff 2e19 27.06';
% % %  label{2}='Npuff 5e19 25.06';
% % %  label{3}='Npuff 8e19 27.05';
% % %  label{4}='Npuff 12e19 27.06';
% % %  label{5}='Npuff 12e19 27.06';
% % %  label{6}='Npuff 12e19 15.08';
% % %  label{7}='Npuff 12e19 27.08';
% % %  label{8}='Npuff 8e18 rot 27.08';
% % %  label{9}='Npuff 2e19 rot 27.08';
% % %  label{10}='Npuff 5e19 rot 27.08';
% % %  label{11}='Npuff 8e19 rot 27.08';
% % %  label{12}='Npuff 8e19 rot 29.08';
% % %  label{13}='Npuff 2e19 rot bar 30.08';
% % %  label{14}='Npuff 5e19 rot bar 30.08';
% % %  label{15}='Npuff 8e19 rot bar 30.08';
%  label{5}='a0.81 21';
%  label{6}='a0.87 21';
%  label{7}='a0.90 21';
%  label{8}='a0.95 21';
%  label{5}='a0.90 D2e22 N2e19 08';
%  label{6}='a0.90 D2e22 N2e19 09';
 
%   label{1}='a0.87 N2e19 ET 17';
%   label{2}='a0.87 N5e19 ET 17';
%   label{3}='a0.87 N8e19 ET 17';
%   label{4}='a0.87 N2e19 RT 17';
%   label{5}='a0.87 N5e19 RT 17';
%   label{6}='a0.87 N8e19 RT 17';
%   label{7}='a0.87 N2e19 ET 21';
%   label{8}='a0.87 N5e19 ET 21';
%   label{9}='a0.87 N8e19 ET 21';
%   label{10}='a0.87 N2e19 RT 21';
%   label{11}='a0.87 N5e19 RT 21';
%   label{12}='a0.87 N8e19 RT 21';
%   label{13}='a0.87 N12e19 ET 22';
 
% PATH_PREFIX{1}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
%PATH_PREFIX{1}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff2e19_drift0.5_lowNinit_lowNflux/watch_13.05.2016/';
%PATH_PREFIX{2}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff2e19_drift0.5_lowNinit_lowNflux/watch_16.05.2016/';
% PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
%PATH_PREFIX{3}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff2e19_drift0.5_lowNinit_lowNflux/watch_18.05.2016/';
% PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_highNinit/watch_13.05.2016/';
% PATH_PREFIX{7}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{8}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{9}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff2e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{10}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{11}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{12}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff4e21_Npuff5e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
%PATH_PREFIX{1}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff1.4e22_Npuff2e19_drift0.2_lowNinit/watch_12.05.2016/';
%PATH_PREFIX{2}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff1.4e22_Npuff2e19_drift0.2_lowNinit_lowNflux/watch_12.05.2016/';
% 
% 
% PATH_PREFIX{15}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{16}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff2e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{3}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff5e19_drift0.2_lowNinit/watch_12.05.2016/';
% PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff1.6e22_Npuff5e19_drift0.2_lowNinit_lowNflux/watch_12.05.2016/';
% PATH_PREFIX{5}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_lowNinit/watch_13.05.2016/';
% PATH_PREFIX{6}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_lowNinit_lowNflux/watch_13.05.2016/';
%PATH_PREFIX{7}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff2e22_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';
%PATH_PREFIX{8}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.74_Dpuff2e22_Npuff5e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% 
% PATH_PREFIX{23}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff1.2e22_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{24}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff1.2e22_Npuff2e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{25}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{26}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{26}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff2e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{27}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{28}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{28}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff5e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{29}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{30}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{31}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff2e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';
% PATH_PREFIX{32}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{33}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{34}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff5e19_nodrift_lowNinit_lowNflux/watch_10.05.2016/';


% PATH_PREFIX{9}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{10}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{11}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{12}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';


% PATH_PREFIX{9}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff8e20_Npuff2e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{10}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff8e20_Npuff2e19_nodrift_lowNinit/watch_10.05.2016/';
% PATH_PREFIX{11}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff8e20_Npuff5e19_nodrift_highNinit/watch_10.05.2016/';
% PATH_PREFIX{12}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff8e20_Npuff5e19_nodrift_lowNinit/watch_10.05.2016/';


% PATH_PREFIX{1}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff2e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{2}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff2e19_nodrift_lowNinit/watch_06.05.2016/';
% PATH_PREFIX{3}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff5e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff2e22_Npuff5e19_nodrift_lowNinit/watch_06.05.2016/';
% PATH_PREFIX{5}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff2e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{6}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff2e19_nodrift_lowNinit/watch_06.05.2016/';
% PATH_PREFIX{7}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff5e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{8}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff4e21_Npuff5e19_nodrift_lowNinit/watch_06.05.2016/';
% PATH_PREFIX{9}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff2e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{10}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff2e19_nodrift_lowNinit/watch_06.05.2016/';
% PATH_PREFIX{11}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff5e19_nodrift_highNinit/watch_06.05.2016/';
% PATH_PREFIX{12}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.95_Dpuff8e20_Npuff5e19_nodrift_lowNinit/watch_06.05.2016/';

%PATH_PREFIX{4}='/home/senichenkov/B2runs/Detachment_2016/AUG28903_Coriolis/alb0.81_Dpuff2e22_Npuff5e19_nodrift_lowNinit/watch_04.05.2016/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_negativeB/watch_19.05.2015/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_negativeB/watch_19.05.2015/';

%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_nodrift_istate/watch_16.06.2015/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_nodrift_istate/watch_16.06.2015/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_nodrift/watch_04.06.2015/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_nodrift/watch_04.06.2015/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_negativeB/watch_02.04.2015/';
% PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_negativeB/watch_02.04.2015/';
% 
% 
% label{1}='alb0.81 D2e22 N2e19 h';
% label{1}='a0.74 D1.6e22 dr 0.5 13';
% label{2}='a0.74 D1.6e22 dr 0.5 16';
% label{4}='alb0.81 D2e22 N5e19 h';
% label{4}='a0.81 D2e22 N5e19 h';
% label{7}='alb0.81 D4e21 N2e19 h';
% label{8}='alb0.81 D4e21 N2e19 l';
% label{9}='alb0.81 D4e21 N2e19 lfl';
% label{10}='alb0.81 D4e21 N5e19 h';
% label{11}='alb0.81 D4e21 N5e19 l';
% label{12}='alb0.81 D4e21 N5e19 lfl';
% label{1}='alb0.81 D1.4e22 N2e19 l';
% label{2}='alb0.81 D1.4e22 N2e19 lfl';
% 
% label{15}='alb0.74 D1.6e22 N2e19 l';
% label{16}='alb0.74 D1.6e22 N2e19 lfl';
% label{3}='alb0.74 D1.6e22 N5e19 l';
% label{4}='alb0.74 D1.6e22 N5e19 lfl';
% label{5}='a0.81 D2e22 N5e19 l';
% label{6}='a0.81 D2e22 N5e19 llfl';
% %label{7}='alb0.74 D2e22 N5e19 l';
%label{8}='alb0.74 D2e22 N5e19 lfl';
% 
% label{1}='alb0.95 D2e22 N2e19 h';
% label{2}='alb0.95 D2e22 N2e19 l';
% label{3}='alb0.95 D2e22 N5e19 h';
% label{4}='alb0.95 D2e22 N5e19 l';
% label{5}='alb0.95 D4e21 N2e19 h';
% label{6}='alb0.95 D4e21 N2e19 l';
% label{7}='alb0.95 D4e21 N5e19 h';
% label{8}='alb0.95 D4e21 N5e19 l';
% label{9}='alb0.95 D8e20 N2e19 h';
% label{10}='alb0.95 D8e20 N2e19 l';
% label{11}='alb0.95 D8e20 N5e19 h';
% label{12}='alb0.95 D8e20 N5e19 l';
%label{4}='alb0.81 D2e22 N5e19_l';
%label{3}='<n_i>=8.0';
%label{5}='<n_i>=12.0';
%label{7}='na01 8.0 no drift 2';
%label{8}='na01 12.0 no drift 2';
%%label{7}='<n_i>_{CORE}=3.0';
%%label{6}='na01 3.0 density only';
%label{4}='<n_i>=8.0 no drift';
%label{6}='<n_i>_{CORE}=12.0 no drift';


%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_05.05.2015/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_nodrift/watch_04.06.2015/';


%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_negativeB/watch_02.04.2015/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_negativeB/watch_14.04.2015/';

%label{1}='na01 4.0 negative B 02.04';
%label{2}='na01 4.0 negative B 14.04';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_negative_B_14.01.2015/first_step_from0_drift/positive_fluid/run/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_negative_B_14.01.2015/first_step_from0_drift/negative_fluid/run/';
% 
% label{1}='positive';
% label{2}='negative';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_nodrift/watch_15.01.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_nodrift/watch_30.01.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0_nodrift/watch_01.03.2015/';
% label{1}='15.01.2015';
% label{2}='30.01.2015';
% label{3}='01.03.2015';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_15.01.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_30.01.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_01.03.2015/';
% label{1}='15.01.2015';
% label{2}='30.01.2015';
% label{3}='01.03.2015';

%PATH_PREFIX='/home/ilya/B2runs/solps5.3/repeat17151.4138.96x36.Hmode.gfortran.mpi/watch_30.10.2013_17:13:41/';
%PATH_PREFIX='/home/ilya/B2runs/solps5.3/AUG17151/repeat17151.4138.96x36.Hmode.gfortran.nompi/watch_30.10.2013_17:07:42/'
%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.2/AUG17151/Detachment_2012/drift_0.0_resc1e-20_nowdia_novecrb_limua_limna1e10_sigma1e-5_bcmom15/watch_28.05.2012_18:34:30/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/17151.4138.96x36.mpi.nodrift_rBCSPb_volrec/watch_04.12.2013/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/17151.4138.96x36.mpi.nodrift_rBCSPb_volrec_a0.995/watch_11.12.2013/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/17151.4138.96x36.mpi.nodrift_rBCSPb_volrec_a0.99/watch_17.12.2013/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/drift_volrec_alb0.997/drift0.3_sig5e-5/watch_09.01.2014/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/drift_volrec_alb0.997/drift0.7_sig5e-5/watch_09.01.2014/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/drift_volrec_alb0.997/drift1.0_sig5e-5/run_1/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/drift_volrec_alb0.99/drift1.0_sig5e-5_ver_Jan2014/watch_03.02.2014_18:05:49/';
%PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2013/drift_volrec_alb0.99/drift1.0_sig5e-5_ver_Mar2014/watch_01.04.2014/';

%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver081/28.10.2014/watch_10.11.2014/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_25.11.2014_09:48:54/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_01.12.2014_21:43:22/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_05.12.2014_05:58:30/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_12.12.2014/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_21.12.2014/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_30.12.2014/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_13.01.2015/';


%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_27.11.2014_14:25:40/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_28.11.2014_15:46:42/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_30.11.2014_21:56:59/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_01.12.2014_21:44:46/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_03.12.2014_07:10:53/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_04.12.2014_08:39:02/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_05.12.2014_15:43:28/';
%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_09.12.2014_07:55:10/';

%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_thermal_force/watch_10.12.2014/';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_15.01.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_30.01.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_01.03.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_23.03.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_04.04.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_14.04.2015/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_19.04.2015/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_30.04.2015/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_05.05.2015/';
% label{1}='15.01.2015';
% label{2}='30.01.2015';
% label{3}='01.03.2014';
% label{4}='23.03.2015';
% label{5}='04.04.2015';
% label{6}='14.04.2015';
% label{7}='19.04.2015';
% label{8}='30.04.2015';
% label{9}='05.05.2015';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_29.01.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_30.01.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_01.03.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_23.03.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_05.04.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_14.04.2015/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_19.04.2015/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_30.04.2015/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0/watch_05.05.2015/';
% label{1}='29.01.2015';
% label{2}='30.01.2015';
% label{3}='01.03.2014';
% label{4}='23.03.2015';
% label{5}='05.04.2015';
% label{6}='14.04.2015';
% label{7}='19.04.2015';
% label{8}='30.04.2015';
% label{9}='05.05.2015';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_29.01.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_30.01.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_01.03.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_23.03.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_03.04.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_14.04.2015/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_19.04.2015/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_30.04.2015/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0/watch_05.05.2015/';
% label{1}='29.01.2015';
% label{2}='30.01.2015';
% label{3}='01.03.2014';
% label{4}='23.03.2015';
% label{5}='03.04.2015';
% label{6}='14.04.2015';
% label{7}='19.04.2015';
% label{8}='30.04.2015';
% label{9}='05.05.2015';

%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_25.11.2014_19:06:11/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_26.11.2014_15:59:49/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_27.11.2014_14:24:45/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_28.11.2014_15:45:38/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_29.11.2014_22:03:20/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_30.11.2014_21:55:20/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_01.12.2014_21:47:52/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_03.12.2014_07:14:11/';
%PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_04.12.2014_22:54:55/';
%PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_06.12.2014/';
%PATH_PREFIX{11}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_07.12.2014/';
%PATH_PREFIX{12}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_09.12.2014/';
%PATH_PREFIX{13}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_10.12.2014/';
%PATH_PREFIX{14}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_11.12.2014/';
%PATH_PREFIX{15}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_13.12.2014/';
%PATH_PREFIX{16}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_14.12.2014/';
%PATH_PREFIX{17}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_15.12.2014/';

%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_01.12.2014_22:32:20/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_03.12.2014_21:58:40/';
%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_30.11.2014_22:31:16/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_04.12.2014/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_06.12.2014/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_07.12.2014/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_08.12.2014/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_09.12.2014/';
%PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_10.12.2014/';
%PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_11.12.2014/';
%PATH_PREFIX{11}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_13.12.2014/';
%PATH_PREFIX{12}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_14.12.2014/';
%PATH_PREFIX{13}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_15.12.2014/';


%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_01.12.2014_22:05:24/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_03.12.2014_07:11:45/';
%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_30.11.2014_22:03:44/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_04.12.2014_21:37:37/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_06.12.2014_10:12:29/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_07.12.2014_18:16:11/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_08.12.2014_18:55:54/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_lizzlans/watch_09.12.2014_07:56:24/';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_17.06.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_15.09.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_20.09.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_27.09.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_05.10.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_11.10.2015/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_20.10.2015/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/200_steps/run/';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_positive_old/watch_21.12.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_positive_old/watch_23.12.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_negative_new/watch_21.12.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_negative_new/watch_23.12.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_positive_old/watch_29.12.2015/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_negative_new/watch_29.12.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_positive_old/watch_11.02.2016/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_ua/u_negative_new/watch_09.02.2016/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/test_intcor/new_correction/watch_16.02.2016/';

%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_20.12.2014/';
%PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_21.12.2014/';
%PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_22.12.2014/';
%PATH_PREFIX{11}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_23.12.2014/';
%PATH_PREFIX{12}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_24.12.2014/';
%PATH_PREFIX{13}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_30.12.2014/';
%PATH_PREFIX{14}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_13.01.2015/';

% label{1}='17.06.2015';
% label{2}='15.09.2015';
% label{3}='n20.09.2015';
% label{4}='27.09.2015';
% label{5}='05.10.2015';
% label{6}='11.10.2015';
% label{7}='20.10.2015';
% label{8}='23.10.2015 + 200 steps';

% label{1}='21.12.2015';
% label{2}='23.12.2015';
% label{5}='21.12.2015 new';
% label{6}='23.12.2015 new';
% label{3}='29.12.2015';
% label{7}='29.12.2015 new';
% label{4}='11.02.2016';
% label{8}='09.02.2016 new';
% label{9}='new intcor';


% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_05.06.2015/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_15.09.2015/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_20.10.2015/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_27.09.2015/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_05.10.2015/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_08.06.2015/';
% 
% label{1}='05.06.2015';
% label{2}='08.06.2015';
% label{3}='15.09.2015';
% label{4}='27.09.2015';
% label{5}='05.10.2015';
% label{6}='20.10.2015';


%PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0/watch_13.01.2015/';
%PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_nodrift/watch_05.12.2014/';
%PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_8.0/watch_13.01.2015/';
%PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_12.0/watch_13.01.2015/';
%PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_3.0_lizzlans/watch_13.01.2015/';
%PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.5_lizzlans/watch_13.01.2015/';
%%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_2.0_restart/watch_21.12.2014/';
%PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_4.0_thermal_force/watch_13.01.2015/';
%PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2014/ver083/na01_8.0_thermal_force/watch_13.01.2015/';

% PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/200_steps/run/';
% PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/400_steps/run/';
% PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/600_steps/run/';
% PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/800_steps/run/';
% PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1000_steps/run/';
% PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1200_steps/run/';
% PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1400_steps/run/';
% PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1600_steps/run/';
% PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1800_steps/run/';
% PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/2000_steps/run/';
% PATH_PREFIX{11}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/2200_steps/run/';
% PATH_PREFIX{12}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/2400_steps/run/';
% PATH_PREFIX{13}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/2600_steps/run/';
% PATH_PREFIX{14}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/2800_steps/run/';
% PATH_PREFIX{15}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/3000_steps/run/';
% PATH_PREFIX{16}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/3200_steps/run/';
% PATH_PREFIX{17}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/3400_steps/run/';
% PATH_PREFIX{18}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/3600_steps/run/';
% PATH_PREFIX{19}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/3800_steps/run/';
% PATH_PREFIX{20}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4000_steps/run/';
% PATH_PREFIX{21}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4200_steps/run/';
% PATH_PREFIX{22}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4400_steps/run/';
% PATH_PREFIX{23}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4600_steps/run/';
% PATH_PREFIX{24}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4800_steps/run/';
% PATH_PREFIX{25}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/5000_steps/run/';
% PATH_PREFIX{26}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/6000_steps/run/';
% PATH_PREFIX{27}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/6800_steps/run/';
% PATH_PREFIX{28}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/8000_steps/run/';
% PATH_PREFIX{29}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/9000_steps/run/';
% PATH_PREFIX{30}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/10000_steps/run/';
% 
% label{1}='200';
% label{2}='400';
% label{3}='600';
% label{4}='800';
% label{5}='1000';
% label{6}='1200';
% label{7}='1400';
% label{8}='1600';
% label{9}='1800';
% label{10}='2000';
% label{11}='2200';
% label{12}='2400';
% label{13}='2600';
% label{14}='2800';
% label{15}='3000';
% label{16}='3200';
% label{17}='3400';
% label{18}='3600';
% label{19}='3800';
% label{20}='4000';
% label{21}='4200';
% label{22}='4400';
% label{23}='4600';
% label{24}='4800';
% label{25}='5000';
% label{26}='6000';
% label{27}='6800';
% label{28}='8000';
% label{29}='9000';
% label{30}='10000';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/1000_steps/run/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/4000_steps/run/';
% % % PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/6800_steps/run/';
% % % PATH_PREFIX{4}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/10000_steps/run/';
% % % PATH_PREFIX{5}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/13000_steps/run/';
% % % PATH_PREFIX{6}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/16000_steps/run/';
% % % PATH_PREFIX{7}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/19000_steps/run/';
% % % PATH_PREFIX{8}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/22000_steps/run/';
% % % PATH_PREFIX{9}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/25000_steps/run/';
% % % PATH_PREFIX{10}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/28000_steps/run/';
% % % PATH_PREFIX{11}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/31000_steps/run/';
% % % PATH_PREFIX{12}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/34000_steps/run/';
% % % PATH_PREFIX{13}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/37000_steps/run/';
% % % PATH_PREFIX{14}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/40000_steps/run/';
% % % PATH_PREFIX{15}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/43000_steps/run/';
% % % PATH_PREFIX{16}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/46000_steps/run/';
% % % PATH_PREFIX{17}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/49000_steps/run/';
% % % PATH_PREFIX{18}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/52000_steps/run/';
% % % PATH_PREFIX{19}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/55000_steps/run/';
% % % PATH_PREFIX{20}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/58000_steps/run/';
% % % PATH_PREFIX{21}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/61000_steps/run/';
% % % PATH_PREFIX{22}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/64000_steps/run/';
% % % PATH_PREFIX{23}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/67000_steps/run/';
% % % PATH_PREFIX{24}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/70000_steps/run/';
% % % PATH_PREFIX{25}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/73000_steps/run/';
% % % PATH_PREFIX{26}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/76000_steps/run/';
% % % PATH_PREFIX{27}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/79000_steps/run/';
% % % PATH_PREFIX{28}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/82000_steps/run/';
% % % PATH_PREFIX{29}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/20000_steps/run/';
% % % PATH_PREFIX{30}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_23.10.2015_multi/21000_steps/run/';
% % % 
% % % label{1}='1000';
% % % label{2}='4000';
% % % label{3}='6800';
% % % label{4}='10000';
% % % label{5}='13000';
% % % label{6}='16000';
% % % label{7}='19000';
% % % label{8}='22000';
% % % label{9}='25000';
% % % label{10}='28000';
% % % label{11}='31000';
% % % label{12}='34000';
% % % label{13}='37000';
% % % label{14}='40000';
% % % label{15}='43000';
% % % label{16}='46000';
% % % label{17}='49000';
% % % label{18}='52000';
% % % label{19}='55000';
% % % label{20}='58000';
% % % label{21}='61000';
% % % label{22}='64000';
% % % label{23}='67000';
% % % label{24}='70000';
% % % label{25}='73000';
% % % label{26}='76000';
% % % label{27}='79000';
% % % label{28}='82000';
% % % label{29}='20000';
% % % label{30}='21000';

%   PATH_PREFIX{1}='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_ANK/alb0.81_Dpuff2e22_Npuff2e19/watch_14.03.2016/';
%   PATH_PREFIX{2}='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_ANK/alb0.81_Dpuff2e22_Npuff2e20/watch_14.03.2016/';
%   PATH_PREFIX{3}='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_ANK/alb0.95_Dpuff2e22_Npuff2e19/watch_17.03.2016/';
%   PATH_PREFIX{4}='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_ANK/alb0.95_Dpuff2e22_Npuff2e19/watch_21.03.2016/';
%   PATH_PREFIX{6}='/tokp/work/sytovae/test_sigp/solps-iter/runs/alb0.81_Dpuff2e22_Npuff2e20/b2mn.exe.dir/';
%   PATH_PREFIX{5}='/tokp/work/iys/SOLPS-ITER/solps-iter/runs/Detachment_N/AUG28903_ANK/alb0.95_Dpuff2e22_Npuff2e20/b2mn.exe.dir/';

% %  PATH_PREFIX{3}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22/watch_12.02.2016/';
% %  PATH_PREFIX{4}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22/watch_20.02.2016/';
% %  PATH_PREFIX{5}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22_2/watch_21.02.2016/';
% %  PATH_PREFIX{6}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22_thfLizzlans/watch_19.02_thf/';
% %  PATH_PREFIX{7}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff2e21/watch_20.02.2016/';
% %  PATH_PREFIX{8}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22/watch_25.02.2016/';
% %  PATH_PREFIX{9}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff2e21/watch_25.02.2016/';
% %  PATH_PREFIX{10}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff1e22/watch_29.02.2016/';
% %  PATH_PREFIX{11}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff2e21/watch_29.02.2016/';
% %  PATH_PREFIX{12}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_ANK/Detachment_2016/AUG28903/BCCON27_ANK_albFelix_Dpuff2e22/watch_29.02.2016/';
% % 
%   label{1}='alb0.81 N2e19';
%   label{2}='alb0.81 N2e20';
%   label{3}='alb0.95 N2e19 17.03';
%   label{4}='alb0.95 N2e19 21.03';
%   label{5}='alb0.95 N2e20';
%   label{6}='alb0.81 N2e20 thf';
% 
% %  label{3}='interm 1';
% %  label{4}='1 20.02';
% %  label{5}='2 21.02';
% %  label{6}='end th force';
% %  label{7}='red. fuel.';
% %  label{8}='1 25.02';
% %  label{9}='red. fuel. 25.02';
% %  label{10}='1 29.02';
% %  label{11}='red. fuel. 29.02';
% %  label{12}='incr. fuel. 29.02';

% % % % % % % % % % %  PATH_PREFIX{1}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_4.0/watch_05.05.2015/';
% % % % % % % % % % %  PATH_PREFIX{2}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_8.0_vprll/watch_05.10.2015/';
% % % % % % % % % % %  PATH_PREFIX{3}='/home/ilya/B2runs/solps5.3/AUG17151/Detachment2015/ver083/na01_12.0_vprll/watch_05.10.2015/';
% % % % % % % % % % %  EXP_DATA_PREFIX='/home/ilya/B2SOLPS/Chankin_experimental_data/';
% % % % % % % % % % % 
% % % % % % % % % % % label{1}='<n_i> 4.0';
% % % % % % % % % % % label{2}='<n_i> 8.0';
% % % % % % % % % % % label{3}='<n_i> 12.0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%label{1}='na01 4.0';
%label{2}='na01 4.0 nodrift';
%label{3}='na01 8.0';
%label{4}='na01 12.0';
%label{5}='na01 3.0';
%label{6}='na01 2.5';
%%label{7}='na01 2.0';
%label{7}='na01 4.0 thermal force';
%label{8}='na01 8.0 thermal force';


%label{1}='2012 NOdrift albedo = 0.997';
%label{2}='2013 NOdrift albedo = 0.997';
%label{3}='2013 NOdrift albedo = 0.995';
%label{4}='2013 NOdrift albedo = 0.990';
%label{5}='2013 drift 0.3 albedo = 0.997';
%label{6}='2013 drift 0.7 albedo = 0.997';
%label{7}='2013 drift 1.0 albedo = 0.997';
%label{8}='2014 drift 1.0 albedo = 0.99';
%label{9}='2014 drift 1.0 albedo = 0.99 NEW BC on targets';

%label{1}='na01 4.0 10.11.2014';
%label{2}='na01 4.0 25.11.2014';
%label{3}='na01 4.0 01.12.2014';
%label{4}='na01 4.0 05.12.2014';
%label{5}='na01 4.0 12.12.2014';
%label{6}='na01 4.0 21.12.2014';
%label{7}='na01 4.0 30.12.2014';
%label{8}='na01 4.0 13.01.2015';

%label{1}='na01 4.0 nodrift 27.11.2014';
%label{2}='na01 4.0 nodrift 28.11.2014';
%label{3}='na01 4.0 nodrift 30.11.2014';
%label{4}='na01 4.0 nodrift 01.12.2014';
%label{5}='na01 4.0 nodrift 03.12.2014';
%label{6}='na01 4.0 nodrift 04.12.2014';
%label{7}='na01 4.0 nodrift 05.12.2014';

%label{1}='na01 12.0 02.12.2014';
%label{2}='na01 12.0 03.12.2014';
%label{3}='na01 12.0 05.12.2014';
%label{4}='na01 12.0 09.12.2014';
%label{5}='na01 12.0 17.12.2014';
%label{6}='na01 12.0 18.12.2014';
%label{7}='na01 12.0 19.12.2014';
%label{8}='na01 12.0 20.12.2014';
%label{9}='na01 12.0 21.12.2014';
%label{10}='na01 12.0 22.12.2014';
%label{11}='na01 12.0 23.12.2014';
%label{12}='na01 12.0 24.12.2014';
%label{13}='na01 12.0 30.12.2014';
%label{14}='na01 12.0 13.01.2015';

%label{1}='na01 8.0 25.11.2014';
%label{2}='na01 8.0 26.11.2014';
%label{3}='na01 8.0 27.11.2014';
%label{4}='na01 8.0 28.11.2014';
%label{5}='na01 8.0 29.11.2014';
%label{6}='na01 8.0 30.11.2014';
%label{7}='na01 8.0 01.12.2014';
%label{8}='na01 8.0 02.12.2014';
%label{9}='na01 8.0 04.12.2014';
%label{10}='na01 8.0 05.12.2014';


%label{1}='na01 2.0 30.11.2014';
%label{2}='na01 2.0 01.12.2014';
%label{3}='na01 2.0 03.12.2014';
%label{4}='na01 2.0 04.12.2014';
%label{5}='na01 2.0 06.12.2014';
%label{6}='na01 2.0 07.12.2014';
%label{7}='na01 2.0 08.12.2014';
%label{8}='na01 2.0 09.12.2014';


%label{1}='na01 2.5 30.11.2014';
%label{2}='na01 2.5 01.12.2014';
%label{3}='na01 2.5 03.12.2014';
%label{4}='na01 2.5 04.12.2014';
%label{5}='na01 2.5 06.12.2014';
%label{6}='na01 2.5 07.12.2014';
%label{7}='na01 2.5 08.12.2014';
%label{8}='na01 2.5 09.12.2014';
%label{9}='na01 2.5 10.12.2014';
%label{10}='na01 2.5 11.12.2014';
%label{11}='na01 2.5 13.12.2014';
%label{12}='na01 2.5 14.12.2014';
%label{13}='na01 2.5 15.12.2014';



%label{1}='na01 3.0 25.11.2014';
%label{2}='na01 3.0 26.11.2014';
%label{3}='na01 3.0 27.11.2014';
%label{4}='na01 3.0 28.11.2014';
%label{5}='na01 3.0 29.11.2014';
%label{6}='na01 3.0 30.11.2014';
%label{7}='na01 3.0 01.12.2014';
%label{8}='na01 3.0 03.12.2014';
%label{9}='na01 3.0 04.12.2014';
%label{10}='na01 3.0 06.12.2014';
%label{11}='na01 3.0 07.12.2014';
%label{12}='na01 3.0 09.12.2014';
%label{13}='na01 3.0 10.12.2014';
%label{14}='na01 3.0 11.12.2014';
%label{15}='na01 3.0 13.12.2014';
%label{16}='na01 3.0 14.12.2014';
%label{17}='na01 3.0 15.12.2014';

%label{1}='old form of thermal force';
%label{2}='new form of thermal force';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Nitrogen/Npuff_2e18_watch_06.04.2017/b2mn.exe.dir/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps-iter/runs_old_style/AUG28903_April2017/Neon/Ne_puff_2e18_watch_06.04.2017/b2mn.exe.dir/';
% % % label{1}='N 2e18';
% % % label{2}='Ne 2e18';

% % % PATH_PREFIX{1}='/home/ilya/B2runs/solps5.2/GlobusM/34410/Lena_simple_BC/watch2/';
% % % PATH_PREFIX{2}='/home/ilya/B2runs/solps5.2/GlobusM/34358/B2run008/watch_03.03.2016/';
% % % label{1}='34410';
% % % label{2}='34458';
% % % Figure_Store_PATH='/home/ilya/B2runs/solps5.2/GlobusM/34358/B2run008/test_Compare_B2';

if exist(Figure_Store_PATH,'dir') ~= 7 
    mkdir(Figure_Store_PATH);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exp_data_flag
    Color_exp=cell(7);
%    legend_exp=cell(5);
    Marker_exp=cell(8);
    
    Color_exp{1} = [0.9 0.1 0.1];     % looks like red  - to correspond to quantities plotted in red
    Color_exp{2} = [0.95 0.05 0.05];  % looks like red  - to correspond to quantities plotted in red
    Color_exp{3} = [0.1 0.1 0.9];     % looks like blue - to correspond to quantities plotted in blue
    Color_exp{4} = [0.05 0.05 0.95];  % looks like blue - to correspond to quantities plotted in blue
    Color_exp{5} = [0.0 0.05 0.9];    % looks like blue - to correspond to quantities plotted in blue
    Color_exp{6} = [0.85,0.15,0.9];   % looks like   - to correspond to quantities plotted in  
    Color_exp{7} = [0.5,0.15,0.1];    % looks like   - to correspond to quantities plotted in  

    Marker_exp{1} = 'x';
    Marker_exp{2} = '*';
    Marker_exp{3} = '+';
    Marker_exp{4} = 'o';
    Marker_exp{5} = 'd';
    Marker_exp{6} = '^';
    Marker_exp{7} = 'v';
    Marker_exp{8} = 's';

    read_exp_data_AUG28903
%    read_exp_data_AUG17151
end;


%%%%%%%% READ GEOMETRY DATA 

read_geometry_Nresults;

ne=zeros(max(ny)+2,max(nx)+2,Nresults);
ne_norm=zeros(max(ny)+2,max(nx)+2,Nresults);
ne2=zeros(max(ny)+2,max(nx)+2,Nresults);
te=zeros(max(ny)+2,max(nx)+2,Nresults);
ti=zeros(max(ny)+2,max(nx)+2,Nresults);
po=zeros(max(ny)+2,max(nx)+2,Nresults);

jx=zeros(max(ny)+2,max(nx)+2,Nresults);
jy=zeros(max(ny)+2,max(nx)+2,Nresults);

na=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
nD2=zeros(max(ny)+2,max(nx)+2,Nresults);

ua=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
pa=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
pa_dyn=zeros(max(ny)+2,max(nx)+2,Nresults,ns);

pas=zeros(max(ny)+2,max(nx)+2,Nresults);
pas_fullHD=zeros(max(ny)+2,max(nx)+2,Nresults);

pNeut=zeros(max(ny)+2,max(nx)+2,Nresults);

%Mach=zeros(max(ny)+2,max(nx)+2,Nresults,ns);

sna_sral=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
sna_sral=zeros(max(ny)+2,max(nx)+2,Nresults,ns);

Zeff=zeros(max(ny)+2,max(nx)+2,Nresults);
jsat=zeros(max(ny)+2,max(nx)+2,Nresults);

Ey_lk=zeros(max(ny)+2,max(nx)+2,Nresults);
Ey_iyv=zeros(max(ny)+2,max(nx)+2,Nresults);

fnax=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnax_mdf=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_mdf=zeros(max(ny)+2,max(nx)+2,Nresults,ns);

fnax_Dgradn=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_Dgradn=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnax_nuExB=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_nuExB=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnax_PSch=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_PSch=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnax_dia=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_dia=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnax_nuAN=zeros(max(ny)+2,max(nx)+2,Nresults,ns);
fnay_nuAN=zeros(max(ny)+2,max(nx)+2,Nresults,ns);


sna=zeros(max(ny)+2,max(nx)+2,Nresults,ns);

fhey_mdf=zeros(max(ny)+2,max(nx)+2,Nresults);
fhiy_mdfY=zeros(max(ny)+2,max(nx)+2,Nresults);

fhey_ExB=zeros(max(ny)+2,max(nx)+2,Nresults);
fhiy_ExB=zeros(max(ny)+2,max(nx)+2,Nresults);

fhiy_curr=zeros(max(ny)+2,max(nx)+2,Nresults);

fhx_tot=zeros(max(ny)+2,max(nx)+2,Nresults);
fhex_tot=zeros(max(ny)+2,max(nx)+2,Nresults);
fhix_tot=zeros(max(ny)+2,max(nx)+2,Nresults);

jy_AN=zeros(max(ny)+2,max(nx)+2,Nresults);
jy_vispar=zeros(max(ny)+2,max(nx)+2,Nresults);
jy_inert=zeros(max(ny)+2,max(nx)+2,Nresults);


Fnay_mdf_in=zeros(max(nsep)+3,Nresults,ns);
Fnay_nuExB_in=zeros(max(nsep)+3,Nresults,ns);
Fnay_Dgradn_in=zeros(max(nsep)+3,Nresults,ns);


Fhey_mdf=zeros(max(nsep)+3,Nresults);
Fhey_mdf_plusExB=zeros(max(nsep)+3,Nresults);
Fhiy_mdf=zeros(max(nsep)+3,Nresults);
Fhiy_mdf_plusExB=zeros(max(nsep)+3,Nresults);
Fhiy_NEO=zeros(max(nsep)+3,Nresults);
Fhiy_PSch=zeros(max(nsep)+3,Nresults);

fhe_low_outer=zeros(max(ny)+1,Nresults);
fhi_low_outer=zeros(max(ny)+1,Nresults);
fhtot_low_outer=zeros(max(ny)+1,Nresults);
fhe_low_inner=zeros(max(ny)+1,Nresults);
fhi_low_inner=zeros(max(ny)+1,Nresults);
fhtot_low_inner=zeros(max(ny)+1,Nresults);
fhe_upper_outer=zeros(max(ny)+1,Nresults);
fhi_upper_outer=zeros(max(ny)+1,Nresults);
fhtot_upper_outer=zeros(max(ny)+1,Nresults);
fhe_upper_inner=zeros(max(ny)+1,Nresults);
fhi_upper_inner=zeros(max(ny)+1,Nresults);
fhtot_upper_inner=zeros(max(ny)+1,Nresults);

I_in=zeros(Nresults,1);
I_out=zeros(Nresults,1);

E_x=zeros(max(ny)+2,max(nx)+2,Nresults);
E_y=zeros(max(ny)+2,max(nx)+2,Nresults);
ux_ExB=zeros(max(ny)+2,max(nx)+2,Nresults);
uy_ExB=zeros(max(ny)+2,max(nx)+2,Nresults);

if EIRENE_flag
    pdena=zeros(max(N_tria),Natmi,Nresults);
    pdenm=zeros(max(N_tria),Nmoli,Nresults);
    edena=zeros(max(N_tria),Natmi,Nresults);
    edenm=zeros(max(N_tria),Nmoli,Nresults);
end;


for m=1:Nresults
   
    if exist([PATH_PREFIX{m} 'b2nph9_te.dat'],'file') == 2    
        te(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2nph9_te.dat'],nx(m),ny(m),max(nx),max(ny));
        ti(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2nph9_ti.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'b2npht_te.dat'],'file') == 2
        te(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npht_te.dat'],nx(m),ny(m),max(nx),max(ny));
        ti(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npht_ti.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'te.dat'],'file') == 2
        te(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'te.dat'],nx(m),ny(m),max(nx),max(ny));
        ti(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'ti.dat'],nx(m),ny(m),max(nx),max(ny));
    end;
    
    if exist([PATH_PREFIX{m} 'b2npp7_po.dat'],'file') == 2    
        po(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npp7_po.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'b2nppo_po.dat'],'file') == 2
        po(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2nppo_po.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'po.dat'],'file') == 2
        po(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'po.dat'],nx(m),ny(m),max(nx),max(ny));
    end;
    Ey_iyv(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'Eyc.dat'],nx(m),ny(m),max(nx),max(ny));

    for i=2:ny+1
    for j=2:ntt+1
        E_x(i,j,m)=(po(i,left(i,j)+2,m)-po(i,right(i,j)+2,m))/(hx(i,j,m)+0.5*(hx(i,right(i,j)+2,m)+hx(i,left(i,j)+2,m)));
        E_y(i,j,m)=(po(i-1,j,m)-po(i+1,j,m))/(hy(i,j,m)+0.5*(hy(i+1,j,m)+hy(i-1,j,m)));
    end;
    if nc2==ntt
        for j=ntt+2:ntt+3
         E_x(i,j,m)=(po(i,left(i,j)+2,m)-po(i,right(i,j)+2,m))/(hx(i,j,m)+0.5*(hx(i,right(i,j)+2,m)+hx(i,left(i,j)+2,m)));
        E_y(i,j,m)=(po(i-1,j,m)-po(i+1,j,m))/(hy(i,j,m)+0.5*(hy(i+1,j,m)+hy(i-1,j,m)));
       end;
    end;
    for j=ntt+4:nx+1
        E_x(i,j,m)=(po(i,left(i,j)+2,m)-po(i,right(i,j)+2,m))/(hx(i,j,m)+0.5*(hx(i,right(i,j)+2,m)+hx(i,left(i,j)+2,m)));
        E_y(i,j,m)=(po(i-1,j,m)-po(i+1,j,m))/(hy(i,j,m)+0.5*(hy(i+1,j,m)+hy(i-1,j,m)));
    end;
    
    ux_ExB(:,:,m) = -Bz(:,:,m).*E_y(:,:,m)./(B(:,:,m)).^2;
    uy_ExB(:,:,m) =  Bz(:,:,m).*E_x(:,:,m)./(B(:,:,m)).^2;
    

    end;
    
    if exist([PATH_PREFIX{m} 'b2tfhe_fch_px.dat'],'file') == 2
        jx(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npp7_fchx.dat'],nx(m),ny(m),max(nx),max(ny));
        jy(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npp7_fchy.dat'],nx(m),ny(m),max(nx),max(ny));  
    
        jy_AN(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfhe_fchanmly.dat'],nx(m),ny(m),max(nx),max(ny));
        jy_vispar(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfhe_fchvispary.dat'],nx(m),ny(m),max(nx),max(ny));
        jy_inert(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfhe_fchinerty.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'fchx_p.dat'],'file') == 2
        jx(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fchx.dat'],nx(m),ny(m),max(nx),max(ny));
        jy(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fchy.dat'],nx(m),ny(m),max(nx),max(ny));  
    
        jy_AN(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fchanmly.dat'],nx(m),ny(m),max(nx),max(ny));
        jy_vispar(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fchvispary.dat'],nx(m),ny(m),max(nx),max(ny));
        jy_inert(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fchinerty.dat'],nx(m),ny(m),max(nx),max(ny));
    end;
    
    I_in(m) = sum(jx(2:ny(m)+1,2,m));
    I_out(m) = sum(jx(2:ny(m)+1,nx(m)+2,m));

    if exist([PATH_PREFIX{m} 'b2nph9_fhex.dat'],'file') == 2
        fhey_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2nph9_fhey.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2nph9_fhiy.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_PSch(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfhi__fhiPSchy.dat'],nx(m),ny(m),max(nx),max(ny));
    elseif exist([PATH_PREFIX{m} 'b2npht_fhex.dat'],'file') == 2
        fhey_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npht_fhey.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npht_fhiy.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_PSch(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fhiPSchy.dat'],nx(m),ny(m),max(nx),max(ny));
    else
        fhey_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fhey.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_mdf(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fhiy.dat'],nx(m),ny(m),max(nx),max(ny));
        fhiy_PSch(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'fhiPSchy.dat'],nx(m),ny(m),max(nx),max(ny));       
    end;
    
    if EIRENE_flag 
       Eirene_neutral_counter = 1;
%       sna_eir=zeros(ny(m)+2,nx(m)+2,Nresults,ns);
% % % % READ TRIANGLE VOLUME FROM EIRENE
% % %        vol_eir(1:N_tria(m),m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,1,N_tria(m)+3,1]) * 1.0e-6;
% % %      
% % % % READ DENSITIES FROM EIRENE OUTPUT AND CONVERT TO SI UNITS
% % %        pdena(1:N_tria(m),1:Natmi,m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,1+1,N_tria(m)+3,Natmi+1]) * 1.0e6;
% % %        pdenm(1:N_tria(m),1:Nmoli,m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,Natmi+1+1,N_tria(m)+3,Natmi+Nmoli+1]) * 1.0e6;
% % % %       pdeni(1:N_tria(m),m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,Natmi+Nmoli+1+1,N_tria(m)+3,Natmi+Nmoli+Nioni+1]) * 1.0e6;
% % %      
% % % % READ ENERGY DENSITIES FROM EIRENE OUTPUT AND CONVERT TO SI UNITS
% % %        edena(1:N_tria(m),1:Natmi,m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,Natmi+Nmoli+Nioni+1+1,N_tria(m)+3,2*Natmi+Nmoli+Nioni+1])*1.0e6*qe;
% % %        edenm(1:N_tria(m),1:Nmoli,m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,2*Natmi+Nmoli+Nioni+1+1,N_tria(m)+3,2*Natmi+2*Nmoli+Nioni+1])*1.0e6*qe;
% % % %       edeni(1:N_tria(m),m) = dlmread([PATH_PREFIX{m} 'eirmod_extrab25.dat'],'',[4,2*Natmi+2*Nmoli+Nioni+1+1,N_tria(m)+3,2*Natmi+2*Nmoli+2*Nioni+1])*1.0e6*qe;    
    end;
    
    for is=1:ns
        if SOLPS_ITER(m)==1
          is_string = num2str(is-1,'%0.3i');
          if EIRENE_flag == 1
              Eir_nc_string = num2str(Eirene_neutral_counter,'%0.3i');
          end;
        else
          is_string = num2str(is-1,'%0.2i');
          if EIRENE_flag == 1
              Eir_nc_string = num2str(Eirene_neutral_counter,'%0.2i');
          end;
        end;
    
        % velocities
%       ua(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_ua' is_string '.dat'],nx,ny);
       ua(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npmo_ua' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
       
       if Za(is)==0  % special treatment of neutral particles because of optional usage of Eirene
        
         if EIRENE_flag == 1 % read output from Eirene
            
% %             % densities
% %             na(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_dab2_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny));
% %             
% %             % fluxes
% %             fnax(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hy(:,:).*hz(:,:);
% %             fnay(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hx(:,:).*hz(:,:);
% %             
% %             if Eirene_neutral_counter == 1
% %                 %molecules density
% %                 nD2(:,:,m)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_dmb2_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); % Deuterium molecules
% %                 
% %                 % fluxes
% %                  fnax(:,:,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)) + ... 
% %                      readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_pfluxm_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hy(:,:).*hz(:,:);
% %                  fnay(:,:,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)) + ...
% %                      readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_rfluxm_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hx(:,:).*hz(:,:);
% %             else
% %               % fluxes
% %                  fnax(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_pfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hy(:,:).*hz(:,:);
% %                  fnay(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2stbr_rfluxa_eir' Eir_nc_string '.dat'],nx(m),ny(m),max(nx),max(ny)); %.*hx(:,:).*hz(:,:);
% %             end;
            
            Eirene_neutral_counter = Eirene_neutral_counter + 1;
            
         else  % read standard B2 output for fluid neutrals
            
            %densities
            na(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npco_na' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
            
            % fluxes
             fnax(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnbx' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
             fnay(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnby' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
            
            % particle sources
             sna(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npco_sna' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
%             sna_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_sna0' is_string '.dat'],nx,ny)+na(:,:,is).*readdatavalue([PATH_PREFIX 'b2sral_sna1' is_string '.dat'],nx,ny);

            % momentum fluxes
%             fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
%             fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);

            % momentum sources           
%             smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smb' is_string '.dat'],nx,ny);
   
         end;
        
          fnax_mdf(:,:,m,is) = fnax(:,:,m,is);
          fnay_mdf(:,:,m,is) = fnay(:,:,m,is); 
       else   % read standard B2 output for charged particles
        
        % densities
          if exist([PATH_PREFIX{m} 'b2npc9_na' is_string '.dat'],'file') == 2
                na(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npc9_na' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          elseif exist([PATH_PREFIX{m} 'b2npco_na' is_string '.dat'],'file') == 2
                na(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npco_na' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          elseif exist([PATH_PREFIX{m} 'na' is_string '.dat'],'file') == 2
                na(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'na' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          end;
 
%         % fluxes
          fnax(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnbx' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnay(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnby' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
%         fnax(:,:,is)=readdatavalue([PATH_PREFIX 'fnax' is_string '.dat'],nx,ny);
%         fnay(:,:,is)=readdatavalue([PATH_PREFIX 'fnay' is_string '.dat'],nx,ny);
%         
          if exist([PATH_PREFIX{m} 'b2npc9_fnax' is_string '.dat'],'file') == 2
                fnax_mdf(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npc9_fnax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
                fnay_mdf(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npc9_fnay' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          else
                fnax_mdf(:,:,m,is)=fnax(:,:,m,is);
                fnay_mdf(:,:,m,is)=fnay(:,:,m,is);
          end;
          
% 
% 
%         % flux components
          fnax_Dgradn(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_dPat_mdf_gradnax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnay_Dgradn(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_dPat_mdf_gradnay' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnax_nuExB(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_vaecrbnax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnay_nuExB(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_vaecrbnay' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnax_PSch(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnbPSchx' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnay_PSch(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_fnbPSchy' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnax_dia(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_vadianax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          fnay_dia(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_vadianay' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          if exist([PATH_PREFIX{m} 'b2tfnb_cvlbnax' is_string '.dat'],'file') == 2
            fnax_nuAN(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_cvlbnax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          end;
          fnay_nuAN(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_cvlbnay' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
%         
%         fnax_uDPC(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_dpccornax' is_string '.dat'],nx,ny);
          fnay_nuAN(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2tfnb_bxuanax' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          
% 
%         % velocities
%         ux_ExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbecrbx' is_string '.dat'],nx,ny);
%         uy_ExB(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbecrby' is_string '.dat'],nx,ny);
%         ux_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbdiax' is_string '.dat'],nx,ny);
%         uy_dia(:,:,is)=readdatavalue([PATH_PREFIX 'b2tfnb_vbdiay' is_string '.dat'],nx,ny);
%         
%         % particle sources
          if exist([PATH_PREFIX{m} 'b2npc9_sna' is_string '.dat'],'file') == 2
                sna(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npc9_sna' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          elseif exist([PATH_PREFIX{m} 'b2npco_sna' is_string '.dat'],'file') == 2
                sna(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m} 'b2npco_sna' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          elseif exist([PATH_PREFIX{m} 'sna0' is_string '.dat'],'file') == 2
            sna(:,:,m,is)=readdatavalue_Nresults([PATH_PREFIX{m}  'sna0' is_string '.dat'],nx(m),ny(m),max(nx),max(ny)) + ...
                na(:,:,m,is).*readdatavalue_Nresults([PATH_PREFIX{m}  'sna1' is_string '.dat'],nx(m),ny(m),max(nx),max(ny));
          end;
%         sna_sral(:,:,is)=readdatavalue([PATH_PREFIX 'b2sral_sna0' is_string '.dat'],nx,ny)+na(:,:,is).*readdatavalue([PATH_PREFIX 'b2sral_sna1' is_string '.dat'],nx,ny);
%         if EIRENE_flag == 1 % read output from Eirene
%            sna_eir(:,:,is)=readdatavalue([PATH_PREFIX 'b2stbr_sna_eir' is_string '.dat'],nx,ny);
%         end;
%         
%         % momentum fluxes
%         fmox(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmox' is_string '.dat'],nx,ny);
%         fmoy(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_fmoy' is_string '.dat'],nx,ny);
%         
%         % momentum sources
%         smo(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smb' is_string '.dat'],nx,ny);
% 
%             
%         % momentum source components
%         smogp(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smogp' is_string '.dat'],nx,ny);
%         smotf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smotf' is_string '.dat'],nx,ny);
%         smocf(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smocf' is_string '.dat'],nx,ny);
%         smoch(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smoch' is_string '.dat'],nx,ny);
%         smovv(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovv' is_string '.dat'],nx,ny);
%         smovh(:,:,is)=readdatavalue([PATH_PREFIX 'b2npmo_smovh' is_string '.dat'],nx,ny);
%         smoii(:,:,is)=readdatavalue([PATH_PREFIX 'b2stcx_smq' is_string '.dat'],nx,ny)+ ...
%             readdatavalue([PATH_PREFIX 'b2stel_smq_ion' is_string '.dat'],nx,ny)+ ...
%             readdatavalue([PATH_PREFIX 'b2stel_smq_rec' is_string '.dat'],nx,ny);
%         smodt(:,:,is)=readdatavalue([PATH_PREFIX 'b2srdt_smodt' is_string '.dat'],nx,ny);
%         
%         if EIRENE_flag
%             smoat(:,:,2)=readdatavalue([PATH_PREFIX 'b2stbr_smo_eir' is_string '.dat'],nx,ny);
%         end;
       
       end;
       
       for j=1:nx(m)+2
          fhey_ExB(i,j,m)=fhey_ExB(i,j,m)+0.5*(te(i,j,m)+te(i-1,j,m))*fnay_nuExB(i,j,m,is);
          fhiy_ExB(i,j,m)=fhiy_ExB(i,j,m)+0.5*(ti(i,j,m)+ti(i-1,j,m))*fnay_nuExB(i,j,m,is);
        end;

    end;
 
    for i=2:ny(m)+2-1
       for j=2:nx(m)+2-1
       Ey_lk(i,j,m)=-(po(i+1,j,m)-po(i-1,j,m))/(hy(i,j,m)+0.5*(hy(i+1,j,m)+hy(i-1,j,m)));
       end;
    end;
        
    if exist([PATH_PREFIX{m} 'table_low_outer.dat']) == 2 ...
            fhe_low_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_outer.dat'],'',[1,6,ny(m)+1,6]);
            fhi_low_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_outer.dat'],'',[1,7,ny(m)+1,7]);
            fhtot_low_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_outer.dat'],'',[1,8,ny(m)+1,8]);
    end;

    if exist([PATH_PREFIX{m} 'table_low_inner.dat']) == 2 ...
            fhe_low_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_inner.dat'],'',[1,6,ny(m)+1,6]);
            fhi_low_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_inner.dat'],'',[1,7,ny(m)+1,7]);
            fhtot_low_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_low_inner.dat'],'',[1,8,ny(m)+1,8]);
    end;
    if exist([PATH_PREFIX{m} 'table_upper_outer.dat']) == 2 ...
            fhe_upper_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_outer.dat'],'',[1,6,ny(m)+1,6]);
            fhi_upper_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_outer.dat'],'',[1,7,ny(m)+1,7]);
            fhtot_upper_outer(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_outer.dat'],'',[1,8,ny(m)+1,8]);
    end;

    if exist([PATH_PREFIX{m} 'table_upper_inner.dat']) == 2 ...
            fhe_upper_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_inner.dat'],'',[1,6,ny(m)+1,6]);
            fhi_upper_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_inner.dat'],'',[1,7,ny(m)+1,7]);
            fhtot_upper_inner(1:ny(m)+1,m)=dlmread([PATH_PREFIX{m} 'table_upper_inner.dat'],'',[1,8,ny(m)+1,8]);
    end;
    
    for i=1:ny(m)+1
        fhx_tot(i+1,1,m)= 1.0e6*fhtot_low_inner(i,m)*hy(i+1,1,m)*hz(i+1,1,m);
        fhx_tot(i+1,nx(m)+2,m)=1.0e6*fhtot_low_outer(i,m)*hy(i+1,nx(m)+2,m)*hz(i+1,nx(m)+2,m);
        fhex_tot(i+1,1,m)= 1.0e6*fhtot_low_inner(i,m)*hy(i+1,1,m)*hz(i+1,1,m);
        fhex_tot(i+1,nx(m)+2,m)=1.0e6*fhtot_low_outer(i,m)*hy(i+1,nx(m)+2,m)*hz(i+1,nx(m)+2,m);
        fhix_tot(i+1,1,m)= 1.0e6*fhtot_low_inner(i,m)*hy(i+1,1,m)*hz(i+1,1,m);
        fhix_tot(i+1,nx(m)+2,m)=1.0e6*fhtot_low_outer(i,m)*hy(i+1,nx(m)+2,m)*hz(i+1,nx(m)+2,m);
        
        if nc3 ~= nc2 + 1
            fhx_tot(i+1,ntt(m)+2,m)= 1.0e6*fhtot_upper_inner(i,m)*hy(i+1,ntt(m)+2,m)*hz(i+1,ntt(m)+2,m);
            fhx_tot(i+1,ntt(m)+3,m)=1.0e6*fhtot_upper_outer(i,m)*hy(i+1,ntt(m)+3,m)*hz(i+1,ntt(m)+3,m);
            fhex_tot(i+1,ntt(m)+2,m)= 1.0e6*fhtot_upper_inner(i,m)*hy(i+1,ntt(m)+2,m)*hz(i+1,ntt(m)+2,m);
            fhex_tot(i+1,ntt(m)+3,m)=1.0e6*fhtot_upper_outer(i,m)*hy(i+1,ntt(m)+3,m)*hz(i+1,ntt(m)+3,m);
            fhix_tot(i+1,ntt(m)+2,m)= 1.0e6*fhtot_upper_inner(i,m)*hy(i+1,ntt(m)+2,m)*hz(i+1,ntt(m)+2,m);
            fhix_tot(i+1,ntt(m)+3,m)=1.0e6*fhtot_upper_outer(i,m)*hy(i+1,ntt(m)+3,m)*hz(i+1,ntt(m)+3,m);            
        end;
    end;

    for j=1:nx(m)+2
        fhiy_curr(i,j,m)=0.5*(ti(i,j,m)+ti(i-1,j,m))*(jy_AN(i,j,m)+jy_vispar(i,j,m)+jy_inert(i,j,m));           
    end;
    
    if EIRENE_flag
     

    
    end;
end;


cs=sqrt((te+ti)/(Amain*mp));
te=te/qe;
ti=ti/qe;

%Calculate electron density

for is=1:ns
     ne=ne+na(:,:,:,is)*Za(is);
%   ni(:,:)=ni(:,:)+na(:,:,is)*max(Za(is),0)/max(Za(is),1);
     ne2=ne2+na(:,:,:,is)*Za(is)*Za(is);
%     nas=nas+na(:,:,:,is);
%     nasm=nasm+na(:,:,:,is)*Am(is);
     pa(:,:,:,is)=(Za(is)*te+ti).*na(:,:,:,is)*qe;
     pa_dyn(:,:,:,is)=0.5*Am(is)*ua(:,:,:,is).*ua(:,:,:,is).*na(:,:,:,is)*mp;
     pas=pas+pa(:,:,:,is);
     pas_fullHD=pa(:,:,:,is)+pa_dyn(:,:,:,is)+pas_fullHD;
     if Za(is) == 0
         pNeut = pNeut + na(:,:,:,is).*ti*qe;
     end;
end;

% Ion saturation current 
jsat=abs(Bx)./B.*na(:,:,:,2)*qe.*cs;


ne_core=0.0;
%Mach number
for m=1:Nresults
    ne_core = ne(1,nout(m),m);
    ne_norm(:,:,m)=ne(:,:,m)./ne_core;
    
    if exist([PATH_PREFIX{m} 'Zeff.dat'],'file') == 2
        Zeff(:,:,m) = readdatavalue_Nresults([PATH_PREFIX{m} 'Zeff.dat'],nx(m),ny(m),max(nx),max(ny));
    else
        Zeff(:,:,m)=ne2(:,:,m)./ne(:,:,m);
    end;

    
% total deuterium density on B2 mesh
    if EIRENE_flag        
        nD_tot(:,:,m)=na(:,:,m,is_D01)+na(:,:,m,is_D01-1)+nD2(:,:,m);
    else
        nD_tot(:,:,m)=na(:,:,m,is_D01)+na(:,:,m,is_D01-1);
    end;
%-------------------------------------------
% total helium fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
if exist('is_He01','var')
    fnax_He_ch(:,:,m)     = fnax(:,:,m,is_He01)+fnax(:,:,m,is_He02);
    fnay_He_ch(:,:,m)     = fnay(:,:,m,is_He01)+fnay(:,:,m,is_He02);
    fnax_mdf_He_ch(:,:,m) = fnax_mdf(:,:,m,is_He01)+fnax_mdf(:,:,m,is_He02);
    fnay_mdf_He_ch(:,:,m) = fnay_mdf(:,:,m,is_He01)+fnay_mdf(:,:,m,is_He02);
    
    fnax_PSch_He_ch(:,:,m) = fnax_PSch(:,:,m,is_He01)+fnax_PSch(:,:,m,is_He02);
    fnay_PSch_He_ch(:,:,m) = fnay_PSch(:,:,m,is_He01)+fnay_PSch(:,:,m,is_He02);


    fnax_He_all(:,:,m) = fnax_He_ch(:,:,m) + fnax(:,:,m,is_He01-1);
    fnay_He_all(:,:,m) = fnay_He_ch(:,:,m) + fnay(:,:,m,is_He01-1);
    fnax_mdf_He_all(:,:,m) = fnax_mdf_He_ch(:,:,m) + fnax_mdf(:,:,m,is_He01-1);
    fnay_mdf_He_all(:,:,m) = fnay_mdf_He_ch(:,:,m) + fnay_mdf(:,:,m,is_He01-1);
    
    nHe_ch(:,:,m) = na(:,:,m,is_He01)+na(:,:,m,is_He02);
    nHe_tot(:,:,m) = nHe_ch(:,:,m)+na(:,:,m,is_He01-1);
    uaHe_ch_avr(:,:,m) = (ua(:,:,m,is_He01).*na(:,:,m,is_He01)+ua(:,:,m,is_He02).*na(:,:,m,is_He02))./nHe_ch(:,:,m);

end;

%-------------------------------------------
% total carbon densities - sum over ALL states and sum over CHARGED states
% total carbon fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
    if exist('is_C01','var')
       fnax_C_ch(:,:,m)     = fnax(:,:,m,is_C01)+fnax(:,:,m,is_C02)+fnax(:,:,m,is_C03)+fnax(:,:,m,is_C04)+fnax(:,:,m,is_C05)+fnax(:,:,m,is_C06);
       fnay_C_ch(:,:,m)     = fnay(:,:,m,is_C01)+fnay(:,:,m,is_C02)+fnay(:,:,m,is_C03)+fnay(:,:,m,is_C04)+fnay(:,:,m,is_C05)+fnay(:,:,m,is_C06);
       fnax_mdf_C_ch(:,:,m) = fnax_mdf(:,:,m,is_C01)+fnax_mdf(:,:,m,is_C02)+fnax_mdf(:,:,m,is_C03)+fnax_mdf(:,:,m,is_C04)+fnax_mdf(:,:,m,is_C05)+fnax_mdf(:,:,m,is_C06);
       fnay_mdf_C_ch(:,:,m) = fnay_mdf(:,:,m,is_C01)+fnay_mdf(:,:,m,is_C02)+fnay_mdf(:,:,m,is_C03)+fnay_mdf(:,:,m,is_C04)+fnay_mdf(:,:,m,is_C05)+fnay_mdf(:,:,m,is_C06);
    
       fnax_C_all(:,:,m) = fnax_C_ch(:,:,m) + fnax(:,:,m,is_C01-1);
       fnay_C_all(:,:,m) = fnay_C_ch(:,:,m) + fnay(:,:,m,is_C01-1);
       fnax_mdf_C_all(:,:,m) = fnax_mdf_C_ch(:,:,m) + fnax_mdf(:,:,m,is_C01-1);
       fnay_mdf_C_all(:,:,m) = fnay_mdf_C_ch(:,:,m) + fnay_mdf(:,:,m,is_C01-1);
    
       fnax_PSch_C_ch(:,:,m) = fnax_PSch(:,:,m,is_C01)+fnax_PSch(:,:,m,is_C02)+fnax_PSch(:,:,m,is_C03)+fnax_PSch(:,:,m,is_C04)+fnax_PSch(:,:,m,is_C05)+fnax_PSch(:,:,m,is_C06);
       fnay_PSch_C_ch(:,:,m) = fnay_PSch(:,:,m,is_C01)+fnay_PSch(:,:,m,is_C02)+fnay_PSch(:,:,m,is_C03)+fnay_PSch(:,:,m,is_C04)+fnay_PSch(:,:,m,is_C05)+fnay_PSch(:,:,m,is_C06);

       nC_ch(:,:,m) = na(:,:,m,is_C01)+na(:,:,m,is_C02)+na(:,:,m,is_C03)+na(:,:,m,is_C04)+na(:,:,m,is_C05)+na(:,:,m,is_C06);
       nC_tot(:,:,m) = nC_ch(:,:,m)+na(:,:,m,is_C01-1);
       uaC_ch_avr(:,:,m) = (ua(:,:,m,is_C01).*na(:,:,m,is_C01)+ua(:,:,m,is_C02).*na(:,:,m,is_C02)+ua(:,:,m,is_C03).*na(:,:,m,is_C03)+...
           ua(:,:,m,is_C04).*na(:,:,m,is_C04)+ua(:,:,m,is_C05).*na(:,:,m,is_C05)+ua(:,:,m,is_C06).*na(:,:,m,is_C06))./nC_ch(:,:,m);
    end;

%-------------------------------------------
% total nitrogen fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
    if exist('is_N01','var')
       fnax_N_ch(:,:,m)     = fnax(:,:,m,is_N01)+fnax(:,:,m,is_N02)+fnax(:,:,m,is_N03)+fnax(:,:,m,is_N04)+fnax(:,:,m,is_N05)+fnax(:,:,m,is_N06)+fnax(:,:,m,is_N07);
       fnay_N_ch(:,:,m)     = fnay(:,:,m,is_N01)+fnay(:,:,m,is_N02)+fnay(:,:,m,is_N03)+fnay(:,:,m,is_N04)+fnay(:,:,m,is_N05)+fnay(:,:,m,is_N06)+fnay(:,:,m,is_N07);
       fnax_mdf_N_ch(:,:,m) = fnax_mdf(:,:,m,is_N01)+fnax_mdf(:,:,m,is_N02)+fnax_mdf(:,:,m,is_N03)+fnax_mdf(:,:,m,is_N04)+fnax_mdf(:,:,m,is_N05)+fnax_mdf(:,:,m,is_N06)+fnax_mdf(:,:,m,is_N07);
       fnay_mdf_N_ch(:,:,m) = fnay_mdf(:,:,m,is_N01)+fnay_mdf(:,:,m,is_N02)+fnay_mdf(:,:,m,is_N03)+fnay_mdf(:,:,m,is_N04)+fnay_mdf(:,:,m,is_N05)+fnay_mdf(:,:,m,is_N06)+fnay_mdf(:,:,m,is_N07);
    
       fnax_PSch_N_ch(:,:,m) = fnax_PSch(:,:,m,is_N01)+fnax_PSch(:,:,m,is_N02)+fnax_PSch(:,:,m,is_N03)+fnax_PSch(:,:,m,is_N04)+fnax_PSch(:,:,m,is_N05)+fnax_PSch(:,:,m,is_N06)+fnax_PSch(:,:,m,is_N07);
       fnay_PSch_N_ch(:,:,m) = fnay_PSch(:,:,m,is_N01)+fnay_PSch(:,:,m,is_N02)+fnay_PSch(:,:,m,is_N03)+fnay_PSch(:,:,m,is_N04)+fnay_PSch(:,:,m,is_N05)+fnay_PSch(:,:,m,is_N06)+fnay_PSch(:,:,m,is_N07);

       fnax_N_all(:,:,m) = fnax_N_ch(:,:,m) + fnax(:,:,m,is_N01-1);
       fnay_N_all(:,:,m) = fnay_N_ch(:,:,m) + fnay(:,:,m,is_N01-1);
       fnax_mdf_N_all(:,:,m) = fnax_mdf_N_ch(:,:,m) + fnax_mdf(:,:,m,is_N01-1);
       fnay_mdf_N_all(:,:,m) = fnay_mdf_N_ch(:,:,m) + fnay_mdf(:,:,m,is_N01-1);
    
       nN_ch(:,:,m) = na(:,:,m,is_N01)+na(:,:,m,is_N02)+na(:,:,m,is_N03)+na(:,:,m,is_N04)+na(:,:,m,is_N05)+na(:,:,m,is_N06)+na(:,:,m,is_N07);
       nN_tot(:,:,m) = nN_ch(:,:,m)+na(:,:,m,is_N01-1);
       uaN_ch_avr(:,:,m) = (ua(:,:,m,is_N01).*na(:,:,m,is_N01)+ua(:,:,m,is_N02).*na(:,:,m,is_N02)+ua(:,:,m,is_N03).*na(:,:,m,is_N03)+...
           ua(:,:,m,is_N04).*na(:,:,m,is_N04)+ua(:,:,m,is_N05).*na(:,:,m,is_N05)+ua(:,:,m,is_N06).*na(:,:,m,is_N06)+ua(:,:,m,is_N07).*na(:,:,m,is_N07))./nN_ch(:,:,m);

     end;

%-------------------------------------------
% total neon fluxes - sum over ALL states and sum over CHARGED states
%-------------------------------------------
    if exist('is_Ne01','var')
       fnax_Ne_ch(:,:,m)     = fnax(:,:,m,is_Ne01)+fnax(:,:,m,is_Ne02)+fnax(:,:,m,is_Ne03)+fnax(:,:,m,is_Ne04)+fnax(:,:,m,is_Ne05)+fnax(:,:,m,is_Ne06)+fnax(:,:,m,is_Ne07)+fnax(:,:,m,is_Ne08)+fnax(:,:,m,is_Ne09)+fnax(:,:,m,is_Ne10);
       fnay_Ne_ch(:,:,m)     = fnay(:,:,m,is_Ne01)+fnay(:,:,m,is_Ne02)+fnay(:,:,m,is_Ne03)+fnay(:,:,m,is_Ne04)+fnay(:,:,m,is_Ne05)+fnay(:,:,m,is_Ne06)+fnay(:,:,m,is_Ne07)+fnay(:,:,m,is_Ne08)+fnay(:,:,m,is_Ne09)+fnay(:,:,m,is_Ne10);
       fnax_mdf_Ne_ch(:,:,m) = fnax_mdf(:,:,m,is_Ne01)+fnax_mdf(:,:,m,is_Ne02)+fnax_mdf(:,:,m,is_Ne03)+fnax_mdf(:,:,m,is_Ne04)+fnax_mdf(:,:,m,is_Ne05)+fnax_mdf(:,:,m,is_Ne06)+fnax_mdf(:,:,m,is_Ne07)+fnax_mdf(:,:,m,is_Ne08)+fnax_mdf(:,:,m,is_Ne09)+fnax_mdf(:,:,m,is_Ne10);
       fnay_mdf_Ne_ch(:,:,m) = fnay_mdf(:,:,m,is_Ne01)+fnay_mdf(:,:,m,is_Ne02)+fnay_mdf(:,:,m,is_Ne03)+fnay_mdf(:,:,m,is_Ne04)+fnay_mdf(:,:,m,is_Ne05)+fnay_mdf(:,:,m,is_Ne06)+fnay_mdf(:,:,m,is_Ne07)+fnay_mdf(:,:,m,is_Ne08)+fnay_mdf(:,:,m,is_Ne09)+fnay_mdf(:,:,m,is_Ne10);
    
       fnax_PSch_Ne_ch(:,:,m) = fnax_PSch(:,:,m,is_Ne01)+fnax_PSch(:,:,m,is_Ne02)+fnax_PSch(:,:,m,is_Ne03)+fnax_PSch(:,:,m,is_Ne04)+fnax_PSch(:,:,m,is_Ne05)+fnax_PSch(:,:,m,is_Ne06)+fnax_PSch(:,:,m,is_Ne07)+fnax_PSch(:,:,m,is_Ne08)+fnax_PSch(:,:,m,is_Ne09)+fnax_PSch(:,:,m,is_Ne10);
       fnay_PSch_Ne_ch(:,:,m) = fnay_PSch(:,:,m,is_Ne01)+fnay_PSch(:,:,m,is_Ne02)+fnay_PSch(:,:,m,is_Ne03)+fnay_PSch(:,:,m,is_Ne04)+fnay_PSch(:,:,m,is_Ne05)+fnay_PSch(:,:,m,is_Ne06)+fnay_PSch(:,:,m,is_Ne07)+fnay_PSch(:,:,m,is_Ne08)+fnay_PSch(:,:,m,is_Ne09)+fnay_PSch(:,:,m,is_Ne10);

       fnax_Ne_all(:,:,m) = fnax_Ne_ch(:,:,m) + fnax(:,:,m,is_Ne01-1);
       fnay_Ne_all(:,:,m) = fnay_Ne_ch(:,:,m) + fnay(:,:,m,is_Ne01-1);
       fnax_mdf_Ne_all(:,:,m) = fnax_mdf_Ne_ch(:,:,m) + fnax_mdf(:,:,m,is_Ne01-1);
       fnay_mdf_Ne_all(:,:,m) = fnay_mdf_Ne_ch(:,:,m) + fnay_mdf(:,:,m,is_Ne01-1);
    
       nNe_ch(:,:,m) = na(:,:,m,is_Ne01)+na(:,:,m,is_Ne02)+na(:,:,m,is_Ne03)+na(:,:,m,is_Ne04)+na(:,:,m,is_Ne05)+na(:,:,m,is_Ne06)+na(:,:,m,is_Ne07)+na(:,:,m,is_Ne08)+na(:,:,m,is_Ne09)+na(:,:,m,is_Ne10);
       nNe_tot(:,:,m) = nNe_ch(:,:,m)+na(:,:,m,is_Ne01-1);
       uaNe_ch_avr(:,:,m) = (ua(:,:,m,is_Ne01).*na(:,:,m,is_Ne01)+ua(:,:,m,is_Ne02).*na(:,:,m,is_Ne02))./nNe_ch(:,:,m);
    end;
end;

set(0,'DefaultFigureWindowStyle','normal')
set(0,'DefaultFigureWindowStyle','docked')
%format compact


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron density
if exp_data_flag && exist('N_ne_midpl','var')
    R_plot_Nresults(y2,ne,nx,ny,Nresults,nout,'Electron density at outer midplane','$n_{e}, \; m^{-3}$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_ne_midpl,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_ne_midpl
        plot(exp_data_ne_midpl(:,2*i-1),exp_data_ne_midpl(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_ne_midpl{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_ne_midpl},'location','NorthEast');   
else
    R_plot_Nresults(y2,ne,nx,ny,Nresults,nout,'Electron density at outer midplane','$n_{e}, \; m^{-3}$',label,0);
end;
% % % R_ne_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/ne_exp.txt','',[1 0 19 0]);
% % % ne_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/ne_exp.txt','',[1 1 19 1]);
% % % plot(R_ne_exp_midpl,ne_exp_midpl,'--','LineWidth',2,'Color',[0,0,0]);
% % % legend(label{1:Nresults},'{n_e}_{EXP}','location','best');
set(gcf,'PaperPositionMode','auto')
Figname = 'ne_midpl_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%stop;

R_plot_Nresults(y2,ne_norm,nx,ny,Nresults,nout,'Normalized electron density at outer midplane','$n_{e}\; n_{e\:CORE}$',label,0);
hold all;
set(gcf,'PaperPositionMode','auto')
Figname = 'ne_norm';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion density
R_plot_Nresults(y2,na(:,:,:,2),nx,ny,Nresults,nout,'Main ion density at outer midplane','$n_{i}, \; m^{-3}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'na_main';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot Zeff
R_plot_Nresults(y2,Zeff,nx,ny,Nresults,nout,'Zeff at outer midplane','$Z_{eff}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Zeff_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
R_plot_Nresults(y2,Zeff,nx,ny,Nresults,nin,'Zeff at inner midplane','$Z_{eff}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Zeff_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron temperature
if exp_data_flag && exist('N_Te_midpl','var')
    R_plot_Nresults(y2,te,nx,ny,Nresults,nout,'Electron temperature at outer midplane','$T_{e}, \; eV$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_Te_midpl,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Te_midpl
        plot(exp_data_Te_midpl(:,2*i-1),exp_data_Te_midpl(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_Te_midpl{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Te_midpl},'location','NorthEast');   
else
     R_plot_Nresults(y2,te,nx,ny,Nresults,nout,'Electron temperature at outer midplane','$T_{e}, \; eV$',label,0);
end;
% % % R_te_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/te_exp.txt','',[1 0 19 0]);
% % % te_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/te_exp.txt','',[1 1 19 1]);
% % % plot(R_te_exp_midpl,te_exp_midpl,'--','LineWidth',2,'Color',[0,0,0]);
% % % legend(label{1:Nresults},'{T_e}_{EXP}','location','best');
set(gcf,'PaperPositionMode','auto')
Figname = 'Te_midpl_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion temperature
if exp_data_flag && exist('N_Te_midpl','var')
    R_plot_Nresults(y2,ti,nx,ny,Nresults,nout,'Ion temperature at outer midplane','$T_{i}, \; m^{-3}$',label,0);
    hold all;
    v = axis;
    legend_label=cell(N_Ti_midpl,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Ti_midpl
        plot(exp_data_Ti_midpl(:,2*i-1),exp_data_Ti_midpl(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_Ti_midpl{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Ti_midpl},'location','NorthEast');   
else
    R_plot_Nresults(y2,ti,nx,ny,Nresults,nout,'Ion temperature at outer midplane','$T_{i}, \; eV$',label,0);
end;    
% % % R_ti_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/ti_exp.txt','',[1 0 19 0]);
% % % ti_exp_midpl=dlmread('~/B2SOLPS/Chankin_experimental_data/ti_exp.txt','',[1 1 19 1]);
% % % plot(R_ti_exp_midpl,ti_exp_midpl,'--','LineWidth',2,'Color',[0,0,0]);
% % % legend(label{1:Nresults},'{T_i}_{EXP}','location','best');
set(gcf,'PaperPositionMode','auto')
Figname = 'Ti_midpl_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion velocity
R_plot_Nresults(y2,ua(:,:,:,2),nx,ny,Nresults,nout,'Ion parallel velocity at outer midplane','$u_{||}, \; m/s$',label,0);
hold all;
set(gcf,'PaperPositionMode','auto')
%print('-depsc2','-r600',[Figure_Store_PATH,'ua01.eps']);
%print('-dpng','-r600',[Figure_Store_PATH,'Ti.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot radial electric field
R_plot_Nresults(y2,Ey_lk,nx,ny,Nresults,nout,'Radial electric field (by LK) at outer midplane','$E_y,  V/m$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Ey_LK';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

R_plot_Nresults(y2,Ey_iyv,nx,ny,Nresults,nout,'Radial electric field (by IYV) at outer midplane','$E_y,  V/m$',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Ey_IYV.eps']);




% Flux01mdf_in=zeros(max(nsep)+2,Nresults);
% Flux03mdf_in=zeros(max(nsep)+2,Nresults);
% Flux04mdf_in=zeros(max(nsep)+2,Nresults);
% Flux05mdf_in=zeros(max(nsep)+2,Nresults);
% Flux06mdf_in=zeros(max(nsep)+2,Nresults);
% Flux07mdf_in=zeros(max(nsep)+2,Nresults);
% Flux08mdf_in=zeros(max(nsep)+2,Nresults);
% Flux10mdf_in=zeros(max(nsep)+2,Nresults);
% Flux11mdf_in=zeros(max(nsep)+2,Nresults);
% 
% Flux01vecb_in=zeros(max(nsep)+2,Nresults);
% Flux01diff_in=zeros(max(nsep)+2,Nresults);
% 
% 
% Fhe_mdfY=zeros(max(nsep)+2,Nresults);
% Fhe_mdfY_plusExB=zeros(max(nsep)+2,Nresults);
% Fhi_mdfY=zeros(max(nsep)+2,Nresults);
% Fhi_mdfY_plusExB=zeros(max(nsep)+2,Nresults);
% Fhi_NEOY=zeros(max(nsep)+2,Nresults);
% Fhi_PSchY=zeros(max(nsep)+2,Nresults);



for m=1:Nresults
     
    for i=-1:nsep(m)+1
        for is=1:ns
             Fnay_mdf_in(i+2,m,is) = poloidal_int_core_DND(fnay_mdf(:,:,m,is),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
             Fnay_nuExB_in(i+2,m,is) = poloidal_int_core_DND(fnay_nuExB(:,:,m,is),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
             Fnay_Dgradn_in(i+2,m,is) = poloidal_int_core_DND(fnay_Dgradn(:,:,m,is),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        end;

        Fhey_mdf(i+2,m)=poloidal_int_core_DND(fhey_mdf(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        Fhey_mdf_plusExB(i+2,m)=poloidal_int_core_DND(fhey_mdf(:,:,m)+fhey_ExB(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        Fhiy_mdf(i+2,m)=poloidal_int_core_DND(fhiy_mdf(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        Fhiy_mdf_plusExB(i+2,m)=poloidal_int_core_DND(fhiy_mdf(:,:,m)+fhiy_ExB(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        Fhiy_NEO(i+2,m)=poloidal_int_core_DND(-fhiy_PSch(:,:,m)+5/2*fhiy_ExB(:,:,m)+5/2*fhiy_curr(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        
        if exist('is_He01','var')
            Fnay_He_ch(i+2,m)=poloidal_int_core_DND(fnay_He_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_He_ch(i+2,m)=poloidal_int_core_DND(fnay_mdf_He_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_He_all(i+2,m)=poloidal_int_core_DND(fnay_He_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_He_all(i+2,m)=poloidal_int_core_DND(fnay_mdf_He_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        end;
        if exist('is_C01','var')
            Fnay_C_ch(i+2,m)=poloidal_int_core_DND(fnay_C_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_C_ch(i+2,m)=poloidal_int_core_DND(fnay_mdf_C_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_C_all(i+2,m)=poloidal_int_core_DND(fnay_C_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_C_all(i+2,m)=poloidal_int_core_DND(fnay_mdf_C_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        end;
        if exist('is_N01','var')
            Fnay_N_ch(i+2,m)=poloidal_int_core_DND(fnay_N_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_N_ch(i+2,m)=poloidal_int_core_DND(fnay_mdf_N_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_N_all(i+2,m)=poloidal_int_core_DND(fnay_N_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_N_all(i+2,m)=poloidal_int_core_DND(fnay_mdf_N_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        end;
        if exist('is_Ne01','var')
            Fnay_Ne_ch(i+2,m)=poloidal_int_core_DND(fnay_Ne_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_Ne_ch(i+2,m)=poloidal_int_core_DND(fnay_mdf_Ne_ch(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_Ne_all(i+2,m)=poloidal_int_core_DND(fnay_Ne_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
            Fnay_mdf_Ne_all(i+2,m)=poloidal_int_core_DND(fnay_mdf_Ne_all(:,:,m),nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),i);
        end;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion flux
R_plot_1Darray_Nresults(y2,Fnay_mdf_in(:,:,2),Nresults,nsep,nout,'Main ion flux','${\Gamma_i01}_{tot},  s^{-1}$',label);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Gamma_i01.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main diffusive flux
R_plot_1Darray_Nresults(y2,Fnay_Dgradn_in(:,:,2),Nresults,nsep,nout,'Main ion diffusive flux','${\Gamma_i01}_{diff},  s^{-1}$',label);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Gamma_i01_diff.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion ExB flux
R_plot_1Darray_Nresults(y2,Fnay_nuExB_in(:,:,2),Nresults,nsep,nout,'Main ion ExB flux','${\Gamma_i01}_{ExB},  s^{-1}$',label);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Gamma_i01_ExB.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux in electron channel
R_plot_1Darray_Nresults(y2,Fhey_mdf_plusExB,Nresults,nsep,nout,'Electron heat flux','${Q_e}_{tot},  W$',label);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Qe.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux in ion channel
R_plot_1Darray_Nresults(y2,Fhiy_mdf_plusExB,Nresults,nsep,nout,'Ion heat flux','${Q_i}_{tot},  W$',label);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Qi.eps']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot neoclassical ion heat flux
set(gcf,'PaperPositionMode','auto')
R_plot_1Darray_Nresults(y2,Fhiy_NEO,Nresults,nsep,nout,'Neoclassical ion heat flux','${Q_i}_{NEO},  W$',label);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density and its integrated flux
if exist('is_He01','var')
    % at outer midplane
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nout,'Total helium density at outer midplane','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHe_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at LFS (core and SOL)
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nc4,'Total helium density at X point, LFS, SOL side','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHe_Xpnt_out_SOL_side.eps']);
    % just below the X-point at LFS (PFR and SOL)
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nc4+1,'Total helium density at X point, LFS, divertor side','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHe_Xpnt_out_div_side.eps']);
    % at inner midplane
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nin,'Total helium density at inner midplane','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHe_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at HFS (core and SOL)
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nc1,'Total helium density at X point, HFS, SOL side','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHe_Xpnt_in_SOL_side.eps']);
    % just below the X-point at HFS (PFR and SOL)
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nc1-1,'Total helium density at X point, HFS, divertor side','$n_{\rm He}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHe_Xpnt_in_div_side.eps']);
    % net flux through the closed flux surface in the core
    R_plot_1Darray_Nresults(y2,Fnay_mdf_He_ch,Nresults,nsep,nout,'Total helium flux (charged state)','$\Gamma_{\rm He}, s^{-1}$',label);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'Gamma_He';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

if exist('is_C01','var')
    % at outer midplane
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nout,'Total carbon density at outer midplane','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at LFS (core and SOL)
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nc4,'Total carbon density at X point, LFS, SOL side','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nC_Xpnt_out_SOL_side.eps']);
    % just below the X-point at LFS (PFR and SOL)
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nc4+1,'Total carbon density at X point, LFS, divertor side','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nC_Xpnt_out_div_side.eps']);
    % at innter midplane
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nin,'Total carbon density at inner midplane','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at HFS (core and SOL)
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nc1,'Total carbon density at X point, HFS, SOL side','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nC_Xpnt_in_SOL_side.eps']);
    % just below the X-point at HFS (PFR and SOL)
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nc1-1,'Total carbon density at X point, HFS, divertor side','$n_{\rm C}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nC_Xpnt_in_div_side.eps']);
    % net flux through the closed flux surface in the core
    R_plot_1Darray_Nresults(y2,Fnay_mdf_C_ch,Nresults,nsep,nout,'Total carbon flux (charged state)','$\Gamma_{\rm C}, s^{-1}$',label);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'Gamma_C';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

if exist('is_N01','var')
    % at outer midplane
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nout,'Total nitrogen density at outer midplane','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at LFS (core and SOL)
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nc4,'Total nitrogen density at X point, LFS, SOL side','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nN_Xpnt_out_SOL_side.eps']);
    % just below the X-point at LFS (PFR and SOL)
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nc4+1,'Total nitrogen density at X point, LFS, divertor side','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nN_Xpnt_out_div_side.eps']);
    % at innter midplane
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nin,'Total nitrogen density at inner midplane','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at HFS (core and SOL)
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nc1,'Total nitrogen density at X point, HFS, SOL side','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nN_Xpnt_in_SOL_side.eps']);
    % just below the X-point at HFS (PFR and SOL)
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nc1-1,'Total nitrogen density at X point, HFS, divertor side','$n_{\rm N}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nN_Xpnt_in_div_side.eps']);
    % net flux through the closed flux surface in the core
    R_plot_1Darray_Nresults(y2,Fnay_mdf_N_ch,Nresults,nsep,nout,'Total nitrogen flux (charged state)','$\Gamma_{\rm N}, s^{-1}$',label);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'Gamma_N';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

if exist('is_Ne01','var')
    % at outer midplane
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nout,'Total neon density at outer midplane','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at LFS (core and SOL)
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nc4,'Total neon density at X point, LFS, SOL side','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNe_Xpnt_out_SOL_side.eps']);
    % just below the X-point at LFS (PFR and SOL)
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nc4+1,'Total neon density at X point, LFS, divertor side','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNe_Xpnt_out_div_side.eps']);
    % at inner midplane
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nin,'Total neon density at inner midplane','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    % just above the X-point at HFS (core and SOL)
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nc1,'Total neon density at X point, HFS, SOL side','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNe_Xpnt_in_SOL_side.eps']);
    % just below the X-point at HFS (PFR and SOL)
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nc1-1,'Total neon density at X point, HFS, divertor side','$n_{\rm Ne}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNe_Xpnt_in_div_side.eps']);
    % net flux through the closed flux surface in the core
    R_plot_1Darray_Nresults(y2,Fnay_mdf_Ne_ch,Nresults,nsep,nout,'Total neon flux (charged state)','$\Gamma_{\rm Ne}, s^{-1}$',label);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'Gamma_Ne';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;



%for inner target


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron density at inner target
if exp_data_flag && exist('N_ne_inner_bottom','var')
    R_plot_Nresults(y2,ne,nx,ny,Nresults,npl,'Electron density at inner target','$n_e, \; m^{-3}$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_ne_inner_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_ne_inner_bottom
        plot(exp_data_ne_inner_bottom(:,2*i-1),exp_data_ne_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_ne_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_ne_inner_bottom},'location','best');   
else
    R_plot_Nresults(y2,ne,nx,ny,Nresults,npl,'Electron density at inner target','$n_e, \; m^{-3}$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'ne_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron temperature at inner target
if exp_data_flag && exist('N_Te_inner_bottom','var')
    R_plot_Nresults(y2,te,nx,ny,Nresults,npl,'Electron temperature at inner target','$T_e, \; eV$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_Te_inner_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Te_inner_bottom
        plot(exp_data_Te_inner_bottom(:,2*i-1),exp_data_Te_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_Te_inner_bottom{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Te_inner_bottom},'location','best');   
else
    R_plot_Nresults(y2,te,nx,ny,Nresults,npl,'Electron temperature at inner target','$T_e, \; eV$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'Te_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion temperature at inner target
R_plot_Nresults(y2,ti,nx,ny,Nresults,npl,'Ion temperature at inner target','$T_i, \; eV$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Ti_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion saturation current density at inner target
if exp_data_flag && exist('N_jsat_inner_bottom','var')
    R_plot_Nresults(y2,jsat,nx,ny,Nresults,npl,'Ion saturation current at inner target','$j_{sat}, \; A/m^2$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_jsat_inner_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_jsat_inner_bottom
        plot(exp_data_jsat_inner_bottom(:,2*i-1),exp_data_jsat_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jsat_inner_bottom{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_jsat_inner_bottom},'location','best');   
else
    R_plot_Nresults(y2,jsat,nx,ny,Nresults,npl,'Ion saturation current at inner target','$j_{sat}, \; A/m^2$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'jsat_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot potential at inner target
R_plot_Nresults(y2,po,nx,ny,Nresults,npl_flux,'Potential at inner target','$\varphi, \; V$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'po_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot Mach number for main ions at outer target
R_plot_Nresults(y2,ua(:,:,:,2)./cs,nx,ny,Nresults,nx,'Mach number at inner target, D^+','$M$',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[PATH_PREFIX{1},'../../','Mach_in.eps']);
%print('-dpng','-r600',[PATH_PREFIX{1},'../../','Mach_in.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot net current density at inner target
if exp_data_flag && exist('N_jx_inner_bottom','var')
    R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,npl_flux,'Net current density at inner target','$j_{\perp}, \; A/m^2$',label,0);
    hold all;
    v = axis;
    legend_label=cell(N_jx_inner_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_jx_inner_bottom
        plot(exp_data_jx_inner_bottom(:,2*i-1),exp_data_jx_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jx_inner_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_jx_inner_bottom},'location','best');   
else
    R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,npl_flux,'Net current density at inner target','$j_{\perp}, \; A/m^2$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'jx_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%for heat fluxes to inner target
%npl = [0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux density in electron channel at inner target
%R_plot_Nresults(y2,fhetotX./hy./hz,nx,ny,Nresults,npl,'Heat flux density in electron channel at inner target','$q_{e}, \; W/m^2$',label,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux density in ion channel at inner target
%R_plot_Nresults(y2,fhitotX./hy./hz,nx,ny,Nresults,npl,'Heat flux density in ion channel at inner target','$q_{i}, \; W/m^2$',label,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion flux density at inner target
R_plot_Nresults(y2,-(fnax_mdf(:,:,:,2)+fnax_PSch(:,:,:,2))./hz./hy,nx,ny,Nresults,npl_flux,'Main ion particle flux density at inner target','$\Gamma_{D^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_D_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot helium flux density at inner target (sum over charged states)
if exist('is_He01','var')
    R_plot_Nresults(y2,-(fnax_He_ch+fnax_PSch_He_ch)./hz./hy,nx,ny,Nresults,npl_flux,'Helium particle flux density at inner target','$\Gamma_{He^{(ch)}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_He_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot carbon flux density at inner target (sum over charged states)
if exist('is_C01','var')
    R_plot_Nresults(y2,-(fnax_C_ch+fnax_PSch_C_ch)./hz./hy,nx,ny,Nresults,npl_flux,'Carbon particle flux density at inner target','$\Gamma_{C^{(ch)}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_C_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot nitrogen flux density at inner target (sum over charged states)
if exist('is_N01','var')
    R_plot_Nresults(y2,-(fnax_N_ch+fnax_PSch_N_ch)./hz./hy,nx,ny,Nresults,npl_flux,'Nitrogen particle flux density at inner target','$\Gamma_{N^{(ch)}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_N_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot neon flux density at inner target (sum over charged states)
if exist('is_Ne01','var')
    R_plot_Nresults(y2,-(fnax_Ne_ch+fnax_PSch_Ne_ch)./hz./hy,nx,ny,Nresults,npl_flux,'Neon particle flux density at inner target','$\Gamma_{Ne^{(ch)}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_Ne_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot total heat flux density at inner target
if exp_data_flag && exist('N_fhtotX_inner_bottom','var')
    R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,npl,'Heat flux density at inner target','$q_{tot}, \; W/m^2$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_fhtotX_inner_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_fhtotX_inner_bottom
        plot(exp_data_fhtotX_inner_bottom(:,2*i-1),exp_data_fhtotX_inner_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_fhtotX_inner_bottom{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_fhtotX_inner_bottom},'location','best');   
else
    R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,npl,'Heat flux density at inner target','$q_{tot}, \; W/m^2$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'q_in';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot neutral pressure at inner target
R_plot_Nresults(y2,pNeut,nx,ny,Nresults,npl_flux,'Neutral pressure at inner target','$p_{N}, \; Pa$',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[PATH_PREFIX{1},'../../','pN_in.eps']);
%print('-dpng','-r600',[PATH_PREFIX{1},'../../','pN_in.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner target
if exist('is_He01','var')
    R_plot_Nresults(y2,na(:,:,:,is_He01),nx,ny,Nresults,npl_flux,'He{+1} density at inner target','$n_{\rm He^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHe01_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_He02),nx,ny,Nresults,npl_flux,'He{+2} density at inner target','$n_{\rm He^{+2}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHe02_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,npl_flux,'Total He density at inner target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHetot_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nHe_ch,nx,ny,Nresults,npl_flux,'He density (charged states) at inner target','$n_{ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHech_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner target
if exist('is_C01','var')
    R_plot_Nresults(y2,na(:,:,:,is_C01),nx,ny,Nresults,npl_flux,'C{+1} density at inner target','$n_{\rm C^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC01_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_C02),nx,ny,Nresults,npl_flux,'C{+2} density at inner target','$n_{\rm C^{+2}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC02_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_C03),nx,ny,Nresults,npl_flux,'C{+3} density at inner target','$n_{\rm C^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC03_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,npl_flux,'Total C density at inner target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nCtot_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nC_ch,nx,ny,Nresults,npl_flux,'C density (charged states) at inner target','$n_{ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nCch_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner target
if exist('is_N01','var')
    R_plot_Nresults(y2,na(:,:,:,is_N01),nx,ny,Nresults,npl_flux,'N{+1} density at inner target','$n_{\rm N^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN01_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_N02),nx,ny,Nresults,npl_flux,'N{+2} density at inner target','$n_{\rm N^{+2}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN02_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_N03),nx,ny,Nresults,npl_flux,'N{+3} density at inner target','$n_{\rm N^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN03_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,npl_flux,'Total N density at inner target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNtot_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nN_ch,nx,ny,Nresults,npl_flux,'N density (charged states) at inner target','$n_{ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNch_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner target
if exist('is_Ne01','var')
    R_plot_Nresults(y2,na(:,:,:,is_Ne01),nx,ny,Nresults,npl_flux,'Ne{+1} density at inner target','$n_{\rm Ne^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe01_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_Ne02),nx,ny,Nresults,npl_flux,'Ne{+2} density at inner target','$n_{\rm Ne^{+2}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe02_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_Ne03),nx,ny,Nresults,npl_flux,'Ne{+3} density at inner target','$n_{\rm Ne^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe03_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,npl_flux,'Total Ne density at inner target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNetot_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nNe_ch,nx,ny,Nresults,npl_flux,'Ne density (charged states) at inner target','$n_{ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNech_in';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;
    
%print('-dpng','-r600',[PATH_PREFIX{1},'../../','pN_in.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot extra target profiles for DND topology
if nc3~=nc2+1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron density at inner top target
   if exp_data_flag && exist('N_ne_inner_top','var')
    R_plot_Nresults(y2,ne,nx,ny,Nresults,ntt,'Electron density at inner top target','$n_e, \; m^{-3}$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_ne_inner_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_ne_inner_top
        plot(exp_data_ne_inner_top(:,2*i-1),exp_data_ne_inner_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_ne_inner_top{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_ne_inner_top},'location','best');   
   else
    R_plot_Nresults(y2,ne,nx,ny,Nresults,ntt,'Electron density at inner top target','$n_e, \; m^{-3}$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'ne_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron temperature at inner top target
   if exp_data_flag && exist('N_Te_inner_top','var')
    R_plot_Nresults(y2,te,nx,ny,Nresults,ntt,'Electron temperature at inner top target','$T_e, \; eV$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_Te_inner_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Te_inner_top
        plot(exp_data_Te_inner_top(:,2*i-1),exp_data_Te_inner_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_Te_inner_top{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Te_inner_top},'location','best');   
   else
    R_plot_Nresults(y2,te,nx,ny,Nresults,ntt,'Electron temperature at inner top target','$T_e, \; eV$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Te_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion temperature at inner top target
   R_plot_Nresults(y2,ti,nx,ny,Nresults,ntt,'Ion temperature at inner top target','$T_i, \; eV$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Ti_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion saturation current density at inner top target
   if exp_data_flag && exist('N_jsat_inner_top','var')
     R_plot_Nresults(y2,jsat,nx,ny,Nresults,ntt,'Ion saturation current at inner top target','$j_{sat}, \; A/m^2$',label,1);
     hold all;
     v = axis;
     legend_label=cell(N_jsat_inner_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_jsat_inner_top
        plot(exp_data_jsat_inner_top(:,2*i-1),exp_data_jsat_inner_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jsat_inner_top{i};
     end;
     v(3)=0.0;
%    axis(v);
     legend(label{1:Nresults},legend_label{1:N_jsat_inner_top},'location','best');   
   else
     R_plot_Nresults(y2,jsat,nx,ny,Nresults,ntt,'Ion saturation current at inner top target','$j_{sat}, \; A/m^2$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'jsat_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot net current density at inner top target
   if exp_data_flag && exist('N_jx_inner_top','var')
     R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,ntt,'Net current density at inner target','$j_{\perp}, \; A/m^2$',label,0);
     hold all;
     v = axis;
     legend_label=cell(N_jx_inner_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_jx_inner_top
        plot(exp_data_jx_inner_top(:,2*i-1),exp_data_jx_inner_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jx_inner_top{i};
     end;
     v(3)=0.0;
     axis(v);
     legend(label{1:Nresults},legend_label{1:N_jx_inner_top},'location','best');   
   else
     R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,ntt,'Net current density at inner target','$j_{\perp}, \; A/m^2$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'jx_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot potential at inner top target
   R_plot_Nresults(y2,po,nx,ny,Nresults,ntt,'Potential at inner top target','$\varphi, \; V$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'po_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion flux density at inner top target
   R_plot_Nresults(y2,-(fnax_mdf(:,:,:,2)+fnax_PSch(:,:,:,2))./hz./hy,nx,ny,Nresults,ntt,'Main ion particle flux density at inner top target','$\Gamma_{D^{+}}, \; m^{-2}s^{-1}$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Gamma_D_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot total heat flux density at inner top target
   if exp_data_flag && exist('N_fhtotX_inner_top','var')
     R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,ntt,'Heat flux density at inner top target','$q_{tot}, \; W/m^2$',label,1);
     hold all;
     v = axis;
     legend_label=cell(N_fhtotX_inner_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_fhtotX_inner_top
        plot(exp_data_fhtotX_inner_top(:,2*i-1),exp_data_fhtotX_inner_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_fhtotX_inner_top{i};
     end;
     v(3)=0.0;
%    axis(v);
     legend(label{1:Nresults},legend_label{1:N_fhtotX_inner_top},'location','best');   
   else
     R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,ntt,'Heat flux density at inner top target','$q_{tot}, \; W/m^2$',label,0);
   end; 
   set(gcf,'PaperPositionMode','auto')
   Figname = 'q_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner top target
   if exist('is_He01','var')
     R_plot_Nresults(y2,na(:,:,:,is_He01),nx,ny,Nresults,ntt,'He{+1} density at inner top target','$n_{\rm He^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHe01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_He02),nx,ny,Nresults,ntt,'He{+2} density at inner top target','$n_{\rm He^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHe02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,ntt,'Total He density at inner top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHetot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nHe_ch,nx,ny,Nresults,ntt,'He density (charged states) at inner top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHech_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner top target
   if exist('is_C01','var')
     R_plot_Nresults(y2,na(:,:,:,is_C01),nx,ny,Nresults,ntt,'C{+1} density at inner top target','$n_{\rm C^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_C02),nx,ny,Nresults,ntt,'C{+2} density at inner top target','$n_{\rm C^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_C03),nx,ny,Nresults,ntt,'C{+3} density at inner top target','$n_{\rm C^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,ntt,'Total C density at inner top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nCtot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nC_ch,nx,ny,Nresults,ntt,'C density (charged states) at inner top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nCch_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
  end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner top target
   if exist('is_N01','var')
     R_plot_Nresults(y2,na(:,:,:,is_N01),nx,ny,Nresults,ntt,'N{+1} density at inner top target','$n_{\rm N^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_N02),nx,ny,Nresults,ntt,'N{+2} density at inner top target','$n_{\rm N^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_N03),nx,ny,Nresults,ntt,'N{+3} density at inner top target','$n_{\rm N^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,ntt,'Total N density at inner top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNtot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nN_ch,nx,ny,Nresults,ntt,'N density (charged states) at inner top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNch_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at inner top target
   if exist('is_Ne01','var')
     R_plot_Nresults(y2,na(:,:,:,is_Ne01),nx,ny,Nresults,ntt,'Ne{+1} density at inner top target','$n_{\rm Ne^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_Ne02),nx,ny,Nresults,ntt,'Ne{+2} density at inner top target','$n_{\rm Ne^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_Ne03),nx,ny,Nresults,ntt,'Ne{+3} density at inner top target','$n_{\rm Ne^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,ntt,'Total Ne density at inner top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNetot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nNe_ch,nx,ny,Nresults,ntt,'Ne density (charged states) at inner top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNech_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron density at outer top target
   if exp_data_flag && exist('N_ne_outer_top','var')
    R_plot_Nresults(y2,ne,nx,ny,Nresults,ntt+1,'Electron density at outer top target','$n_e, \; m^{-3}$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_ne_outer_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_ne_outer_top
        plot(exp_data_ne_outer_top(:,2*i-1),exp_data_ne_outer_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_ne_outer_top{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_ne_outer_top},'location','best');   
   else
    R_plot_Nresults(y2,ne,nx,ny,Nresults,ntt+1,'Electron density at outer top target','$n_e, \; m^{-3}$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'ne_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron temperature at outer top target
   if exp_data_flag && exist('N_Te_outer_top','var')
    R_plot_Nresults(y2,te,nx,ny,Nresults,ntt+1,'Electron temperature at outer top target','$T_e, \; eV$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_Te_outer_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Te_outer_top
        plot(exp_data_Te_outer_top(:,2*i-1),exp_data_Te_outer_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_Te_outer_top{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Te_outer_top},'location','best');   
   else
    R_plot_Nresults(y2,te,nx,ny,Nresults,ntt+1,'Electron temperature at outer top target','$T_e, \; eV$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Te_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion temperature at outer top target
   R_plot_Nresults(y2,ti,nx,ny,Nresults,ntt+1,'Ion temperature at outer top target','$T_i, \; eV$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Ti_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion saturation current density at outer top target
   if exp_data_flag && exist('N_jsat_outer_top','var')
     R_plot_Nresults(y2,jsat,nx,ny,Nresults,ntt+1,'Ion saturation current at outer top target','$j_{sat}, \; A/m^2$',label,1);
     hold all;
     v = axis;
     legend_label=cell(N_jsat_outer_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_jsat_outer_top
        plot(exp_data_jsat_outer_top(:,2*i-1),exp_data_jsat_outer_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jsat_outer_top{i};
     end;
     v(3)=0.0;
%    axis(v);
     legend(label{1:Nresults},legend_label{1:N_jsat_outer_top},'location','best');   
   else
     R_plot_Nresults(y2,jsat,nx,ny,Nresults,ntt+1,'Ion saturation current at outer top target','$j_{sat}, \; A/m^2$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'jsat_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot net current density at outer top target
   if exp_data_flag && exist('N_jx_outer_top','var')
     R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,ntt+2,'Net current density at outer target','$j_{\perp}, \; A/m^2$',label,0);
     hold all;
     v = axis;
     legend_label=cell(N_jx_outer_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_jx_outer_top
        plot(exp_data_jx_outer_top(:,2*i-1),exp_data_jx_outer_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jx_outer_top{i};
     end;
     v(3)=0.0;
     axis(v);
     legend(label{1:Nresults},legend_label{1:N_jx_outer_top},'location','best');   
   else
     R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,ntt+2,'Net current density at outer target','$j_{\perp}, \; A/m^2$',label,0);
   end;
   set(gcf,'PaperPositionMode','auto')
   Figname = 'jx_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot potential at outer top target
   R_plot_Nresults(y2,po,nx,ny,Nresults,ntt+1,'Potential at outer top target','$\varphi, \; V$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'po_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion flux density at outer top target
   R_plot_Nresults(y2,-(fnax_mdf(:,:,:,2)+fnax_PSch(:,:,:,2))./hz./hy,nx,ny,Nresults,ntt+2,'Main ion particle flux density at outer top target','$\Gamma_{D^{+}}, \; m^{-2}s^{-1}$',label,0);
   set(gcf,'PaperPositionMode','auto')
   Figname = 'Gamma_D_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot total heat flux density at outer top target
   if exp_data_flag && exist('N_fhtotX_outer_top','var')
     R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,ntt+2,'Heat flux density at outer top target','$q_{tot}, \; W/m^2$',label,1);
     hold all;
     v = axis;
     legend_label=cell(N_fhtotX_outer_top,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
     for i = 1:N_fhtotX_outer_top
        plot(exp_data_fhtotX_outer_top(:,2*i-1),exp_data_fhtotX_outer_top(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_fhtotX_outer_top{i};
     end;
     v(3)=0.0;
%    axis(v);
     legend(label{1:Nresults},legend_label{1:N_fhtotX_outer_top},'location','best');   
   else
     R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,ntt+2,'Heat flux density at outer top target','$q_{tot}, \; W/m^2$',label,0);
   end; 
   set(gcf,'PaperPositionMode','auto')
   Figname = 'q_in_top';
   print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
   print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer top target
   if exist('is_He01','var')
     R_plot_Nresults(y2,na(:,:,:,is_He01),nx,ny,Nresults,ntt+1,'He{+1} density at outer top target','$n_{\rm He^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHe01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_He02),nx,ny,Nresults,ntt+1,'He{+2} density at outer top target','$n_{\rm He^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHe02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,ntt+1,'Total He density at outer top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHetot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nHe_ch,nx,ny,Nresults,ntt+1,'He density (charged states) at outer top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nHech_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer top target
   if exist('is_C01','var')
     R_plot_Nresults(y2,na(:,:,:,is_C01),nx,ny,Nresults,ntt+1,'C{+1} density at outer top target','$n_{\rm C^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_C02),nx,ny,Nresults,ntt+1,'C{+2} density at outer top target','$n_{\rm C^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_C03),nx,ny,Nresults,ntt+1,'C{+3} density at outer top target','$n_{\rm C^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nC03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,ntt+1,'Total C density at outer top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nCtot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nC_ch,nx,ny,Nresults,ntt+1,'C density (charged states) at outer top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nCch_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
  end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer top target
   if exist('is_N01','var')
     R_plot_Nresults(y2,na(:,:,:,is_N01),nx,ny,Nresults,ntt+1,'N{+1} density at outer top target','$n_{\rm N^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_N02),nx,ny,Nresults,ntt+1,'N{+2} density at outer top target','$n_{\rm N^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_N03),nx,ny,Nresults,ntt+1,'N{+3} density at outer top target','$n_{\rm N^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nN03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,ntt+1,'Total N density at outer top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNtot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nN_ch,nx,ny,Nresults,ntt+1,'N density (charged states) at outer top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNch_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer top target
   if exist('is_Ne01','var')
     R_plot_Nresults(y2,na(:,:,:,is_Ne01),nx,ny,Nresults,ntt+1,'Ne{+1} density at outer top target','$n_{\rm Ne^{+1}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe01_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_Ne02),nx,ny,Nresults,ntt+1,'Ne{+2} density at outer top target','$n_{\rm Ne^{+2}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe02_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,na(:,:,:,is_Ne03),nx,ny,Nresults,ntt+1,'Ne{+3} density at outer top target','$n_{\rm Ne^{+3}}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNe03_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,ntt+1,'Total Ne density at outer top target','$n_{tot}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNetot_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
     R_plot_Nresults(y2,nNe_ch,nx,ny,Nresults,ntt+1,'Ne density (charged states) at outer top target','$n_{ch}, \; m^{-3}$',label,0);
     set(gcf,'PaperPositionMode','auto')
     Figname = 'nNech_in_top';
     print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
     print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
   end;
   
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electron density at outer target
if exp_data_flag && exist('N_ne_outer_bottom','var')
    R_plot_Nresults(y2,ne,nx,ny,Nresults,nx,'Electron density at outer target','$n_e, \; m^{-3}$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_ne_outer_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_ne_outer_bottom
        plot(exp_data_ne_outer_bottom(:,2*i-1),exp_data_ne_outer_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',24,'LineStyle','none','LineWidth',1.5,'Color',[0 0 0]);
        legend_label{i}=legend_exp_ne_outer_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_ne_outer_bottom},'location','best');   
else
    R_plot_Nresults(y2,ne,nx,ny,Nresults,nx,'Electron density at outer target','$n_e, \; m^{-3}$',label,0);
end;
%R_ne_exp_out_target=dlmread('~/B2SOLPS/Chankin_experimental_data/ne_outer_exp.txt','',[1 0 22 0]);
%ne_exp_out_target=dlmread('~/B2SOLPS/Chankin_experimental_data/ne_outer_exp.txt','',[1 1 22 1]);
%plot(R_ne_exp_out_target,ne_exp_out_target,'--','LineWidth',2,'Color',[0,0,0]);
%legend(label{1:Nresults},'{n_e}_{EXP}','location','best');
set(gcf,'PaperPositionMode','auto')
Figname = 'ne_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electrons temperature at outer target
if exp_data_flag && exist('N_Te_outer_bottom','var')
    R_plot_Nresults(y2,te,nx,ny,Nresults,nx,'Electron temperature at outer target','$T_e, \; eV$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_Te_outer_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_Te_outer_bottom
        plot(exp_data_Te_outer_bottom(:,2*i-1),exp_data_Te_outer_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',24,'LineStyle','none','LineWidth',1.5,'Color',[0 0 0]);
        legend_label{i}=legend_exp_Te_outer_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_Te_outer_bottom},'location','best');   
else
    R_plot_Nresults(y2,te,nx,ny,Nresults,nx,'Electron temperature at outer target','$T_e, \; eV$',label,0);
end;
%R_te_exp_out_target=dlmread('~/B2SOLPS/Chankin_experimental_data/te_outer_exp.txt','',[1 0 26 0]);
%te_exp_out_target=dlmread('~/B2SOLPS/Chankin_experimental_data/te_outer_exp.txt','',[1 1 26 1]);
%plot(R_te_exp_out_target,te_exp_out_target,'--','LineWidth',2,'Color',[0,0,0]);
%legend(label{1:Nresults},'{T_e}_{EXP}','location','best');
set(gcf,'PaperPositionMode','auto')
Figname = 'Te_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot electrons temperature at outer target
R_plot_Nresults(y2,ti,nx,ny,Nresults,nx,'Ion temperature at outer target','$T_i, \; eV$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Ti_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot ion saturation current density at outer target
if exp_data_flag && exist('N_jsat_outer_bottom','var')
    R_plot_Nresults(y2,jsat,nx,ny,Nresults,nx,'Ion saturation current at outer target','$j_{sat}, \; A/m^2$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_jsat_outer_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_jsat_outer_bottom
        plot(exp_data_jsat_outer_bottom(:,2*i-1),exp_data_jsat_outer_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jsat_outer_bottom{i};
    end;
    v(3)=0.0;
%    axis(v);
    legend(label{1:Nresults},legend_label{1:N_jsat_outer_bottom},'location','best');   
else
    R_plot_Nresults(y2,jsat,nx,ny,Nresults,nx,'Ion saturation current at outer target','$j_{sat}, \; A/m^2$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'jsat_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot net current density at outer target
if exp_data_flag && exist('N_jx_outer_bottom','var')
    R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,nx,'Net current density at outer target','$j_{\perp}, \; A/m^2$',label,0);
    hold all;
    v = axis;
    legend_label=cell(N_jx_outer_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_jx_outer_bottom
        plot(exp_data_jx_outer_bottom(:,2*i-1),exp_data_jx_outer_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_jx_outer_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_jx_outer_bottom},'location','best');   
else
    R_plot_Nresults(y2,jx./hz./hy,nx,ny,Nresults,nx,'Net current density at outer target','$j_{\perp}, \; A/m^2$',label,0);
end;
Figname = 'jx_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot Mach number for main ions at outer target
R_plot_Nresults(y2,ua(:,:,:,2)./cs,nx,ny,Nresults,nx,'Mach number at outer target, D^+','$M$',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[PATH_PREFIX{1},'../../','Mach_out.eps']);
%print('-dpng','-r600',[PATH_PREFIX{1},'../../','Mach_out.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux density in electron channel at outer target
%R_plot_Nresults(y2,fhex_tot./hy./hz,nx,ny,Nresults,nx,'Heat flux density in electron channel at outer target','$q_{e}, \; W/m^2$',label,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot heat flux density in ion channel at outer target
%R_plot_Nresults(y2,fhix_tot./hy./hz,nx,ny,Nresults,nx,'Heat flux density in ion channel at outer target','$q_{i}, \; W/m^2$',label,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot main ion flux density at outer target
R_plot_Nresults(y2,(fnax_mdf(:,:,:,2)+fnax_PSch(:,:,:,2))./hz./hy,nx,ny,Nresults,nx,'Main ion particle flux density at outer target','$\Gamma_{D^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_D_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot helium flux density at outer target (sum over charged states)
if exist('is_He01','var')
    R_plot_Nresults(y2,(fnax_He_ch+fnax_PSch_He_ch)./hz./hy,nx,ny,Nresults,nx,'Helium particle flux density at outer target','$\Gamma_{He^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_He_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot nitrogen flux density at outer target (sum over charged states)
if exist('is_N01','var')
    R_plot_Nresults(y2,(fnax_N_ch+fnax_PSch_N_ch)./hz./hy,nx,ny,Nresults,nx,'Nitrogen particle flux density at outer target','$\Gamma_{N^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_N_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot carbon flux density at outer target (sum over charged states)
if exist('is_C01','var')
    R_plot_Nresults(y2,(fnax_C_ch+fnax_PSch_C_ch)./hz./hy,nx,ny,Nresults,nx,'Carbon particle flux density at outer target','$\Gamma_{C^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_C_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot neon flux density at outer target (sum over charged states)
if exist('is_Ne01','var')
    R_plot_Nresults(y2,(fnax_Ne_ch+fnax_PSch_Ne_ch)./hz./hy,nx,ny,Nresults,nx,'Neon particle flux density at outer target','$\Gamma_{Ne^{+}}, \; m^{-2}s^{-1}$',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Gamma_Ne_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot total heat flux density at outer target
if exp_data_flag && exist('N_fhtotX_outer_bottom','var')
    R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,nx,'Heat flux density at outer target','$q_{tot}, \; W/m^2$',label,1);
    hold all;
    v = axis;
    legend_label=cell(N_fhtotX_outer_bottom,1);
%    legend_label{1}=label01;
%    legend_label{2}=label02;
    for i = 1:N_fhtotX_outer_bottom
        plot(exp_data_fhtotX_outer_bottom(:,2*i-1),exp_data_fhtotX_outer_bottom(:,2*i),'Marker',Marker_exp{i},'MarkerSize',12,'LineStyle','none','Color',[0 0 0]);
        legend_label{i}=legend_exp_fhtotX_outer_bottom{i};
    end;
    v(3)=0.0;
    axis(v);
    legend(label{1:Nresults},legend_label{1:N_fhtotX_outer_bottom},'location','best');   
else
    R_plot_Nresults(y2,fhx_tot./hy./hz,nx,ny,Nresults,nx,'Heat flux density at outer target','$q_{tot}, \; W/m^2$',label,0);
end;
set(gcf,'PaperPositionMode','auto')
Figname = 'q_out';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot neutral pressure at outer target
R_plot_Nresults(y2,pNeut,nx,ny,Nresults,nx-1,'Neutral pressure at outer target','$p_{N}, \; Pa$',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[PATH_PREFIX{1},'../../','pN_out.eps']);
%print('-dpng','-r600',[PATH_PREFIX{1},'../../','pN_out.png']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer target
if exist('is_He01','var')
    R_plot_Nresults(y2,na(:,:,:,is_He01),nx,ny,Nresults,nx,'He{+1} density at outer target','$n_{\rm He^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHe01_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_He02),nx,ny,Nresults,nx,'He{+2} density at outer target','$n_{\rm He^{+2}}, \; m^{-3}$',label,0);
    Figname = 'nHe02_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nHe_tot,nx,ny,Nresults,nx,'Total He density at outer target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHetot_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nHe_ch,nx,ny,Nresults,nx,'He density (charged states) at outer target','$n_{\ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nHech_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer target
if exist('is_C01','var')
    R_plot_Nresults(y2,na(:,:,:,is_C01),nx,ny,Nresults,nx,'C{+1} density at outer target','$n_{\rm C^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nC01_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_C02),nx,ny,Nresults,nx,'C{+2} density at outer target','$n_{\rm C^{+2}}, \; m^{-3}$',label,0);
    Figname = 'nC02_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_C03),nx,ny,Nresults,nx,'C{+3} density at outer target','$n_{\rm C^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN031_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nC_tot,nx,ny,Nresults,nx,'Total C density at outer target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nCtot_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nC_ch,nx,ny,Nresults,nx,'C density (charged states) at outer target','$n_{\ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nCch_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N05),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+5} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN5_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N05),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+5} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN5_SOL_nsep_and_16.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N06),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+6} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN6_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N06),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+6} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN6_SOL_nsep_and_16.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N07),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+7} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN7_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N07),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+7} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN7_SOL_nsep_and_16.eps']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer target
if exist('is_N01','var')
    R_plot_Nresults(y2,na(:,:,:,is_N01),nx,ny,Nresults,nx,'N{+1} density at outer target','$n_{\rm N^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN01_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_N02),nx,ny,Nresults,nx,'N{+2} density at outer target','$n_{\rm N^{+2}}, \; m^{-3}$',label,0);
    Figname = 'nN02_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_N03),nx,ny,Nresults,nx,'N{+3} density at outer target','$n_{\rm N^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nN031_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nN_tot,nx,ny,Nresults,nx,'Total N density at outer target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNtot_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nN_ch,nx,ny,Nresults,nx,'N density (charged states) at outer target','$n_{\ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNch_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N05),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+5} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN5_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N05),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+5} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN5_SOL_nsep_and_16.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N06),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+6} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN6_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N06),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+6} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN6_SOL_nsep_and_16.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N07),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'N^{+7} velocity in the SOL, iy = nsep+2','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN7_SOL_nsep_and_2.eps']);
% % %     poloidal_plot_Nresults(x2,ua(:,:,:,is_N07),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'N^{+7} velocity in the SOL, iy = nsep+16','n_N',label,0);
% % %     set(gcf,'PaperPositionMode','auto')
% % %     print('-depsc2','-r600',[PATH_PREFIX{1},'../../','uN7_SOL_nsep_and_16.eps']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot impurity density at outer target
if exist('is_Ne01','var')
    R_plot_Nresults(y2,na(:,:,:,is_Ne01),nx,ny,Nresults,nx,'Ne{+1} density at outer target','$n_{\rm Ne^{+1}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe01_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_Ne02),nx,ny,Nresults,nx,'Ne{+2} density at outer target','$n_{\rm Ne^{+2}}, \; m^{-3}$',label,0);
    Figname = 'nNe02_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,na(:,:,:,is_Ne03),nx,ny,Nresults,nx,'Ne{+3} density at outer target','$n_{\rm Ne^{+3}}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNe031_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nNe_tot,nx,ny,Nresults,nx,'Total Ne density at outer target','$n_{tot}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNetot_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
    R_plot_Nresults(y2,nNe_ch,nx,ny,Nresults,nx,'Ne density (charged states) at outer target','$n_{\ch}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    Figname = 'nNech_out';
    print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
    print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);
end;


poloidal_plot_Nresults(x2,na(:,:,:,2),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'main ion density in the SOL, iy = nsep+2','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'nD_SOL_nsep_and_2.eps']);
poloidal_plot_Nresults(x2,na(:,:,:,2),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'main ion density in the SOL, iy = nsep+16','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'nD_SOL_nsep_and_16.eps']);
poloidal_plot_Nresults(x2,ua(:,:,:,2),npl_flux,nc2,nc3,nx,Nresults,nsep+2,'main ion velocity in the SOL, iy = nsep+2','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'uD_SOL_nsep_and_2.eps']);
poloidal_plot_Nresults(x2,ua(:,:,:,2),npl_flux,nc2,nc3,nx,Nresults,nsep+16,'main ion velocity in the SOL, iy = nsep+16','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'uD_SOL_nsep_and_16.eps']);

poloidal_plot_Nresults(x2,pas-pNeut,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'total pressure in the SOL, iy = nsep+2','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'pressure_SOL_nsep_and_2.eps']);
poloidal_plot_Nresults(x2,pas-pNeut,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'total pressure in the SOL, iy = nsep+16','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'pressure_SOL_nsep_and_16.eps']);


poloidal_plot_Nresults(x2,te,nc1,nc2,nc3,nc4,Nresults,nsep,'Electron temperature in the CORE near separatrix','T_e, \; eV',label,0);
set(gcf,'PaperPositionMode','auto')
Figname = 'Te_CORE_nsep.eps';
print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


poloidal_plot_Nresults(x2,ti,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'Ion temperature in the SOL, iy = nsep+2','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Ti_SOL_nsep_and_2.eps']);


poloidal_plot_Nresults(x2,ti,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'Ion temperature in the SOL, iy = nsep+16','n_N',label,0);
set(gcf,'PaperPositionMode','auto')
print('-depsc2','-r600',[Figure_Store_PATH,'Ti_SOL_nsep_and_16.eps']);

if exist('is_He01','var')
    poloidal_plot_Nresults(x2,nHe_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'Total He density in the SOL, iy = nsep+2','$n_{He}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHetot_SOL_nsep_and_2.eps']);
    poloidal_plot_Nresults(x2,nHe_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'Total He density in the SOL, iy = nsep+16','$n_{He}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nHetot_SOL_nsep_and_16.eps']);
end;

if exist('is_C01','var')
    poloidal_plot_Nresults(x2,nC_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'Total C density in the SOL, iy = nsep+2','$n_C, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nCtot_SOL_nsep_and_2.eps']);
    poloidal_plot_Nresults(x2,nC_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'Total N density in the SOL, iy = nsep+16','$n_C, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nCtot_SOL_nsep_and_16.eps']);
end;

if exist('is_N01','var')
    poloidal_plot_Nresults(x2,nN_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'Total N density in the SOL, iy = nsep+2','$n_N, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNtot_SOL_nsep_and_2.eps']);
    poloidal_plot_Nresults(x2,nN_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'Total N density in the SOL, iy = nsep+16','$n_N, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNtot_SOL_nsep_and_16.eps']);
end;

if exist('is_Ne01','var')
    poloidal_plot_Nresults(x2,nNe_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+2,'Total Ne density in the SOL, iy = nsep+2','$n_{Ne}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNetot_SOL_nsep_and_2.eps']);
    poloidal_plot_Nresults(x2,nNe_tot,npl_flux,nc2,nc3,nx,Nresults,nsep+16,'Total Ne density in the SOL, iy = nsep+16','$n_{Ne}, \; m^{-3}$',label,0);
    set(gcf,'PaperPositionMode','auto')
    print('-depsc2','-r600',[Figure_Store_PATH,'nNetot_SOL_nsep_and_16.eps']);
end;

% % % % % % % x_value=zeros(Nresults,1);
% % % % % % % Jx_inner=zeros(Nresults,1);
% % % % % % % Jx_outer=zeros(Nresults,1);
% % % % % % % Jx_outer_Kallenbach=zeros(Nresults,1);
% % % % % % % 
% % % % % % % for m=1:Nresults
% % % % % % %     iy_Kallenbach(m) = 2;
% % % % % % %     while Z0(iy_Kallenbach(m),nx(m)+2,m) < -1.0
% % % % % % %         iy_Kallenbach(m) = iy_Kallenbach(m) + 1;
% % % % % % %     end;
% % % % % % %     
% % % % % % %     Jx_inner(m) = sum(jx(2:ny(m)+1,2,m));
% % % % % % %     Jx_outer(m) = sum(jx(2:ny(m)+1,nx(m)+2,m));
% % % % % % %     Jx_outer_Kallenbach(m)=sum(jx(2:iy_Kallenbach(m),nx(m)+2,m));
% % % % % % %     
% % % % % % %     Nmain_ch(m) = sum(sum(na(2:ny(m)+1,2:nx(m)+1,m,is_main).*vol(2:ny(m)+1,2:nx(m)+1,m)));
% % % % % % %     Nmain_ch_core(m) = sum(sum(na(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m,is_main).*vol(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %     Nmain_ch_SOL(m) = sum(sum(na(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m,is_main).*vol(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %     Nmain_ch_in_divertor(m) = sum(sum(na(2:ny(m)+1,2:nc1(m)+1,m,is_main).*vol(2:ny(m)+1,2:nc1(m)+1)));
% % % % % % %     Nmain_ch_out_divertor(m) = sum(sum(na(2:ny(m)+1,nc4(m)+3:nx(m)+1,m,is_main).*vol(2:ny(m)+1,nc4(m)+3:nx(m)+1)));
% % % % % % %     
% % % % % % %     Nmain_tot_B2(m) = Nmain_ch(m) + sum(sum( (na(2:ny(m)+1,2:nx(m)+1,m,is_main-1) + 2.0*nD2(2:ny(m)+1,2:nx(m)+1,m)) .* vol(2:ny(m)+1,2:nx(m)+1,m) ));
% % % % % % %     
% % % % % % %     if EIRENE_flag
% % % % % % %         Nmain_tot(m) = Nmain_ch(m) + sum((pdena(1:N_tria(m),eir_atom(is_main),m)+2.0*pdenm(1:N_tria(m),eir_mol(is_main),m)).*vol_eir(1:N_tria(m),m));
% % % % % % %     else
% % % % % % %         Nmain_tot(m) = Nmain_tot_B2(m);
% % % % % % %     end;
% % % % % % %     
% % % % % % %     Ne(m) = sum(sum(ne(2:ny(m)+1,2:nx(m)+1,m).*vol(2:ny(m)+1,2:nx(m)+1,m)));
% % % % % % %     Ne_core(m) = sum(sum(ne(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m).*vol(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %     Ne_SOL(m) = sum(sum(ne(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m).*vol(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %     Ne_in_divertor(m) = sum(sum(ne(2:ny(m)+1,2:nc1(m)+1,m).*vol(2:ny(m)+1,2:nc1(m)+1)));
% % % % % % %     Ne_out_divertor(m) = sum(sum(ne(2:ny(m)+1,nc4(m)+3:nx(m)+1,m).*vol(2:ny(m)+1,nc4(m)+3:nx(m)+1)));
% % % % % % % 
% % % % % % %     if exist('is_N01','var')
% % % % % % %         NNch(m) = sum(sum(nN_ch(2:ny(m)+1,2:nx(m)+1,m).*vol(2:ny(m)+1,2:nx(m)+1,m)));
% % % % % % %         NNch_core(m) = sum(sum(nN_ch(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m).*vol(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %         NNch_SOL(m) = sum(sum(nN_ch(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m).*vol(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %         NNch_in_divertor(m) = sum(sum(nN_ch(2:ny(m)+1,2:nc1(m)+1,m).*vol(2:ny(m)+1,2:nc1(m)+1)));
% % % % % % %         NNch_out_divertor(m) = sum(sum(nN_ch(2:ny(m)+1,nc4(m)+3:nx(m)+1,m).*vol(2:ny(m)+1,nc4(m)+3:nx(m)+1)));
% % % % % % %         NNtot_core(m) = sum(sum( (nN_ch(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m)+na(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m,is_N01-1)) .* vol(2:nsep(m)+2,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %         NNtot_SOL(m) = sum(sum( (nN_ch(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m)+na(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]],m,is_N01-1)) .* vol(nsep(m)+3:ny(m)+1,[[nc1(m)+2:nc2(m)+2] [nc3(m)+2:nc4(m)+2]])));
% % % % % % %         NNtot_in_divertor(m) = sum(sum( (nN_ch(2:ny(m)+1,2:nc1(m)+1,m)+na(2:ny(m)+1,2:nc1(m)+1,m,is_N01-1)) .* vol(2:ny(m)+1,2:nc1(m)+1)));
% % % % % % %         NNtot_out_divertor(m) = sum(sum( (nN_ch(2:ny(m)+1,nc4(m)+3:nx(m)+1,m)+na(2:ny(m)+1,nc4(m)+3:nx(m)+1,m,is_N01-1)) .* vol(2:ny(m)+1,nc4(m)+3:nx(m)+1)));
% % % % % % %  
% % % % % % %         NNtot_B2(m) = NNch(m) + sum(sum( na(2:ny(m)+1,2:nx(m)+1,m,is_N01-1)  .* vol(2:ny(m)+1,2:nx(m)+1,m) ));
% % % % % % %  
% % % % % % %         if EIRENE_flag
% % % % % % %             NNtot(m) = NNch(m) + sum(pdena(1:N_tria(m),eir_atom(is_N01),m).*vol_eir(1:N_tria(m),m));
% % % % % % %         else
% % % % % % %             NNtot(m) = NNtot_B2(m);
% % % % % % %         end;
% % % % % % %     end;
% % % % % % %     x_value(m)=Parameter{m};
% % % % % % % end;
% % % % % % % 
% % % % % % % figure;
% % % % % % % plot(x_value,Nmain_tot,'Color','red','LineWidth',3);
% % % % % % % hold all;
% % % % % % % plot(x_value,Nmain_ch,'Color','blue','LineWidth',3);
% % % % % % % plot(x_value,Ne,'Color',[0.45,0.1,0.05],'LineWidth',3);
% % % % % % % if exist('is_N01','var')
% % % % % % %     plot(x_value,NNtot,'Color',[0.75,0.2,0.15],'LineWidth',3);
% % % % % % %     legend('N_{main}^{(tot)}','{N_{main}_{+}}','N_e','N_N','location','best','FontSize',12);
% % % % % % % else
% % % % % % %     legend('N_{main}^{(tot)}','{N_{main}_{+}}','N_e','location','best','FontSize',12);
% % % % % % % end;
% % % % % % % set(gca,'FontName','Times','FontSize',24);
% % % % % % % xlabel(Parameter_label,'FontName','Times','FontSize',36);
% % % % % % % ylabel('N, number of particles','interpreter', 'latex','FontName','Times','FontSize',36);
% % % % % % % title('Total number of particles in the domain','FontName','Times','FontSize',36);
% % % % % % % hold all;
% % % % % % % grid on;
% % % % % % % grid minor;
% % % % % % % 
% % % % % % % figure;
% % % % % % % plot(x_value,Nmain_tot,'Color','red','LineWidth',3);
% % % % % % % hold all;
% % % % % % % plot(x_value,Nmain_ch,'Color','blue','LineWidth',3);
% % % % % % % plot(x_value,Nmain_ch_core,'Color',[0.45,0.1,0.05],'LineWidth',3);
% % % % % % % plot(x_value,Nmain_ch_SOL,'Color',[0.75,0.2,0.15],'LineWidth',3);
% % % % % % % plot(x_value,Nmain_ch_in_divertor,'Color',[0.15,0.05,0.5],'LineWidth',3);
% % % % % % % plot(x_value,Nmain_ch_out_divertor,'Color',[0.25,0.5,0.25],'LineWidth',3);
% % % % % % % set(gca,'FontName','Times','FontSize',24);
% % % % % % % legend('total','charged','charged core','charged SOL','charged in','charged out','location','best','FontSize',12); 
% % % % % % % xlabel(Parameter_label,'FontName','Times','FontSize',36);
% % % % % % % ylabel('N, number of particles','interpreter', 'latex','FontName','Times','FontSize',36);
% % % % % % % title('Total number of main ions','FontName','Times','FontSize',36);
% % % % % % % hold all;
% % % % % % % grid on;
% % % % % % % grid minor;
% % % % % % % 
% % % % % % % figure;
% % % % % % % plot(x_value,Ne,'Color','red','LineWidth',3);
% % % % % % % hold all;
% % % % % % % %plot(x_value,Ne_ch,'Color','blue','LineWidth',3);
% % % % % % % plot(x_value,Ne_core,'Color',[0.45,0.1,0.05],'LineWidth',3);
% % % % % % % plot(x_value,Ne_SOL,'Color',[0.75,0.2,0.15],'LineWidth',3);
% % % % % % % plot(x_value,Ne_in_divertor,'Color',[0.15,0.05,0.5],'LineWidth',3);
% % % % % % % plot(x_value,Ne_out_divertor,'Color',[0.25,0.5,0.25],'LineWidth',3);
% % % % % % % set(gca,'FontName','Times','FontSize',24);
% % % % % % % legend('total','core','SOL','inner','outer','location','best','FontSize',12); 
% % % % % % % xlabel(Parameter_label,'FontName','Times','FontSize',36);
% % % % % % % ylabel('N, number of particles','interpreter', 'latex','FontName','Times','FontSize',36);
% % % % % % % title('Total number of main ions','FontName','Times','FontSize',36);
% % % % % % % hold all;
% % % % % % % grid on;
% % % % % % % grid minor;
% % % % % % % 
% % % % % % % if exist('is_N01','var')
% % % % % % %     figure;
% % % % % % %     plot(x_value,NNtot,'Color','red','LineWidth',3);
% % % % % % %     hold all;
% % % % % % %     plot(x_value,NNch,'Color','blue','LineWidth',3);
% % % % % % %     plot(x_value,NNch_core,'Color',[0.45,0.1,0.05],'LineWidth',3);
% % % % % % %     plot(x_value,NNch_SOL,'Color',[0.75,0.2,0.15],'LineWidth',3);
% % % % % % %     plot(x_value,NNch_in_divertor,'Color',[0.15,0.05,0.5],'LineWidth',3);
% % % % % % %     plot(x_value,NNch_out_divertor,'Color',[0.25,0.5,0.25],'LineWidth',3);
% % % % % % %     set(gca,'FontName','Times','FontSize',24);
% % % % % % %     legend('total','charged','charged core','charged SOL','charged in','charged out','location','best','FontSize',12); 
% % % % % % %     xlabel(Parameter_label,'FontName','Times','FontSize',36);
% % % % % % %     ylabel('N, number of particles','interpreter', 'latex','FontName','Times','FontSize',36);
% % % % % % %     title('Total number of Nitrogen atoms','FontName','Times','FontSize',36);
% % % % % % %     hold all;
% % % % % % %     grid on;
% % % % % % %     grid minor;
% % % % % % % end;
% % % % % % % 
% % % % % % % figure;
% % % % % % % plot(x_value,Jx_inner,'Color','red','LineWidth',3);
% % % % % % % hold all;
% % % % % % % plot(x_value,Jx_outer,'Color','blue','LineWidth',3);
% % % % % % % plot(x_value,Jx_outer_Kallenbach,'Color',[0.45,0.1,0.05],'LineWidth',3);
% % % % % % % legend('inner target','outer target','segment of outer target','location','best','FontSize',12); 
% % % % % % % set(gca,'FontName','Times','FontSize',24);
% % % % % % % xlabel(Parameter_label,'FontName','Times','FontSize',36);
% % % % % % % ylabel('N','interpreter', 'latex','FontName','Times','FontSize',36);
% % % % % % % title('Total current through plates (sheathes)','FontName','Times','FontSize',36);
% % % % % % % hold all;
% % % % % % % grid on;
% % % % % % % grid minor;
    
% poloidal_plot_Nresults(x2,hx,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'hx at iy=nsep+1','$h_x, \; m$',label,0);
% poloidal_plot_Nresults(x2,hy,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'hy at iy=nsep+1','$h_y, \; m$',label,0);
% poloidal_plot_Nresults(x2,hy1,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'hy1 at iy=nsep+1','$h_{y1}, \; m$',label,0);
% poloidal_plot_Nresults(x2,vol./(hx.*hy1.*hz),-npl,ntop,ntop+1,nx,Nresults,nsep+1,' at iy=nsep+1','$\sqrt{g}/(h_x\:h_{y1}\:h_z)$',label,0);

%stop;

% poloidal_plot_Nresults(x2,ne,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'Electron density at iy=nsep+1','$n_e, \; m^{-3}$',label,0);
% poloidal_plot_Nresults(x2,na03,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'C^{+1} ion density at iy=nsep+1','$n_{C^{+1}}, \; m^{-3}$',label,0);
% 
% poloidal_plot_Nresults(x2,sna_sral01,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'Main ion source at iy=nsep+1','$S, \; s^{-1}$',label,0);
% poloidal_plot_Nresults(x2,sna_sral03,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'C^{+1} ion source at iy=nsep+1','$S, \; s^{-1}$',label,0);
% 
% poloidal_plot_Nresults(x2,te,-npl,ntop,ntop+1,nx,Nresults,nsep+1,'Electron temperature at iy=nsep+1','$T_e, \; eV$',label,0);
% 
% poloidal_plot_Nresults(x2,ne,-npl,ntop,ntop+1,nx,Nresults,nsep+2,'Electron density at iy=nsep+2','$n_e, \; m^{-3}$',label,0);
% poloidal_plot_Nresults(x2,na03,-npl,ntop,ntop+1,nx,Nresults,nsep+2,'C^{+1} ion density at iy=nsep+2','$n_{C^{+1}}, \; m^{-3}$',label,0);
% 
% poloidal_plot_Nresults(x2,sna_sral01,-npl,ntop,ntop+1,nx,Nresults,nsep+2,'Main ion source at iy=nsep+2','$S, \; s^{-1}$',label,0);
% poloidal_plot_Nresults(x2,sna_sral03,-npl,ntop,ntop+1,nx,Nresults,nsep+2,'C^{+1} ion source at iy=nsep+2','$S, \; s^{-1}$',label,0);
% 
% poloidal_plot_Nresults(x2,te,-npl,ntop,ntop+1,nx,Nresults,nsep+2,'Electron temperature at iy=nsep+2','$T_e, \; eV$',label,0);
% 
% poloidal_plot_Nresults(x2,ne,-npl,ntop,ntop+1,nx,Nresults,nsep+3,'Electron density at iy=nsep+3','$n_e, \; m^{-3}$',label,0);
% poloidal_plot_Nresults(x2,na03,-npl,ntop,ntop+1,nx,Nresults,nsep+3,'C^{+1} ion density at iy=nsep+3','$n_{C^{+1}}, \; m^{-3}$',label,0);
% 
% poloidal_plot_Nresults(x2,sna_sral01,-npl,ntop,ntop+1,nx,Nresults,nsep+3,'Main ion source at iy=nsep+3','$S, \; s^{-1}$',label,0);
% poloidal_plot_Nresults(x2,sna_sral03,-npl,ntop,ntop+1,nx,Nresults,nsep+3,'C^{+1} ion source at iy=nsep+3','$S, \; s^{-1}$',label,0);
% 
% poloidal_plot_Nresults(x2,te,-npl,ntop,ntop+1,nx,Nresults,nsep+3,'Electron temperature at iy=nsep+3','$T_e, \; eV$',label,0);
% 
% poloidal_plot_Nresults(x2,ne,nc1,nc2,nc3,nc4,Nresults,nsep+1,'Electron density at iy=nsep','$n_e, \; m^{-3}$',label,0);
% poloidal_plot_Nresults(x2,na03,nc1,nc2,nc3,nc4,Nresults,nsep+1,'C^{+1} ion density at iy=nsep','$n_{C^{+1}}, \; m^{-3}$',label,0);
% 
% poloidal_plot_Nresults(x2,sna_sral01,nc1,nc2,nc3,nc4,Nresults,nsep+1,'Main ion source at iy=nsep','$S, \; s^{-1}$',label,0);
% poloidal_plot_Nresults(x2,sna_sral03,nc1,nc2,nc3,nc4,Nresults,nsep+1,'C^{+1} ion source at iy=nsep','$S, \; s^{-1}$',label,0);
% 
% poloidal_plot_Nresults(x2,te,nc1,nc2,nc3,nc4,Nresults,nsep+1,'Electron temperature at iy=nsep','$T_e, \; eV$',label,0);

global PlotSize;

% Use actual screen size to plot in a full screen mode
PlotSize = get(0,'ScreenSize');

% or set up the plot size manually (in pixels)
PlotSize=zeros(1,4);

PlotSize(1) = 1;
PlotSize(2) = 900;
PlotSize(3) = 1200;
PlotSize(4) = 900;

Plot2DMargins = [1.25 1.7  -1.25 -0.65];
Plot2DMargins_whole = [0.8 2.3  -1.30 1.10];
 
% The whole poloidal cross-section of Globus-M tokamak
%  Plot2DMargins = [0.18 0.4  -0.6 -0.2]; 
%  Plot2DMargins_whole = [0.05 0.7  -0.60 0.60];

% ITER near X-point
% Plot2DMargins = [4.0 6.5  -4.60 -2.10];
 % ITER whole B2 mesh
% Plot2DMargins_whole = [4.0 8.7  -5.00 5.00];
 
 
Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
Level_ne_log=logspace(-1,1.7,50);
for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
    if mod(m,6)==0
        subplot(2,3,6);
    else
        subplot(2,3,mod(m,6));
    end;        
    plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nD_tot(:,:,m)/1.0e19),'$n_D, \; \rm 10^{19} \: m^{-3}$',['nD_' label{m} '_log10'] ,...
log10(Level_ne_log),label{m},Plot2DMargins_whole);
   
end;
% Figname = '2D_nD';
% print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
% print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
    if mod(m,6)==0
        subplot(2,3,6);
    else
        subplot(2,3,mod(m,6));
    end;        
    plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(ne(:,:,m)/1.0e19),'$n_e, \; \rm 10^{19} \: m^{-3}$',['ne_' label{m} '_log10'] ,...
log10(Level_ne_log),label{m},Plot2DMargins_whole);
end;
% Figname = '2D_ne';
% print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
% print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

if exist('is_He01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nHe_log=logspace(-2,1.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nHe_tot(:,:,m)/1.0e19),'$n_{He}, \; \rm 10^{19} \: m^{-3}$',['nHe_' label{m} '_log10'] ,...
        log10(Level_nHe_log),label{m},Plot2DMargins_whole);
   end;
end;

if exist('is_C01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nC_log=logspace(-2,1.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nC_tot(:,:,m)/1.0e19),'$n_C, \; \rm 10^{19} \: m^{-3}$',['nC_' label{m} '_log10'] ,...
        log10(Level_nC_log),label{m},Plot2DMargins_whole);
   end;
end;


if exist('is_N01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nN_log=logspace(-2,1.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nN_tot(:,:,m)/1.0e19),'$n_N, \; \rm 10^{19} \: m^{-3}$',['nN_' label{m} '_log10'] ,...
        log10(Level_nN_log),label{m},Plot2DMargins_whole);
   end;
end;

if exist('is_N01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nN_rel_log=logspace(-3,0.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
      end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nN_tot(:,:,m)/max(max(nN_tot(:,:,m)))),'$n_N/{n_N}_{max}$',['nN_' label{m} '_log10'] ,...
        log10(Level_nN_rel_log),label{m},Plot2DMargins_whole);
   end;
end;
if exist('is_N01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nN_rel_log=logspace(-4,0.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
      end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nN_tot(:,:,m)./na(:,:,m,is_main)),'$n_N/{n_D}$',['nNnD_' label{m} '_log10'] ,...
        log10(Level_nN_rel_log),label{m},Plot2DMargins_whole);
   end;
end;


if exist('is_Ne01','var')
   Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0];%,60.0, 80.0, 100.0];
   Level_nNe_log=logspace(-2,1.0,50);
   for m=1:Nresults
     if mod(m,6)==1
         figure
         2*2;
     end;
     if mod(m,6)==0
        subplot(2,3,6);
     else
        subplot(2,3,mod(m,6));
     end;        
     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},log10(nNe_tot(:,:,m)/1.0e19),'$n_{Ne}, \; \rm 10^{19} \: m^{-3}$',['nNe_' label{m} '_log10'] ,...
        log10(Level_nNe_log),label{m},Plot2DMargins_whole);
   end;
end;

% Figname = '2D_nN';
% print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
% print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);


% % % for m=1:Nresults
% % %      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},te(:,:,m),'$T_e, \; \rm eV$',['Te3_' label{m} '_steps'] ,...
% % %          [0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6,2.8,3.0,3.2,3.4,3.6,3.8,4.0,4.2,4.4,4.6,4.8,5.0],label{m},[1.2 1.6  -1.25 -0.65]);
% % % %       [0.1,0.2,0.5,0.8,1.0,1.2,1.5,2.0,2.5,3.0,5.0,8.0,10.0,15.0,20.0,25.0,30.0,35.0,40.0,50.0]
% % % %       [0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6],label{m},[1.25 1.5  -1.08 -0.88]
% % % end;
% % % 
% % % 
for m=1:Nresults
    if mod(m,6)==1
         figure
     end;
    if mod(m,6)==0
        subplot(2,3,6);
    else
        subplot(2,3,mod(m,6));
    end;        
    axis(Plot2DMargins);
    plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},te(:,:,m),'$T_e, \; \rm eV$',['Te_' label{m} ],...
         [0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50 60 70 80 90 100 120 140]/2.0,...
         label{m},Plot2DMargins);
     %axis equal;
     %caxis manual;
end;
% Figname = '2D_Te';
% print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
% print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

% % % for m=1:Nresults
% % %     if mod(m,6)==1
% % %          figure
% % %      end;
% % %     if mod(m,6)==0
% % %         subplot(2,3,6);
% % %     else
% % %         subplot(2,3,mod(m,6));
% % %     end;        
% % %     axis(Plot2DMargins);
% % %     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},pas(:,:,m),'$n_eT_e + \sum n_aT_i, \; \rm Pa$',['Te_' label{m} ],...
% % %          [0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50 60 70 80 90 100 120 140]*30.0,...
% % %          label{m},Plot2DMargins);
% % %      %axis equal;
% % %      %caxis manual;
% % % end;
% % % 
% % % for m=1:Nresults
% % %     if mod(m,6)==1
% % %          figure
% % %      end;
% % %     if mod(m,6)==0
% % %         subplot(2,3,6);
% % %     else
% % %         subplot(2,3,mod(m,6));
% % %     end;        
% % %     axis(Plot2DMargins);
% % %     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},pas(:,:,m),'$n_eT_e + \sum \left(n_aT_i + \frac{m_au_{a||}^2}{2}\right), \; \rm Pa$',['Te_' label{m} ],...
% % %          [0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50 60 70 80 90 100 120 140]*30.0,...
% % %          label{m},Plot2DMargins);
% % %      %axis equal;
% % %      %caxis manual;
% % % end;

Figname = '2D_poTe';
for m=1:Nresults
    if mod(m,6)==1
        if i>1
%             Figname = [Figname,num2str(floor(m/6),'%0.2i')];
%             print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
%             print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);  
        end;
         figure
     end;
    if mod(m,6)==0
        subplot(2,3,6);
    else
        subplot(2,3,mod(m,6));
    end;        
    axis(Plot2DMargins);
    plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},po(:,:,m)./te(:,:,m),'$e\varphi/T_e$',['poTe_' label{m} ],...
         [-50 -40 -30 -25 -20 -18 -16 -14 -12 -10 -8 -6 -4 -2 0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50]/2.0,...
         label{m},Plot2DMargins);
     %axis equal;
     %caxis manual;
end;
% Figname = [Figname,num2str(floor(m/6),'%0.2i')];
% print('-depsc2','-r600',[Figure_Store_PATH,Figname,'.eps']);
% print('-dpng','-r600',[Figure_Store_PATH,Figname,'.png']);

% % % Level_ux=[-10000 -8000 -6000 -4000 -2000 -1000 -800 -600 -400 -200 -100 -50 -25 0 25 50 100 200 400 600 800 1000 2000 4000 6000 8000 1000];
% % % for m=1:Nresults
% % %     if mod(m,6)==1
% % %          figure
% % %          2*2
% % %      end;
% % %     if mod(m,6)==0
% % %         subplot(2,3,6);
% % %     else
% % %         subplot(2,3,mod(m,6));
% % %     end;        
% % %     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},ua(:,:,m,is_D01).*Bx(:,:,m)./B(:,:,m),'$b_x\left< ua_{D||}\right>, \; \rm m/s$',['uaD' label{m} ],...
% % %           Level_ux/2.0,...
% % %          label{m},Plot2DMargins_whole);
% % %      %axis equal;
% % %      %caxis manual;
% % % end;
% % % 
% % % %Level_ux=[-6000 0 6000];
% % % 
% % % for m=1:Nresults
% % %     if mod(m,6)==1
% % %          figure
% % %          2*2;
% % %      end;
% % %     if mod(m,6)==0
% % %         subplot(2,3,6);
% % %     else
% % %         subplot(2,3,mod(m,6));
% % %     end;        
% % %     plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},uaN_ch_avr(:,:,m).*Bx(:,:,m)./B(:,:,m)+ux_ExB(:,:,m),'$b_x\left<ua_{N||}\right>+u_{x}^{(\rm ExB)}, \; \rm m/s$',['uxN' label{m} ],...
% % %           Level_ux,...
% % %          label{m},Plot2DMargins_whole);
% % %      %axis equal;
% % %      %caxis manual;
% % % end;
% % % for m=1:Nresults
% % %     if mod(m,6)==1
% % %          figure
% % %          2*2;
% % %      end;
% % %     if mod(m,6)==0
% % %         subplot(2,3,6);
% % %     else
% % %         subplot(2,3,mod(m,6));
% % %     end;        
% % %     plot_poloidal_arrow(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntt(m),nsep(m),nsep2(m),PATH_PREFIX{m},uaN_ch_avr(:,:,m),'$u_{Nx}$','ux_arrow',Plot2DMargins_whole);
% % %      %axis equal;
% % %      %caxis manual;
% % % end;
%%plot_poloidal_arrow(nx(1),ny(1),nc1(1),nc2(1),nc3(1),nc4(1),ntt(1),nsep(1),nsep2(1),PATH_PREFIX{1},uaN_ch_avr(:,:,1),'u_{Nx}','ux_arrow',Plot2DMargins_whole);
% % % 
% % % 
% % % for m=1:Nresults
% % %      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},ne(:,:,m)/1.0e19,'$n_e, \; \rm 10^{19} \; m^{-3}$',['ne_' label{m} '_steps'] , ...
% % %          [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0,60.0],...
% % %          label{m},[1.1 1.7  -1.25 -0.65]);
% % % %     caxis(caxis) freeze;
% % % %         [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,24.0,26.0,28.0,30.0,40.0,50.0,60.0,80.0,100.0],...
% % % 
% % % end;
% % % 
% % % if exist('is_C01','var')
% % %    for m=1:Nresults
% % %      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},nC_total(:,:,m)/1.0e19,'$n_{C^{\rm total}}, \; \rm 10^{19} \; m^{-3}$',['nC_total_' label{m} '_steps'] , ...
% % %          [0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0],...
% % %          label{m},[1.1 1.7  -1.25 -0.65]);
% % % %     caxis(caxis) freeze;
% % %    end;
% % % end;
% % % 
% % % for m=1:Nresults
% % %      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},pas(:,:,m)/1000,'$p_{total}, \; \rm kPa$',['p_tot_' label{m} '_steps'],...
% % %          [0 50 100 150 200 250 300 350 400 450 500]/1000,...
% % %          label{m},[1.1 1.7  -1.25 -0.65]);
% % % %     [0 100 150 200 250 300 350 400 450 500 550 600 800 1000 1200 1400 1600 1800 2000 2200 2500 2800 3000]/1000,...
% % % end;

% % % for m=1:Nresults
% % %      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},pas_fullHD(:,:,m)/1000,'$p_{total}^{\rm HydrDyn}, \; \rm kPa$',['p_tot_fullHD' label{m} '_steps'],...
% % %          [0 100 150 200 250 300 350 400 450 500 550 600 800 1000]/1000,...
% % %          label{m},[1.1 1.7  -1.25 -0.65]);
% % % %     [0 100 150 200 250 300 350 400 450 500 550 600 800 1000 1200 1400 1600 1800 2000 2200 2500 2800 3000]/1000,...
% % % end;

stop;

% for m=1:Nresults
%      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},na01(:,:,m),'$n_{D^{+}}, \; \rm m^{-3}$',['nD01_' label{m} '_steps'] ,[1e20 2e20 3e20 4e20 5e20 6e20 7e20 8e20 9e20 10e20 11e20 12e20 13e20 14e20 15e20 16e20 17e20 18e20 20e20],label{m},[1.25 1.5  -1.08 -0.88]);
% end;
% for m=1:Nresults
%      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},sna_sral01(:,:,m),'$S_{D^{+}}, \; s^{-1}$',['sD01_' label{m} '_steps'] ,[-20e20 -19e20 -18e20 -17e20 -16e20 -15e20 -14e20 -13e20 -12e20 -11e20 -10e20 -9e20 -8e20 -7e20 -6e20 -5e20 -4e20 -3e20 -2e20 -1e20 0 1e20 2e20 3e20 4e20 5e20 6e20 7e20 8e20 9e20 10e20 11e20 12e20 13e20 14e20 15e20 16e20 17e20 18e20 20e20],label{m},[1.25 1.5  -1.08 -0.88]);
% end;
% for m=1:Nresults
%      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},na03(:,:,m),'$n_{C^{+}}, \; \rm m^{-3}$',['nC01_' label{m} '_steps'] ,[1e18 2e18 3e18 4e18 5e18 6e18 7e18 8e18 9e18 10e18 11e18 12e18 13e18 14e18 15e18 16e18 17e18 18e18 20e18],label{m},[1.25 1.5  -1.08 -0.88]);
% end;
% for m=1:Nresults
%      plot2D(nx(m),ny(m),nc1(m),nc2(m),nc3(m),nc4(m),ntop(m),nsep(m),nsep(m),PATH_PREFIX{m},sna_sral03(:,:,m),'$S_{C^{+}}, \; s^{-1}$',['sD01_' label{m} '_steps'] ,[-20e18 -19e18 -18e18 -17e18 -16e18 -15e18 -14e18 -13e18 -12e18 -11e18 -10e18 -9e18 -8e18 -7e18 -6e18 -5e18 -4e18 -3e18 -2e18 -1e18 0 1e18 2e18 3e18 4e18 5e18 6e18 7e18 8e18 9e18 10e18 11e18 12e18 13e18 14e18 15e18 16e18 17e18 18e18 20e18],label{m},[1.25 1.5  -1.08 -0.88]);
% end;


stop;

