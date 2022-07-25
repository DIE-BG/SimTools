function plot_prediction_mms_corr(MODEL, varargin)

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
    addParameter(p, 'PlotList', get(MODEL.M, 'ylist'));
    addParameter(p, 'TabRange', qq(2021,4):4:qq(2024,4));
    addParameter(p, 'AnnotationRange', qq(2021,4):4:qq(2024,4));
    addParameter(p, 'AutoSave', false);
    addParameter(p, 'EndPlotAsTable', false);
    addParameter(p, 'FontSize', 11);
    addParameter(p, 'ColNameWidth', 0.4);
parse(p, varargin{:});
params = p.Results;

% ------ Para las pruebas -----
%{
params.StartDate =  MODEL.DATES.hist_start;
params.SavePath = fullfile( ...
                            cd, ...
                            'plots', ...                            
                            'corrimiento', ...
                            MODEL.CORR_DATE, ...
                            MODEL.CORR_VER, ...
                            'prediction' ...
                        );
params.CloseAll = true;
params.PlotList = get(MODEL.MF, 'ylist');
params.TabRange = qq(2021,4):4:qq(2024,4);
params.AutoSave = true;
params.EndPlotAsTable = false;
%}
% ----------

SS = get(MODEL.MF, 'sstate');

if params.EndPlotAsTable
    END_PLOT_DATE = params.TabRange(end);
else
    END_PLOT_DATE = MODEL.DATES.pred_end; 
end


% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

list = params.PlotList;


for var = 1 : length(list)
    
    var_data_m = list{var};
    var_data = regexp(var_data_m, 'm_(.*)$', 'tokens', 'once');
    var_data = var_data{1};
    % ----- Creación de figura -----
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
        params.StartDate:END_PLOT_DATE, ...MODEL.DATES.pred_end, ...
        MODEL.F_pred.(var_data_m),'.-b', ...
        'MarkerSize', 20, ...
        'LineWidth', 2 ...
    );

    grid on;  
    
    if isempty(MODEL.data_mr.(var_data).UserData.name)
        temp_title = var_data;
    else
        temp_title = MODEL.data_mr.(var_data).UserData.name;
    end

    title( ...
        sprintf(...
            '%s \n %s - %s', ...
            temp_title, ...
            dat2char(MODEL.DATES.pred_start), ...
            dat2char(END_PLOT_DATE) ...MODEL.DATES.pred_end)...
        ) ,...
        Interpreter='none'...
    )

    highlight(params.StartDate:MODEL.DATES.hist_end);

    vline( ...
        MODEL.END_HIST.(var_data), ...
        'LineWidth', 1, ...
        'LineStyle', '-.' ...
    );
    
    zeroline();
    
     if SS.(strcat(var_data, '_ss')) ~= 0      
    hline(...
        SS.(strcat(var_data, '_ss')), ...
        'LineWidth', 1.5, ...
        'LineStyle', ':' ...
        );
    end

    % Anotaciones
    SimTools.scripts.die_anotaciones( ...
        dat2dec(params.AnnotationRange)', ...
        MODEL.F_pred.(var_data_m)(params.AnnotationRange), ...
        string(num2str(MODEL.F_pred.(var_data_m)(params.AnnotationRange), '%0.2f')), ...
        'Container', plot_p ...
    )
    
    x_lims = get(gca, 'XLim');
    SimTools.scripts.anotaciones_simples(...
       x_lims(1), ...
       SS.(strcat(var_data, '_ss')), ...
       sprintf('Estado Estacionario: %0.2f', SS.(strcat(var_data, '_ss'))), ...
       'Container', plot_p, ...
       'LineStyle', ':', ...
       'HeadStyle', 'none', ...
       'FontSize', 7 ...
       )

    % ----- Panel de Tabla -----
    table_p = uipanel( ...
        main_p, ...
        'Position', [0, 1 - 0.8 - 0.10, 1, 0.10], ...
        'BackgroundColor', [1, 1, 1] ...
    );
    SimTools.scripts.plot_data_table( ...
        params.TabRange, ...
        MODEL.F_pred.(var_data_m)(params.TabRange), ...
        'Parent', table_p, ...
        'SeriesNames', list(var),...
        'FontSize', params.FontSize, ...
        'ColNameWidth', params.ColNameWidth...
    )
    
    % ----- Panel de notas -----
     notes_p = uipanel( ...
        main_p, ...
        'Position', [0, 0, 1, 0.10], ...
        'BackgroundColor', [1, 1, 1] ...
    );
    temp_string = {...
        'Notas:', ...
        sprintf('   - Último dato observado en %s, correspondiente a la línea vertical punteada.', MODEL.data_mr.(var_data).UserData.endhist), ...
        sprintf('   - Fuente historia: %s %s.', MODEL.data_mr.(var_data).UserData.refhist, MODEL.data_mr.(var_data).UserData.refhist_mmdate), ...
        sprintf('   - Fuente de anclaje: %s %s.', MODEL.data_mr.(var_data).UserData.refpred, MODEL.data_mr.(var_data).UserData.refpred_mmdate), ...
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
% ----- Save -----


if var < 10
    num = sprintf("0%i", var);
else
    num = sprintf('%i', var);
end


SimTools.scripts.pausaGuarda(...
    fullfile(params.SavePath, ...
    sprintf("%s_%s_shd_dsc_and_diff.png", num, var_data)), ...
    'AutoSave', params.AutoSave ...
)




end

if params.CloseAll
close all
end

end