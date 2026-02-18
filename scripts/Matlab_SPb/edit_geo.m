%% This script provides the possibility to make a modifications in unstructured mesh by editing .geo file. See file edit_geo_manual for full description.
Matlab_path = extractBefore(mfilename('fullpath'),'edit_geo');
set(0,'DefaultFigureWindowStyle','docked')
format compact
global PATH_NEW_GEO path is_file_written counterFile
counterFile = 0;
if exist([Matlab_path 'edit_geo.mat'],'file')
    prev_path = load([Matlab_path 'edit_geo.mat'],'PATH_NEW_GEO');
    rootdir = fileparts(prev_path.PATH_NEW_GEO) + "/";
    [file,location] = uigetfile(rootdir+"*.geo");
else
    [file,location] = uigetfile("*.geo");
end
if location == 0
    return;
end
path = [location file];
if ~contains(path,"modified")
    PATH_NEW_GEO = [location replace(file,".geo","") '_modified.geo'];
else
    PATH_NEW_GEO = path;
end
save([Matlab_path 'edit_geo.mat'],"PATH_NEW_GEO");
is_file_written = false;
global geo structures
if exist([location 'vessel.dat'],'file')
    structures = read_structure([location 'vessel.dat']);
elseif exist([location 'structure.dat'],'file')
    structures = read_structure([location 'structure.dat']);
else
    structure = struct('nel',{},'r',{},'z',{});
end
geo = read_geo(path);
plot_geo(false);

function swap(ix,iy,p1,p2)
    global geo
    tmp =geo.crxs(ix,iy,p1);
    geo.crxs(ix,iy,p1) = geo.crxs(ix,iy,p2);
    geo.crxs(ix,iy,p2) = tmp;
    tmp =geo.crys(ix,iy,p1);
    geo.crys(ix,iy,p1) = geo.crys(ix,iy,p2);
    geo.crys(ix,iy,p2) = tmp;
end

function plot_geo(is_reload)
    global geo
    [nx,ny,np] = size(geo.crxs);
    v = zeros(1,0);
    f = zeros(1,0);
    index = 1;
    indexf = 1;
    geo.connPoints = zeros(nx,ny,np);
    for ix=1:nx
        for iy=1:ny
          tmp = get_polygon(geo, ix,iy);
          if ~any(tmp == 0)
              f(index,1:4) = indexf:indexf+3;
              v(f(index,1:4),1:2) = tmp;
              geo.connPoints(ix,iy,2) =  indexf;
              geo.connPoints(ix,iy,4) =  indexf+1;
              geo.connPoints(ix,iy,5) =  indexf+2;
              geo.connPoints(ix,iy,3) =  indexf+3;
              index = index+1;
              indexf = indexf+4;
          end
        end
    end
    if ~is_reload
        figure();
    end
    hold on
    axis equal
    patch('Faces',f,'Vertices',v,'FaceColor','none','LineWidth',0.1);
    set(gca, 'XAxisLocation', 'top');
    plot_boundary_faces(-1,-1,geo);
    if is_reload
        return;
    end
    uicontrol('Units','normalized', 'Position',[0.35 0 0.1 0.05],'String','move point poloidally',...
      'Callback', {@get_point});

    uicontrol('Units','normalized', 'Position',[0.35 0.05 0.1 0.05],'String','move point free',...
      'Callback', {@move_point_free});

    uicontrol('Units','normalized', 'Position',[0.25 0.00 0.1 0.05],'String','split vertex',...
      'Callback', {@split_vertex});

    uicontrol('Units','normalized','Position',[0.25 0.05 0.1 0.05],'String','merge points',...
      'Callback', {@merge_points});


    uicontrol('Units','normalized','Position',[0.15 0.05 0.1 0.05],'String','show outer cells',...
      'Callback', {@show_outer_cells});
    uicontrol('Units','normalized','Position',[0.15 0.00 0.1 0.05],'String','show structures',...
      'Callback', {@show_structures});


    uicontrol('Units','normalized','Position',[0.45 0 0.125 0.04],'String','move line poloidally',...
      'Callback', {@move_line});

    uicontrol('Units','normalized','Position',[0.45 0.04 0.125 0.04],'String','move line poloidally partly',...
      'Callback', {@move_line,true});

    uicontrol('Style', 'checkbox','String', 'Apply restrictions','Value', 1, 'Units','normalized',...
        'Position',[0.45 0.08 0.125 0.02]);


    uicontrol('Units','normalized','Position',[0.575 0 0.1 0.05],'String','set type of cell',...
      'Callback', {@set_type_of_cell});
    uicontrol('Units','normalized','Position',[0.575 0.05 0.1 0.05],'String','set boundary face',...
      'Callback', {@set_point_as_boundary});

    uicontrol('Units','normalized','Position',[0.7 0 0.1 0.05],'String','write geo',...
      'Callback', {@write_new_geo});
    uicontrol('Units','normalized','Position',[0.7 0.05 0.1 0.05],'String','reload geo',...
      'Callback', {@reload_geo});
end

