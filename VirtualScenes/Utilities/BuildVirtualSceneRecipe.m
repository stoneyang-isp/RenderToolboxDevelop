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

%% Read scene and object metadata.
sceneMetadata = ReadMetadata(baseSceneModel);
parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);

flashMetadata = ReadMetadata('CameraFlash');

% each scene material gets has a corresponding
% single-band reflectance in the mask condition
materialsByIndex = cell(1, numel(baseSceneMaterials) + numel(objectMaterialSets));

%% Set up the base scene lights.
% set base scene lights turn off base scene lights when making pixel masks
blackArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:0 800:0'}, ...
    {'spectrum'});
maskBaseSceneLightSet = cell(1, numel(sceneMetadata.lightIds));
[maskBaseSceneLightSet{:}] = deal(blackArea);

% write out mappings for base scene lights
AppendLightMappings(defaultMappings, mappingsFile, ...
    sceneMetadata.lightIds, baseSceneLights, 'Generic scene');
AppendLightMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, maskBaseSceneLightSet, 'Generic mask');

%% Identify each base scene object with a single-band reflectance.
maskBaseSceneMaterialSet = cell(size(baseSceneMaterials));

% choose single-band reflectances starting at 400nm
wls = 300:10:800;
wlsOffset = 10;
background = 0;
inBand = 1;
for ii = 1:numel(maskBaseSceneMaterialSet)
    reflectance = GetSingleBandReflectance(wls, wlsOffset+ii, background, inBand);
    singleBandMatte = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        reflectance, ...
        {'spectrum'});
    maskBaseSceneMaterialSet{ii} = singleBandMatte;
    materialsByIndex{ii} = singleBandMatte;
end

% write out mappings for base scene materials
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, baseSceneMaterials, [], 'Generic scene');
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.materialIds, maskBaseSceneMaterialSet, [], 'Generic mask');

%% Set up the "flash" light for making object pixel masks.
% use a uniform spectrum for the "flash"
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
flashLightId = ['camera-flash-' flashMetadata.lightIds{1}];
AppendLightMappings(mappingsFile, mappingsFile, ...
    {flashLightId}, {whiteArea}, 'Generic mask');

% use a uniform reflectance for the "flash"
whiteMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
flashMaterialId = ['camera-flash-' flashMetadata.materialIds{1}];
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    {flashMaterialId}, {whiteMatte}, [], 'Generic mask');

%% Set up inserted objects.
% single-band reflectances starting after the base scene reflectances
sceneOffset = numel(maskBaseSceneMaterialSet);

% basic conditions file columns
allNames = {'imageName', 'groupName', 'camera-flash'};
allValues = {...
    'mask', 'mask', flashMetadata.relativePath; ...
    'scene', 'scene', 'none'};

nInserted = numel(insertedObjects);
for oo = 1:nInserted
    % get each object model
    modelName = insertedObjects{oo};
    objectMetadata = ReadMetadata(modelName);
    
    % identify each inserted object with a single-band reflectance
    reflectance = GetSingleBandReflectance(wls, wlsOffset+sceneOffset+oo, background, inBand);
    singleBandMatte = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        reflectance, ...
        {'spectrum'});
    maskObjectMaterialSet = cell(1, numel(objectMetadata.materialIds));
    [maskObjectMaterialSet{:}] = deal(singleBandMatte);
    materialsByIndex{sceneOffset+oo} = singleBandMatte;
    
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
    @(recipe)MakeVirtualSceneObjectMasks(recipe, pixelThreshold, toneMapFactor, isScale, sceneName)};

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% record which single-band reflectances correspond to which scene materials
recipe.processing.materialsByIndex = materialsByIndex;
