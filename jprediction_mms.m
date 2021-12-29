function MODEL = jprediction_mms(MODEL, varargin)

% jprediction_mms realiza el pronóstico de todas las variables del modelo,
% anclando aquellas Definidas como exóngenas en `MODEL.ExoVar`.
%{
% ## Syntax ##
%
%     jprediction_mms(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, con el modelo 
% resuelto, `MODEL.data_mr` con los datos recortados y  `MODEL.ExoVar` con
% el nombre de las variables definidas como exógenas y que serán ancladas.
%
%
% ## Options ##
%
% * PredRange = MODEL.DATES.pred_start:MODEL.DATES.pred_end [ `DateWrapper` ] - 
% Rango a pronosticar.
%
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden los pronósticos dentro del
% campo `MODEL.JPRED`.
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
%   ----- Para Pruebas -----
params.PredRange = MODEL.DATES.hist_start + 1:qq(2020,2);
params.SpecificExo = struct( ...
                        'v_cpi_sub', 2 ...
                     );
%}
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parámetros opcionales
p = inputParser;
    addParameter(p, 'PredRange', MODEL.DATES.pred_start:MODEL.DATES.pred_end);
    addParameter(p, 'SpecificExo', {});
parse(p, varargin{:});
params = p.Results; 


% Se verifica que las variables a anclar cuentan con suficiente datos. De
% no tener suficientes, se dispara un error.
isInRange_Exo = all( ...
    cellfun( ...
        @(x) MODEL.data_mr.(x).Range(1) <= params.PredRange(1) && ...
            MODEL.data_mr.(x).Range(end) >= params.PredRange(end), ...
    MODEL.ExoVar, ...
    'UniformOutput', true)...
);

if ~isempty(params.SpecificExo)
    isInRange_SpecificExo = all( ...
        cellfun( ...
            @(x) MODEL.data_mr.(x).Range(1) <= params.PredRange(1) && ...
                MODEL.data_mr.(x).Range(end) >= params.PredRange(end), ...
        fieldnames(params.SpecificExo), ...
        'UniformOutput', true)...
    );
else
    isInRange_SpecificExo = true;
end

if ~isInRange_Exo || ~isInRange_SpecificExo
    error('Alguna de las variables no tiene suficiente información para anclar.')
end


% Se define el plan de simulación, definiendo como exógenas aquellas
% variables definidas en `MODEL.ExoVar`.
pred_plan = plan(MODEL.M, params.PredRange);

% Exogenizar variables en el rango completo de pronóstico.
% for i = 1:length(MODEL.ExoVar)
    pred_plan = exogenize(pred_plan, ...
        MODEL.ExoVar, ...MODEL.ExoVar{i}, ...
        params.PredRange);
    
    pred_plan = endogenize(pred_plan, ...
        strcat('s_', MODEL.ExoVar), ...strcat('s_', MODEL.ExoVar{i}), ...
        params.PredRange);
% end

% Exogenizar variables en el rango completo de pronóstico.


if ~isempty(params.SpecificExo)
SpecificExo_names = fieldnames(params.SpecificExo);
    for i = 1:length(SpecificExo_names)
        pred_plan = exogenize(pred_plan, ...
            SpecificExo_names{i}, ...
            params.PredRange(1:params.SpecificExo.(SpecificExo_names{i})) ...
        );
        
        pred_plan = endogenize(pred_plan, ...
            strcat('s_', SpecificExo_names{i}), ...
            params.PredRange(1:params.SpecificExo.(SpecificExo_names{i})) ...
        );
    end
end


%Simulación de pronósticos.
q = simulate(MODEL.M, ...
    MODEL.data_mr, ...
    params.PredRange, ...
    'plan',pred_plan, ...
    'anticipate',false);

% Almacenamiento de resultados en estructura MODEL.
MODEL.JPRED = dbextend(MODEL.data_mr, q);

end

% params.PredRange = MODEL.DATES.hist_start + 1:MODEL.DATES.hist_end