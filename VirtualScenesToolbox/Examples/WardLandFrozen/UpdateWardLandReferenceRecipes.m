%% Locate, unpack, update, and pack up WardLand reference recipes.

clear;
clc;

% locate the packed-up recipes
recipesFolder = fullfile( ...
    VirtualScenesRoot(), 'Examples', 'WardLandFrozen', 'Recipes');

% edit some batch renderer options
hints.renderer = 'Mitsuba';
hints.workingFolder = getpref('VirtualScenes', 'workingFolder');

%% Plant and barrel.
archive = fullfile(recipesFolder, 'PlantAndBarrel.zip');
plantAndBarrel = UnpackRecipe(archive, hints);
plantAndBarrel.input.executive{end+1} = @MakeRecipeFactoids;
PackUpRecipe(plantAndBarrel, archive);

%% Warehouse with near and areas of interest.
archive = fullfile(recipesFolder, 'NearFarWarehouse.zip');
nearFarWarehouse = UnpackRecipe(archive, hints);
nearFarWarehouse.input.executive{end+1} = @MakeRecipeFactoids;
PackUpRecipe(nearFarWarehouse, archive);

%% Flat checkerboard with no inserted objects.
archive = fullfile(recipesFolder, 'Mondrian.zip');
mondrian = UnpackRecipe(archive, hints);
mondrian.input.executive{end+1} = @MakeRecipeFactoids;
PackUpRecipe(mondrian, archive);

%% Checkerboard with many inserted blobbie objects.
archive = fullfile(recipesFolder, 'Blobbies.zip');
blobbies = UnpackRecipe(archive, hints);
blobbies.input.executive{end+1} = @MakeRecipeFactoids;
PackUpRecipe(blobbies, archive);