function show_structures(~,~)
    mesh_fig = get_mesh_fig_from_fig();
    if isempty(mesh_fig.structures)
        global structures
        colors = prism(length(structures));
        for istr = 1:length(structures)
            h = plot(structures(istr).r,structures(istr).z,"Color",colors(istr,:),"LineWidth",2);
            h.DataTipTemplate.DataTipRows(3).Label = 'Structure number';
            h.DataTipTemplate.DataTipRows(3).Value = istr*ones(length(structures(istr).r),1);
        end
    else
        delete(mesh_fig.structures);
    end
end

function plot_boundary_faces(~,~,geo,fcLbl)
   if ~exist('fcLbl','var')
       list_of_fcLbls = unique(geo.cflags(:,:,2:5));
       N_bounds =  length(list_of_fcLbls);
       colors = lines(N_bounds);
   end
   mesh_fig = get_mesh_fig_from_fig();
   delete(mesh_fig.bfcs(:))
   delete(mesh_fig.bmarkers(:))
   delete(mesh_fig.bfcsmarkers(:))
   for ix=1:geo.nx
        for iy=1:geo.ny
            polygon = get_polygon(geo, ix,iy);
            for ip=2:5
                [x,y] = get_face_ends_coords(polygon,ip-1);
                if exist('fcLbL','var') && geo.cflags(ix,iy,ip)==fcLbl
                    plot(x,y,"-r","LineWidth",1.5)
                elseif geo.cflags(ix,iy,ip) ~= 0 || geo.cflags(ix,iy,1) == 3
                    if geo.cflags(ix,iy,ip) ~= 0
                        plot(x,y,"-","LineWidth",1.5,"Color",colors(list_of_fcLbls == geo.cflags(ix,iy,ip),:));
                        if x(1) ~= x(2) || y(1) ~= y(2)
                            h=plot(mean(x),mean(y),"^","LineWidth",1,"Color",colors(list_of_fcLbls == geo.cflags(ix,iy,ip),:));
                            h.DataTipTemplate.DataTipRows(3).Label = 'fcLbL';
                            h.DataTipTemplate.DataTipRows(3).Value = geo.cflags(ix,iy,ip);
                            % % For string values, use function handles
                            % h.DataTipTemplate.DataTipRows(4) = dataTipTextRow('Type',@(x,y) 'Boundary');
                        end
                    elseif geo.cflags(ix,iy,1) == 3
                        plot(geo.crxs(ix,iy,1),geo.crys(ix,iy,1),"bs");
                    end
                end
            end
        end
    end
end


function reload_geo(ButtonH, EventData)
    global geo path is_file_written PATH_NEW_GEO
    Xlims = get(gca, 'XLim');
    YLims = get(gca, 'YLim');
    % clf
    ax = gca;
    cla(ax);
    if ~is_file_written
        geo = read_geo(path);
    else
        geo = read_geo(PATH_NEW_GEO);
    end
    plot_geo(true);

    xlim(ax,Xlims);
    ylim(ax,YLims);
end
function set_point_as_boundary(~,~,points)
    global geo;
    if ~exist('points','var')
        [points,is_stop] = get_coords_from_fig(-1);
        if is_stop
            return;
        end
    end
    label=inputdlg({'Enter boundary number'},'value',[1 40]);
    if isempty(label) || isempty(str2num(label{1}))
        return;
    end
    list_of_fcLbls = unique(geo.cflags(:,:,2:5));
    if (str2num(label{1}) < 0 || str2num(label{1}) > max(list_of_fcLbls))
        answer = questdlg('You want to set probably wrong face label (label can`t be negative and has any gap in list of labels). Do you want to continue?', ...
	        'Yes','No');
        if strcmp(answer,'No')
            return
        end
    end

    for ipoint=1:size(points,1)
        point = points(ipoint,:);
        [ixc, iyc, ip] = get_cell_index(point(1),point(2),geo);
        polygon = get_polygon(geo,ixc,iyc);
        x = zeros(4,1);
        y = zeros(4,1);
        for ip=1:4
            [x(ip),y(ip)] = get_face_coords(polygon,ip);
        end
        dist = (x-point(1)).^2+(y-point(2)).^2;
        ifc = find(dist == min(dist));
    
        geo.cflags(ixc,iyc,ifc+1) = str2num(label{1});
        if geo.cflags(ixc,iyc,ifc+1) ~= 0
            geo.cflags(ixc,iyc,1) = 3;
            plot(geo.crxs(ixc,iyc,1),geo.crys(ixc,iyc,1),'bs');
            [x,y] = get_face_ends_coords(polygon,ifc);
    
            N_bounds =  length(list_of_fcLbls);
            colors = lines(N_bounds);
            if any(str2num(label{1}) == list_of_fcLbls)
                mesh_fig = get_mesh_fig_from_fig();
                for k=1:length(mesh_fig.bfcs)
                    if mean(mesh_fig.bfcs(k).XData) == mean(x) && mean(mesh_fig.bfcs(k).YData) == mean(y)
                        delete(mesh_fig.bfcs(k));
                    end
                end
                for k=1:length(mesh_fig.bfcsmarkers)
                    if mesh_fig.bfcsmarkers(k).XData == mean(x) && mesh_fig.bfcsmarkers(k).YData == mean(y)
                        delete(mesh_fig.bfcsmarkers(k));
                    end
                end
                color = colors(list_of_fcLbls == geo.cflags(ixc,iyc,ifc+1),:);
                plot(x,y,"-","Color",color,"LineWidth",1.5);
                h=plot(mean(x),mean(y),"^","LineWidth",1,"Color",color);
                h.DataTipTemplate.DataTipRows(3).Label = 'fcLbL';
                h.DataTipTemplate.DataTipRows(3).Value = geo.cflags(ixc,iyc,ifc+1);
                % % For string values, use function handles
                % h.DataTipTemplate.DataTipRows(4) = dataTipTextRow('Type',@(x,y) 'Boundary');
            else
                plot_boundary_faces(0,0,geo);
            end
        else
            mesh_fig = get_mesh_fig_from_fig();
            for k=1:length(mesh_fig.bfcs)
                if mean(mesh_fig.bfcs(k).XData) == x(ifc) && mean(mesh_fig.bfcs(k).YData) == y(ifc)
                    delete(mesh_fig.bfcs(k));
                end
            end
            for k=1:length(mesh_fig.bfcsmarkers)
                if mesh_fig.bfcsmarkers(k).XData == mean(x(ifc)) && mesh_fig.bfcsmarkers(k).YData == mean(y(ifc))
                    delete(mesh_fig.bfcsmarkers(k));
                end
            end
        end
    end
