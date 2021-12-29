function die_pausaGuarda(nombre_grafica, varargin)

% die_pausaGuarda guarda la gráfica luego de hacer una pausa para posible
% modifiaciones.
%{
% ## Syntax ##
%
%     die_pausaGuarda(nombre_grafica)
%
% ## Input Arguments ##
%
% __`nombre_grafica`__ [ struct ] -
% Nombre de la gráfica que indica el directorio donde se guardará.
%
% ## Options ##
%

% para graficar en la tabla.
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
    addParameter(p, 'AutoSave', false);
parse(p, varargin{:});
params = p.Results;

if ~params.AutoSave
% Permite ingresar estilo tipo LaTeX en el título del mensaje.
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = '';%'modal';

caja_mensaje = msgbox( ...
    {'\bf\fontname{Segoe UI}\fontsize{20}1. Modifique la gráfica';'2. Presione OK'}, ...
    'Ayuda', ...
    'help', ...
    CreateStruct ...
    );

caja_mensaje.Resize = 'on';

% Detiene la ejecución del código hasta que se presiona 'OK'.
uiwait(caja_mensaje);
end

saveas( ...
    gcf, ...
    nombre_grafica ...
);

close all

end
