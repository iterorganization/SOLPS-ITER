%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get_comuse gets commonly used variables for a simulation and puts them in a  %
% single structure. By calling functions with this structure this function     %
% works similarly to a module in fortran.                                      %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function comuse = get_comuse(filename)

% Obtain dimensions from netcdf file
finfo = ncinfo(filename);
dimNames = {finfo.Dimensions.Name};
% NB nx_these_scripts = nx_b2 + 2, ny_these_scripts = ny_b2 + 2
dimMatch = strcmp(dimNames,'nx_plus2');
comuse.nx = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'ny_plus2');
comuse.ny = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'ns');
comuse.ns = finfo.Dimensions(dimMatch).Length;
dimMatch = strcmp(dimNames,'nstra');
comuse.nstra = finfo.Dimensions(dimMatch).Length;
% Get crx, cry:
comuse.r = ncread(filename,'crx');
comuse.z = ncread(filename,'cry');
% cr, cz, cr_x, cz_x, cr_y, cz_y calculated as in b2mds.F:
comuse.cr = mean(comuse.r,3);
comuse.cz = mean(comuse.z,3);
comuse.cr_x = zeros(comuse.nx-1,comuse.ny);
comuse.cz_x = zeros(comuse.nx-1,comuse.ny);
comuse.cr_y = zeros(comuse.nx,comuse.ny-1);
comuse.cz_y = zeros(comuse.nx,comuse.ny-1);
for iy = 1:comuse.ny
    for ix = 1:comuse.nx-1
        comuse.cr_x(ix,iy)=(comuse.r(ix+1,iy,1)+comuse.r(ix+1,iy,3))/2;
        comuse.cz_x(ix,iy)=(comuse.z(ix+1,iy,1)+comuse.z(ix+1,iy,3))/2;
    end
end
for iy = 1:comuse.ny-1
    for ix = 1:comuse.nx
        comuse.cr_y(ix,iy)=(comuse.r(ix,iy+1,1)+comuse.r(ix,iy+1,2))/2;
        comuse.cz_y(ix,iy)=(comuse.z(ix,iy+1,1)+comuse.z(ix,iy+1,2))/2;
    end
end
% Neighbouring indices (apply same indexing as is done on MDSPlus server)
comuse.rightix = ncread(filename,'rightix')+1;
comuse.leftix = ncread(filename,'leftix')+1;
comuse.rightiy = ncread(filename,'rightiy')+1;
comuse.leftiy = ncread(filename,'leftiy')+1;
comuse.topix = ncread(filename,'topix')+1;
comuse.bottomix = ncread(filename,'bottomix')+1;
comuse.topiy = ncread(filename,'topiy')+1;
comuse.bottomiy = ncread(filename,'bottomiy')+1;
% OMP and sep indices (again, same indexing as MDSPlus server)
comuse.imp = ncread(filename,'jxi')+1;
comuse.omp = ncread(filename,'jxa')+1;
comuse.sep = ncread(filename,'jsep')+1;
% Species string:
tmp = ncread(filename,'species');
comuse.species = {};
for i=1:comuse.ns
    comuse.species{i} = strtrim(tmp(:,i)');
end
% b2mndr_eirene:
comuse.b2mndr_eirene = ncread(filename,'b2mndr_eirene');
% b2mndr_hz:
comuse.b2mndr_hz = ncread(filename,'b2mndr_hz');
% za:
comuse.za = ncread(filename,'za');
% am, mp, ev:
comuse.am = ncread(filename,'am');
comuse.mp = ncread(filename,'mp');
comuse.ev = ncread(filename,'ev');
% Derive dspol as in b2mds.F:
hx = ncread(filename,'hx');
bb = ncread(filename,'bb');
comuse.dspolx = zeros(comuse.nx,comuse.ny);
comuse.dsparx = zeros(comuse.nx,comuse.ny);
for iy=1:comuse.ny
    comuse.dspolx(1,iy)=-hx(1,iy);
    comuse.dsparx(1,iy)=-hx(1,iy)*abs(bb(1,iy,4)/bb(1,iy,1)); %FIX OM 18/4/2019 from bb(ix-1,iy,3)->bb(ix-1,iy,4)
    for ix=2:comuse.nx
      comuse.dspolx(ix,iy)=comuse.dspolx(ix-1,iy)+hx(ix-1,iy);
      comuse.dsparx(ix,iy)=comuse.dsparx(ix-1,iy)+hx(ix-1,iy)*abs(bb(ix-1,iy,4)/bb(ix-1,iy,1)); %FIX OM 18/4/2019 from bb(ix-1,iy,3)->bb(ix-1,iy,4)
    end
end

comuse.dspol = zeros(comuse.nx,comuse.ny);
comuse.dspar = zeros(comuse.nx,comuse.ny);

comuse.dspol(1:end-1,:) = 0.5*(comuse.dspolx(1:end-1,:)+comuse.dspolx(2:end,:));
comuse.dspol(end,:) = comuse.dspolx(end,:)+0.5*hx(end,:);
comuse.dspar(1:end-1,:) = 0.5*(comuse.dsparx(1:end-1,:)+comuse.dsparx(2:end,:));
comuse.dspar(end,:) = comuse.dsparx(end,:)+0.5*hx(end,:)*abs(bb(end,:,4)/bb(end,:,1)); %FIX OM 18/4/2019 from bb(ix-1,iy,3)->bb(ix-1,iy,4)
% Save dv, hx, bb, gs:
comuse.dv = ncread(filename,'vol');
comuse.hx = hx;
% comuse.hy = ncread(filename,'hy');
% comuse.hz = ncread(filename,'hz');
comuse.bb = bb;
comuse.gs = ncread(filename,'gs');
% Set plotting colormap:
comuse.cmap = ([0.0000    0.4470    0.7410;...
                0.8500    0.3250    0.0980;...
                0.9290    0.6940    0.1250;...
                0.4940    0.1840    0.5560;...
                0.4660    0.6740    0.1880;...
                0.3010    0.7450    0.9330;...
                0.6350    0.0780    0.1840]);

