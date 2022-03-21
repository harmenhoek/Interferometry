function [c, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, Settings, c)
    %% Processing
    
    % The last term defines the length of the slice. This is needed since 
    % there is a bug in MATLAB. If not specified, the slice will be of an 
    % arbitrary length. Not that the GUI (improfile without output) does
    % give the correct slice length.
    % intensity = improfile(I, x_all, y_all, slice_length), where
    % length(intensity) is slice length.

    % 24-1-2022 => added split smoothing and peak fit Settings.PeakFitSettings. So slice
    % can have different slice Settings.PeakFitSettings for inside (a) and outside (b).
    % 24-1-2022 => Implemented Settings.PeakFitSettings struct. Settings.PeakFitSettings are passed in 
    % function with Settings.PeakFitSettings.a.MinPeakProminence, etc.

    % Important note: function works from outside to inside! That's why a
    % and b are so confusingly used here. Better would be to rewrite
    % function to work from inside to outside ...

    if ~exist('c', 'var')
        c = improfile(I, roi(:,1), roi(:,2), norm(roi(1,:)'-roi(2,:)'));
    end
    c(1:10) = nan;
    c(end-10:end) = nan;
    
    % check if splitting is possible if CutOff isset.
    if Settings.PeakFitSettings.CutOff && Settings.PeakFitSettings.CutOffValue > length(c)
        Logging(1, append('The CutOff value (', num2str(Settings.PeakFitSettings.CutOffValue), ') for peak fitting is bigger than the total slice length (', num2str(length(c)), ').'))
    elseif Settings.PeakFitSettings.CutOff && strcmpi(Settings.SliceType, 'sector')
        Settings.PeakFitSettings.CutOffValue = length(c) - Settings.PeakFitSettings.CutOffValue;
    end
    c_nor = (c-min(c))/(max(c)-min(c));
    
    if Settings.PeakFitSettings.CutOff
        c_nor_a = smoothdata(c_nor(1:Settings.PeakFitSettings.CutOffValue), 'gaussian', Settings.PeakFitSettings.b.Smoothing);
        c_nor_b = smoothdata(c_nor(Settings.PeakFitSettings.CutOffValue+1:end), 'gaussian', Settings.PeakFitSettings.a.Smoothing);
        c_nor = [c_nor_a; c_nor_b];
    else
        c_nor = smoothdata(c_nor, 'gaussian', Settings.PeakFitSettings.a.Smoothing);
    end
    
    
    % catch really short slices
    if length(c_nor) < 50  % TODO find a nicer way to catch these things
        pks = [];
        pks_locs = [];
        mns = [];
        mns_locs = [];
    else
        % MinPeakDistance, MinPeakHeight (only above y-value x), Threshold (higher 
        % than x from points around), MinPeakProminence (drops at least x till next
        % peak)

        if Settings.PeakFitSettings.CutOff
            
            %inside
            [pks_b, pks_locs_b] = findpeaks(c_nor_b, ...
            'MinPeakProminence', Settings.PeakFitSettings.a.MinPeakProminence, ...
            'MinPeakDistance', Settings.PeakFitSettings.a.MinPeakDistance ...
            );
            [mns_b, mns_locs_b] = findpeaks(-c_nor_b, ...
            'MinPeakProminence', Settings.PeakFitSettings.a.MinPeakProminence, ...
            'MinPeakDistance', Settings.PeakFitSettings.a.MinPeakDistance ...
            );
        
            % The first maxima or minima of part b (outside) is not taken
            % into account if it's too close to the start
            % (MinPeakProminance excludes it then). To fix this, we include
            % extra data in part b: up to the first extrema in part a. We
            % then have to resmooth the data. Still not perfect, but it
            % finds the first extrema.
            if Settings.PeakFitSettings.CutOffIncludeMargin && ~isempty(pks_locs_b) && ~isempty(mns_locs_b)
                first_peak = min([pks_locs_b(1); mns_locs_b(1)]) + length(c_nor_a);
                c_nor_a = smoothdata(c_nor(1:first_peak), 'gaussian', Settings.PeakFitSettings.b.Smoothing);
                c_nor_b =  smoothdata(c_nor(first_peak+1:end), 'gaussian', Settings.PeakFitSettings.a.Smoothing);
                c_nor = [c_nor_a; c_nor_b];
            end
            
            %outside
            [pks_a, pks_locs_a] = findpeaks(c_nor_a, ...
            'MinPeakProminence', Settings.PeakFitSettings.b.MinPeakProminence, ...
            'MinPeakDistance', Settings.PeakFitSettings.b.MinPeakDistance ...
            );
            [mns_a, mns_locs_a] = findpeaks(-c_nor_a, ...
            'MinPeakProminence', Settings.PeakFitSettings.b.MinPeakProminence, ...
            'MinPeakDistance', Settings.PeakFitSettings.b.MinPeakDistance ...
            );
        
            pks = [pks_a; pks_b];
            pks_locs = [pks_locs_a; pks_locs_b+Settings.PeakFitSettings.CutOffValue];
            mns = [mns_a; mns_b];
            mns_locs = [mns_locs_a; mns_locs_b+Settings.PeakFitSettings.CutOffValue];
        else
            [pks, pks_locs] = findpeaks(c_nor, ...
                'MinPeakProminence', Settings.PeakFitSettings.a.MinPeakProminence, ...
                'MinPeakDistance', Settings.PeakFitSettings.a.MinPeakDistance ...
                );
            
            [mns, mns_locs] = findpeaks(-c_nor, ...
                'MinPeakProminence', Settings.PeakFitSettings.a.MinPeakProminence, ...
                'MinPeakDistance', Settings.PeakFitSettings.a.MinPeakDistance ...
                );
        end
    end

