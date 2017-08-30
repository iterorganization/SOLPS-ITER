function integral = volume_integral_region(value,nxbeg,nybeg,nxend,nyend,nx,ny,left,right);



integral = 0.0;
for i=nybeg+2:nyend+2
for j=nxbeg+2:nxend+2
    if (left(i,j) ~= -2 && right(i,j) ~= nx-1)
       integral = integral + value(i,j);
    end;
end;
end;
