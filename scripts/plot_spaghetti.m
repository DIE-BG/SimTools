function plot_spaghetti(MODEL, varargin)

% plot_spaghetti realiza las de gráficas spaghettis de los pronósticos con 
% variables exógenas ancladas.
%{
% ## Syntax ##
%
%     plot_spaghetti(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, con el modelo 
% resuelto, `MODEL.data_mr` con los datos recortados y  `MODEL.ExoVar` con
% el nombre de las variables definidas como exógenas y que serán ancladas, 
% `MODEL.EvalVar` con las variables que serán evaluadas.
%
%
% ## Options ##
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * PredRange = MODEL.DATES.pred_start:MODEL.DATES.pred_end [ `DateWrapper` ] - 
% Rango a pronosticar.
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


p = inputParser;
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'Color', [0, 0, 1]);
parse(p, varargin{:});
params = p.Results; 

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

for i = 1:length(MODEL.EvalVar)
    figure('Position', [1 42.0181818181818 1675.63636363636 825.6]);
    
    % Gráficas de spaghetti
    plot(MODEL.JF_pred_sim{1}.(MODEL.EvalVar{i}), ...
        'Color', params.Color, ...
        'LineStyle', '-.', ...
        'LineWidth', 1)

    hold on

    for j = 2:length(MODEL.JF_pred_sim)%length(params.PredRange)
        plot(MODEL.JF_pred_sim{j}.(MODEL.EvalVar{i}), ...
        'Color', params.Color, ...
        'LineStyle', '-.', ...
        'LineWidth', 1, ...
        'HandleVisibility','off')
    end
    
    % Líneas de referencia
    plot(MODEL.data_mr.(MODEL.EvalVar{i}), 'w', ...
        'LineWidth', 7, ...
        'HandleVisibility','off')

    plot(MODEL.data_mr.(MODEL.EvalVar{i}), 'k', ...
        'LineWidth', 3)

    hold off

    legend(["Pronóstico", "Historia"], ...
        'FontSize', 12)

    title(sprintf("%s \n Comparación Entre História y Pronóstico", MODEL.EvalVar{i}), ...
        'Interpreter', 'none', ...
        'FontSize', 15)
    
    % Numeración para los nombres de las gráficas
    if i < 10
        num = sprintf("0%i", i);
    else
        num = sprintf('%i', i);
    end
    saveas(gcf, ...
        fullfile(params.SavePath, ...
        sprintf("%s_%s_spaghetti.png", num, MODEL.EvalVar{i}))...
    )
end

close all

end