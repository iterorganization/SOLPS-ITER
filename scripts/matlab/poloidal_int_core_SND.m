function integral = poloidal_int_core_SND(value,nx,ny,nc1,nc2,nrad);



integral = 0.0;
for j=nc1:nc2
    integral = integral + value(nrad+2,j+2);
end;
