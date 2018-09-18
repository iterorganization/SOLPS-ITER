%set(0,'DefaultFigureWindowStyle','docked')
%format compact

Level_ne=[0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0,6.0,7.0,8.0,9.0,10.0,11.0,12.0,13.0,14,0,15.0,16.0,17.0,18.0,19.0,20.0,22.0,25.0,26.0,28.0,30.0,40.0,50.0,60.0];%, 80.0, 100.0];
figure;
Figname='ne';
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ne*1.0e-19,'$n_e, \; \rm 10^{19} \; m^{-3}$',Figname,Level_ne,label2D,Plot2DMargins);
%axis equal;
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);

Level_ne_log=logspace(0,2,100);
figure;
Figname='ne_log10';
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(ne*1.0e-19),'$n_e, \; \rm 10^{19} \; m^{-3}$','ne_log10',log10(Level_ne_log),label2D,Plot2DMargins);
%axis equal;
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);



Level_na=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5, 0.8 1.0 1.5 2.0 3.0 5.0 8.0 10.0 12.0 15.0 20.0 30.0];

if exist('is_D01','var')
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_D01-1)*1.0e-19,['$n_{',label{is_D01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nD00',Level_na,label2D,Plot2DMargins);
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_D01)*1.0e-19,['$n_{',label{is_D01},'}, \; \rm 10^{19} \; m^{-3}$'],'nD01',Level_ne,label2D,Plot2DMargins);
    Level_ne_log=logspace(0,1.69896,50);
    figure;
    Level_nD_log=logspace(1.69896-3,1.69896,50);
    Figname='nD_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((na(:,:,is_D01-1)+2*nD2+na(:,:,is_D01))*1.0e-19),'$n_D, \; \rm 10^{19} \; m^{-3}$',Figname,log10(Level_nD_log),label2D,Plot2DMargins_whole);
    %axis equal;
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);end;

if exist('is_T01','var')
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_T01-1)*1.0e-19,['$n_{',label{is_T01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nD00',Level_ne,label2D,Plot2DMargins);
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_T01)*1.0e-19,['$n_{',label{is_T01},'}, \; \rm 10^{19} \; m^{-3}$'],'nD01',Level_ne,label2D,Plot2DMargins);
end;

%Level_dna = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0 2.4 2.8 3.2 3.6 4.0];
Level_dna = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.5 1.8 2.0 2.5 3.0 5.0 8.0 10.0];

plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,dna(:,:,is_main),'$D_{\rm main ions} \; m^{2}/s$','DNA_D01',Level_dna,label2D,Plot2DMargins);

if EIRENE_flag==1
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,nD2*1.0e-19,'$n_{D_2}, \; \rm 10^{19} \; m^{-3}$','nD2',Level_na,label2D,Plot2DMargins);
% %     figure;
%    plot_Eirene_profiles2(PATH_PREFIX,pdena(:,1)/1.0e19,['$n_{',label{is_D01-1},'}, \; \rm 10^{19} \; m^{-3}, from \; Eirene$'],'nD0_EIR',Level_na,label2D,Plot2DMargins_whole);
% %     figure;
    plot_Eirene_profiles2(PATH_PREFIX,(2*pdenm(:,1)+pdena(:,1))/1.0e19,'$2*n_{D_2}+n_D, \; \rm 10^{19} \; m^{-3}, from \; Eirene$','nD_EIR',Level_na*3,label2D,Plot2DMargins_whole);
%    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,tD2,'$T_{D_2}, \; \rm eV$','TD2',[0.01 0.02 0.05 0.1 0.2 0.5 0.8 1.0 1.2 1.5 1.8 2.0 2.5 3.0 5.0 8.0 10.0 12.0 15.0],label2D,Plot2DMargins);
    Level_pD2 = [0.002 0.005 0.008 0.01 0.02 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.8 2.0 2.5 3.0 4.0 5.0 6.0 7.0 8.0 10.0];
     % figure;
    plot_Eirene_profiles2(PATH_PREFIX,(edena(:,1)+edena(:,2))*2.0/3.0,'$\rm D \; neutral \; pressure \; (a+m) \; \frac23 \left<n E\right>, \; Pa, \; from \; Eirene$','pD_EIR',Level_pD2,label2D,Plot2DMargins_whole);
% %     figure;
% %      plot_Eirene_profiles2(PATH_PREFIX,edenm(:,1)*2.0/3.0,'$\rm D_2 \; molecule \; pressure \; \frac23 \left<n E\right>, \; Pa, \; from \; Eirene$','pD2_EIR',Level_pD2,label2D,Plot2DMargins_whole);
% % % %       plot_Eirene_profiles2(PATH_PREFIX,edenN_tot*2.0/3.0,'$\rm total \; neutral \; pressure \; \frac23 \left<n E\right>, \; Pa, \; from \; Eirene$','ptot_EIR',Level_pD2,label2D,Plot2DMargins_whole);
% %      if exp_data_flag && exist('exp_data_neutral_flux_flux','var')
% %          plot(exp_data_neutral_flux_RZ(:,1),exp_data_neutral_flux_RZ(:,2),'LineStyle','none','LineWidth',3,'MarkerSize',12,'Marker','d','MarkerFaceColor','r');
% %      end;
% %      plot([exp_data_neutral_flux_RZ(5,1) 1.84],[exp_data_neutral_flux_RZ(5,2) -1.3],'LineWidth',3,'Color','r');
% %      plot([exp_data_neutral_flux_RZ(9,1) 2.02],[exp_data_neutral_flux_RZ(9,2) -1.18],'LineWidth',3,'Color','r');
     %    tdenm=2.0/3.0*edenm(:,1)./max(pdenm(:,1),1.0e10)/qe;
