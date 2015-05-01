%% Summarize image spatial statistics..
%   @param reductions cell array of reductions from AnalyzeSpatialStats()
%
% @details
% Show some handy summary figures for arbitrary but interesting spatial
% summary data as computed from AnalyzeSpatialStats().  @a reductions
% must be a cell array of "reduction" outputs from multiple calls to
% AnalyzeSpatialStats().
%
% @details
% Plots the mean and std of each reduction, across all elements of the
% given @a reductions.
%
% @details
% Returns the handle of the figure used for plotting.
%
% @details
% Usage:
%   fig = SummarizeSpatialStats(reductions)
function fig = SummarizeSpatialStats(reductions)

%% Organize the data for plotting.
nReductions = numel(reductions);
allReductions = [reductions{:}];
plotNames = fieldnames(allReductions);
nPlots = numel(plotNames);
for ii = 1:nPlots
    name = plotNames{ii};
    r = [allReductions.(name)];
    plotData.(name).mean = [r.mean];
    plotData.(name).std = [r.std];
    plotData.(name).low = [r.low];
    plotData.(name).high = [r.high];
end

%% Plot a summary.
fig = figure();
xAxis = 1:nReductions;

for ii = 1:nPlots
    name = plotNames{ii};
    low = min(plotData.(name).low);
    high = max(plotData.(name).high);
    y = plotData.(name).mean;
    e = plotData.(name).std;
    
    subplot(nPlots, 1, ii);
    errorbar(xAxis, y, e);
    
    title(name);
    set(gca(), 'XTick', xAxis);
    
    if ~isnan(low) && ~isnan(high)
        set(gca(), 'YLim', [low high]);
    end
end

