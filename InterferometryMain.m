clc; clear all; Settings = struct();

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
- What if Settings.PlotSingleSlice does not have extrema?!
- Alignment of contour on image, espcially when sector is selected.
- Show image sector above average slice (covert to radial coordinates).

%} 


%% INPUT
% Mandatory input is Settings.Source_Filename, the interferometry image.
% Additionally the variable img_cntr = [x0, y0] can be set witht the center
% of the interferometry pattern (x0,y0) (heighest point in image). If this
% variable is not set, a GUI allows you to select it.

% Settings.Source_Filename = 'data\fc2_save_2021-10-20-145841-0667.tif';
% Settings.Interferometry_Center = 1e3 * [1.9823, 0.8367];

% Settings.Source_Filename = 'data\100-3h-11102021102024-0.tiff';
% Settings.Interferometry_Center = 1e3 * [1.3635, 2.9930];

Settings.Source_Filename = 'data\Basler_a2A5328-15ucBAS__40087133__20220124_141421951_36.tiff';
Settings.Interferometry_Center = 1e3 * [2.2415, 4.6085];
Settings.RefractiveIndex_Medium = 1.4329;
Settings.Analyze_TwoParts_CutOff = 1473;

%% SETTINGS

Settings.AnalyzeFolder = false;

Settings.Lambda = 520e-9;                        % Wavelength of light in meters.

Settings.NumberSlices = 400;                     % Total number of radial slices in the full 2pi
Settings.AnalyzeSector = true;                   % If true, only a sector (between Settings.SectorStart and Settings.SectorEnd) of the full 2pi will be analyzed.
    Settings.SectorStart = (3/2)*pi - pi/16;      % Clockwise from 3 o'clock. 
    Settings.SectorEnd = (3/2)*pi + pi/16;        % Note: beyond 3 o'clock not yet supported.

Settings.EstimateOutsides = true;               % If true, before first extrema and after last extrema will be estimated (see documentation).

Settings.FilterBy_AmountExtrema = false;         % TODO needs some work, when some slices are nan.
    Settings.AmountExtrema_MaxDeviation = 0.05;  % Kick out slice if number of extrema differs > this number from the average number of extrema of all slices.

Settings.HeightResolution = 2e-9;                % Resolution of model fitting. Minimal step size in end result is determined by this. 2nm is decent.

Settings.PlotSingleSlice = 4;                    % Show several analysis steps of a certain slice.
Settings.ShowHeightProfileProgress = true;       % Show progress of Height Profile calculation of all slices.

% Plotting
Settings.Show_Plots = true;
    Settings.Plot_VisualizeSlices = true;
    Settings.Plot_SingleSlice = true;
    Settings.Plot_Surface = false; % not working properly
    Settings.Plot_Contour = true;
        Settings.Plot_Contour_OverlayOnImage = true;
        Settings.Plot_Contour_Levels = 10;
        Settings.Plot_Contour_Transparency = 0.6;
    Settings.Plot_AverageHeight = true;                    % Calculate average multiple slices (consider analyzing only a quadrant).

% Saving
Settings.Save_Figures = false;
    Settings.Save_PNG = true;
    Settings.Save_TIFF = true;
    Settings.Save_FIG = true;
    Settings.Save_Folder = 'results';
Settings.Save_Data = true;

Settings.ShowLogoAtStart = true;

% Peak fitting settings
% if Settings.Analyze_TwoParts is false, inside settings are used for all data
Settings.Smoothing_inside = 10;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
Settings.MinPeakDistance_inside = 15;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
Settings.MinPeakProminence_inside = 0.15;        % Peak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
Settings.Analyze_TwoParts = true;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
    Settings.Smoothing_outside = 200;            % Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
    Settings.MinPeakDistance_outside = 500;      % Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
    Settings.MinPeakProminence_outside = 0.3;    % Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
    Settings.Analyze_TwoPart_IncludeMargin = true; % include inside data (up to first extrema) into outside, to enhance peak finding.

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

if Settings.ShowLogoAtStart
    clc
    ShowLogo
end

Logging(5, append('Code started on ', datestr(datetime('now')), '.'))