%    plot_Eirene_profiles2(PATH_PREFIX,tdenm,'$\rm D_2 \; molecule \; temperature \; eV \; from \; Eirene$','TD2_EIR',[0.01 0.02 0.05 0.1 0.2 0.5 0.8 1.0 1.2 1.5 1.8 2.0 2.5 3.0 5.0 8.0 10.0 12.0 15.0],label2D,Plot2DMargins);
end;

if exist('is_He01','var')
    Level_nHe2=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5, 0.8 1.0 1.5 2.0]; 
    Level_nHe1=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1 0.12 0.14 0.16 0.18 0.2]; 

    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_He01-1)*1.0e-19,['$n_{',label{is_He01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nN00',Level_nHe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_He01)*1.0e-19,['$n_{',label{is_He01},'}, \; \rm 10^{19} \; m^{-3}$'],'nN01',Level_nHe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_He02)*1.0e-19,['$n_{',label{is_He02},'}, \; \rm 10^{19} \; m^{-3}$'],'nN02',Level_nHe2,label2D,Plot2DMargins);

    Level_nCtot=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(nHe_tot)*1.0e-19,'$n_{He^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nHetot',Level_nHe2,label2D,Plot2DMargins);
end;

if exist('is_C01','var')
    Level_nC1=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5,0.8,1.0,1.5,2.0]; 
    Level_nC4=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5]; 
    Level_nC6=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1]; 

% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C01-1)*1.0e-19,['$n_{',label{is_C01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nC00',Level_nC1,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C01)*1.0e-19,['$n_{',label{is_C01},'}, \; \rm 10^{19} \; m^{-3}$'],'nC01',Level_nC1,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C02)*1.0e-19,['$n_{',label{is_C02},'}, \; \rm 10^{19} \; m^{-3}$'],'nC02',Level_nC1,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C03)*1.0e-19,['$n_{',label{is_C03},'}, \; \rm 10^{19} \; m^{-3}$'],'nC03',Level_nC4,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C04)*1.0e-19,['$n_{',label{is_C04},'}, \; \rm 10^{19} \; m^{-3}$'],'nC04',Level_nC4,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C05)*1.0e-19,['$n_{',label{is_C05},'}, \; \rm 10^{19} \; m^{-3}$'],'nC05',Level_nC6,label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_C06)*1.0e-19,['$n_{',label{is_C06},'}, \; \rm 10^{19} \; m^{-3}$'],'nC06',Level_nC6,label2D,Plot2DMargins);

    Level_nCtot=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    Level_nCtot=[0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(nC_tot)*1.0e-19,'$n_{C^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nCtot',Level_nC1,label2D,Plot2DMargins);
    figure;
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nC_tot*1.0e-19),'$n_{C^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nCtot_log10',log10(Level_nCtot),label2D,Plot2DMargins);
end;

if exist('is_N01','var')
    Level_nN1=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5,0.8,1.0,1.5,2.0,2.5,3.0,3.5,4.0,5.0]./5.0; 
    Level_nN2=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5,0.8,1.0,1.5,2.0]./5.0; 
    Level_nN4=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2,0.3,0.5]./5.0; 
    Level_nN7=[1e-7, 5e-7, 1e-6, 5e-6, 0.00001, 0.00003, 0.00008,0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1]; 
    
    Level_nN_log=logspace(-5,-0.698971,100);
    Level_nN_log=logspace(-5,-2,50);

    figure;
     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N01-1)*1.0e-19),['$n_{',label{is_N01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nN00_log10',log10(Level_nN_log),label2D,Plot2DMargins);
     if EIRENE_flag==1
% % %         figure;
      plot_Eirene_profiles2(PATH_PREFIX,pdena(:,2)/1.0e19,['$n_{',label{is_N01-1},'}, \; \rm 10^{19} \; m^{-3}, from \; Eirene$'],'nN0_EIR',Level_nN7,label2D,Plot2DMargins_whole);%[0.9 2.22  -1.35 -0.25]);
% % %         figure;
% % %         plot_Eirene_profiles2(PATH_PREFIX,edena(:,2)*2.0/3.0,'$\rm N \; atom \; pressure \; \frac23 \left<n E\right>, \; Pa, \; from \; Eirene$','pN_EIR',Level_pD2/100,label2D,Plot2DMargins);
% % % %        tdena=2.0/3.0*edena(:,2)./max(pdena(:,2),1.0e10)/qe;
% % % %         plot_Eirene_profiles2(PATH_PREFIX,tdena,'$\rm N \; atom \; temperature, \frac23 \left<n E\right>/\left<n\right> \; eV \; from \; Eirene$','TN_EIR',[0.01 0.02 0.03 0.04 0.05 0.06 0.08 0.1],label2D,Plot2DMargins);
    end;
    
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N01)*1.0e-19),['$n_{',label{is_N01},'}, \; \rm 10^{19} \; m^{-3}$'],'nN01_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N02)*1.0e-19),['$n_{',label{is_N02},'}, \; \rm 10^{19} \; m^{-3}$'],'nN02_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N03)*1.0e-19),['$n_{',label{is_N03},'}, \; \rm 10^{19} \; m^{-3}$'],'nN03_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N04)*1.0e-19),['$n_{',label{is_N04},'}, \; \rm 10^{19} \; m^{-3}$'],'nN04_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N05)*1.0e-19),['$n_{',label{is_N05},'}, \; \rm 10^{19} \; m^{-3}$'],'nN05_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N06)*1.0e-19),['$n_{',label{is_N06},'}, \; \rm 10^{19} \; m^{-3}$'],'nN06_log10',log10(Level_nN_log),label2D,Plot2DMargins);
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(na(:,:,is_N07)*1.0e-19),['$n_{',label{is_N07},'}, \; \rm 10^{19} \; m^{-3}$'],'nN07_log10',log10(Level_nN_log),label2D,Plot2DMargins);

    Level_nCtot=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0];
    figure;
    Figname='nNtot_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nN_tot*1.0e-19),'$n_{N^{\rm total}}, \; \rm 10^{19} \; m^{-3}$',Figname,log10(Level_nN_log),label2D,Plot2DMargins_whole);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);
    figure;
    Figname='nNch_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nN_ch*1.0e-19),'$n_{N^{\rm ions}}, \; \rm 10^{19} \; m^{-3}$',Figname,log10(Level_nN_log),label2D,Plot2DMargins_whole);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);    
    

    Level_nNrel_log=logspace(-3,0,30);
    figure;
    Figname='nNrel_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nN_tot/max(max(nN_tot))),'$n_{N}/n_N^{(max)}$',Figname,log10(Level_nNrel_log),label2D,Plot2DMargins_whole);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);    
    
