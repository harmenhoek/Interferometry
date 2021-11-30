function [y_start, y_end] = GetMedians(y, max_samples)

    if length(y) <= max_samples
        y_start = y(1);
        y_end = y(end);
    else
        y_start = median(y(1:max_samples));
        y_end = median(y(end-max_samples:end));
    end
end