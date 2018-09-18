function iout=poloidal_plot_5(x,value1,value2,value3,value4,value5,nx,ny,nb1,ne1,nb2,ne2,npl,nlines,Gtitle,Ylabel,label1,label2,label3,label4,label5);

%figure;
figure('Position',[1 900 1250 900]);
set(figure(gcf), 'name', Gtitle);
%axes('FontName','Times','FontSize',24);
xx=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
value=zeros((ne1-nb1)+1+(ne2-nb2)+1,1);
npli=0;
      xx(1:ne1-nb1+1)=x(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x(npl+npli+2,nb2+2:ne2+2);
      value(1:ne1-nb1+1)=value1(npl+npli+2,nb1+2:ne1+2);
      value(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value1(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-o','LineWidth',2,'Color',[1,0,0]);
      hold all;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-s','LineWidth',2,'Color',[0.45,0.1,0.05]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-*','LineWidth',2,'Color',[0.75,0.2,0.15]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-h','LineWidth',2,'Color',[0,0,0]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-^','LineWidth',2,'Color',[0.15,0.05,0.5]);
      hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'->','LineWidth',2,'Color',[0.25,0.5,0.25]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-<','LineWidth',2,'Color',[1,0.6,0]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-v','LineWidth',2,'Color',[1,0.05,0.75]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-+','LineWidth',2,'Color',[0.25,0.5,0.25]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-o','LineWidth',2,'Color',[0,0,1]);
      hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-s','LineWidth',2,'Color',[0.5,0.5,1]);
      hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-*','LineWidth',2,'Color',[0.0,0.5,1]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-h','LineWidth',2,'Color',[1.0,0.5,1]);
      hold all;
end;
npli=npli+1;

%%%%

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-o','LineWidth',2,'Color',[0.6,0.05,0.4]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-s','LineWidth',2,'Color',[0.35,0.65,0.15]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-h','LineWidth',2,'Color',[0.8,0.2,0.8]);
      hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-*','LineWidth',2,'Color',[0.2,0.2,0.5]);
      hold all;
end;
npli=npli+1;


if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-+','LineWidth',2,'Color',[0.4,0.4,0.55]);
      hold all;
end;
npli=npli+1;

if npl + npli <= ny && npli <= nlines - 1
      xx(1:ne1-nb1+1)=x2(npl+npli+2,nb1+2:ne1+2);
      xx(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=x2(npl+npli+2,nb2+2:ne2+2);
      value1(1:ne1-nb1+1)=value(npl+npli+2,nb1+2:ne1+2);
      value1(ne1-nb1+2:(ne1-nb1)+1+(ne2-nb2)+1)=value(npl+npli+2,nb2+2:ne2+2);
      plot(xx,value1,'-<','LineWidth',2,'Color',[0.5,0.5,0.5]);
      hold all;
end;
npli=npli+1;

set(gca,'FontName','Times','FontSize',30);
xlabel('Distance from origin (in poloidal direction), m','FontName','Times','FontSize',30);
ylabel(Ylabel,'interpreter', 'latex','FontSize',30,'FontName','Times');
title(Gtitle,'FontName','Times','FontSize',30);
legend(label1,label2,label3,label4,label5'Location','NorthEastOutside');
grid on
grid minor;
iout=0;
