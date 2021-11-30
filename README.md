# Interferometry
 MATLAB program for analyzing interferometry images

## About


## How to use

## Settings


## Code overview

The main code requires several functions:
- `Logging.m` Takes care of logging data clearly to the screen. Logging level can be set.
- `GetIntersectsImageBorder.m` Calculates the intersection point of a line through a point in the image at a certain angle.
- `HeightProfileForSlice.m` 

### Logging.m


### GetIntersectsImageBorder.m
`function intersect = GetIntersectsImageBorder(intersect_point, theta, image_size)`
Get coordinates of point where a line at angle theta (CCW from y=0, i.e. positive y direction) through point intersect_point intersects the border of an image.

- `intersect_point` is the starting point of the line as [x, y]. 
- `theta` is the angle in CCW direction from y=0 (3 o'clock position). Note that when plotting an image y is reversed, thus direction becomes CW.
- `image_size` is the size of the image as [height, width] TODO verify

The result `intersect` is [x, y] of the intersect with the image edge.

Note: this function requires the standard `lineToBorderPoints` which is included in the XXX extension TODO

### HeightProfileForSlice.m
