classdef TimeTracker
    % Just a test. Not very practical at all, but anyways ...
    
    properties
       Ticcer {mustBeNumeric}
       TimeRemaining {mustBeNumeric}
       TimePerImage
       ImageCount  {mustBeNumeric}
       ExtraTime {mustBeNumeric}
    end
    methods
        
        function obj = Initiate(obj, iterations, extratime)
             obj.TimePerImage = nan(1,iterations);
             obj.ImageCount = iterations;
             obj.ExtraTime = extratime;
        end
        
        function obj = StartIteration(obj)
            obj.Ticcer = tic;
        end
        
        function [obj, remaining] = EndIteration(obj)
            firstnan = find(isnan(obj.TimePerImage), 1, 'first');
            obj.TimePerImage(firstnan) = toc(obj.Ticcer);
            if obj.ImageCount > 1
                obj.TimeRemaining = (obj.ImageCount-firstnan)*mean(obj.TimePerImage, 'omitnan') + obj.ExtraTime;  % 1.6 for rest of code.
                if obj.TimeRemaining < 90 && obj.TimeRemaining > 1
                    remaining = append('Estimated time remaining: ', num2str(round(obj.TimeRemaining)), ' seconds.');
                elseif obj.TimeRemaining > 1
                    remaining = append('Estimated time remaining: ', num2str(round(obj.TimeRemaining/60)), ' minutes.');
                else
                    remaining = 'Done any second now ...';
                end
            else
                remaining = [];
            end
        end
    end
end