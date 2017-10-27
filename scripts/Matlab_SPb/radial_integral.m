function integral = radial_integral(value,ibeg,iend,npol);



integral = 0.0;
for i=ibeg+2:iend+2
    integral = integral + value(i,npol+2);
end;
