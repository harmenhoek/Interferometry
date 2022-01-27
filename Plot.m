classdef Plot
    methods (Static)
        
        function Analyze_TwoParts_CutOff = VisualizeSlicesCutOff(Settings, FigData)
            if Settings.Display.IndividualPlots
                f = figure('visible', 'on');
            else
                f = figure('visible', 'off');
            end
            imshow(FigData.I)
            hold on
            for k = 1:length(FigData.theta_all)
                pnt = FigData.points(k, :);
                roi = [pnt; Settings.Interferometry_Center];
                plot(roi(:,1), roi(:,2), 'Color', 'red', 'LineWidth', 2)
                plot(pnt(:,1), pnt(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                text(pnt(:,1), pnt(:,2), num2str(k))
                clear pnt roi
            end
            pnt = drawpoint;
            Analyze_TwoParts_CutOff = round(norm(pnt.Position-Settings.Interferometry_Center));
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
                for k = 1:length(FigData.theta_all)
                    pnt = FigData.points(k, :);
                    roi = [pnt; Settings.Interferometry_Center];
                    plot(roi(:,1), roi(:,2), 'Color', 'red', 'LineWidth', 2)
                    plot(pnt(:,1), pnt(:,2), '.', 'Color', 'red' , 'MarkerSize', 20)
                    text(pnt(:,1), pnt(:,2), num2str(k))
                    clear pnt roi
                end
                if Settings.Analyze_TwoParts
                    if Settings.AnalyzeSector
                        plot_arc(Settings.SectorStart, Settings.SectorEnd, Settings.Interferometry_Center(1), Settings.Interferometry_Center(2), Settings.Analyze_TwoParts_CutOff)
                    else 
                        plot_arc(0, 2*pi, Settings.Interferometry_Center(1), Settings.Interferometry_Center(2), Settings.Analyze_TwoParts_CutOff)
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
                plot(c_l(FigData.pks_locs), FigData.pks, '.', 'MarkerSize', 10, 'Color', 'black')
                plot(c_l(FigData.mns_locs), -FigData.mns, '.', 'MarkerSize', 10, 'Color', 'green')
                xlabel('Distance from center [pix]')
                ylabel('Intensity [arb. units]')
                xlim([0, max(c_l)])
                title('After img adjustments and normalization')

                nexttile;
                plot(c_l, FigData.d_final.*1e6, 'Color', 'blue', 'LineWidth', 2)
                xlabel('Distance from center [pix]')
                ylabel('Height [um]')
                xlim([0, max(c_l)])
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
                plot(FigData.HeightProfile_Mean, 'LineWidth', 3)
                xlabel('Distance from center[pix]')
                ylabel('Height [um]')
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
                hold on
                map = parula(length(FigData.HeightProfile_Mean_AllImages));
                for i = 1:length(FigData.HeightProfile_Mean_AllImages)
                   plot(FigData.HeightProfile_Mean_AllImages{i}, 'LineWidth', 3, 'Color', map(i,:))
                end
                xlabel('Distance from center[pix]')
                ylabel('Height [um]')
%                 colormap parula
%                 colorbar
            else
                f = [];
            end
        end % f = AverageHeight_AllImages
        
        
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