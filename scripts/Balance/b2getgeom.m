%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% b2getgeom reads b2 geometry for a SOLPS simulation.                          %
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) January 2017.                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function geomstruc = b2getgeom(SIMID,B2FLOC,b2fpstr)

if isnumeric(SIMID)
    % Values from MDSPlus server:
    mdsdisconnect;
    mdsopen('solps-mdsplus.aug.ipp.mpg.de:8001::solps',SIMID);
    geomstruc.nx = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NX');
    geomstruc.ny = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NY');
    geomstruc.ns = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:NS');
    geomstruc.r = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:R');
    geomstruc.z = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:Z');
    geomstruc.cr=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR');
    geomstruc.cz=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ');
    geomstruc.cr_x=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR_X');
    geomstruc.cr_y=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CR_Y');
    geomstruc.cz_x=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ_X');
    geomstruc.cz_y=mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:CZ_Y');
    geomstruc.rightix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:RIGHTIX');
    geomstruc.leftix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:LEFTIX');
    geomstruc.rightiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:RIGHTIY');
    geomstruc.leftiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:LEFTIY');
    geomstruc.topix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:TOPIX');
    geomstruc.bottomix = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:BOTTOMIX');
    geomstruc.topiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:TOPIY');
    geomstruc.bottomiy = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:BOTTOMIY');
    geomstruc.sep = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:SEP');
    geomstruc.omp = mdsvalue('\SOLPS::TOP.SNAPSHOT.DIMENSIONS:OMP');
    geomstruc.dspol = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:DSPOL');
    geomstruc.dspar = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:DSPAR');
    geomstruc.specstr = mdsvalue('\SOLPS::TOP.IDENT:SPECIES');
    geomstruc.za = mdsvalue('\SOLPS::TOP.SNAPSHOT.GRID:ZA');
    mdsclose;
