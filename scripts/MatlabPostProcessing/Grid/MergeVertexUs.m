function gmtry = MergeVertexUs(gmtry0,vx0,vx)
%
%

if length(vx0)~=length(vx)
    error('vx0 en vx need to have same length.');
end


% Init as copy
gmtry = gmtry0;

for i = 1:length(vx0)
    
    % Identify face between vertices to be merged: will be removed
    iFc_rem = find((gmtry0.fcVx(:,1) == vx0(i) & gmtry0.fcVx(:,2) == vx(i)) |...
                   (gmtry0.fcVx(:,2) == vx0(i) & gmtry0.fcVx(:,1) == vx(i)))
    
    % Identify cells that are affected
    iCv_rem = gmtry0.fcCv(iFc_rem,:)
    
    % Adapt vertex numbers of cells and faces
    gmtry.cvVx(gmtry0.cvVx    == vx0(i)) = vx(i);
    gmtry.fcVx(gmtry0.fcVx(:,1) == vx0(i),1) = vx(i);
    gmtry.fcVx(gmtry0.fcVx(:,2) == vx0(i),2) = vx(i);
    
    % Remove vertex data
    gmtry.nVx    = gmtry0.nVx - 1;
    gmtry.vxBb   = gmtry0.vxBb([1:vx0(i)-1,vx0(i)+1:gmtry.nVx]',:);
    gmtry.vxFfbz = gmtry0.vxFfbz([1:vx0(i)-1,vx0(i)+1:gmtry.nVx]');
    gmtry.vxFpsi = gmtry0.vxFpsi([1:vx0(i)-1,vx0(i)+1:gmtry.nVx]',:);
    gmtry.vxX    = gmtry0.vxX([1:vx0(i)-1,vx0(i)+1:gmtry.nVx]');
    gmtry.vxY    = gmtry0.vxY([1:vx0(i)-1,vx0(i)+1:gmtry.nVx]');
    
    % Remove face data
    gmtry.nFc    = gmtry0.nFc - 1;
    gmtry.fcBb   = gmtry0.fcBb([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]',:);
    gmtry.fcHc   = gmtry0.fcHc([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]',:);
    gmtry.fcHt   = gmtry0.fcHt([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]');
    gmtry.fcLbl  = gmtry0.fcLbs([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]');
    gmtry.fcPbs  = gmtry0.fcPbs([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]');
    gmtry.fcQalf = gmtry0.fcQalf([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]',:);
    gmtry.fcQbet = gmtry0.fcQbet([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]',:);
    gmtry.fcQgam = gmtry0.fcQgam([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]',:);
    gmtry.fcReg  = gmtry0.fcReg([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]');
    gmtry.fcS    = gmtry0.fcS([1:iFc_rem-1,iFc_rem+1:gmtry.nFc]');
    
%     for j = 1:length(iCv_rem)
%         
%         if gmtry.cvVx(iCv_rem(j),2) == 3 % triangular cell => becomes degenerate
%             
%             gmtry.cvVx(gmtry0.cvVx   ==vx0(i)) = vx(i);
%             gmtry.fcVx(gmtry0.fcVx(:)==vx0(i)) = vx(i);
%             
%         else
%             error('Unexpected cell topogoly.')
%         end
%            
%     end

end
