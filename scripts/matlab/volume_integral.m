function integral = volume_integral(value,nx,ny);



integral = 0.0;
for i=1:ny+2
for j=1:nx+2
    integral = integral + value(i,j);
end;
end;
