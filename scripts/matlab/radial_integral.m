function integral = radial_integral(value,nx,ny,npol);



integral = 0.0;
for i=1+1:ny+2-1
    integral = integral + value(i,npol+2);
end;