% %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,nN_tot*1.0e-19,'$n_{N^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nNtot',Level_nN1,label2D,Plot2DMargins);
% %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,nN_tot*1.0e-19,'$n_{N^{\rm total}}, \; \rm 10^{19} \; m^{-3}$','nNtot_sq',Level_nN1*5.0,label2D,Plot2DMargins_whole);
end;

if exist('is_Ne01','var')
    Level_nNe1=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04,0.05,0.06,0.08,0.1,0.15,0.2]; 
    Level_nNe6=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02]; 
    Level_nNe8=[0.0001,0.0003,0.0008,0.001,0.002,0.004,0.006,0.008,0.01,0.02,0.03,0.04]; 

    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne01-1)*1.0e-19,['$n_{',label{is_Ne01-1},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe00',Level_nNe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne01)*1.0e-19,['$n_{',label{is_Ne01},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe01',Level_nNe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne02)*1.0e-19,['$n_{',label{is_Ne02},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe02',Level_nNe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne03)*1.0e-19,['$n_{',label{is_Ne03},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe03',Level_nNe1,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne04)*1.0e-19,['$n_{',label{is_Ne04},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe04',Level_nNe6,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne05)*1.0e-19,['$n_{',label{is_Ne05},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe05',Level_nNe6,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne06)*1.0e-19,['$n_{',label{is_Ne06},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe06',Level_nNe6,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne07)*1.0e-19,['$n_{',label{is_Ne07},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe07',Level_nNe6,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne08)*1.0e-19,['$n_{',label{is_Ne08},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe08',Level_nNe8,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne09)*1.0e-19,['$n_{',label{is_Ne09},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe09',Level_nNe8,label2D,Plot2DMargins);
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,na(:,:,is_Ne10)*1.0e-19,['$n_{',label{is_Ne10},'}, \; \rm 10^{19} \; m^{-3}$'],'nNe10',Level_nNe8,label2D,Plot2DMargins);

    Level_nNe_log=logspace(-5,-0.698971-1,100);
    figure;
    Figname='nNetot_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nNe_tot*1.0e-19),'$n_{Ne^{\rm total}}, \; \rm 10^{19} \; m^{-3}$',Figname,log10(Level_nNe_log),label2D,Plot2DMargins_whole);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);    
    figure;
    Figname='nNech_log10';
    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(nNe_ch*1.0e-19),'$n_{Ne^{\rm ions}}, \; \rm 10^{19} \; m^{-3}$',Figname,log10(Level_nNe_log),label2D,Plot2DMargins_whole);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);    
end;

Level_Zeff=[1.0,1.05,1.1,1.15,1.2,1.25,1.3,1.35,1.4,1.45,1.5,1.55,1.6,1.65,1.7,1.75,1.8,1.85,1.9,1.95,2.0,2.05,2.1,2.15,2.2,2.25,2.3,2.35,2.4,2.45,2.5,2.55,2.6,2.65,2.7,2.75,2.8,2.85,2.9,2.95,3.0]; 
figure;
Figname='Zeff';
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,Zeff,'$Z_{eff}$',Figname,Level_Zeff,label2D,Plot2DMargins_whole);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);    


  if exist('is_D01','var')
% % %     Level_uaD=[-6e4 -5e4 -4e4 -3e4 -2e4 -1.6e4 -1.2e4 -0.8e4 -0.4e4 -0.2e4 -0.1e4 -0.6e3 -0.4e3 -0.2e3 -0.1e3 0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4];
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01),['$u_{',label{is_D01},'}, \; m/s$'],'uD01',Level_uaD,label2D,Plot2DMargins);
% % %     Level_MachD=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
% % % %    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01)./cs_mi,['$M_{',label{is_D01},'}, $'],'MD01',Level_MachD,label2D,Plot2DMargins);
      figure;
      Figname='uD01_arrows';
      plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_D01)/1000,['$u_{||',label{is_D01},'}, \; \rm km/s$'],Figname,[-3.0e4 0 3.0e4]/1000,Plot2DMargins,'center');
      print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
 end;
