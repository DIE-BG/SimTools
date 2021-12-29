function MODEL = diff_shd_dsc(MODEL)

% diff_shd_dsc calcula la primera diferencia de la descomposición de
% choques.
%{
% ## Syntax ##
%
%     MODEL = shd_dsc(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Debe contener como mínimo los resultados de la descomposición de choques 
% del modelo `MODEL.shd_dsc`.
%
% ## Options ##
%
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura de modelo a la que se le añaden la descomposición de choques
% en primera diferencia `MODEL.diff_shd_dsc`.
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

MODEL.diff_shd_dsc = structfun( ...
    @(x) diff(x), ...
    MODEL.shd_dsc, ...
    'UniformOutput', false ...
    );

end