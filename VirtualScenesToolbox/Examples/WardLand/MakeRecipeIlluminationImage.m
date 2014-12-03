% Compute "refelctance" and "illumination" images for a rendering.
%   recipe should be a recipe from BuildWardLandRecipe()
%   filterWidth width of sliding average to fill gaps in object pixel mask
%   toneMapFactor and isScale are passed to MakeMontage()
function recipe = MakeRecipeIlluminationImage(recipe, filterWidth, toneMapFactor, isScale)

if nargin < 2 || isempty(filterWidth)
    filterWidth = 5;
end

if nargin < 3 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 4 || isempty(isScale)
    isScale = true;
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

% "subtract out" matte from ward rendering to leave specular radiance only
specularRadiance = wardRendering.multispectralImage - matteRendering.multispectralImage;

% convert materials in scene to indexable multi-spectral pixels ("spexels")
spexelWls = MakeItWls(S);
nSpexelWls = S(3);
spacing = S(2);
nMaterials = numel(recipe.processing.allSceneMatteMaterials);
diffuseSpexels = zeros(nMaterials, nSpexelWls);
specularSpexels = zeros(nMaterials, nSpexelWls);
for ii = 1:nMaterials
    diffuseMaterial = recipe.processing.allSceneMatteMaterials{ii};
    diffuseSpexels(ii, :) = extractMaterialSpexel( ...
        diffuseMaterial, 'diffuseReflectance', spacing, spexelWls);
    
    wardMaterial = recipe.processing.allSceneWardMaterials{ii};
    specularSpexels(ii, :) = extractMaterialSpexel( ...
        wardMaterial, 'specularReflectance', spacing, spexelWls);
end

% raw reflectance images uses the object pixel mask to look up spexels
materialIndexMask = recipe.processing.materialIndexMask;
fatMask = repmat(materialIndexMask, [1, 1, nSpexelWls]);
diffuseReflectanceRaw = zeros(imageSize);
specularReflectanceRaw = zeros(imageSize);
for ii = 1:nMaterials
    isMaterial = fatMask == ii;
    nIsMaterial = sum(isMaterial(:));
    if nIsMaterial > 0
        nSpexels = nIsMaterial/nSpexelWls;
        diffuseReflectanceRaw(isMaterial(:)) = repmat(diffuseSpexels(ii,:), nSpexels, 1);
        specularReflectanceRaw(isMaterial(:)) = repmat(specularSpexels(ii,:), nSpexels, 1);
    end
end

% fill in gaps in reflectance images by sliding local average
diffuseReflectanceInterp = SmoothOutGaps(diffuseReflectanceRaw, materialIndexMask, filterWidth);
specularReflectanceInterp = SmoothOutGaps(specularReflectanceRaw, materialIndexMask, filterWidth);

% "divide out" the reflectances from the renderings to leave illumination
diffuseIlluminationRaw = matteRendering.multispectralImage ./ diffuseReflectanceInterp;
diffuseIlluminationInterp = SmoothOutGaps(diffuseIlluminationRaw, materialIndexMask, filterWidth);
specularIlluminationRaw = specularRadiance ./ specularReflectanceInterp;
specularIlluminationInterp = SmoothOutGaps(specularIlluminationRaw, materialIndexMask, filterWidth);

% take the mean illuminations within each object
objectMask = zeros(size(materialIndexMask));
diffuseIlluminationMeanRaw = zeros(imageSize);
specularIlluminationMeanRaw = zeros(imageSize);
for ii = 1:nMaterials
    objectMask(:) = 0;
    objectMask(materialIndexMask == ii) = 1;
    nIsObject = sum(objectMask(:));
    if nIsObject > 0
        isMaterial = fatMask == ii;
        diffuseMeanIllum = MeanUnderMask(diffuseIlluminationInterp, objectMask);
        diffuseIlluminationMeanRaw(isMaterial(:)) = repmat(diffuseMeanIllum, nIsObject, 1);
        specularMeanIllum = MeanUnderMask(specularIlluminationInterp, objectMask);
        specularIlluminationMeanRaw(isMaterial(:)) = repmat(specularMeanIllum, nIsObject, 1);
    end
end
diffuseIlluminationMeanInterp = SmoothOutGaps(diffuseIlluminationMeanRaw, materialIndexMask, filterWidth);
specularIlluminationMeanInterp = SmoothOutGaps(specularIlluminationMeanRaw, materialIndexMask, filterWidth);