end

function set_type_of_cell(~,~)
    global geo
    [chosen_cells,is_stop] = get_coords_from_fig(-1);
    if is_stop
        return;
    end
    list = {'Inner','Outer','Boundary'};
    [indx,tf] = listdlg('ListString',list);
    if ~tf
        return
    end
    fprintf("You have defined cell as %s cell\n",list{indx});
    for ipoint=1:size(chosen_cells,1)
        chosen_cell = chosen_cells(ipoint,:);
        [ix,iy,~] = get_cell_index(chosen_cell(1),chosen_cell(2),geo);
    
        if geo.cflags(ix,iy,1) == indx
            return;
        end
        if geo.cflags(ix,iy,1) == 3
            polygon = get_polygon(geo,ix,iy);
            for ip=1:4
                [x,y] = get_face_coords(polygon,ip); 
                if geo.cflags(ix,iy,ip+1) ~= 0
                    geo.cflags(ix,iy,ip+1) = 0;
                end
                mesh_fig = get_mesh_fig_from_fig();
                for k=1:length(mesh_fig.bfcs)
                    if mean(mesh_fig.bfcs(k).XData) == x && mean(mesh_fig.bfcs(k).YData) == y
                        delete(mesh_fig.bfcs(k));
                    end
                end
                for k=1:length(mesh_fig.bfcsmarkers)
                    if mesh_fig.bfcsmarkers(k).XData == x && mesh_fig.bfcsmarkers(k).YData == y
                        delete(mesh_fig.bfcsmarkers(k));
                    end
                end
                for k=1:length(mesh_fig.bmarkers)
                    if mesh_fig.bmarkers(k).XData == geo.crxs(ix,iy,1)...
                        && mesh_fig.bmarkers(k).YData == geo.crys(ix,iy,1)
                        delete(mesh_fig.bmarkers(k));
                    end
                end
            end
        elseif indx == 3
            set_point_as_boundary(0,0,chosen_cell);
        end
        geo.cflags(ix,iy,1) = indx;
    end
end

function show_outer_cells(~, ~)
    global geo
    mesh_fig = get_mesh_fig_from_fig();
    if isempty(mesh_fig.omarkers)
        [ix,iy] = find(geo.cflags(:,:,1) == 2);
        xs = zeros(size(ix)); ys = zeros(size(iy));
        for k=1:length(ix)
            xs(k) = geo.crxs(ix(k),iy(k),1);
            ys(k) = geo.crys(ix(k),iy(k),1);
        end
        plot(xs,ys,'ob');
    else
        delete(mesh_fig.omarkers);
    end
end

