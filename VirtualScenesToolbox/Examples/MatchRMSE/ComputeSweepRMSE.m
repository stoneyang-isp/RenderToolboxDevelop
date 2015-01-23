% Plot image RMSE vs the "lambdas" of a parameter sweep.
%   recipe - a recipe from BuildSweepConditions()
%   imageNames - imageNames from BuildSpectrumSweep() or similar
function rmses = ComputeSweepRMSE(recipe, imageNames)

% locate the baseline rendering
renderings = GetWorkingFolder('renderings', true, recipe.input.hints);
firstOutput = fullfile(renderings, [imageNames{1} '.mat']);
firstData = load(firstOutput);

% compute RMSE vs baseline for each rendering
nRenderings = numel(imageNames);
rmses = zeros(1, nRenderings);
for ii = 1:nRenderings
    output = fullfile(renderings, [imageNames{ii} '.mat']);
    data = load(output);
    diff = firstData.multispectralImage - data.multispectralImage;
    rmses(ii) = rms(diff(:));
end
