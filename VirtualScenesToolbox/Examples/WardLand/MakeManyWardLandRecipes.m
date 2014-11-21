%% Construct and archive a set of many Ward Land recipes.

% You can use this script to generate the a large set of packed-up recipes.
% You should not need to run this script very often.  Instead, run
% ExecuteManyWardLandRecipes to execute all the packed-up recipes.

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

% where to save new recipes
projectName = 'WardLand';
recipeFolder = ...
    fullfile(getpref('VirtualScenes', 'outputFolder'), projectName);
if (~exist(recipeFolder, 'dir'))
    mkdir(recipeFolder);
end

%% Choose how many recipes to make and from what components.
nScenes = 2;
nObjectsPerScene = 5;
nLightsPerScene = 2;

baseSceneSet = { ...
    'IndoorPlant', ...
    'Warehouse', ...
    'CheckerBoard'};

objectSet = { ...
    'Barrel', ...
    'Blobbie-01', ...
    'Blobbie-02', ...
    'Blobbie-03', ...
    'Blobbie-04', ...
    'Blobbie-05', ...
    'ChampagneBottle', ...
    'RingToy', ...
    'SmallBall', ...
    'Xylophone', ...
    };

lightSet = { ...
    'BigBall', ...
    'SmallBall', ...
    'Panel', ...
    };

%% Build multiple from the sets above.
for ii = 1:nScenes
    % start a new recipe
    hints.recipeName = sprintf('%s-%02d', projectName, ii);
    ChangeToWorkingFolder(hints);
    
    % make sure Ward Land resources are available to this recipe
    [matteMaterials, wardMaterials] = GetWardLandMaterials(hints);
    lightSpectra = GetWardLandIlluminantSpectra(hints);
    
    % choose a random base scene for this recipe
    baseScene = baseSceneSet{randi(numel(baseSceneSet), 1)};
    
    % choose objects, materials, lights, and spectra for this recipe
    choices = GetWardLandChoices(baseScene, ...
        objectSet, nObjectsPerScene, ...
        lightSet, nLightsPerScene, ...
        scaleMin, scaleMax, rotMin, rotMax, ...
        matteMaterials, wardMaterials, lightSpectra);
    
    % assemble the recipe
    recipe = BuildWardLandRecipe(defaultMappings, choices, hints);
    
    % archive it
    %   only include the resources subfolder
    archiveFile = fullfile(recipeFolder, hints.recipeName);
    excludeFolders = {'scenes', 'renderings', 'images', 'temp'};
    PackUpRecipe(recipe, archiveFile, excludeFolders);
end
