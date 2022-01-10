clc; clear all;

%% ABOUT

%% TODO

%{
- Overlay slices on surface plot
- Overlay image (transparent almost) on surface plot
- Comment HeightProfileForSlice function
- In HeightProfileForSlice improve peak fitting
- Multiple image processing, including interferometry of starting point.


FIXES TODO
- Slice plot: length of height profile wrong. AND it is flipped.
- Prevent average slice if sector >180 deg and img_cntr is not centered
(perhaps compare length of slice deviation).
- What if PlotSingleSlice does not have extrema?!
- Alignment of contour on image, espcially when sector is selected.
- Show image sector above average slice (covert to radial coordinates).

%} 


%% INPUT
% Mandatory input is filename, the interferometry image.
% Additionally the variable img_cntr = [x0, y0] can be set witht the center
% of the interferometry pattern (x0,y0) (heighest point in image). If this
% variable is not set, a GUI allows you to select it.

% filename = 'data\fc2_save_2021-10-20-145841-0667.tif';
% img_cntr = 1e3 * [1.9823, 0.8367];

filename = 'data\100-3h-11102021102024-0.tiff';
img_cntr = 1e3 * [1.3635, 2.9930];


%% SETTINGS

Lambda = 530e-9;                        % Wavelength of light in meters.

NumberSlices = 300;                     % Total number of radial slices in the full 2pi
AnalyzeSector = true;                   % If true, only a sector (between SectorStart and SectorEnd) of the full 2pi will be analyzed.
    SectorStart = pi + pi/2 - pi/16;    % Cloclwise from 3 o'clock. 
    SectorEnd = pi + pi/2 + pi/16;      % Note: beyond 3 o'clock not yet supported.

EstimateOutsides = true;               % If true, before first extrema and after last extrema will be estimated (see documentation).

FilterBy_AmountExtrema = false;         % TODO needs some work, when some slices are nan.
    AmountExtrema_MaxDeviation = 0.05;  % Kick out slice if number of extrema differs > this number from the average number of extrema of all slices.

HeightResolution = 2e-9;                % Resolution of model fitting. Minimal step size in end result is determined by this. 2nm is decent.

PlotSingleSlice = 4;                    % Show several analysis steps of a certain slice.
ShowHeightProfileProgress = true;       % Show progress of Height Profile calculation of all slices.

% Plotting
Plot_Average = true;                    % Calculate average multiple slices (consider analyzing only a quadrant).

% Saving
Save_Figures = true;
    Save_PNG = true;
    Save_TIFF = true;
    Save_FIG = true;
    Save_Folder = 'results';

ShowLogoAtStart = true;

global LogLevel
LogLevel = 6;  % Recommended at least 2. To reduce clutter use 5. To show all use 6.
%{
    1, 'ERROR';     % Code cannot continue.
    2, 'ACTION';    % User needs to do something.
    3, 'WARNING';   % Code can continue, but user should note something (decision made by code e.g.).
    4, 'PROGRESS';  % Show user that something is being done now, e.g. when wait is long.
    5, 'INFO';      % Information about code progress. E.g. 'Figures are being saved'.
    6, 'OK';        % just to show progress is going on as planned.
%}


%% 0 - Settings checks and ititialization

if ShowLogoAtStart
    clc
    ShowLogo
end

Logging(5, append('Code started on ', datestr(datetime('now')), '.'))

% Set default plotting sizes
set(0,'defaultAxesFontSize',15)

% Check if filename file is supported format
[~, ~, ext] = fileparts(filename);
if ~any(strcmp({'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp', '.gif'}, ext))
    Logging(1, 'File format not supported.')
end

status = CheckIfClass('numeric', {'Lambda', 'PlotSingleSlice', 'NumberSlices', 'SectorStart', 'SectorEnd'});
status2 = CheckIfClass('logical', {'AnalyzeSector', 'ShowHeightProfileProgress', 'FilterBy_AmountExtrema', 'Plot_Average', 'Save_Figures', 'Save_PNG', 'Save_TIFF', 'Save_FIG', 'ShowLogoAtStart'});
status3 = CheckIfClass('char', {'Save_Folder'});
if min([status, status2, status3]) == 0
    Logging(1, 'Could not continue because of invalid settings (see WARNINGs above).')
else
    Logging(6, 'Settings are all of the right type.')
end

% Check amount of slices
dtheta = 2*pi / NumberSlices;
if AnalyzeSector
    theta_all = (ceil(SectorStart/(2*pi)*NumberSlices):floor(SectorEnd/(2*pi)*NumberSlices)).*dtheta;
else
    theta_all = (1:NumberSlices).*dtheta;
