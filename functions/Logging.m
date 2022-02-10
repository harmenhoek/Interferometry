function Logging(type, message)
% LOGGING  Log message to the screen with correct formatting.
%   LOGGING(type, message) Log a message of type to the screen. Where
% type is one of:
% 1 -> 'ERROR';     -> Code cannot continue.
% 2 -> 'ACTION';    -> User needs to do something.
% 3 -> 'WARNING';   -> Code can continue, but user should note something (decision made by code e.g.).
% 4 -> 'PROGRESS';  -> Show user that something is being done now, e.g. when wait is long.
% 5 -> 'INFO';      -> Information about code progress. E.g. 'Figures are being saved'.
% 6 -> 'OK';        -> Just to show progress is going on as planned.
%
% To set the LogLevel, set global variable LogLevel, like:
%   global LogLevel
%   LogLevel = 3
% All messages with type of <= 3 will be shown, i.e. ERRORs, ACTIONs and
% WARNINGs.

    global LogLevel
    LogTypes = {...
        1, 'ERROR',     'red';      % Code cannot continue.
        2, 'ACTION',    '_blue';    % User needs to do something.
        3, 'WARNING',   [1 .65 0];  % Code can continue, but user should note something (decision made by code e.g.).
        4, 'PROGRESS',  'white';    % Show user that something is being done now, e.g. when wait is long.
        5, 'INFO',      'cyan';     % Information about code progress. E.g. 'Figures are being saved'.
        6, 'OK',        'green';    % Just to show progress is going on as planned.
    }; 

    if isempty(LogLevel)
        global LogLevel
        LogLevel = 1;
        fprintf('WARNING   LogLevel was undefined, set to 1. To define set before using LogLevel: \n global LogLevel \n LogLevel = 4; \n')
    end
    
    if ~isa(type, 'double') || ~ismember(type, cell2mat(LogTypes(:,1)))
        error(append('"', num2str(type), '"', ' is not an integer or not a valid interger. Supported values are "', num2str(cell2mat(LogTypes(:,1)')), '"'))
    end
    
    if ~isa(message, 'char') && ~isa(message, 'string')
        error(append('"', num2str(message), '"', ' should be a string.'))
    end
    
    if type == 1 && LogLevel >= type  % show actual error when error
        error(append( ...
            pad(LogTypes{type, 2}, 10), ... % pad to length 10 (trailing spaces)
            regexprep(message, '%', '%%') ...
            ))
        return
    end

    if LogLevel >= type
        fprintf(pad(LogTypes{type, 2}, 10))
        fprintf(append( ... % pad to length 10 (trailing spaces)
            regexprep(message, '%', '%%'), ...
            '\n' ...
            ))

% 03-01-2022 fprintf is broken as of MATLAB 2021b. No fixavailable.
%         cprintf(LogTypes{type, 3}, pad(LogTypes{type, 2}, 10))
%         cprintf('white', append( ... % pad to length 10 (trailing spaces)
%             regexprep(message, '%', '%%'), ...
%             '\n' ...
%             ))
        
        
        
%         fprintf(append( ...
%             pad(LogTypes{type, 2}, 10), ... % pad to length 10 (trailing spaces)
%             regexprep(message, '%', '%%'), ...
%             '\n' ...
%             ))
    end

end