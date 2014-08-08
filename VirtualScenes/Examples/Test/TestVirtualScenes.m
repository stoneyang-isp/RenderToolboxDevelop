%% Test the Virtual Scenes tools.
clear
clc

%% Choose options;
hints.whichConditions = [];
hints.imageWidth = 200;
hints.imageHeight = 160;
hints.renderer = 'Mitsuba';
hints.recipeName = 'TestVirtualScenes';

ChangeToWorkingFolder(hints);

%% Set up the base scene.
sceneName = 'IndoorPlant';
sceneMetadata = ReadMetadata(sceneName);

parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);
defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');
mappingsFile = 'TestMappings.txt';
conditionsFile = 'TestConditions.txt';

% append mappings to the base mappings
plainMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
AppendLightMappings(defaultMappings, mappingsFile, sceneMetadata.lightIds);
AppendMaterialMappings(mappingsFile, mappingsFile, sceneMetadata.materialIds);

%% Coordinate mappings and conditions that will insert random objects.
objectNames = {'Barrel', 'ChampagneBottle', 'RingToy', 'Xylophone'};

nInserted = 5;

wls = 300:10:800;

allNames = {};
allValues = {};
for ii = 1:nInserted
    % choose an object
    objectName = sprintf('object-%d', ii);
    modelName = objectNames{randi(numel(objectNames))};
    objectMetadata = ReadMetadata(modelName);
    objectModelPath = GetVirtualScenesPath(objectMetadata.relativePath);

    % choose object reflectance
    reflectance = GetSingleBandReflectance(wls, 10+ii, 1);
    
    % choose object position
    position = GetRandomPosition(sceneMetadata.boundingVolume);
    
    % choose conditions for this object
    reflectanceName = sprintf('reflectance-%d', ii);
    positionName = sprintf('position-%d', ii);
    varNames = {objectName, reflectanceName, positionName};
    maskValues = {objectModelPath, reflectance, position};
    realValues = {objectModelPath, reflectance, position};
    
    allNames = cat(2, allNames, varNames);
    allValues = cat(2, allValues, maskValues);
    
    % pack up materials for this object
    nMaterials = numel(objectMetadata.materialIds);
    objectMatte = plainMatte;
    objectMatte.properties(1).propertyValue = ['(' reflectanceName ')'];
    materialDescriptions = cell(1, nMaterials);
    [materialDescriptions{:}] = deal(objectMatte);
    
    % append mappings for this object's materials
    idPrefix = [objectName '-'];
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        objectMetadata.materialIds, materialDescriptions, idPrefix);
end

WriteConditionsFile(conditionsFile, allNames, allValues);

%% Pack up a recipe for this virutal scene.
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @MakeRecipeMontage, ...
    };

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

%% Will it render?
recipe = ExecuteRecipe(recipe);