else
    % nx, ny, ns from b2fstate (assume it's in the run directory):
    [fb2fs,errmsg] = fopen([SIMID,'b2fstate']);
    if (~isempty(errmsg))
        error('myApp:argChk','Error opening b2fstate file: %s',errmsg);
    end
    tmp = textscan(fb2fs, '%s', 1, 'delimiter', '\n', 'headerlines', 2);
    tmp = str2num(tmp{1}{1});
    geomstruc.nx = tmp(1)+2;
    geomstruc.ny = tmp(2)+2;
    geomstruc.ns = tmp(3);
    fclose(fb2fs);
    % crx, cry from b2fplasma (assume it's in the run directory):
    geomstruc.r = reshape(getdata(b2fpstr,B2FLOC,'crx'),geomstruc.nx,geomstruc.ny,4);
    geomstruc.z = reshape(getdata(b2fpstr,B2FLOC,'cry'),geomstruc.nx,geomstruc.ny,4);
    % cr, cz, cr_x, cz_x, cr_y, cz_y calculated as in b2mds.F:
    geomstruc.cr = mean(geomstruc.r,3);
    geomstruc.cz = mean(geomstruc.z,3);
    geomstruc.cr_x = zeros(geomstruc.nx-1,geomstruc.ny);
    geomstruc.cz_x = zeros(geomstruc.nx-1,geomstruc.ny);
    geomstruc.cr_y = zeros(geomstruc.nx,geomstruc.ny-1);
    geomstruc.cz_y = zeros(geomstruc.nx,geomstruc.ny-1);
    for iy = 1:geomstruc.ny
        for ix = 1:geomstruc.nx-1
            geomstruc.cr_x(ix,iy)=(geomstruc.r(ix+1,iy,1)+geomstruc.r(ix+1,iy,3))/2;
            geomstruc.cz_x(ix,iy)=(geomstruc.z(ix+1,iy,1)+geomstruc.z(ix+1,iy,3))/2;
        end
    end
    for iy = 1:geomstruc.ny-1
        for ix = 1:geomstruc.nx
            geomstruc.cr_y(ix,iy)=(geomstruc.r(ix,iy+1,1)+geomstruc.r(ix,iy+1,2))/2;
            geomstruc.cz_y(ix,iy)=(geomstruc.z(ix,iy+1,1)+geomstruc.z(ix,iy+1,2))/2;
        end
    end
    
    % Neighbouring indices from b2fgmtry (assume it's either in the run
    % directory or in baserun at the same directory level):
    if exist([SIMID,'b2fgmtry'],'file')
        b2fgmtryname = [SIMID,'b2fgmtry'];
    elseif exist([SIMID,'../baserun/b2fgmtry'],'file')
        b2fgmtryname = [SIMID,'../baserun/b2fgmtry'];
    else
        error('Cannot find b2fgmtry file.');
    end
    fb2gm = fopen(b2fgmtryname);
    b2fgstr = fread(fb2gm,'*char')';
    n = geomstruc.nx*geomstruc.ny;
    k = strfind(b2fgstr,'rightix');
    fseek(fb2gm,k+length('rightix'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.rightix = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'leftix');
    fseek(fb2gm,k+length('leftix'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.leftix = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'rightiy');
    fseek(fb2gm,k+length('rightiy'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.rightiy = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'leftiy');
    fseek(fb2gm,k+length('leftiy'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.leftiy = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'topix');
    fseek(fb2gm,k+length('topix'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.topix = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'bottomix');
    fseek(fb2gm,k+length('bottomix'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.bottomix = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'topiy');
    fseek(fb2gm,k+length('topiy'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.topiy = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    k = strfind(b2fgstr,'bottomiy');
    fseek(fb2gm,k+length('bottomiy'),'bof');
    tmp = textscan(fb2gm,'%d',n);
    geomstruc.bottomiy = reshape(tmp{1},geomstruc.nx,geomstruc.ny)+1; % Same indexing as MDSPlus server
    fclose(fb2gm);
    % Separatrix and OMP indices from run.log (assume it's in the run
    % directory):
    [frun,errmsg] = fopen([SIMID,'run.log']);
    if (~isempty(errmsg))
        error('myApp:argChk','Error opening b2fstate file: %s',errmsg);
    end
    tline = ' ';
    while ischar(tline)
        tline = fgetl(frun);
        if strncmp(tline,'  NSTRA',7)
            tmp = str2num(tline(strfind(tline,'=')+1:end));
            geomstruc.nstra = tmp;
        end
        if strncmp(tline,' jxi, jxa, jsep',15)
            tmp = str2num(tline(strfind(tline,':')+1:end));
            geomstruc.omp = tmp(2)+1; % Same indexing as MDSPlus server
            geomstruc.sep = tmp(3)+1; % Same indexing as MDSPlus server
        end
        if strncmp(tline,'Start tallies by region',23)
            fgetl(frun);
            tline = fgetl(frun);
            tmp = textscan(tline(12:end),'%s');
            geomstruc.species = {};
            for i=1:length(tmp{1})
                geomstruc.species{i} = tmp{1}{i};
            end
            break;
        end
    end
    fclose(frun);
    % ZA from b2ah.dat:
    if exist([SIMID,'b2ah.dat'],'file')
        b2ahname = [SIMID,'b2ah.dat'];
    elseif exist([SIMID,'../baserun/b2ah.dat'],'file')
        b2ahname = [SIMID,'../baserun/b2ah.dat'];
    else
        error('Cannot find b2ah.dat file.');
    end
    fb2ah = fopen(b2ahname);
    geomstruc.za = [];
    tline = ' ';
    while ischar(tline)
        tline = fgetl(fb2ah);
        if strncmp(tline,'*specs',6)
            tline = fgetl(fb2ah);
            while tline(1) ~= '*'
                tmp = str2num(tline(find(tline=='''',1,'last')+1:end));
                geomstruc.za = [geomstruc.za,round(tmp(1))];
                tline = fgetl(fb2ah);
            end
            break;
        end
    end
    fclose(fb2ah);
    % Derive dspol and dspar as in b2mds.F:
    hx = reshape(getdata(b2fpstr,B2FLOC,'hx'),geomstruc.nx,geomstruc.ny);
    bb = reshape(getdata(b2fpstr,B2FLOC,'bb'),geomstruc.nx,geomstruc.ny,4);
    geomstruc.dspol = zeros(geomstruc.nx,geomstruc.ny);
    geomstruc.dspar = zeros(geomstruc.nx,geomstruc.ny);
    for iy=1:geomstruc.ny
        geomstruc.dspol(1,iy)=0;
        geomstruc.dspar(1,iy)=0;
        for ix=2:geomstruc.nx
          geomstruc.dspol(ix,iy)=geomstruc.dspol(ix-1,iy)+(hx(ix-1,iy)+hx(ix,iy))/2;
%           geomstruc.dspar(ix,iy)=geomstruc.dspar(ix-1,iy)+hx...
                              (hx(ix-1,iy)*abs(bb(ix-1,iy,3)/bb(ix-1,iy,1))+...
                               hx(ix,iy)*abs(bb(ix,iy,3)/bb(ix,iy,1)))/2;
        end
    end
end
