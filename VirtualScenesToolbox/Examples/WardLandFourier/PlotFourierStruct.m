%% Plot results from Fourier analysis stored in a "Fourier Struct".
%   @param fourierStruct "Fourier Struct" as from WardLandToFourierStruct()
%   @param fig optional figure handle to plot into
%   @param fontSize optional fontSize for all plots
%
% @details
% Plots results of spatial frequency analysis stored in the given @a
% fourierStruct, as returned from AnalyzeFourierStruct().
%
% @details
% Returns the given @a fourierStruct with each element (maybe) updated.
% Also returns a figure handle for the new plot.
%
% @details
% Usage:
%   [fourierStruct, fig] = PlotFourierStruct(fourierStruct, fig, fontSize)
%
% @ingroup WardLand
function [fourierStruct, fig] = PlotFourierStruct(fourierStruct, fig, fontSize)

if nargin < 2 || isempty(fig)
    fig = figure();
end
figure(fig);

if nargin < 3 || isempty(fontSize)
    fontSize = 14;
end

% figure out a common y-lim for amplitude plots
results = [fourierStruct.results];
amplitudes = [results.amplitudes];
commonYLim = log([min(amplitudes) max(amplitudes)]);

nTodo = numel(fourierStruct);
plotColors = lines(nTodo);
for ii = 1:nTodo
    % choose the row of subplots to plot to
    plotOffset = (ii-1)*4;
    
    % plot the original RGB image
    subplot(nTodo, 4, plotOffset + 1);
    imshow(uint8(fourierStruct(ii).rgb));
    
    set(gca(), 'FontSize', fontSize);
    ylabel(fourierStruct(ii).name);
    
    % plot the grayscale image (e.g. luminance)
    subplot(nTodo, 4, plotOffset + 2);
    imshow(fourierStruct(ii).grayscale ./ max(fourierStruct(ii).grayscale(:)));
    
    set(gca(), 'FontSize', fontSize);
    if (ii == 1)
        title('grayscale');
    end
    
    % visualize the Fourier transform data
    subplot(nTodo, 4, plotOffset + 3);
    imshow(log(abs(fourierStruct(ii).results.fourierNormalized)), []);
    
    set(gca(), 'FontSize', fontSize);
    if (ii == 1)
        title('log(fft amplitude)');
    end
    
    % plot frequency distributions
    subplot(nTodo, 4, plotOffset + 4);
    plot(fourierStruct(ii).results.frequencies, ...
        log(fourierStruct(ii).results.amplitudes), ...
        'LineWidth', 2, ...
        'Color', plotColors(ii,:));
    
    ylim(commonYLim);
    set(gca(), 'FontSize', fontSize);
    if (ii == 1)
        title('frequency distribution');
        ylabel('log(fft amplitude)')
        xlabel('frequency')
    end
end