function write_new_geo(ButtonH, EventData)
    global PATH_NEW_GEO geo is_file_written
    if ~isstring(PATH_NEW_GEO)
        PATH_NEW_GEO = string(PATH_NEW_GEO);
    end
    [FILEPATH,NAME,EXT] = fileparts(PATH_NEW_GEO);
    if exist(PATH_NEW_GEO,'file')
        answer = questdlg("File " + PATH_NEW_GEO + " already exist. Save to anoter file?", ...
	'Choose name of file', 'Yes','No','Cancel','Cancel');
    switch answer
        case 'Yes'
            pattern = 'modified_(\d+)';
            [tokens, matches] = regexp(NAME, pattern, 'tokens', 'match');
            if ~isempty(tokens)
                num = str2double(tokens{1}{1});
                number = num + 1;
                NEW_NAME = strrep(NAME, matches{1}, sprintf('modified_%d', number));
            else
                number = 1;
                NEW_NAME = NAME + "_1";
            end
            PATH_NEW_GEO = FILEPATH + "/" + NEW_NAME + EXT;
            num_cls = 0;
            if ~isStringScalar(PATH_NEW_GEO)
                warning("PATH_NEW_GEO is corrupted. Set path again");
                tmp =inputdlg({'PATH_NEW_GEO is corrupted. Set path again'},'value',[1 40],strjoin(strip(PATH_NEW_GEO)));
                PATH_NEW_GEO = tmp{1};
            end
            while exist(PATH_NEW_GEO,'file') && num_cls < 10000
                [tokens, matches] = regexp(NEW_NAME, pattern, 'tokens', 'match');
                if ~isempty(tokens)
                    num = str2double(tokens{1}{1});
                    number = num + 1;
                    NEW_NAME = strrep(NEW_NAME, matches{1}, sprintf('modified_%d', number));
                else
                    number = 1;
                    NEW_NAME = NEW_NAME + "_1";
                end
                PATH_NEW_GEO = FILEPATH + "/" + NEW_NAME + EXT;
                num_cls = num_cls+1;
            end
        case 'No'
        case 'Cancel'
            return
        otherwise
            return
    end
    end
    write_geo(PATH_NEW_GEO,geo);
    is_file_written = true;
    fprintf("New geo file was written to %s\n",PATH_NEW_GEO);
    Matlab_path = evalin('base','Matlab_path');
    save([Matlab_path 'edit_geo.mat'],"PATH_NEW_GEO");
end


