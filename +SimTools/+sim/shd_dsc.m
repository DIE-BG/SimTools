function MODEL = shd_dsc(MODEL, varargin)

% shd_dsc realiza la descomposición de choques de un modelo suavizado que ya 
% pasó por un proceso de predicción. 
%{
% ## Syntax ##
%
%     MODEL = shd_dsc(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Debe contener como mínimo la estructura del modelo suavizada `MODEL.MF`, 
% `MODEL.F`, así como la estructura de fechas `MODEL.DATES`.
%
% ## Options ##
%
% * Pred = [ `true`|false ] - Descomposición de choques incluyendo las
% proyecciones.
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden la descomposición de choques
% `MODEL.shd_dsc`.
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

% Parametros opcionales
 p = inputParser;
    addParameter(p, 'Pred', true);
    addParameter(p, 'EndDate', MODEL.DATES.pred_end)
parse(p, varargin{:});
params = p.Results; 

% Rango de fechas para realizar la descomposición.

if params.Pred
    shdRange = MODEL.DATES.hist_start:MODEL.DATES.pred_end;   
else
    shdRange = MODEL.DATES.hist_start:MODEL.DATES.hist_end;   
end


% Agrupamiento para la agregación de los choques que conforman a las
% variables en las ecuaciones de medida.
GR = grouping(MODEL.MF, 'shock');

E_names = get(MODEL.MF, 'Elist'); % Nombre de choques.

for i = 1:length(E_names)
    GR = addgroup(GR, ...
        E_names{i}(3:end), ...
        E_names{i});
end

% Descomposición de choques
SHD = simulate(MODEL.MF, MODEL.F_pred,shdRange, ...
    'anticipate',false, ...
    'contributions',true);

% Evaluación de contribuciones
[G,] = eval(GR,SHD);                                                                                                                                 % Evaluate contributions                                                                              

MODEL.shd_dsc = G;
MODEL.shd_dsc = structfun(@(x) round(x, 8), MODEL.shd_dsc, 'UniformOutput', false);
end