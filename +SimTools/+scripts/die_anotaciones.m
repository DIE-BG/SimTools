function die_anotaciones(posicionX, posicionY, nota, varargin)

% die_anotaciones coloca anotaciones se�alando a los puntos dados en los
% argumentos.
%{
% ## Syntax ##
%
%    die_anotaciones(posicionX, posicionY, nota, varargin)
%
% ## Input Arguments ##
%
% __`posicionX`__ [ array ] -
% Debe contener las corrdenadas en x del punto a se�alar.
%
% __`posicionY`__ [ array ] -
% Debe contener las corrdenadas en y del punto a se�alar.
%
% nota [ cell ] -
% Debe contener los strings con las anotaciones..
%
% ## Options ##
%
% * Color = 'k' [ array|string ] - Color de las anotaciones.
%
% * FontSize = 12  [ `integer` ] - Tama�o de la letra.
%
% * FontWeight = 'b' [String] - Peso de la fuente.
%
% * Container = gcf [Handle] - Nombre de la figura en donde se colocar�n
% las etiquetas.
%
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
    addParameter(p, 'Color', 'k');
    addParameter(p, 'FontSize', 10);
    addParameter(p, 'FontWeight', 'b');
    addParameter(p, 'Container', gcf);
    addParameter(p, 'IsAnt', false);
    addParameter(p, 'XAdjustment', 0);
    addParameter(p, 'YAdjustment', 0);
parse(p, varargin{:});
params = p.Results; 

x = get(gca, "XLim");

y = get(gca, "YLim");

axis_pos = get(gca, "Position"); % [xMin,yMin,xExtent,yExtent]


% Conversi�n de posiciones
note_x = axis_pos(1) + ((posicionX - x(1))/(x(2)-x(1))) * axis_pos(3);

note_y = axis_pos(2) + ((posicionY - y(1))/(y(2)-y(1))) * axis_pos(4);

for i = 1:length(nota)
    %{
    Colocaci�n de todas las anotaciones en la gr�fica. Si el elemento a
    etiquetar est� antes de la mitad del gr�fico, la etiqueta se pone del lado
    derecho del elemento. 
    %}
    if params.IsAnt
        note = annotation(params.Container, ...
                "textarrow", ...
                [note_x(i) + 0.02, note_x(i)+params.XAdjustment], ...
                [note_y(i) - 0.02, note_y(i)+params.YAdjustment] ...
            );
    else
        note = annotation(params.Container, ...
                "textarrow", ...
                [note_x(i) + 0.02, note_x(i)+params.XAdjustment], ...
                [note_y(i) + 0.02, note_y(i)+params.YAdjustment] ...
            );
    end
    
    note.String = nota(i);
    
    % Formato de etiquetas
    note.Color = params.Color;
    note.FontSize = params.FontSize;
    note.FontWeight = params.FontWeight;
    
end

end