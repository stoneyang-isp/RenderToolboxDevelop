%% Sandbox for adjusting mask eagerness.

%% Load the recipe.
clear;
clc;

recipeFile = '/Users/ben/Documents/MATLAB/render-toolbox/WardLand-2.zip';
recipe = UnpackRecipe(recipeFile);
[scenePath, sceneBase, sceneExt] = fileparts(recipeFile);

%% Re-analyze the renderings with new parameters.
toneMapFactor = 100;
isScale = true;
pixelThreshold = 0.005;
filterWidth = 7;

recipe.input.executive{3} = @(recipe)MakeRecipeObjectMasks( ...
    recipe, pixelThreshold, toneMapFactor, isScale);
recipe.input.executive{4} = @(recipe)MakeRecipeIlluminationImage( ...
    recipe, filterWidth, toneMapFactor, isScale);

ExecuteRecipe(recipe, 3:4);

ShowDetail(recipe);
