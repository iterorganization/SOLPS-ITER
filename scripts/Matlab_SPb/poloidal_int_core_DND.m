function integral = poloidal_int_core_DND(value,nx,ny,nc1,nc2,nc3,nc4,nrad);



integral = 0.0;
for j=nc1:nc2
    integral = integral + value(nrad+2,j+2);
end;
for j=nc3:nc4
    integral = integral + value(nrad+2,j+2);
end;
