%% Construct, execute, and archive a set of Ward Land feference recipes.
clear;
clc;

% choose batch renderer options
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.isPlot = false;
hints.renderer = 'Mitsuba';
defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');

% choose virutal scenes options
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

% render, process and archive
plantAndBarrel = ExecuteRecipe(plantAndBarrel);
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

% render, process and archive
nearFarWarehouse = ExecuteRecipe(nearFarWarehouse);
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

% render, process and archive
mondrian = ExecuteRecipe(mondrian);
archive = fullfile( ...
    getpref('VirtualScenes', 'outputFolder'), hints.recipeName);
PackUpRecipe(mondrian, archive, {'temp'});

%% Build the Blobbie recipe.

% doesn't work yet
return;

hints.recipeName = 'Blobbies';
ChangeToWorkingFolder(hints);
[matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
lightSpectra = GetWardLandIlluminantSpectra(hints);

% assemble the recipe
choices = GetWardLandChoices('CheckerBoard', ...
    {'Blobbie1', 'Blobbie2', 'Blobbie3', 'Blobbie4'}, 5, ...
    {'BigBall', 'LittleBall', 'Panel'}, 3, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightSpectra);
blobbies = BuildWardLandRecipe(defaultMappings, choices, hints);
