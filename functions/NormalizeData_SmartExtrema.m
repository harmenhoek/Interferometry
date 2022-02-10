function y_normalized = NormalizeData_SmartExtrema(y, averagepoints)
    if averagepoints > 1 && length(y) > averagepoints
        y_sorted = sort(y); %SLOW
        y_min = median(y_sorted(1:averagepoints),'omitnan');
        y_max = median(y_sorted(find(~isnan(y_sorted), averagepoints, 'last'))); %exlude nans
    else
        y_min = min(y);
        y_max = max(y);
    end
    y_normalized = (y-y_min)/(y_max-y_min);
    if averagepoints > 1
        y_normalized(y_normalized<0) = min(y); %if average_extrema
        y_normalized(y_normalized>1) = max(y); %if average_extrema
    end
end