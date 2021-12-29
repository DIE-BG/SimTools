close all
%clear all


load mms5.mat;

d = dbload('data_q.csv');
startpred = qq(2021,2);   
endpred   = qq(2030,4);    

%r = simulate(g,d,startpred:endpred,'plan',Q,'anticipate',false);
r = simulate(g,d,startpred:endpred,'anticipate',true);
r = dbextend(d,r);
      

%%GRÁFICAS
    startplot = qq(2010,4);
    plotrng = startplot:qq(2025,4);
    plotrng_a = qq(2005,1):qq(2025,4);

%Gráfica1
figure;

list1 = {'i', 'v_cpi', 'v_cpi_sub', 'v_cpi_nosub', 'v_y',   'r',  'v_s',  'v_z',  'E_v_cpi', 'E_v_s', 'prem',  'v_y_star', 'v_cpi_star', 'i_star', 'v_fpi'};

set(gcf,'defaultaxesfontname','times','defaultaxesfontsize',10);
for j = 1 : length(list1)
  subplot(4,4,j);
  plot(plotrng, r.(list1{j}),'.-b');
  grid on;
  title(list1{j},'interpreter','none');
  highlight(startplot:startpred-1);
end


dbsave(r,'full_data');