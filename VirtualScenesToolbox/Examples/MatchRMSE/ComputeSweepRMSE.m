% Plot image RMSE vs the "lambdas" of a parameter sweep.
%   recipe - a recipe from BuildSweepConditions()
%   imageNames - imageNames from BuildSpectrumSweep() or similar
%   pixelMask - optional 2D mask, true where RMSE should be taken
function rmses = ComputeSweepRMSE(recipe, imageNames, pixelMask)

% locate the baseline rendering
renderings = GetWorkingFolder('renderings', true, recipe.input.hints);
firstOutput = fullfile(renderings, [imageNames{1} '.mat']);
firstData = load(firstOutput);

imageSize = size(firstData.multispectralImage);
if nargin < 3 || isempty(pixelMask)
    % trivial non-mask
    pixelMask = true(imageSize);
else
    % expand 2D mask to cover multi-spectral dimensions
    pixelMask = repmat(pixelMask, [1, 1, imageSize(3)]);
end

% compute RMSE vs baseline for each rendering
nRenderings = numel(imageNames);
rmses = zeros(1, nRenderings);
for ii = 1:nRenderings
    output = fullfile(renderings, [imageNames{ii} '.mat']);
    data = load(output);
    errorImage = firstData.multispectralImage - data.multispectralImage;
    
    rmses(ii) = rms(errorImage(pixelMask));
end
