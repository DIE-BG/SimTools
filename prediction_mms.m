function MODEL = prediction_mms(MODEL)

% prediction_mms  utiliza la estructural del modelo suavizado en
% `MODEL.MF`, así como los resultados del suavizado en `MODEL.F` Para
% generar los pronósticos de las variables.
%{
% ## Syntax ##
%
%     MODEL = prediction_mms(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura que contiene como mínimo la estructura del modelo suavizado en
% `MODEL.MF`, así como los resultados del suavizado en `MODEL.F` y las fechas
% Para realizar la predicción en `MODEL.DATES`.
%
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura a la que se le añade `MODEL.F_pred` con los resultados de la
% predicción.
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021

F_pred = jforecast(MODEL.MF, MODEL.F,... 
   MODEL.DATES.pred_start:MODEL.DATES.pred_end,...
   'anticipate=',false,...
   'meanOnly=',true);

% Añade los resultados del pronóstico a la estructura de resultados del 
% suavizado (F).
F_pred = dboverlay(MODEL.F, F_pred);

MODEL.F_pred = F_pred;

end