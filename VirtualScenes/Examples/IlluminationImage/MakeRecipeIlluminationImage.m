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

% load the scene renderings
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'matte.mat'))
        matteDataFile = dataFile;
    elseif ~isempty(strfind(dataFile, 'ward.mat'))
        wardDataFile = dataFile;
    end
end
matteRendering = load(matteDataFile);
wardRendering = load(wardDataFile);
imageSize = size(matteRendering.multispectralImage);
S = matteRendering.S;

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
reflectanceRaw = zeros(imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        reflectanceRaw(isMaterial(:)) = repmat(spexels(ii,:), nIsMaterial/nSpexelWls, 1);
    end
end

% fill in gaps in reflectance image by sliding local average
reflectanceInterp = SmoothOutGaps(reflectanceRaw, materialIndexMask, filterWidth);

% "divide out" the reflectance from the matte rendering to leave illumination
illuminationRaw = matteRendering.multispectralImage ./ reflectanceInterp;
illuminationInterp = SmoothOutGaps(illuminationRaw, materialIndexMask, filterWidth);

% take the mean illumination within each object
illuminationMeanRaw = zeros(imageSize);
objectMask = zeros(size(materialIndexMask));
for ii = 1:nMaterials
    objectMask(:) = 0;
    objectMask(materialIndexMask == ii) = 1;
    nIsObject = sum(objectMask(:));
    if nIsObject > 0
        meanIllum = MeanUnderMask(illuminationInterp, objectMask);
        isMaterial = fatMask == ii;
        illuminationMeanRaw(isMaterial(:)) = repmat(meanIllum, nIsObject, 1);
    end
end
illuminationMeanInterp = SmoothOutGaps(illuminationMeanRaw, materialIndexMask, filterWidth);

% "subtract out" matte from ward rendering to leave specular radiance only
specularOnly = wardRendering.multispectralImage - matteRendering.multispectralImage;

%% Write out analysis images to disk.

% save the scene renderings in sRgb
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
recipe.processing.matteSrgb = writeImage( ...
    fullfile(imageFolder, [imageName '-radiance-diffuse.png']), ...
    uint8(MultispectralToSRGB(matteRendering.multispectralImage, S, toneMapFactor, isScale)));

recipe.processing.wardSrgb = writeImage( ...
    fullfile(imageFolder, [imageName '-radiance-ward.png']), ...
    uint8(MultispectralToSRGB(wardRendering.multispectralImage, S, toneMapFactor, isScale)));

recipe.processing.specularSrgb = writeImage( ...
    fullfile(imageFolder, [imageName '-radiance-specular.png']), ...
    uint8(MultispectralToSRGB(specularOnly, S, toneMapFactor, isScale)));

% save reflectances as sRgb
recipe.processing.reflectanceRaw = writeImage( ...
    fullfile(imageFolder, [imageName '-reflectance-raw.png']), ...
    uint8(MultispectralToSRGB(reflectanceRaw, S, toneMapFactor, isScale)));

recipe.processing.eflectanceSmooth = writeImage( ...
    fullfile(imageFolder, [imageName '-reflectance-interp.png']), ...
    uint8(MultispectralToSRGB(reflectanceInterp, S, toneMapFactor, isScale)));

% save illuminations as sRgb
recipe.processing.illuminationRaw = writeImage( ...
    fullfile(imageFolder, [imageName '-illumination-raw.png']), ...
    uint8(MultispectralToSRGB(illuminationRaw, S, toneMapFactor, isScale)));

recipe.processing.illuminationSmooth = writeImage( ...
    fullfile(imageFolder, [imageName '-illumination-interp.png']), ...
    uint8(MultispectralToSRGB(illuminationInterp, S, toneMapFactor, isScale)));

recipe.processing.lluminationMeanRaw = writeImage( ...
    fullfile(imageFolder, [imageName '-illumination-mean-raw.png']), ...
    uint8(MultispectralToSRGB(illuminationMeanRaw, S, toneMapFactor, isScale)));

recipe.processing.illuminationMeanSmooth = writeImage( ...
    fullfile(imageFolder, [imageName '-illumination-mean-interp.png']), ...
    uint8(MultispectralToSRGB(illuminationMeanInterp, S, toneMapFactor, isScale)));


function fileName = writeImage(fileName, imageData)
imwrite(imageData, fileName);
