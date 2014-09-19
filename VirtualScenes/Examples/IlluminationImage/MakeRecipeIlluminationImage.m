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
nMaterials = numel(recipe.processing.sceneMaterialsByIndex);
spexels = zeros(nMaterials, nSpexelWls);
for ii = 1:nMaterials
    material = recipe.processing.sceneMaterialsByIndex{ii};
    propertyNames = {material.properties.propertyName};
    isDiffuse = strcmp(propertyNames, 'diffuseReflectance');
    diffuseReflectance = material.properties(isDiffuse);
    reflectanceString = diffuseReflectance.propertyValue;
    [wls, mags] = SparseSpectrumToRegular(reflectanceString, spacing);
    spexels(ii, :) = SplineRaw(wls', mags', spexelWls);
end

% raw reflectance image uses the object pixel mask to look up spexels
materialIndexImage = recipe.processing.materialIndexImage;
fatMask = repmat(materialIndexImage, [1, 1, nSpexelWls]);
rawReflectance = zeros(imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        rawReflectance(isMaterial(:)) = repmat(spexels(ii,:), nIsMaterial/nSpexelWls, 1);
    end
end

% smooth reflectance image fills in gaps with a sliding average
window = 1:filterWidth - floor(filterWidth/2);
smoothReflectance = rawReflectance;
width = imageSize(1);
height = imageSize(2);
for ii = 1:width
    for jj = 1:height
        if materialIndexImage(ii,jj) > 0
            % no gap here
            continue;
        end
        
        % smooth gap by averaging over a filter window
        iiWindow = min(max(window + ii, 1), width);
        jjWindow = min(max(window + jj, 1), height);
        materialIndexWindow = materialIndexImage(iiWindow, jjWindow);
        materialIndexSelection = materialIndexWindow(:) > 0;
        spexelWindow = spexels(materialIndexWindow(materialIndexSelection), :);
        meanSpexel = mean(spexelWindow, 1);
        smoothReflectance(ii,jj,:) = meanSpexel;
    end
end

% "divide out" the reflectance from the rendering to leave illumination
illumination = sceneRendering.multispectralImage ./ smoothReflectance;

% save the scene rendering in sRgb
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
sceneSrgbFile = fullfile(imageFolder, [imageName '-scene-srgb.png']);
MakeMontage({sceneDataFile}, ...
    sceneSrgbFile, toneMapFactor, isScale, recipe.input.hints);
recipe.processing.sceneSrgbFile = sceneSrgbFile;

% save the raw reflectance image as sRgb
rawReflectanceFile = fullfile(imageFolder, [imageName '-scene-raw-reflectance.png']);
rawReflectanceSrgb = MultispectralToSRGB(rawReflectance, S, toneMapFactor, isScale);
imwrite(uint8(rawReflectanceSrgb), rawReflectanceFile);
recipe.processing.rawReflectanceImage = rawReflectanceFile;

% save the smooth reflectance image as sRgb
smoothReflectanceFile = fullfile(imageFolder, [imageName '-scene-smooth-reflectance.png']);
smoothReflectanceSrgb = MultispectralToSRGB(smoothReflectance, S, toneMapFactor, isScale);
imwrite(uint8(smoothReflectanceSrgb), smoothReflectanceFile);
recipe.processing.rawReflectanceImage = smoothReflectanceFile;

% save the illumination image as sRgb
illuminationFile = fullfile(imageFolder, [imageName '-scene-illumination.png']);
illuminationSrgb = MultispectralToSRGB(illumination, S, toneMapFactor, isScale);
imwrite(uint8(illuminationSrgb), illuminationFile);
recipe.processing.rawReflectanceImage = illuminationFile;

