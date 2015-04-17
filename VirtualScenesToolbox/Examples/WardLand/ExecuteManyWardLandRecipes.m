%% Locate, unpack, and execute many WardLand recipes created earlier.
%
% Use this script to render many archived recipes created earlier, using
% MakeManyWardLandRecipes.
%
% You can configure a few recipe parameters at the top of this script.
% The values will apply to all generated recipes.  For example, you can
% change the output image size here, when you execute the recipes.  You
% don't have to generate new recipes to change the image size.
%
% @ingroup WardLand

%% Overall Setup.
clear;
clc;

% location of packed-up recipes
projectName = 'WardLand';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'recipesFolder'), projectName);
if ~exist(recipeFolder, 'dir')
    disp(['Recipe folder not found: ' recipeFolder]);
end

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');
hints.imageWidth = 640;
hints.imageHeight = 480;

%% Choose how to execute the recipes.
toneMapFactor = 100;
isScale = true;

executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeRGBImages(recipe, toneMapFactor, isScale), ...
    };

%% Locate and render each packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = numel(archiveFiles);
recipes = cell(1, nScenes);
for ii = 1:nScenes
    recipes{ii} = UnpackRecipe(archiveFiles{ii}, hints);
    recipes{ii}.input.hints.renderer = hints.renderer;
    recipes{ii}.input.hints.workingFolder = hints.workingFolder;
    recipes{ii}.input.hints.imageWidth = hints.imageWidth;
    recipes{ii}.input.hints.imageHeight = hints.imageHeight;
    recipes{ii}.input.executive = executive;
    recipes{ii} = ExecuteRecipe(recipes{ii});
end

%% Analyze the renderings.
toneMapFactor = 10;
isScale = true;
filterWidth = 7;
lmsSensitivities = 'T_cones_ss2';
dklSensitivities = 'T_CIE_Y21';

for ii = 1:nScenes
    recipes{ii} = MakeRecipeAlbedoFactoidImages(recipes{ii}, toneMapFactor, isScale);
    recipes{ii} = MakeRecipeShapeIndexFactoidImages(recipes{ii});
    
    recipes{ii} = MakeRecipeIlluminationImages(recipes{ii}, filterWidth, toneMapFactor, isScale);
    recipes{ii} = MakeRecipeBoringComparison(recipes{ii}, toneMapFactor, isScale);
    
    recipes{ii} = MakeRecipeLMSImages(recipes{ii}, lmsSensitivities);
    recipes{ii} = MakeRecipeDKLImages(recipes{ii}, lmsSensitivities);
    
    recipes{ii} = MakeRecipeImageMontage(recipes{ii});
    recipes{ii} = MakeRecipeFactoids(recipes{ii});
    recipes{ii} = MakeRecipeFactoidMontage(recipes{ii});
end
