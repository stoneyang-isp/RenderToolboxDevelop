%% Analyze the given image for some spatial statistics.
%   @param rgb 3-channel rgb representation of an image
%   @param lum 1-channel luminance representation of the same image
%   @param lms 3-channel LMS representation of the same image
%   @param binEdges bins to use for two-point correlation
%   @param samplesPerBin samples to use for two-point correlation analysis
%   @param doPlot whether to make a figure, or just return reduction stats
%
% @details
% Compute some arbitrary but intereseting spatial variation statistics for
% the given image.  @a rgb, @a lum, and @a lms, should all be
% representations of the same image.
%
% @details
% Makes a figure with the given images, a histogram of lum the values, and
% six two-point correlation plots for each of the L, M, and S image planes
% and their crosses.
%
% @details
% Returns a struct with some "reduction" statistics about the image
% including the mean and std of the lum values and the mean and std from
% each two-point correlation analysis.  The struct field names will
% indicate which analysis the statistics come from.  For example, "lum"
% (luminance), "SS" (LMS S vs S) and "SM" (LMS S vs M).
%
% @details
% Also returns the handle of the figure used for plotting, if any.
%
% @details
% Usage:
%   [reductions, fig] = AnalyzeSpatialStats(rgb, lum, lms, binEdges, samplesPerBin, doPlot)
function [reductions, fig] = AnalyzeSpatialStats(rgb, lum, lms, binEdges, samplesPerBin, doPlot)

fig = [];

s = size(rgb);
diagonal = sqrt(s(1)*s(1) + s(2)*s(2));

if nargin < 4 || isempty(binEdges)
    binEdges = 0:5:diagonal/2;
end

if nargin < 5 || isempty(samplesPerBin)
    samplesPerBin = 1000;
end

if nargin < 6 || isempty(doPlot)
    doPlot = true;
end


%% Always calculate the reductions.
reductions.lum = calculateReductions(lum, nan, nan);

twoPointLow = -0.2;
twoPointHigh = 1.0;
L = lms(:,:,1);
M = lms(:,:,2);
S = lms(:,:,3);
reductions.LL = calculateReductions(TwoPointCorrelationDistribution(L, L, binEdges, samplesPerBin), twoPointLow, twoPointHigh);
reductions.LS = calculateReductions(TwoPointCorrelationDistribution(L, S, binEdges, samplesPerBin), twoPointLow, twoPointHigh);
reductions.SS = calculateReductions(TwoPointCorrelationDistribution(S, S, binEdges, samplesPerBin), twoPointLow, twoPointHigh);
reductions.LM = calculateReductions(TwoPointCorrelationDistribution(L, M, binEdges, samplesPerBin), twoPointLow, twoPointHigh);
reductions.MM = calculateReductions(TwoPointCorrelationDistribution(M, M, binEdges, samplesPerBin), twoPointLow, twoPointHigh);
reductions.MS = calculateReductions(TwoPointCorrelationDistribution(M, S, binEdges, samplesPerBin), twoPointLow, twoPointHigh);

if ~doPlot
    return;
end

%% Plot a summary.
fig = figure();

subplot(4,3,1);
imshow(rgb, [0 max(rgb(:))]);
title('rgb')

subplot(4,3,2);
imshow(lum, [0 max(lum(:))]);
title('lum')

subplot(4,3,3);
hist(lum(:))
title('histogram of lum')

subplot(4,3,4);
maxLms = max(lms(:));
imshow(L, [0 maxLms]);
title('L')

subplot(4,3,5);
imshow(M, [0 maxLms]);
title('M')

subplot(4,3,6);
imshow(S, [0 maxLms]);
title('S')

reductionNames = {'LL', 'LS', 'SS', 'LM', 'MM', 'MS'};
for ii = 1:numel(reductionNames)
    name = reductionNames{ii};
    raw = reductions.(name).raw;
    
    subplot(4,3,6+ii);
    plot(binEdges(2:end), raw);
    ylim([-0.2 1])
    title(name)
end


% calculate reduction statis for a matrix, put them in a struct
function r = calculateReductions(x, low, high)
r.low = low;
r.high = high;
r.raw = x;
r.mean = mean(x(:));
r.std = std(x(:));
