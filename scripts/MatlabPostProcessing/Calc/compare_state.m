function compare_state(state1,state2,ns)

vars = {'na';'ne';'ua';'te';'ti';'po';'fna';'fhe';'fhi'};

dim =    [ns  1    ns   1    1    1    ns*2   2     2 ];

errmax = -1;
for kk=1:length(vars)
    eval(['yy1=state1.',vars{kk},';'])
    eval(['yy2=state2.',vars{kk},';'])
    
    if dim(kk)==ns
        for is=1:ns
            err = norm(yy1(:,:,is)-yy2(:,:,is))/norm(yy1(:,:,is));
            sprintf(['\nAverage error on ',vars{kk},' for species %i = %d'],is,err)
            errmax = max(errmax,err);
        end
    elseif dim(kk)==ns*2
        for is=1:ns
            for ii=1:2
                err = norm(yy1(:,:,ii,is)-yy2(:,:,ii,is))/norm(yy1(:,:,ii,is));
                sprintf(['\nAverage error on ',vars{kk},' for species %i, rad/pol %i = %d'],is,ii,err)
                errmax = max(errmax,err);
            end
        end
        
    elseif dim(kk)==2
        for is=1:2
            err = norm(yy1(:,:,is)-yy2(:,:,is))/norm(yy1(:,:,is));
            sprintf(['\nAverage error on ',vars{kk},' for rad/pol %i = %d'],is,err)
            errmax = max(errmax,err);
        end
    else
        err = norm(yy1(:,:)-yy2(:,:))/norm(yy1(:,:));
        sprintf(['\nAverage error on ',vars{kk},'= %d'],err)
        errmax = max(errmax,err);
    end


end

errmax


end