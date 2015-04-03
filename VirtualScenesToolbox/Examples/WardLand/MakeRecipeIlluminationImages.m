%% Compute the "illumination" images for a WardLand recipe.
%   @param recipe a recipe struct from BuildWardLandRecipe()
%   @param filterWidth width of sliding average to fill gaps in object mask
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%   @param useAlbedo whether to use "albedo" instead of "reflectance" data
%
% @details
% Uses results from MakeRecipeRGBImages(), MakeRecipeReflectanceImages(),
% and MakeRecipeAlbedoFactoidImages() to compute "illumination" images for
% the given WardLand @a recipe.
%
% @details
% Returns the given @a recipe, updated with reflectance image data saved
% in the "illumination" group.
%
% @details
% Usage:
%   recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale, useAlbedo)
%
% @ingroup WardLand
function recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale, useAlbedo)

if nargin < 2 || isempty(filterWidth)
    filterWidth = 5;
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 4 || isempty(isScale)
    isScale = true;
end

if nargin < 5 || isempty(useAlbedo)
    useAlbedo = false;
end

%% Load scene renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'matte.mat'))
        matteDataFile = dataFile;
    end
end


%% Get radiance data.
matteRendering = load(matteDataFile);
matteRadiance = matteRendering.multispectralImage;
imageSize = size(matteRadiance);

S = GetRecipeProcessingData(recipe, 'radiance', 'S');
wls = MakeItWls(S);
nWls = numel(wls);

%% Get reflectance, albedo, and object mask data.
diffuseReflectance = LoadRecipeProcessingImageFile(recipe, 'reflectance', 'diffuseInterp');
albedo = LoadRecipeProcessingImageFile(recipe, 'albedo', 'albedo');
materialIndexMask = LoadRecipeProcessingImageFile(recipe, 'mask', 'materialIndexes');


%% "Divide out" reflectances from radiance to leave illumination.
if useAlbedo
    diffuseRaw = matteRadiance ./ albedo;
else
    diffuseRaw = matteRadiance ./ diffuseReflectance;
end

diffuseInterp = SmoothOutGaps(diffuseRaw, materialIndexMask, filterWidth);


%% Take mean illumination within each object.
diffuseMeanRaw = zeros(imageSize);

fatMask = repmat(materialIndexMask, [1, 1, nWls]);
objectMask = zeros(size(materialIndexMask));

nMaterials = numel(recipe.processing.allSceneMatteMaterials);
for ii = 1:nMaterials
    objectMask(:) = 0;
    objectMask(materialIndexMask == ii) = 1;
    nIsObject = sum(objectMask(:));
    if nIsObject > 0
        isMaterial = fatMask == ii;
        diffuseMeanIllum = MeanUnderMask(diffuseInterp, objectMask);
        diffuseMeanRaw(isMaterial(:)) = repmat(diffuseMeanIllum, nIsObject, 1);
    end
end

diffuseMeanInterp = SmoothOutGaps(diffuseMeanRaw, materialIndexMask, filterWidth);


%% Make sRGB representations.
diffuseRawSRGB = uint8(MultispectralToSRGB(diffuseRaw, S, toneMapFactor, isScale));
diffuseInterpSRGB = uint8(MultispectralToSRGB(diffuseInterp, S, toneMapFactor, isScale));

diffuseMeanRawSRGB = uint8(MultispectralToSRGB(diffuseMeanRaw, S, toneMapFactor, isScale));
diffuseMeanInterpSRGB = uint8(MultispectralToSRGB(diffuseMeanInterp, S, toneMapFactor, isScale));


%% Save images.
group = 'illumination';
format = 'mat';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseRaw', format, diffuseRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseInterp', format, diffuseInterp);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseMeanRaw', format, diffuseMeanRaw);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'diffuseMeanInterp', format, diffuseMeanInterp);

format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseRaw', format, diffuseRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseInterp', format, diffuseInterpSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseMeanRaw', format, diffuseMeanRawSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBDiffuseMeanInterp', format, diffuseMeanInterpSRGB);
