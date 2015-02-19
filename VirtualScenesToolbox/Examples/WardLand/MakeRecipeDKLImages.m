% Convert some LMS images to DKL representations.
%   @param recipe a recipe from BuildWardLandRecipe()
%   @param lmsSensitivities a Psychtoolbox colorimetric mat-file name
%   @param dklSensitivities a Psychtoolbox colorimetric mat-file name
%
% @details
% Converts some of the WardLand LMS sensor images for the given @a recipe
% to DKL sensor images and writes the DKL images to disk.  See 
% MakeRecipeMLSImages().
%
% @details
% By default, uses Psychtoolbox cone "ss2" and CIE "y2" sensitivities to
% compute the DKL images.  If @a lmsSensitivities or @a dklSensitivities
% is provided, each must be an alternative Psychtoolbox colorimetric
% mat-file to use instead.
%
% @details
% Returns the given @a recipe, updated with new DKL images:
%   - recipe.processing.dkl.diffuseIlluminationInterp will contain a struct
%   with the names of new grayscale image files for L, RG, and BY sensor
%   images, based on the WardLand interpolated, diffuse illumination image.
%   - recipe.processing.dkl.diffuseIlluminationMeanInterp will contain a
%   struct with the names of new grayscale image files for L, RG, and BY
%   sensor images, based on the WardLand illumination image with mean
%   illumination taken over each object.
%   - recipe.processing.dkl.diffuseReflectanceInterp will contain a struct
%   with the names of new grayscale image files for L, RG, and BY sensor
%   images, based on the WardLand interpolated, diffuse reflectance image.
%   .
% @details
% Usage:
%   recipe = MakeRecipeDKLImages(recipe, lmsSensitivities, dklSensitivities)
%
% @ingroup WardLand
function recipe = MakeRecipeDKLImages(recipe, lmsSensitivities, dklSensitivities)

if nargin < 2 || isempty(lmsSensitivities)
    lmsSensitivities = 'T_cones_ss2';
end

if nargin < 3 || isempty(dklSensitivities)
    dklSensitivities = 'T_CIE_Y2';
end

% get lms and skl sensitivity functions
S = recipe.processing.multispectral.S;
lms = load(lmsSensitivities);
dkl = load(dklSensitivities);
T_lms = SplineCmf(lms.S_cones_ss2, lms.T_cones_ss2, S);
T_dkl = SplineCmf(dkl.S_CIE_Y2, dkl.T_CIE_Y2, S);

% where to write out new images
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);

% compute DKL for diffuse illumination
recipe.processing.dkl.diffuseIlluminationInterp = ...
    computeDKL('diffuseIlluminationInterp', ...
    recipe.processing.lms.diffuseIlluminationInterp.lmsImage, ...
    T_lms, ...
    T_dkl, ...
    imageFolder);

% compute DKL for diffuse illumination, mean per object
recipe.processing.dkl.diffuseIlluminationMeanInterp = ...
    computeDKL('diffuseIlluminationMeanInterp', ...
    recipe.processing.lms.diffuseIlluminationMeanInterp.lmsImage, ...
    T_lms, ...
    T_dkl, ...
    imageFolder);

% compute DKL for diffuse reflectance
recipe.processing.dkl.diffuseReflectanceInterp = ...
    computeDKL('diffuseReflectanceInterp', ...
    recipe.processing.lms.diffuseReflectanceInterp.lmsImage, ...
    T_lms, ...
    T_dkl, ...
    imageFolder);

function dklData = computeDKL(name, lmsImage, T_lms, T_dkl, imageFolder)
% convert lms image to Psychtoolbox "cal format" for processing
nX = size(lmsImage, 2);
nY = size(lmsImage, 1);
[lmsImageCalFormat, nXCheck, nYCheck] = ImageToCalFormat(lmsImage);
if (nX ~= nXCheck || nY ~= nYCheck)
    error('Something wonky about converstion into cal format');
end

% subtract mean of each LMS channel as the "background"
lmsMeans = mean(lmsImageCalFormat, 2);
lsmResidualImageCalFormat = bsxfun(@minus, lmsImageCalFormat, lmsMeans);

% compute the DKL image
M_LsmResidualToDKL = ComputeDKL_M(lmsMeans, T_lms, T_dkl);
dklImageCalFormat = M_LsmResidualToDKL * lsmResidualImageCalFormat;
dklData.dklImage = CalFormatToImage(dklImageCalFormat, nX, nY);

% for visualization, stretch each dkl plane into full range of grayscale
dklImageScaled = zeros(size(dklData.dklImage));
for ii = 1:3
    thisPlaneIn = dklData.dklImage(:,:,ii);
    thisPlaneMaxAbs = max(abs(thisPlaneIn(:)));
    thisPlaneOut = thisPlaneIn / thisPlaneMaxAbs + 0.5;
    dklImageScaled(:,:,ii) = thisPlaneOut;
end

% write out D, K, and L channels to disk
dklData.l = WriteImage( ...
    fullfile(imageFolder, 'dkl', [name '-l.png']), ...
    dklImageScaled(:,:,1));

dklData.rg = WriteImage( ...
    fullfile(imageFolder, 'dkl', [name '-rg.png']), ...
    dklImageScaled(:,:,2));

dklData.by = WriteImage( ...
    fullfile(imageFolder, 'dkl', [name '-by.png']), ...
    dklImageScaled(:,:,3));

% write all of the DKL data
dklData.all = fullfile(imageFolder, 'dkl', [name '-all.mat']);
dklImage = dklData.dklImage;
save(dklData.all, 'name', 'lmsImage', 'T_lms', 'T_dkl', 'dklImage');
