% Analyze Virtual Scene renderings for inserted object pixel masks.
%   recipe should be a recipe from BuildVirtualSceneRecipe
%   pixelThreshold can be mask "conservativeness" like 0.1
%   pixelMaskRgbs can be array of RGB rows for inserted objects
%   toneMapFactor and isScale are passed to MakeMontage()
%   imageName is optional base file name for images
function recipe = MakeVirtualSceneObjectMasks(recipe, pixelThreshold, pixelMaskRgbs, toneMapFactor, isScale, imageName)

if nargin < 2 || isempty(pixelThreshold)
    pixelThreshold = 0.1;
end

if nargin < 3 || isempty(pixelMaskRgbs)
    pixelMaskRgbs = 255*[ ...
        0 0 1; ...
        0 1 0; ...
        0 1 1; ...
        1 0 0; ...
        1 0 1; ...
        1 1 0; ...
        1 1 1];
end

if nargin < 4 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 5 || isempty(isScale)
    isScale = true;
end

if nargin < 6 || isempty(imageName)
    imageName = recipe.input.hints.recipeName;
end

% find the mask and scene renderings
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'mask.mat'))
        maskDataFile = dataFile;
    end
    if ~isempty(strfind(dataFile, 'scene.mat'))
        sceneDataFile = dataFile;
    end
end

% save the scene rendering in sRgb
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
sceneSrgbFile = fullfile(imageFolder, [imageName '-srgb.png']);
sceneSrgb = MakeMontage({sceneDataFile}, ...
    sceneSrgbFile, toneMapFactor, isScale, recipe.input.hints);
recipe.processing.sceneSrgbFile = sceneSrgbFile;

% save the mask rendering in sRgb
maskSrgbFile = fullfile(imageFolder, [imageName '-mask-srgb.png']);
MakeMontage({maskDataFile}, ...
    maskSrgbFile, toneMapFactor, isScale, recipe.input.hints);
recipe.processing.maskSrgbFile = maskSrgbFile;

% make a mask image that identifies objects by color
maskRendering = load(maskDataFile);
imageSize = size(maskRendering.multispectralImage);
objectMask = zeros(imageSize(1), imageSize(2), 3, 'uint8');
objectMaskSuperimposed = uint8(sceneSrgb);
for ii = 1:imageSize(1)
    for jj = 1:imageSize(2)
        pixelSpectrum = squeeze(maskRendering.multispectralImage(ii,jj,:));
        isHigh = pixelSpectrum > max(pixelSpectrum)*pixelThreshold;
        if sum(isHigh) == 1
            objectMask(ii,jj,:) = pixelMaskRgbs(isHigh,:);
            objectMaskSuperimposed(ii,jj,:) = pixelMaskRgbs(isHigh,:);
        end
    end
end

% save the mask itself in rgb
maskRgbFile = fullfile(imageFolder, [imageName '-mask.png']);
imwrite(objectMask, maskRgbFile)
recipe.processing.maskRgbFile = maskRgbFile;

% save the mask superimposed on the scene in rgb
maskSuperimposedFile = fullfile(imageFolder, [imageName '-superimposed.png']);
imwrite(objectMaskSuperimposed, maskSuperimposedFile)
recipe.processing.maskSuperimposedFile = maskSuperimposedFile;

