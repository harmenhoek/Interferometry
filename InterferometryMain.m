clc; clear all; Settings = struct(); Settings.LensPresets = struct(); addpath('functions')

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
- FinalSlice and other slices in seperate folders if images > 10
- Update PROC name to more readable one.

%} 


%% INPUT
% Mandatory input is Settings.Source_Filename, the interferometry image.
% Additionally the variable img_cntr = [x0, y0] can be set witht the center
% of the interferometry pattern (x0,y0) (heighest point in image). If this
% variable is not set, a GUI allows you to select it.

% Settings.Source_Filename = 'data\fc2_save_2021-10-20-145841-0667.tif';
% Settings.SectorCenter = 1e3 * [1.9823, 0.8367];

% Settings.Source_Filename = 'data\100-3h-11102021102024-0.tiff';
% Settings.SectorCenter = 1e3 * [1.3635, 2.9930];

% Settings.Source = 'data\Basler_a2A5328-15ucBAS__40087133__20220124_141421951_36.tiff';

% Settings.Source = 'data\20220124_evaptest_zeiss_greenfilter';
% Settings.SectorCenter = 1e3 * [2.2415, 4.6085];
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
% Settings.SectorCenter = [4533.5 735.5];
% Settings.SectorStart = pi/2 + pi/8;      % Clockwise from 3 o'clock. 
% Settings.SectorEnd = pi - pi/8;        % Note: beyond 3 o'clock not yet supported.
% Settings.Analyze_TwoParts = false;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
% Settings.Smoothing_inside = 250;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
% Settings.MinPeakDistance_inside = 80;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
% Settings.MinPeakProminence_inside = .15;        % PCutOffIncludeMargineak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
% Settings.ImageProcessing.EnhanceContrast = false;
% Settings.IgnoreInside = true;
% Settings.Analyze_TwoParts_CutOff = 1618;

% Settings.Source = 'data\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_75.tiff';
% Settings.Source = 'data\20220201';
% Settings.Source = 'E:\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_20.tiff';
% Settings.Source = 'E:\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_21.tiff';
% Settings.Source = 'E:\20220201\Basler_a2A5328-15ucBAS__40087133__20220201_125331578_130.tiff';
% Settings.Source = 'E:\20220201\';
% Settings.TimeInterval = 10;
% Settings.LensMagnification = 'ZeisX2'; % if not set, pixels will be use as unit.
% Settings.SectorCenter = [4485.5 729.5];
% Settings.SectorStart = pi/2 + pi/4 + pi/16;      % Clockwise from 3 o'clock. 
% Settings.SectorEnd = pi - pi/8;        % Note: beyond 3 o'clock not yet supported.
% Settings.Analyze_TwoParts = true;                % Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup))
% Settings.Smoothing_inside = 10;                  % Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
% Settings.MinPeakDistance_inside = 17;            % Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
% Settings.MinPeakProminence_inside = .08;        % PCutOffIncludeMargineak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
%     Settings.Smoothing_outside = 50;            % Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
%     Settings.MinPeakDistance_outside = 500;      % Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
%     Settings.MinPeakProminence_outside = 0.18;    % Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
% Settings.ImageProcessing.EnhanceContrast = false;
% Settings.IgnoreInside = false;
% Settings.Analyze_TwoParts_CutOff = 1350;
% Settings.Lambda = 520e-9;                        % Wavelength of light in meters.


% TODO: settings wizard for analysis settings! Choose prominance etc
% TODO: make MinPeakProminance settings to orginal image!


%{
Mandatory settings
    Settings.Source --> string to local path of folder with image, or single image
    Settings.TimeInterval --> (only mandatory if source is folder) XXX

Optional settings
    Settings.SectorCenter
    Settings.Analyze_TwoParts_CutOff
    Settings.ZeisLensMagnification
    Settings.ConversionFactorPixToMm
%}



% Settings.Source = 'E:\20220210_nikon\open air green filter-4x\';

% Settings.Source = 'data\20220210_nikon\1-02102022020936-48.tiff';             % STRING  (Local) path to single image or folder to be analyzed. 
% Settings.TimeInterval = 10;                         % FLOAT   Time between frames in second (if multiple images)
% Settings.LensMagnification = 'NikonX4';             % STRING  if not set, pixels will be use as unit.
% Settings.SectorCenter = [28 1388];         % ARRAY   Center of the interferometry pattern, from where the slices will originate.
% Settings.SectorStart = 0;                           % FLOAT   Clockwise from 3 o'clock. 
% Settings.SectorEnd = pi/16;                         % FLOAT   Note: beyond 3 o'clock not yet supported.
% Settings.Analyze_TwoParts = true;                   % LOGIC   Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup)). If false, only _inside is used.
%     Settings.Analyze_TwoParts_CutOff = 1242;        % INT     Below this datapoint uses _inside settings, after uses _outside settings.
%     Settings.Smoothing_inside = 10;                 % FLOAT   Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
%     Settings.MinPeakDistance_inside = 17;           % FLOAT   Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
%     Settings.MinPeakProminence_inside = .08;        % FLOAT   CutOffIncludeMarginPeak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
%     Settings.Smoothing_outside = 50;                % FLOAT   Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
%     Settings.MinPeakDistance_outside = 100;         % FLOAT   Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
%     Settings.MinPeakProminence_outside = 0.18;      % FLOAT   Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
% Settings.ImageProcessing.EnhanceContrast = false;   % LOGIC   Enhance contrast before slicing data.
% Settings.IgnoreInside = false;                      % LOGIC   If .Analyze_TwoParts is true, this can just ignore all inside data (sets it to nan).
% Settings.Lambda = 532e-9;                           % FLOAT   Wavelength of light in meters.
% Settings.RefractiveIndex_Medium = 1.434;            % FLOAT   Refractive index of the medium.


