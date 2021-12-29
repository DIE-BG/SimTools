%% Presentación de descomposición de varianza relativa

list_path = fullfile('plots', 'descomposicion_varianza', 'rel');

list = ls( ...
        fullfile(list_path, '*.png') ...
        );

% Diapositiva de título
exportToPPTX('addslide','Master',1,'Layout','Diapositiva de título');
% exportToPPTX('addtext','1. Escenario Base','Position','Title');
exportToPPTX('addtext','**Descomposición de Varianza Relativa**', ...
    'Position','Title','HorizontalAlignment','Left');


% Diapositivas de contenido

for i = 1:size(list, 1)
    
    % Tipo de slide
    exportToPPTX('addslide','Master',1,'Layout','En blanco');
    
    % Imagen
    exportToPPTX( ...
            'addpicture', ...
            fullfile( ...
                list_path, ...
                regexp(list(i, :), '^(\S*)(?=\s|$)', 'match', 'once') ...
            )...
    );
end
