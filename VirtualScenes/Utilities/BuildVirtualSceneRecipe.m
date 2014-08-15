%% Build a recipe for a virutal scene.
%   sceneName should be any name for this new recipe
%   hints should be batch renderer hints
%   defaultMappings should be 'DefaultMappings.txt', etc.
%   baseSceneModel should be 'IndoorPlant' etc.
%   baseSceneMaterials should be {material1, material2, ...}
%   baseSceneLights should be {light1, light2, ...}
%   insertedObjects should be {'Barrel', 'Barrel', 'RingToy', ...}
%   objectPositions should be {[xyz], [xyz], [xyz], ...}
%   objectMaterials should be {{materialSet1}, {materialSet2}, {materialSet3}, ...}
function recipe = BuildVirtualSceneRecipe(sceneName, hints, defaultMappings, ...
    baseSceneModel, baseSceneMaterials, baseSceneLights, ...
    insertedObjects, objectPositions, objectMaterialSets)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Augment batch renderer options.
hints.whichConditions = 1:2;
hints.remodeler = 'InsertObjectRemodeler';

ChangeToWorkingFolder(hints);

mappingsFile = [sceneName '-Mappings.txt'];
conditionsFile = [sceneName '-Conditions.txt'];

sceneMetadata = ReadMetadata(baseSceneModel);
parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);

%% Set up the base scene.
% set base scene lights to white area lights when making pixel masks
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
maskBaseSceneLightSet = cell(1, numel(sceneMetadata.lightIds));
[maskBaseSceneLightSet{:}] = deal(whiteArea);

% set base scene materials to matte white when making pixel masks
whiteMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
maskBaseSceneMaterialSet = cell(size(baseSceneMaterials));
[maskBaseSceneMaterialSet{:}] = deal(whiteMatte);

% write out mappings for base scene lights
AppendLightMappings(defaultMappings, mappingsFile, ...
    sceneMetadata.lightIds, baseSceneLights, 'Generic scene');
AppendLightMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, maskBaseSceneLightSet, 'Generic mask');

% write out mappings for base scene materials
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, baseSceneMaterials, [], 'Generic scene');
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, maskBaseSceneMaterialSet, [], 'Generic mask');

%% Set up inserted objects.
% choose single-band reflectances starting at 400nm
wls = 300:10:800;
startIndex = 10;

% basic conditions file columns
allNames = {'imageName', 'groupName'};
allValues = {'mask', 'mask'; 'scene', 'scene'};

nInserted = numel(insertedObjects);
for oo = 1:nInserted
    % get each object model
    modelName = insertedObjects{oo};
    objectMetadata = ReadMetadata(modelName);
    
    % identify each object with a single-band reflectance
    reflectance = GetSingleBandReflectance(wls, startIndex+oo, 1);
    singleBandMatte = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        reflectance, ...
        {'spectrum'});
    maskObjectMaterialSet = cell(1, numel(objectMetadata.materialIds));
    [maskObjectMaterialSet{:}] = deal(singleBandMatte);
    
    % add conditions columns for each object
    objectColumn = sprintf('object-%d', oo);
    positionColumn = sprintf('position-%d', oo);
    objectModelPath = objectMetadata.relativePath;
    objectPosition = objectPositions{oo};
    
    varNames = {objectColumn, positionColumn};
    varValues = {objectModelPath, objectPosition; ...
        objectModelPath, objectPosition;};
    
    allNames = cat(2, allNames, varNames);
    allValues = cat(2, allValues, varValues);
    
    % write out mappings for object materials
    idPrefix = [objectColumn '-'];
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        objectMetadata.materialIds, objectMaterialSets{oo}, idPrefix, 'Generic scene');
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        objectMetadata.materialIds, maskObjectMaterialSet, idPrefix, 'Generic mask');
end

% write out the conditions file
WriteConditionsFile(conditionsFile, allNames, allValues);

%% Pack it all up in a recipe.
toneMapFactor = 100;
isScale = true;
pixelThreshold = 0.1;
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeVirtualSceneObjectMasks(recipe, pixelThreshold, [], toneMapFactor, isScale, sceneName)};

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