% % % 
% % % if exist('is_T01','var')
% % %     Level_uaT=[-6e4 -5e4 -4e4 -3e4 -2e4 -1.6e4 -1.2e4 -0.8e4 -0.4e4 -0.2e4 -0.1e4 -0.6e3 -0.4e3 -0.2e3 -0.1e3 0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4];
% % %     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01),['$u_{',label{is_T01},'}, \; m/s$'],'uT01',Level_uaD,label2D,Plot2DMargins);
% % %     Level_MachT=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
% % % %    plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01)./cs_mi,['$M_{',label{is_T01},'}, $'],'MT01',Level_MachT,label2D,Plot2DMargins);
% % %     plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_T01),['$u_{',label{is_T01},'}$'],'uT01_arrows',Plot2DMargins);
% % % end;
% % % 
% % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,cs,['$cs, \; m/s$'],'cs',...
% % %     [0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4 7e4 8e4 1e5 1.2e5 1.5e5],label2D,Plot2DMargins);


 if exist('is_N01','var')
%     Level_uaN=[-6e4 -5e4 -4e4 -3e4 -2e4 -1.6e4 -1.2e4 -0.8e4 -0.4e4 -0.2e4 -0.1e4 -0.6e3 -0.4e3 -0.2e3 -0.1e3 0 0.1e3 0.2e3 0.1e4 0.2e4 0.4e4 0.8e4 1.2e4 1.6e4 2e4 3e4 4e4 5e4 6e4]; 
% 
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N01-1)*1.0e-3,['$u_{|| ',label{is_N01-1},'}, \; \rm km/s$'],'uN00',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N01)*1.0e-3,['$u_{|| ',label{is_N01},'}, \; \rm km/s$'],'uN01',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N02)*1.0e-3,['$u_{|| ',label{is_N02},'}, \; \rm km/s$'],'uN02',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N03)*1.0e-3,['$u_{|| ',label{is_N03},'}, \; \rm km/s$'],'uN03',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N04)*1.0e-3,['$u_{|| ',label{is_N04},'}, \; \rm km/s$'],'uN04',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N05)*1.0e-3,['$u_{|| ',label{is_N05},'}, \; \rm km/s$'],'uN05',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N06)*1.0e-3,['$u_{|| ',label{is_N06},'}, \; \rm km/s$'],'uN06',Level_uaN,label2D,Plot2DMargins);
%     plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,is_N07)*1.0e-3,['$u_{|| ',label{is_N07},'}, \; \rm km/s$'],'uN07',Level_uaN,label2D,Plot2DMargins);
     figure;
     Figname='uN_ch_avr_arrows';
     plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,uaN_ch_avr/1000,['$u_{||N}, \; \rm km/s $'],Figname,[-3.0e4 0 3.0e4]/1000,Plot2DMargins,'center');
     print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
     figure;
     Figname='Gamma_N_ch_avr_arrows';
     plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,fnax_mdf_N_ch+fnax_dia_N_ch+fnax_PSch_N_ch,['$\Gamma_{xN}, \; \rm s^{-1} $'],Figname,[-1.0e18 0 1.0e18],Plot2DMargins,'face  ');
     print('-depsc2',[PATH_PREFIX,Figname,'.eps']);

end;


% Level_Mach=[-3.0 -2.5 -2.0 -1.5 -1.0 -0.9 -0.8 -0.7 -0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.5 2.0 2.5 3.0];
% plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ua(:,:,2)./cs_mi,'$M_{D^{+}}, $','MD01',Level_Mach,label2D,Plot2DMargins);



Level_potential=[-100,-70,-50,-20,-10,-5,0,5,10,15,20,25,30,35,40,45,50,60,70,80,90,100]; %,110,120,130,140,150,200];
%Level_potential=[0,5,10,15,20,25,30,35,40,45,50,60,70,80,90,100];
figure;
Figname='po'
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,po,'$\varphi, \; \rm V$',Figname,Level_potential,label2D,Plot2DMargins);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);  

Level_phiTe=[-50 -40 -30 -25 -20 -18 -16 -14 -12 -10 -8 -6 -4 -2 0 2 4 6 8 10 12 14 16 18 20 25 30 40 45 50 60];
figure;
Figname='poTe';
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,po./te,'$\varphi/T_e$',Figname,Level_phiTe,label2D,Plot2DMargins);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);  


% % Level_Te=[0.1,0.2,0.5,0.8,1.0,1.5,2.0,2.5,3.0,5.0,8.0,10.0,12.0,14.0,16.0,18.0,20.0,24.0,28.0,32.0,36.0,40.0,50.0,60.0,70.0,80.0,90.0,100.0,120.0,150.0];
% % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te',Level_Te,label2D,Plot2DMargins);
% % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti',Level_Te,label2D,Plot2DMargins);
Level_Te_log=logspace(0,3);
figure;
Figname='Te_log10';
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(te),'$T_e, \; \rm eV$',Figname,log10(Level_Te_log),label2D,Plot2DMargins);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);  

figure;
Figname='Ti_log10';
iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(ti),'$T_i, \; \rm eV$',Figname,log10(Level_Te_log),label2D,Plot2DMargins);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);  


% % % Level_Te=[0.1,0.2,0.5,0.8,1.0,1.2,1.5,2.0,2.5,3.0,5.0,8.0,10.0];
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te1',Level_Te,label2D,Plot2DMargins);
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti1',Level_Te,label2D,Plot2DMargins);
% % % 
% % % Level_Te=[0.1,0.2,0.5,0.8,1.0,1.2,1.5,2.0,2.5,3.0,5.0,8.0,10.0,20.0,30.0,40.0];
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,te,'$T_e, \; \rm eV$','Te2',Level_Te,label2D,Plot2DMargins);
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,ti,'$T_i, \; \rm eV$','Ti2',Level_Te,label2D,Plot2DMargins);
% % % 
% % % Level_hce = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0 2.4 2.8 3.2 3.6 4.0 4.4 4.8 5.2 5.6 6.0 7.0 8.0 9.0 10.0 12.0 14.0 16.0 18.0 20.0];
% % % Level_hce = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2];
% % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,hce,'$\chi_{e} \; m^{2}/s$','HCE',Level_hce,label2D,Plot2DMargins);
% % % 
% % % Level_hci = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2 1.4 1.6 1.8 2.0 2.4 2.8 3.2 3.6 4.0 4.4 4.8 5.2 5.6 6.0 7.0 8.0 9.0 10.0 12.0 14.0 16.0 18.0 20.0];
% % % Level_hci = [0.02 0.03 0.04 0.05 0.08 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.2];
% % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,hci(:,:,ns+1),'$\chi_{i} \; m^{2}/s$','HCI',Level_dna,label2D,Plot2DMargins_whole);

