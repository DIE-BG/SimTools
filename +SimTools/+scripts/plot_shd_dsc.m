function plot_shd_dsc(MODEL, varargin)

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
    addParameter(p, 'Rng', MODEL.DATES.hist_start:MODEL.DATES.pred_end);
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
   MODEL.F_pred = dbclip(MODEL.F_pred, MODEL.DATES.hist_start:MODEL.DATES.hist_end);
elseif ~params.OnlyHist && ~isempty(params.Rng)
   MODEL.shd_dsc = dbclip(MODEL.shd_dsc, MODEL.DATES.hist_end - 20:MODEL.DATES.hist_end + 20);
   MODEL.F_pred = dbclip(MODEL.F_pred, MODEL.DATES.hist_end - 20:MODEL.DATES.hist_end + 20);
end


% Variables a descomponer
var_plot = params.Variables;

% Choques a las variables
var_shd = get(MODEL.MF, 'elist');

% Paleta de colores
col = distinguishable_colors(length(var_shd) + 1, ...
    'b', ...
    @(x) colorspace('RGB->Lab',x));

% Estados estacionarios
MFSS = get(MODEL.M, 'sstate');

% El iterador i representa la variable a ser descompuesta
for i = 1:length(var_plot)

    % Cálculo de contribuciones
    MODEL.shd_dsc.(var_plot{i})(:,end-1) = abs( ...
        MODEL.shd_dsc.(var_plot{i}){:,end-1} - MFSS.(var_plot{i}) ...
        );

    figure('Position', [1 42.0182 1.6756e+03 825.6000]);
    hold on
    
    % Barras
    barcon(MODEL.shd_dsc.(var_plot{i}){:, 1:end}, ...
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
    title(var_plot{i}, 'Interpreter', 'none');
    % Leyendas
    legend(var_shd,'location','northeastoutside','FontSize',11, 'Interpreter', 'none')
    grid on;
    hold off
   
%     Modificar el eje y para que parta desde el estado estacionario en
%     lugar de cero.

%     ytickformat('%0.2f')
    if params.Level 
        temp_ythicklabel = string(round(get(gca, 'YTick') + real(MFSS.(var_plot{i})), 2));
        set(gca, 'YTickLabel', temp_ythicklabel);
    end
%     Almacenamiento de gráficas
    
     

    if i < 10
        num = sprintf("0%i", i);
    else
        num = sprintf('%i', i);
    end
    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_shd_dsc.png", var_plot{i}))...
    )

end

if params.CloseAll
    close all
end

end