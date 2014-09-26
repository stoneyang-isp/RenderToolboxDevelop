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

% find the mask renderings
nRenderings = numel(recipe.rendering.radianceDataFiles);
isMask = false(1, nRenderings);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    isMask(ii) = ~isempty(regexp(dataFile, 'mask-\d+\.mat$', 'once'));
end
maskDataFiles = recipe.rendering.radianceDataFiles(isMask);

% start building an object mask from the mask renderings
rendering = load(maskDataFiles{1});
imageSize = size(rendering.multispectralImage);
materialIndexMask = zeros(imageSize(1), imageSize(2), 'uint8');
grandMultispectralImage = zeros(imageSize(1), imageSize(2), 0);

imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
nPages = numel(maskDataFiles);
for pp = 1:nPages
    % save mask rendering in sRgb
    dataFile = maskDataFiles{pp};
    maskName = sprintf('mask-%d', pp);
    maskSrgbFile = fullfile(imageFolder, [imageName '-' maskName '-srgb.png']);
    MakeMontage({dataFile}, ...
        maskSrgbFile, toneMapFactor, isScale, recipe.input.hints);
    recipe.processing.maskSrgbFile{pp} = maskSrgbFile;
    
    % stack up all the mask renderings
    rendering = load(dataFile);
    grandMultispectralImage = cat(3, grandMultispectralImage, rendering.multispectralImage);
end

% make a mask image that identifies objects by color
for ii = 1:imageSize(1)
    for jj = 1:imageSize(2)
        pixelSpectrum = squeeze(grandMultispectralImage(ii,jj,:));
        isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
        if sum(isHigh) == 1
            whichBand = find(isHigh, 1, 'first');
            materialIndexMask(ii,jj) = whichBand;
        end
    end
end
recipe.processing.materialIndexMask = materialIndexMask;

% save an image that shows coverage for the materialIndexImage
maskCoverage = zeros(imageSize(1), imageSize(2), 'uint8');
maskCoverage(materialIndexMask > 0) = 255;
maskCoverageFile = fullfile(imageFolder, [imageName '-mask-coverage.png']);
imwrite(maskCoverage, maskCoverageFile)
recipe.processing.maskCoverageFile = maskCoverageFile;
