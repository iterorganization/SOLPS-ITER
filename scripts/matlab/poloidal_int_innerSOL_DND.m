function integral = poloidal_int_innerSOL_DND(value,nx,ny,nc2,nc3,nrad);



integral = 0.0;
for j=-1:nc2
    integral = integral + value(nrad+2,j+2);
end;
for j=nc3:nx
    integral = integral + value(nrad+2,j+2);
end;