figure;
Figname='p_tot';
iout= plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,pas/1000,'$p_{tot},  kPa$',Figname,[0 100 150 200 250 300 350 400 450 500 550 600 800 1000 1200 1400 1600 1800 2000 2200 2500 2800 3000]/1000,label2D,Plot2DMargins);
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
print('-dpng',[PATH_PREFIX,Figname,'.png']);  


% In this block only main ions are proceeded
Level_div_f=[-5e24 -4e24 -3e24 -2e24 -1e24 -8e23 -4e23 -2e23 -1e23 -8e22 -6e22 -4e22 -2e22 -1e22 -8e21 -5e21 -2e21 -1e21 -8e20 -5e20 -2e20 -1e20 -5e19 -2e19 -1e19 0 ...
    1e19 2e19 5e19 1e20 2e20 5e20 8e20 1e21 2e21 5e21 8e21 1e22 2e22 4e22 6e22 8e22 1e23 2e23 4e23 8e23 1e24 2e24 3e24 4e24 5e24];

%iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f,['${\rm div} \: \Gamma^{(main \; ions)}, \rm \; s^{-1}m^{-3}$'],'div_fD01',Level_div_f,label2D,Plot2DMargins);
Level_div_f_log10=logspace(18,25,100);

if exist('is_C01','var')
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_C01,['${\rm div} \: \Gamma^{(C+01)}, \rm \; s^{-1}m^{-3}$'],'div_fC01',Level_div_f/200,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_C01,['${\rm div} \: \Gamma^{(C+01)}_{ExB}, \rm \; s^{-1}m^{-3}$'],'div_fExB_C01',Level_div_f/200,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_C02,['${\rm div} \: \Gamma^{(C+02)}, \rm \; s^{-1}m^{-3}$'],'div_fC02',Level_div_f/200,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_C03,['${\rm div} \: \Gamma^{(C+03)}, \rm \; s^{-1}m^{-3}$'],'div_fC03',Level_div_f/400,label2D,Plot2DMargins);
    if EIRENE_flag==1
        figure;
        Figname='sourceC01_Eirene';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(sna_eir(:,:,is_C01)./vol),'${\rm C^{+01} \:ion \: source \: from \: Eirene} , \rm  \; s^{-1}m^{-3}$',Figname,log10(Level_div_f_log10),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
        print('-dpng',[PATH_PREFIX,Figname,'.png']);  
    end;
end;

if exist('is_N01','var')
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_N01,['${\rm div} \: \Gamma^{(N+01)}, \rm \; s^{-1}m^{-3}$'],'div_fN01',Level_div_f/1000,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_N01,['${\rm div} \: \Gamma^{(N+01)}_{ExB}, \rm \; s^{-1}m^{-3}$'],'div_fExB_N01',Level_div_f/1000,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_N02,['${\rm div} \: \Gamma^{(N+02)}, \rm \; s^{-1}m^{-3}$'],'div_fN02',Level_div_f/1000,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_f_N03,['${\rm div} \: \Gamma^{(N+03)}, \rm \; s^{-1}m^{-3}$'],'div_fN03',Level_div_f/2000,label2D,Plot2DMargins);
    if EIRENE_flag==1
        figure;
        Figname='sourceN01_Eirene_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(sna_eir(:,:,is_N01)./vol),'$S_{N^{+}}, \rm  \; s^{-1}m^{-3}$',Figname,log10(Level_div_f_log10)-2,label2D,Plot2DMargins);
        Figname='sourceN01_Eirene_log10_with_arrows';
        plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,fnax_mdf_N_ch+fnax_dia_N_ch+fnax_PSch_N_ch,['$\Gamma_{xN}, \; \rm s^{-1} $'],Figname,[-1.0e12 0 1.0e12],Plot2DMargins,'face  ');
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
        print('-dpng',[PATH_PREFIX,Figname,'.png']);  
    end;
end;

% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_x+div_fvp_x+div_fDgrn_x,'${\rm div} \: (nu_{x}^{E\times B}+nb_xu_{||}-D\nabla_x n), \rm  \; s^{-1}m^{-3} \; (main \; ions)$','div_f_x01',Level_div_f,label2D,Plot2DMargins);
% % % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_y,'${\rm div} \: nu_{y}^{E\times B}, \rm  \;  s^{-1}m^{-3} \; (main \; ions)$','div_fvey01',Level_div_f,label2D,Plot2DMargins);
% % % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_x,'${\rm div} \: nu_{x}^{E\times B}, \rm \; s^{-1}m^{-3}  \; (main \; ions)$','div_fvex01',Level_div_f,label2D,Plot2DMargins);
% % % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fDgrn_y,'${\rm div} \: \left(-D\nabla_y n\right), \rm  \; s^{-1}m^{-3} \; (main \; ions)$','div_fDgrn_y01',Level_div_f,label2D,Plot2DMargins);
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fvp_x,'${\rm div} \: nb_xu_{||}, \rm  \; s^{-1}m^{-3}  \; (main \; ions)$','div_fvpx01',Level_div_f,label2D,Plot2DMargins);
% % % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fDgrn_x,'${\rm div} \: \left(-D\nabla_x n\right), \rm  \; s^{-1}m^{-3}  \; (main \; ions)$','div_fDgrn_x01',Level_div_f,label2D,Plot2DMargins);
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fDgrn_y+div_fDgrn_x,'${\rm div} \: (-D\nabla n), \rm  \; s^{-1}m^{-3} \; (main \; ions)$','div_fDgrn_01',Level_div_f,label2D,Plot2DMargins);
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fve_x+div_fve_y,'${\rm div} \: n{\vec u}^{E\times B}, \rm  \;  s^{-1}m^{-3} \; (main \; ions)$','div_fve01',Level_div_f,label2D,Plot2DMargins);
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fPSch_x+div_fPSch_y,'${\rm div} \: n{\vec u}^{\rm dia}, \rm  \;  s^{-1}m^{-3} \; (main \; ions)$','div_fPSch01',Level_div_f,label2D,Plot2DMargins);
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sna(:,:,is_main)./vol,'${\rm main \:ion \: source} , \rm  \; s^{-1}m^{-3}$','source01',Level_div_f,label2D,Plot2DMargins);
if EIRENE_flag==1
    figure;
    Figname='source01_Eirene_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(sna_eir(:,:,is_main)./vol),'$S_{D^{+}} , \rm  \; s^{-1}m^{-3}$',Figname,log10(Level_div_f_log10),label2D,Plot2DMargins);
    Figname='source01_Eirene_log10';
    plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,fnax_mdf(:,:,is_D01)+fnax_dia(:,:,is_D01)+fnax_PSch(:,:,is_D01),['$\Gamma_{xD}, \; \rm s^{-1} $'],Figname,[-1.0e12 0 1.0e12],Plot2DMargins,'face  ');
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);  
end;
% % % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,snadt(:,:,is_main)./vol,'$\frac{\partial n}{\partial t} \; {\rm for \: main \: ions} , \rm  \; s^{-1}m^{-3}$','dndt01',Level_div_f,label2D,Plot2DMargins);
% % % % % End of the block devoted to main ions


 Level_Ex=[-1200,-1000,-800,-600,-400,-200,0,200,400,600,800,1000,1200];
% % % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x, \; \rm V/m$','Ex',Level_Ex,label2D,Plot2DMargins);
% % % % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x, \; \rm V/m$','Ex_sign',[-2000 -10 0 10 1000],label2D,Plot2DMargins);
% % % % 
% % % % Level_Ey=[-20.0,-16.0,12.0,-8.0,-6.0,-5.0,-4.0,-2.0,-1.4,-1.0,-0.8,-0.6,-0.4,-0.2,0.0,0.2,0.4,0.6,0.8,1.0,1.4,2.0,4.0,6.0,8.0,10.0];
% % % %  plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_y*1.0e-3,'$E_y, \; \rm kV/m$','Ey',Level_Ey,label2D,Plot2DMargins);

figure;
Figname='Ex_arrows';
plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,E_x,'$E_x$',Figname,Level_Ex, Plot2DMargins,'center');
print('-depsc2',[PATH_PREFIX,Figname,'.eps']);

Level_jx=[-2.5e4,-2e4,-1e4,-9e3,-8e3,-7e3,-6e3,-5e3,-4e3,-3e3,-2e3,-1e3,0.0,1e3,2e3,3e3,4e3,5e3, 6e3,7e3,8e3,9e3,1e4,2e4,2.5e4];
% % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jxc_dens,'$j_x, \; \rm A/m^{2}$','jx',Level_jx,label2D,Plot2DMargins);
% % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$B_{pol}\:j_{||} / B, \; \rm A/m^{2}$','jprll',Level_jx,label2D,Plot2DMargins);
% plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sigxc_luc_Ebx,'$b_x\:\sigma_{||}^{\rm luciani}E_{||}, \; \rm A/m^{2}$','sigxc_luc_Ebx',Level_jx,label2D,Plot2DMargins);
% plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,sigxc_Ebx,'$b_x\:\sigma_{||}^{\rm CL}E_{||}, \; \rm A/m^{2}$','sigxc_Ebx',Level_jx,label2D,Plot2DMargins);
% plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$b_x\:j_{||}, \; \rm A/m^{2}$','jprll_sign',[-2.5e4, 10.0 0 10.0 5.0e3],label2D,Plot2DMargins);

% This line is named after the turkey!
%plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(j_prllc_dens-sigxc_luc_Ebx)./(abs(jx_prllc_dens)+abs(j_prllc_dens)),'$(j_{||}-\:\sigma_{||}E_{||})\; / \; (\left|j_{||}\right|+\left|\:\sigma_{||}E_{||}\right|)$','jprll-sigmE',[-0.2,-0.15,-0.12,-0.1,-0.08,-0.05,-0.03,-0.02,-0.01,0,0.01,0.02,0.03,0.05,0.08,0.1,0.12,0.15,0.2],label2D,Plot2DMargins);
% This line is named after the turkey!

