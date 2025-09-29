function write_b2fgmtry_st(file,label,gmtry)
% write_b2fgmtry_st(file,label,gmtry)
%
% Write structured b2fgmtry file for use by B2.5.
%
%

% Author: Wouter Dekeyser
% E-mail: wouter.dekeyser@kuleuven.be
% November 2016

disp(['Attempting write_b2fgmtry_st.'])

[fid,msg] = fopen(file,'wt');
if (fid == -1)
   error(msg);
end


%% Write a version header

VERSION = 'VERSION03.000.006 Matlab';
fprintf(fid,'%s\n',VERSION);
disp(['write_b2fgmtry_st -- file version ',VERSION(8:end)]);

%% Write dimensions nx, ny, ns

nx = size(gmtry.vol,1)-2;
ny = size(gmtry.vol,2)-2;

write_ifield(fid,'nx,ny',[nx,ny]);


%% Write label

write_sfield(fid,'label',label);


%% Write symmetry information

write_ifield(fid,'isymm',gmtry.isymm);


%% Write gmtry variables

write_rfield(fid,'crx' ,gmtry.crx);
write_rfield(fid,'cry' ,gmtry.cry);
write_rfield(fid,'fpsi',gmtry.fpsi);
write_rfield(fid,'ffbz',gmtry.ffbz);
write_rfield(fid,'bb'  ,gmtry.bb);
write_rfield(fid,'vol' ,gmtry.vol);
write_rfield(fid,'hx'  ,gmtry.hx);
write_rfield(fid,'hy'  ,gmtry.hy);
write_rfield(fid,'qz'  ,gmtry.qz);
write_rfield(fid,'qc'  ,gmtry.qc);
write_rfield(fid,'gs'  ,gmtry.gs);


%% Some other geometrical parameters

write_ifield(fid,'nlreg',gmtry.nlreg);
write_ifield(fid,'nlxlo',gmtry.nlxlo);
write_ifield(fid,'nlxhi',gmtry.nlxhi);
write_ifield(fid,'nlylo',gmtry.nlylo);
write_ifield(fid,'nlyhi',gmtry.nlyhi);
write_ifield(fid,'nlloc',gmtry.nlloc);

write_ifield(fid,'nncut'    ,gmtry.nncut);
write_ifield(fid,'leftcut'  ,gmtry.leftcut);
write_ifield(fid,'rightcut' ,gmtry.rightcut);
write_ifield(fid,'topcut'   ,gmtry.topcut);
write_ifield(fid,'bottomcut',gmtry.bottomcut);

write_ifield(fid,'leftix'   ,gmtry.leftix);
write_ifield(fid,'rightix'  ,gmtry.rightix);
write_ifield(fid,'topix'    ,gmtry.topix);
write_ifield(fid,'bottomix' ,gmtry.bottomix);
write_ifield(fid,'leftiy'   ,gmtry.leftiy);
write_ifield(fid,'rightiy'  ,gmtry.rightiy);
write_ifield(fid,'topiy'    ,gmtry.topiy);
write_ifield(fid,'bottomiy' ,gmtry.bottomiy);

write_ifield(fid,'region'     ,gmtry.region);
write_ifield(fid,'nnreg'      ,gmtry.nnreg);
write_ifield(fid,'resignore'  ,gmtry.resignore);
write_ifield(fid,'periodic_bc',gmtry.periodic_bc);

write_rfield(fid,'pbs' ,gmtry.pbs);

write_rfield(fid,'parg',gmtry.parg);


%% Close file

fclose(fid);

disp(['Done write_b2fgmtry_st with no errors.'])

end
