function [ifs] = find_flux_surfaces(gmtry,icv)

faces = gmtry.cvFc(gmtry.cvFcP(icv,1):gmtry.cvFcP(icv,1)+gmtry.cvFcP(icv,2)-1);

fsfc = gmtry.fsFc;

count = 1;
for ii = 1 : length(faces)
    % now find face ifc in flux surface list
    iss = find(gmtry.fsFc==faces(ii)); % index in the list
    if ~isempty(iss)
        for js = 1 : gmtry.nFs %loop over number of flux surfaces and find where iss is
            is1 = gmtry.fsFcP(js,1);
            is2 = gmtry.fsFcP(js,1) + gmtry.fsFcP(js,2) -1;
            if iss >= is1 && iss<= is2
                % found!
                ifs(count) = js;
                count = count + 1;
                break
            end
        end
    end

end

    ifs = unique(ifs);

end