%In the turkey reference frame it should be:
% % % % figure;
% % % % Figname='jprll-sigmE';
% % % % plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(jx_prllc_dens-sigxc_luc_Ebx)./(abs(jx_prllc_dens)+abs(j_prllc_dens)),'$(\left|j_{||}-\:\sigma_{||}E_{||}\right|)\; / \; (\left|j_{||}\right|+\left|\:\sigma_{||}E_{||}\right|)$','jprll-sigmE',[-0.2,-0.15,-0.12,-0.1,-0.08,-0.05,-0.03,-0.02,-0.01,0,0.01,0.02,0.03,0.05,0.08,0.1,0.12,0.15,0.2],label2D,Plot2DMargins);
% % % %     print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
% % % %     print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
% % % %     print('-dpng',[PATH_PREFIX,Figname,'.png']);  

figure;
Figname='jprll_and_sigmE';
plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,Ohm_ratio_c,'$(\left|j_{||}/\sigma_{||}\right|)\; / \; (\left|j_{||}/\sigma_{||}\right|+\left|j_{||}/\sigma_{||}-E_{||}\right|)$','jprll_and_sigmE',[0,0.01,0.02,0.03,0.05,0.08,0.1,0.12,0.15,0.2,0.25,0.3,0.4,0.5,0.6,0.7,0.8,0.9,0.95,0.97,0.99,1.0],label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);  


Level_jy=[-8e3,-7e3,-6e3,-5e3,-4e3,-3e3,-2e3,-1.6e3,-1.2e3,-8e2,-4e2,-3e2,-2e2,-1e2,-50,-25,0.0,25,50,100,200,300,4e2,8e2,1e3,2e3,3e3,4e3,5e3];
%plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jyc_dens,'$j_y, \; \rm A/m^{2}$','jy',Level_jy,label2D,Plot2DMargins);

figure;
plot_poloidal_arrow(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,jx_prllc_dens,'$j_{||}$','jprll_arrows',Level_jx,Plot2DMargins,'center');

Level_div_j_dia=[-50000 -40000 -30000 -20000 -10000 -5000 -4000 -3000 -2000 -1000 0 1000 2000 3000 4000 5000 10000];
Level_div_j_tot=[-200 -160 -120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120 160 200];
Level_div_j_small=[-10000 -8000 -6000 -4000 -2000 -1000 -800 -600 -400 -200 0 200 400 600 800 1000 2000 4000 6000 8000 10000];
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_dia+div_j_inert,'${\rm div} j_{\nabla B},  A/m^3$','div_j_dia',Level_div_j_dia,label2D,Plot2DMargins);
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_prll,'${\rm div} j_{prll},  A/m^3$','div_j_prll',Level_div_j_dia,label2D,Plot2DMargins);
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j,'${\rm div} j_{tot},  A/m^3$','div_j_tot',Level_div_j_tot,label2D,Plot2DMargins);
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_dia+div_j_inert+div_j_prll,'${\rm div} \left(j_{dia}+j_{inert}+j_{prll}\right),  A/m^3$','div_j_dia_prll',Level_div_j_small,label2D,Plot2DMargins);
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_vispar+div_j_visper+div_j_visq,'${\rm div} \left(j_{vispar}+j_{visper}+j_{visq}\right),  A/m^3$','div_j_vis',Level_div_j_small,label2D,Plot2DMargins);
% iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_j_AN,'${\rm div} \left(j_{AN}\right),  A/m^3$','div_j_AN',Level_div_j_small,label2D,Plot2DMargins);

% % % Level_Qe=[-40000000 -20000000 -10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0 10000 20000 40000 60000 100000 200000 400000 600000 1000000 2000000 4000000 6000000 8000000 10000000];
Level_Qe=[-40000000 -20000000 -10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0];% 10000 20000 40000 60000 100000 200000 400000 600000 1000000 2000000 4000000 6000000 8000000 10000000];
Level_Qe_log10=logspace(5,7.6989,30);
if EIRENE_flag
    figure;
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,-(she_stel+she_eir)./vol,'$\rm {Q_e}_{loss},\: atoms\:and\:ions \; \rm W/m^3$','Qe_tot',-Level_Qe,label2D,Plot2DMargins);
% % %     iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(she_eir)./vol,'$\rm {Q_e}_{loss},\: atoms, \; \rm W/m^3$','Qe_eir',Level_Qe,label2D,Plot2DMargins);
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,(she_stel)./vol,'$\rm {Q_e}_{loss},\: ions, \; \rm W/m^3$','Qe_stel',Level_Qe,label2D,Plot2DMargins);
    figure;
    Figname='Qe_tot_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(-(she_stel+she_eir)./vol/1.0e6),'$\rm Q^{e}_{loss},\: a+i, \; \rm MW/m^3$','Qe_tot_log10',log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    print('-djpeg',[PATH_PREFIX,Figname,'.jpg']);
    print('-dpng',[PATH_PREFIX,Figname,'.png']);  
end;


Level_Qrad=[-10000000 -8000000 -6000000 -4000000 -2000000 -1000000 -800000 -600000 -400000 -200000 -100000 -80000 -60000 -40000 -20000 -10000 0];

if exist('is_He01','var')   
    if EIRENE_flag
        figure;
        Figname='QradHech_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_He01))./vol/1.0e6),...
            '$\rm {Q_{He_{ions}}}^{(rad)},\:all\:helium\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    else
        figure;
        Figname='QradHetot_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_He01-1)+Qrad(:,:,is_He01))./vol),...
            '$\rm {Q_e}_{rad},\:all\:helium\:ions \; \rm W/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        figure;
        Figname='QradHe00_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_He01-1)./vol),['$\rm ',label{is_He01-1},'\: radiation\:losses, \; \rm W/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    end;
    figure;
    Figname='QradHe01_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_He01)./vol),['$\rm ',label{is_He01},'\: radiation\:losses, \; \rm W/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
end;

