Note: documentation last updated on January 3.

# Sɪɴɢʟᴇ Wᴀᴠᴇʟᴇɴɢᴛʜ Rᴇғʟᴇᴄᴛɪᴏɴ Iɴᴛᴇʀғᴇʀᴏᴍᴇᴛʀʏ Aɴᴀʟʏsɪs
 MATLAB program for analyzing single wavelength interference microscopy images.

## About
This MATLAB program converts inteferometry images obtained using single wavelength interference microscopy into a height profile.
Program limitations:

- Images need to be recorded at a single wavelength (can be a finite bandwidth, in that case give the average wavelength.)
- Surface of the interference pattern needs to be monotomically increasing or decreasing, i.e. there can not be any local maxima.
- The program can only determine a relative height profile, i.e. there needs to be a known height in the pattern to obtain exact heights. This is a limatition of single wavelength interferometry.

## Table of Content

[TOC]

## Usage

1. Open file `InterferometryMain.m`.
2. Update the `filename` at the top of the code if necessary, and `img_cntr` (highest point in image) if available. The letter is not required.
3. Check the settings in de code (explained below).
4. Run the code.

## Workings

The 2D interferometry image (image 1) is split up in 1D radial intensity slices originating from an image center (image 2). Each slice (image 3) is normalized and then analyzed seperately by detecing all the extrema in the intensity profile (image 4). Assuming the height difference between 2 maxima or 2 minima in the spectrum is the wavelength / 2, and this intensity varies with a cosine, we can fit each section of the spectra between 2 extrema with the model (image 5). The resulting height profiles between all extrema are stitched together to make a full height profile for each slice (image 6). Combining these height profiles for all slices and using interpolation results in a 3D height map of the surface (image 7a, 7b, 7c).

| <div style="width:33%"><img src="screenshots\1_raw.jpg" style="zoom:15%;" />1. Original image (compressed) | <div style="width:33%"><img src="screenshots\2_slices.png" style="zoom:33%;" />2. Image enhancement <br />+ slice determination</div> | <div style="width:33%"><img src="screenshots\3_slice.png" style="zoom:33%;" />3. Individual slice analysis</div> |
| :----------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="screenshots\4_sliceanalysis.png" style="zoom:33%;" />4. Spectrum normalization<br />+ smoothing + peak detection</div> | <img src="screenshots\5_modelfitting.png" style="zoom:33%;" />5. Extrema-extrema model fitting | <img src="screenshots\6_sliceheight.png" style="zoom:33%;" />6. Stitched height profile for one slice |
| <img src="screenshots\7a_contourmap.png" style="zoom:33%;" />7a. Combined slices into a contour map | <img src="screenshots\7b_3dsurface.png" style="zoom:33%;" />7b. 3D surface map | <img src="screenshots\7c_averagedslice.png" style="zoom:33%;" />7c. Averaged slice for a pi/8 sector |

Note: The interferometry pattern shown above has local extrema that cannot be detected, resulting in incorrect slices.

## Configuration

**Basic settings**

| Setting                  | Type          | Description                                                  |
| ------------------------ | ------------- | ------------------------------------------------------------ |
| `filename`               | string        | Path to single image path                                    |
| `img_cntr`               | array [x, y]  | Center point of all the radial slices (highest point in the image). From here all the radial slices will originate. Optional. If not set, GUI allows to select it in the image. |
| `Lambda`                 | double        | Wavelength of the light used in the image in meters (if finite bandwidth, define center). |
| `NumberSlices`           | double        | Total number of radial slices (originating in `img_cntr`) in the full 2pi. |
| `AnalyzeSector`          | boolean       | If `true`,  only a sector (between `SectorStart` (double) and `SectorEnd` (double)) of the full 2pi will be analyzed. |
| `EstimateOutsides`       | boolean       | If `true`, before first extrema and after last extrema will be estimated, otherwise these datapoints will be filled in `NaN`. See `HeightProfileForSlice.m` function description below for explanation of this setting. |
| `FilterBy_AmountExtrema` | boolean       | If `true`, slices will be disregarded if the amount of extrema in a slice deviates more than AmountExtrema_MaxDeviation from the median amount of all slices. Note: the full 2pi is analyzed, and the origin is not centered, many slices will be discarded. Recommened use only when analyzing short sector. Example below. |
| `LogLevel`               | integer [1-6] | Log level depth. If 1, only errors will be shown. See all levels at `Logging.m` function below. |

## Examples

### Example 1: full surface map of oil drop

### Example 2: sector of