%% INPUT
Settings.Source = 'E:\H-TK\H-TK\closed cell green filter 4x\10min_interval\1-02112022023441-96.tiff';             % STRING  (Local) path to single image or folder to be analyzed. 
% Settings.Source = 'E:\H-TK\H-TK\closed cell green filter 4x\testset\';             % STRING  (Local) path to single image or folder to be analyzed. 
% Settings.TimeInterval = 600;                        % FLOAT   Time between frames in second (if multiple images)
Settings.TimeInterval = 'FromFile';                     % STRING `'FromFile'` or NUMERIC If FromFile, the datetime stamp is 
    % read from the image filename. This datetime is converted to seconds from start automatically. 
    % `Settings.TimeIntervalFormat` and `Settings.TimeIntervalFilenameFormat` must be set. If NUMERIC, give the time in 
    % seconds between each frame.
    Settings.TimeIntervalFormat = 'MMddyyyyHHmmss';     % STRING datetime format. See MATLAB documentation on datetime.
    Settings.TimeIntervalFilenameFormat = {'-', '-'};   % CELL with 2 strings giving the pattern before the 
            % TimeIntervalFormat and after.
       % example: 1-02012022152110-1015 -->  {'-', '-'}, with Settings.TimeIntervalFormat = "ddMMyyyyHHmmss"
       % example: recording2022-02-01_15:13:12_image2 --> {'recording','_'}, with .TimeIntervalFormat = "yyyy-MM-dd_HH:mm:ss" 
                % note that it looks for the last occurance of '_'. '_image' would have given the same result.
Settings.LensMagnification = 'NikonX4';             % STRING  if not set, pixels will be use as unit.
Settings.SliceType = 'linear';                      % STRING  either sector or linear
    Settings.SectorCenter = [43 1316];          % ARRAY   Center of the interferometry pattern, from where the slices will originate.
    Settings.SectorStart = 0;                           % FLOAT   If SliceType is sector: Clockwise from 3 o'clock. 
    Settings.SectorEnd = pi/16;                         % FLOAT   If SliceType is sector: Note: beyond 3 o'clock not yet supported.
    Settings.LinearSliceSpacing = 25;               % INT     Spacing between the slices, in pixels.
     Settings.LinearStart = [595 1919];              % ARRAY   Start point of sliced area. Between Start and End the slices will be made. Optional: if not set, GUI allows to set.
     Settings.LinearEnd = [487 2666];                % ARRAY   End point of sliced area. Optional: if not set, GUI allows to set.
     Settings.LinearAngle = 0.0457*pi;               % FLOAT   Angle between horizontal (x>0) and slice in radians (CW). Note: LinearAngle is decisive, not angle between Start and End. Optional: if not set, GUI allows to set.
