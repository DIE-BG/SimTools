%% Presentación Sector Fiscal

disp("Generando presentación")

tdy = datetime();
tdy.Format = "dd-MMM-uuuu HH_mm_ss";

%% Start new presentation
isOpen  = exportToPPTX();
if ~isempty(isOpen)
    % If PowerPoint already started, then close first and then open a new one
    exportToPPTX('close');
end

exportToPPTX('open',fullfile('scripts', 'presentaciones', 'dieTemplate.pptx'));

%% Diapositiva de título
exportToPPTX('addslide','Master',1,'Layout','Diapositiva de título');
exportToPPTX('addtext','**SVAR01_10**','Position','Title');
exportToPPTX('addtext','Departamento de Investigaciones Económicas    Banco de Guatemala','Position','Subtitle',...
              'HorizontalAlignment','center');
exportToPPTX('addtext',sprintf('%s', string(datetime())),...
             'HorizontalAlignment','center', ...
             'Position',[0 5.75 13.33 0.5]);

%% Diapositivas de contenido

% ppt_trans_eq
% tabla_parametros
ppt_impulse_response
ppt_prediction
ppt_var_dsc_rel
ppt_shd_dsc


%% Save
exportToPPTX( ...
    'save', ...
    fullfile( 'notebooks', ...
        'SVAR01_10.pptx' ...
    ) ...
);

disp("Presentación finalizada y almacenada");