function integral = volume_integral_whole(value,nx,ny,left,right);



integral = 0.0;
for i=2:ny+1
for j=2:nx+1
    if (left(i,j) ~= -2 && right(i,j) ~= nx-1)
       integral = integral + value(i,j);
    end;
end;
end;
