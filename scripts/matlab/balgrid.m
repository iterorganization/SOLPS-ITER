function balgrid(geomb2,indbal,iyplot,axgrid,reverse)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% balgrid plots the whole grid for a particular simulation, as well as the     %
% particular volume where integrated balance is to be performed and the        %
% poloidal cells along which poloidal balance will be performed                % 
%                                                                              %
% David Moulton (david.moulton@ccfe.ac.uk) August 2015.                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

axis(axgrid,'equal');
xlabel(axgrid,'R (m)');
ylabel(axgrid,'Z (m)');

rbl = geomb2.r(:,:,1);
rbr = geomb2.r(:,:,2);
rtl = geomb2.r(:,:,3);
rtr = geomb2.r(:,:,4);
zbl = geomb2.z(:,:,1);
zbr = geomb2.z(:,:,2);
ztl = geomb2.z(:,:,3);
ztr = geomb2.z(:,:,4);

% Plot the grid (including ghost cells):
patch([reshape(rbl,1,[]);...
       reshape(rbr,1,[]);...
       reshape(rtr,1,[]);...
       reshape(rtl,1,[])],...
      [reshape(zbl,1,[]);...
       reshape(zbr,1,[]);...
       reshape(ztr,1,[]);...
       reshape(ztl,1,[])],'w','parent',axgrid,'handlevisibility','off');

% Plot the volume of interest:
patch([reshape(rbl(indbal),1,[]);...
       reshape(rbr(indbal),1,[]);...
       reshape(rtr(indbal),1,[]);...
       reshape(rtl(indbal),1,[])],...
      [reshape(zbl(indbal),1,[]);...
       reshape(zbr(indbal),1,[]);...
       reshape(ztr(indbal),1,[]);...
       reshape(ztl(indbal),1,[])],...
      'y','parent',axgrid);

% Plot the rings along which poloidal balance is to be performed:
for iy=iyplot
    inds = find(indbal(:,iy));
    if ~isempty(inds)
        patch([reshape(rbl(inds,iy),1,[]);...
               reshape(rbr(inds,iy),1,[]);...
               reshape(rtr(inds,iy),1,[]);...
               reshape(rtl(inds,iy),1,[])],...
              [reshape(zbl(inds,iy),1,[]);...
               reshape(zbr(inds,iy),1,[]);...
               reshape(ztr(inds,iy),1,[]);...
               reshape(ztl(inds,iy),1,[])],...
              'm','parent',axgrid);
    end
end
   
% Plot the left- and right-most surfaces of the volume of interest
rleft = [];
zleft = [];
rright = [];
zright = [];
for iy = 1:geomb2.ny
    first = find(indbal(:,iy),1,'first');
    last = find(indbal(:,iy),1,'last');
    if ~isempty(first)
        rleft = [rleft,rbl(first,iy),rtl(first,iy)];
        zleft = [zleft,zbl(first,iy),ztl(first,iy)];
        rright = [rright,rbr(last,iy),rtr(last,iy)];
        zright = [zright,zbr(last,iy),ztr(last,iy)];
    end
end

if ~reverse
    plot(rleft,zleft,'-g','parent',axgrid);
    plot(rright,zright,'-r','parent',axgrid);
else
    plot(rright,zright,'-r','parent',axgrid);
    plot(rleft,zleft,'-g','parent',axgrid);
end
    
legend(axgrid, 'integrated balance volume',...
                           'poloidal balance cells',...
                           'upstream face',...
                           'downstream face')

end
