%% Tabla con la información de los parámetros

params_limits = readtable("data\rangos_param.csv");

params_limits.calibrado = cellfun(@(x) get(MODEL.M, 'Parameters').(x), ...
    params_limits.nombre);

params_limits.is_in = params_limits.calibrado >= params_limits.lim_inf & ...
    params_limits.calibrado <= params_limits.lim_sup;

params_limits.is_in_show = params_limits.nombre;
for i = 1:size(params_limits, 1)
    if params_limits.is_in(i)
        params_limits.is_in_show{i} = '-';
    else
        params_limits.is_in_show{i} = 'Fuera de rango.';
    end
end

n_per_in = sum(params_limits.is_in)*100/size(params_limits, 1);
t = sprintf('Porcentaje de parámetros dentros del rango = %0.2f %%', ...
    n_per_in);


%% Conversión a cellArray


names = {'Nombre', 'Parámetro Calibrado', 'Límite Inferior', 'Límite Superior', ''};
vals = table2cell(params_limits(:, {'nombre', 'calibrado', 'lim_inf', 'lim_sup', 'is_in_show'}));

nCols = length(names);


%% Slidels

exportToPPTX('addslide','Master',1,'Layout','En blanco');

exportToPPTX('addtable', ...
    [names; vals], ...
    'Vert','middle','Horiz','center','FontSize',9, ...
    'ColumnWidth',1/nCols*ones(1, nCols), ...
    'Position',[3 1 8 3]);

exportToPPTX('addtext',t, ...
    'Position',[0.5 6.5 13.33 1.18], ...
    'FontSize',11);
