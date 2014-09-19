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

% convert materials in scene to indexable multi-spectral pixels
%   mixels?  spexels?  speckles?
S = recipe.processing.S;
spexelWls = MakeItWls(S);
nSpexelWls = numel(spexelWls);
spacing = recipe.processing.S(2);
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
fatMask = repmat(recipe.processing.materialIndexImage, [1, 1, nSpexelWls]);
rawReflectance = zeros(recipe.processing.imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        rawReflectance(isMaterial(:)) = repmat(spexels(ii,:), nIsMaterial/nSpexelWls, 1);
    end
end

% save the raw reflectance image as sRGB
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);
rawReflectanceFile = fullfile(imageFolder, [imageName '-raw-reflectance.png']);
rawReflectanceSrgb = MultispectralToSRGB(rawReflectance, S, toneMapFactor, isScale);
imwrite(uint8(rawReflectanceSrgb), rawReflectanceFile);
recipe.processing.rawReflectanceImage = rawReflectanceFile;
