function MODEL = read_data_corr(MODEL, varargin)

% read_data  lee los datos, los recorta a la ventana especificada para la 
% historia asignas las observaciones para las respectivas variables de
% medida.
%{
% ## Syntax ##
%
%     MODEL = read_data(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura con los nombres del archivo `.mod`, archivo `.m` con
% parámetros, `.csv` con los datos. Además incluye objeto M de tipo `model`
% previamente resuleto, así como una estructura llamada `DATES` que
% contiene los límites de las fechas históricas y para la predicción.
%
% ## Options ##
%
% * FixedPredVar = {} [ `Cell` ] - Nombre de variables de transición con
% anclajes.
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura a la que se le añade `data` con los datos originales, `data_mr`
% con los datos recortados y `ylist_data` con las observaciones para las variables 
% de medida y `DATES.hist_start` como la máxima fecha inicial de los datos,
% la cual se usa para recortar la data.
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
    addParameter(p, 'FixedPredVar', {});
    addParameter(p, 'EndoVar', {});
    addParameter(p, 'StartEndoVar', {});
    addParameter(p, 'EndEndoVar', {});
    addParameter(p, 'AroundZero', false);
    addParameter(p, 'OutSampleEval', false);
    addParameter(p, 'IsBackcast', false);
    addParameter(p, 'NoAnch', false);
    parse(p, varargin{:});
params = p.Results;

%{
% PARA PRUEBAS: Son necesarios los pasos previos en la función
% eval_forecast.m
params.FixedPredVar = MODEL.ExoVar;
params.EndoVar = MODEL.EvalVar;
params.StartEndoVar = MODEL.DATES.hist_start;
params.EndEndoVar = MODEL.DATES.hist_end;
params.AroundZero = ~params.AroundSS;
params.OutSampleEval = true;
params.IsBackcast = params.IsBackcast;
params.NoAnch = params.NoAnch;
%}

% Lectura del archivo de datos. -------------------------------------------

% Verifica si la fuente de datas es un archivo .mat o un .csv
if strcmp(...
    regexp(MODEL.data_file_name, '\.(\S*)$', 'tokens', 'once'), ...
    'mat' ...
)
    data = load(MODEL.data_file_name);
    data_names_temp = fieldnames(data);
    data = data.(data_names_temp{1});
else
    data = databank.fromCSV(MODEL.data_file_name);
end

% Filtramos las variables de tal modo que queden solo las que pertenencen
% al modelo.
data = data * get(MODEL.M, 'xlist');

% Fecha históricas en los datos. Se especifican en el csv con los datos. -----------
start_hist = structfun(@(x) x.Range(1), data, 'UniformOutput', false);

end_hist = structfun(@(x) x.userdata.endhist, data, 'UniformOutput', false);
end_hist = structfun(@(x) str2dat(x), end_hist, 'UniformOutput',false);

% Límites de fechas en el archivo original de datos. ----------------------
start_data = structfun(@(x) x.Range(1), data, 'UniformOutput', false);
end_data = structfun(@(x) x.Range(end), data, 'UniformOutput', false);

% Se agrega un filtro para las variables que no se anclarán.

if params.NoAnch
    params.EndoVar = get(MODEL.M, 'xlist');
    params.FixedPredVar = {};
end

if ~isempty(params.EndoVar) && ~isempty(params.StartEndoVar)
    for i = 1:length(params.EndoVar)
        start_hist.(params.EndoVar{i}) = params.StartEndoVar;
    end
end

if ~isempty(params.EndoVar) && ~isempty(params.EndEndoVar)
    for i = 1:length(params.EndoVar)
        end_hist.(params.EndoVar{i}) = params.EndEndoVar;
    end
end

% Si las variables tienen una fecha incial mayor a la que se encuentra en
% los datos, o si tiene una fecha final menor que en los datos, se
% espcifica que es una de las variables a anclar. -------------------------
data_names = fieldnames(data);
if isempty(params.FixedPredVar) && ~params.NoAnch
    params.FixedPredVar = data_names( ...
        cellfun( ...
            @(x) start_data.(x) < start_hist.(x) || end_data.(x) > end_hist.(x), ...
            data_names ...
        ) ...
    );
end

% Transformar como variable alrededor de la media si es que se requiere. --
if params.AroundZero && params.OutSampleEval
    temp_obsrng = params.StartEndoVar:params.EndEndoVar; % Rango observaciones
    if params.IsBackcast
        temp_evalrng = min(struct2array(start_data)):params.StartEndoVar - 1;
    else
        temp_evalrng = params.EndEndoVar + 1:max(struct2array(end_data)); % Rango de evaluación
    end
    
    temp_means = struct(); % Series de tiempo con dos diferentes medias
    for i = 1:length(data_names)
        temp_means.(data_names{i}) = tseries();
        temp_means.(data_names{i})(temp_obsrng) = mean( ...
            data.(data_names{i})(temp_obsrng) ...
        );
        temp_means.(data_names{i})(temp_evalrng) = mean( ...
            data.(data_names{i})(temp_evalrng) ...
        );
        % Recalculando data al rededor de la media
        data.(data_names{i}) = data.(data_names{i}) - temp_means.(data_names{i});
    end
end

% Recorte de información dadas las variables a anclar. --------------------

data_mr = data;

% Si se especifica que no hay anclajes, data_mr no conserva ningún datos
% fuera de la historia para todas la variables.

for i = 1:length(data_names)
    if any(strcmp(data_names{i}, params.FixedPredVar))
        data_mr.(data_names{i}) = data.(data_names{i});
    else
        data_mr.(data_names{i}) = resize( ...
            data.(data_names{i}), ...
            start_hist.(data_names{i}):end_hist.(data_names{i}) ...
        );
    end
end

% Asignación de datos para variables en ecuaciones de medida. -------------

ylist = get(MODEL.M,'ylist');                                         
ylist_obs = cellfun( ...
    @(x) regexp(x, '(?<=m_)(\S*)$', 'tokens', 'once'), ...
    ylist ...
);

for i = 1:length(ylist)
    O.(ylist{i}) = data_mr.(ylist_obs{i});
end

% Ouput -------------------------------------------------------------------

MODEL.data = data;
MODEL.data_mr = data_mr;
MODEL.ylist_data = O;

MODEL.DATES.hist_start = params.StartEndoVar;
MODEL.END_HIST = end_hist;
MODEL.FixedPredVar = params.FixedPredVar;

end
