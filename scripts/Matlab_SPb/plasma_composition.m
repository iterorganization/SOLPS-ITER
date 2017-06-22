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
        label_string{1}='D00';
        label_string{2}='D01';
        
        is_D01 = 2;  % species index of deuterium ion
        is_main = 2; % species index of main ion
        
        Natmi = 1; % number of atoms in Eirene (here Deuterium and Nitrogen)
        Nmoli = 1; % number of molecules in Eirene (here D_2 molecules)
        Nioni = 1; % number of test ions in Eirene (here D+ ions)

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
        label_string{1}='T00';
        label_string{2}='T01';
       
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

        label_string{1}='D00';
        label_string{2}='D01';
        label_string{3}='T00';
        label_string{4}='T01';

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
        
        label_string{1}='D00';
        label_string{2}='D01';

        label_string{10}='He00';
        label_string{11}='He01';
        label_string{12}='He02';

        label_string{3}='C00';
        label_string{4}='C01';
        label_string{5}='C02';
        label_string{6}='C03';
        label_string{7}='C04';
        label_string{8}='C05';
        label_string{9}='C06';

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
        
        label_string{1}='D00';
        label_string{2}='D01';

        label_string{3}='He00';
        label_string{4}='He01';
        label_string{5}='He02';

        label_string{6}='C00';
        label_string{7}='C01';
        label_string{8}='C02';
        label_string{9}='C03';
        label_string{10}='C04';
        label_string{11}='C05';
        label_string{12}='C06';

        
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
   
        label_string{1}='D00';
        label_string{2}='D01';

        label_string{3}='C00';
        label_string{4}='C01';
        label_string{5}='C02';
        label_string{6}='C03';
        label_string{7}='C04';
        label_string{8}='C05';
        label_string{9}='C06';
        
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
        
        natm = 2;       %%% number of atom/ion sorts
        Zatm = zeros(natm,1);  %%% charge state of atom nuclei
        
        Zatm(1) = 1;
        Zatm(2) = 7;

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
   
        label_string{1}='D00';
        label_string{2}='D01';

        label_string{3}='N00';
        label_string{4}='N01';
        label_string{5}='N02';
        label_string{6}='N03';
        label_string{7}='N04';
        label_string{8}='N05';
        label_string{9}='N06';
        label_string{10}='N07';

        is_D01 = 2;    % species index of deuterium ion
        is_N01 = 4;    % species index of N^{+1} ion
        is_N02 = 5;    % species index of N^{+2} ion
        is_N03 = 6;    % species index of N^{+3} ion
        is_N04 = 7;    % species index of N^{+4} ion
        is_N05 = 8;    % species index of N^{+5} ion
        is_N06 = 9;    % species index of N^{+6} ion
        is_N07 = 10;    % species index of N^{+7} ion
        is_main = 2; % species index of main ion
        
        Natmi = 2; % number of atoms in Eirene (here Deuterium and Nitrogen)
        Nmoli = 1; % number of molecules in Eirene (here D_2 molecules)
        Nioni = 1; % number of test ions in Eirene (here D+ ions)
        
        eir_atom(1) = 1;
        eir_atom(2) = 1;
        eir_atom(3) = 2;
        eir_atom(4) = 2;
        eir_atom(5) = 2;
        eir_atom(6) = 2;
        eir_atom(7) = 2;
        eir_atom(8) = 2;
        eir_atom(9) = 2;
        eir_atom(10) = 2;
        eir_mol(1) = 1;
        eir_mol(2) = 1;
        eir_mol(3) = 2;
        eir_mol(4) = 2;
        eir_mol(5) = 2;
        eir_mol(6) = 2;
        eir_mol(7) = 2;
        eir_mol(8) = 2;
        eir_mol(9) = 2;
        eir_mol(10) = 2;
        
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_Ne'
        ns = 13;        %%% number of species
        
        natm = 2;       %%% number of atom/ion sorts
        Zatm = zeros(natm,1);  %%% charge state of atom nuclei
        
        Zatm(1) = 1;
        Zatm(2) = 10;

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral Ne
        Za(4)=1.0;  %% Ne+
        Za(5)=2.0;  %% Ne+2
        Za(6)=3.0;  %% Ne+3
        Za(7)=4.0;  %% Ne+4
        Za(8)=5.0;  %% Ne+5
        Za(9)=6.0;  %% Ne+6
        Za(10)=7.0;  %% Ne+7
        Za(11)=8.0;  %% Ne+8
        Za(12)=9.0;  %% Ne+9
        Za(13)=10.0;  %% Ne+10


        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=20.0; %% Neon
        Am(4)=20.0;
        Am(5)=20.0;
        Am(6)=20.0;
        Am(7)=20.0;
        Am(8)=20.0;
        Am(9)=20.0;
        Am(10)=20.0;
        Am(11)=20.0;
        Am(12)=20.0;
        Am(13)=20.0;

        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='Ne^{0}';
        label{4}='Ne^{+1}';
        label{5}='Ne^{+2}';
        label{6}='Ne^{+3}';
        label{7}='Ne^{+4}';
        label{8}='Ne^{+5}';
        label{9}='Ne^{+6}';
        label{10}='Ne^{+7}';
        label{11}='Ne^{+8}';
        label{12}='Ne^{+9}';
        label{13}='Ne^{+10}';
   
        label_string{1}='D00';
        label_string{2}='D01';

        label_string{3}='Ne00';
        label_string{4}='Ne01';
        label_string{5}='Ne02';
        label_string{6}='Ne03';
        label_string{7}='Ne04';
        label_string{8}='Ne05';
        label_string{9}='Ne06';
        label_string{10}='Ne07';
        label_string{11}='Ne08';
        label_string{12}='Ne09';
        label_string{13}='Ne10';

        is_D01 = 2;    % species index of deuterium ion
        is_Ne01 = 4;    % species index of Ne^{+1} ion
        is_Ne02 = 5;    % species index of Ne^{+2} ion
        is_Ne03 = 6;    % species index of Ne^{+3} ion
        is_Ne04 = 7;    % species index of Ne^{+4} ion
        is_Ne05 = 8;    % species index of Ne^{+5} ion
        is_Ne06 = 9;    % species index of Ne^{+6} ion
        is_Ne07 = 10;    % species index of Ne^{+7} ion
        is_Ne08 = 11;    % species index of Ne^{+7} ion
        is_Ne09 = 12;    % species index of Ne^{+7} ion
        is_Ne10 = 13;    % species index of Ne^{+7} ion
        is_main = 2; % species index of main ion         

        Natmi = 2; % number of atoms in Eirene (here Deuterium and Nitrogen)
        Nmoli = 1; % number of molecules in Eirene (here D_2 molecules)
        Nioni = 1; % number of test ions in Eirene (here D+ ions)

        eir_atom(1) = 1;
        eir_atom(2) = 1;
        eir_atom(3) = 2;
        eir_atom(4) = 2;
        eir_atom(5) = 2;
        eir_atom(6) = 2;
        eir_atom(7) = 2;
        eir_atom(8) = 2;
        eir_atom(9) = 2;
        eir_atom(10) = 2;
        eir_atom(11) = 2;
        eir_atom(12) = 2;
        eir_atom(13) = 2;
        eir_mol(1) = 1;
        eir_mol(2) = 1;
        eir_mol(3) = 2;
        eir_mol(4) = 2;
        eir_mol(5) = 2;
        eir_mol(6) = 2;
        eir_mol(7) = 2;
        eir_mol(8) = 2;
        eir_mol(9) = 2;
        eir_mol(10) = 2;
        eir_mol(11) = 2;
        eir_mol(12) = 2;
        eir_mol(13) = 2;

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    case 'D_He_Ne'
        ns = 16;        %%% number of species
        
        natm = 3;       %%% number of atom/ion sorts
        Zatm = zeros(natm,1);  %%% charge state of atom nuclei
        
        Zatm(1) = 1;
        Zatm(2) = 2;
        Zatm(3) = 10;

        Amain = 2.0;
        
        Za(1)=0.0;  %% neutral D
        Za(2)=1.0;  %% D+
        
        Za(3)=0.0;  %% neutral He
        Za(4)=1.0;  %% He+
        Za(5)=2.0;  %% He+2

        Za(6)=0.0;  %% neutral Ne
        Za(7)=1.0;  %% Ne+
        Za(8)=2.0;  %% Ne+2
        Za(9)=3.0;  %% Ne+3
        Za(10)=4.0;  %% Ne+4
        Za(11)=5.0;  %% Ne+5
        Za(12)=6.0;  %% Ne+6
        Za(13)=7.0;  %% Ne+7
        Za(14)=8.0;  %% Ne+8
        Za(15)=9.0;  %% Ne+9
        Za(16)=10.0;  %% Ne+10


        Am(1)=2.0;  %% Deuterium
        Am(2)=2.0;

        Am(3)=4.0; %% Helium
        Am(4)=4.0;
        Am(5)=4.0;

        Am(6)=20.0; %% Neon
        Am(7)=20.0;
        Am(8)=20.0;
        Am(9)=20.0;
        Am(10)=20.0;
        Am(11)=20.0;
        Am(12)=20.0;
        Am(13)=20.0;
        Am(14)=20.0;
        Am(15)=20.0;
        Am(16)=20.0;

        label=cell(ns+1);
        
        label{1}='D^{0}';
        label{2}='D^{+}';

        label{3}='He^{0}';
        label{4}='He^{+1}';
        label{5}='He^{+2}';

        label{6}='Ne^{0}';
        label{7}='Ne^{+1}';
        label{8}='Ne^{+2}';
        label{9}='Ne^{+3}';
        label{10}='Ne^{+4}';
        label{11}='Ne^{+5}';
        label{12}='Ne^{+6}';
        label{13}='Ne^{+7}';
        label{14}='Ne^{+8}';
        label{15}='Ne^{+9}';
        label{16}='Ne^{+10}';
   
        is_D01 = 2;    % species index of deuterium ion

        is_He01 = 4;    % species index of He^{+1} ion
        is_He02 = 5;    % species index of He^{+2} ion

        is_Ne01 = 7;    % species index of Ne^{+1} ion
        is_Ne02 = 8;    % species index of Ne^{+2} ion
        is_Ne03 = 9;    % species index of Ne^{+3} ion
        is_Ne04 = 10;    % species index of Ne^{+4} ion
        is_Ne05 = 11;    % species index of Ne^{+5} ion
        is_Ne06 = 12;    % species index of Ne^{+6} ion
        is_Ne07 = 13;    % species index of Ne^{+7} ion
        is_Ne08 = 14;    % species index of Ne^{+7} ion
        is_Ne09 = 15;    % species index of Ne^{+7} ion
        is_Ne10 = 16;    % species index of Ne^{+7} ion
        is_main = 2; % species index of main ion         

        Natmi = 3; % number of atoms in Eirene (here Deuterium and Nitrogen)
        Nmoli = 1; % number of molecules in Eirene (here D_2 molecules)
        Nioni = 1; % number of test ions in Eirene (here D+ ions)
        
        eir_atom(1) = 1;
        eir_atom(2) = 1;
        eir_atom(3) = 2;
        eir_atom(4) = 2;
        eir_atom(5) = 2;
        eir_atom(6) = 3;
        eir_atom(7) = 3;
        eir_atom(8) = 3;
        eir_atom(9) = 3;
        eir_atom(10) = 3;
        eir_atom(11) = 3;
        eir_atom(12) = 3;
        eir_atom(13) = 3;
        eir_atom(14) = 3;
        eir_atom(15) = 3;
        eir_atom(16) = 3;
        eir_mol(1) = 1;
        eir_mol(2) = 1;
        eir_mol(3) = 2;
        eir_mol(4) = 2;
        eir_mol(5) = 2;
        eir_mol(6) = 3;
        eir_mol(7) = 3;
        eir_mol(8) = 3;
        eir_mol(9) = 3;
        eir_mol(10) = 3;
        eir_mol(11) = 3;
        eir_mol(12) = 3;
        eir_mol(13) = 3;
        eir_mol(14) = 3;
        eir_mol(15) = 3;
        eir_mol(16) = 3;
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   

    otherwise
        disp('Plasma composition is not recognized. Stop.');
end;

label{ns+1}='electrons';
