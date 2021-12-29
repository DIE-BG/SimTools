function  measure = eval_jprediction_mms(MODEL, varargin)

% eval_jprediction_mms realiza la evaluación de los pronósticos almacenados
% en `MODEL.JPRED`.
%{
% ## Syntax ##
%
%     eval_jprediction_mms(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura con los datos recortados `MODEL.data_mr`, 
% con los datos recortados, `MODEL.JPRED` con los resultados del proceso de
% proyección y el campo `MODEL.EvalVar` con el nombre de aquellas variables
% que se evaluarán.
%
%
% ## Options ##
%
% * PredRange = MODEL.DATES.pred_start:MODEL.DATES.pred_end [ `DateWrapper` ] - 
% Rango que abarca el pronóstico.
%
% * EvalFun = @(x) mean(x) [ `function_handle` ] - Función para el cálculo
% del estadistico de error.
%
% * EvalHorizon = [4, 8, 12] [ `double` ] - Vector que contiene los
% pronósticos a los que se evaluará el estadístico de error.
%
%
% ## Output Arguments ##
%
% __`measure`__ [ double ] - 
% Matriz que contiene los estadísticos de error. En las columnas se
% encuentra `MODEL.EvalVar` y en las filas `EvalHorizon`.
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
    addParameter(p, 'EvalFun', @(x) mean(x));
    addParameter(p, 'EvalHorizon', [4, 8, 12])
parse(p, varargin{:});
params = p.Results;

% Recorte de datos a la porción que contiene los pronósticos
obs = dbclip(MODEL.data_mr, params.PredRange);
pred = dbclip(MODEL.JPRED, params.PredRange);

% Cálculo de los errores
error = cellfun(@(x) pred.(x) - obs.(x), MODEL.EvalVar, ...
    'UniformOutput', false);

% Cálculo de la medida de error. 
measure = [];

for i = 1:length(params.EvalHorizon)
    % Si no se cuentan con suficientes datos para computar la medida de
    % error en un horizonte de pronóstico, se asigna un NaN.
    if length(params.PredRange) < params.EvalHorizon(i)
        measure(i, :) = NaN(1, length(MODEL.EvalVar));
    else
        measure(i, :) = cellfun( ...            
            @(x) x.Data(params.EvalHorizon(i)), ... @(x) params.EvalFun(x.Data(1:params.EvalHorizon(i))), ...
            error);
    end
end

end

MODEL = jprediction_mms(MODEL, 'PredRange', MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end)
params.PredRange = MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end
params.EvalFun = @(x) mean(x)
params.EvalHorizon = [4, 8, 12]
