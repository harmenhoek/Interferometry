classdef Plot
    methods (Static)
        
        function Analyze_TwoParts_CutOff = VisualizeSlicesCutOff(Settings, FigData)
            f = figure('visible', 'on');
            imshow(FigData.I)
            hold on
            for k = 1:Settings.NumberSlicesSelection
                PntStart = floor(FigData.Slice_Startpoints(k, :));
                PntEnd = floor(FigData.Slice_Endpoints(k, :));
                roi = [PntEnd; PntStart];
                plot(roi(:,1), roi(:,2), 'Color', 'red', 'LineWidth', 2)
                plot(PntStart(:,1), PntStart(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                plot(PntEnd(:,1), PntEnd(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                text(PntEnd(:,1), PntEnd(:,2), num2str(k))
                clear pnt roi
            end
            pnt = drawpoint;

            if strcmpi(Settings.SliceType, 'sector')
                Analyze_TwoParts_CutOff = round(norm(pnt.Position-FigData.Slice_Endpoints(k)));
            elseif strcmpi(Settings.SliceType, 'linear')
                Analyze_TwoParts_CutOff = ceil(point_to_line([pnt.Position 0], [Settings.LinearStart 0], [Settings.LinearEnd 0]));
            end

            close(f)
        end % f = VisualizeSlicesCutOff
        
        function f = VisualizeSlices(Settings, FigData)
            if Settings.Plot_VisualizeSlices && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                imshow(FigData.I)
                hold on
                for k = 1:Settings.NumberSlicesSelection
                    PntStart = floor(FigData.Slice_Startpoints(k, :));
                    PntEnd = floor(FigData.Slice_Endpoints(k, :));
                    roi = [PntEnd; PntStart];
%                     pnt = FigData.points(k, :);
%                     roi = [pnt; Settings.Interferometry_Center];
                    plot(roi(:,1), roi(:,2), 'Color', 'red', 'LineWidth', 2)
                    plot(PntStart(:,1)+1, PntStart(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                    plot(PntEnd(:,1), PntEnd(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                    text(PntEnd(:,1), PntEnd(:,2), num2str(k))
                    clear pnt roi
                end
                if Settings.Analyze_TwoParts
                    if strcmpi(Settings.SliceType, 'sector')
                        if Settings.AnalyzeSector
                            plot_arc(Settings.SectorStart, Settings.SectorEnd, Settings.SectorCenter(1), Settings.SectorCenter(2), Settings.Analyze_TwoParts_CutOff)
                        else 
                            plot_arc(0, 2*pi, Settings.Interferometry_Center(1), Settings.Interferometry_Center(2), Settings.Analyze_TwoParts_CutOff)
                        end
                    elseif strcmpi(Settings.SliceType, 'linear')
                        x1 = Settings.LinearStart(1) + Settings.Analyze_TwoParts_CutOff * cos(Settings.LinearAngle);
                        y1 = Settings.LinearStart(2) + Settings.Analyze_TwoParts_CutOff * sin(Settings.LinearAngle);
                        x2 = Settings.LinearEnd(1) + Settings.Analyze_TwoParts_CutOff * cos(Settings.LinearAngle);
                        y2 = Settings.LinearEnd(2) + Settings.Analyze_TwoParts_CutOff * sin(Settings.LinearAngle);
                        plot(x1, y1, '.', 'MarkerSize', 25, 'Color', 'black')
                        plot(x2, y2, '.', 'MarkerSize', 25, 'Color', 'black')
                        plot([x1 x2], [y1 y2], ':', 'LineWidth', 4, 'Color', 'black')
                    end
                end
            else
                f = [];
            end
        end % f = VisualizeSlices
        
        function f = SingleSliceAnalysis(Settings, FigData)
            if Settings.Plot_SingleSlice && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                tiledlayout(3,1,'TileSpacing','tight');
        
                c_l = 1:length(FigData.c_or);
                nexttile;
                plot(c_l, FigData.c_or, 'Color', 'red', 'LineWidth', 2)
                xlabel('Distance from center [pix]')
                ylabel('Intensity [arb. units]')
                xlim([0, max(c_l)])
                title(strcat('Original slice #', num2str(FigData.slicenumber)))

                nexttile;
                line(c_l, FigData.c_nor, 'Color', 'red', 'LineWidth', 2)
                hold on
                plot(c_l(FigData.pks_locs), FigData.pks, '.', 'MarkerSize', 20, 'Color', 'black')
                plot(c_l(FigData.mns_locs), -FigData.mns, '.', 'MarkerSize', 20, 'Color', 'green')
                xlabel('Distance from center [pix]')
                ylabel('Intensity [arb. units]')
                xlim([0, max(c_l)])
                title('After img adjustments and normalization')

                nexttile;
                plot(c_l ./ Settings.ConversionFactorPixToMm, FigData.d_final.*1e6, 'Color', 'blue', 'LineWidth', 2)
                xlabel(sprintf('Distance from center [%s]', Settings.DistanceUnit))
                ylabel('Height [um]')
                xlim([0, max(c_l) ./ Settings.ConversionFactorPixToMm])
                title('Height profile after model fit')
            else
                f = [];
            end
        end % f = SingleSliceAnalysis
        
        function f = Surface(Settings, FigData)
            if Settings.Plot_Surface && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                [newXY,~,locMembers] = unique([FigData.data_all(:,1), FigData.data_all(:,2)], 'rows', 'stable');  % if slices overlap, filter out doubles
                xx = newXY(:,1)';
                yy = newXY(:,2)';
                zz = splitapply(@(v) mean(v), FigData.data_all(:,3)', locMembers');  % group the values of z by the duplicate pairs, take the mean
                T = delaunay(xx, yy);
                trisurf(T, yy, xx, -zz+max(zz), 'EdgeColor', 'none')
                % 3d scatter plot
                % scatter3(data_all(:,1), data_all(:,2), data_all(:,3), [], data_all(:,3), 'filled')
            else
                f = [];
            end
        end % f = Surface
        
        function f = Contour(Settings, FigData)
            if Settings.Plot_Contour && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                
                if Settings.Plot_Contour_OverlayOnImage
                    imshow(FigData.I_or)
                    hold on
                end
                % tri surface
                x = FigData.data_all(:,1);
                y = FigData.data_all(:,2);
                z = FigData.data_all(:,3);
                [xq,yq] = meshgrid(linspace(min(x),max(x),sqrt(length(x))), ...
                    linspace(min(y),max(y),sqrt(length(y))));
                warning('off', 'all')  % TODO: remove duplicate x,y datapoints (average z). Now this throws a warning by griddate (and it is done automatically).
                    vq = griddata(x,y,z,xq,yq);
                warning('on', 'all')
                % s = surf(yq,xq,-vq+max(max(vq)),'EdgeColor','none', 'FaceLighting','gouraud');
                linetype = '-';  % '-' ':' ':' '-,'  or add colors: '--g'
                [~, hContour] = contourf(xq,yq,vq, Settings.Plot_Contour_Levels, linetype);
                hContour.LineWidth = .2;
                hContour.LineColor = [.5 .5 .5];
                if Settings.Plot_Contour_OverlayOnImage
                    drawnow;
                    hFills = hContour.FacePrims;  % array of TriangleStrip objects
                    [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
                    for idx = 1 : numel(hFills)
                        hFills(idx).ColorData(4) = Settings.Plot_Contour_Transparency * 255;   % default=255
                    end
                end
                set(gca, 'YDir','reverse')
                ylim([0, size(FigData.I_or, 1)])
                xlim([0, size(FigData.I_or, 2)])
                colorbar;
            else
                f = [];
            end
        end % f = Contour
        
        function f = AverageHeight(Settings, FigData)
            if Settings.Plot_AverageHeight && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                plot((1:length(FigData.HeightProfile_Mean)) ./ Settings.ConversionFactorPixToMm, FigData.HeightProfile_Mean * 1e6, 'LineWidth', 3)
                xlabel(sprintf('Distance from center [%s]', Settings.DistanceUnit))
                ylabel('Height [µm]')
            else
                f = [];
            end
        end % f = AverageHeight
        
        function f = AverageHeight_AllImages(Settings, FigData)
            if Settings.Plot_AverageHeightAllImages && (Settings.Save_Figures || Settings.Display.TotalPlots)
                if Settings.Display.TotalPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                
                MinStepSizeTime = min(diff(Settings.TimeFromStart));
                FullTimeScale = Settings.TimeFromStart(1):MinStepSizeTime:Settings.TimeFromStart(end);
                map = parula(length(FullTimeScale)); % create colormap with all possible timesteps.


                hold on
%                 map = parula(length(FigData.HeightProfile_Mean_AllImages));
                
                if Settings.Plot_AverageHeightAllImages_EquivPoint < 1  % we want EquivPoint to be an Setting, so use negative to work backwards. STUPID MATLAB works with 'end' to indicate last value, so extra code here ...
                    equiv_value = max(cellfun(@(x) x(end+Settings.Plot_AverageHeightAllImages_EquivPoint), FigData.HeightProfile_Mean_AllImages));
                else
                    equiv_value = max(cellfun(@(x) x(Settings.Plot_AverageHeightAllImages_EquivPoint), FigData.HeightProfile_Mean_AllImages)); % the value of y(100) for every slice. to align all data
                end
                
                for i = 1:length(FigData.HeightProfile_Mean_AllImages)
                    y = FigData.HeightProfile_Mean_AllImages{i};
                    if Settings.Plot_AverageHeightAllImages_EquivPoint < 1
                        y = y + equiv_value - y(end+Settings.Plot_AverageHeightAllImages_EquivPoint);
                    else
                        y = y + equiv_value - y(Settings.Plot_AverageHeightAllImages_EquivPoint);
                    end
                    datapoints = length(FigData.HeightProfile_Mean_AllImages{i});

                    [~, indexOfMin] = min(abs(FullTimeScale-Settings.TimeFromStart(i)));
                    plot((1:datapoints) ./ Settings.ConversionFactorPixToMm, y * 1e6, 'LineWidth', 2, 'Color', map(indexOfMin,:))
                end
%                 legend(append('t=', compose('%g', Settings.TimeRange), 's'))
                xlabel(sprintf('Distance from center [%s]', Settings.DistanceUnit))
                ylabel('Height [µm]')



                
                if max(Settings.TimeFromStart) > 600
                    stepsize = round((max(Settings.TimeFromStart)/60-min(Settings.TimeFromStart/60))/5);
                    barticks = min(Settings.TimeFromStart):stepsize:max(Settings.TimeFromStart);
                    c = colorbar('TickLabels', barticks, 'Ticks', linspace(0,1,6));
                    ylabel(c, 'Time [min]', 'FontSize', Settings.PlotFontSize)
                else
                    stepsize = round((max(Settings.TimeFromStart)-min(Settings.TimeFromStart))/5);
                    barticks = min(Settings.TimeFromStart):stepsize:max(Settings.TimeFromStart);
                    c = colorbar('TickLabels', barticks, 'Ticks', linspace(0,1,6));
                    ylabel(c, 'Time [s]', 'FontSize', Settings.PlotFontSize)
                end
                xlim([0, max(cellfun(@(x) length(x), FigData.HeightProfile_Mean_AllImages)) / Settings.ConversionFactorPixToMm])
                ylim([0, max(cellfun(@(x) max(x), FigData.HeightProfile_Mean_AllImages))* 1e6]) %cell2mat needed if HeightProfile_Mean_AllImages contains empty cells
            else
                f = [];
            end
        end % f = AverageHeight_AllImages
        
        function f = ResultPlot(Settings, FigData)
            if Settings.Plot_ResultPlot && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                f.Position = [10 10 800 600];
                
                clrs = [0 0.4470 0.7410; 0.6350 0.0780 0.1840; .9763 .9831 .0538; 0.8500 0.3250 0.0980; 0.9290 0.6940 0.125];
                
                t = tiledlayout(5,3);
                
                nexttile([3 3]);
                imshow(FigData.I)
                hold on
                for k = 1:Settings.NumberSlicesSelection
                    PntStart = floor(FigData.Slice_Startpoints(k, :));
                    PntEnd = floor(FigData.Slice_Endpoints(k, :));
                    roi = [PntEnd; PntStart];
 
%                     pnt = FigData.points(k, :);
%                     roi = [pnt; Settings.Interferometry_Center];
                    plot(roi(:,1), roi(:,2), 'Color', [0.9290 0.6940 0.125 0.2], 'LineWidth', 1)
                    clear pnt roi
                end
                
                offset_x = 50;
                rectangle('Position',[offset_x-20, 100-40, offset_x+Settings.ConversionFactorPixToMm, 300], 'FaceColor', 'white', 'Curvature', 0, 'LineStyle', 'none')
                plot([offset_x offset_x+Settings.ConversionFactorPixToMm], [100 100], '-', 'Color', 'red', 'LineWidth', 3)
                text(round(offset_x+Settings.ConversionFactorPixToMm/2), 120, '1 mm', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'red')
          
                c_l = 1:length(FigData.c_or);
                x = c_l ./ Settings.ConversionFactorPixToMm;
                
                nexttile([2 3]);
                colororder([clrs(2,:);clrs(1,:)])
                yyaxis left
                c_or_nor = (FigData.c_or-min(FigData.c_or))/(max(FigData.c_or)-min(FigData.c_or));
                if Settings.PeakFitSettings.CutOff %show the cutoff line
                    plot([1 1].*(max(FigData.Distance_IntersectToEnd)+Settings.PeakFitSettings.CutOffValue)./Settings.ConversionFactorPixToMm, [-0.05 1.05], ':', 'LineWidth', 2, 'Color', 'black')
                end
                hold on
                plot(x, c_or_nor , '-', 'Color', clrs(5,:), 'LineWidth', 2)
                plot(x, FigData.c_nor,  '-', 'Color', clrs(2,:), 'LineWidth', 2)
                plot(x(FigData.pks_locs), FigData.pks, '.', 'MarkerSize', 25, 'Color', clrs(2,:))
                plot(x(FigData.mns_locs), -FigData.mns, '.', 'MarkerSize', 25, 'Color', clrs(2,:))
               
                xlabel('Distance from center [pix]')
                ylabel('Intensity [arb. units]')
                ylim([-0.05 1.05])

                yyaxis right
                plot(x, FigData.d_final.*1e6, '.-', 'Color', clrs(1,:), 'LineWidth', 3)
                xlabel(sprintf('Distance from center [%s]', Settings.DistanceUnit))
                ylabel('Height [um]')
                ylim([0 1.01*max(FigData.d_final.*1e6)])
                xlim([0, max(x)])
                l = legend({'Fit settings change', 'Average slice', 'Filtered slice', '', '', 'Height profile'}, 'Location', 'best');
                l.Units = 'normalized';
                l.Position = [0.7402 0.1267 0.1704 0.0983];
                
                t.TileSpacing = 'compact';
                t.Padding = 'compact';
                
                [~, filename, ~] = fileparts(FigData.Image);
                title(t, filename, 'Interpreter', 'none')
                
                
                
            else
                f = [];
            end
        end % f = ResultPlot


        function f = SliceImage(Settings, FigData)
            if Settings.Plot_SliceImage && (Settings.Save_Figures || Settings.Display.IndividualPlots)
                if Settings.Display.IndividualPlots
                    f = figure('visible', 'on');
                else
                    f = figure('visible', 'off');
                end
                f.Position = [10 10 2000 600];
                imagesc(FigData.slice_image)
                colormap(Settings.Plot_SliceImageColormap)
                hold on

                % make average slice fit
                a = FigData.average_slice;
                a(a==0) = nan;
                a = (a-min(a))/(max(a)-min(a)).*size(FigData.slice_image,1);
                a = flipud(a);
                plot(a, 'Color', Settings.Plot_SliceImagePlotcolor, 'LineWidth', Settings.Plot_SliceImagePlotlinewidth)   
                axis off
                title(FigData.plottitle, 'Interpreter', 'none')
            else
                f = [];
            end
        end % f = SliceImage

        
        
%         function f = AverageHeight(Settings, FigData)
%             if Settings.Plot_AverageHeight && (Settings.Save_Figures || Settings.Display.IndividualPlots)
%                 if Settings.Display.IndividualPlots
%                     f = figure('visible', 'on');
%                 else
%                     f = figure('visible', 'off');
%                 end
%             else
%                 f = [];
%             end
%         end % f = AverageHeight
        
    end
end

function P = plot_arc(a,b,h,k,r)
    % Plot a circular arc as a pie wedge.
    % a is start of arc in radians, 
    % b is end of arc in radians, 
    % (h,k) is the center of the circle.
    % r is the radius.
    t = linspace(a,b);
    x = r*cos(t) + h;
    y = r*sin(t) + k;
    P = plot(x,y,'b','LineWidth', 3);
    if ~nargout
        clear P
    end
end

function d = point_to_line(pt, v1, v2)
    a = v1 - v2;
    b = pt - v2;
    d = norm(cross(a,b)) / norm(a);
end