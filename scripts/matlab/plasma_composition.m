%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plasma Composition setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%===================================================
% This script is a part of Analysis_B2.m script
%===================================================

%  ns - number of species

% Za(ns) - species charge
% Am(ns) - species mass number

% Amain - main ion mass number


% label(ns+1) - strings to label species in legends

switch Plasma_Composition
    

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D'
        ns = 2;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        

        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;


        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}'; 
        
        is_D01 = 2;  % species index of deuterium ion
        is_main = 2; % species index of main ion
        
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'T'
        ns = 2;        %%% number of species

        Amain = 3.0;
        
        Za(1)=0.0;  %% neutral T
        Za(2)=1.0;  %% T+
        

        Am(1)=3.0;  %% Tritium
        Am(2)=3.0;


        label=cell(ns+1);
        
        label{1}='T^{0}';
        label{2}='T^{+}'; 
        
        is_T01 = 2;  % species index of tritium ion
        is_main = 2; % species index of main ion
        
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_T'
        ns = 4;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral T
        Za(4)=1.0;  %% T+
        
        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=3.0;  %% Tritium
        Am(4)=3.0;


        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';   
        label{3}='T^{0}';
        label{4}='T^{+}';   

        is_D01 = 2;  % species index of deuterium ion
        is_T01 = 4;  % species index of tritium ion
        is_main = 2; % species index of main ion

    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_C_He'
        ns = 12;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral C
        Za(4)=1.0;  %% C+
        Za(5)=2.0;  %% C+2
        Za(6)=3.0;  %% C+3
        Za(7)=4.0;  %% C+4
        Za(8)=5.0;  %% C+5
        Za(9)=6.0;  %% C+6

        Za(10)=0.0;  %% neutral Helium
        Za(11)=1.0;  %% He+1
        Za(12)=2.0;  %% He+2

        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=12.0; %% Carbon
        Am(4)=12.0;
        Am(5)=12.0;
        Am(6)=12.0;
        Am(7)=12.0;
        Am(8)=12.0;
        Am(9)=12.0;

        Am(10)=4.0; %% Helium
        Am(11)=4.0;
        Am(12)=4.0;


        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='C^{0}';
        label{4}='C^{+1}';
        label{5}='C^{+2}';
        label{6}='C^{+3}';
        label{7}='C^{+4}';
        label{8}='C^{+5}';
        label{9}='C^{+6}';

        label{10}='He^{0}';
        label{11}='He^{+1}';
        label{12}='He^{+2}';
        
        is_D01 = 2;    % species index of deuterium ion
        is_C01 = 4;    % species index of C^{+1} ion
        is_C02 = 5;    % species index of C^{+2} ion
        is_C03 = 6;    % species index of C^{+3} ion
        is_C04 = 7;    % species index of C^{+4} ion
        is_C05 = 8;    % species index of C^{+5} ion
        is_C06 = 9;    % species index of C^{+6} ion
        is_He01 = 11;  % species index of He^{+1} ion
        is_He02 = 12;  % species index of He^{+2} ion
        is_main = 2; % species index of main ion

    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_He_C'
        ns = 12;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% He+0
        Za(4)=1.0;  %% He+1
        Za(5)=2.0;  %% He+2

        Za(6)=0.0;  %% neutral C
        Za(7)=1.0;  %% C+
        Za(8)=2.0;  %% C+2
        Za(9)=3.0;  %% C+3
        Za(10)=4.0;  %% C+4
        Za(11)=5.0;  %% C+5
        Za(12)=6.0;  %% C+6


        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=4.0; %% Helium
        Am(4)=4.0;
        Am(5)=4.0;

        Am(6)=12.0; %% Carbon
        Am(7)=12.0;
        Am(8)=12.0;
        Am(9)=12.0;
        Am(10)=12.0;
        Am(11)=12.0;
        Am(12)=12.0;

        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='He^{0}';
        label{4}='He^{+1}';
        label{5}='He^{+2}';

        label{6}='C^{0}';
        label{7}='C^{+1}';
        label{8}='C^{+2}';
        label{9}='C^{+3}';
        label{10}='C^{+4}';
        label{11}='C^{+5}';
        label{12}='C^{+6}';
        
        is_D01 = 2;     % species index of deuterium ion
        is_C01 = 7;     % species index of C^{+1} ion
        is_C02 = 8;     % species index of C^{+2} ion
        is_C03 = 9;     % species index of C^{+3} ion
        is_C04 = 10;    % species index of C^{+4} ion
        is_C05 = 11;    % species index of C^{+5} ion
        is_C06 = 12;    % species index of C^{+6} ion
        is_He01 = 4;    % species index of He^{+1} ion
        is_He02 = 5;    % species index of He^{+2} ion
        is_main = 2; % species index of main ion
        
            
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_C'
        ns = 9;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral C
        Za(4)=1.0;  %% C+
        Za(5)=2.0;  %% C+2
        Za(6)=3.0;  %% C+3
        Za(7)=4.0;  %% C+4
        Za(8)=5.0;  %% C+5
        Za(9)=6.0;  %% C+6


        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=12.0; %% Carbon
        Am(4)=12.0;
        Am(5)=12.0;
        Am(6)=12.0;
        Am(7)=12.0;
        Am(8)=12.0;
        Am(9)=12.0;

        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='C^{0}';
        label{4}='C^{+1}';
        label{5}='C^{+2}';
        label{6}='C^{+3}';
        label{7}='C^{+4}';
        label{8}='C^{+5}';
        label{9}='C^{+6}';
   
        is_D01 = 2;    % species index of deuterium ion
        is_C01 = 4;    % species index of C^{+1} ion
        is_C02 = 5;    % species index of C^{+2} ion
        is_C03 = 6;    % species index of C^{+3} ion
        is_C04 = 7;    % species index of C^{+4} ion
        is_C05 = 8;    % species index of C^{+5} ion
        is_C06 = 9;    % species index of C^{+6} ion
        is_main = 2; % species index of main ion
        
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_N'
        ns = 10;        %%% number of species

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral N
        Za(4)=1.0;  %% N+
        Za(5)=2.0;  %% N+2
        Za(6)=3.0;  %% N+3
        Za(7)=4.0;  %% N+4
        Za(8)=5.0;  %% N+5
        Za(9)=6.0;  %% N+6
        Za(9)=7.0;  %% N+6
        Za(10)=7.0;  %% N+7

        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=14.0; %% Nitrogen
        Am(4)=14.0;
        Am(5)=14.0;
        Am(6)=14.0;
        Am(7)=14.0;
        Am(8)=14.0;
        Am(9)=14.0;
        Am(10)=14.0;

        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='N^{0}';
        label{4}='N^{+1}';
        label{5}='N^{+2}';
        label{6}='N^{+3}';
        label{7}='N^{+4}';
        label{8}='N^{+5}';
        label{9}='N^{+6}';
        label{10}='N^{+7}';
   
        is_D01 = 2;    % species index of deuterium ion
        is_N01 = 4;    % species index of N^{+1} ion
        is_N02 = 5;    % species index of N^{+2} ion
        is_N03 = 6;    % species index of N^{+3} ion
        is_N04 = 7;    % species index of N^{+4} ion
        is_N05 = 8;    % species index of N^{+5} ion
        is_N06 = 9;    % species index of N^{+6} ion
        is_N07 = 10;    % species index of N^{+7} ion
        is_main = 2; % species index of main ion
        
         
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   

    otherwise
        disp('Plasma composition is not recognized. Stop.');
end;

label{ns+1}='electrons';
