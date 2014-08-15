%% Test the Virtual Scenes tools.
clear
clc

%% Choose options.
hints.whichConditions = [];
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.remodeler = 'InsertObjectRemodeler';
hints.renderer = 'Mitsuba';
hints.recipeName = 'TestVirtualScenes';

ChangeToWorkingFolder(hints);

%% Choose a set of materials to work with.
whiteMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});

orangeMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0 500:0 610:1 800:1'}, ...
    {'spectrum'});

greenWard = BuildDesription('material', 'anisoward', ...
    {'diffuseReflectance', 'specularReflectance'}, ...
    {'mccBabel-7.spd', '300:1 800:0'}, ...
    {'spectrum'});

goldMetal = BuildDesription('material', 'metal', ...
    {'roughness', 'eta', 'k'}, ...
    {0.5, 'Au.eta.spd', 'Au.k.spd'}, ...
    {'float', 'spectrum', 'spectrum'});

materials = {orangeMatte, greenWard, goldMetal};

%% Choose a set of lights to work with.
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});

load B_cieday
scale = 1.5;
spd = GenerateCIEDay(4000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, 'Sun.spd');

sunArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sun.spd'}, ...
    {'spectrum'});

spd = GenerateCIEDay(4000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, 'Sky.spd');

skyArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sky.spd'}, ...
    {'spectrum'});

lights = {whiteArea, sunArea, skyArea};

%% Set up the base scene.
sceneName = 'IndoorPlant';
sceneMetadata = ReadMetadata(sceneName);

parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);
defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');
mappingsFile = 'TestMappings.txt';
conditionsFile = 'TestConditions.txt';

% set base scene objects to matte white in when making masks
nBaseMaterials = numel(sceneMetadata.materialIds);
[baseMaskMaterials{1:nBaseMaterials}] = deal(whiteMatte);
AppendMaterialMappings(defaultMappings, mappingsFile, ...
    sceneMetadata.materialIds, baseMaskMaterials, [], 'Generic mask');

% set base scene object materials for the real scene
baseSceneMaterials = materials(randi(numel(materials), [1, nBaseMaterials]));
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, baseSceneMaterials, [], 'Generic scene');

% set base scene lights to white area when making masks
nBaseLights = numel(sceneMetadata.lightIds);
[baseMaskLights{1:nBaseLights}] = deal(whiteArea);
AppendLightMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, baseMaskLights, 'Generic mask');

% set base scene lights for the real scene
baseSceneLights = lights(randi(numel(lights), [1, nBaseLights]));
AppendLightMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, baseSceneLights, 'Generic scene');


%% Choose which objects to insert.
nInserted = 5;
modelNames = {'Barrel', 'ChampagneBottle', 'RingToy', 'Xylophone'};
insertedModels = modelNames(randi(numel(modelNames), [1, nInserted]));

% a "scene" material for each object
sceneMaterials = materials(randi(numel(materials), [1 nInserted]));

% a "mask material for each object
wls = 300:10:800;
maskMaterials = cell(1, nInserted);
for ii = 1:nInserted
    reflectance = GetSingleBandReflectance(wls, 10+ii, 1);
    maskMatte = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        reflectance, ...
        {'spectrum'});
    maskMaterials{ii} = maskMatte;
end

%% Assemble mappings and conditions that will insert random objects.
allNames = {'imageName', 'groupName'};
allValues = {'mask', 'mask'; 'scene', 'scene'};
for ii = 1:nInserted
    % choose an object
    objectName = sprintf('object-%d', ii);
    modelName = insertedModels{ii};
    objectMetadata = ReadMetadata(modelName);
    objectModelPath = GetVirtualScenesPath(objectMetadata.relativePath);
    
    % choose object position
    position = GetRandomPosition(sceneMetadata.boundingVolume);
    
    % add conditions file columns for this object
    positionName = sprintf('position-%d', ii);
    varNames = {objectName, positionName};
    maskValues = {objectModelPath, position; objectModelPath, position};
    
    allNames = cat(2, allNames, varNames);
    allValues = cat(2, allValues, maskValues);
    
    % add mappings blocks for this object's materials
    idPrefix = [objectName '-'];
    materialDescriptions = cell(size(objectMetadata.materialIds));
    [materialDescriptions{:}] = deal(maskMaterials{ii});
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        objectMetadata.materialIds, materialDescriptions, idPrefix, 'Generic mask');
    [materialDescriptions{:}] = deal(sceneMaterials{ii});
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        objectMetadata.materialIds, materialDescriptions, idPrefix, 'Generic scene');
end

WriteConditionsFile(conditionsFile, allNames, allValues);

%% Pack up a recipe for this virutal scene.
toneMapFactor = 100;
isScale = true;
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeMontage(recipe, toneMapFactor, isScale), ...
    };

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

%% Will it render?
recipe = ExecuteRecipe(recipe);