%% Test the Virtual Scenes tools.
clear;
clc;

%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.isPlot = false;
hints.renderer = 'Mitsuba';
hints.recipeName = 'TestVirtualScenes';

defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');
resources = GetWorkingFolder('resources', false, hints);

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
scale = 1.1;
spd = GenerateCIEDay(4000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, fullfile(resources, 'Sun.spd'));

sunArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sun.spd'}, ...
    {'spectrum'});

spd = GenerateCIEDay(10000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, fullfile(resources, 'Sky.spd'));

skyArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sky.spd'}, ...
    {'spectrum'});

lights = {whiteArea, sunArea, skyArea};

%% Choose sets of base scenes and objects to work with.
baseSceneNames = {'Warehouse'};
objectNames = {'Barrel', 'ChampagneBottle', 'RingToy', 'Xylophone'};

%% Make a recipe for each base scene, with some objects inserted.
nBaseScenes = 1;
nInserted = 4;
recipeArchives = cell(1, nBaseScenes);
for bb = 1:nBaseScenes
    % choose a base scene model
    baseSceneModel = baseSceneNames{randi(numel(baseSceneNames))};
    baseSceneMetadata = ReadMetadata(baseSceneModel);
    baseSceneModelPath = GetVirtualScenesPath(baseSceneMetadata.relativePath);
    
    % choose materials for the base scene
    nMaterials = numel(baseSceneMetadata.materialIds);
    baseSceneMaterials = materials(randi(numel(materials), [1, nMaterials]));
    
    % choose lights for the base scene
    nLights = numel(baseSceneMetadata.lightIds);
    baseSceneLights = lights(randi(numel(lights), [1, nLights]));
    
    % choose objects to insert in the model
    insertedObjects = objectNames(randi(numel(objectNames), [1, nInserted]));
    objectPositions = cell(1, nInserted);
    objectMaterialSets = cell(1, nInserted);
    for oo = 1:nInserted
        objectModel = insertedObjects{oo};
        objectMetadata = ReadMetadata(objectModel);
        objectModelPath = GetVirtualScenesPath(objectMetadata.relativePath);
        
        % choose object position
        objectPositions{oo} = GetRandomPosition(baseSceneMetadata.boundingVolume);
        
        % choose a set of materials for this object
        objectMaterial = materials{randi(numel(materials))};
        materialSet = cell(size(objectMetadata.materialIds));
        [materialSet{:}] = deal(objectMaterial);
        objectMaterialSets{oo} = materialSet;
    end
    
    sceneName = sprintf('VirtualScene-%d', bb);
    recipe = BuildVirtualSceneRecipe(sceneName, hints, defaultMappings, ...
        baseSceneModel, baseSceneMaterials, baseSceneLights, ...
        insertedObjects, objectPositions, objectMaterialSets);
    
    recipe = ExecuteRecipe(recipe);
    
    recipeArchives{oo} = fullfile(GetUserFolder(), 'render-toolbox', sceneName);
    PackUpRecipe(recipe, recipeArchives{oo}, {'temp'});
end