Settings.Analyze_TwoParts = true;                   % LOGIC   Use different settings for inside and outside of slice (set cutoff with Settings.Analyze_TwoParts_CutOff, or don't set (popup)). If false, only _inside is used.
     Settings.Analyze_TwoParts_CutOff = 671;         % INT     Below this datapoint uses _inside settings, after uses _outside settings.
    Settings.Smoothing_inside = 10;                 % FLOAT   Gaussian moving average smoothing of inside data (see MATLABs smoothdata function), default: 10
    Settings.MinPeakDistance_inside = 17;           % FLOAT   Peak fitting MinPeakDistance of inside data (see MATLABs findpeaks function), default: 15
    Settings.MinPeakProminence_inside = .08;        % FLOAT   CutOffIncludeMarginPeak fitting MinPeakProminance of inside data (see MATLABs findpeaks function), default: 0.15
    Settings.Smoothing_outside = 50;                % FLOAT   Gaussian moving average smoothing of outside data (see MATLABs smoothdata function)
    Settings.MinPeakDistance_outside = 100;         % FLOAT   Peak fitting MinPeakDistance of outside data (see MATLABs findpeaks function)
    Settings.MinPeakProminence_outside = 0.18;      % FLOAT   Peak fitting MinPeakProminance of outside data (see MATLABs findpeaks function)
Settings.ImageProcessing.EnhanceContrast = false;   % LOGIC   Enhance contrast before slicing data.
Settings.IgnoreInside = false;                      % LOGIC   If .Analyze_TwoParts is true, this can just ignore all inside data (sets it to nan).
Settings.Lambda = 532e-9;                           % FLOAT   Wavelength of light in meters.
Settings.RefractiveIndex_Medium = 1.434;            % FLOAT   Refractive index of the medium.

%% GENERAL SETTINGS
Settings.Anlysismode_averaging = 2;                 % INT     1 is height profile for each line, than average. 2 is average first, than height profile for single line.
Settings.Stitching_AveragePoints = 1;               % INT     When stiching this value determines how many Slice_Endpoints are averaged at start and end of each dataset for use for stitching with previous/next dataset.
Settings.ImageSkip = 1;                             % INT     Allows to skip images in the analysis. Eg. 4 will analyze images 1,5,9,13,etc
Settings.NumberSlices = 500;                        % INT     Total number of radial slices in the full 2pi for SliceType=sector.
Settings.AnalyzeSector = true;                      % LOGIC   If true, only a sector (between Settings.SectorStart and Settings.SectorEnd) of the full 2pi will be analyzed.
Settings.EstimateOutsides = true;                   % LOGIC   If true, before first extrema and after last extrema will be estimated (see documentation).
Settings.FilterBy_AmountExtrema = false;            % LOGIC   TODO needs some work, when some slices are nan.
    Settings.AmountExtrema_MaxDeviation = 0.05;     % FLOAT   Kick out slice if number of extrema differs > this number from the average number of extrema of all slices.

% Display settings (things that show while code is running)
Settings.Display.IndividualPlots = true;            % LOGIC   Individual plots are plots that are made for each frame. Only determines showing them to screen, if false, Save_Figures still works.
Settings.Display.TotalPlots = true;                 % LOGIC   Total plots are plots that have one instance, created at the end. Only determines showing them to screen, if false, Save_Figures still works.
Settings.Display.ImageProgress = true;              % LOGIC   Show which image is currently processed. Only visible if LogLevel is 6.
    Settings.Display.ImageProgressValue = 1;        % FLOAT   Show image progress every x images.
Settings.Display.HeightProfileProgress = true;     % LOGIC   Show progress of Height Profile calculation of all slices. Only visible if LogLevel is 6.
    Settings.Display.HeightProfileProgressValue = 10; % FLOAT Show which section of a single slice is currently being processed. Only visible if LogLevel is 6.
Settings.Display.LogoAtStart = true;                % LOGIC   Show logo and extra info at the start.
    
% Plotting
Settings.Plot_VisualizeSlices = true;               % LOGIC   Plot original image with overlay of the slices plus two-part-analysis line if set.
Settings.Plot_SingleSlice = true;                   % LOGIC   Plot analysis for a single slice (raw slice, filtered slice with peak detection, height profile).
    Settings.PlotSingleSlice = 50;                  % FLOAT   If analysis mode == 1, this value determines which slice is plotted. In mode 2 the average slice is always used.
Settings.Plot_Surface = false;                      % LOGIC   OUT OF DATE. do not use.
Settings.Plot_Contour = false;                      % LOGIC   OUT OF DATE. do not use.  TODO: not an option is Analysismode_averaging == 2
    Settings.Plot_Contour_OverlayOnImage = true;    % LOGIC   Show image underneath contour plot.
    Settings.Plot_Contour_Levels = 10;              % INT     Number of levels of the contour plot. See MATLAB documentation.
    Settings.Plot_Contour_Transparency = 0.6;       % FLOAT   Transparancy of contour plot on original image.
Settings.Plot_AverageHeight = true;                 % LOGIC   Plot the height profile for each image seperately.
Settings.Plot_AverageHeightAllImages = true;        % LOGIC   Plot all height profiles of all images into a single plot, with colorbar.
    Settings.Plot_AverageHeightAllImages_EquivPoint = -10;  % INT This point of all the slices will be set equal, so that the minimal value of whatever slice is 0. Use minus for last values. (0 == end, -1 == end-1, etc) 
Settings.Plot_ResultPlot = true;                    % LOGIC   Plot image, with underneath a combined plot of original slice, filtered slice, detected extrema and height profile.
Settings.PlotFontSize = 15;                         % INT     FontSize in all plots.

% Saving
Settings.Save_Figures = true;                       % LOGIC   Automatically save figures (works even if Display.xx = false).
    Settings.Save_PNG = true;                       % LOGIC   Save plot as png.
    Settings.Save_TIFF = false;                     % LOGIC   Save plot as tiff (note that this is very slow).
    Settings.Save_FIG = true;                       % LOGIC   Save plot as MATLAB fig.
Settings.Save_Data = true;                          % LOGIC   Save final data as .dat.
Settings.Save_Folder = 'results';                % STRING  Path where data and figures will be saved (unique folder is created inside).

% Peak fitting settings
Settings.Analyze_TwoPart_IncludeMargin = true;      % LOGIC   only if twoparts is on. This includes a little (till first extrema in innter dataset) of the inner data into the outer data set. This ensure an extrema close to the boundary can be found.

% Conversion pix to SI
Settings.LensPresets.ZeisX2 = 677;                  % FLOAT   pixels per mm. Standard presets to use as conversion, assuming in focus. Add like .xMagnification = PixToMm.
Settings.LensPresets.ZeisX5 = 1837;                 % FLOAT   pixels per mm. 
Settings.LensPresets.ZeisX10 = 3679;                % FLOAT   pixels per mm. 
Settings.LensPresets.NikonX2 = 1355;                % FLOAT   pixels per mm. 
Settings.LensPresets.NikonX4 = 2700;                % FLOAT   pixels per mm. 

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
Settings.HeightResolution = 2e-9;                % Resolution of model fitting. Minimal step size in end result is determined by this. 2nm is decent. NO LONGER NEEEDED. REMOVE IN MODELFIT PLEASE.



%% 0 - Settings checks and ititialization

if Settings.Display.LogoAtStart
    clc
    ShowLogo
end

Logging(5, append('Code started on ', datestr(datetime('now')), '.'))

% Set default plotting sizes
set(0,'defaultAxesFontSize', Settings.PlotFontSize);
% set(gca,'TickLabelInterpreter','latex');

status = CheckIfClass('numeric', {'Settings.Lambda', 'Settings.PlotSingleSlice', 'Settings.NumberSlices', 'Settings.Display.ImageProgressValue', 'Settings.Display.HeightProfileProgressValue'});
status2 = CheckIfClass('logical', {'Settings.AnalyzeSector', 'Settings.Display.HeightProfileProgress', 'Settings.Display.HeightProfileProgress', 'Settings.FilterBy_AmountExtrema', 'Settings.Plot_AverageHeight', 'Settings.Save_Figures', 'Settings.Save_PNG', 'Settings.Save_TIFF', 'Settings.Save_FIG', 'Settings.Display.LogoAtStart'});
status3 = CheckIfClass('char', {'Settings.Save_Folder'});
if min([status, status2, status3]) == 0
    Logging(1, 'Could not continue because of invalid settings (see WARNINGs above).')
else
    Logging(6, 'Settings are all of the right type.')
end
clear status status2 status3


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
    elseif strcmpi(Settings.TimeInterval, 'FromFile')
        Logging(5, 'Time intervals will be determined from filenames.')
    elseif CheckIfClass('numeric', {'Settings.TimeInterval'})
        Settings.TimeRange = 0:Settings.TimeInterval:Settings.TimeInterval*Settings.ImageCount_SourceFolder;
        Settings.TimeRange = Settings.TimeRange(1:Settings.ImageSkip:Settings.ImageCount_SourceFolder);
    else
        Logging(1, append('No valid setting Settings.TimeInterval= ', num2str(Settings.TimeInterval), '. Should be numeric time interval, or "FromFile".'))
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
    stamp = append('PROC',  datestr(now, 'YYYY-mm-dd-HH-MM-SS'));
    savefolder_sub = append(Settings.Save_Folder, '\', stamp);
    [status, msg] = mkdir(savefolder_sub);

    if status == 0
        Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub, '\', '\\'), '" failed! Error: ', msg))
    else
        Logging(5, append('Created folder for image saving "', strrep(savefolder_sub, '\', '\\'), '" successfully.' ))
    end

    basename = append(savefolder_sub, '\', name, '_', stamp);
    
    
end

% Create subfolders for AverageSlice, FinalSlice and Slice 
if Settings.ImageCount > 1
    savefolder_sub_AverageSlice = append(savefolder_sub, '\AverageSlice');
    [status, msg] = mkdir(savefolder_sub_AverageSlice);
    if status == 0
        Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub_AverageSlice, '\', '\\'), '" failed! Error: ', msg))
    else
        Logging(5, append('Created folder for image saving "', strrep(savefolder_sub_AverageSlice, '\', '\\'), '" successfully.' ))
    end

    savefolder_sub_Slice = append(savefolder_sub, '\Slice');
    [status, msg] = mkdir(savefolder_sub_Slice);
    if status == 0
        Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub_Slice, '\', '\\'), '" failed! Error: ', msg))
    else
        Logging(5, append('Created folder for image saving "', strrep(savefolder_sub_Slice, '\', '\\'), '" successfully.' ))
    end

    savefolder_sub_FinalSlice = append(savefolder_sub, '\FinalSlice');
    [status, msg] = mkdir(savefolder_sub_FinalSlice);
    if status == 0
        Logging(1, append('Folder creation for image saving "', strrep(savefolder_sub_FinalSlice, '\', '\\'), '" failed! Error: ', msg))
    else
        Logging(5, append('Created folder for image saving "', strrep(savefolder_sub_FinalSlice, '\', '\\'), '" successfully.' ))
    end

    basename_AverageSlice = append(savefolder_sub_AverageSlice, '\', stamp);
    basename_Slice = append(savefolder_sub_Slice, '\', stamp);
    basename_FinalSlice = append(savefolder_sub_FinalSlice, '\', stamp);
else
    basename_AverageSlice = append(savefolder_sub, '\', stamp);
    basename_Slice = append(savefolder_sub, '\', stamp);
    basename_FinalSlice = append(savefolder_sub, '\', stamp);
end

clear stamp savefolder_sub


if Settings.Save_Figures
    if ~Settings.Save_PNG && ~Settings.Save_TIFF && ~Settings.Save_FIG
        Settings.Save_Figures = false;
        Logging(3, 'Settings.Save_PNG, Settings.Save_TIFF, Settings.Save_FIG are all set to false. No figures will be saved.')
    else
        extensions = {'png', 'tiff', 'fig'};
        save_extensions = extensions([Settings.Save_PNG, Settings.Save_TIFF, Settings.Save_FIG]);
    end
else
    Logging(3, 'Figures will not be saved!')
end

% TODO:  Check if all images are same size

% Determine if to plot individual plots or not
    %TODO include timer. If no choice is made in 60s, start without showing plots.
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
if ~isfield(Settings, 'LensMagnification') && ~isfield(Settings, 'ConversionFactorPixToMm')
    Settings.ConversionFactorPixToMm = 1;
    Settings.DistanceUnit = 'pix';
elseif isfield(Settings, 'LensMagnification')
    if isfield(Settings.LensPresets, Settings.LensMagnification)
        Settings.ConversionFactorPixToMm = getfield(Settings.LensPresets, Settings.LensMagnification);
    else
        Logging(1, append('Lens preset ', Settings.LensMagnification, ' does not exist. Valid options are: ', strjoin(fields(Settings.LensPresets), ', '), '. Or add as new to Settings.LensPresets.'))
    end    
end

if ~Settings.Save_Data
    Logging(3, 'Data will not be saved!')
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

if ~isfield(Settings, 'SectorCenter') && strcmpi(Settings.SliceType, 'sector')
    Logging(2, 'No image center given in settings, pick image center now.')
    f_temp = figure;
    imshow(I)
    pnt = drawpoint;
    Settings.SectorCenter = pnt.Position;
    Logging(5, append('SectorCenter is ', num2str(Settings.SectorCenter), '.'))
    close(f_temp)
end

if strcmpi(Settings.SliceType, 'linear') && (~isfield(Settings, 'LinearStart') || ~isfield(Settings, 'LinearEnd') || ~isfield(Settings, 'LinearAngle'))
    Logging(2, 'Settings.LinearStart, Settings.LinearEnd or Settings.LinearAngle not set, please draw line perpendicular to linear slices.')
    f_temp = figure;
    imshow(I)
    lne = drawline;


    [~, idx] = min(lne.Position(:,2)); % we want the smallest y to be point 1
    Settings.LinearStart = lne.Position(idx,:);
    Settings.LinearEnd = lne.Position(mod(idx,2)+1,:);
    % LinearAngle is the angle between positive x-axis and line (CW).
    
    Settings.LinearAngle = pi/2 + atan((Settings.LinearEnd(2)-Settings.LinearStart(2))/(Settings.LinearEnd(1)-Settings.LinearStart(1)));
    Settings.LinearAngle = mod(Settings.LinearAngle, pi); % just to  be sure we stay 0<=LinearAngle<=pi

    Logging(5, append('Settings.LinearStart = [', num2str(Settings.LinearStart(1)), ' ', num2str(Settings.LinearStart(2)), '], Settings.LinearEnd = [', num2str(Settings.LinearEnd(1)), ' ', num2str(Settings.LinearEnd(2)),  '], Settings.LinearAngle = ', num2str(round(Settings.LinearAngle/pi, 5)), '*pi.'))
    close(f_temp)
else
    status = CheckIfClass('numeric', {'Settings.LinearStart', 'Settings.LinearEnd', 'Settings.LinearAngle'});
    if status == 0
        Logging(1, 'Could not continue because of invalid settings (see WARNINGs above).')
    else
        Logging(6, 'Settings are all of the right type.')
    end
    clear status
end

clear pnt lne
Logging(6, 'Image loaded successfully.')

%% 2 - Determine slices

Logging(5, '---- Slice determining started.')

if strcmpi(Settings.SliceType, 'sector')
    dtheta = 2*pi / Settings.NumberSlices;
    if Settings.AnalyzeSector
        Theta_Slices = (ceil(Settings.SectorStart/(2*pi)*Settings.NumberSlices):floor(Settings.SectorEnd/(2*pi)*Settings.NumberSlices)).*dtheta;
    else
        Theta_Slices = (1:Settings.NumberSlices).*dtheta;
    end
    if Settings.SectorEnd - Settings.SectorStart < 0
        Logging(1, 'Negative quadrants are not (yet) supported. quadrant_end > quadrant_start.')
    end

    if length(Theta_Slices) < 1 || (length(Theta_Slices) == 1 && isnan(Theta_Slices))
        Logging(1, 'Amount of slices (slices) should at least be 1. Increase the slices or quadrant size.')
    elseif length(Theta_Slices) > 1000
        Logging(3, 'Amount of slices (slices) is extremely big and therefore completion may take long. Consider reducing the slices or quadrant size.')
    end    
    if length(Theta_Slices) < Settings.PlotSingleSlice
        Logging(3, 'Settings.PlotSingleSlice is bigger than the amount of slices. No single slice data will be shown.')
    end

    Slice_Startpoints = nan(length(Theta_Slices), 2);
    Slice_Startpoints(:, 1) = Settings.SectorCenter(1);
    Slice_Startpoints(:, 2) = Settings.SectorCenter(2);

    Slice_Endpoints = nan(length(Theta_Slices), 2);

    for k = 1:length(Theta_Slices)
        theta = Theta_Slices(k);
        Slice_Endpoints(k, :) = GetIntersectsImageBorder(Settings.SectorCenter, theta, I_size);
        clear intersect_edge intersect_edge2 polangle idx theta
    end

    % Select TwoPart CutOff point
    if (Settings.Analyze_TwoParts || Settings.IgnoreInside) && ~isfield(Settings, 'Analyze_TwoParts_CutOff')
        Logging(2, 'No cutoff point chosen for TwoPart analysis of data. Please select now.')
        Settings.Analyze_TwoParts_CutOff = Plot.VisualizeSlicesCutOff(Settings, struct('I',I, 'Slice_Startpoints',Slice_Startpoints, 'Slice_Endpoints',Slice_Endpoints));
        Logging(5, append('Cutoff point for TwoPart analysis (or cutoff) Settings.Analyze_TwoParts_CutOff = ', num2str(Settings.Analyze_TwoParts_CutOff), '.'))
    end
    if Settings.Analyze_TwoParts || Settings.IgnoreInside
        Settings.PeakFitSettings.CutOffValue = Settings.Analyze_TwoParts_CutOff;
    end
    
    Settings.NumberSlicesSelection = length(Theta_Slices);
    Distance_IntersectToEnd = zeros(1,Settings.NumberSlicesSelection); %NOT TESTED

    % Visualize slices
    f1 = Plot.VisualizeSlices(Settings, struct('I',I, 'Slice_Startpoints',Slice_Startpoints, 'Slice_Endpoints',Slice_Endpoints));
    SaveFigure(min([Settings.Save_Figures Settings.Plot_VisualizeSlices]), f1, save_extensions, append(basename, '_SlicesOverview'));
    if ~Settings.Display.IndividualPlots; close(f1); end % must close, even if not visible, otherwise in memory.

    clear f1 f2 k dtheta savename show_slices

elseif strcmpi(Settings.SliceType, 'linear')

    %distance between start and endpoint. used to determine number of slices
    LinearSliceWidth = norm(Settings.LinearStart-Settings.LinearEnd);
    Settings.NumberSlicesSelection = ceil(LinearSliceWidth / Settings.LinearSliceSpacing);

    Slice_Startpoints = nan(Settings.NumberSlicesSelection, 2);
    Slice_Endpoints = nan(Settings.NumberSlicesSelection, 2);
    All_Intersects = cell(1,Settings.NumberSlicesSelection);
    Distance_IntersectToEnd = nan(Settings.NumberSlicesSelection, 1);

    for k = 1:Settings.NumberSlicesSelection
        xn = Settings.LinearStart(1) + (k-1) * Settings.LinearSliceSpacing * -sin(Settings.LinearAngle);
        yn = Settings.LinearStart(2) + (k-1) * Settings.LinearSliceSpacing * cos(Settings.LinearAngle);
%         xn = Settings.LinearStart(1) + (k-1) * Settings.LinearSliceSpacing * cos(Settings.LinearAngle - pi/2); %- for MATLAB definitions
%         yn = Settings.LinearStart(2) + (k-1) * Settings.LinearSliceSpacing * -sin(Settings.LinearAngle - pi/2);
        IntersectPoint = [xn yn]; % We need a list with intersect points to determine. Determine with Interfemetry_Center and shift by Settings.LinearSliceSpacing and angle theta every time.
        Intersects = GetIntersectsImageBorder2(IntersectPoint, Settings.LinearAngle, I_size);
        Slice_Startpoints(k, :) = Intersects{1};
        Slice_Endpoints(k, :) = Intersects{2};
        All_Intersects{k} = IntersectPoint;
        Distance_IntersectToEnd(k) = floor(norm(Slice_Startpoints(k, :) - IntersectPoint));
    end


    % Select TwoPart CutOff point
    if (Settings.Analyze_TwoParts || Settings.IgnoreInside) && ~isfield(Settings, 'Analyze_TwoParts_CutOff')
        Logging(2, 'No cutoff point chosen for TwoPart analysis of data. Please select now.')
        Settings.Analyze_TwoParts_CutOff = Plot.VisualizeSlicesCutOff(Settings, struct('I',I,  'Slice_Startpoints',Slice_Startpoints, 'Slice_Endpoints',Slice_Endpoints));
        Logging(5, append('Cutoff point for TwoPart analysis (or cutoff) Settings.Analyze_TwoParts_CutOff = ', num2str(Settings.Analyze_TwoParts_CutOff), '.'))
    end

    if Settings.Analyze_TwoParts || Settings.IgnoreInside
        Settings.PeakFitSettings.CutOffValue = Settings.Analyze_TwoParts_CutOff;
    end

 
    % Visualize slices
    f1 = Plot.VisualizeSlices(Settings, struct('I',I, 'Slice_Startpoints',Slice_Startpoints, 'Slice_Endpoints',Slice_Endpoints));
    hold on 

    for p = 1:length(All_Intersects)
        plot(All_Intersects{p}(1), All_Intersects{p}(2), '.', 'MarkerSize', 20, 'Color', 'yellow')
    end
    plot(Settings.LinearStart(1), Settings.LinearStart(2), '.', 'MarkerSize', 30, 'Color', 'green')
    plot(Settings.LinearEnd(1), Settings.LinearEnd(2), '.', 'MarkerSize', 30, 'Color', 'green')

    SaveFigure(min([Settings.Save_Figures Settings.Plot_VisualizeSlices]), f1, save_extensions, append(basename, '_SlicesOverview'));
    if ~Settings.Display.IndividualPlots; close(f1); end % must close, even if not visible, otherwise in memory

   
%     clear f1 f2 k dtheta savename show_slices

else
    Logging(1, append('No valid setting Settings.SliceType= ', num2str(Settings.SliceType), '. Should be "linear" or "sector".'))
end


Logging(6, 'Slices determined successfully.')

%% Init and Determine time

Settings.Time = {};

if strcmpi(Settings.TimeInterval, 'FromFile')
    Logging(5, 'Timestamps are read from image files ...')
    for i = 1:Settings.ImageCount 
        Image = Settings.Analysis_ImageList{i};
        [~, datetimestamp, ext] = fileparts(Image);
        try
            datetimestamp_sub = ExtractSubstrFromString(datetimestamp, Settings.TimeIntervalFilenameFormat);
        catch
            Logging(1, append('It seems like not all images have the right filename to extract the datetime stamp from it. It could not be determined for: ', datetimestamp, ext, '.'))
        end
        Settings.Time{i} = datetime(datetimestamp_sub, 'InputFormat', Settings.TimeIntervalFormat); 
    end
    Settings.TimeFromStart = cellfun(@(x) seconds(time(between(Settings.Time{1}, x, 'time'))), Settings.Time);
elseif CheckIfClass('numeric', {'Settings.TimeInterval'})
    Settings.TimeFromStart = (1:Settings.ImageCount) * Settings.TimeInterval;
else
    Logging(1, append('Settings.TimeInterval= ', num2str(Settings.TimeInterval), ' is not a valid option. Choose "FromFile" or an integer.'))
end

%% X - Iterate over all images

Logging(5, '---- Height Profile calculations started.')

HeightProfiles_ForSlices_AllImages = cell(1, length(Settings.Analysis_ImageList));
HeightProfile_Mean_AllImages = cell(1, length(Settings.Analysis_ImageList));

TimeRemaining = TimeTracker;
TimeRemaining = Initiate(TimeRemaining,  length(Settings.Analysis_ImageList), 1.8);

for i = 1:Settings.ImageCount
    TimeRemaining = StartIteration(TimeRemaining);
    Image = Settings.Analysis_ImageList{i}; 

    if Settings.Display.ImageProgress && mod(i, Settings.Display.ImageProgressValue) == 0
        Logging(6, append("Image ", num2str(i), "/", num2str(Settings.ImageCount), ' being processed.'))
    end
    
    I_or = imread(Image);
    I = rgb2gray(I_or);
    I = adapthisteq(I);
    
    %% 3 - Get HeightProfile for all slices
    
    
    HeightProfiles_ForSlices = cell(Settings.NumberSlicesSelection ,1);
    number_extrema = nan(Settings.NumberSlicesSelection, 2);
    slice_lengths = nan(Settings.NumberSlicesSelection, 1);

        
    
    if Settings.Anlysismode_averaging == 1 % DOES NOT SUPPORT LINEAR SLICES YET

        no_height_profile = 0;
        first_empty_row = 1;
        for k = 1:length(Slice_Endpoints)  % iterate over all the end Slice_Endpoints (same length as all slices to analyze)
            if mod(k, round(length(Theta_Slices)/Settings.Display.HeightProfileProgressValue)) == 0 && Settings.Display.HeightProfileProgress
                Logging(6, append("Height Profile calculation for image ", num2str(i) ," at ", num2str(k/(length(Theta_Slices)/10)*10), '%.'))
            end
            pnt = floor(Slice_Endpoints(k, :));
            roi = [pnt; Settings.SectorCenter];
    
            [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, Settings);
            if Settings.IgnoreInside 
                d_final(1:Settings.Analyze_TwoParts_CutOff) = NaN;
            end
    
            if isnan(d_final)
                no_height_profile = no_height_profile + 1;
            end
            number_extrema(k, 1:2) = [length(pks), length(mns)];
            slice_lengths(k) = length(c_or);
    
            [xx, yy] = fillline(Settings.SectorCenter, pnt, length(d_final));
            if length(d_final) ~= 1
                HeightProfiles_ForSlices{k} = [xx', yy', d_final'];
                first_empty_row = first_empty_row + length(xx);
            end
            
    
            % Plot one slice
            if k == Settings.PlotSingleSlice
                f4 = Plot.SingleSliceAnalysis(Settings, struct('c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k));
                SaveFigure(min([Settings.Save_Figures Settings.Plot_SingleSlice]), f4, save_extensions, append(basename_Slice, '_Slice', num2str(k), '_', num2str(i)));
                if ~Settings.Display.IndividualPlots; close(f4); end % must close, even if not visible, otherwise in memory
            end
    
            clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns d_final
    
        end % iteration over all slices
    elseif Settings.Anlysismode_averaging == 2
        
        no_height_profile = 0;
        first_empty_row = 1;
        cel_AllSlices = cell(1,Settings.NumberSlicesSelection);
        for k = 1:Settings.NumberSlicesSelection  % iterate over all the end Slice_Endpoints (same length as all slices to analyze)
            PntStart = floor(Slice_Startpoints(k, :));
            PntEnd = floor(Slice_Endpoints(k, :));
            roi = [PntEnd; PntStart];


%             pnt = floor(Slice_Endpoints(k, :));
%             roi = [pnt; Settings.SectorCenter];
            cel_AllSlices{k} = improfile(I, roi(:,1), roi(:,2), norm(roi(1,:)'-roi(2,:)')); 
        end
        % determine the length of the longest slice and include some extra distance, since we need to offset the data to
        % align better.
        max_length = max(cellfun(@(x) length(x), cel_AllSlices)) + max(Distance_IntersectToEnd) - min(Distance_IntersectToEnd);
        arr_AllSlices = nan(length(Slice_Endpoints), max_length);
        
        for m=1:Settings.NumberSlicesSelection
            % We want an array with all the slices, but since the slices have different lengths, we need to fill in nan for
            % the shorter ones. Also, we want to align the slices on the Slice_Startpoints line in linear case. The latter is
            % done using the Distance_IntersectToEnd.

            
            startpnt = max(Distance_IntersectToEnd) - Distance_IntersectToEnd(m) + 1;
            arr_AllSlices(m, startpnt : startpnt + length(cel_AllSlices{m}) - 1) = flip(cel_AllSlices{m});
            clear startpnt


%             arr_AllSlices(m,1:length(cel_AllSlices{m})) = cel_AllSlices{m}; % CHANGE THIS: now aligning on first datapoints, needs to be on analysis line
%             arr_AllSlices(m,max_length-length(cel_AllSlices{m})+1:end) = cel_AllSlices{m};

        end
        arr_AllSlices = flip(arr_AllSlices,2);

        arr_AverageSlice = mean(arr_AllSlices, 1, 'omitnan'); %TODO also nan if less than n datapoints (e.g. 3).
        
        [c_or, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(NaN, NaN, Settings, arr_AverageSlice');


        if Settings.IgnoreInside 
            d_final(1:Settings.Analyze_TwoParts_CutOff) = NaN;
        end

        %TODO: check if nan. PLUS LOT OF REDUDANT CODE NOW. 
        number_extrema(k, 1:2) = [length(pks), length(mns)];
        slice_lengths(k) = length(c_or);

        [xx, yy] = fillline(PntStart, PntEnd, length(d_final));
        if length(d_final) ~= 1
            HeightProfiles_ForSlices{k} = [xx', yy', d_final'];
            first_empty_row = first_empty_row + length(xx);
        end

        Settings.Plot_ResultPlot = true;
        f9 = Plot.ResultPlot(Settings, struct('Image',Image, 'Slice_Startpoints',Slice_Startpoints, 'Slice_Endpoints',Slice_Endpoints, 'I',I, 'c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k, 'Distance_IntersectToEnd', Distance_IntersectToEnd));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_ResultPlot]), f9, save_extensions, append(basename_FinalSlice, '_FinalSlice', num2str(k), '_', num2str(i)));
        if ~Settings.Display.IndividualPlots; close(f9); end % must close, even if not visible, otherwise in memory
            
        % Plot one slice
        f4 = Plot.SingleSliceAnalysis(Settings, struct('c_or',c_or, 'c_nor',c_nor,  'pks',pks, 'pks_locs',pks_locs, 'mns',mns, 'mns_locs',mns_locs, 'd_final',d_final, 'slicenumber',k));
        SaveFigure(min([Settings.Save_Figures Settings.Plot_SingleSlice]), f4, save_extensions, append(basename_Slice, '_Slice', num2str(k), '_', num2str(i)));
        if ~Settings.Display.IndividualPlots; close(f4); end % must close, even if not visible, otherwise in memory

        HeightProfile_Mean = d_final;
%         clear pnt roi xx yy c_l c_nor c_or mns_locs pks_locs pks mns d_final

    end



    if no_height_profile == length(Slice_Endpoints)
        Logging(1, 'No height profiles could be calculated for any of the slices. Check if slices are not to short')
    elseif no_height_profile > 0
        Logging(3, append('A height profile could not be calculated for ', num2str(no_height_profile), '/', num2str(length(Slice_Endpoints)), ' slices.'))
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
    SaveFigure(min([Settings.Save_Figures Settings.Plot_AverageHeight]), f6, save_extensions, append(basename_AverageSlice, '_AverageSlice', num2str(i)));
    if ~Settings.Display.IndividualPlots; close(f6); end % must close, even if not visible, otherwise in memory

    Logging(6, append('Plotting finished successfully for image ', num2str(i), '.'))
    
    %% Return from loop
    HeightProfiles_ForSlices_AllImages{i} = HeightProfiles_ForSlices;
    HeightProfile_Mean_AllImages{i} = HeightProfile_Mean;
    
    clear f5 f6 f7 f8 data data_all
    
    [TimeRemaining, TimeLeft] = EndIteration(TimeRemaining);
    if TimeLeft
        Logging(5, TimeLeft)
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
    save(append(basename, '_results.mat'), 'Settings', 'HeightProfiles_ForSlices_AllImages', 'Slice_Endpoints', 'HeightProfile_Mean_AllImages')
    % note: original slices c are not saved.
end

Logging(6, 'Saving finished successfully.')

% clear data_cell_noempties Slice_Endpoints I I_or I_size LogLevel number_extrema slice_lengths Theta_Slices basename
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



