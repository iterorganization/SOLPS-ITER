% Given a logical array specifying the balance volume, find values of edge-
% centred quantities at the left- or right-most ends of that volume
function fluxend = findlr(flux,indbal,direction,rightix,rightiy)
    fluxend = [];
    for iy=1:size(flux,2)
        inds = find(indbal(:,iy));
        if ~isempty(inds)
            if strcmp(lower(direction),'left')
                fluxend = [fluxend,flux(inds(1),iy)];
            elseif strcmp(lower(direction),'right')
                fluxend = [fluxend,flux(rightix(inds(end),iy),rightiy(inds(end),iy))];
            else
                error('direction must be ''left'' or ''right''');
            end
        end
    end
end