function plot_pred_corr_compared(MODEL, varargin)

% plot_prediction_mms_corr realiza las gráficas del proceso de predicción del
% modelo.
%{
% ## Syntax ##
%
%     plot_prediction_mms_corr(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, la estructura
% de fechas `MODEL.DATES`, así como la estructura de resultados del proceso
% de predicción `MODEL.F_pred`.
%
% ## Options ##
%
% * StartDate = MODEL.DATES.hist_start [ `DateWrapper` ] - Fecha a la que
% empieza a graficar la historia.
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * CloseAll = [`true`|false] - Cerrar todas las gráficas luego de
% completar el proceso.
%
% * PlotList = get(MODEL.M, 'xlist')) [cell] - Nombre de las variables a
% graficar.
%
% * TabRange =  qq(2021,4):4:qq(2024,4) [ `DateWrapper` ] - Rango de fechas
% para graficar en la tabla.
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
p = inputParser;
    addParameter(p, 'StartDate', MODEL.DATES.hist_start);
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'CloseAll', true);
    addParameter(p, 'PlotList', get(MODEL.M, 'xlist'));
    addParameter(p, 'TabRange', qq(2021,4):4:qq(2024,4));
    addParameter(p, 'AutoSave', false);
    addParameter(p, 'FullDataAnt_Name', {});
    addParameter(p, 'LegendsNames', {});
    addParameter(p, 'PlotSSLine', true);
    addParameter(p, 'PlotAnnotations', true);
parse(p, varargin{:});
params = p.Results;

SS = get(MODEL.M, 'sstate');

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

% ----- Carga del Full Data anterior  -----

if ~isempty(params.FullDataAnt_Name)
full_data_ant = databank.fromCSV(params.FullDataAnt_Name);
end


% Ajuste de datos a las observaciones para la tasa de interés real---------

MODEL.F_pred.r.Data(1:length(MODEL.data_mr.r.Data)) = MODEL.data_mr.r.Data;

% ----- Inicialización de las iteraciones -----

list = params.PlotList;