%% CHECKS

    % catch if no peaks or mins are found
    if isempty(mns) && ~isempty(pks)
        d_final = nan;
        pks_locs = nan;
        mns_locs = nan;
        pks = nan;
        mns = nan;
        return
    end % if ~isempty(mns) && ~isempty(pks)


%% Extra processing

    % 23-11-2021: BELOW SHOULD BE REMOVED. There is no real min,max. We
    % should 
%     if pks_locs(end) < mns_locs(end)  % add min or max to last datapoint
%         pks_locs = [pks_locs; length(c)];
%         pks = [pks; c_nor(end)];
%     else
%         mns_locs = [mns_locs; length(c)];
%         mns = [mns; -c_nor(end)];
%     end
    
    pks = flip(pks); pks_locs = flip(pks_locs); 
    mns = flip(mns); mns_locs = flip(mns_locs); 

%% Fitting with model


    d_all = cell(1, length(pks_locs) + length(mns_locs) - 2);

    locs = [pks_locs; mns_locs];
    extr = [pks; mns];
    [locs, idx] = sort(locs);
    extr = extr(idx);
    locs = flip(locs);
    extr = flip(extr);
    
    if isempty(extr)
        d_final = nan;
        return
    end

    for i = 1:length(extr)-1      
        x1 = locs(i+1);
        x2 = locs(i);
    
        y = c_nor(x1:x2);

        y_nor = NormalizeData_SmartExtrema(y, Settings.Stitching_AveragePoints);
    
        d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
        d_all{i} = d(2:end);
    end


    %% Fitting first and last section
    % This is tricky. In the ideal world the intensity of each maximum and
    % minimum of the intereferometry pattern is equal (0 or 1). But this is
    % not the case in reality. Therefore we have to find the peaks in the
    % spectrum, and fit the model to the normalized dataet between each
    % extrema.
    % This does not work for the first and last dataset (before first
    % extrema and after last extrema), since we have no idea what the
    % intensity of the actual maximum (out of frame) is going to be. Safest
    % approach is to skip these sections (Settings.EstimateOutsides = false), an
    % estimation can be made (Settings.EstimateOutsides = true) by assuming the
    % extrema of this section is the average of the extrema that are
    % visible.
    % Note: it happens that the first or last datapoint is actual greater
    % than the average extrema. In that case we assume it to be a real
    % extrema and treat it like any other extrema.

    if Settings.EstimateOutsides && length(extr) > 1

        min_avg = -mean(mns);
        max_avg = mean(pks);
    
        % fit from START to first extrema
        x = 1:locs(end);
        y = c_nor(x);  % intensity
        %x_nor = x-x(1); % is already the case? copied from above. Check!
        y_nor = NormalizeData_SmartExtrema(y, Settings.Stitching_AveragePoints);
        [y_start, y_end] = GetMedians(y, 10);
        
        if y(1) < y(end) % increasing dataset (to first max)
            if y_start < min_avg % start value is actual lower than avg. Assume it's a real min
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "START increasing, actual minimum")
            else
                % the actual min is not in our data. thus instead of scaling
                % from 0-1 we need to scale from b to 1, where b is the difference
                % between the estimated actual min (min_avg) and our min
                % (abs(min(y)-min_avg)).
                b = abs(min(y)-min_avg);
                y_nor = y_nor*(1-b)+b;
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "START increasing, estimated minimum")
            end
        else % decrease
            if y_end > max_avg % end value is actual higher than avg. Assume it's a real max
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "START decreasing, actual maximum")
            else
                % the actual max is not in our data. thus instead of
                % scaling from 0-1 we scale from 0 to 1-b, where be is the
                % difference between the estimated actual max (max_avg) and
                % our max (abs(max(y)-max_avg)).
                b = abs(max(y)-max_avg); % NOT TESTED ... No dataset ...
                y_nor = y_nor*(1-b);
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                Logging(6, "START decreasing, estimated maximum")
            end
        end
