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
    addParameter(p, 'HistStart', {})
parse(p, varargin{:});
params = p.Results;

% Lectura del archivo de datos. -------------------------------------------

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

if isempty(params.HistStart)
hist_start = max( ...
    structfun(...
        @(x) x.Range(1), ...
        data ...
    ) ...
);
else
    hist_start = params.HistStart;
end

% Fecha histórica final. Se especifica en el csv con los datos. -----------
end_hist = structfun(@(x) x.userdata.endhist, data, 'UniformOutput', false);
end_hist = structfun(@(x) str2dat(x), end_hist, 'UniformOutput',false);

end_data = structfun(@(x) x.Range(end), data, 'UniformOutput', false);

data_names = fieldnames(data);

% Si las variables tienen una fecha final mayor al fin de su historia y no
% se especifica las variables a anclar, utiliza estas para anclar. --------
if isempty(params.FixedPredVar)
    params.FixedPredVar = data_names( ...
        cellfun( ...
            @(x) end_data.(x) > end_hist.(x), ...
            data_names ...
        ) ...
    );
end

% Recorte de información dadas las variables a anclar. --------------------

data_mr = data;

for i = 1:length(data_names)
    if any(strcmp(data_names{i}, params.FixedPredVar))
        data_mr.(data_names{i}) = data.(data_names{i});
    else
        data_mr.(data_names{i}) = resize( ...
            data.(data_names{i}), ...
            hist_start:end_hist.(data_names{i}) ...
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

MODEL.DATES.hist_start = hist_start;
MODEL.END_HIST = end_hist;
MODEL.FixedPredVar = params.FixedPredVar;

end
