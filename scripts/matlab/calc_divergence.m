function [div_x,div_y,div] = calc_divergence(flux_x,flux_y,nx,ny,top,right);

%div_x=zeros(ny+2,nx+2);
%div_y=zeros(ny+2,nx+2);
%div=zeros(ny+2,nx+2);

for i=1:ny+2
    for j=1:nx+2
        div_x(i,j) = - flux_x(i,j);
        div_y(i,j) = - flux_y(i,j);
        if top(i,j) ~= ny+1 
            div_y(i,j) = div_y(i,j) + flux_y(top(i,j)+2,j);
%            divqi(i,j) = divqi(i,j) + fhe_mdfY(top(i,j)+2,j);
        end;
        if right(i,j) ~= nx+1
            div_x(i,j) = div_x(i,j) + flux_x(i,right(i,j)+2);
%            divqi(i,j) = divqi(i,j) + fhe_mdfX(i,right(i,j)+2);
        end;
    end;
end;
div=div_x+div_y;
iout=0;