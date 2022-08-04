function MODEL = kalman_smth(MODEL, varargin)

% kalman_smth  utiliza la estructural del modelo en `MODEL.M`, los datos
% para las variables de medida en `MODEL.ylist_data` y las fechas
% históricas en `MODEL.DATES` para realizar el suavizamiento de Kalman.
%{
% ## Syntax ##
%
%     MODEL = kalman_smth(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura que contiene como mínimo la estructura del modelo en
% `MODEL.M`, los datos de la variables de medida en `MODEL.ylist_data` y
% las fechas históricas en `MODEL.DATES`.
%
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura a la que se le añade `MF` con el modelo resuelto y filtrado,
% así como `F` que contiene información resultante del proceso de
suavizado.
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

if isstruct(MODEL.DATES.hist_start)
    temp_hist_start = max(struct2array(MODEL.DATES.hist_start));
    temp_hist_end = MODEL.DATES.hist_end;
elseif isstruct(MODEL.DATES.hist_end)
    temp_hist_start = MODEL.DATES.hist_start;
    temp_hist_end = min(struct2array(MODEL.DATES.hist_end));
else
    temp_hist_start = MODEL.DATES.hist_start;
    temp_hist_end = MODEL.DATES.hist_end;
end

p = inputParser;
    addParameter(p, 'FilterRange', temp_hist_start:temp_hist_end);
parse(p, varargin{:});
params = p.Results; 


[MF,F] = filter( ...
    MODEL.M, ...
    MODEL.ylist_data, ...
    params.FilterRange, ...
    'meanOnly=',true ...
);

MODEL.MF = MF;
MODEL.F = F;

end