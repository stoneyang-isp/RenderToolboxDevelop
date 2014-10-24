%% Test the Virtual Scenes tools.
clear;
clc;

%% Choose batch renderer options.
hints.imageWidth = 320;
hints.imageHeight = 240;
hints.isPlot = false;
hints.renderer = 'Mitsuba';
hints.recipeName = 'WardLand';

defaultMappings = fullfile(VirtualScenesRoot(), 'Data', 'DefaultMappings.txt');
resources = GetWorkingFolder('resources', false, hints);

ChangeToWorkingFolder(hints);

%% Choose a set of Color Checker materials to work with.
% with matte and ward variants
colorCheckerSpectra = GetColorCheckerSpectra();
nSpectra = numel(colorCheckerSpectra);
matteMaterials = cell(1, nSpectra);
wardMaterials = cell(1, nSpectra);
for ii = 1:nSpectra
    matteMaterials{ii} = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        colorCheckerSpectra(ii), ...
        {'spectrum'});
    specularSpectrum = sprintf('300:%.1f 800:%.1f', rand()*.5, rand()*.5);
    wardMaterials{ii} = BuildDesription('material', 'anisoward', ...
        {'diffuseReflectance', 'specularReflectance'}, ...
        {colorCheckerSpectra{ii}, specularSpectrum}, ...
        {'spectrum', 'spectrum'});
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
baseSceneNames = {'IndoorPlant'};
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
    whichMaterials = randi(numel(matteMaterials), [1, nMaterials]);
    baseSceneMatteMaterials = matteMaterials(whichMaterials);
    baseSceneWardMaterials = wardMaterials(whichMaterials);
    
    % choose lights for the base scene
    nLights = numel(baseSceneMetadata.lightIds);
    baseSceneLights = lights(randi(numel(lights), [1, nLights]));
    
    % choose objects to insert in the model
    insertedObjects = objectNames(randi(numel(objectNames), [1, nInserted]));
    objectPositions = cell(1, nInserted);
    objectMatteMaterialSets = cell(1, nInserted);
    objectWardMaterialSets = cell(1, nInserted);
    for oo = 1:nInserted
        objectModel = insertedObjects{oo};
        objectMetadata = ReadMetadata(objectModel);
        objectModelPath = GetVirtualScenesPath(objectMetadata.relativePath);
        
        % choose object position
        objectPositions{oo} = GetRandomPosition(baseSceneMetadata.boundingVolume);
        
        % choose a set of materials for this object
        nMaterials = numel(objectMetadata.materialIds);
        whichMaterials = randi(numel(matteMaterials), [1 nMaterials]);
        objectMatteMaterialSets{oo} = matteMaterials(whichMaterials);
        objectWardMaterialSets{oo} = wardMaterials(whichMaterials);
    end
    
    % build a new recipe
    recipe = BuildVirtualSceneRecipe(hints, defaultMappings, ...
        baseSceneName, ...
        baseSceneMatteMaterials, baseSceneWardMaterials, ...
        baseSceneLights, ...
        insertedObjects, objectPositions, ...
        objectMatteMaterialSets, objectWardMaterialSets);
    
    % clean up the working folder
    rmdir(GetWorkingFolder('images', false, hints), 's');
    rmdir(GetWorkingFolder('renderings', false, hints), 's');
    rmdir(GetWorkingFolder('scenes', false, hints), 's');
    rmdir(GetWorkingFolder('temp', false, hints), 's');
    
    % run the recipe and collect errors locally for debugging
    whichExecutives = 1:numel(recipe.input.executive);
    throwException = false;
    recipe = ExecuteRecipe(recipe, whichExecutives, throwException);
    errorData = GetFirstRecipeError(recipe, throwException);
    if ~isempty(errorData)
        rethrow(errorData);
    end
    
    % archive the recipe
    archiveName = sprintf('%s-%d', hints.recipeName, bb);
    recipeArchives{oo} = fullfile(GetUserFolder(), 'illumination-data', archiveName);
    PackUpRecipe(recipe, recipeArchives{oo}, {'temp'});
end
