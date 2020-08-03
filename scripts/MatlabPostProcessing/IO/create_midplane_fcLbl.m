clc
clear all
close all
addpath /vsc-hard-mounts/leuven-data/321/vsc32100/solps-iter_ad/scripts/MatlabPostProcessing/IO
addpath /vsc-hard-mounts/leuven-data/321/vsc32100/solps-iter_ad/scripts/MatlabPostProcessing/Plotting

gmtry = read_b2fgmtry_us('./baserun/b2fgmtry');

ymid = 5.0; %define vertical distance at which midplane is located
eps=1e-3;
vv = abs(ymid-gmtry.vxY)<eps; %find vertices 'close enough' to the desired axial distance
ind = 1:gmtry.nVx; ind=ind(vv); %find their indexes

cost=[];
cc=1;
for kk=1:gmtry.nFc
    %for any face, check if both its vertices belongs to the list made
    %before
    if any(gmtry.fcVx(kk,1)==ind) & any(gmtry.fcVx(kk,2)==ind)
        cost(cc)=kk;
        cc=cc+1;
    end
end

figure
plotgrid(gmtry)
% Plot in red only faces belonging to identified midplane
for iCv = 1:gmtry.nCi
    rco = [];
	zco = [];
	for iFc = 1:gmtry.cvFcP(iCv,2)
        if any(gmtry.cvFc(gmtry.cvFcP(iCv,1)+iFc-1)==cost)
            rco    = [rco,[gmtry.vxX(gmtry.fcVx(gmtry.cvFc(gmtry.cvFcP(iCv,1)+iFc-1),1));...
                          gmtry.vxX(gmtry.fcVx(gmtry.cvFc(gmtry.cvFcP(iCv,1)+iFc-1),2))]];
            zco    = [zco,[gmtry.vxY(gmtry.fcVx(gmtry.cvFc(gmtry.cvFcP(iCv,1)+iFc-1),1));...
                          gmtry.vxY(gmtry.fcVx(gmtry.cvFc(gmtry.cvFcP(iCv,1)+iFc-1),2))]];
        end
    end
	plot(rco,zco,'r*-');hold on;  
end
label = 33; %choose lebel
if (any(gmtry.fcLbl==label))
    msgbox('Selected label is already being used in b2fgmtry', 'Error','error');
    error('Invalid label value')
end
gmtry.fcLbl(cost) = label; %assign desired label




write_b2fgmtry_us('b2fgmtry_new','test',gmtry)

% test new generated geometry
gmtry = read_b2fgmtry_us('b2fgmtry_new');
gmtry.fcLbl(cost)
