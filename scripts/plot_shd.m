function plot_shd(MODEL, varargin)

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
    addParameter(p, 'OnlyHist', false);
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
   MODEL.shd_dsc = dbclip(MODEL.shd_dsc, MODEL.DATES.hist_start:MODEL.DATES.hist_end);
   MODEL.diff_shd_dsc = dbclip(MODEL.diff_shd_dsc, MODEL.DATES.hist_start:MODEL.DATES.hist_end);
   MODEL.F_pred = dbclip(MODEL.F_pred, MODEL.DATES.hist_start:MODEL.DATES.hist_end);
end

% Variables a descomponer
var_plot = params.Variables;

% Choques a las variables

% Paleta de colores
col = distinguishable_colors(length(var_plot) + 1, ...
    'b', ...
    @(x) colorspace('RGB->Lab',x));

% El iterador i representa la variable a ser descompuesta
for i = 1:length(var_plot)

    figure('Position', [1 42.0182 1.6756e+03 825.6000]);
    hold on
    
    % Barras
    barcon(MODEL.shd_dsc.(var_plot{i}){:, 1:end}, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false); 
    % Línea vertical en el fin de historia
    grfun.vline(MODEL.DATES.hist_end,'timePosition','middle');
    % Título
    set(gca,'FontSize',12);       
    title( ...
        { ...
            var_plot{i}; ...
            "Choques Estructurales" ...
        }, ...
        'Interpreter', 'none');
    grid on;
    hold off
   
% Almacenamiento    

    if i < 10
        num = sprintf("0%i", i);
    else
        num = sprintf('%i', i);
    end
    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_%s.png", num, var_plot{i}))...
    )

end

if params.CloseAll
    close all
end

end

% ----- TEST -----
% params.Variables = get(MODEL.MF, 'elist');
% i = 1;