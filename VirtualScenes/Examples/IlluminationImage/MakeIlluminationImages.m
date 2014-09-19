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
greyishMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0.5 800:0.5'}, ...
    {'spectrum'});

reddishMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0.1 650:0.1 660:0.9 800:0.9'}, ...
    {'spectrum'});

greenishMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0.1 490:0.1 500:0.9 600:0.9 610:0.1 800:0.1'}, ...
    {'spectrum'});

blueishMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0.9 490:0.9 500:0.1 800:0.1'}, ...
    {'spectrum'});

materials = {greyishMatte, reddishMatte, greenishMatte, blueishMatte};

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
baseSceneNames = {'IndoorPlant'};
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
    objectMaterials = cell(1, nInserted);
    for oo = 1:nInserted
        objectModel = insertedObjects{oo};
        objectMetadata = ReadMetadata(objectModel);
        objectModelPath = GetVirtualScenesPath(objectMetadata.relativePath);
        
        % choose object position
        objectPositions{oo} = GetRandomPosition(baseSceneMetadata.boundingVolume);
        
        % choose a material for this object
        objectMaterials{oo} = materials{randi(numel(materials))};
    end
    
    sceneName = sprintf('VirtualScene-%d', bb);
    recipe = BuildVirtualSceneRecipe(sceneName, hints, defaultMappings, ...
        baseSceneModel, baseSceneMaterials, baseSceneLights, ...
        insertedObjects, objectPositions, objectMaterials);
    
    recipe = ExecuteRecipe(recipe);
    
    recipeArchives{oo} = fullfile(GetUserFolder(), 'render-toolbox', sceneName);
    PackUpRecipe(recipe, recipeArchives{oo}, {'temp'});
end
