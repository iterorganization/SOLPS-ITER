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
% za:
comuse.za = ncread(filename,'za');
% Derive dspol as in b2mds.F:
hx = ncread(filename,'hx');
bb = ncread(filename,'bb');
comuse.dspol = zeros(comuse.nx,comuse.ny);
for iy=1:comuse.ny
    comuse.dspol(1,iy)=0;
    comuse.dspar(1,iy)=0;
    for ix=2:comuse.nx
      comuse.dspol(ix,iy)=comuse.dspol(ix-1,iy)+(hx(ix-1,iy)+hx(ix,iy))/2;
    end
end
% Save dv, hx, bb:
comuse.dv = ncread(filename,'vol');
comuse.hx = hx;
comuse.bb = bb;
% Set plotting colormap:
comuse.cmap = ([0.0000    0.4470    0.7410;...
                0.8500    0.3250    0.0980;...
                0.9290    0.6940    0.1250;...
                0.4940    0.1840    0.5560;...
                0.4660    0.6740    0.1880;...
                0.3010    0.7450    0.9330;...
                0.6350    0.0780    0.1840]);

