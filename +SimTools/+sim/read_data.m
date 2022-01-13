function MODEL = read_data(MODEL)

% read_data  Lee los datos, los recorta a la ventana especificada para la 
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
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura a la que se le añade `data` con los datos originales, `data_mr`
% con los datos recortados y `ylist_data` con las observaciones para las variables 
% de medida. 
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -DIE
% -Octubre 2021


data = databank.fromCSV(MODEL.data_file_name);

% Recorte de información al rango de fechas de historia
data_mr = structfun(@(var) resize(var,MODEL.DATES.hist_start:MODEL.DATES.hist_end), ...
    data, ...
    'UniformOutput', false);

% Asignación de datos para variables en ecuaciones de medida
ylist = get(MODEL.M,'ylist');                                         
ylist_obs = cellfun(@(x) regexp(x, '(?<=m_)(\S*)$', 'tokens', 'once'), ...
    ylist);

for i = 1:length(ylist)
    O.(ylist{i}) = data_mr.(ylist_obs{i});
end


MODEL.data = data;
MODEL.data_mr = data_mr;
MODEL.ylist_data = O;

end