function move_line(~, ~, move_part)
    global geo
    mesh_fig = get_mesh_fig_from_fig();
    [point_from_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    [point_to_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    if exist('move_part','var') && move_part
        [final_vertex,is_stop] = get_coords_from_fig(1);
        if is_stop
            return;
        end
    end
    [moved_from_point, moved_to_point,~,~] = move_point(mesh_fig,point_from_move,point_to_move);
    if isempty(moved_from_point)
        return;
    end
    fprintf("from (%2.8f, %2.8f) to (%2.8f, %2.8f)\n", moved_from_point, moved_to_point);
    
    moved_points = zeros(0,2);
    moved_points(end+1,:) = moved_to_point;
    neighbor_points = zeros(0,2);
    for ip=2:5
        [ix, iy] = find(geo.crxs(:,:,ip) == moved_to_point(1) & geo.crys(:,:,ip) == moved_to_point(2));
        if length(ix) > 1 || length(iy) > 1
            return;
        end
        polygon = get_polygon(geo,ix,iy);
        ip_in_polygon = find(polygon(:,1) == moved_to_point(1) & polygon(:,2) == moved_to_point(2));
        [a,b] = get_rad_vxs(polygon,ip_in_polygon);
        if a(1) ~= moved_to_point(1) && a(2) ~= moved_to_point(2)
            neighbor_points(end+1,:) = a;
        end
        if b(1) ~= moved_to_point(1) && b(2) ~= moved_to_point(2)
            neighbor_points(end+1,:) = b;
        end
    end
    neighbor_points = unique(neighbor_points,"rows");
    if exist('move_part','var') && move_part 
        if diste(neighbor_points(1,:),final_vertex) < diste(neighbor_points(2,:),final_vertex)
            moved_points = move_line_segment(moved_from_point,moved_to_point,neighbor_points(1,:),moved_points,mesh_fig,final_vertex);
        else
            moved_points = move_line_segment(moved_from_point,moved_to_point,neighbor_points(2,:),moved_points,mesh_fig,final_vertex);
        end
    else
        moved_points = move_line_segment(moved_from_point,moved_to_point,neighbor_points(1,:),moved_points,mesh_fig);
        moved_points = move_line_segment(moved_from_point,moved_to_point,neighbor_points(2,:),moved_points,mesh_fig);
    end
end

function moved_points = move_line_segment(moved_from_point,moved_to_point,point_from_move,moved_points,mesh_fig,final_vertex)
    global geo
    is_boundary_cell_found = false;
    k=0;
    while ~is_boundary_cell_found && k < geo.ny
        k = k+1;
        dx = moved_to_point(1) - moved_from_point(1);
        dy = moved_to_point(2) - moved_from_point(2);
        if k>1
            for k1=1:length(neighbor_points)
                if all(neighbor_points(k1,1) ~= moved_points(:,1)) && all(neighbor_points(k1,2) ~= moved_points(:,2))
                    point_from_move = neighbor_points(k1,:);
                    break;
                end
            end
        end
        dxmax = inf;
        dymax = inf;
        for ip=2:5
            [ix, iy] = find(geo.crxs(:,:,ip) == point_from_move(1) & geo.crys(:,:,ip) == point_from_move(2));
            if length(ix) > 1 || length(iy) > 1 || geo.cflags(ix,iy,ip) ~= 0
                return;
            end
            polygon = get_polygon(geo,ix,iy);
            ip_in_polygon = find(polygon(:,1) == point_from_move(1) & polygon(:,2) == point_from_move(2));
            [a,b] = get_pol_vxs(polygon,ip_in_polygon);
            dxmax = min(dxmax,abs(a(1)-b(1)));
            dymax = min(dymax,abs(a(2)-b(2)));
        end
        k=1;
        while k <= length(gcf().Children)
            if contains(class(gcf().Children(k)), 'UIControl') ...
                    && contains(gcf().Children(k).Style, 'checkbox')
                break;
            end
            k = k+1;
        end
        if gcf().Children(k).Value == 1
            point_to_move(1) = point_from_move(1) + max(min(dx,dxmax*0.9),-dxmax*0.9);
            point_to_move(2) = point_from_move(2) + max(min(dy,dymax*0.9),-dymax*0.9);
        else
            point_to_move(1) = point_from_move(1) + dx;
            point_to_move(2) = point_from_move(2) + dy;
        end

        if exist('final_vertex','var') && (diste(point_to_move,final_vertex)...
                > diste(moved_points(end,:),final_vertex))
            break
        end

        [moved_from_point, moved_to_point,~,~] = move_point(mesh_fig,point_from_move,point_to_move);
        if isempty(moved_from_point)
            return;
        end
        fprintf("from (%2.8f, %2.8f) to (%2.8f, %2.8f)\n", moved_from_point, moved_to_point);
        moved_points(end+1,:) = moved_to_point;

        neighbor_points = zeros(0,2);
        for ip=2:5
            [ix, iy] = find(geo.crxs(:,:,ip) == moved_to_point(1) & geo.crys(:,:,ip) == moved_to_point(2));
            if length(ix) > 1 || length(iy) > 1
                return;
            end
            polygon = get_polygon(geo,ix,iy);
            if geo.cflags(ix,iy,1) == 3
                is_boundary_cell_found = true;
            end
            ip_in_polygon = find(polygon(:,1) == moved_to_point(1) & polygon(:,2) == moved_to_point(2));
            [a,b] = get_rad_vxs(polygon,ip_in_polygon);
            if a(1) ~= moved_to_point(1) && a(2) ~= moved_to_point(2)
                neighbor_points(end+1,:) = a;
            end
            if b(1) ~= moved_to_point(1) && b(2) ~= moved_to_point(2)
                neighbor_points(end+1,:) = b;
            end
        end
        neighbor_points = unique(neighbor_points,"rows");
    end
end

function get_point(ButtonH, EventData)
    [point_from_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    [point_to_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    mesh_fig = get_mesh_fig_from_fig();

    [moved_from_point, moved_to_point,~,~] = move_point(mesh_fig,point_from_move,point_to_move);
    if isempty(moved_to_point)
        return;
    end
    fprintf("from (%2.8f, %2.8f) to (%2.8f, %2.8f)\n", moved_from_point, moved_to_point);
end

function merge_points(~, ~)
    global geo
    mesh_fig = get_mesh_fig_from_fig();
    [point_from_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    [point_to_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    all_inds = get_all_point_inds(geo,point_to_move);
    ix_to = all_inds(1,1);iy_to = all_inds(1,2);ip_to = all_inds(1,3);
    point_to_move = [geo.crxs(ix_to,iy_to,ip_to) geo.crys(ix_to,iy_to,ip_to)];
 
    all_inds = get_all_point_inds(geo,point_from_move);
    ix = all_inds(1,1);iy = all_inds(1,2);ip = all_inds(1,3);
    point_from_move = [geo.crxs(ix,iy,ip) geo.crys(ix,iy,ip)];

    [rows, ~] = size(all_inds);
    for k=1:rows
        ix = all_inds(k,1);iy = all_inds(k,2);ip = all_inds(k,3);
        geo.crxs(ix,iy,ip) = geo.crxs(ix_to,iy_to,ip_to);
        geo.crys(ix,iy,ip) = geo.crys(ix_to,iy_to,ip_to);
        geo.crxs(ix,iy,1) = mean(geo.crxs(ix,iy,2:5));
        geo.crys(ix,iy,1) = mean(geo.crys(ix,iy,2:5));

        geo.psi(ix,iy,ip,1:3) =  geo.psi(ix_to,iy_to,ip_to,1:3);
        geo.psi(ix,iy,1,1) =  mean(geo.psi(ix,iy,2:5,1));
        geo.bp(ix,iy) = geo.bp(ix_to,iy_to);
        geo.bt(ix,iy) = geo.bt(ix_to,iy_to);
        geo.ffbz(ix,iy,ip) = geo.ffbz(ix_to,iy_to,ip_to);
    end

    update_point_on_plot(mesh_fig,point_from_move,point_to_move)
end


function move_point_free(~, ~)
    global geo
    [point_from_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    [point_to_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    mesh_fig = get_mesh_fig_from_fig();
    all_inds = get_all_point_inds(geo,point_from_move);
    point_from_move = [geo.crxs(all_inds(1,1),all_inds(1,2),all_inds(1,3))...
        geo.crys(all_inds(1,1),all_inds(1,2),all_inds(1,3))];
    update_point_on_plot(mesh_fig,point_from_move,point_to_move);

    fprintf("from (%2.8f, %2.8f) to (%2.8f, %2.8f)\n", point_from_move, point_to_move);
    [rows, ~] = size(all_inds);
    for k=1:rows
        ix = all_inds(k,1);iy = all_inds(k,2);ip = all_inds(k,3);
        geo.crxs(ix,iy,ip) = point_to_move(1);
        geo.crys(ix,iy,ip) = point_to_move(2);

        geo.crxs(ix,iy,1) = mean(geo.crxs(ix,iy,2:5));
        geo.crys(ix,iy,1) = mean(geo.crys(ix,iy,2:5));

        [bt, bp] = change_magnetic_field(geo,ix,iy, [geo.crxs(ix,iy,1) geo.crys(ix,iy,1)]);
        geo.bp(ix,iy) = bp;
        geo.bt(ix,iy) = bt;
    end
end

function split_vertex(~, ~)
    global geo
    mesh_fig = get_mesh_fig_from_fig();
    [point_from_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    [point_to_move,is_stop] = get_coords_from_fig(1);
    if is_stop
        return;
    end
    try
        [ix,iy,ip] = get_cell_index(point_from_move(1),point_from_move(2),geo);
    catch
    end

    fprintf("from (%2.8f, %2.8f) to (%2.8f, %2.8f)\n", point_from_move, point_to_move);
    all_inds = get_all_point_inds(geo,point_from_move);
    
    shift = 0;
    for row=1:size(all_inds,1)
        if all_inds(row,1)  == ix && all_inds(row,2)  == iy
            point_from_move = [geo.crxs(ix,iy,all_inds(row,3)) geo.crys(ix,iy,all_inds(row,3))];
            geo.crxs(ix,iy,all_inds(row,3)) = point_to_move(1)+shift;
            geo.crys(ix,iy,all_inds(row,3)) = point_to_move(2);
            mesh_fig.p.Vertices(geo.connPoints(ix,iy,all_inds(row,3)),:) =...
                [point_to_move(1)+shift point_to_move(2)];
            shift = shift + 0.01;
        end
    end
    
    if geo.cflags(ix,iy,1) == 3
        plot_boundary_faces(0,0,geo);
    end
end

function [point_from_move,point_to_move,dist_p,dist_n] = move_point(mesh_fig,point_from_move,point_to_move)
    global geo
    %%%%% находим координату точки, которую будем двигать
    dist = (geo.crxs(:,:,2:end)-point_from_move(1)).^2+(geo.crys(:,:,2:end)-point_from_move(2)).^2;
    all_inds = zeros(0,0);
    for k=1:4
        [ix, iy] = find(dist(:,:,k) == min(min(min(dist))));
        for ik=1:length(ix)
            all_inds(end+1,1:3) = [ix(ik) iy(ik) k+1];
        end
    end
    
    [rows,~] = size(all_inds);

    ix = all_inds(1,1);iy = all_inds(1,2);ip = all_inds(1,3);
    point_from_move = [geo.crxs(ix,iy,ip), geo.crys(ix,iy,ip)];

    %%%ищем точку куда будем двигать
    [ixc, iyc, ~] = get_cell_index(point_to_move(1),point_to_move(2),geo);
    tmp = all_inds(:,1) == ixc & all_inds(:,2) == iyc;
    polygon = get_polygon(geo, ixc,iyc);
    [a, b] = get_pol_vxs(polygon,1);
    if ~(all(a == point_from_move) || all(b == point_from_move))
        [a, b] = get_pol_vxs(polygon,2);
    end

    [point_to_move(1),  point_to_move(2)] = get_closestpoint(a,b,point_to_move);

    %%% записываем как изменились расстояния
    dist_p(1) = abs(a(1)-point_to_move(1)); dist_p(2) = abs(a(2)-point_to_move(2)); 
    dist_n(1) = abs(b(1)-point_to_move(1)); dist_n(2) = abs(b(2)-point_to_move(2)); 
    %%% обновляем точки на графике
    update_point_on_plot(mesh_fig,point_from_move,point_to_move)
    
    for k=1:rows
        ix = all_inds(k,1);iy = all_inds(k,2);ip = all_inds(k,3);

        p_old = [geo.crxs(ix,iy,1) geo.crys(ix,iy,1)];

        geo.crxs(ix,iy,ip) = point_to_move(1);
        geo.crys(ix,iy,ip) = point_to_move(2);

        geo.crxs(ix,iy,1) = mean(geo.crxs(ix,iy,2:5));
        geo.crys(ix,iy,1) = mean(geo.crys(ix,iy,2:5));
      
        [bt, bp] = change_magnetic_field(geo,ix,iy, p_old);
        geo.bp(ix,iy) = bp;
        geo.bt(ix,iy) = bt;
    end

end

function [bt, bp] = change_magnetic_field(geo,ix,iy, old_point)
    
    x_coord = geo.crxs(:,iy,1);
    y_coord = geo.crys(:,iy,1);
    bp = geo.bp(:,iy);
    bp = bp(x_coord ~= 0);
    y_coord = y_coord(x_coord ~= 0);
    x_coord = x_coord(x_coord ~= 0);
    dist_to_bp = sqrt((x_coord-old_point(1)).^2+(y_coord-old_point(2)).^2);
    i_bp = find(dist_to_bp == min(dist_to_bp));
    diff_x = diff(x_coord);
    diff_y = diff(y_coord);
    dist_pol = sqrt(diff_x.^2+diff_y.^2);
    pol_coord = zeros(1,length(diff_y));
    for ik = 2:length(diff_y)+1
        pol_coord(1,ik) = pol_coord(1,ik-1)+dist_pol(ik-1);
    end
    xq = diste([x_coord(i_bp-1) y_coord(i_bp-1)], [geo.crxs(ix,iy,1) geo.crys(ix,iy,1)])+pol_coord(i_bp-1);

    bt = geo.bt(ix,iy)*old_point(2)/geo.crys(ix,iy,1);
    fprintf("in cell (ix,iy) (%d,%d) Bt was changed form %.2f to %.2f\n",ix,iy,geo.bt(ix,iy),bt);

    bp =interp1(pol_coord,bp,xq,'spline');
    fprintf("in cell (ix,iy) (%d,%d) Bp was changed form %.2f to %.4f\n",ix,iy,geo.bp(ix,iy),bp);
end


function [x, y] = get_closestpoint(a,b,c)
    C1 = b(1)-a(1);C2 = b(2)-a(2);
    A=1; B = -C1/C2; C = -a(1)+a(2)*C1/C2;
    x = (B*(B*c(1)-A*c(2))-A*C)/(A^2+B^2);
    y = (A*(-B*c(1)+A*c(2))-B*C)/(A^2+B^2);
end

function [ixc, iyc, ip] = get_cell_index(xc,yc,geo)
    for ix=1:geo.nx
        for iy=1:geo.ny
              polygon = get_polygon(geo, ix,iy);
              if inpolygon(xc,yc,polygon(:,1),polygon(:,2))
                  ixc = ix;iyc=iy;
                  dist = sqrt((xc-polygon(:,1)).^2+(yc-polygon(:,2)).^2);
                  tmp = find(dist == min(dist));
                  ip = tmp(1);
                  return
             end
        end
    end
end

function polygon = get_polygon(geo, ix,iy)
         polygon = [geo.crxs(ix,iy,2) geo.crys(ix,iy,2); geo.crxs(ix,iy,4) geo.crys(ix,iy,4);...
              geo.crxs(ix,iy,5) geo.crys(ix,iy,5); geo.crxs(ix,iy,3) geo.crys(ix,iy,3)];
end

function [a,b] = get_pol_vxs(polygon,ip)
    if ip==3 || ip == 2
        a = [polygon(3,1),polygon(3,2)];
        b = [polygon(2,1),polygon(2,2)];
    elseif ip == 1 || ip == 4
        a = [polygon(1,1),polygon(1,2)];
        b = [polygon(4,1),polygon(4,2)];
    end
end

function [a,b] = get_rad_vxs(polygon,ip)
    if ip==1 || ip == 2
        a = [polygon(1,1),polygon(1,2)];
        b = [polygon(2,1),polygon(2,2)];
    elseif ip == 3 || ip == 4
        a = [polygon(3,1),polygon(3,2)];
        b = [polygon(4,1),polygon(4,2)];
    end
end

function dist = diste(a,b)

   dist = sqrt((a(1)-b(1)).^2+(a(2)-b(2)).^2);
end


function all_inds = get_all_point_inds(geo,a)

        dist = (geo.crxs(:,:,2:end)-a(1)).^2+(geo.crys(:,:,2:end)-a(2)).^2;
        all_inds = zeros(0,0);
        for j=1:4
            [ixt, iyt] = find(dist(:,:,j) == min(min(min(dist))));
            for ik=1:length(ixt)
                all_inds(end+1,1:3) = [ixt(ik) iyt(ik) j+1];
            end
        end
end

function [x,y] = get_face_coords(polygon,ip)
        ip = ip+1;
        switch ip
            case 2
                x = mean([polygon(1,1),polygon(2,1)]);
                y = mean([polygon(1,2),polygon(2,2)]);
            case 4
                x = mean([polygon(3,1),polygon(4,1)]);
                y = mean([polygon(3,2),polygon(4,2)]);
            case 5
                x = mean([polygon(2,1),polygon(3,1)]);
                y = mean([polygon(2,2),polygon(3,2)]);
            case 3
                x = mean([polygon(4,1),polygon(1,1)]);
                y = mean([polygon(4,2),polygon(1,2)]);
        end
end

function [x,y] = get_face_ends_coords(polygon,ip)
        ip = ip+1;
        switch ip
            case 2 
                x = [polygon(1,1),polygon(2,1)];
                y = [polygon(1,2),polygon(2,2)];
            case 4
                x = [polygon(3,1),polygon(4,1)];
                y = [polygon(3,2),polygon(4,2)];
            case 5
                x = [polygon(2,1),polygon(3,1)];
                y = [polygon(2,2),polygon(3,2)];
            case 3
                x = [polygon(4,1),polygon(1,1)];
                y = [polygon(4,2),polygon(1,2)];
        end
end


function update_point_on_plot(mesh_fig,point_from_move,point_to_move)
    mesh_fig.p.Vertices(mesh_fig.p.Vertices(:,1) == point_from_move(1),1) = point_to_move(1);
    mesh_fig.p.Vertices(mesh_fig.p.Vertices(:,2) == point_from_move(2),2) = point_to_move(2);
    update_boundary_face_on_plot(mesh_fig,point_from_move,point_to_move)
    update_boundary_cell_marker_on_plot(mesh_fig,point_from_move,point_to_move);
end

function update_boundary_cell_marker_on_plot(mesh_fig,point_from_move,point_to_move)
    global geo
    all_inds = get_all_point_inds(geo,point_from_move);
    all_inds = unique(all_inds(:,1:2),'rows');
    for k=1:length(all_inds)
        if geo.cflags(all_inds(k,1),all_inds(k,2),1) == 3
            for k2=1:length(mesh_fig.bmarkers)
                if mesh_fig.bmarkers(k2).XData == geo.crxs(all_inds(k,1),all_inds(k,2),1) ...
                        && mesh_fig.bmarkers(k2).YData == geo.crys(all_inds(k,1),all_inds(k,2),1)
                    tmp = geo.crxs(all_inds(k,1),all_inds(k,2),2:5);
                    tmp(tmp == point_from_move(1)) = point_to_move(1);
                    xc_new = mean(tmp);
                    tmp = geo.crys(all_inds(k,1),all_inds(k,2),2:5);
                    tmp(tmp == point_from_move(2)) = point_to_move(2);
                    yc_new = mean(tmp);
                    mesh_fig.bmarkers(k2).XData = xc_new;
                    mesh_fig.bmarkers(k2).YData = yc_new;
                end
            end
        end
    end

end
function update_boundary_face_on_plot(mesh_fig,point_from_move,point_to_move)
    for k=1:length(mesh_fig.bfcs)
        if (mesh_fig.bfcs(k).XData(1) == point_from_move(1) && mesh_fig.bfcs(k).YData(1) == point_from_move(2))
            update_boundary_marker_on_plot(mesh_fig,[mean(mesh_fig.bfcs(k).XData) mean(mesh_fig.bfcs(k).YData)],...
                [mean([point_to_move(1) mesh_fig.bfcs(k).XData(2)]) mean([point_to_move(2) mesh_fig.bfcs(k).YData(2)])])
            mesh_fig.bfcs(k).XData(1) = point_to_move(1);
            mesh_fig.bfcs(k).YData(1) = point_to_move(2);
        end
        if (mesh_fig.bfcs(k).XData(2) == point_from_move(1) && mesh_fig.bfcs(k).YData(2) == point_from_move(2))
           update_boundary_marker_on_plot(mesh_fig,[mean(mesh_fig.bfcs(k).XData) mean(mesh_fig.bfcs(k).YData)],...
                [mean([point_to_move(1) mesh_fig.bfcs(k).XData(1)]) mean([point_to_move(2) mesh_fig.bfcs(k).YData(1)])])
            mesh_fig.bfcs(k).XData(2) = point_to_move(1);
            mesh_fig.bfcs(k).YData(2) = point_to_move(2);
        end
    end
end

function update_boundary_marker_on_plot(mesh_fig,point_from_move,point_to_move)
    for k=1:length(mesh_fig.bfcsmarkers)
        if mesh_fig.bfcsmarkers(k).XData == point_from_move(1) ...
              && mesh_fig.bfcsmarkers(k).YData == point_from_move(2)
            mesh_fig.bfcsmarkers(k).XData = point_to_move(1);
            mesh_fig.bfcsmarkers(k).YData = point_to_move(2);
        end
    end
end

function mesh_fig = get_mesh_fig_from_fig()
    mesh_fig = struct;
    all_objs = gcf().Children(end).Children;
    mesh_fig.bfcs = gobjects(0,1);
    mesh_fig.bfcsmarkers = gobjects(0,1);
    mesh_fig.bmarkers = gobjects(0,1);
    mesh_fig.omarkers = gobjects(0,1);
    mesh_fig.structures = gobjects(0,1);
    for k=1:length(all_objs)
        obj = all_objs(k);
        if contains(class(obj), 'Line')
            if strcmp(obj.LineStyle,'-')
                if obj.LineWidth == 2
                    mesh_fig.structures(end+1) = obj;
                else
                    mesh_fig.bfcs(end+1) = obj;
                end
            elseif strcmp(obj.LineStyle,'none') && strcmp(obj.Marker,'square')
                mesh_fig.bmarkers(end+1) = obj;
            elseif strcmp(obj.LineStyle,'none') && strcmp(obj.Marker,'o')
                mesh_fig.omarkers(end+1) = obj;
            elseif strcmp(obj.LineStyle,'none') && strcmp(obj.Marker,'^')
                mesh_fig.bfcsmarkers(end+1) = obj;
            end
        elseif contains(class(obj), 'Patch')
            mesh_fig.p = obj;
        end
    end
end

function [point,is_stop] = get_coords_from_fig(nPoints)
    point = zeros(0,2);
    is_stop = false;
    if nPoints > 0
        [xc,yc, button] = ginput(nPoints);
        if isempty(button) || button == 3
            is_stop = true;
        end
        point = zeros(size(xc,1),2);
        point(:,1) = xc;
        point(:,2) = yc;
    else
        is_end = false;
        while ~is_end
            [xc,yc, button] = ginput(1);
            if isempty(button) || button == 3
                is_stop = true;
                is_end = true;
            end
            point(end+1,:) = [xc, yc];
            if ~isempty(button) && button == 2
                is_end = true;
            end
        end
    end
end
