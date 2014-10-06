% Compute "refelctance" and "illumination" images for a rendering.
%   recipe should be a recipe from BuildVirtualSceneRecipe
%   filterWidth width of sliding average to fill gaps in object pixel mask
%   toneMapFactor and isScale are passed to MakeMontage()
%   imageName is optional base file name for images
function recipe = MakeRecipeIlluminationImage(recipe, filterWidth, toneMapFactor, isScale, imageName)

if nargin < 2 || isempty(filterWidth)
    filterWidth = 5;
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

% find the scene rendering
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'scene.mat'))
        sceneDataFile = dataFile;
    end
end
sceneRendering = load(sceneDataFile);
imageSize = size(sceneRendering.multispectralImage);
S = sceneRendering.S;

% convert materials in scene to indexable multi-spectral pixels
%   mixels?  spexels?  speckles?
spexelWls = MakeItWls(S);
nSpexelWls = numel(spexelWls);
spacing = S(2);
nMaterials = numel(recipe.processing.allSceneMaterials);
spexels = zeros(nMaterials, nSpexelWls);
for ii = 1:nMaterials
    material = recipe.processing.allSceneMaterials{ii};
    propertyNames = {material.properties.propertyName};
    isDiffuse = strcmp(propertyNames, 'diffuseReflectance');
    diffuseReflectance = material.properties(isDiffuse);
    reflectanceString = diffuseReflectance.propertyValue;
    [wls, mags] = SparseSpectrumToRegular(reflectanceString, spacing);
    spexels(ii, :) = SplineRaw(wls', mags', spexelWls);
end

% raw reflectance image uses the object pixel mask to look up spexels
materialIndexMask = recipe.processing.materialIndexMask;
fatMask = repmat(materialIndexMask, [1, 1, nSpexelWls]);
rawReflectance = zeros(imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        rawReflectance(isMaterial(:)) = repmat(spexels(ii,:), nIsMaterial/nSpexelWls, 1);
    end
end

% fill in gaps in reflectance image by sliding local average
smoothReflectance = SmoothOutGaps(rawReflectance, materialIndexMask, filterWidth);

% "divide out" the reflectance from the rendering to leave illumination
rawIllumination = sceneRendering.multispectralImage ./ smoothReflectance;
smoothIllumination = SmoothOutGaps(rawIllumination, materialIndexMask, filterWidth);

% take the mean illumination within each object
meanIlluminationRaw = zeros(imageSize);
objectMask = zeros(size(materialIndexMask));
for ii = 1:nMaterials
    objectMask(:) = 0;
    objectMask(materialIndexMask == ii) = 1;
    nIsObject = sum(objectMask(:));
    if nIsObject > 0
        meanIllum = MeanUnderMask(smoothIllumination, objectMask);
        isMaterial = fatMask == ii;
        meanIlluminationRaw(isMaterial(:)) = repmat(meanIllum, nIsObject, 1);
    end
end
meanIlluminationSmooth = SmoothOutGaps(meanIlluminationRaw, materialIndexMask, filterWidth);

%% Write out analysis images to disk.

% save the scene rendering in sRgb
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
sceneSrgbFile = fullfile(imageFolder, [imageName '-scene-srgb.png']);
MakeMontage({sceneDataFile}, ...
    sceneSrgbFile, toneMapFactor, isScale, recipe.input.hints);
recipe.processing.sceneSrgbFile = sceneSrgbFile;

% save reflectance images as sRgb
recipe.processing.rawReflectanceImage = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-raw.png']), ...
    uint8(MultispectralToSRGB(rawReflectance, S, toneMapFactor, isScale)));

recipe.processing.smoothReflectanceImage = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-smooth.png']), ...
    uint8(MultispectralToSRGB(smoothReflectance, S, toneMapFactor, isScale)));

% save illumination image as sRgb
recipe.processing.rawIlluminationImage = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-raw.png']), ...
    uint8(MultispectralToSRGB(rawIllumination, S, toneMapFactor, isScale)));

recipe.processing.smoothIlluminationImage = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-smooth.png']), ...
    uint8(MultispectralToSRGB(smoothIllumination, S, toneMapFactor, isScale)));

recipe.processing.meanIlluminationRaw = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-mean-raw.png']), ...
    uint8(MultispectralToSRGB(meanIlluminationRaw, S, toneMapFactor, isScale)));

recipe.processing.meanIlluminationSmooth = writeImage( ...
    fullfile(imageFolder, [imageName '-scene-illumination-mean-smooth.png']), ...
    uint8(MultispectralToSRGB(meanIlluminationSmooth, S, toneMapFactor, isScale)));


function fileName = writeImage(fileName, imageData)
imwrite(imageData, fileName);
