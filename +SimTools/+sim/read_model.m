function MODEL = read_model(MODEL, varargin)
% read_model  Lee el modelo, le asigna los parámetros y resuelve el estado
% estado estacionario.
%{
% ## Syntax ##
%
%     MODEL = read_model(MODEL)
%
% ## Input Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura con los nombres del archivo `.mod`, archivo `.m` con
% parámetros y `.csv` con los datos.
%
%
% ## Options ##
%
% * ParamAssignName = {} [ `cell` ] - Nombre de los parámetros a modificar
% en el readmodel.m.
%
% * ParamAssignValue = [] [ `double` ] - Valores de los parámetros a
% modificar definidos anteriormente.
%
% * ParamExtraAssign = [] [ cell ] - Condiciones adicionales que deben ser
% reevaluadas dada la estructura del readmodel.m. Se definen como strings
% dentro del cell.
%
% ## Output Arguments ##
%
% __`MODEL`__ [ struct ] - 
% Estructura con el modelo. 
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
    addParameter(p, 'ParamAssignName', {});
    addParameter(p, 'ParamAssignValue', []);
    addParameter(p, 'ParamExtraAssign', {});
parse(p, varargin{:});
params = p.Results; 

% Se verifica que la cantidad de nombres de parámetros a reasignar sea la
% misma que la cantidad de valores. ---------------------------------------

if ~(length(params.ParamAssignName) == length(params.ParamAssignValue))
    error('La cantidad de nombres de parámetros no coincide con la cantidad de valores.')
end

% Asignación de parámetros a la estructura `s`. ---------------------------

run(MODEL.param_file_name);

% Reasignación de parámetros. ---------------------------------------------

if isempty(params.ParamAssignName) && isempty(params.ParamAssignValue)
    disp('No se modifican los parámetros del redmodel.m')
elseif isempty(params.ParamAssignName) || isempty(params.ParamAssignValue)
    warning('ParamAssign vacío en nombres o valores.')
else
    for i = 1:length(params.ParamAssignName)
        eval(...
            sprintf('s.%s = %f;', ...
                params.ParamAssignName{i}, ...
                params.ParamAssignValue(i) ...
            )...    
        );
    end
end

% Reevaluación de restricciones extra. ------------------------------------

if ~isempty(params.ParamExtraAssign)
    disp('Existen restricciones extra a los parámetros reasignados.')
    for i = 1:length(params.ParamExtraAssign)
        eval(params.ParamExtraAssign{i})
    end
end

% Asignación de parámetros al modelo, solución del estado estacionario. ---

M = model(MODEL.mod_file_name, 'assign', s);
M = sstate(M,'growth=',true,'MaxFunEvals',1000,'display=','off');

[flag,discrep,eqtn] = chksstate(M);

if flag
    disp("El estado estacionario calculado tiene una discrepacia aceptable")
    disp("respecto al estado estacionario impuesto.")
else
    warning("El estado estacionario calculado discrepa del impuesto.")
end

M = solve(M,'error=',true);

MODEL.M = M;

end