function plot_data_table(rng, y, varargin)

% plot_data_table grafica una tabla con los datos especificados en los
% argumentos.
%{
% ## Syntax ##
%
%    plot_data_table(rng, y, varargin)
%
% ## Input Arguments ##
%
% __`rng`__ [ DateWrapper ] -
% Rango de fechas a colocar en la tabla.
%
% __`y`__ [ array ] -
% Matriz donde cada columna corresponde a una serie diferente a graficar.
%
% ## Options ##
%
% * SeriesNames = [ cell ] - Nombre de las series a graficar..
%
% * DatesName = [ `String` ] - Nombre de la fila con las fechas.
%
% * NumFormat = '%0.2f' [String] - Decimales a colocar en la tabla.
%
% * FontSize = 12 [ integar ] - Tamaño de la fuente.
%
% * Parent = '' [Handle] - Nombre de la figura padre.
%
% * BackgroundColor = [1, 1, 1] [Array] Vector rgb para color de fondo de
% la tabla.
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
% --- TEST ----
% rng = qq(2020,4):qq(2021,4);
% y = rand(length(rng), 3);
% varargin = {};

 p = inputParser;
    addParameter(p, 'SeriesNames', arrayfun(@(x) {sprintf('Serie %i', x)}, 1:size(y, 2)));
    addParameter(p, 'DatesName', 'Fechas')
    addParameter(p, 'NumFormat', '%0.2f')
    addParameter(p, 'FontSize', 11)
    addParameter(p, 'FontName', 'Arial')
    addParameter(p, 'Parent', '')
    addParameter(p, 'ColNameWidth', 0.4)
    addParameter(p, 'BackgroundColor', [1, 1, 1])
    addParameter(p, 'TextColor', ...
        SimTools.from_stack_exchange.distinguishable_colors( ...
            size(y, 2), ...
            'w', ...
            @(x) SimTools.from_stack_exchange.colorspace('RGB->Lab',x)))
parse(p, varargin{:});
params = p.Results;  

% Defining layout constants - change to adjust 'look and feel'
% The names of the tests
DatesNames = dat2str(rng);
% Number of test columns
NumTests = length(DatesNames);
NumRows = 1 + size(y, 2);      % Total number of rows - header (1) + number of results (m)
TopMargin = 0.05; % Margin between top of figure and title row
BotMargin = 0.20; % Margin between last test row and bottom of figure
LftMargin = 0.03; % Margin between left side of figure and Computer Name
RgtMargin = 0.03; % Margin between last test column and right side of figure
CNWidth = params.ColNameWidth;  % Width of Computer Name column
MidMargin = 0.03; % Margin between Computer Name column and first test column
HBetween = 0.005; % Distance between two rows of tests
WBetween = 0.015; % Distance between two columns of tests
% Width of each test column
TestWidth = (1-LftMargin-CNWidth-MidMargin-RgtMargin-(NumTests-1)*WBetween)/NumTests;
% Height of each test row
RowHeight = (1-TopMargin-(NumRows-1)*HBetween-BotMargin)/NumRows;
% Beginning of first test column
BeginTestCol = LftMargin+CNWidth+MidMargin;

if isempty(params.Parent)
    fig = figure('menubar','none', ...
        'numbertitle','off',...
        'BackgroundColor', params.BackgroundColor);
else
    fig = params.Parent;
end

ax = axis;
axis off
% Create headers

% Computer Name column header
uicontrol(fig,'Style', 'text', 'Units', 'normalized', ...
    'Position', [LftMargin 1-TopMargin-RowHeight CNWidth RowHeight],...
    'String',  params.DatesName, ...
    'Tag', 'Computer_Name', ...
    'FontWeight','bold', ...
    'FontSize', params.FontSize, ...
    'BackgroundColor', params.BackgroundColor);

% Test name column header
for k=1:NumTests
    uicontrol(fig,'Style', 'text', 'Units', 'normalized', ...
        'Position', [BeginTestCol+(k-1)*(WBetween+TestWidth) 1-TopMargin-RowHeight TestWidth RowHeight],...
        'String', DatesNames{k}, ...
        'FontWeight', 'bold', ...
        'FontSize', params.FontSize, ...
        'FontName', params.FontName, ...
        'BackgroundColor', params.BackgroundColor);
end
% For each computer
for k=1:NumRows-1
    VertPos = 1-TopMargin-k*(RowHeight+HBetween)-RowHeight;
    % Computer Name row header
    uicontrol(fig,'Style', 'text', 'Units', 'normalized', ...
        'Position', [LftMargin VertPos CNWidth RowHeight],...
        'String', params.SeriesNames{k}, ...
        'HorizontalAlignment', 'center', ...
        'FontSize', params.FontSize, ...
        'FontName', params.FontName, ...
        'FontWeight', 'bold', ...
        'BackgroundColor', params.BackgroundColor ,...
        'ForegroundColor', params.TextColor(k, :));%, ...'ForegroundColor', thecolor
        
    % Test results for that computer
    for n=1:NumTests
        temp_str = sprintf(params.NumFormat,y(n, k));
        if strcmp('NaN', temp_str)
            temp_str = '-';
        end
        uicontrol(fig,'Style', 'text', 'Units', 'normalized', ...
            'Position', [BeginTestCol+(n-1)*(WBetween+TestWidth) VertPos TestWidth RowHeight],...
            'String', temp_str, ...
            'FontSize', params.FontSize, ...
            'FontName', params.FontName, ...
            'BackgroundColor', params.BackgroundColor, ...
            'ForegroundColor', params.TextColor(k, :));
    end
end

end

