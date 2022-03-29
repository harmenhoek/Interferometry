function [pks, pks_locs, mns, mns_locs] = ManualPeakCorrections(y, pks, pks_locs, mns, mns_locs)
    % This function allows to manually correct extrema. A plot is shown with the extrema on it. User can then delete and
    % moving existing points, or add new extrema.

    % 29-3-2022 Harmen Hoek

    Logging(5, 'Manual Peak finiding correction started.')
   

    f = figure('visible', 'on');
    h = gca;
    hold on
    plot(y)
    
    rois_pks = cell(1, length(pks));
    rois_mns = cell(1, length(mns));

    for i = 1:length(pks)
        rois_pks{i} = drawpoint(gca, 'Position', [pks_locs(i), pks(i)], 'Color', 'green');
    end

    for i = 1:length(mns)
        rois_mns{i} = drawpoint(gca, 'Position', [mns_locs(i), -mns(i)], 'Color', 'blue');
    end

    Logging(2, 'Drag around existing extrema, right click to delete.')

    con = 1;
    while con
        Logging(2, 'Press "a" to add a MAXima  |  any other key to continue to MINima selection.')
        x = input('', 's');
        if strcmpi(x, 'a')
            Logging(5, 'Select a new maxima in the plot now.')
            rois_pks{end+1} = drawpoint(h, 'Color', 'green');
            Logging(5, 'Maxima added.')
        else
            con = 0;
        end
    end

    con = 1;
    while con
        Logging(2, 'Press "a" to add a MINima  |  any other key to continue.')
        x = input('', 's');
        if strcmpi(x, 'a')
            Logging(5, 'Select a new minima in the plot now.')
            rois_mns{end+1} = drawpoint(h, 'Color', 'blue');
            Logging(5, 'Minima added.')
        else
            con = 0;
        end
    end

    valid_pks = cellfun(@(x) isvalid(x), rois_pks);
    pks_locs = cell2mat(cellfun(@(x) round(x.Position(1)), rois_pks(valid_pks == 1), 'UniformOutput', false))';
    pks = cell2mat(cellfun(@(x) x.Position(2), rois_pks(valid_pks == 1), 'UniformOutput', false))';

    valid_mns = cellfun(@(x) isvalid(x), rois_mns);
    mns_locs = cell2mat(cellfun(@(x) round(x.Position(1)), rois_mns(valid_mns == 1), 'UniformOutput', false))';
    mns = cell2mat(cellfun(@(x) -x.Position(2), rois_mns(valid_mns == 1), 'UniformOutput', false))';
   
    close(f)

    Logging(5, 'Manual Peak finiding correction completed successfully.')

    % TODO: show points changes, deleted and added.

end