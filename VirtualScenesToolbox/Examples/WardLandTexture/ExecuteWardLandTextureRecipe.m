%% Locate, unpack, and execute a WardLand Texture recipe created eariler.
%
% Use this script to render an archived recipe created earlier, using
% MakeWardLandTextureRecipe.
%
% You can configure a few recipe parameters at the top of this script.
% For example, you can change the output image size here, when you execute
% the recipe.  You don't have to generate a new recipe to change the image
% size.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLandTexture';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
    return;
end

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640;
hints.imageHeight = 480;


%% Locate the packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = numel(archiveFiles);
if nScenes < 1
    disp('Recipe  not found!');
    return;
end

recipe = UnpackRecipe(archiveFiles{1}, hints);

recipe.input.hints.renderer = hints.renderer;
recipe.input.hints.workingFolder = hints.workingFolder;
recipe.input.hints.imageWidth = hints.imageWidth;
recipe.input.hints.imageHeight = hints.imageHeight;


%% Render in steps to contain errors.
% scene files
recipe = ExecuteRecipe(recipe, 1);

% main rendering
recipe = ExecuteRecipe(recipe, 2);

%% Cobble together some analyses.
toneMapFactor = 100;
isScale = true;
pixelThreshold = 0.01;
filterWidth = 7;

recipe = MakeRecipeRGBImages(recipe, toneMapFactor, isScale);
recipe = MakeRecipeObjectMasks(recipe, pixelThreshold);
recipe = MakeRecipeReflectanceImages(recipe, filterWidth, toneMapFactor, isScale);
recipe = MakeRecipeAlbedoFactoidImages(recipe, toneMapFactor, isScale);

%% Compare reflectance and albedo and resulting illumination images.
radiance = LoadRecipeProcessingImageFile(recipe, 'radiance', 'SRGBMatte');
albedo = LoadRecipeProcessingImageFile(recipe, 'albedo', 'SRGBAlbedo');
reflect = LoadRecipeProcessingImageFile(recipe, 'reflectance', 'SRGBDiffuseInterp');

recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale, true);
illumAlbedoRaw = LoadRecipeProcessingImageFile(recipe, 'illumination', 'SRGBDiffuseRaw');
illumAlbedoInterp = LoadRecipeProcessingImageFile(recipe, 'illumination', 'SRGBDiffuseInterp');

recipe = MakeRecipeIlluminationImages(recipe, filterWidth, toneMapFactor, isScale, false);
illumReflectRaw = LoadRecipeProcessingImageFile(recipe, 'illumination', 'SRGBDiffuseRaw');
illumReflectInterp = LoadRecipeProcessingImageFile(recipe, 'illumination', 'SRGBDiffuseInterp');

%% Show side by side.
imageFolder = GetWorkingFolder('images', false, recipe.input.hints);
montageName = fullfile(imageFolder, 'albedo-vs-reflect.png');
images = { ...
    radiance, radiance; ...
    albedo, reflect; ...
    illumAlbedoRaw, illumReflectRaw; ...
    illumAlbedoInterp, illumReflectInterp; ...
    };

names = { ...
    'radiance', 'radiance'; ...
    'albedo factoid', 'our reflectance'; ...
    'albedo illum raw', 'reflectance illum raw'; ...
    'albedo illum interp', 'reflectance illum interp'; ...
    };

MakeImageMontage(montageName, images, names);


%% TODO: finish refactoring!
%
% boring, LMS, DKL, basic montage, rgb factoids, rgb, factoid montage
%
% Build recipe just does basic executive
%
% Execute recipe adds in longer executive
%