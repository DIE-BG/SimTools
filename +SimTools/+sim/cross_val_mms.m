function MODEL = cross_val_mms(MODEL, varargin)

% cross_val_mms la evaluación de los pronósticos disminuyendo la ventana,
% dejando aquellas variables exógenas ancladas hasta el fin de historia.
%{
% ## Syntax ##
%
%     cross_val_mms(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, con el modelo 
% resuelto, `MODEL.data_mr` con los datos recortados, `MODEL.ExoVar` con
% el nombre de las variables definidas como exógenas y que serán ancladas; 
% y la estructura con los datos `MODEL.data_mr`.
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
% * EvalFunTag = 'ME' [ `char` ] - Nombre corto para el estadístico de
% error.
%
% * EvalHorizon = [4, 8, 12] [ `double` ] - Vector que contiene los
% pronósticos a los que se evaluará el estadístico de error.
%
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden los resultados de la
% evaluación con ventana móvil, almacenados en `MODEL.EVAL`.
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
    addParameter(p, 'PredRange', MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end);
    addParameter(p, 'EvalFun', @(x) mean(x, 3, 'omitnan'));
    addParameter(p, 'EvalFunTag', 'ME');
    addParameter(p, 'SpecificExo', {});
    addParameter(p, 'EvalHorizon', [4, 8, 12]); % 1, 2 y 3 años adelante.
parse(p, varargin{:});
params = p.Results;

measure = [];

if ~isempty(params.SpecificExo)
    max_anchor = structfun(@(x) max(x), params.SpecificExo);
else
    max_anchor = 0;
end

for t = 1:(length(params.PredRange) - max_anchor)
    MODEL_temp = SimTools.sim.jprediction_mms( ...
        MODEL, ...
        'SpecificExo', params.SpecificExo, ...
        'PredRange', params.PredRange(t:end) ...
    );


    measure(:, :, t) = SimTools.sim.error_jprediction_mms(MODEL_temp, ...
            'PredRange', params.PredRange(t:end), ...
            'EvalHorizon', params.EvalHorizon);
end

resume = params.EvalFun(measure);

if ~any(strcmp('EVAL', fieldnames(MODEL)))
    MODEL.EVAL = struct();
end

MODEL.EVAL.(params.EvalFunTag) = struct();

for i = 1:length(MODEL.EvalVar)
    MODEL.EVAL.(params.EvalFunTag).(MODEL.EvalVar{i}) = resume(:, i);
end

MODEL.EVAL.(params.EvalFunTag).measure = measure;
MODEL.EVAL.(params.EvalFunTag).EvalHorizon = params.EvalHorizon;
    
end

% params.PredRange = MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end
% params.EvalFun = @(x) mean(x, 3, 'omitnan')
% params.EvalFunTag = 'ME'
% params.EvalHorizon = [4, 8, 12]