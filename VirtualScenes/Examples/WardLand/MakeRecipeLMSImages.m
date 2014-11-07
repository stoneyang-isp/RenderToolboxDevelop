% Convert some illumination and reflectance images to LMS representations.
%   recipe should be a recipe from BuildWardLandRecipe()
%   sensitivities should be a Psychtoolbox colorimetric mat-file name
function recipe = MakeRecipeLMSImages(recipe, sensitivities)

if nargin < 2 || isempty(sensitivities)
    sensitivities = 'T_cones_ss2';
end

% where to write out new images
imageFolder = GetWorkingFolder('images', true, recipe.input.hints);

% compute LMS for diffuse illumination
recipe.processing.lms.diffuseIlluminationInterp = ...
    computeLMS('diffuseIlluminationInterp', ...
    recipe.processing.multispectral.diffuseIlluminationInterp, ...
    recipe.processing.multispectral.S, ...
    sensitivities, ...
    imageFolder);

% compute LMS for diffuse illumination, mean per object
recipe.processing.lms.diffuseIlluminationMeanInterp = ...
    computeLMS('diffuseIlluminationMeanInterp', ...
    recipe.processing.multispectral.diffuseIlluminationMeanInterp, ...
    recipe.processing.multispectral.S, ...
    sensitivities, ...
    imageFolder);

% compute LMS for diffuse reflectance
recipe.processing.lms.diffuseReflectanceInterp = ...
    computeLMS('diffuseReflectanceInterp', ...
    recipe.processing.multispectral.diffuseReflectanceInterp, ...
    recipe.processing.multispectral.S, ...
    sensitivities, ...
    imageFolder);

function lmsData = computeLMS(name, multispectral, S, sensitivities, imageFolder)
% compute actual LMS sensor image
lmsData.lmsImage = ...
    MultispectralToSensorImage(multispectral, S, sensitivities);

% write out L, M, and S channels to disk
lmsMax = max(lmsData.lmsImage(:));

lmsData.l = WriteImage( ...
    fullfile(imageFolder, 'lms', [name '-l.png']), ...
    lmsData.lmsImage(:,:,1) ./ lmsMax);

lmsData.m = WriteImage( ...
    fullfile(imageFolder, 'lms', [name '-m.png']), ...
    lmsData.lmsImage(:,:,2) ./ lmsMax);

lmsData.s = WriteImage( ...
    fullfile(imageFolder, 'lms', [name '-s.png']), ...
    lmsData.lmsImage(:,:,3) ./ lmsMax);

% write all of the LMS data
lmsData.all = fullfile(imageFolder, 'lms', [name '-all.mat']);
lmsImage = lmsData.lmsImage;
save(lmsData.all, 'name', 'multispectral', 'S', 'sensitivities', 'lmsImage');
