function area_divide = calc_area(comuse,areatype)

    switch areatype
        case 'parallel'
            area_divide = comuse.fcS.*abs(comuse.fcQalf(:,1)).*...
                comuse.fcBb(:,1)./comuse.fcBb(:,4);
            units = 'm^{-2}s^{-1}';
        case 'contact'
            area_divide = comuse.fcS; % Poloidal contact area
            units = 'm^{-2}s^{-1}';
        case 'none'
            area_divide = ones(comuse.nFc,1); % No division by area
            units = 's^{-1}';
        otherwise
            error('Area type ''%s'' not supported.',areatype);
    end

end
