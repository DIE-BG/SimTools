%1. SIMULACI�N DE UN CHOQUE DE UN PUNTO PORCENTUAL A LA TASA DE INTER�S DE
%POL�TICA MONETARIA

%Definici�n de per�odos de simulaci�n
startSim = 1;
endSim = 40;

% Creaci�n de un choque en el per�odo 1
p1.s_i(startSim) = 1;

%Asignaci�n del choque al modelo, el cual se convertir� en g1
g1 = assign(g, p1);

%Soluci�n del modelo g1 con el choque
g1 = solve(g1);
g1 = sstate(g1);
ss1 = get(g1, 'sstate');

%Base de datos con estados estacionarios del modelo original (g)
g_sim = sstatedb(g, startSim-4 :endSim);
g_sim.s_i(startSim) = 1; %choque

%Simulaci�n del modelo con choque (g1)
g1_sim = simulate (g1, g_sim, startSim:endSim);
g1_sim = dbextend(g_sim, g1_sim);


% GR�FICAS

plotrng = startSim-4:endSim;

figure;

list = {'i', 'v_y',  'v_cpi', 'v_cpi_sub', 'v_cpi_nosub', 'v_z', 'E_v_cpi', 'v_s', 'E_v_s', 'prem', 'r',  'v_cpi_star', 'v_y_star', 'i_star', 'v_fpi'};

set(gcf, 'defaultaxesfontname', 'times', 'defaultaxesfontsize', 9);

for j=1:length(list)
    subplot(4,4, j);
    plot(plotrng, g1_sim.(list{j}), '.-b');
    grid on
    title(list{j}, 'interpreter', 'none');
    ylabel('Variacion porcentual', 'Fontsize', 9);
    xlabel('Per�odo de tiempo', 'Fontsize', 9);
end

 %Estimaci�n de la raz�n de sacrificio:   
 g1_sim.cs_v_y = cumsum(g1_sim.v_y - g1_sim.v_y_ss);
 g1_sim.cs_v_cpi = cumsum(g1_sim.v_cpi - g1_sim.v_cpi_ss);
 g1_sim.cs_v_cpi_sub = cumsum(g1_sim.v_cpi_sub - g1_sim.v_cpi_sub_ss);
 g1_sim.cs_v_cpi_nosub = cumsum(g1_sim.v_cpi_nosub - g1_sim.v_cpi_nosub_ss);
 g1_sim.cs_i = cumsum(g1_sim.i - g1_sim.i_ss);
 g1_sim.cs_r = cumsum(g1_sim.r - g1_sim.i_ss + g1_sim.v_cpi_ss);
 g1_sim.cs_v_s = cumsum(g1_sim.v_s - g1_sim.v_s_ss);
 g1_sim.cs_v_z = cumsum(g1_sim.v_z - g1_sim.v_z_ss);
 g1_sim.cs_E_v_cpi = cumsum(g1_sim.E_v_cpi - g1_sim.v_cpi_ss);
 g1_sim.cs_E_v_s = cumsum(g1_sim.E_v_s - g1_sim.v_s_ss);
 g1_sim.cs_prem = cumsum(g1_sim.prem - g1_sim.prem_ss);
 g1_sim.cs_v_y_star = cumsum(g1_sim.v_y_star - g1_sim.v_y_star_ss);
 g1_sim.cs_v_cpi_star = cumsum(g1_sim.v_cpi_star - g1_sim.v_cpi_star_ss);
 g1_sim.cs_i_star = cumsum(g1_sim.i_star - g1_sim.i_star_ss);
 g1_sim.cs_v_fpi = cumsum(g1_sim.v_fpi - g1_sim.v_fpi_ss);
 
 g2 = [g1_sim.cs_v_y, g1_sim.cs_v_cpi, g1_sim.cs_v_cpi_sub, g1_sim.cs_v_cpi_nosub, g1_sim.cs_i, g1_sim.cs_r, g1_sim.cs_v_s, g1_sim.cs_v_z, g1_sim.cs_E_v_cpi, g1_sim.cs_E_v_s, g1_sim.cs_prem, g1_sim.cs_v_y_star, g1_sim.cs_v_cpi_star, g1_sim.cs_i_star, g1_sim.cs_v_fpi ];
 
