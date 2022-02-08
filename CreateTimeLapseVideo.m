Settings = struct();

Settings.ImageSkip = 1;
Settings.FrameRate = 24;
Settings.Resize = 0.5;
Settings.Save_Folder = 'results';

global LogLevel
LogLevel = 5;
    

Logging(2, 'Select the folder with images for video.')
Settings.Source = uigetdir;

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

%% Filename

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
	writeVideo(outputVideo, img)
    
    [TimeRemaining, TimeLeft] = EndIteration(TimeRemaining);
    Logging(5, TimeLeft)
end
close(outputVideo)