| `FilterBy_AmountExtrema = false`                             | `FilterBy_AmountExtrema = true`<br />`AmountExtrema_MaxDeviation = 0.05` |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="screenshots\FilterBy_AmountExtrema_false.png" style="zoom: 33%;" /> | <img src="screenshots\FilterBy_AmountExtrema_true.png" style="zoom: 33%;" /> |



## Codes overview

- `InterferometryMain.m` The main code.
- `Logging.m` Takes care of logging data clearly to the screen. Logging level can be set.
- `GetIntersectsImageBorder.m` Calculates the intersection point of a line through a point in the image at a certain angle.
- `HeightProfileForSlice.m` Calculates the height profile for an intensity profile.
- `ModelFit.m` Fits a section of an intensity profile to a model to get the corresponding height.
- `GetMedians.m` Gets the median of several datapoints at the start and end of a dataset.
- `cprintf.m` See https://nl.mathworks.com/matlabcentral/fileexchange/24093-cprintf-display-formatted-colored-text-in-command-window.

### InterferometryMain.m

This is the code to run when using this program. The code uses all the functions below. Step-by-step what this code does:

1. Settings are checked if valid.
2. Image is read, converted to grayscale and the contrast is increased.
3. If no image center (`img_cntr` variable) is set by user, the user is asked to pick the center  point of the interferometry pattern (highest point in image).
4. Using the `img_cntr` as origin, the image slices are determined using the `GetIntersectsImageBorder` function.
5. The code iterates over all slices (start-end coordinates). For each slice the function `HeightProfileForSlice` is ran to calculate the height profile of an interferometry spectrum. The corresponding x,y coordinates for each datapoint is determined using `fillline`. If no height profile can be determined (e.g. when no maxima is found, NaN is returned for that slice).
6. If set by user settings, data is filtered. The current version only allows filtering by deviations in the number of extrema compared to the median number of extrema.
7. Data is plotted. For the 3D surface plot and contour plot the x,y,z data of all the slices is interpolated to a rectangular grid and duplicates are averaged. For the slice average, the

### Logging.m

`function Logging(type, message)`
To log a message to the screen in a consistent format.

Input: 

- `type` is the number corresponding to a type of message:

  | `type` | Message  | Color             | Explanation                                                  |
  | ------ | -------- | ----------------- | ------------------------------------------------------------ |
  | 1      | ERROR    | red               | Code cannot continue. Will throw an error and stop execution. |
  | 2      | ACTION   | blue (underlined) | User needs to do something.                                  |
  | 3      | WARNING  | orange            | Code can continue, but user should note something (decision made by code e.g.). |
  | 4      | PROGRESS | white             | Show user that something is being done now, e.g. when wait is long. |
  | 5      | INFO     | cyan              | Information about code progress. E.g. 'Figures are being saved'. |
  | 6      | OK       | green             | Just to show progress is going on as planned.                |

- `message` is a string with the message.

Output:

<img src="screenshots\Logging_output.png" style="zoom:75%; align:left;" />

Usage:

- At the top of the code, define the log level (if not, only error messages are shown).
  `global LogLevel` defines a global variable
  `LogLevel = 3` sets the log level. All log messages in the code set to `type`<= 3 will be shown.

- In the code, use when needed

  `Logging(3, 'This is a warning, and will be displayed orange')`to display a warning, for example.


### GetIntersectsImageBorder.m
`function intersect = GetIntersectsImageBorder(intersect_point, theta, image_size)`
Get coordinates of point where a line at angle theta (CCW from y=0, i.e. positive y direction) through point intersect_point intersects the border of an image.

