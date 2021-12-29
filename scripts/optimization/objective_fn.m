function RMSE = objective_fn(MODEL, varargin)

p = inputParser;
    addParameter(p, 'ParamAssignName', {});
    addParameter(p, 'ParamAssignValue', []);
    addParameter(p, 'ParamExtraAssign', {});
    addParameter(p, 'UpperLimit', []);
    addParameter(p, 'LowerLimit', []);
parse(p, varargin{:});
params = p.Results; 

% Lectura y solución de modelo
MODEL = read_model(MODEL, ...
    'ParamAssignName', params.ParamAssignName, ...
    'ParamAssignValue', params.ParamAssignValue, ...
    'ParamExtraAssign', params.ParamExtraAssign);

% Lectura de datos
MODEL = read_data(MODEL);

% Evaluación y Otimización

if ~isempty(params.LowerLimit) && any(params.ParamAssignValue <= params.LowerLimit)
    RMSE = 1000;

elseif ~isempty(params.UpperLimit) && any(params.ParamAssignValue >= params.UpperLimit)
    RMSE = 1000;

else
    RMSE = cross_val_mms(MODEL, ...
    'PredRange',  MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end, ...
    'EvalFun', @(x) sqrt(mean(x.^2, 3, 'omitnan')), ...
    'EvalFunTag', 'RMSE', ...
    'EvalHorizon', 4).EVAL.RMSE.v_cpi_sub(1);
end
    
end