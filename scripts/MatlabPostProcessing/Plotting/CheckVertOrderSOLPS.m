function is_ordered = CheckVertOrderSOLPS(geo_us,cells)
% is_ordered = CheckVertOrderSOLPS(geo_us,cells)
%
% Check per cell whether the vertices and faces are ordered correctly,
% following the right turning scheme
% Returns the array is_ordered with the indication whether the information
% is ordered correctly or not. 1 = correctly ordered, 0 = not correctly
% ordered
%

if nargin == 2
    is_ordered = ones(length(cells),1);
else
    is_ordered = ones(geo_us.nCi,1);
    cells = 1:geo_us.nCi;
end

% Calc face centers
fcX = 0.5*sum(geo_us.vxX(geo_us.fcVx),2);
fcY = 0.5*sum(geo_us.vxY(geo_us.fcVx),2);

for j = 1:length(cells)
    iCv = cells(j);
    nv = geo_us.cvVxP(iCv,2);
    s = geo_us.cvVxP(iCv,1);

    % Get vertices and faces
    verts = geo_us.cvVx(s:s+nv - 1);
    faces = geo_us.cvFc(s:s+nv - 1);


    % First check whether vertices and faces are connected according to the
    % correct ordering
    for i = 1: nv-1  %number of faces -1
        v1 = verts(i);
        v2 = verts(i+1);
        f1 = faces(i);
        v1f = geo_us.fcVx(f1,1);
        v2f = geo_us.fcVx(f1,2);
        %if ~ismember(verts(i), geo_us.face.vert(faces(i),:)) || ~ismember(verts(i+1), geo_us.face.vert(faces(i),:))
        if ((v1 ~= v1f) && (v1 ~= v2f)) || ((v2 ~= v1f) && (v2 ~= v2f))
            is_ordered(j) = 0;
            break % probably not translatable to fortran
        end
    end
    i = nv;
    v1 = verts(i);
    f1 = faces(i);
    v1f = geo_us.fcVx(f1,1);
    v2f = geo_us.fcVx(f1,2);
    %if ~ismember(verts(i),geo_us.face.vert(faces(i),:)) || ~ismember(verts(1), geo_us.face.vert(faces(i),:))
    if ((v1 ~= v1f) && (v1 ~= v2f)) || ((verts(1) ~= v1f) && (verts(1) ~= v2f))
        is_ordered(j) = 0;
    end

    if is_ordered(j) == 1   %if the above is still oke => check the directions

        cvX = geo_us.cvX(iCv);
        cvY = geo_us.cvY(iCv);
        %Calculate vectors between centroids and vertices
        vec_vxX = geo_us.vxX(verts)- cvX;
        vec_vxY = geo_us.vxY(verts)- cvY;

        %Calculate vectors between centroids and face centers
        %face centers
        %fcX = (geo_us.vxX(geo_us.face.vert(faces,1))  + geo_us.vxX(geo_us.face.vert(faces,2)) ) /2;
        %fcY = (geo_us.vxY(geo_us.face.vert(faces,1))  + geo_us.vxY(geo_us.face.vert(faces,2)) ) /2;

        %vectors
        vec_fcX = fcX(faces) - cvX;
        vec_fcY = fcY(faces) - cvY;


        for i = 1:nv-1

            %check sinus between vector to vertex (a) and vector to face
            %center (b)
            %calculate angles (sin = |a x b| / norm(a)*norm(b))
            %with |a x b | = ax*by - bx*ay
            sin1 = vec_vxX(i)*vec_fcY(i) - vec_fcX(i) * vec_vxY(i);

            %should be positive
            if sin1 < 0
                is_ordered(j) = 0;
                break
            else
                %check sinus between vector to face center (b) and vector
                %to second vertex (a)
               sin2 = vec_fcX(i)*vec_vxY(i+1) - vec_vxX(i+1)*vec_fcY(i);
               if sin2 < 0
                  is_ordered(j) = 0;
                  break
               end
            end

        end
        %last face needs normally no checking anymore because all vertices
        %where already involved in loop above, so if last faces has
        %verts(1) en verts(end) (which is checked earlier), this is OK

    end


end

