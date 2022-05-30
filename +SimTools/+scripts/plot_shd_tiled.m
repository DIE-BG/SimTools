function plot_shd_tiled(MODEL, varargin)

% plot_diff_shd_dsc realiza las gráficas de descomposición de choques del modelo
% suavizado en primeras diferencias.
%{
% ## Syntax ##
%
%     plot_diff_shd_dsc(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.MF`,
% `MODEL.diff_shd_dsc` y `MODEL.DATES`
%
%
% ## Options ##
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * Variables = get(MODEL.MF, 'xlist') [ `cell` ] - Nombre de variable a
% graficar.
%
% * CloseAll = [ `true`|false ] - Nombre de variable a
% graficar.
%
% * OnlyHist = [ true|`false` ] - Se grafica solamente la historia.
%
% * MeasurementShocks = [ true|`false` ] - Graficar los choques a las
% variables de medida.
%
% * exoShocks = [ true|`false` ] - Graficar los choques a las variables
% exógenas.
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

%{ 
% ----- TEST SECTION -----
params = struct;
params.Variables = get(MODEL.MF, 'elist');
params.CloseAll = true;
params.SavePath = fullfile( ...
                    cd, ...
                    'plots', ...
                    'corrimiento', ...
                    MODEL.CORR_DATE, ...
                    MODEL.CORR_VER, ...
                    'structural_shocks' ...
                );
params.OnlyHist = false;
params.MeasurementShocks = false;
params.ExoShocks = false;
%}

% Parametros opcionales
 p = inputParser;
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'Variables', get(MODEL.MF, 'elist'));
    addParameter(p, 'CloseAll', true);
    addParameter(p, 'OnlyHist', false);
    addParameter(p, 'MeasurementShocks', false);
    addParameter(p, 'ExoShocks', false);
    parse(p, varargin{:});
params = p.Results; 

% ----- Verificación y creación del directorio para las gráficas ---
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

% --- Se recortan los datos a solamente la historia, si es que se requiere.
if params.OnlyHist
   MODEL.shd_dsc = dbclip( ...
       MODEL.shd_dsc, ...
       MODEL.DATES.hist_start:MODEL.DATES.hist_end ...
   );

   MODEL.diff_shd_dsc = dbclip( ...
       MODEL.diff_shd_dsc, ...
       MODEL.DATES.hist_start:MODEL.DATES.hist_end ...
   );
   
   MODEL.F_pred = dbclip( ...
       MODEL.F_pred, ...
       MODEL.DATES.hist_start:MODEL.DATES.hist_end ...
   );
end

% --- Filtrar las choches a las variables de medida. -----

measurementShocks = regexp(get(MODEL.MF, 'elist')', 's_m_.*', 'match');
measurementShocks = measurementShocks(cellfun(@(x) ~isempty(x), measurementShocks));
measurementShocks = cellfun(@(x) x{1}, measurementShocks, 'UniformOutput', false);

% --- Filtrar las choches a las variables de exógenas. -----

exoShocks = regexp(get(MODEL.MF, 'elist')', '.*exo.*', 'match');
exoShocks = exoShocks(cellfun(@(x) ~isempty(x), exoShocks));
exoShocks = cellfun(@(x) x{1}, exoShocks, 'UniformOutput', false);


% Se filtran la variables de medida del plot.
if params.MeasurementShocks
    var_plot = params.Variables;
else
    var_plot = params.Variables - measurementShocks;
end

% Se filtran las variables exogenas del plot.
if ~params.ExoShocks
    var_plot = var_plot - exoShocks;
end

% --- Paleta de colores ---
col = SimTools.from_stack_exchange.distinguishable_colors( ...
    length(var_plot) + 1, ...
    'b', ...
    @(x) SimTools.from_stack_exchange.colorspace('RGB->Lab',x) ...
);


% ----- Obtener la fecha máxima de anclajes -----
min_date = min(structfun(@(x) x.Range(1), MODEL.data_mr));
max_date = max(structfun(@(x) x.Range(end), MODEL.data_mr));

% ----- Recorte de choques estructurales al rango de fechas -----
shd_trm = dbclip(MODEL.shd_dsc, min_date:max_date);

% ----- Tamaño de la grilla -----
grid_size_cols = 2;
grid_size_rows = ceil(length(var_plot)/2);

index = reshape(1:(grid_size_cols*grid_size_rows), grid_size_rows , grid_size_cols)';

% ----- Gráfica -----
figure('Position', [1 42.0182 1.6756e+03 825.6000]);

tiled_plot = tiledlayout(grid_size_rows, grid_size_cols);

% El iterador i representa la variable a ser descompuesta
for i = 1:length(var_plot)
    
    nexttile;
    
   % Barras
    barcon(shd_trm.(var_plot{index(i)}){:, 1:end}, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false); 

    % Línea vertical en el fin de historia
    grfun.vline(MODEL.DATES.hist_end,'timePosition','middle');

    % Título
    set(gca,'FontSize', 8);       
    title( ...
        var_plot{index(i)}, ...
        'Interpreter', 'none');
    grid on;

end

title(tiled_plot, 'Choques Estructurales', ...
    'FontWeight', 'bold', ...
    'FontSize', 14)

% ----- Save -----

saveas(gcf, ...
    fullfile(params.SavePath, ...
    'plot_shd_tiled.png')...
)

% ----- Cerrar la gráfica -----
if params.CloseAll
    close all
end

end