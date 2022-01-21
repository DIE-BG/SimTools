function MODEL = impulse_response(MODEL, varargin)

% impulse_response realiza el cálculo de los impulso respuesta dado choques
% de 1 unidad en las variables de choques especificadas en el modelo.
%{
% ## Syntax ##
%
%     MODEL = impulse_response(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Debe contener como mínimo la estructura del modelo suavizada `MODEL.M`,
% Así como la estructura de fechas `MODEL.DATES` con el rango de fechas a
% a predecir. 
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden el resultado en `MODEL.impulse_response`
% de la simulación de un choque de 1%.
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

% Definición de períodos de simulación

p = inputParser;
    addParameter(p, 'FromSState', true);
parse(p, varargin{:});
params = p.Results; 

startSim = 1;
endSim = MODEL.DATES.pred_end - MODEL.DATES.pred_start;

temp_sname = get(MODEL.M, 'elist');

%Base de datos con estados estacionarios del modelo original (g)

SIM = sstatedb(MODEL.M, startSim-4:endSim);

    for shock = 1:length(temp_sname)
        % Inicializamos la estructura de datos para la simulación.
        IMPULSE_RESPONSE.(temp_sname{shock}).sim = SIM;
        % Imponemos un choque de 1% en la variable especificada.
        IMPULSE_RESPONSE.(temp_sname{shock}).sim.(temp_sname{shock})(startSim) = 1;
        % Simulamos el efecto que tiene el choque anterior en el resto de
        % variables, dada la estructura del modelo.
        IMPULSE_RESPONSE.(temp_sname{shock}).sim_r = simulate(MODEL.M, ...
            IMPULSE_RESPONSE.(temp_sname{shock}).sim, ...
            startSim:endSim);
        % Combinamos los resultados con la estructura que impuso el choque.
        IMPULSE_RESPONSE.(temp_sname{shock}).sim_r = dbextend( ...
            IMPULSE_RESPONSE.(temp_sname{shock}).sim, ...
            IMPULSE_RESPONSE.(temp_sname{shock}).sim_r);
        % Desechamos las variables temporales y nos quedamos con aquella
        % que contiene los resultados combinados.
        IMPULSE_RESPONSE.(temp_sname{shock}) = IMPULSE_RESPONSE.(temp_sname{shock}).sim_r;
        if ~params.FromSState
            IMPULSE_RESPONSE.(temp_sname{shock}) = cell2struct(...
                cellfun(...
                    @(x) IMPULSE_RESPONSE.(temp_sname{shock}).(x) - SIM.(x), ...
                    get(MODEL.M, 'xlist'), ...
                    'UniformOutput', false ...
                ), ...
                get(MODEL.M, 'xlist'), ...
                2 ...
            );
        end
        % Corregir problemas de aproximación.
        IMPULSE_RESPONSE.(temp_sname{shock}) = structfun( ...
            @(x) round(x, 8), ...
            IMPULSE_RESPONSE.(temp_sname{shock}), ...
            'UniformOutput', false ...
        );
    end

MODEL.impulse_response = IMPULSE_RESPONSE;
end