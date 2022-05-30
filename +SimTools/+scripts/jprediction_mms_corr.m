
function MODEL = jprediction_mms_corr(MODEL, varargin)

% jprediction_mms_corr realiza el pronóstico de todas las variables del modelo,
% anclando aquellas que poseen datos más allá del fin de historia y poseen
% un choque que se pueda endogenizar.
%{
% ## Syntax ##
%
%     jprediction_mms_corr(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo filtrado `MODEL.MF`, 
% `MODEL.data_mr` con los datos recortados.
%
%
% ## Options ##
%
% * PredRange = MODEL.DATES.pred_start:MODEL.DATES.pred_end [ `DateWrapper` ] - 
% Rango a pronosticar.
%
% * NoShocksVar = {} [ `Cell` ] - Nombres de las variables que no poseen
% choques.
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden los pronósticos dentro del
% campo `MODEL.F_pred`.
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

% Parámetros opcionales
p = inputParser;
    addParameter(p, 'PredRange', MODEL.DATES.pred_start:MODEL.DATES.pred_end);
    addParameter(p, 'NoShocksVar', {});
    addParameter(p, 'SaveFullData', false);
    addParameter(p, 'CoerceObs', true);
parse(p, varargin{:});
params = p.Results; 



pred_plan = plan(MODEL.MF, params.PredRange);

var_names = fieldnames(MODEL.data_mr);

for i = 1:length(var_names)
    % Realiza el proceso de exogenizar y endogenizar aquellas variables que
    % tienen datos más allá del fin de historia para el modelo.
    if MODEL.data_mr.(var_names{i}).Range(end) > MODEL.DATES.hist_end
          % Deja fuera de este proceso aquellas variables que no tiene choques que puedan ser
          % endogenizados.
          if ~isempty(params.NoShocksVar) && ~any(strcmp(var_names{i}, params.NoShocksVar))
            
              pred_plan = exogenize( ...
                pred_plan, ...
                var_names{i}, ...
                MODEL.DATES.pred_start:MODEL.data_mr.(var_names{i}).Range(end) ...
            );
              
            pred_plan = endogenize( ...
                pred_plan, ...
                strcat('s_', var_names{i}), ...
                MODEL.DATES.pred_start:MODEL.data_mr.(var_names{i}).Range(end) ...
            );
            % Condición del modelo si todas las variables a anclar tienen choques.
            elseif isempty(params.NoShocksVar)

            pred_plan = exogenize( ...
                pred_plan, ...
                var_names{i}, ...
                MODEL.DATES.pred_start:MODEL.data_mr.(var_names{i}).Range(end) ...
            );

            pred_plan = endogenize( ...
                pred_plan, ...
                strcat('s_', var_names{i}), ...
                MODEL.DATES.pred_start:MODEL.data_mr.(var_names{i}).Range(end) ...
            );
        end
    end
end



%Simulación de pronósticos.
q = simulate( ...
    MODEL.MF, ...
    MODEL.data_mr, ...
    params.PredRange, ...
    'plan', pred_plan, ...
    'anticipate', false ...
);

% Almacenamiento de resultados en estructura MODEL.

F_pred = dboverlay(MODEL.F, q);

MODEL.F_pred = F_pred;

% ---------------- Almacenamiento opcional del full data ------------------

% if params.SaveFullData
%     dat_temp = dboverlay( ...
%         MODEL.F_pred * get(MODEL.MF, 'xlist'), ...
%         MODEL.data_mr);
%     dat_temp = structfun(@(x) round(x, 8), dat_temp, 'UniformOutput', false);
%     databank.toCSV(dat_temp, fullfile(MODEL.FULLDATANAME_ACT), Inf);
% end

if params.SaveFullData
    dat_temp = MODEL.F_pred * get(MODEL.MF, 'ylist');
    
    dat_temp = cell2struct(...
        struct2cell(dat_temp), ...
        cellfun(@(x) x{1}, regexp(get(MODEL.MF, 'ylist'), 'm_(.*)$', 'tokens', 'once'), 'UniformOutput', false) ...
    );

    dat_temp = dboverlay( ...
        dat_temp, ...
        MODEL.data_mr ...
    );

    dat_temp = structfun(@(x) round(x, 8), dat_temp, 'UniformOutput', false);
    databank.toCSV(dat_temp, fullfile(MODEL.FULLDATANAME_ACT), Inf);
end

if params.CoerceObs
    MODEL.F_pred = structfun(@(x) round(x, 8), ...
        dboverlay(MODEL.F_pred, MODEL.data_mr), ...
        'UniformOutput', false);
end

end

