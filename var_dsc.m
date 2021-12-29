function MODEL = var_dsc(MODEL)

% var_dsc realiza la descomposición de varianza del rango de fechas a
% pronosticar, dada la estructura del modelo suavizado `MODEL.MF`
%{
% ## Syntax ##
%
%     MODEL = var_dsc(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Debe contener como mínimo la estructura del modelo suavizada `MODEL.MF`,
% Así como la estructura de fechas `MODEL.DATES` con el rango de fechas a
% a predecir. 
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden la descomósición absoluta
% `MODEL.var_dsc.abs`, realtiva `MODEL.var_dsc.rel` y una lista con el orden
% y una lista con el nombre de las filas.
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

[X, Y, List, A, B] = fevd(MODEL.MF, ...
    MODEL.DATES.pred_start:MODEL.DATES.pred_end);

MODEL.var_dsc.abs = A;
MODEL.var_dsc.rel = B;
MODEL.var_dsc.s_name = List{2};

end
