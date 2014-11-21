%% Locate, unpack, and execute WardLand reference recipes created earlier.

% Use this script to render several accompanying packed-up recipes.

clear;
clc;

% Edit some batch renderer options.
imageWidth = 640/4;
imageHeight = 480/4;

%% Plant and barrel.
archive = fullfile(getpref('VirtualScenes', 'outputFolder'), 'PlantAndBarrel.zip');
plantAndBarrel = UnpackRecipe(archive);
plantAndBarrel.input.hints.imageWidth = imageWidth;
plantAndBarrel.input.hints.imageHeight = imageHeight;
plantAndBarrel = ExecuteRecipe(plantAndBarrel);

%% Warehouse with near and areas of interest.
archive = fullfile(getpref('VirtualScenes', 'outputFolder'), 'NearFarWarehouse.zip');
nearFarWarehouse = UnpackRecipe(archive);
nearFarWarehouse.input.hints.imageWidth = imageWidth;
nearFarWarehouse.input.hints.imageHeight = imageHeight;
nearFarWarehouse = ExecuteRecipe(nearFarWarehouse);

%% Flat checkerboard with no inserted objects.
archive = fullfile(getpref('VirtualScenes', 'outputFolder'), 'Mondrian.zip');
mondrian = UnpackRecipe(archive);
mondrian.input.hints.imageWidth = imageWidth;
mondrian.input.hints.imageHeight = imageHeight;
mondrian = ExecuteRecipe(mondrian);

%% Checkerboard with many inserted blobbie objects.
archive = fullfile(getpref('VirtualScenes', 'outputFolder'), 'Blobbies.zip');
blobbies = UnpackRecipe(archive);
blobbies.input.hints.imageWidth = imageWidth;
blobbies.input.hints.imageHeight = imageHeight;
blobbies = ExecuteRecipe(blobbies);
