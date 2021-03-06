function [status] = CheckIfClass(checkclass, variables)
% CheckIfClass  Checks if the input variables (cell with variables as
% strings) are all of the type checkclass ('logical', 'char' or 'numeric').
%   [status] = CheckIfClass(checkclass, variables) 
% Displays to screen the variables that are do not satisfy the checkclass
% and returns 'status' which is 0 if checks fail (this allows to see a list
% of all variables that need to be fixed.

% Function needs Logging.m!

% Example:
%   variable1 = 'This is a string';
%   variable2 = true;
%   variable3 = 34.53;
%   [status] = CheckIfClass('logical', {'variable1', 'variable2', 'variable3'})
% Result:
%   WARNING   Variable "variable1" should be logical, but is not (currently a char).
%   WARNING   Variable "variable3" should be logical, but is not (currently a double).
%   status =
%       0

    status = 1;
    for i = 1:length(variables)
        variable = variables{i};
        if strcmp(checkclass, 'logical')
             if ~islogical(evalin('base', variable))
                status = 0;
                Logging(3, append('Variable "', variable, '" should be logical, but is not (currently a ', num2str(class(evalin('base', variable))) ,').'));
            end
        elseif strcmp(checkclass, 'numeric')
            if ~isnumeric(evalin('base', variable))
                status = 0;
                Logging(3, append('Variable "', variable, '" should be numeric, but is not (currently a ', num2str(class(evalin('base', variable))) ,').'));
            end
        elseif strcmp(checkclass, 'char')
            if ~ischar(evalin('base', variable))
                status = 0;
                Logging(3, append('Variable "', variable, '" should be char, but is not (currently a ', num2str(class(evalin('base', variable))) ,').'));
            end
        else
            Logging(1, 'Class not supported. Choose "numeric", "logical" or "char"')
        end
    end
end