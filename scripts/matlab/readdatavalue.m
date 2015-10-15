function X=readdatavalue(name,nx,ny)

Y=dlmread(name,'',1,1);
A=(ny+2:-1:1);
X=Y([A],:);


