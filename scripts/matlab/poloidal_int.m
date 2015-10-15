function integral = poloidal_int(value,nx,ny,nxstart,nxend,nrad);



integral = 0.0;
for j=nxstart:nxend
    integral = integral + value(nrad+2,j+2);
end;
