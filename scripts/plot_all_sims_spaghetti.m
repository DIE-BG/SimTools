function plot_all_sims_spaghetti(MODEL, models_list, varargin)


% plot_all_sims_spaghetti realiza las gráficas despaghettis para todos los
% modelos disponibles en la carpeta dada.
%{
% ## Syntax ##
%
%    plot_all_sims_spaghetti(MODEL, models_list, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Objeto de modelo que contiene todo lo requerido por el paquete.
%
% __`models_list`__ [ struct ] -
% Struct en el que cada campo es el nombre de un modelo, el cual contiene
% el nombre de las variables a graficar con su propia nomeclatura.
%
%
% ## Options ##
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * SimsPath = fullfile('data', 'sims', 'forecast')) [ `String` ] -
% Directorio donde se encuentran las simulaciones.
%
% * Colors = distinguishable_colors(...) [ `array` ] - Matriz donde cada fila
% son los colores para cada modelo.
%
% * VariableNames = models_list.(models_names{1}) [ `cell` ] - Nombres
% comunes para las variables a graficar.
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

models_names = fieldnames(models_list);

 p = inputParser;
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'SimsPath', fullfile('data', 'sims', 'forecast'));
    addParameter(p, 'Colors', ...
        distinguishable_colors( ...
            length(fieldnames(models_list)), ...
            'w', ...
            @(x) colorspace('RGB->Lab',x)));
    addParameter(p, 'VariableNames', models_list.(models_names{1}));
    addParameter(p, 'EndHist', {});
parse(p, varargin{:});
params = p.Results; 

%% Directorio de guardado

% params.SavePath = fullfile(cd, 'plots', 'spaghetti', 'combinado');

if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

%% Presentación de impulsos-respuestas

MODEL = load_sims_forecast(MODEL, 'SimsPath', params.SimsPath);

if ~isempty(params.EndHist)
    MODEL.data_mr = dbclip(MODEL.data_mr, MODEL.DATES.hist_start:params.EndHist);
end

%% Variables compartidas

colors = params.Colors;

for var = 1:length(params.VariableNames) 

    figure('Position', [1 42.0181818181818 1675.63636363636 825.6]);

    hold on
    
    legend_label = [];

    for mod = 1:length(models_names)
        if ~isempty(params.EndHist)
            MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{1} = ...
                dbclip(...
                    MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{1}, ...
                    MODEL.DATES.hist_start:params.EndHist ...
                );
        end
        plot( ...
            MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{1}.(models_list.(models_names{mod}){var}), ...
            'LineStyle', '-.', ...
            'Color', colors(mod, :), ...
            'LineWidth', 1)
        
        for sim = 2:length(MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim)

            if ~isempty(params.EndHist)
                MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{sim} = ...
                    dbclip(...
                        MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{sim}, ...
                        MODEL.DATES.hist_start:params.EndHist ...
                    );
            end

            plot( ...
                MODEL.FORECAST_SIMS.(models_names{mod}).JF_pred_sim{sim}.(models_list.(models_names{mod}){var}), ...
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
        MODEL.data_mr.(models_list.(models_names{mod}){var}), ...
        'w', ...
        'LineWidth', 7, ...
        'HandleVisibility','off')

    plot( ...
        MODEL.data_mr.(models_list.(models_names{mod}){var}), ...
        'k', ...
        'LineWidth', 3)

    hold off


    legend_label = [legend_label, "Historia"];
    legend(legend_label, ...
        'FontSize', 12, ...
        'Interpreter', 'none')

    title(sprintf("%s \n Comparación Entre História y Pronóstico", params.VariableNames{var}), ...'v_cpi_sub'),...
        'Interpreter', 'none', ...
        'FontSize', 15)

    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_spaghetti_comb.png", params.VariableNames{var}))...
    )
end

close all

end
    

