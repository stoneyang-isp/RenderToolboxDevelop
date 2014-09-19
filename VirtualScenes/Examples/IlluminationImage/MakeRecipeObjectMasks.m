% Analyze Virtual Scene renderings for inserted object pixel masks.
%   recipe should be a recipe from BuildVirtualSceneRecipe
%   pixelThreshold can be mask "conservativeness" like 0.1
%   toneMapFactor and isScale are passed to MakeMontage()
%   imageName is optional base file name for images
function recipe = MakeRecipeObjectMasks(recipe, pixelThreshold, toneMapFactor, isScale, imageName)

if nargin < 2 || isempty(pixelThreshold)
    pixelThreshold = 0.1;
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 4 || isempty(isScale)
    isScale = true;
end

if nargin < 5 || isempty(imageName)
    imageName = recipe.input.hints.recipeName;
end

% find the mask rendering
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'mask.mat'))
        maskDataFile = dataFile;
    end
end

% save the mask rendering in sRgb
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
maskSrgbFile = fullfile(imageFolder, [imageName '-mask-srgb.png']);
MakeMontage({maskDataFile}, ...
    maskSrgbFile, toneMapFactor, isScale, recipe.input.hints);
recipe.processing.maskSrgbFile = maskSrgbFile;

% make a mask image that identifies objects by color
maskRendering = load(maskDataFile);
imageSize = size(maskRendering.multispectralImage);
materialIndexMask = zeros(imageSize(1), imageSize(2), 'uint8');
for ii = 1:imageSize(1)
    for jj = 1:imageSize(2)
        pixelSpectrum = squeeze(maskRendering.multispectralImage(ii,jj,:));
        isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
        if sum(isHigh) == 1
            whichMaterial = find(isHigh, 1, 'first');
            materialIndexMask(ii,jj) = whichMaterial;
        end
    end
end
recipe.processing.materialIndexImage = materialIndexMask;

% save an image that shows coverage for the materialIndexImage
maskCoverage = zeros(imageSize(1), imageSize(2), 'uint8');
maskCoverage(materialIndexMask > 0) = 255;
maskCoverageFile = fullfile(imageFolder, [imageName '-mask-coverage.png']);
imwrite(maskCoverage, maskCoverageFile)
recipe.processing.maskCoverageFile = maskCoverageFile;
