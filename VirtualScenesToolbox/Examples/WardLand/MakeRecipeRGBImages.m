%% Convert recipe multi-spectral renderings to sRGB representations.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param toneMapFactor passed to MakeMontage()
%   @param isScale passed to MakeMontage()
%
% @details
% Processes several WardLand multi-spectral renderings and makes sRGB
% representations of them.  @a toneMapFactor and @a isScale affect scaling
% of the sRGB images.  See MultispectralToSRGB() and XYZToSRGB().
%
% @details
% Saves sRGB images in the "radiance" processing group.  See
% SaveRecipeProcessingImageFile().
%
% @details
% Usage:
%   recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale)
%
% @ingroup WardLand
function recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale)

if nargin < 2 || isempty(toneMapFactor)
    toneMapFactor = 100;
end

if nargin < 3 || isempty(isScale)
    isScale = true;
end

%% Load scene renderings.
nRenderings = numel(recipe.rendering.radianceDataFiles);
maskDataFiles = {};
for ii = 1:nRenderings
    dataFile = recipe.rendering.radianceDataFiles{ii};
    if ~isempty(strfind(dataFile, 'matte.mat'))
        matteDataFile = dataFile;
    elseif ~isempty(strfind(dataFile, 'ward.mat'))
        wardDataFile = dataFile;
    elseif ~isempty(regexp(dataFile, 'mask-\d+\.mat$', 'once'));
        maskDataFiles{end+1} = dataFile;
    end
end

%% Get multi-spectral and sRGB radiance images.
wardRendering = load(wardDataFile);
wardRadiance = wardRendering.multispectralImage;

matteRendering = load(matteDataFile);
matteRadiance = matteRendering.multispectralImage;

specularRadiance = wardRadiance - matteRadiance;

S = wardRendering.S;
wardSRGB = uint8(MultispectralToSRGB(wardRadiance, S, toneMapFactor, isScale));
matteSRGB = uint8(MultispectralToSRGB(matteRadiance, S, toneMapFactor, isScale));
specularSRGB = uint8(MultispectralToSRGB(specularRadiance, S, toneMapFactor, isScale));

nMaskRenderings = numel(maskDataFiles);
maskSRGB = cell(1, nMaskRenderings);
for ii = 1:nMaskRenderings
    maskRendering = load(maskDataFiles{ii});
    maskRadiance = maskRendering.multispectralImage;
    maskSRGB{ii} = uint8(MultispectralToSRGB(maskRadiance, S, toneMapFactor, isScale));
end

%% Save images to disk.
group = 'radiance';
format = 'png';
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBWard', format, wardSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBMatte', format, matteSRGB);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'SRGBSpecular', format, specularSRGB);

for ii = 1:nMaskRenderings
    maskName = sprintf('SRGBMask%d', ii);
    recipe = SaveRecipeProcessingImageFile(recipe, group, maskName, format, maskSRGB{ii});
end

recipe = SetRecipeProcessingData(recipe, group, 'S', S);
recipe = SaveRecipeProcessingImageFile(recipe, group, 'specular', 'mat', specularRadiance);
