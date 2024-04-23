function plot_var_dsc(MODEL, varargin)

% plot_var_dsc realiza las gráficas de descomposición de varianzas de los
% pronósticos del modelo.
%{
% ## Syntax ##
%
%     plot_var_dsc(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`,
% `MODEL.var_dsc` y `MODEL.DATES`
%
%
% ## Options ##
%
% * Rel = [ `true`|`false` ] - Descomposición relativa o absotula.
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * Variables = get(MODEL.M, 'xlist') [ `cell` ] - Variables a graficar.
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

% Parametros opcionales de la función


% Parametros opcionales
 p = inputParser;
    addParameter(p, 'Rel', true);
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'Variables', get(MODEL.M, 'xlist'))
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
var_dsc_plot = params.Variables;
% Número de shocks que componen las barras
nSVar = length(MODEL.var_dsc.s_name);

% Paleta de colores
col = distinguishable_colors(nSVar,'b',@(x) colorspace('RGB->Lab',x));

for i = 1:length(var_dsc_plot)
    
    figure('Position', [1 42.0182 1.6756e+03 825.6000]);
    % Selección de la data a graficar dado el parámetro `Rel`.
    if params.Rel
        vals = MODEL.var_dsc.rel.(var_dsc_plot{i});
    else
        vals = MODEL.var_dsc.abs.(var_dsc_plot{i});
    end
    
    barcon(vals, ...
        'barWidth=', 1, ...
        'dateFormat=','YYFP', ...
        'colorMap=',col, ...
        'evenlySpread=', false);
    
    % Construcción de los nombres de las variables para las leyendas
    leg = cellfun(@(x) regexp(x, '(?<=<--s_)(\D*)$', 'match', 'once'), ...
        MODEL.var_dsc.rel.(var_dsc_plot{i}).comment, ...
        'UniformOutput',false);
    legend(get(MODEL.M, 'elist'), ...
        'Interpreter','none', ...
        'Location','bestoutside')
    
    xlim(dat2dec([MODEL.DATES.pred_start, MODEL.DATES.pred_end]));

    % Condiciones para los límites en y, título
    if params.Rel
        ylim([0, 1])
        title(sprintf("Descomposición de Varianza Relativa \n Pronósticos de la variable %s", var_dsc_plot{i}), ...
            'Interpreter', 'none')
    else
        title(sprintf("Descomposición de Varianza Absoluta \n Pronósticos de la variable %s", var_dsc_plot{i}), ...
            'Interpreter', 'none')
    end
    
    % Dado el parametro Rel, construye un nombre para la gráfica a guardar

    if i < 10
        num = sprintf("0%i", i);
    else
        num = sprintf('%i', i);
    end
    if params.Rel
        saveas(gcf, ...
            fullfile(params.SavePath, ...
            sprintf("%s_%s_vdsc_rel.png", num, var_dsc_plot{i}))...
        )
    else
        saveas(gcf, ...
            fullfile(params.SavePath, ...
            sprintf("%s_%s_vdsc_abs.png", num, var_dsc_plot{i}))...
        )
    end

end

close all

end