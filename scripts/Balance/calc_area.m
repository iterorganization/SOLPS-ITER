function area_divide = calc_area(comuse,areatype)

    % Shorthand for geometry variables:
    nx = comuse.nx;
    ny = comuse.ny;
    leftix = comuse.leftix+1;  % Convert to one-based
    leftiy = comuse.leftiy+1;

    dv = comuse.dv; % Cell vol.
    hx = comuse.hx; % hx
    B = comuse.bb; % Mag. field
    
    switch areatype
        case 'parallel'        
            % Parallel area at cell centres:
            apll = dv./hx.*abs(B(:,:,1)./B(:,:,4));
            % Map to left cell face:
            area_divide = zeros(nx,ny);
            for iy=1:ny
                for ix=1:nx
                    if leftix(ix,iy)<1
                        continue;
                    end
                    area_divide(ix,iy) = (apll(leftix(ix,iy),leftiy(ix,iy))*dv(ix,iy)+...
                                          apll(ix,iy)*dv(leftix(ix,iy),leftiy(ix,iy)))/...
                                         (dv(ix,iy)+dv(leftix(ix,iy),leftiy(ix,iy)));
                end
            end
            units = 'm^{-2}s^{-1}';
        case 'contact'
            area_divide = comuse.gs(:,:,1); % Poloidal contact area
            units = 'm^{-2}s^{-1}';
        case 'none'
            area_divide = ones(comuse.nx,comuse.ny); % No division by area
            units = 's^{-1}';
        otherwise
            error('Area type ''%s'' not supported.',areatype);
    end

end