%% Keep a few multispectral images in memory.
recipe.processing.multispectral.S = S;
recipe.processing.multispectral.diffuseReflectanceInterp = ...
    diffuseReflectanceInterp;
recipe.processing.multispectral.diffuseIlluminationInterp = ...
    diffuseIlluminationInterp;
recipe.processing.multispectral.diffuseIlluminationMeanInterp = ...
    diffuseIlluminationMeanInterp;

%% Write out analysis images to disk.
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);

% save the scene renderings in sRgb
recipe.processing.srgb.main = WriteImage( ...
    fullfile(imageFolder, 'radiance', 'main.png'), ...
    uint8(MultispectralToSRGB(wardRendering.multispectralImage, S, toneMapFactor, isScale)));

recipe.processing.srgb.matte = WriteImage( ...
    fullfile(imageFolder, 'radiance', 'diffuse.png'), ...
    uint8(MultispectralToSRGB(matteRendering.multispectralImage, S, toneMapFactor, isScale)));

recipe.processing.srgb.specular = WriteImage( ...
    fullfile(imageFolder, 'radiance', 'specular.png'), ...
    uint8(MultispectralToSRGB(specularRadiance, S, toneMapFactor, isScale)));

% save reflectances as sRgb
% diffuse
recipe.processing.srgb.diffuseReflectanceRaw = WriteImage( ...
    fullfile(imageFolder, 'reflectance', 'diffuse-raw.png'), ...
    uint8(MultispectralToSRGB(diffuseReflectanceRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.diffuseReflectanceInterp = WriteImage( ...
    fullfile(imageFolder, 'reflectance', 'diffuse-interp.png'), ...
    uint8(MultispectralToSRGB(diffuseReflectanceInterp, S, toneMapFactor, isScale)));

% specular
recipe.processing.srgb.specularReflectanceRaw = WriteImage( ...
    fullfile(imageFolder, 'reflectance', 'specular-raw.png'), ...
    uint8(MultispectralToSRGB(specularReflectanceRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.specularReflectanceInterp = WriteImage( ...
    fullfile(imageFolder, 'reflectance', 'specular-interp.png'), ...
    uint8(MultispectralToSRGB(specularReflectanceInterp, S, toneMapFactor, isScale)));

% save illuminations as sRgb
% diffuse
recipe.processing.srgb.diffuseIlluminationRaw = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'diffuse-raw.png'), ...
    uint8(MultispectralToSRGB(diffuseIlluminationRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.diffuseIlluminationInterp = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'diffuse-interp.png'), ...
    uint8(MultispectralToSRGB(diffuseIlluminationInterp, S, toneMapFactor, isScale)));

recipe.processing.srgb.diffuseIlluminationMeanRaw = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'diffuse-mean-raw.png'), ...
    uint8(MultispectralToSRGB(diffuseIlluminationMeanRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.diffuseIlluminationMeanInterp = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'diffuse-mean-interp.png'), ...
    uint8(MultispectralToSRGB(diffuseIlluminationMeanInterp, S, toneMapFactor, isScale)));

% specular
recipe.processing.srgb.specularIlluminationRaw = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'specular-raw.png'), ...
    uint8(MultispectralToSRGB(specularIlluminationRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.specularIlluminationInterp = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'specular-interp.png'), ...
    uint8(MultispectralToSRGB(specularIlluminationInterp, S, toneMapFactor, isScale)));

recipe.processing.srgb.specularIlluminationMeanRaw = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'specular-mean-raw.png'), ...
    uint8(MultispectralToSRGB(specularIlluminationMeanRaw, S, toneMapFactor, isScale)));

recipe.processing.srgb.specularIlluminationMeanInterp = WriteImage( ...
    fullfile(imageFolder, 'illumination', 'specular-mean-interp.png'), ...
    uint8(MultispectralToSRGB(specularIlluminationMeanInterp, S, toneMapFactor, isScale)));

function spexel = extractMaterialSpexel(material, propertyName, spacing, spexelWls)
propertyNames = {material.properties.propertyName};
isProperty = strcmp(propertyNames, propertyName);
property = material.properties(isProperty);
[wls, mags] = SparseSpectrumToRegular(property.propertyValue, spacing);
spexel = SplineRaw(wls', mags', spexelWls);
