clear all
shotnumber = 74957 %SOLPS MDS shotnumber
machine_name = 'JET'
title_case ='JET case for detachment - pulse 89241 at 48.5246s (i.e, no Nitrogen)';
legend_expt = 'JET pulse 89241 at 48.5246s';
legend_SOLPS = strcat('SOLPS run: ',int2str(shotnumber));
mdsopen('solps-mdsplus.aug.ipp.mpg.de:8001::solps',shotnumber)%JET case for detachment shot 89241, very little nitrogen and no feedback
nx = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NX');
ny = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NY');

r=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:R');
z=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:Z');
connlength=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:DSPAR')

na=mdsvalue('\SOLPS::TOP.SNAPSHOT:NA');
ne=mdsvalue('\SOLPS::TOP.SNAPSHOT:NE');
te=mdsvalue('\SOLPS::TOP.SNAPSHOT:TE');


figure('windowstyle','docked'); hold on;
axis equal;
title(strcat('Grid: ', machine_name, ' for SOLPS shotnumber: ',num2str(shotnumber)))

patch([reshape(r(:,:,1),[1 nx*ny]);...
       reshape(r(:,:,2),[1 nx*ny]);...
       reshape(r(:,:,4),[1 nx*ny]);...
       reshape(r(:,:,3),[1 nx*ny])],...
      [reshape(z(:,:,1),[1 nx*ny]);...
       reshape(z(:,:,2),[1 nx*ny]);...
       reshape(z(:,:,4),[1 nx*ny]);...
       reshape(z(:,:,3),[1 nx*ny])],'g');%reshape(ne,1,[]));

cr=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR');
omp = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:OMP');
sep=mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:SEP')
print -dpdf test.pdf
%mdsclose
%Now connect for Expt data on JET:
mdsconnect('mdsplus.jet.efda.org')
%Read in jetppf data:
%ppfread(pulse number, 'hrts',variable, 0, jetppf)% 'hrts' for midplane,%ky4d for target data
[y_exp,x_exp,t_exp] = ppfread(89241,'hrts','ne',0,'jetppf');
time_exp=find(abs(t_exp-48.5246)<0.01)%From array of t_exp, find index whose value matches with specific time in s, here 48.5246
xlen=length(x_exp) %length of array
figure('windowstyle','docked'); hold on;
plot(x_exp,y_exp(((xlen*time_exp)-(xlen-1)):xlen*time_exp),'b-o')


%NOW PLOT SOLPS RESULT:
%figure('windowstyle','docked'); hold on;
%plot wrt dist from separatrix:
%plot(cr(omp,:)-cr(omp,sep+2),ne(omp,:))
%plot wrt major radius on outer mid plane:
%plot(cr(omp,:),te(omp,:))
plot(cr(omp,:),ne(omp,:),'ko')

title(title_case)
ylabel('ne at outer midplane')
xlabel('Radial distance')
legend(legend_expt,legend_SOLPS)

%Plot te to compare with expt:
[y_exp,x_exp,t_exp] = ppfread(89241,'hrts','te',0,'jetppf');
time_exp=find(abs(t_exp-48.5246)<0.01)%From array of t_exp, find index whose value matches with specific time in s, here 48.5246
xlen=length(x_exp) %length of array
figure('windowstyle','docked'); hold on;
plot(x_exp,y_exp(((xlen*time_exp)-(xlen-1)):xlen*time_exp),'b-o')
%NOW PLOT SOLPS RESULT:
plot(cr(omp,:),te(omp,:),'ko')
title(title_case)
ylabel('te at outer midplane')
xlabel('Radial distance')
legend(legend_expt,legend_SOLPS)




load 'ne3da.last10';%in matlab load format, .last10 is considered extension to file name.
x_prof = ne3da(:,1)     
elec_den = ne3da(:,2)
figure('windowstyle','docked');%hold on;
%plot(x_prof,elec_den);
semilogy(x_prof,elec_den);
hold on;
legend('elec den driven')
ylabel('diffusivity') 
xlabel('Radial distance')    
title('SOLPS radial profile')
%unload 'ne3da.last10'


load 'dn3da.last10';%in matlab load format, .last10 is considered extension to file name.
x_prof = dn3da(:,1)     
particle_den = dn3da(:,2)
figure('windowstyle','docked');%hold on;
%plot(x_prof,particle_den);
semilogy(x_prof,particle_den);
hold on;
legend('particle den driven')
ylabel('diffusivity') 
xlabel('Radial distance')    
title('SOLPS radial profile')

load 'ki3da.last10';%in matlab load format, .last10 is considered extension to file name.
x_prof = ki3da(:,1)     
particle_den = ki3da(:,2)
figure('windowstyle','docked');%hold on;
%plot(x_prof,particle_den);
semilogy(x_prof,particle_den);
hold on;
legend('ion temp driven driven', 'Location', 'north')
ylabel('diffusivity') 
xlabel('Radial distance')    
title('SOLPS radial profile')


mdsclose
mdsdisconnect