% Set default plotting sizes
set(0,'defaultAxesFontSize',15)

% Check if Settings.Source_Filename file is supported format
[~, ~, ext] = fileparts(Settings.Source_Filename);
if ~any(strcmp({'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp', '.gif'}, ext))
    Logging(1, 'File format not supported.')
end

status = CheckIfClass('numeric', {'Settings.Lambda', 'Settings.PlotSingleSlice', 'Settings.NumberSlices', 'Settings.SectorStart', 'Settings.SectorEnd'});
status2 = CheckIfClass('logical', {'Settings.AnalyzeSector', 'Settings.ShowHeightProfileProgress', 'Settings.FilterBy_AmountExtrema', 'Settings.Plot_AverageHeight', 'Settings.Save_Figures', 'Settings.Save_PNG', 'Settings.Save_TIFF', 'Settings.Save_FIG', 'Settings.ShowLogoAtStart'});
status3 = CheckIfClass('char', {'Settings.Save_Folder'});
if min([status, status2, status3]) == 0
    Logging(1, 'Could not continue because of invalid settings (see WARNINGs above).')
else
    Logging(6, 'Settings are all of the right type.')
end
clear status status2 status3

% Check amount of slices
dtheta = 2*pi / Settings.NumberSlices;
if Settings.AnalyzeSector
    theta_all = (ceil(Settings.SectorStart/(2*pi)*Settings.NumberSlices):floor(Settings.SectorEnd/(2*pi)*Settings.NumberSlices)).*dtheta;
else
    theta_all = (1:Settings.NumberSlices).*dtheta;
end
if Settings.SectorEnd - Settings.SectorStart < 0
    Logging(1, 'Negative quadrants are not (yet) supported. quadrant_end > quadrant_start.')
end
if length(theta_all) < 1 || (length(theta_all) == 1 && isnan(theta_all))
    Logging(1, 'Amount of slices (slices) should at least be 1. Increase the slices or quadrant size.')
elseif length(theta_all) > 1000
    Logging(3, 'Amount of slices (slices) is extremely big and therefore completion may take long. Consider reducing the slices or quadrant size.')
end    
if length(theta_all) < Settings.PlotSingleSlice
    Logging(3, 'Settings.PlotSingleSlice is bigger than the amount of slices. No single slice data will be shown.')
end

% Correct wavelength for breaking index
Settings.Lambda_Corrected = Settings.Lambda / Settings.RefractiveIndex_Medium;

% Check valid Settings.HeightResolution
steps = (Settings.Lambda_Corrected/4) / Settings.HeightResolution;
maxres =  num2str(ceil((Settings.Lambda_Corrected/4) / 5 *1e9));
minres =  num2str(ceil((Settings.Lambda_Corrected/4) / 500*1e9));
if steps < 5
    Logging(1, strcat("Settings.HeightResolution too big, choose a value between ", minres, " and ", maxres, " nm."))
elseif steps > 500
    Logging(3, strcat("Settings.HeightResolution very small, this might signigicantly slow down the code, choose a value between ", minres, " and ", maxres, "nm."))
end


