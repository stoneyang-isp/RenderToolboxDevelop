%% Compare virtual scene "boring" rendering vs illumination images.
%   @param recipe a recipe from BuildWardLandRecipe()
%	@param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% For the given WardLand @a recipe, compares the "boring" rendering to the
% computed diffuse illumination image.  These images should be similar,
% except for the effects of interreflections.
%
% @details
% Returns the given @a recipe, updated with new images:
%   - recipe.processing.boring.radiance is an sRGB representation of the
%   "boring" rendering.
%   - recipe.processing.boring.boringMinusIllum for visual comparison, an
%   sRGB representation of the "boring" multi-spectral image, minus the
%   computed diffuse illumination image.
%   - recipe.processing.boring.illumMinusBoring for visual comparison, an
%   sRGB representation of the computed diffuse illumination image, minus
%   the boring multi-spectral image.
%   .
%
% @details
% Usage:
%   recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeBoringComparison(recipe, toneMapFactor, isScale)

if nargin < 2 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 3 || isempty(isScale)
    isScale = true;
end

% find the boring rendering
nRenderings = numel(recipe.rendering.radianceDataFiles);
isBoring = false(1, nRenderings);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    isBoring(ii) = ~isempty(regexp(dataFile, 'boring\.mat$', 'once'));
end
boringDataFiles = recipe.rendering.radianceDataFiles(isBoring);
boringRendering = load(boringDataFiles{1});
S = boringRendering.S;

% get the interpolated illumination image
diffuseIlluminationInterp = recipe.processing.multispectral.diffuseIlluminationInterp;

% scale images and take the diff
boringMean = mean(boringRendering.multispectralImage(:));
boringScaled = boringRendering.multispectralImage ./ boringMean;
illumMean = mean(diffuseIlluminationInterp(~isnan(diffuseIlluminationInterp(:))));
illumScaled = diffuseIlluminationInterp ./ illumMean;
boringMinusIllum = boringScaled - illumScaled;
illumMinusBoring = illumScaled - boringScaled;

%% Write out analysis images to disk.
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);

recipe.processing.boring.radiance = WriteImage( ...
    fullfile(imageFolder, 'radiance', 'boring.png'), ...
    uint8(MultispectralToSRGB(boringRendering.multispectralImage, S, toneMapFactor, isScale)));

recipe.processing.boring.boringMinusIllum = WriteImage( ...
    fullfile(imageFolder, 'boring', 'boringMinusIllum.png'), ...
    uint8(MultispectralToSRGB(boringMinusIllum, S, toneMapFactor, isScale)));

recipe.processing.boring.illumMinusBoring = WriteImage( ...
    fullfile(imageFolder, 'boring', 'illumMinusBoring.png'), ...
    uint8(MultispectralToSRGB(illumMinusBoring, S, toneMapFactor, isScale)));
