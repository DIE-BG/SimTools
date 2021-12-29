function MODEL = load_sims_forecast(MODEL, varargin)


% load_sims_forecast carga las simulaciones de pronósticos realizadas para
% las gráficas de espagjetti.
%{
% ## Syntax ##
%
%     load_sims_forecast(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - Objeto tipo struct con todos los resultados del
% modelo.
%
%
% ## Options ##
%
% * SimsPath = fullfile('data', 'sims', 'forecast')[ `string` ] -
% Directorio donde se encuentran las simulaciones.
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden el resultado en `MODEL.FORECAST_SIMS`
% de los pronósticos disponibles para los diferentes modelos.
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

% Parametros opcionales
 p = inputParser;
    addParameter(p, 'SimsPath', fullfile('data', 'sims', 'forecast'));
parse(p, varargin{:});
params = p.Results; 

% Lista de archivos de pronósticos simulados
% list_path = fullfile('data', 'sims', 'forecast');
list_path = params.SimsPath;

list = ls( ... '
        fullfile(list_path, '*_forecast.mat') ...
        );


% Asignación de pronósticos simulados a MODEL
MODEL.FORECAST_SIMS = struct();

for i = 1:size(list, 1)
    temp_name = regexp(list(i, :), '^(\S*)(?=_forecast)', 'match', 'once');    
   
    MODEL.FORECAST_SIMS.(temp_name) = load( ...
        fullfile( ...
            list_path, ...
            regexp(list(i, :), '^(\S*)(?=\s|$)', 'match', 'once') ...
        ) ...
    );
end

end
