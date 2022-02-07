clc; clear all; Settings = struct(); Settings.LensPresets = struct();

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

- ESTIMATE remaining time left, based on average iteration time of each
loop + extra at the end.

- For Settings.EstimateOutsides, show where the expected minima is going to
be.
- Select reference distance: where all the slices have the same length
(point that can't be missed)
- Ignore inside data. 
- Plotting fails for Settings.Analyze_TwoParts_CutOff
now
- function AverageHeight, fix distance from center.

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

% Settings.Source = 'data\Basler_a2A5328-15ucBAS__40087133__20220124_141421951_36.tiff';

% Settings.Source = 'data\20220124_evaptest_zeiss_greenfilter';
% Settings.Interferometry_Center = 1e3 * [2.2415, 4.6085];
% Settings.Analyze_TwoParts_CutOff = 1473;
% Settings.TimeInterval = 10;
% Settings.ZeisLensMagnification = 'x5'; % if not set, pixels will be use as unit.
% Settings.SectorStart = (3/2)*pi - pi/16;      % Clockwise from 3 o'clock. 
% Settings.SectorEnd = (3/2)*pi + pi/16;        % Note: beyond 3 o'clock not yet supported.
% % Peak fitting settings
% % if Settings.Analyze_TwoParts is false, inside settings are used for all data
% Settings.Analyze_TwoParts = true;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
% Settings.Smoothing_inside = 10;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
% Settings.MinPeakDistance_inside = 15;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
% Settings.MinPeakProminence_inside = 0.15;        % Peak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
%     Settings.Smoothing_outside = 200;            % Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
%     Settings.MinPeakDistance_outside = 500;      % Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
%     Settings.MinPeakProminence_outside = 0.3;    % Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
%     Settings.Analyze_TwoPart_IncludeMargin = true; % include inside data (up to first extrema) into outside, to enhance peak finding.
% Settings.ImageProcessing.EnhanceContrast = true;
% Settings.IgnoreInside = false;

% % Settings.Source = 'data\20220131_test\Basler_a2A5328-15ucBAS__40087133__20220131_142549018_1.tiff';
% Settings.Source = 'data\20220131_test\';
% Settings.TimeInterval = 30*60;
% Settings.ZeisLensMagnification = 'x2'; % if not set, pixels will be use as unit.
% Settings.Interferometry_Center = [4533.5 735.5];
% Settings.SectorStart = pi/2 + pi/8;      % Clockwise from 3 o'clock. 
% Settings.SectorEnd = pi - pi/8;        % Note: beyond 3 o'clock not yet supported.
% Settings.Analyze_TwoParts = false;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
% Settings.Smoothing_inside = 250;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
% Settings.MinPeakDistance_inside = 80;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
% Settings.MinPeakProminence_inside = .15;        % PCutOffIncludeMargineak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
% Settings.ImageProcessing.EnhanceContrast = false;
% Settings.IgnoreInside = true;
% Settings.Analyze_TwoParts_CutOff = 1618;

% Settings.Source = 'data\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_176.tiff';
Settings.Source = 'E:\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_47.tiff';
% Settings.Source = 'E:\20220201\';
Settings.TimeInterval = 30;
Settings.ZeisLensMagnification = 'x2'; % if not set, pixels will be use as unit.
Settings.Interferometry_Center = [4485.5 729.5];
Settings.SectorStart = pi/2 + pi/4 + pi/16;      % Clockwise from 3 o'clock. 
Settings.SectorEnd = pi - pi/8;        % Note: beyond 3 o'clock not yet supported.
Settings.Analyze_TwoParts = true;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
Settings.Smoothing_inside = 0.1;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
Settings.MinPeakDistance_inside = 18;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
Settings.MinPeakProminence_inside = .10;        % PCutOffIncludeMargineak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
    Settings.Smoothing_outside = 0.1;            % Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
    Settings.MinPeakDistance_outside = 500;      % Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
    Settings.MinPeakProminence_outside = 0.3;    % Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
Settings.ImageProcessing.EnhanceContrast = false;
Settings.IgnoreInside = false;
Settings.Analyze_TwoParts_CutOff = 1350;

% TODO: settings wizard for analysis settings! Choose prominance etc
% TODO: make MinPeakProminance settings to orginal image!


%{
Mandatory settings
    Settings.Source --> string to local path of folder with image, or single image
    Settings.TimeInterval --> (only mandatory if source is folder) XXX

Optional settings
    Settings.Interferometry_Center
    Settings.Analyze_TwoParts_CutOff
    Settings.ZeisLensMagnification
    Settings.ConversionFactorPixToMm
%}


%% SETTINGS

Settings.Lambda = 520e-9;                        % Wavelength of light in meters.
Settings.RefractiveIndex_Medium = 1.4329;

Settings.Anlysismode_averaging = 2; % 1 is height profile for each line, than average. 2 is average first, than height profile for single line.

Settings.Stitching_AveragePoints = 5;

Settings.ImageSkip = 1;     % Allows to skip images in the analysis. Eg. 4 will analyze images 1,5,9,13,etc

Settings.NumberSlices = 1600;                     % Total number of radial slices in the full 2pi
Settings.AnalyzeSector = true;                   % If true, only a sector (between Settings.SectorStart and Settings.SectorEnd) of the full 2pi will be analyzed.
%     Settings.SectorStart = (3/2)*pi - pi/16;      % Clockwise from 3 o'clock. 
%     Settings.SectorEnd = (3/2)*pi + pi/16;        % Note: beyond 3 o'clock not yet supported.

Settings.EstimateOutsides = true;               % If true, before first extrema and after last extrema will be estimated (see documentation).

Settings.FilterBy_AmountExtrema = false;         % TODO needs some work, when some slices are nan.
    Settings.AmountExtrema_MaxDeviation = 0.05;  % Kick out slice if number of extrema differs > this number from the average number of extrema of all slices.

Settings.HeightResolution = 2e-9;                % Resolution of model fitting. Minimal step size in end result is determined by this. 2nm is decent.

Settings.PlotSingleSlice = 50;                    % Show several analysis steps of a certain slice.

% Display settings (things that show while code is running)
Settings.Display.IndividualPlots = true;  % only determines showing them to screen, if false, Save_Figures still works.
Settings.Display.TotalPlots = true;
Settings.Display.ImageProgress = true;
    Settings.Display.ImageProgressValue = 1;
Settings.Display.HeightProfileProgress = false;       % Show progress of Height Profile calculation of all slices.
    Settings.Display.HeightProfileProgressValue = 10;
Settings.Display.LogoAtStart = true;
    
% Plotting
Settings.Plot_VisualizeSlices = false;
Settings.Plot_SingleSlice = true;
Settings.Plot_Surface = false; % not working properly
Settings.Plot_Contour = false;
    Settings.Plot_Contour_OverlayOnImage = true;
    Settings.Plot_Contour_Levels = 10;
    Settings.Plot_Contour_Transparency = 0.6;
Settings.Plot_AverageHeight = true;                    % Calculate average multiple slices (consider analyzing only a quadrant).
Settings.Plot_AverageHeightAllImages = true;
Settings.PlotFontSize = 15;

% Saving
Settings.Save_Figures = false;
    Settings.Save_PNG = true;
    Settings.Save_TIFF = true;
    Settings.Save_FIG = true;
    Settings.Save_Folder = 'results';
Settings.Save_Data = false;

% Peak fitting settings
Settings.Analyze_TwoPart_IncludeMargin = true;  % only if twoparts is on

% Conversion pix to SI
Settings.LensPresets.x2 = 677;  % Standard presets to use as conversion, assuming in focus. Add like .xMagnification = PixToMm.
Settings.LensPresets.x5 = 1837;
Settings.LensPresets.x10 = 3679;

global LogLevel
LogLevel = 5;  % Recommended at least 2. To reduce clutter use 5. To show all use 6.
%{
    1, 'ERROR';     % Code cannot continue.
    2, 'ACTION';    % User needs to do something.
    3, 'WARNING';   % Code can continue, but user should note something (decision made by code e.g.).
    4, 'PROGRESS';  % Show user that something is being done now, e.g. when wait is long.
    5, 'INFO';      % Information about code progress. E.g. 'Figures are being saved'.
    6, 'OK';        % just to show progress is going on as planned.
%}



%% 0 - Settings checks and ititialization

if Settings.Display.LogoAtStart
    clc
    ShowLogo
end

Logging(5, append('Code started on ', datestr(datetime('now')), '.'))

% Set default plotting sizes
set(0,'defaultAxesFontSize', Settings.PlotFontSize);
% set(gca,'TickLabelInterpreter','latex');

status = CheckIfClass('numeric', {'Settings.Lambda', 'Settings.PlotSingleSlice', 'Settings.NumberSlices', 'Settings.SectorStart', 'Settings.SectorEnd', 'Settings.Display.ImageProgressValue', 'Settings.Display.HeightProfileProgressValue'});
status2 = CheckIfClass('logical', {'Settings.AnalyzeSector', 'Settings.Display.HeightProfileProgress', 'Settings.Display.HeightProfileProgress', 'Settings.FilterBy_AmountExtrema', 'Settings.Plot_AverageHeight', 'Settings.Save_Figures', 'Settings.Save_PNG', 'Settings.Save_TIFF', 'Settings.Save_FIG', 'Settings.Display.LogoAtStart'});
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


% Set peak fit settings structure
Settings.PeakFitSettings = struct();
Settings.PeakFitSettings.CutOff = Settings.Analyze_TwoParts;
Settings.PeakFitSettings.a.MinPeakProminence = Settings.MinPeakProminence_inside;
Settings.PeakFitSettings.a.MinPeakDistance = Settings.MinPeakDistance_inside;
Settings.PeakFitSettings.a.Smoothing = Settings.Smoothing_inside;
if Settings.PeakFitSettings.CutOff
    Settings.PeakFitSettings.b.MinPeakProminence = Settings.MinPeakProminence_outside;
    Settings.PeakFitSettings.b.MinPeakDistance = Settings.MinPeakDistance_outside;
    Settings.PeakFitSettings.b.Smoothing = Settings.Smoothing_outside;
end
Settings.PeakFitSettings.CutOffIncludeMargin = Settings.Analyze_TwoPart_IncludeMargin;


% Settings.Source = 'data\';
Settings.AnalyzeRange = false;

if isfolder(Settings.Source)
    Settings.AnalyzeFolder = true;
    Logging(5, 'Source is a folder, multiple images will be analyzed.')
elseif isfile(Settings.Source)
    Settings.AnalyzeFolder = false;
    Logging(5, 'Source is a file, this single image will be analyzed.')
else
    Logging(1, append('Entered Source "', string(Settings.Source), '" is not a folder nor file.'))
end


% List all images in selected folder.
if Settings.AnalyzeFolder
    if ~strcmp(Settings.Source(end), '\')
        Settings.Source = append(Settings.Source, '\');
    end
    Settings.Source_ImageList = {};  % list with all the images found in the folder. Settings.Analysis_ImageList is the list of images that will be analyzed (selection of prior).
    for ext = {'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp', '.gif'} %check for images of this type in source folder and append to imagelist if they exist.
        images = dir(append(Settings.Source, '*', ext{1}));
        images_fullpath = cellfun(@(x) append(x.folder, '\', x.name), num2cell(images), 'UniformOutput', false);
        Settings.Source_ImageList = [Settings.Source_ImageList, images_fullpath];
    end
    Settings.Source_ImageList = natsortfiles(Settings.Source_ImageList); % Stephen (2022). Natural-Order Filename Sort (https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort), MATLAB Central File Exchange. Retrieved January 27, 2022. 
    Settings.Analysis_ImageList = Settings.Source_ImageList(1:Settings.ImageSkip:length(Settings.Source_ImageList));

    if isempty(Settings.Source_ImageList)
        Logging(1, 'No images found in Source folder.')
    else
        Logging(5, append(num2str(length(Settings.Source_ImageList)), ' images found in Source folder, ', num2str(length(1:Settings.ImageSkip:length(Settings.Source_ImageList))), ' will be analyzed (every ', num2str(Settings.ImageSkip), ' image(s)).'))
    end
     
%     if isfield(Settings, 'AnalyzeRange')  %check wether user wants to analyze a range of images  DO NOT USE THIS SETTINGS. DEPRICATED.
%         if isempty(Settings.AnalyzeRange) || ~Settings.AnalyzeRange
%            Settings.Analyze_Range_Values = 1:length(Settings.Source_ImageList);
%         end
%     else 
%         Settings.Analyze_Range_Values = 1:length(Settings.Source_ImageList);
%         Logging(5, 'The entered selected Range of images (alphabetically in folder) will be analyzed.')
%     end

    Settings.ImageCount = length(Settings.Analysis_ImageList);
    Settings.ImageCount_SourceFolder = length(Settings.Source_ImageList);

    if ~isfield(Settings, 'TimeInterval')
        Logging(1, 'TimeInterval is not set. Add "Settings.Timeinterval" to your settings.')
    elseif ~CheckIfClass('numeric', {'Settings.TimeInterval'})
        Logging(1, 'Could not continue because of invalid setting (see WARNING above).')
    else
        Settings.TimeRange = 0:Settings.TimeInterval:Settings.TimeInterval*Settings.ImageCount_SourceFolder;
        Settings.TimeRange = Settings.TimeRange(1:Settings.ImageSkip:Settings.ImageCount_SourceFolder);
    end

else %input is single file
    % Check if Settings.Source file is supported format
    [~, ~, ext] = fileparts(Settings.Source);
    if ~any(strcmp({'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp', '.gif'}, ext))
        Logging(1, 'File format not a supported image.')
    end
    Settings.Source_ImageList = {Settings.Source};
    Settings.Analysis_ImageList = Settings.Source_ImageList;
    Settings.ImageCount = 1;
end

% Set save folder and naming for figures and data
save_extensions = NaN;
basename = '';
if Settings.Save_Figures || Settings.Save_Data
    [~, name, ~] = fileparts(Settings.Source_ImageList{1});
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

% TODO:  Check if all images are same size

% Determine if to plot individual plots or not
if Settings.Display.IndividualPlots && length(Settings.Analysis_ImageList) > 2
    Logging(2, 'There are more than 2 images in the selected folder, and Show_Plots is on. This can significantly slow down your computer. Do you wish to continue, or turn off Show_Plots?')
    x = input('Y (keep on) / N (turn off) [N]  ','s');
    if isempty(x) || strcmpi(x, 'N')
        Settings.Display.IndividualPlots = false;
        Logging(5, 'Showing plots to screen is turned off.')
    elseif strcmpi(x, 'Y')
        Logging(3, 'Showing plots is still on. This can significantly slow down your computer.')
    else
        Logging(1, 'No valid input')
    end
    clear x
end

% Determine conversion factor and unit for distance scale
Settings.DistanceUnit = 'mm'; % the standard  (µm)
if ~isfield(Settings, 'ZeisLensMagnification') && ~isfield(Settings, 'ConversionFactorPixToMm')
    Settings.ConversionFactorPixToMm = 1;
    Settings.DistanceUnit = 'pix';
elseif isfield(Settings, 'ZeisLensMagnification')
    if isfield(Settings.LensPresets, Settings.ZeisLensMagnification)
        Settings.ConversionFactorPixToMm = getfield(Settings.LensPresets, Settings.ZeisLensMagnification);
    else
        Logging(1, append('Lens preset ', Settings.ZeisLensMagnification, ' does not exist. Valid options are: ', strjoin(fields(Settings.LensPresets), ', '), '. Or add as new to Settings.LensPresets.'))
    end    
end

clear ext steps maxres minres status msg path name extensions savefolder_sub images_fullpath images
Logging(6, 'Settings checked and all valid.')

tic

%% 1 - Image loading

Logging(5, '---- Image loading started.')

I_or = imread(Settings.Analysis_ImageList{1});
I = rgb2gray(I_or);
if Settings.ImageProcessing.EnhanceContrast
    I = adapthisteq(I);
end

I_size(1) = size(I, 1);
I_size(2) = size(I, 2);

if ~isfield(Settings, 'Interferometry_Center')
    Logging(2, 'No image center given in settings, pick image center now.')
    f_temp = figure;
    imshow(I)
    pnt = drawpoint;
    Settings.Interferometry_Center = pnt.Position;
    Logging(5, append('Interferometry_Center is ', num2str(Settings.Interferometry_Center), '.'))
    close(f_temp)
end

clear pnt
Logging(6, 'Image loaded successfully.')

%% 2 - Determine slices

Logging(5, '---- Slice determining started.')

points = nan(length(theta_all), 2);

for k = 1:length(theta_all)
    theta = theta_all(k);
    points(k, :) = GetIntersectsImageBorder(Settings.Interferometry_Center, theta, I_size);
    clear intersect_edge intersect_edge2 polangle idx theta
end

% Select TwoPart CutOff point
if (Settings.Analyze_TwoParts || Settings.IgnoreInside) && ~isfield(Settings, 'Analyze_TwoParts_CutOff')
    Logging(2, 'No cutoff point chosen for TwoPart analysis of data. Please select now.')
    Settings.Analyze_TwoParts_CutOff = Plot.VisualizeSlicesCutOff(Settings, struct('I',I,  'theta_all',theta_all, 'points',points));
    Logging(5, append('Cutoff point for TwoPart analysis (or cutoff) Settings.Analyze_TwoParts_CutOff = ', num2str(Settings.Analyze_TwoParts_CutOff), '.'))
end
if Settings.Analyze_TwoParts || Settings.IgnoreInside
    Settings.PeakFitSettings.CutOffValue = Settings.Analyze_TwoParts_CutOff;
end

% Visualize slices
f1 = Plot.VisualizeSlices(Settings, struct('I',I,  'theta_all',theta_all, 'points',points));
SaveFigure(min([Settings.Save_Figures Settings.Plot_VisualizeSlices]), f1, save_extensions, append(basename, '_SlicesOverview'));
if ~Settings.Display.IndividualPlots; close(f1); end % must close, even if not visible, otherwise in memory

clear f1 f2 k dtheta savename show_slices
Logging(6, 'Slices determined successfully.')

%% X - Iterate over all images

Logging(5, '---- Height Profile calculations started.')

HeightProfiles_ForSlices_AllImages = cell(1, length(Settings.Analysis_ImageList));
HeightProfile_Mean_AllImages = cell(1, length(Settings.Analysis_ImageList));
TimePerImage = nan(1, length(Settings.Analysis_ImageList));

for i = 1:Settings.ImageCount
    tStart = tic;
    Image = Settings.Analysis_ImageList{i};
    
%     if mod(num2str(i), round(Settings.ImageCount/10)) == 0
%         Logging(5, append("~~~~~~ Height profile calculations for all images at ", num2str(round(i/Settings.ImageCount*10)*10), "% ~~~~~~"))
%     end

    if mod(i, Settings.Display.ImageProgressValue) == 0 && Settings.Display.ImageProgress
        Logging(6, append("Image ", num2str(i), "/", num2str(Settings.ImageCount), ' being processed.'))
    end
    
    I_or = imread(Image);
    I = rgb2gray(I_or);
    I = adapthisteq(I);
    
    %% 3 - Get HeightProfile for all slices

    HeightProfiles_ForSlices = cell(length(theta_all) ,1);
    number_extrema = nan(length(theta_all), 2);
    slice_lengths = nan(length(theta_all), 1);
        
    
    if Settings.Anlysismode_averaging == 1

        no_height_profile = 0;
        first_empty_row = 1;
        for k = 1:length(points)  % iterate over all the end points (same length as all slices to analyze)
            if mod(k, round(length(theta_all)/Settings.Display.HeightProfileProgressValue)) == 0 && Settings.Display.HeightProfileProgress
                Logging(6, append("Height Profile calculation for image ", num2str(i) ," at ", num2str(k/(length(theta_all)/10)*10), '%.'))
            end
            pnt = floor(points(k, :));
            roi = [pnt; Settings.Interferometry_Center];
    
            [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, Settings);
            if Settings.IgnoreInside 
                d_final(1:Settings.Analyze_TwoParts_CutOff) = NaN;
            end
    
            if isnan(d_final)
                no_height_profile = no_height_profile + 1;
            end
            number_extrema(k, 1:2) = [length(pks), length(mns)];
            slice_lengths(k) = length(c_or);
    
            [xx, yy] = fillline(Settings.Interferometry_Center, pnt, length(d_final));
            if length(d_final) ~= 1
                HeightProfiles_ForSlices{k} = [xx', yy', d_final'];
                first_empty_row = first_empty_row + length(xx);
            end
    
    
            % Plot one slice
            if k == Settings.PlotSingleSlice
                f4 = Plot.SingleSliceAnalysis(Settings, struct('c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k));
                SaveFigure(min([Settings.Save_Figures Settings.Plot_SingleSlice]), f4, save_extensions, append(basename, '_Slice', num2str(k), '_', num2str(i)));
                if ~Settings.Display.IndividualPlots; close(f4); end % must close, even if not visible, otherwise in memory
            end
    
            clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns d_final
    
        end % iteration over all slices
    elseif Settings.Anlysismode_averaging == 2
        
        no_height_profile = 0;
        first_empty_row = 1;
        cel_AllSlices = cell(1,length(points));
        for k = 1:length(points)  % iterate over all the end points (same length as all slices to analyze)
            pnt = floor(points(k, :));
            roi = [pnt; Settings.Interferometry_Center];
            cel_AllSlices{k} = improfile(I, roi(:,1), roi(:,2), norm(roi(1,:)'-roi(2,:)')); 
        end
        max_length = max(cellfun(@(x) length(x), cel_AllSlices));
        arr_AllSlices = nan(length(points), max_length);
        for m=1:length(cel_AllSlices)
            arr_AllSlices(m,1:length(cel_AllSlices{m})) = cel_AllSlices{m};
            arr_AllSlices(m,max_length-length(cel_AllSlices{m})+1:end) = cel_AllSlices{m};
        end
        arr_AverageSlice = mean(arr_AllSlices, 1, 'omitnan'); %TODO also nan if less than n datapoints (e.g. 3).
        
        [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(NaN, NaN, Settings, arr_AverageSlice');

        if Settings.IgnoreInside 
            d_final(1:Settings.Analyze_TwoParts_CutOff) = NaN;
        end

        %TODO: check if nan. PLUS LOT OF REDUDANT CODE NOW. 
        number_extrema(k, 1:2) = [length(pks), length(mns)];
        slice_lengths(k) = length(c_or);

        [xx, yy] = fillline(Settings.Interferometry_Center, pnt, length(d_final));
        if length(d_final) ~= 1
            HeightProfiles_ForSlices{k} = [xx', yy', d_final'];
            first_empty_row = first_empty_row + length(xx);
        end

        % Plot one slice
        f4 = Plot.SingleSliceAnalysis(Settings, struct('c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_SingleSlice]), f4, save_extensions, append(basename, '_Slice', num2str(k), '_', num2str(i)));
        if ~Settings.Display.IndividualPlots; close(f4); end % must close, even if not visible, otherwise in memory

        HeightProfile_Mean = d_final;
%         clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns d_final

    end



    if no_height_profile == length(points)
        Logging(1, 'No height profiles could be calculated for any of the slices. Check if slices are not to short')
    elseif no_height_profile > 0
        Logging(3, append('A height profile could not be calculated for ', num2str(no_height_profile), '/', num2str(length(points)), ' slices.'))
    else
        Logging(6, 'Height profiles could be calculated for all slices.')
    end

    clear k first_empty_row f4 no_height_profile
    Logging(6, append('Height profiles determined successfully for all slices for image ', num2str(i), '.'))

    %% 4 - Filtering of HeightProfile data and Postprocessing of data

    Logging(6, append('Filtering of HeightProfile data and Postprocessing of data started for image ', num2str(i), '.'))

    % filter based on length of peaks
    if Settings.FilterBy_AmountExtrema
        TotalExtrema = sum(number_extrema, 2);
        MedianExtrema = median(TotalExtrema);
        cntr = 0;
        for k=1:length(TotalExtrema)
            if abs(1-TotalExtrema(k)/MedianExtrema) >= Settings.AmountExtrema_MaxDeviation 
                HeightProfiles_ForSlices{k} = [NaN, NaN, NaN];
                cntr = cntr + 1;
            end
        end
        Logging(3, append(num2str(cntr), ' slices where omitted by Settings.FilterBy_AmountExtrema.'))
        clear k MedianExtrema TotalExtrema cntr
    end

    if Settings.Anlysismode_averaging == 1
        % Convert to single array and Remove NaNs
        data_all = vertcat(HeightProfiles_ForSlices{:});
        data_all(any(isnan(data_all), 2), :) = []; % remove nan values

        % Calculate HeightProfile_Mean of all slices
        HeightProfiles_ForSlices_noempties = HeightProfiles_ForSlices(cellfun(@(x) ~isempty(x), HeightProfiles_ForSlices));
        A = cellfun(@(x) x(:,3), HeightProfiles_ForSlices_noempties, 'UniformOutput', false);
        array_sizes = cellfun(@(x) length(x(find(~isnan(x),1):end)), A); %exclude leading nans
        shortest_array = min(array_sizes(array_sizes ~= 0));
        B = nan(length(A), shortest_array);
        for l = 1:length(A)
            if max(~isnan(A{l}))
                first_nonnan = find(~isnan(A{l}),1);
                data = A{l}(first_nonnan:end);
                B(l, :) = data(end-shortest_array+1:end);
            end
        end
        HeightProfile_Mean = mean(B, 'omitnan');
        clear A B
 
    end
    
    Logging(6, append('Filtering and postprocessing completed successfully for image ', num2str(i), '.'))

    %% 5 - Plotting of results

    Logging(6, append('Plotting of results started for image ', num2str(i), '.'))
    
    if Settings.Anlysismode_averaging == 1
        f5 = Plot.Surface(Settings, struct('data_all',data_all));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_Surface]), f5, save_extensions, append(basename, '_Surface_', num2str(i)));
        if ~Settings.Display.IndividualPlots; close(f5); end % must close, even if not visible, otherwise in memory
    
        
        f7 = Plot.Contour(Settings, struct('I_or',I_or, 'data_all',data_all));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_Contour]), f7, save_extensions, append(basename, '_Contour', num2str(i)));
        if ~Settings.Display.IndividualPlots; close(f7); end % must close, even if not visible, otherwise in memory
    end
    
    f6 = Plot.AverageHeight(Settings, struct('HeightProfile_Mean',HeightProfile_Mean)); %TODO, take mean_array out of here!
    SaveFigure(min([Settings.Save_Figures Settings.Plot_AverageHeight]), f6, save_extensions, append(basename, '_AverageSlice', num2str(i)));
    if ~Settings.Display.IndividualPlots; close(f6); end % must close, even if not visible, otherwise in memory

    Logging(6, append('Plotting finished successfully for image ', num2str(i), '.'))
    
    %% Return from loop
    HeightProfiles_ForSlices_AllImages{i} = HeightProfiles_ForSlices;
    HeightProfile_Mean_AllImages{i} = HeightProfile_Mean;
    
    clear f5 f6 f7 f8 data data_all
    
    TimePerImage(i) = toc(tStart);
    if Settings.ImageCount > 1
        TimeRemaining = (Settings.ImageCount-i)*mean(TimePerImage, 'omitnan') + 1.6;  % 1.6 for rest of code.
        if TimeRemaining < 90 && TimeRemaining > 1
            Logging(5, append('Estimated time remaining: ', num2str(round(TimeRemaining)), ' seconds.'))
        else
            Logging(5, append('Estimated time remaining: ', num2str(round(TimeRemaining/60)), ' minutes.'))
        end
    end
end % iterate over all images

clear i tStart TimeRemaining

%% X - Plot total data

if Settings.ImageCount > 1
    f8 = Plot.AverageHeight_AllImages(Settings, struct('HeightProfile_Mean_AllImages', {HeightProfile_Mean_AllImages}));
    SaveFigure(min([Settings.Save_Figures Settings.Plot_AverageHeightAllImages]), f8, save_extensions, append(basename, '_AverageSlice_total'));
end

%% 6 - Save data

Logging(5, '---- Saving data started.')

% Show amount of data that is being saved.

if Settings.Save_Data
    Slice_Endpoints = points;
    Theta_Slices = theta_all;
    save(append(basename, '_results.mat'), 'Settings', 'HeightProfiles_ForSlices_AllImages', 'Slice_Endpoints', 'HeightProfile_Mean_AllImages', 'Theta_Slices')
    % note: original slices c are not saved.
end

Logging(6, 'Saving finished successfully.')

clear data_cell_noempties points I I_or I_size LogLevel number_extrema slice_lengths theta_all basename
% clear save_extensions

%% 7 - Finish

elapsedtime = toc;
Logging(5, append('Code finished successfully in ', num2str(round(elapsedtime)), ' seconds.'))

clear elapsedtime

%% Functions

function SaveFigure(saving_on, fig, extensions, name)
    % Do some checks? isfig?
    if saving_on
        Logging(6, 'Figure saving in progress ...')
        for i = 1:length(extensions)
            saveas(fig, name, extensions(i))
        end
        Logging(6, 'Figure saved successfully.')
    end
end



