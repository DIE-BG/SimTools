%% Presentación de descomposición de choques

list = varNameShd;
list = cellfun(@(name) strcat(name, '-sd.png'), list, ...
    'UniformOutput', false);

%% Diapositiva de título
exportToPPTX('addslide','Master',1,'Layout','Diapositiva de título');
% exportToPPTX('addtext','1. Escenario Base','Position','Title');
exportToPPTX('addtext','**Descomposición de Choques**','Position','Title','HorizontalAlignment','Left');


%% Diapositivas de contenido

for i = 1:length(list)
    
    % Tipo de slide
    exportToPPTX('addslide','Master',1,'Layout','En blanco');
    
    % Imagen
    exportToPPTX( ...
            'addpicture', ...
            fullfile( ...
                'graficas', ...
                sprintf('exp-%i', EXPERIMENT_NUM), ...
                'shock_desc', ...
                list{i} ...
            )...
        );
end
