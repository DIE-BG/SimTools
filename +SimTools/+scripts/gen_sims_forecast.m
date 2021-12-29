function MODEL = gen_sims_forecast(MODEL, varargin)

% gen_sims_forecast Genera los pronósticos con jucio, anclando las
% variables exógenas. Los pron´soticos simulados se realizan además con
% ventanas móviles.
%{
% ## Syntax ##
%
%     plot_spaghetti(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, con el modelo 
% resuelto, `MODEL.data_mr` con los datos recortados y  `MODEL.ExoVar` con
% el nombre de las variables definidas como exógenas y que serán ancladas, 
% `MODEL.EvalVar` con las variables que serán evaluadas.
%
%
% ## Options ##
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * PredRange = MODEL.DATES.pred_start:MODEL.DATES.pred_end [ `DateWrapper` ] - 
% Rango a pronosticar.
%
% ## Output Arguments ##
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


p = inputParser;
    addParameter(p, 'SaveSim', fullfile(userpath, 'temp'));
    addParameter(p, 'PredRange', MODEL.DATES.pred_start:MODEL.DATES.pred_end);
    addParameter(p, 'ModelName', 'temp');
parse(p, varargin{:});
params = p.Results; 

% Verificación y creación del directorio para las simulaciones
if ~isfolder(params.SaveSim)
    mkdir(params.SaveSim)
end


MODEL.JF_pred_sim = {};

for t = 1:length(params.PredRange)
    MODEL.JF_pred_sim{t} = jprediction_mms(MODEL, ...
    'PredRange', params.PredRange(t:end)).JPRED;

    MODEL.JF_pred_sim{t}.firstpred = params.PredRange(t);
end

save(fullfile(params.SaveSim, sprintf('%s_forecast', params.ModelName)), ...
    '-struct', ...
    'MODEL', 'JF_pred_sim')

end