function plot_impulse_response(MODEL, varargin)

% plot_impulse_response las gráficas de los impulso respuesta simulados.
%{
% ## Syntax ##
%
%     plot_var_dsc(MODEL, varargin)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] -
% Debe contener al menos la estructura del modelo `MODEL.M`,
%`MODEL.impulse_response` y `MODEL.DATES`
%
% ## Options ##
%
% * SavePath = fullfile(userpath, 'temp') [ `String` ] - Directorio donde
% guarda la gráfica.
%
% * ShockName = get(MODEL.M, 'elist') [ `cell` ] - Nombre de los choques a
% graficar.
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
% Parametros opcionales
 p = inputParser;
    addParameter(p, 'SavePath', fullfile(userpath, 'temp'));
    addParameter(p, 'ShockName', get(MODEL.M, 'elist'));
    addParameter(p, 'FontSize', 12);
parse(p, varargin{:});
params = p.Results; 

% Verificación y creación del directorio para las gráficas
if ~isfolder(params.SavePath)
    mkdir(params.SavePath)
else
    rmdir(params.SavePath, 's')
    mkdir(params.SavePath)
end


% Definición de períodos de simulación
startSim = 1;
endSim = MODEL.DATES.pred_end - MODEL.DATES.pred_start;

plotrng = startSim-4:endSim;

% Nombre del origen de los choques
temp_sname = params.ShockName;

% Nobre de las variables afectadas por el choque
xlist = get(MODEL.M, 'xlist');

% Tamaño de la grilla para el subplot
size = ceil(sqrt(length(xlist)));
if size > 5
    warning('La grilla tiene un tamaño demasiado grande.')
end

for shock = 1:length(temp_sname)
    
    figure;
    
    set(gcf, ...
        'defaultaxesfontsize', params.FontSize, ...
        'Position', [1 42.0182 1.6756e+03 825.6000]);
  
    for x_i = 1:length(xlist)
    
        subplot(size, size, x_i);
    
        plot(plotrng, ...
            MODEL.impulse_response.(temp_sname{shock}).(xlist{x_i}), ...
            '.-b');
    
        grid on

         highlight(-3:0);
    
        title(xlist{x_i}, ...
            'interpreter', 'none');
    
        ylabel('Porcentaje', ...
            'Fontsize', params.FontSize);

        ytickformat('%0.3f')
    end
        
    sgtitle(sprintf("Respuesta a un choque en %s", temp_sname{shock}), ...
        'Interpreter', 'none');    
    

    if shock < 10
        num = sprintf("0%i", shock);
    else
        num = sprintf('%i', shock);
    end
       saveas(gcf, ...
                fullfile(params.SavePath, ...
                sprintf("%s_%s.png", num, temp_sname{shock}))...
        )
end

close all

end