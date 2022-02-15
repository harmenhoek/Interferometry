addpath('functions')

Settings = struct();

Settings.ImageSkip = 1;
Settings.FrameRate = 5;
Settings.Resize = 1;
Settings.Save_Folder = 'results';

Settings.Time.Interval = 10;
Settings.Time.ShowTime = true;
Settings.Time.FontSize = 50;
Settings.Time.Round = 0;
Settings.Time.Unit = 'min'; %supported: variable, min, sec, hrs, auto

global LogLevel
LogLevel = 5;

%% Start

clc
Logging(5, append('Code started on ', datestr(datetime('now')), '.'))


%% User Input

Logging(2, 'Select the folder with images for video.')
Settings.Source = uigetdir;

%% Load Files

tic
Settings.Source_ImageList = {};
for ext = {'.tif', '.tiff', '.png', '.jpg', '.jpeg', '.bmp', '.gif'} %check for images of this type in source folder and append to imagelist if they exist.
    images = dir(append(Settings.Source, '\*', ext{1}));
    images_fullpath = cellfun(@(x) append(x.folder, '\', x.name), num2cell(images), 'UniformOutput', false);
    Settings.Source_ImageList = [Settings.Source_ImageList, images_fullpath];
end

Settings.Source_ImageList = natsortfiles(Settings.Source_ImageList); % Stephen (2022). Natural-Order Filename Sort (https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort), MATLAB Central File Exchange. Retrieved January 27, 2022. 
Settings.Analysis_ImageList = Settings.Source_ImageList(1:Settings.ImageSkip:length(Settings.Source_ImageList));

if isempty(Settings.Source_ImageList)
    Logging(1, 'No images found in Source folder.')
else
    Logging(5, append(num2str(length(Settings.Source_ImageList)), ' images found in Source folder, ', num2str(length(1:Settings.ImageSkip:length(Settings.Source_ImageList))), ' will be merged to a video (every ', num2str(Settings.ImageSkip), ' image(s)).'))
end

%% Generate filename

% TODO link to original file, and save in more reasonable folder.

[~, name, ~] = fileparts(Settings.Source_ImageList{1});
stamp = append('PROC',  datestr(now, 'YYYYmmddHHMMSS'));
savefolder_sub = append(Settings.Save_Folder, '\', stamp);

%% Create video

outputVideo = VideoWriter(append(Settings.Save_Folder, '\', stamp));
outputVideo.FrameRate = Settings.FrameRate;

TimeRemaining = TimeTracker;
TimeRemaining = Initiate(TimeRemaining,  length(Settings.Analysis_ImageList), 0);

open(outputVideo)
for ii = 1:length(Settings.Analysis_ImageList)
    TimeRemaining = StartIteration(TimeRemaining);
    
	img = imread(Settings.Analysis_ImageList{ii});
    img = imresize(img, Settings.Resize);
    if Settings.Time.ShowTime
        t = ((ii-1) * Settings.Time.Interval) * Settings.ImageSkip;
        if strcmpi(Settings.Time.Unit, 'variable')           
            if t < 60
                StrTime = append(num2str(t), ' s');
            elseif t < 3600
                StrTime = append(num2str(round(t/60,Settings.Time.Round)), ' min');
            else
                StrTime = append(num2str(round(t/3600,Settings.Time.Round)), ' hours');
            end
        elseif strcmpi(Settings.Time.Unit, 'sec')
            StrTime = append(num2str(t), ' s');
        elseif strcmpi(Settings.Time.Unit, 'min')
            StrTime = append(num2str(round(t/60,Settings.Time.Round)), ' min');
        elseif strcmpi(Settings.Time.Unit, 'hrs')
            StrTime = append(num2str(round(t/3600,Settings.Time.Round)), ' hours');
        elseif strcmpi(Settings.Time.Unit, 'auto')
            totaltime = length(Settings.Analysis_ImageList) * Settings.Time.Interval;
            if totaltime < 60
                StrTime = append(num2str(t), ' s');
            elseif totaltime < 3600
                StrTime = append(num2str(round(t/60,Settings.Time.Round)), ' min');
            else
                StrTime = append(num2str(round(t/3600,Settings.Time.Round)), ' hours');
            end
        else
            Logging(1, append('No valid Settings.Time.Unit = "', num2str(Settings.Time.Unit), '". Choose variable, sec, min, hrs, auto.'))
        end

        img = insertText(img, [10 10], ...
            append('t = ', StrTime), ...
            'FontSize', Settings.Time.FontSize, ...
            'BoxColor', 'white', ...
            'BoxOpacity', 0.4, ...
            'TextColor', 'black');
        writeVideo(outputVideo, img)
    end
    
    [TimeRemaining, TimeLeft] = EndIteration(TimeRemaining);
    Logging(5, TimeLeft)
end
close(outputVideo)


%% Finish



elapsedtime = toc;
Logging(5, append('Code finished successfully in ', num2str(round(elapsedtime)), ' seconds.'))

clear elapsedtime

