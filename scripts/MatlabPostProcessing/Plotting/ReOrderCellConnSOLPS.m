function geo_us = ReOrderCellConnSOLPS(geo_us,is_ordered,cells)
% geo_us = ReOrderCellConnSOLPS(geo_us,is_ordered,cells)
%
% Description
% ------------
% Re-orders vertices and faces of cells in an order such that they form a
% chain as you would walk over the cell boundary

% Options
% --------
determined_direction = 1;

if nargin == 2
  % Assumption that is_ordered is for cells = 1:geo_us.nCv
  cells = find(is_ordered == 0);
elseif ~isempty(is_ordered)
  cells = cells(is_ordered == 0);
end

for i = 1:length(cells)
    iCv = cells(i);
        % Information of this cell is not ordered
        s = geo_us.cvVxP(iCv,1);
        n = geo_us.cvVxP(iCv,2);
        verts = geo_us.cvVx(s:s+n - 1);
        faces = geo_us.cvFc(s:s+n - 1);

        new_verts = zeros(n,1);
        new_faces = zeros(n,1);

        % Starting point
        new_verts(1) = verts(1);

        verts_of_faces = geo_us.fcVx(faces,:);

        % Find the two faces connected to that vertex and the other vertex
        % connected to that face

        % Find the first face
        [index,~] = find(verts_of_faces == new_verts(1)); %always array of two because the verts belongs to two faces in that cell

        % HERE DETERMINE right turning or left turning, right turning is
        % used
        if determined_direction

            % Define vectors from cell centers to points (entry1=x, entry2=y)
            vec_start(1) = geo_us.vxX(new_verts(1)) - geo_us.cvX(iCv);
            vec_start(2) = geo_us.vxY(new_verts(1)) - geo_us.cvY(iCv);

            %index1
            face1 = faces(index(1));
            fc1X = (geo_us.vxX(geo_us.fcVx(face1,1)) + geo_us.vxX(geo_us.fcVx(face1,2))) /2;
            fc1Y = (geo_us.vxY(geo_us.fcVx(face1,1)) + geo_us.vxY(geo_us.fcVx(face1,2))) /2;
            vec_face1(1) = fc1X - geo_us.cvX(iCv);
            vec_face1(2) = fc1Y - geo_us.cvY(iCv);

            %index2
            face2 = faces(index(2));
            fc2X = (geo_us.vxX(geo_us.fcVx(face2,1)) + geo_us.vxX(geo_us.fcVx(face2,2))) /2;
            fc2Y = (geo_us.vxY(geo_us.fcVx(face2,1)) + geo_us.vxY(geo_us.fcVx(face2,2))) /2;
            vec_face2(1) = fc2X - geo_us.cvX(iCv);
            vec_face2(2) = fc2Y - geo_us.cvY(iCv);

            % Calculate angles (sin = |a x b| / norm(a)*norm(b))
            % with |a x b | = ax*by - bx*ay
            % dividing by norm is needed because norm is always positive and
            % only the sign matters
            % a = always vector from cell center to starting point
            sin1 = vec_start(1)*vec_face1(2) - vec_face1(1) * vec_start(2);

            sin2 = vec_start(1)*vec_face2(2) - vec_face2(1) * vec_start(2);

            % Choose the one with positive sign, that right turning
            if sin1 > 0
                index = index(1); %first face
            elseif sin2 > 0
                index = index(2); %second face
            else
                figure,plotgeo_us(geo_us,'fast'),hold on
                plot(geo_us.cvX(iCv),geo_us.cvY(iCv),'b*')
                plot(geo_us.vxX(verts),geo_us.vxY(verts),'g*')
                error('ReOrderCellConn: no start face assigned, probably due to cell overlap')
            end


        else
         index = index(1); %this determines right hand turning or left hand turning but not a priori determined which direction
        end
        new_faces(1) = faces(index);


        %After this direction is fixed - implementation should be in a loop
        try % because ordening is non-trivial with slab case with cuts
        for i = 2:length(verts)
            %i-1
            % Find the next vertex
            vs = geo_us.fcVx(new_faces(i-1),:);

            if ~any(new_verts == vs(1))%~ismember(vs(1),new_verts)
                new_verts(i) = vs(1);
            else %elseif ~ismember(new_verts,vs(2)
                new_verts(i) = vs(2);
            end

            % Find the next face
            [index,~] = find(verts_of_faces == new_verts(i)); %two options

            if ~any(new_faces == faces(index(1)))%~ismember(faces(index(1)),new_faces)
               new_faces(i) = faces(index(1));
            else
               new_faces(i) = faces(index(2));
            end
        end

        % Plug new_verts and new_faces in cell.vert and cell.face
        geo_us.cvVx(s:s+n - 1) = new_verts;
        geo_us.cvFc(s:s+n - 1) = new_faces;


        catch
                % Visualize
                figure,plotgeo_us(geo_us,'fast'),hold on
                plot(geo_us.cvX(iCv),geo_us.cvY(iCv),'g*')
                plot(geo_us.vxX(verts),geo_us.vxY(verts),'m*')
                fcX = 0.5*sum(geo_us.vxX(geo_us.fcVx),2);
                fcY = 0.5*sum(geo_us.vxY(geo_us.fcVx),2);
                plot(fcX(faces),fcY(faces),'r*')
                disp(['ReOrderCellConn: not able to order cell ',num2str(iCv)])
         end





end

end