for var = 1 : length(list)

    %% ----- Creación de figura -----
    figure;

    set( ...
        gcf, ...
        'defaultaxesfontsize',12, ...
        'Position', [1 42.0182 1117.1 776.73] ...
    );
    main_p = uipanel('Units','normalized');
    
    % ----- Panel de gráfica -----
    plot_p = uipanel( ...
        main_p, ...
        'Position', [0, 1 - 0.8, 1, 0.8], ...
        'BackgroundColor', [1, 1, 1] ...
    );

    ax = axes(plot_p, 'Units','normalized' ,'Position', [0.1 0.1 0.85 0.8]);

    plot(...
        params.StartDate:MODEL.DATES.pred_end, ...
        MODEL.F_pred.(list{var}),'.-b', ...
        'MarkerSize', 20, ...
        'LineWidth', 2 ...
    );

    if ~isempty(params.FullDataAnt_Name)
        hold on 

        plot(...
            params.StartDate:MODEL.DATES.pred_end, ...
            full_data_ant.(list{var}),'.-r', ...
            'MarkerSize', 20, ...
            'LineWidth', 2 ...
        );
        hold off
        %Returns handles to the patch and line objects
        chi = get(gca, 'Children');
        %Reverse the stacking order so that the patch overlays the line
        set(gca, 'Children',flipud(chi));

        if ~isempty(params.LegendsNames)
            legend(params.LegendsNames);
        end
    end

    grid on;  
    
    if isempty(MODEL.data_mr.(list{var}).UserData.name)
        temp_title = list{var};
    else
        temp_title = MODEL.data_mr.(list{var}).UserData.name;
    end

    title( ...
        sprintf(...
            '%s \n %s - %s', ...
            temp_title, ...
            dat2char(MODEL.DATES.pred_start), ...
            dat2char(MODEL.DATES.pred_end)...
        ) ,...
        Interpreter='none'...
    )

    highlight(params.StartDate:MODEL.DATES.hist_end);

    vline( ...
        MODEL.END_HIST.(list{var}), ...
        'LineWidth', 1, ...
        'LineStyle', '-.' ...
    );
    
    zeroline();
    
    if params.PlotSSLine
        if SS.(strcat(list{var}, '_ss')) ~= 0
        hline(...
            SS.(strcat(list{var}, '_ss')), ...
            'LineWidth', 1.5, ...
            'LineStyle', ':' ...
            );
        end
    end

    % Anotaciones
    if params.PlotAnnotations 
    % Anotaciones para corrimiento actual
    SimTools.scripts.die_anotaciones( ...
        dat2dec(params.TabRange)', ...
        MODEL.F_pred.(list{var})(params.TabRange), ...
        string(num2str(MODEL.F_pred.(list{var})(params.TabRange), '%0.2f')), ...
        'Container', plot_p, ...
        'Color', 'b' ...
    )

    % Anotaciones para corrimiento anterior si es que se grafica
    if ~isempty(params.FullDataAnt_Name)
        SimTools.scripts.die_anotaciones( ...
            dat2dec(params.TabRange)', ...
            full_data_ant.(list{var})(params.TabRange), ...
            string(num2str(full_data_ant.(list{var})(params.TabRange), '%0.2f')), ...
            'Container', plot_p, ...
            'Color', 'r', ...
            'IsAnt', true ...
        )
    end
    end
  
    if params.PlotSSLine
        x_lims = get(gca, 'XLim');
        SimTools.scripts.anotaciones_simples(...
           x_lims(1), ...
           SS.(strcat(list{var}, '_ss')), ...
           sprintf('Estado Estacionario: %0.2f', SS.(strcat(list{var}, '_ss'))), ...
           'Container', plot_p, ...
           'LineStyle', ':', ...
           'HeadStyle', 'none', ...
           'FontSize', 7 ...
           )
    end

    % ----- Panel de Tabla -----
    table_p = uipanel( ...
        main_p, ...
        'Position', [0, 1 - 0.8 - 0.10, 1, 0.10], ...
        'BackgroundColor', [1, 1, 1] ...
    );
    
    data_table = [];
    if ~isempty(params.FullDataAnt_Name)
        data_table(:, 1) = full_data_ant.(list{var})(params.TabRange);
        data_table(:, 2) = MODEL.F_pred.(list{var})(params.TabRange);
        text_Color = [1,0,0 ; 0,0,1];
    else
        data_table(:, 1) = full_data_ant.(list{var})(params.TabRange);
        text_Color = [1, 1, 1];
    end

    SimTools.scripts.plot_data_table( ...
        params.TabRange, ...
        data_table, ...
        'Parent', table_p, ...
        'SeriesNames', params.LegendsNames, ...
        'TextColor', text_Color ...
    )
    
    % ----- Panel de notas -----
     notes_p = uipanel( ...
        main_p, ...
        'Position', [0, 0, 1, 0.10], ...
        'BackgroundColor', [1, 1, 1] ...
    );
    temp_string = {...
        'Notas:', ...
        sprintf('   - Último dato observado en %s, correspondiente a la línea vertical punteada.', MODEL.data_mr.(list{var}).UserData.endhist), ...
        sprintf('   - Fuente historia: %s %s.', MODEL.data_mr.(list{var}).UserData.refhist, MODEL.data_mr.(list{var}).UserData.refhist_mmdate), ...
        sprintf('   - Fuente de anclaje: %s %s.', MODEL.data_mr.(list{var}).UserData.refpred, MODEL.data_mr.(list{var}).UserData.refpred_mmdate), ...
    };
    uicontrol( ...
        notes_p, ...
        'Style', 'text', ...
        'Units', 'normalized', ...
        'Position', [0, 0, 1, 1],...
        'String', temp_string,...
        'FontWeight', 'normal', ...
        'FontSize', 9, ...
        'HorizontalAlignment', 'left', ...
        'BackgroundColor', [1, 1, 1]);
    % ----- Parámetros adicionales ----
    axis on
%% ----- Save -----


if var < 10
    num = sprintf("0%i", var);
else
    num = sprintf('%i', var);
end


SimTools.scripts.pausaGuarda(...
    fullfile(params.SavePath, ...
    sprintf("%s_%s_shd_dsc_and_diff.png", num, list{var})), ...
    'AutoSave', params.AutoSave ...
)




end

if params.CloseAll
close all
end

end