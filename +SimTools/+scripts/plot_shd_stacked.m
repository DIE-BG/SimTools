function plot_shd_stacked(MODEL, varargin)

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
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'Variables', get(MODEL.MF, 'elist'));
    addParameter(p, 'CloseAll', true);
parse(p, varargin{:});
params = p.Results; 

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end


% Variables a descomponer
var_plot = params.Variables;

% Choques a las variables

% Paleta de colores
col = distinguishable_colors(length(var_plot) + 1, ...
    'b', ...
    @(x) colorspace('RGB->Lab',x));


% ----- Obtener la fecha máxima de anclajes -----

min_date = min(structfun(@(x) x.Range(1), MODEL.data_mr));
max_date = max(structfun(@(x) x.Range(end), MODEL.data_mr));

% ----- Recorte de choques estructurales al rango de fechas -----

shd_trm = dbclip(MODEL.shd_dsc, min_date:max_date);

shd_trm.shd_all = shd_trm.(var_plot{1});
for i = 2:length(var_plot)
    shd_trm.shd_all = shd_trm.shd_all + shd_trm.(var_plot{i});
end

% ----- Tamaño de la grilla -----

grid_size_cols = 2;
grid_size_rows = ceil(length(var_plot)/2);

% ----- Gráfica -----

figure('Position', [1 42.0182 1.6756e+03 825.6000]);

% El iterador i representa la variable a ser descompuesta
    barcon(shd_trm.shd_all, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false); 

    grfun.vline(MODEL.DATES.hist_end,'timePosition','middle');

    legend(var_plot,'location','northeastoutside','FontSize',11, 'Interpreter', 'none')

    title('Choques Estructurales', 'Interpreter', 'none', ...
        'FontSize', 15);

% ----- Save -----

saveas(gcf, ...
    fullfile(params.SavePath, ...
    'plot_shd_stacked.png')...
)

% ----- Cerrar la gráfica -----
if params.CloseAll
    close all
end

end

% ----- TEST -----
% params.Variables = get(MODEL.MF, 'elist');
% i = 1;