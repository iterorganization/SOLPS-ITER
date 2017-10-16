function X=readdatavalue(name,nx,ny,max_nx,max_ny)

Y=dlmread(name,'',1,1);
A=(ny+2:-1:1);
X=zeros(max_ny+2,max_nx+2);
%X=1.0;
for i=1:ny+2
    for j=1:nx+2
        X(i,j)=Y(ny+2+1-i,j);
    end;
end;