% Set save folder and naming for figures and data
save_extensions = NaN;
basename = '';
if Settings.Save_Figures || Settings.Save_Data
    [~, name, ~] = fileparts(Settings.Source_Filename);
    stamp = append('PROC',  datestr(now, 'YYYYmmddHHMMSS'));
    savefolder_sub = append(Settings.Save_Folder, '\', stamp);
    [status, msg] = mkdir(savefolder_sub);
    if status == 0
        Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub, '\', '\\'), '" failed! Error: ', msg))
    else
        Logging(5, append('Created folder for image saving "', strrep(savefolder_sub, '\', '\\'), '" successfully.' ))
    end

    basename = append(savefolder_sub, '\', name, '_', stamp);
    
    clear stamp savefolder_sub
end

if Settings.Save_Figures
    if ~Settings.Save_PNG && ~Settings.Save_TIFF && ~Settings.Save_FIG
        Settings.Save_Figures = false;
        Logging(3, 'Settings.Save_PNG, Settings.Save_TIFF, Settings.Save_FIG are all set to false. No figures will be saved.')
    else
        extensions = {'png', 'tiff', 'fig'};
        save_extensions = extensions([Settings.Save_PNG, Settings.Save_TIFF, Settings.Save_FIG]);
    end
end

% Set peak fit settings structure
Settings.PeakFitSettings = struct();
Settings.PeakFitSettings.CutOff = Settings.Analyze_TwoParts;
Settings.PeakFitSettings.CutOffIncludeMargin = Settings.Analyze_TwoPart_IncludeMargin;
Settings.PeakFitSettings.a.MinPeakProminence = Settings.MinPeakProminence_inside;
Settings.PeakFitSettings.b.MinPeakProminence = Settings.MinPeakProminence_outside;
Settings.PeakFitSettings.a.MinPeakDistance = Settings.MinPeakDistance_inside;
Settings.PeakFitSettings.b.MinPeakDistance = Settings.MinPeakDistance_outside;
Settings.PeakFitSettings.a.Smoothing = Settings.Smoothing_inside;
Settings.PeakFitSettings.b.Smoothing = Settings.Smoothing_outside;

% Check wether images > N, then Show_Plots = False


%%
clear ext steps maxres minres status msg path name extensions savefolder_sub
Logging(6, 'Settings checked and all valid.')


%% Start multi-image analysis here.
HeightProfiles_ForSlices_AllImages = struct();

% 
% if Analyze_Folder
%    if ~Analyze_Range
%       Analyze_Range_Values = TOTAL IMAGES; 
%    end
%    
%    for i = Analyze_Range_Values
%       RUN FUNCTION 
%    end
%     
%     
% else
%     
%     
% end
% 
% 
% function SOMETHING(Settings, image)
% 
% end


%% 1 - Image loading

Logging(5, '-- 1/6 -- Image loading started.')

tic

I_or = imread(Settings.Source_Filename);
I = rgb2gray(I_or);
I = adapthisteq(I);

I_size(1) = size(I, 1);
I_size(2) = size(I, 2);

if isfield(Settings, 'Settings.Interferometry_Center')
    Logging(2, 'No image center given in settings, pick image center now.')
    f_temp = figure;
    imshow(I)
    pnt = drawpoint;
    Settings.Interferometry_Center = pnt.Position;
    close(f_temp)
end

clear Settings.Source_Filename pnt
Logging(6, 'Image loaded successfully.')


%% 2 - Determine slices

Logging(5, '-- 2/6 -- Slice determining started.')


points = nan(length(theta_all), 2);

for k = 1:length(theta_all)
    theta = theta_all(k);
    points(k, :) = GetIntersectsImageBorder(Settings.Interferometry_Center, theta, I_size);
    clear intersect_edge intersect_edge2 polangle idx theta
end

% Select TwoPart CutOff point
if Settings.Analyze_TwoParts && ~isfield(Settings, 'Analyze_TwoParts_CutOff')
    Settings.Analyze_TwoParts_CutOff = Plot.VisualizeSlicesCutOff(Settings, struct('I',I,  'theta_all',theta_all, 'points',points));
end
Settings.PeakFitSettings.CutOffValue = Settings.Analyze_TwoParts_CutOff;

% Visualize slices
f1 = Plot.VisualizeSlices(Settings, struct('I',I,  'theta_all',theta_all, 'points',points));
SaveFigure(min([Settings.Save_Figures Settings.Plot_VisualizeSlices]), f1, save_extensions, append(basename, '_SlicesOverview'));

clear f1 f2 k dtheta savename show_slices
Logging(6, 'Slices determined successfully.')

%% 3 - Get HeightProfile for all slices

Logging(5, '-- 3/6 -- Height Profile calculations started.')

data_cell = cell(length(theta_all) ,1);
number_extrema = nan(length(theta_all), 2);
slice_lengths = nan(length(theta_all), 1);

no_height_profile = 0;
first_empty_row = 1;
for k = 1:length(points)  % iterate over all the end points (same length as all slices to analyze)
    if mod(k, round(length(theta_all)/10)) == 0 && Settings.ShowHeightProfileProgress
        Logging(5, append("Height Profile calculation of all slices at ", num2str(k/round(length(theta_all)/10)*10), '%.'))
    end
    pnt = floor(points(k, :));
    roi = [pnt; Settings.Interferometry_Center];

    [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, Settings.Lambda_Corrected, Settings.HeightResolution, Settings.EstimateOutsides, Settings.PeakFitSettings);
    if isnan(d_final)
        no_height_profile = no_height_profile + 1;
    end
    number_extrema(k, 1:2) = [length(pks), length(mns)];
    slice_lengths(k) = length(c_or);

    [xx, yy] = fillline(Settings.Interferometry_Center, pnt, length(d_final));
    if length(d_final) ~= 1
        data_cell{k} = [xx', yy', d_final'];
        first_empty_row = first_empty_row + length(xx);
    end

    
    % Plot one slice
    if k == Settings.PlotSingleSlice
        f4 = Plot.SingleSliceAnalysis(Settings, struct('c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_SingleSlice]), f4, save_extensions, append(basename, '_Slice', num2str(k)));
    end
    
    clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns d_final

end % iteration over all slices

if no_height_profile == length(points)
    Logging(1, 'No height profiles could be calculated for any of the slices. Check if slices are not to short')
elseif no_height_profile > 0
    Logging(3, append('A height profile could not be calculated for ', num2str(no_height_profile), '/', num2str(length(points)), ' slices.'))
else
    Logging(6, 'Height profiles could be calculated for all slices.')
end

clear k first_empty_row f4 no_height_profile
Logging(6, 'Height profiles determined successfully for all slices.')

%% 4 - Filtering of HeightProfile data and Postprocessing of data

Logging(5, '-- 4/6 -- Filtering of HeightProfile data and Postprocessing of data started.')

% filter based on length of peaks
if Settings.FilterBy_AmountExtrema
    TotalExtrema = sum(number_extrema, 2);
    MedianExtrema = median(TotalExtrema);
    cntr = 0;
    for k=1:length(TotalExtrema)
        if abs(1-TotalExtrema(k)/MedianExtrema) >= Settings.AmountExtrema_MaxDeviation 
            data_cell{k} = [NaN, NaN, NaN];
            cntr = cntr + 1;
        end
    end
    Logging(3, append(num2str(cntr), ' slices where omitted by Settings.FilterBy_AmountExtrema.'))
    clear k MedianExtrema TotalExtrema cntr
end

%Convert to single array and Remove NaNs
data_all = vertcat(data_cell{:});
data_all(any(isnan(data_all), 2), :) = []; % remove nan values

Logging(6, 'Filtering and postprocessing completed successfully.')

%% 5 - Plotting of results

Logging(5, '-- 5/6 -- Plotting of results started.')

f5 = Plot.Surface(Settings, struct('data_all',data_all));
SaveFigure(min([Settings.Save_Figures Settings.Plot_Surface]), f5, save_extensions, append(basename, '_Surface'));

f7 = Plot.Contour(Settings, struct('I_or',I_or, 'data_all',data_all));
SaveFigure(min([Settings.Save_Figures Settings.Plot_Contour]), f7, save_extensions, append(basename, '_Contour'));

f6 = Plot.AverageHeight(Settings, struct('data_cell',data_cell));
SaveFigure(min([Settings.Save_Figures Settings.Plot_AverageHeight]), f6, save_extensions, append(basename, '_AverageSlice'));

Logging(6, 'Plotting finished successfully.')

%% 6 - Save data

Logging(5, '-- 6/6 -- Saving data started.')

if Settings.Save_Data
    HeightProfiles_ForSlices = data_cell;
    Slice_Endpoints = points;
    Theta_Slices = theta_all;
    HeightProfile_Mean = mean_array;
    save(append(basename, '_results.mat'), 'Settings', 'HeightProfiles_ForSlices', 'Slice_Endpoints', 'HeightProfile_Mean', 'Theta_Slices')
    % note: original slices c are not saved.
end

Logging(6, 'Saving finished successfully.')

clear data_cell data_cell_noempties points save_extensions I I_or I_size LogLevel mean_array number_extrema slice_lengths theta_all basename

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