Input:
- `intersect_point` is the starting point of the line as [x, y]. 
- `theta` is the angle in CCW direction from y=0 (3 o'clock position). Note that when plotting an image y is reversed, thus direction becomes CW.
- `image_size` is the size of the image as [height, width] TODO verify

Output:
- `intersect` is [x, y] of the intersect with the image edge.

Note: this function requires the standard `lineToBorderPoints` which is included in the XXX extension TODO

### HeightProfileForSlice.m
`[c, c_nor, d_final, pks_locs, mns_locs, pks, mns] = HeightProfileForSlice(I, roi, lambda, HeightResolution, EstimateOutsides)`
Calculates the corresponding height profile for intensity slice using `ModelFit.m`

The code gets the intensity slice between 2 coordinates (`roi`) in the image. The peaks in this intensity slide are calculated using `findpeaks`. Between each extrema the data is normalized and fitted with the model (`ModelFit`). The result is a height profile between each extream (height 0-n). All the seperate heigh profiles are stitched together to get a full height profile (`d_final`).

Input:
- `I` is the image (only BW tested).
- `roi` are the 2 end coordinates in the image for the slice as [x1 y1; x2; y2].
- `lambda` is the wavelength of the light used in the image (in meters).
- `HeightResolution` is the maximum step-size resolution of the final height (see `ModelFit`).
- `EstimateOutsides` `true` or `false` for fitting first (before first extrema) and last (after last extrema) section.
 This is tricky. In the ideal world the intensity of each maximum and minimum of the intereferometry pattern is equal (0 or 1). But this is not the case in reality. Therefore we have to find the peaks in the spectrum, and fit the model to the normalized dataet between each extrema. This does not work for the first and last dataset (before first extrema and after last extrema), since we have no idea what the intensity of the actual maximum (out of frame) is going to be. Safest approach is to skip these sections (EstimateOutsides = false), an estimation can be made (EstimateOutsides = true) by assuming the extrema of this section is the average of the extrema that are visible. Note: it happens that the first or last datapoint is actual greater than the average extrema. In that case we assume it to be a real extrema and treat it like any other extrema.

Output:
- `c` is the intensity of the original slice. `c(1)` is at `(x2, y2)`.
- `c_nor` is the normalized (0-1) version of `c`.
- `d_final` is the final height profile (same lengths as `c` and `c_nor`).
- `pks_locs` are the locations of all the detected peaks.
- `mns_locs` are the locations of all the detected minima.
- `pks` are the values of all the detected peaks.
- `mns` are the values of all the detected minima.

Note: if no peaks are found, the function returns `NaN` for `d_final`, `pks_locs`. `mns_locs`, `pks` and `mns`.



### ModelFit.m

`height = ModelFit(intensity, wavelength, HeightResolution)` 
Converts an half-period intensity slice to a height profile.

This functions takes a half-period intensity slice (`intensity`), i.e. the intensity profile between 2 extrema, and converts it to a `height` profile using simple cosine fitting.
As a model, a cosine is used: `intensity = cos(4 * pi / wavelength * d + 1) / 2`. The equation is numerically solved for N values and then for each intensity value the closest height is found. `N = wavelength / 4 / HeightResolution`. The stepsize in the height `d`is thus `HeightResolution` which results in a step size of the final height profile of less than `HeightResolution`.

Input:

- `intensity` is the intensity profile. Note: input have a period, thus only between 2 extrema.
- `wavelength` is the wavelength of the light used in the image (in meters).
- `HeightResolution`is the maximum step size in the final height (in meters). 2nm is a good value.

Output:

- `height` is the final height profile

### GetMedians.m

`[y_start, y_end] = GetMedians(y, max_samples)`
Return the median at the start and begin of an array `y` of a maximum of `max_samples` data points.

Example: `GetMedians(y, 10)` will return `(y(1:10), y(end-10:end))`if `y` has more than 10 datapoints, and `(y(1:L), y(end-L:end))` where `L` is the number of datapoints in `y` if `y` has less than 10 datapoints.

Input:

- `y` is a 1D dataset.
- `max_samples` is the maximum bin size of the median. 

Output:

- `y_start` is the  median of `max_samples` or less datapoints in at the start of array `y`.
- `y_end` is the  median of `max_samples` or less datapoints in at the end of array `y`.

### fillline.m

Determines all the coordinates between 2 points.

### CheckIfClass.m

`[status] = CheckIfClass(checkclass, variables)`
CheckIfClass  Checks if the input variables (cell with variables as strings) are all of the type checkclass ('logical', 'char' or 'numeric').
   [status] = CheckIfClass(checkclass, variables) 
Displays to screen the variables that are do not satisfy the checkclass and returns 'status' which is 0 if checks fail (this allows to see a list of all variables that need to be fixed.

Function needs Logging.m!

Example:
    `variable1 = 'This is a string';`
    `variable2 = true;`
    `variable3 = 34.53;`
    `[status] = CheckIfClass('logical', {'variable1', 'variable2', 'variable3'}`
Result:
    `WARNING   Variable "variable1" should be logical, but is not (currently a char).`
    `WARNING   Variable "variable3" should be logical, but is not (currently a double).`
    `status =`
    `       0`

Input:

- `checkclass` is a string with the dataclass to check against ('logical', 'char' or 'numeric').
- `variables` is a cell with variables as strings.

Output:

- Output to screen with variables that fail check.
- `status` is 0 when one or more checks fail, 1 when all pass.


## Work in Progess

