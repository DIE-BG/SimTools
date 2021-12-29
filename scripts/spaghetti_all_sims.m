function plot_sims_spaghetti(MODEL, model_list, varargin)


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
    addParameter(p, 'SimsPath', fullfile('data', 'sims', 'forecast'));
parse(p, varargin{:});
params = p.Results; 

%% Directorio de guardado

% params.SavePath = fullfile(cd, 'plots', 'spaghetti', 'combinado');

if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
    elsev
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

%% Presentación de impulsos-respuestas

MODEL = load_sims_forecast(MODEL, params.SimPath);


PredRange = MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end;

%% Variables compartidas



models_names = fieldnames(models_list);

% colors = distinguishable_colors(length(models_names), ...
%     'w', ...
%     @(x) colorspace('RGB->Lab',x));

colors = [0 0 1; 1 0 0];



for var = 1:length(models_list.svar01_10) 

    figure('Position', [1 42.0181818181818 1675.63636363636 825.6]);

    hold on
    
    legend_label = [];

    for mod = 1:length(models_names)
        plot( ...
            MODEL.FORECAST_SIMS.(models_names{mod}).Forecast{1}.(models_list.(models_names{mod}){var}), ...
            'LineStyle', '-.', ...
            'Color', colors(mod, :), ...
            'LineWidth', 1)
        
        for sim = 2:length(PredRange)
            plot( ...
                MODEL.FORECAST_SIMS.(models_names{mod}).Forecast{sim}.(models_list.(models_names{mod}){var}), ...
                'LineStyle', '-.', ...
                'Color', colors(mod, :), ...
                'LineWidth', 1, ...
                'HandleVisibility','off')
        end
        
        legend_label = [...
            legend_label, ...
            sprintf("Pronóstico - %s", string(models_names{mod})) ...
        ];
    end

    plot( ...
        MODEL.data_mr.(models_list.svar01_10{var}), ...
        'w', ...
        'LineWidth', 7, ...
        'HandleVisibility','off')

    plot( ...
        MODEL.data_mr.(models_list.svar01_10{var}), ...
        'k', ...
        'LineWidth', 3)

    hold off


    legend_label = [legend_label, "Historia"];
    legend(legend_label, ...
        'FontSize', 12, ...
        'Interpreter', 'none')

    title(sprintf("%s \n Comparación Entre História y Pronóstico", models_list.svar01_10{var}), ...
        'Interpreter', 'none', ...
        'FontSize', 15)

    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_spaghetti_comb.png",models_list.svar01_10{var}))...
    )
end

close all

end
    

