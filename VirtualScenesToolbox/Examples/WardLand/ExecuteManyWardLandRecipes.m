%% Locate, unpack, and execute many WardLand recipes created earlier.

% Use this script to render many packed-up recipes that you created
% earlier, using MakeManyWardLandRecipes.

clear;
clc;

% location of packed-up recipes
projectName = 'WardLand';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'outputFolder'), projectName);

% edit some batch renderer options
imageWidth = 640/4;
imageHeight = 480/4;

%% Locate and render each packed-up recipe.
archiveFiles = FindFiles(recipeFolder, '\.zip$');
nScenes = numel(archiveFiles);
recipes = cell(1, nScenes);
for ii = 1:nScenes
    recipes{ii} = UnpackRecipe(archiveFiles{ii});
    recipes{ii}.input.hints.imageWidth = imageWidth;
    recipes{ii}.input.hints.imageHeight = imageHeight;
    recipes{ii} = ExecuteRecipe(recipes{ii});
end
