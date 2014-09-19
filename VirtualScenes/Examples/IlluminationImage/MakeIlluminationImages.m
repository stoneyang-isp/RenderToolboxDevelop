%% Test the Virtual Scenes tools.
clear;
clc;

%% Choose batch renderer options.
hints.imageWidth = 640;
hints.imageHeight = 480;
hints.isPlot = false;
hints.renderer = 'Mitsuba';
hints.recipeName = 'IlluminationImages';

defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');
resources = GetWorkingFolder('resources', false, hints);

ChangeToWorkingFolder(hints);

%% Choose a set of Color Checker materials to work with.
colorCheckerSpectra = GetColorCheckerSpectra();
nSpectra = numel(colorCheckerSpectra);
materials = cell(1, nSpectra);
for ii = 1:nSpectra
    materials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
end

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

spd = GenerateCIEDay(20000, B_cieday);
spd = scale * spd ./ max(spd);
wls = SToWls(S_cieday);
WriteSpectrumFile(wls, spd, fullfile(resources, 'Sky.spd'));

skyArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'Sky.spd'}, ...
    {'spectrum'});

lights = {whiteArea, sunArea, skyArea};

%% Choose sets of base scenes and objects to work with.
baseSceneNames = {'IndoorPlant', 'IndoorPlant', 'Warehouse', 'Warehouse'};
objectNames = {'Barrel', 'ChampagneBottle', 'RingToy', 'Xylophone'};

%% Make a recipe for each base scene, with some objects inserted.
nBaseScenes = numel(baseSceneNames);
nInserted = 4;
recipeArchives = cell(1, nBaseScenes);
for bb = 1:nBaseScenes
    % choose a base scene model
    baseSceneName = baseSceneNames{bb};
    baseSceneMetadata = ReadMetadata(baseSceneName);
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
        baseSceneName, baseSceneMaterials, baseSceneLights, ...
        insertedObjects, objectPositions, objectMaterials);
    
    recipe = ExecuteRecipe(recipe);
    
    recipeArchives{oo} = fullfile(GetUserFolder(), 'render-toolbox', sceneName);
    PackUpRecipe(recipe, recipeArchives{oo}, {'temp'});
end
