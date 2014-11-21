%% Construct and archive a set of Ward Land reference recipes.

% We used this script to generate the accompanying packed-up recipes.
% You should not need to run this script again.  Instead, run
% ExecuteWardLandReferenceRecipes to render the packed-up recipes.

%% Overall configuration.

clear;
clc;

% batch renderer options
hints.renderer = 'Mitsuba';
defaultMappings = fullfile( ...
    VirtualScenesRoot(), 'MiscellaneousData', 'DefaultMappings.txt');
hints.isPlot = false;

% virutal scenes options for inserted objects
scaleMin = 0.25;
scaleMax = 2.0;
rotMin = 0;
rotMax = 359;

%% Build the Plant and Barrel Recipe.
hints.recipeName = 'PlantAndBarrel';
ChangeToWorkingFolder(hints);
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(hints);

% assemble the recipe
choices = GetWardLandChoices('IndoorPlant', ...
    {'Barrel', 'Xylophone'}, 4, ...
    {}, 0, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);
plantAndBarrel = BuildWardLandRecipe(defaultMappings, choices, hints);

% archive it archive
archive = fullfile( ...
    getpref('VirtualScenes', 'outputFolder'), hints.recipeName);
PackUpRecipe(plantAndBarrel, archive, {'temp'});

%% Build the Near and Far Warehouse Recipe.
hints.recipeName = 'NearFarWarehouse';
ChangeToWorkingFolder(hints);
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(hints);

% assemble the recipe
choices = GetWardLandChoices('Warehouse', ...
    {'Barrel', 'Xylophone', 'RingToy', 'ChampagneBottle'}, 5, ...
    {}, 0, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);
nearFarWarehouse = BuildWardLandRecipe(defaultMappings, choices, hints);

% archive it
archive = fullfile( ...
    getpref('VirtualScenes', 'outputFolder'), hints.recipeName);
PackUpRecipe(nearFarWarehouse, archive, {'temp'});

%% Build the Mondrian recipe.
hints.recipeName = 'Mondrian';
ChangeToWorkingFolder(hints);
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(hints);

% assemble the recipe
choices = GetWardLandChoices('CheckerBoard', ...
    {}, 0, ...
    {}, 0, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);
mondrian = BuildWardLandRecipe(defaultMappings, choices, hints);

% archive it
archive = fullfile( ...
    getpref('VirtualScenes', 'outputFolder'), hints.recipeName);
PackUpRecipe(mondrian, archive, {'temp'});

%% Build the Blobbie recipe.
hints.recipeName = 'Blobbies';
ChangeToWorkingFolder(hints);
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(hints);

% assemble the recipe
choices = GetWardLandChoices('CheckerBoard', ...
    {'Blobbie-01', 'Blobbie-02', 'Blobbie-03', 'Blobbie-04', 'Blobbie-05'}, 5, ...
    {'BigBall', 'SmallBall', 'Panel'}, 3, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);
blobbies = BuildWardLandRecipe(defaultMappings, choices, hints);

% archive it
archive = fullfile( ...
    getpref('VirtualScenes', 'outputFolder'), hints.recipeName);
PackUpRecipe(blobbies, archive, {'temp'});