end
if SectorEnd - SectorStart < 0
    Logging(1, 'Negative quadrants are not (yet) supported. quadrant_end > quadrant_start.')
end
if length(theta_all) < 1 || (length(theta_all) == 1 && isnan(theta_all))
    Logging(1, 'Amount of slices (slices) should at least be 1. Increase the slices or quadrant size.')
elseif length(theta_all) > 1000
    Logging(3, 'Amount of slices (slices) is extremely big and therefore completion may take long. Consider reducing the slices or quadrant size.')
end    
if length(theta_all) < PlotSingleSlice
    Logging(3, 'PlotSingleSlice is bigger than the amount of slices. No single slice data will be shown.')
end


% Check valid HeightResolution
steps = (Lambda/4) / HeightResolution;
maxres =  num2str(ceil((Lambda/4) / 5 *1e9));
minres =  num2str(ceil((Lambda/4) / 500*1e9));
if steps < 5
    Logging(1, strcat("HeightResolution too big, choose a value between ", minres, " and ", maxres, " nm."))
elseif steps > 500
    Logging(3, strcat("HeightResolution very small, this might signigicantly slow down the code, choose a value between ", minres, " and ", maxres, "nm."))
end


% Check Save_Folder
if Save_Figures
    if ~Save_PNG && ~Save_TIFF && ~Save_FIG
        Save_Figures = false;
        Logging(3, 'Save_PNG, Save_TIFF, Save_FIG are all set to false. No figures will be saved.')
    else
        [path, name, ~] = fileparts(filename);
        stamp = append('PROC',  datestr(now, 'YYYYmmddHHMMSS'));
        savefolder_sub = append(Save_Folder, '\', stamp);
        [status, msg] = mkdir(savefolder_sub);
        if status == 0
            Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub, '\', '\\'), '" failed! Error: ', msg))
        else
            Logging(5, append('Created folder for image saving "', strrep(savefolder_sub, '\', '\\'), '" successfully.' ))
        end

        basename = append(savefolder_sub, '\', name, '_', stamp);
    
        extensions = {'png', 'tiff', 'fig'};
        save_extensions = extensions([Save_PNG, Save_TIFF, Save_FIG]);
    end
end
%%
clear ext steps maxres minres status msg path name extensions savefolder_sub
Logging(6, 'Settings checked and all valid.')

%% 1 - Image loading

Logging(5, '-- 1/6 -- Image loading started.')

tic

I_or = imread(filename);
I = rgb2gray(I_or);
I = adapthisteq(I);

I_size(1) = size(I, 1);
I_size(2) = size(I, 2);

if ~exist('img_cntr')
    Logging(2, 'No image center given in settings, pick image center now.')
    f_temp = figure;
    imshow(I)
    pnt = drawpoint;
    img_cntr = pnt.Position;
    close(f_temp)
end

clear filename pnt
Logging(6, 'Image loaded successfully.')

%% 2 - Determine slices

Logging(5, '-- 2/6 -- Slice determining started.')


points = nan(length(theta_all), 2);

for k = 1:length(theta_all)
    theta = theta_all(k);
    points(k, :) = GetIntersectsImageBorder(img_cntr, theta, I_size);
    clear intersect_edge intersect_edge2 polangle idx theta
end


% Show slices

show_slices = true;

if show_slices   
    if exist('f1')
        figure(1)
        clf(f1)
    else
        f1 = figure(1);
    end
    imshow(I)
    hold on
    for k = 1:length(theta_all)
        pnt = points(k, :);
        roi = [pnt; img_cntr];
        plot(roi(:,1), roi(:,2), 'Color', 'red', 'LineWidth', 2)
        plot(pnt(:,1), pnt(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
        text(pnt(:,1), pnt(:,2), num2str(k))
        clear pnt roi
    end
    SaveFigure(Save_Figures, f1, save_extensions, append(basename, '_SlicesOverview'));
end % if show_slices

clear f1 f2 k dtheta savename
Logging(6, 'Slices determined successfully.')

%% 3 - Get HeightProfile for all slices

Logging(5, '-- 3/6 -- Height Profile calculations started.')

data_cell = cell(length(theta_all) ,1);
number_extrema = nan(length(theta_all), 2);
slice_lengths = nan(length(theta_all), 1);

no_height_profile = 0;
first_empty_row = 1;
for k = 1:length(points)  % iterate over all the end points (same length as all slices to analyze)
% for k=20
    if mod(k, round(length(theta_all)/10)) == 0 && ShowHeightProfileProgress
        Logging(5, append("Height Profile calculation of all slices at ", num2str(k/round(length(theta_all)/10)*10), '%.'))
    end
    pnt = floor(points(k, :));
    roi = [pnt; img_cntr];

    [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, Lambda, HeightResolution, EstimateOutsides);
    if isnan(d_final)
        no_height_profile = no_height_profile + 1;
    end
    number_extrema(k, 1:2) = [length(pks), length(mns)];
    slice_lengths(k) = length(c_or);

    [xx, yy] = fillline(img_cntr, pnt, length(d_final));
    if length(d_final) ~= 1
        data_cell{k} = [xx', yy', d_final'];
        first_empty_row = first_empty_row + length(xx);
    end

    

    
    % Plot one slice
    if k == PlotSingleSlice
        if exist('f4')
            figure(4)
            clf(f4)
        else
            f4 = figure(4);
        end
        
        tiledlayout(3,1,'TileSpacing','tight');
        
        c_l = 1:length(c_or);
        nexttile;
        plot(c_l, c_or, 'Color', 'red', 'LineWidth', 2)
        xlabel('Distance from center [pix]')
        ylabel('Intensity [arb. units]')
        xlim([0, max(c_l)])
        title(strcat('Original slice k=', num2str(k)))
        
        nexttile;
        line(c_l, c_nor, 'Color', 'red', 'LineWidth', 2)
        hold on
        plot(c_l(pks_locs), pks, '.', 'MarkerSize', 10, 'Color', 'black')
        plot(c_l(mns_locs), -mns, '.', 'MarkerSize', 10, 'Color', 'green')
        xlabel('Distance from center [pix]')
        ylabel('Intensity [arb. units]')
        xlim([0, max(c_l)])
        title('After img adjustments and normalization')
        
        nexttile;
%         plot((c_l(end)-length(d_final)+1):c_l(end), d_final.*1e6, 'Color', 'blue', 'LineWidth', 2)
        plot(c_l, d_final.*1e6, 'Color', 'blue', 'LineWidth', 2)
        xlabel('Distance from center [pix]')
        ylabel('Height [um]')
        xlim([0, max(c_l)])
        title('Height profile after model fit')


        SaveFigure(Save_Figures, f4, save_extensions, append(basename, '_Slice', num2str(k)));
    end % plotline
    
    clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns
%     clear d_final

end % points

if no_height_profile == length(points)
    Logging(1, 'No height profiles could be calculated for any of the slices. Check if slices are not to short')
elseif no_height_profile > 0
    Logging(3, append('A height profile could not be calculated for ', num2str(no_height_profile), '/', num2str(length(points)), ' slices.'))
else
    Logging(6, 'Height profiles could be calculated for all slices.')
end

clear k first_empty_row f4
Logging(6, 'Height profiles determined successfully for all slices.')

%% 4 - Filtering of HeightProfile data and Postprocessing of data

Logging(5, '-- 4/6 -- Filtering of HeightProfile data and Postprocessing of data started.')

% filter based on length of peaks
if FilterBy_AmountExtrema
    TotalExtrema = sum(number_extrema, 2);
    MedianExtrema = median(TotalExtrema);
    cntr = 0;
    for k=1:length(TotalExtrema)
        if abs(1-TotalExtrema(k)/MedianExtrema) >= AmountExtrema_MaxDeviation 
            data_cell{k} = [NaN, NaN, NaN];
            cntr = cntr + 1;
        end
    end
    Logging(3, append(num2str(cntr), ' slices where omitted by FilterBy_AmountExtrema.'))
    clear k MedianExtrema TotalExtrema cntr
end



%Convert to single array and Remove NaNs
data_all = vertcat(data_cell{:});
data_all(any(isnan(data_all), 2), :) = []; % remove nan values

Logging(6, 'Filtering and postprocessing completed successfully.')

%% 5 - Create surface and plot

Logging(5, '-- 5/6 -- Plotting started.')

Plot_Surface = false;
if Plot_Surface
    [newXY,~,locMembers] = unique([data_all(:,1), data_all(:,2)], 'rows', 'stable');  % if slices overlap, filter out doubles
    xx = newXY(:,1)';
    yy = newXY(:,2)';
    zz = splitapply(@(v) mean(v), data_all(:,3)', locMembers');  % group the values of z by the duplicate pairs, take the mean

    T = delaunay(xx, yy);
    if exist('f5')
        figure(5)
        clf(f5)
    else
        f5 = figure(5);
    end

    % tri surface
         trisurf(T, yy, xx, -zz+max(zz), 'EdgeColor', 'none')

    % 3d scatter plot
        % scatter3(data_all(:,1), data_all(:,2), data_all(:,3), [], data_all(:,3), 'filled')

    % contour plot (custom function)
        % x = data_all(:,1);
        % y = data_all(:,2);
        % z = data_all(:,3);
        % tricontour(T, x, y, z, linspace(0, max(z), 100))
        % 

    % xlim([0, I_size(1)])
    % ylim([0, I_size(2)])
    
    clear f5 newXY locMembers

    end

Plot_Contour = true;
if Plot_Contour
    if exist('f7')
        figure(7)
        clf(f7)
    else
        f7 = figure(7);
    end
    
    OverlayContourOnImage = true;
    if OverlayContourOnImage
        
        imshow(I_or)
        hold on
        
        
    end
    
    
    % tri surface
    x = data_all(:,1);
    y = data_all(:,2);
    z = data_all(:,3);
    [xq,yq] = meshgrid(linspace(min(x),max(x),sqrt(length(x))), ...
        linspace(min(y),max(y),sqrt(length(y))));
    warning('off', 'all')  % TODO: remove duplicate x,y datapoints (average z). Now this throws a warning by griddate (and it is done automatically).
    vq = griddata(x,y,z,xq,yq);
    warning('on', 'all')
%     s = surf(yq,xq,-vq+max(max(vq)),'EdgeColor','none', 'FaceLighting','gouraud');
    linetype = '-';  % '-' ':' ':' '-,'  or add colors: '--g'
    levels = 10;
    [~, hContour] = contourf(xq,yq,vq, levels, linetype);
    hContour.LineWidth = .2;
    hContour.LineColor = [.5 .5 .5];
    
    
    if OverlayContourOnImage
        drawnow;
        hFills = hContour.FacePrims;  % array of TriangleStrip objects
        [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
        Transparency = 0.6;
        for idx = 1 : numel(hFills)
            hFills(idx).ColorData(4) = Transparency * 255;   % default=255
        end
    end
    set(gca, 'YDir','reverse')
    ylim([0, I_size(1)])
    xlim([0, I_size(2)])
    colorbar;
    
    
    
    SaveFigure(Save_Figures, f7, save_extensions, append(basename, '_Contour'));
    clear f7
end







%%

% Plot average slice   TODO FIX after reversing direction not working
% anymore
if Plot_Average
    if exist('f6')
        figure(6)
        clf(f6)
    else
        f6 = figure(6);
    end
    data_cell_noempties = data_cell(cellfun(@(x) ~isempty(x), data_cell));
    A = cellfun(@(x) x(:,3), data_cell_noempties, 'UniformOutput', false);
    array_sizes = cellfun(@(x) length(x(find(~isnan(x),1):end)), A); %exclude leading nans
    shortest_array = min(array_sizes(array_sizes ~= 0));

    B = nan(length(A), shortest_array);
    for i = 1:length(A)
        if max(~isnan(A{i}))
            first_nonnan = find(~isnan(A{i}),1);
            data = A{i}(first_nonnan:end);
            B(i, :) = data(end-shortest_array+1:end);
        end
    end
    mean_array = mean(B, 'omitnan'); %change to this line


    %     for i = 1:length(A)
    %         first_nonnan = find(~isnan(A{i}),1);
    %         A{i} = A{i}(first_nonnan:end);
    % 
    %     end


        % REDO INTERPOLATE. JUST IGNORE OUTER DATA! AND SHOW IN NEW FIG.
    %     average_slice = CellMeanInterpolate(A');
    %     average_slice = CellMean(A', 'back');

        plot(mean_array, 'LineWidth', 3)
        xlabel('Distance from center[pix]')
        ylabel('Height [um]')
    %     xlim([0, length(average_slice)]) 
    %     clear A
    % test changes here

    SaveFigure(Save_Figures, f6, save_extensions, append(basename, '_AverageSlice'));
    clear f6
end



Plot_Next = false;
if Plot_Next
    if exist('f8')
        figure(8)
        clf(f8)
    else
        f8 = figure(8);
    end
    
    
    
end


Logging(6, 'Plotting finished successfully.')

%% 6 - Save data

Logging(5, '-- 6/6 -- Saving data started.')

% todo

Logging(6, 'Saving finished successfully.')


%% 7 - Finish

elapsedtime = toc;
Logging(5, append('Code finished successfully in ', num2str(round(elapsedtime)), ' seconds.'))

clear elapsedtime

%% Functions

function SaveFigure(saving_on, fig, extensions, name)
    % Do some checks? isfig?
    if saving_on
        Logging(4, 'Figure saving in progress ...')
        for i = 1:length(extensions)
            saveas(fig, name, extensions(i))
        end
        Logging(6, 'Figure saved successfully.')
    end
end