if exist('is_C01','var')   
    if EIRENE_flag
        figure;
        Figname='QradCch_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C01)+Qrad(:,:,is_C02)+Qrad(:,:,is_C03)+Qrad(:,:,is_C04)+Qrad(:,:,is_C05))./vol/1.0e6,...
            '$\rm {Q_e}_{rad},\:all\:carbon\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    else
        figure;
        Figname='QradCtot_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_C01-1)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01)+Qrad(:,:,is_C01))./vol/1.0e6),...
            '$\rm {Q_e}_{rad},\:all\:carbon\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        figure;
        Figname='QradC00_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C01-1)./vol/1.0e6),['$\rm ',label{is_C01-1},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    end;
    figure;
    Figname='QradC01_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C01)./vol/1.0e6),['$\rm ',label{is_C01},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradC02_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C02)./vol/1.0e6),['$\rm ',label{is_C02},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradC03_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C03)./vol/1.0e6),['$\rm ',label{is_C03},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradC04_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C04)./vol/1.0e6),['$\rm ',label{is_C04},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradC05_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_C05)./vol/1.0e6),['$\rm ',label{is_C05},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
end;

if exist('is_N01','var')   
    if EIRENE_flag
        figure;
        Figname='QradNch_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_N01)+Qrad(:,:,is_N02)+Qrad(:,:,is_N03)+Qrad(:,:,is_N04)+Qrad(:,:,is_N05)+Qrad(:,:,is_N06))./vol/1.0e6),...
            '$\rm {Q_{N_{ions}}}^{(rad)},\:all\:nitrogen\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    else
        figure;
        Figname='QradNtot_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_N01-1)+Qrad(:,:,is_N01)+Qrad(:,:,is_N02)+Qrad(:,:,is_N03)+Qrad(:,:,is_N04)+Qrad(:,:,is_N05)+Qrad(:,:,is_N06))./vol/1.0e6),...
            '$\rm {Q_e}_{rad},\:all\:nitrogen\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        figure;
        Figname='QradN00_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N01-1)./vol/1.0e6),['$\rm ',label{is_N01-1},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    end;
    figure;
    Figname='QradN01_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N01)./vol/1.0e6),['$\rm ',label{is_N01},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradN02_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N02)./vol/1.0e6),['$\rm ',label{is_N02},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradN03_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N03)./vol/1.0e6),['$\rm ',label{is_N03},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradN04_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N04)./vol/1.0e6),['$\rm ',label{is_N04},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradN05_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N05)./vol/1.0e6),['$\rm ',label{is_N05},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradN06_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_N06)./vol/1.0e6),['$\rm ',label{is_N06},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
end;

if exist('is_Ne01','var')   
    if EIRENE_flag
        figure;
        Figname='QradNch_log10';
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_Ne01)+Qrad(:,:,is_Ne02)+Qrad(:,:,is_Ne03)+Qrad(:,:,is_Ne04)+Qrad(:,:,is_Ne05)+Qrad(:,:,is_Ne06)+Qrad(:,:,is_Ne07)+Qrad(:,:,is_Ne08)+Qrad(:,:,is_Ne09))./vol/1.0e6),...
            '$\rm {Q_{Ne_{ions}}}^{(rad)},\:all\:neon\:ions \; \rm MW/m^3$',Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    else
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10((Qrad(:,:,is_Ne01-1)+Qrad(:,:,is_Ne01)+Qrad(:,:,is_Ne02)+Qrad(:,:,is_Ne03)+Qrad(:,:,is_Ne04)+Qrad(:,:,is_Ne05)+Qrad(:,:,is_Ne06)+Qrad(:,:,is_Ne07)+Qrad(:,:,is_Ne08)+Qrad(:,:,is_Ne09))./vol/1.0e6),...
            '$\rm {Q_e}_{rad},\:all\:neon\:ions \; \rm MW/m^3$','QradNtot',-Level_Qe,label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
        iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne01-1)./vol/1.0e6),['$\rm ',label{is_Ne01-1},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
        print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    end;
    figure;
    Figname='QradNe01_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne01)./vol/1.0e6),['$\rm ',label{is_Ne01},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe02_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne02)./vol/1.0e6),['$\rm ',label{is_Ne02},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe03_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne03)./vol/1.0e6),['$\rm ',label{is_Ne03},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe04_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne04)./vol/1.0e6),['$\rm ',label{is_Ne04},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe05_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne05)./vol/1.0e6),['$\rm ',label{is_Ne05},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe06_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne06)./vol/1.0e6),['$\rm ',label{is_Ne06},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe07_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne07)./vol/1.0e6),['$\rm ',label{is_Ne07},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe08_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne08)./vol/1.0e6),['$\rm ',label{is_Ne08},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
    figure;
    Figname='QradNe09_log10';
    iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,log10(Qrad(:,:,is_Ne09)./vol/1.0e6),['$\rm ',label{is_Ne09},'\: radiation\:losses, \; \rm MW/m^3$'],Figname,log10(Level_Qe_log10/1.0e6),label2D,Plot2DMargins);
    print('-depsc2',[PATH_PREFIX,Figname,'.eps']);
end;

% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fhe_mdf,['${\rm div} \: Q_{e}, \rm \; W\cdot m^{-3}$'],'div_fhe',Level_Qe,label2D,Plot2DMargins);
% % % iout=plot2D(nx,ny,nc1,nc2,nc3,nc4,ntt,nsep,nsep2,PATH_PREFIX,div_fhi_mdf,['${\rm div} \: Q_{i}, \rm \; W\cdot m^{-3}$'],'div_fhi',Level_Qe,label2D,Plot2DMargins);

