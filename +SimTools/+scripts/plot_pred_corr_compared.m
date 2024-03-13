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
    addParameter(p, 'PlotList', get(MODEL.M, 'ylist'));
    addParameter(p, 'TabRange', qq(2021,4):4:qq(2024,4));
    addParameter(p, 'AnnoRange', qq(2021,4):4:qq(2024,4));
    addParameter(p, 'AutoSave', false);
    addParameter(p, 'FullDataAnt_Name', {});
    addParameter(p, 'LegendsNames', {});
    addParameter(p, 'PlotSSLine', true);
    addParameter(p, 'PlotAnnotations', true);
    addParameter(p, 'EndDatePlot', {});
    addParameter(p, 'LegendLocation', 'northeast');
    addParameter(p, 'AnnotationXAdjustment', 0);
    addParameter(p, 'AnnotationYAdjustment', 0);
parse(p, varargin{:});
params = p.Results;

%{

params.StartDate=MODEL.DATES.hist_start
params.PlotList= {'m_v_c_r'} %get(MODEL.M, 'ylist')
params.TabRange=qq(2021,4):4:qq(2024,4)
params.AnnoRange=qq(2021,4):4:qq(2024,4)
params.AutoSave=false
params.PlotSSLine=true
params.PlotAnnotations=true
params.EndDatePlot={}
params.LegendLocation='northeast'
params.AnnotationXAdjustment=0
params.AnnotationYAdjustment=0
params.SavePath = fullfile( ...
                    cd, ...
                    'plots', ...
                    'corrimiento', ...
                    MODEL.CORR_DATE, ...
                    MODEL.CORR_VER ...
                )
params.CloseAll = true
params.AutoSave = true
params.FullDataAnt_Name = MODEL.FULLDATANAME_ANT
params.LegendsNames = {'Junio 2022', 'Agosto 2022'}
%}

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


if ~isempty(params.EndDatePlot)
    full_data_ant = dbclip(full_data_ant, params.StartDate:params.EndDatePlot);
    MODEL.F_pred = dbclip(MODEL.F_pred, params.StartDate:params.EndDatePlot);
    MODEL.DATES.pred_end = params.EndDatePlot;
end

list = params.PlotList;
% list = cellfun(@(x) regexp(x, 'm_(.*)$', 'tokens', 'once'), list);
% list = list(cellfun(@(x) any(strcmp(x, fieldnames(full_data_ant))), list));


for var = 1 : length(list)
    
    var_data_m = list{var};
    var_data = regexp(var_data_m, 'm_(.*)$', 'tokens', 'once');
    var_data = var_data{1};

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
        MODEL.F_pred.(var_data_m),'.-b', ...
        'MarkerSize', 17, ...
        'LineWidth', 2 ...
    );

    if ~isempty(params.FullDataAnt_Name)
        hold on 

        plot(...
            params.StartDate:MODEL.DATES.pred_end, ...
            full_data_ant.(var_data),'.-r', ...
            'MarkerSize', 15, ...
            'LineWidth', 1.65, ...
            'LineStyle', '--' ...
        );
        hold off
        %Returns handles to the patch and line objects
        chi = get(gca, 'Children');
        %Reverse the stacking order so that the patch overlays the line
        set(gca, 'Children',flipud(chi));

        if ~isempty(params.LegendsNames)
            legend(params.LegendsNames, 'Location', params.LegendLocation);
        end
    end

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
            dat2char(MODEL.DATES.pred_end)...
        ) ,...
        'Interpreter','none'...
    )

    highlight(params.StartDate:MODEL.DATES.hist_end);

    vline( ...
        MODEL.END_HIST.(var_data), ...
        'LineWidth', 1, ...
        'LineStyle', '-.' ...
    );
    
    zeroline();
    
    if params.PlotSSLine
        if SS.(strcat(var_data, '_ss')) ~= 0
        hline(...
            SS.(strcat(var_data, '_ss')), ...
            'LineWidth', 1.5, ...
            'LineStyle', ':' ...
            );
        end
    end

    % Anotaciones
    if params.PlotAnnotations 
    % Anotaciones para corrimiento actual
    SimTools.scripts.die_anotaciones( ...
        dat2dec(params.AnnoRange)', ...
        MODEL.F_pred.(var_data_m)(params.AnnoRange), ...
        string(num2str(MODEL.F_pred.(var_data_m)(params.AnnoRange), '%0.2f')), ...
        'Container', plot_p, ...
        'Color', 'b', ...
        'XAdjustment', params.AnnotationXAdjustment, ...
        'YAdjustment', params.AnnotationYAdjustment ...
    )

    % Anotaciones para corrimiento anterior si es que se grafica
    if ~isempty(params.FullDataAnt_Name)
        SimTools.scripts.die_anotaciones( ...
            dat2dec(params.AnnoRange)', ...
            full_data_ant.(var_data)(params.AnnoRange), ...
            string(num2str(full_data_ant.(var_data)(params.AnnoRange), '%0.2f')), ...
            'Container', plot_p, ...
            'Color', 'r', ...
            'IsAnt', true, ...
            'XAdjustment', params.AnnotationXAdjustment, ...
            'YAdjustment', params.AnnotationYAdjustment ...
        )
    end
    end
  
    if params.PlotSSLine
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
    end

    % ----- Panel de Tabla -----
    table_p = uipanel( ...
        main_p, ...
        'Position', [0, 1 - 0.8 - 0.10, 1, 0.10], ...
        'BackgroundColor', [1, 1, 1] ...
    );
    
    data_table = [];
    if ~isempty(params.FullDataAnt_Name)
        data_table(:, 1) = full_data_ant.(var_data)(params.TabRange);
        data_table(:, 2) = MODEL.F_pred.(var_data_m)(params.TabRange);
        text_Color = [1,0,0 ; 0,0,1];
    else
        data_table(:, 1) = full_data_ant.(var_data)(params.TabRange);
        text_Color = [1, 1, 1];
    end

    SimTools.scripts.plot_data_table( ...
        params.TabRange, ...
        data_table, ...
        'Parent', table_p, ...
        'SeriesNames', params.LegendsNames, ...
        'TextColor', text_Color, ...
        'FontSize', 9 ...
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
%% ----- Save -----


if var < 10
    num = sprintf("0%i", var);
else
    num = sprintf('%i', var);
end


SimTools.scripts.pausaGuarda(...
    fullfile(params.SavePath, ...
    sprintf("%s_%s.png", num, var_data)), ...
    'AutoSave', params.AutoSave ...
)
end

if params.CloseAll
close all
end

end