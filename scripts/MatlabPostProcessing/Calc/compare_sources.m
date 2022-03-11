function compare_sources(state1,state2,ns)

vars =   {'she';'shi';'sna';'smo';'smq';'skt';'reshe';'reshi';'resco';'resmo';'resmt';'respo';'reskt'};

dim =    { '4' ; '4' ;  'ns*2'  ;  'ns*4';  'ns*4';    '4';  '1';  '1';  'ns';  'ns';  '1';  '1';  '1'};
%nx = nx+2;
%ny=ny+2;
%boundary2 = [1:ny];
%boundary1 = [1:nx];

errmax = -1;
for kk=1:length(vars)
    eval(['yy1=state1.',vars{kk},';'])
    eval(['yy2=state2.',vars{kk},';'])
    
    
    if strcmp(dim{kk},'ns')
        for is=1:ns
            err = norm(yy1(:,:,is)-yy2(:,:,is))/(norm(yy1(:,:,is))+1e-30);
            fprintf(['\nAverage error on ',vars{kk},' for species %i = %d'],is,err)
            errmax = max(errmax,err);
        end
    elseif strcmp(dim{kk},'ns*2')
        for is=1:ns
            for ii=1:2
                err = norm(yy1(:,:,ii,is)-yy2(:,:,ii,is))/(norm(yy1(:,:,ii,is))+1e-30);
                fprintf(['\nAverage error on ',vars{kk},' for species %i, ind %i = %d'],is,ii,err)
                errmax = max(errmax,err);
            end
        end
    elseif strcmp(dim{kk},'ns*4')
        for is=1:ns
            for ii=1:4
                err = norm(yy1(:,:,ii,is)-yy2(:,:,ii,is))/(norm(yy1(:,:,ii,is))+1e-30);
                fprintf(['\nAverage error on ',vars{kk},' for species %i, ind %i = %d'],is,ii,err)
                errmax = max(errmax,err);
            end
        end        
    elseif strcmp(dim{kk},'2')
        for is=1:2
            err = norm(yy1(:,:,is)-yy2(:,:,is))/(norm(yy1(:,:,is))+1e-30);
            fprintf(['\nAverage error on ',vars{kk},' for ind %i = %d'],is,err)
            errmax = max(errmax,err);
        end
    elseif strcmp(dim{kk},'4')
        for is=1:4
            err = norm(yy1(:,:,is)-yy2(:,:,is))/(norm(yy1(:,:,is))+1e-30);
            fprintf(['\nAverage error on ',vars{kk},' for ind %i = %d'],is,err)
            errmax = max(errmax,err);
        end
    else
        err = norm(yy1(:,:)-yy2(:,:))/(norm(yy1(:,:))+1e-30);
        fprintf(['\nAverage error on ',vars{kk},'= %d'],err)
        errmax = max(errmax,err);
    end


end

errmax


end