%         d = flip(-d+max(d));
        d_all = [d_all, {d}];
        clear x y x_nor y_nor d b
    
        % fit last extrema to END
        x = 1:(length(c)-locs(1));
        y = c_nor(x);
        %x_nor = x-x(1); % is already the case? copied from above. Check!
        y_nor = NormalizeData_SmartExtrema(y, Settings.Stitching_AveragePoints);
        [~, y_end] = GetMedians(y, 10);

        if y(1) < y(end) % increasing dataset (to end)
            if y_end > max_avg % last value is actual larger than avg. Assume it's a real max
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "END start increasing, actual maximum")
            else
                % the actual max is not in our data. thus instead of
                % scaling from 0-1 we scale from 0 to 1-b, where be is the
                % difference between the estimated actual max (max_avg) and
                % our max (abs(max(y)-max_avg)).
                b = abs(max(y)-max_avg); 
                y_nor = y_nor*(1-b);
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "END start increasing, estimated maximum")
            end
        else % decrease
            if y_end < min_avg % last value is actual lower than avg. Assume it's a real min
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "END start decreasing, actual minimum")
            else
                % the actual min is not in our data. thus instead of
                % scaling from 0-1 we scale from b to 1, where be is the
                % difference between the estimated actual min (min_avg) and
                % our max (abs(min(y)-min_avg)).
                b = abs(min(y)-min_avg);
                y_nor = y_nor*(1-b)+b;
                d = ModelFit(y_nor, Settings.Lambda_Corrected, Settings.HeightResolution);
                 Logging(6, "END start decreasing, estimated minimum")
            end 
        end
        d = flip(-d+max(d));
%         d = flip(d);
        d_all = [{d}, d_all];
        clear x y x_nor y_nor d b y_start y_end

    else  % skip estimating the first and last section, instead add nans
        
        d_pre = nan(1, length(c)-locs(1));
        d_all = [{d_pre}, d_all];

        d_post = nan(1, locs(end));
        d_all = [d_all, {d_post}];

    end

   
    
    %% Stitching data together.
    
    %updated: 3-2-2022
    lastvalues = cumsum(cellfun(@(x) median(x(find(~isnan(x), 1, 'last'))), d_all), 'omitnan'); %exlude nans
    for i=2:length(d_all)
        d_all{i} = d_all{i} + lastvalues(i-1);
    end
    d_final = cell2mat(d_all);
    
    %% Flipping data
    % We want distance=0 to be center of the image. TODO test if it works
    % for slices DOWN!
    
    d_final = -d_final + max(d_final);
    
    c = flip(c);
    c_nor = flip(c_nor);
    
    pks_locs = -pks_locs + length(c);
    mns_locs = -mns_locs + length(c);
        
   

end % function ProfileSLice