function intersect = GetIntersectsImageBorder(intersect_point, theta, image_size)
    % GETINTERSECTSIMAGEBORDER  Get coordinates of point where a line at
    % angle theta (CCW from y=0, i.e. positive y direction) through point
    % intersect_point intersects the border of an image.
    %   intersect = GETINTERSECTSIMAGEBORDER(intersect_point, theta,
    %   image_size).


        % y = ax+b => y = tan(theta)*x + (y0 - tan(theta)x0), where (x0,y0) is img_cntr
        %    or a'+y+b' = 0 => a' = -a, b' = -b (needed form).
    theta = mod(theta, 2*pi);
    x0 = intersect_point(1);
    y0 = intersect_point(2);
    a = tan(theta);
    b = y0 - (tan(theta)*x0);
    dline = [a, -1, b];

    intersect_edge = lineToBorderPoints(dline, image_size);  % get the intersection with the image edge (2 points)
    % We only want the intersection with a single point. Since
    %   lineToBorderPoints is random, we convert cartesian to radian, look at
    %   what angle (polangle) the found points are compared to the
    %   intersect_point, and pick the point that corresponds with the theta.
    intersect_edge2 = {intersect_edge(1:2), intersect_edge(3:4)};  %cell version
    [polangle, ~] = cart2pol(intersect_edge([1 3])-intersect_point(1), intersect_edge([2 4])-intersect_point(2));
    polangle = mod(polangle, 2*pi);  % convert -pi to pi (matlab standard for polar) to 0 to 2pi.
    [~, idx] = min(abs(polangle - theta));  % find which one is closest to the angle we look for (should be exactly the same)
    intersect = intersect_edge2{idx};
end