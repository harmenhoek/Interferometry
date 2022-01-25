function height = ModelFit(intensity, wavelength, HeightResolution)
    % This is the main model for converting intensity pattern to height.
    % This most simple approach uses the fact that between 2 interferometry
    % peaks, the distance traveled by the light is lambda/2. The shape of
    % the interference pattern is ~cos(kx-wt).
    
   
    LUT_datapoints = (wavelength/4) / HeightResolution;
    height = nan(1, length(intensity));
    for j = 1:length(intensity)
        % TODO: do part below better. Use the exact solution instead!
        if intensity(end) < intensity(1) % 1st part down: 0 till lambda/4
            d_mod2 = linspace(0, wavelength/4, LUT_datapoints);
            I_mod2 = (cos(4*pi/wavelength*d_mod2) + 1)/2;
            [~, indexOfMin] = min(abs(intensity(j)-I_mod2));
            height(j) = d_mod2(indexOfMin);
        else % 2nd part up: lambda/4 till lambda/2
            d_mod2 = linspace(wavelength/4, wavelength/2, LUT_datapoints);
            I_mod2 = (cos(4*pi/wavelength*d_mod2) + 1)/2;
            [~, indexOfMin] = min(abs(intensity(j)-I_mod2));
            height(j) = d_mod2(indexOfMin)-wavelength/4;
        end
    end
%     if partial
%         size(d_mod2)
%         size(I_mod2)
%         figure
%         yyaxis left
%         plot(I_mod2, d_mod2)
%         hold on
%         yyaxis right
%         plot(ydata, xdata)
%         title('MODEL')
%     end
end