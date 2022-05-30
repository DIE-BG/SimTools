function plot_shd_dsc_and_diff(MODEL, varargin)

% plot_shd_dsc realiza las gráficas de descomposición de choques del modelo
% suavizado.
%{
% ## Syntax ##
%
%     plot_shd_dsc(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.MF`,
% `MODEL.shd_dsc` y `MODEL.DATES`
%
%
% ## Options ##
%
% * Level = [ `true`|`false` ] - Gráfica a partir del estado estacionario.
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * Variables = get(MODEL.MF, 'xlist') [ `cell` ] - Nombre de variable a
% graficar.
%
% * CloseAll = [`true`|false] - Cerrar todas las gráficas.
%
% * OnlyHist = [`false`|true] - Graficar únicamente la historia.
%
% ## Output Arguments ##
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

% Parametros opcionales
 p = inputParser;
    addParameter(p, 'Level', true);
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'Variables', get(MODEL.MF, 'xlist'));
    addParameter(p, 'CloseAll', true);
    addParameter(p, 'OnlyHist', false);
    addParameter(p, 'ExoVar', false);
    addParameter(p, 'MeasurementShocks', false);
    addParameter(p, 'ExoShocks', false);
parse(p, varargin{:});
params = p.Results; 

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

if params.OnlyHist
   MODEL.shd_dsc = dbclip( ...
       MODEL.shd_dsc, ...
       MODEL.DATES.hist_start:MODEL.DATES.hist_end ...
   );
   MODEL.diff_shd_dsc = dbclip( ...
       MODEL.diff_shd_dsc, ...
       MODEL.DATES.hist_start+1:MODEL.DATES.hist_end ...
   );
   MODEL.F_pred = dbclip( ...
       MODEL.F_pred, ...
       MODEL.DATES.hist_start:MODEL.DATES.hist_end ...
   );
else
   MODEL.shd_dsc = dbclip( ...
       MODEL.shd_dsc, ...
       MODEL.DATES.hist_start:MODEL.DATES.pred_end ...
   );
   MODEL.diff_shd_dsc = dbclip( ...
       MODEL.diff_shd_dsc, ...
       MODEL.DATES.hist_start+1:MODEL.DATES.pred_end ...
   );
   MODEL.F_pred = dbclip( ...
       MODEL.F_pred, ...
       MODEL.DATES.hist_start:MODEL.DATES.pred_end ...
   );
end


% --- Variables a descomponer ----
var_plot = params.Variables;

% Filtrar las choches a las variables de exógenas.

exoVar = regexp(get(MODEL.MF, 'xlist')', '.*exo.*', 'match');
exoVar = exoVar(cellfun(@(x) ~isempty(x), exoVar));
exoVar = cellfun(@(x) x{1}, exoVar, 'UniformOutput', false);

% Se filtran las variables exogenas del plot.
if ~params.ExoVar
    var_plot = var_plot - exoVar;
end


% --- Choques para descomponer a las variables ---
% Choques a las variables
var_shd = get(MODEL.MF, 'elist');
var_shd_fiter = ones(length(var_shd), 1);

% Filtrar las choches a las variables de medida.

measurementShocks = regexp(get(MODEL.MF, 'elist')', 's_m_.*', 'match');
measurementShocks_filter = cellfun(@(x) ~isempty(x), measurementShocks);
measurementShocks = cellfun(@(x) x{1}, measurementShocks(measurementShocks_filter), 'UniformOutput', false);

% Filtrar las choches a las variables de exógenas. 

exoShocks = regexp(get(MODEL.MF, 'elist')', '.*exo.*', 'match');
exoShocks_filter = cellfun(@(x) ~isempty(x), exoShocks);
exoShocks = cellfun(@(x) x{1}, exoShocks(exoShocks_filter), 'UniformOutput', false);


% Se filtran la variables de medida del plot.
if ~params.MeasurementShocks
    var_shd = var_shd - measurementShocks;
    var_shd_fiter = var_shd_fiter - measurementShocks_filter;
end

% Se filtran las variables exogenas del plot.
if ~params.ExoShocks
    var_shd = var_shd - exoShocks;
    var_shd_fiter = var_shd_fiter - exoShocks_filter;
end

% --- Se agregan las condiciones iniciales al problema de filtrar choques.

var_shd_fiter(end + 1: end + 2) = 1;

% --- Paleta de colores ---
col = distinguishable_colors( ...
    length(var_shd_fiter) + 1, ...
    'b', ...
    @(x) colorspace('RGB->Lab',x) ...
);

% --- Estados estacionarios ---
MFSS = get(MODEL.M, 'sstate');

% El iterador i representa la variable a ser descompuesta
for i = 1:length(var_plot)    
    %Límites de y

    % ----- Figura ----
    figure('Position', [1 42.0182 1.6756e+03 10000]);

    tiled_plot = tiledlayout(2, 1, ...
    'Padding', 'none');


    nexttile;

    % Cálculo de contribuciones
    MODEL.shd_dsc.(var_plot{i})(:,end-1) = abs( ...
        MODEL.shd_dsc.(var_plot{i}){:,end-1} - MFSS.(var_plot{i}) ...
        );

    
    hold on
    
    % Barras

    barcon(MODEL.shd_dsc.(var_plot{i}){:, logical(var_shd_fiter)}, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false); 
    % Líneas
    plot(real(MODEL.F_pred.(var_plot{i}) - MFSS.(var_plot{i})),'w','LineWidth',5);
    plot(real(MODEL.F_pred.(var_plot{i}) - MFSS.(var_plot{i})),'k.-','LineWidth',2, 'MarkerSize', 20);
    % Línea vertical en el fin de historia
    grfun.vline(MODEL.DATES.hist_end,'timePosition','middle');
    % Título
    set(gca,'FontSize',12);       
    title(var_plot{i}, 'Interpreter', 'none', ...
        'FontSize', 17);
    % Leyendas
    legend(var_shd,'location','northeastoutside','FontSize',11, 'Interpreter', 'none')
    grid on;
    hold off
   
    x_lim = get(gca, 'XLim');
    x_tick = get(gca, 'XTick');
    x_ticklabel = get(gca, 'XTickLabel');


    % -----

    nexttile;

    hold on
    
    % Barras
    barcon(MODEL.diff_shd_dsc.(var_plot{i}){:, logical(var_shd_fiter)}, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false); 
    % Líneas
    plot( ...
        diff(MODEL.F_pred.(var_plot{i})), ...
        'w', ...
        'LineWidth',3);
    plot( ...
        diff(MODEL.F_pred.(var_plot{i})), ...
        'k.-', ...
        'LineWidth',2, ...
        'MarkerSize', 10);
    % Línea vertical en el fin de historia
    grfun.vline(MODEL.DATES.hist_end,'timePosition','middle');
    % Título
    set(gca,'FontSize',12);
    title('Primera Diferencia', 'Interpreter', 'none');
    set(gca, 'XLim', x_lim);
    set(gca, 'XTick', x_tick);
    set(gca, 'XTickLabel', x_ticklabel);

    % Leyendas
%     legend(var_shd,'location','northeastoutside','FontSize',11, 'Interpreter', 'none')
    grid on;
    hold off

% ----- Límites de y -----
    y_lim_mat = [tiled_plot.Children(1).YLim; tiled_plot.Children(end).YLim];
    y_lim_inf = min(min(y_lim_mat));
    y_lim_sup = max(max(y_lim_mat));

    set(tiled_plot.Children(1), 'YLim', [y_lim_inf, y_lim_sup])
    set(tiled_plot.Children(end), 'YLim', [y_lim_inf, y_lim_sup])

    if params.Level 
        temp_ythicklabel = string(round(get(tiled_plot.Children(end), 'YTick') + real(MFSS.(var_plot{i})), 2));
        set(tiled_plot.Children(end), 'YTickLabel', temp_ythicklabel);
    end

% ----- Almacenamiento de gráficas
    
     

    if i < 10
        num = sprintf("0%i", i);
    else
        num = sprintf('%i', i);
    end
    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_%s_shd-dsc.png", num, var_plot{i}))...
    )

end

if params.CloseAll
    close all
end

end

% ---- Test -----

% params.Level=true;
% params.SavePath=fullfile(userpath, 'temp');
% params.Variables=get(MODEL.MF, 'xlist');
% params.CloseAll= true;