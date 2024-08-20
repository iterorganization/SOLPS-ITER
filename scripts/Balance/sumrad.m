% Given a logical array specifying the balance volume, find radially-summed
% values of fluxes, sources and residuals
% Also immediately calculate the distance from the downstream boundary for
% plotting
function [fluxedge,srcint,resint,xdata,xdatax] = sumrad(flux,src,res,indpol,facesup_pol,facesdown_pol,comuse,polbaldist)

    % Using the poloidal or parallel distance for plotting
    switch polbaldist
        case 'parallel'
            pit = comuse.cvBb(:,1)./comuse.cvBb(:,4);
        case 'poloidal'
            pit = ones(length(comuse.cvBb),1);
        otherwise
            error('Poloidal balance distance ''%s'' not supported.',polbaldist);
    end

    % Initialization
    fluxedge = zeros(size(flux));
    srcint = zeros(size(src));
    resint = zeros(size(res));
    xdata = zeros(size(res));
    xdatax = zeros(length(flux),1);
    iFc_done = []; % keep track of faces that are already included
    iCv_done = []; % keep track of cells that are already considered

    % Start with summing the fluxes at the upstream faces
    for i = 1:length(facesup_pol)
        iFc = facesup_pol(i);
        iFc_done = [iFc_done,iFc];
        if indpol(comuse.fcCv(iFc,1))
            fluxedge(1,:) = fluxedge(1,:) - flux(iFc,:);
            iCv_done = [iCv_done,comuse.fcCv(iFc,2)];
        else
            fluxedge(1,:) = fluxedge(1,:) + flux(iFc,:);
            iCv_done = [iCv_done,comuse.fcCv(iFc,1)];
        end
    end
    iFc_next = iFc_done;

    iout = 1;
    while ~isempty(iFc_next)
        iout = iout + 1;
        iFc_next2 = [];
        distx = 0;
        for i = 1:length(iFc_next)
            iFc = iFc_next(i);
            if ~any(iCv_done == comuse.fcCv(iFc,1))
                iCv = comuse.fcCv(iFc,1);
                iCv_done = [iCv_done,iCv];
            elseif ~any(iCv_done == comuse.fcCv(iFc,2))
                iCv = comuse.fcCv(iFc,2);
                iCv_done = [iCv_done,iCv];
            else
                break;
            end
            srcint(iout-1,:) = srcint(iout-1,:) + src(iCv,:);
            resint(iout-1) = resint(iout-1) + res(iCv);
            distx = distx + comuse.cvHx(iCv)/pit(iCv)/length(iFc_next);
            iFc1 = comuse.cvFcP(iCv,1);
            iFc2 = iFc1 + comuse.cvFcP(iCv,2) - 1;
            for j = iFc1:iFc2
                iFc = comuse.cvFc(j);
                if any(iFc_done == iFc) 
                    continue;
                end
                if comuse.cvFt(comuse.fcCv(iFc,1)) == comuse.cvFt(comuse.fcCv(iFc,2))
                    if iCv == comuse.fcCv(iFc,1)
                        fluxedge(iout,:) = fluxedge(iout,:) + flux(iFc,:);
                    else
                        fluxedge(iout,:) = fluxedge(iout,:) - flux(iFc,:);
                    end
                    iFc_done = [iFc_done,iFc];
                    if ~any(facesdown_pol == iFc)
                        iFc_next2 = [iFc_next2,iFc];
                    end
                end
            end
            iFc_next = iFc_next2;
        end
        xdatax(iout) = xdatax(iout-1) + distx;
    end


    %% Eliminate all unnecessary elements from the fluxes, sources and residuals
    fluxedge(iout+1:end,:) = [];
    srcint(iout:end,:) = [];
    resint(iout:end) = [];
    xdatax(iout+1:end) = [];

    % Reverse the distance
    xdatax = xdatax(end) - xdatax;

    xdata = 0.5*(xdatax(1:end-1) + xdatax(2:end));
 end
