function plot_prediction_mms(MODEL, varargin)

% plot_prediction_mms realiza las gráficas del proceso de predicción del
% modelo.
%{
% ## Syntax ##
%
%     plot_prediction_mms(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`, la estructura
% de fechas `MODEL.DATES`, así como la estructura de resultados del proceso
% de predicción `MODEL.F_pred`.
%
% ## Options ##
%
% * StartDate = MODEL.DATES.hist_start [ `DateWrapper` ] - Fecha a la que
% empieza a graficar la historia.
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
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

% Parametros opcionales de la función
 p = inputParser;
    addParameter(p, 'StartDate', MODEL.DATES.hist_start);
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'CloseAll', true);
parse(p, varargin{:});
params = p.Results;  

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end

% Creación de la gráfica
figure;

list = get(MODEL.M, 'xlist');

size = round(sqrt(length(list)), 0);

if size > 5
    warning('La grilla contiene demasiado elementos.')
end

set(gcf,'defaultaxesfontsize',12, ...
    'Position', [1 42.0182 1.6756e+03 825.6000]);

for var = 1 : length(list)
  
  subplot(size, size, var);

  plot(params.StartDate:MODEL.DATES.pred_end, ...
      MODEL.F_pred.(list{var}),'.-b');

  grid on;  

  title(list{var},'interpreter','none');

  highlight(params.StartDate:MODEL.DATES.hist_end);
end

sgtitle(sprintf('Proyecciones del Modelo \n %s - %s', ...
    dat2char(MODEL.DATES.pred_start), ...
    dat2char(MODEL.DATES.pred_end)))

saveas(gcf, ...
    fullfile(params.SavePath, "prediction.png")...
)

if params.CloseAll
    close all
end

end