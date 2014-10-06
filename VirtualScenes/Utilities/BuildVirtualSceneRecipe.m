%% Build a recipe for a virutal scene.
%   sceneName should be any name for this new recipe
%   hints should be batch renderer hints
%   defaultMappings should be 'DefaultMappings.txt', etc.
%   baseSceneModel should be 'IndoorPlant' etc.
%   baseSceneMatteMaterials should be {material1, material2, ...}
%   baseSceneWardMaterials should be {material1, material2, ...}
%   baseSceneLights should be {light1, light2, ...}
%   insertedObjects should be {'Barrel', 'Barrel', 'RingToy', ...}
%   objectPositions should be {[xyz], [xyz], [xyz], ...}
%   objectMatteMaterialSets should be {{m1, m2, ...}, {m1, m2, ...}, ...}
%   objectWardMaterialSets should be {{m1, m2, ...}, {m1, m2, ...}, ...}
function recipe = BuildVirtualSceneRecipe(sceneName, hints, defaultMappings, ...
    baseSceneModel, baseSceneMatteMaterials, baseSceneWardMaterials, ...
    baseSceneLights, ...
    insertedObjects, objectPositions, ...
    objectMatteMaterialSets, objectWardMaterialSets)

if nargin < 2
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Augment batch renderer options.
hints.remodeler = 'InsertObjectRemodeler';
ChangeToWorkingFolder(hints);
mappingsFile = [sceneName '-Mappings.txt'];
conditionsFile = [sceneName '-Conditions.txt'];

sceneMetadata = ReadMetadata(baseSceneModel);
parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);

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

%% Set up the "flash" light for making object pixel masks.
% use a uniform spectrum for the "flash"
flashMetadata = ReadMetadata('CameraFlash');
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

%% Write mappings for every object's material.

% build a grand list of material ids and scene materials
%   inserted object material ids get prefixed with the object name
allMaterialIds = sceneMetadata.materialIds;
allSceneMatteMaterials = baseSceneMatteMaterials;
allSceneWardMaterials = baseSceneWardMaterials;
nInserted = numel(insertedObjects);
for oo = 1:nInserted
    idPrefix = sprintf('object-%d-', oo);
    objectMetadata = ReadMetadata(insertedObjects{oo});
    nObjectMaterials = numel(objectMetadata.materialIds);
    objectMaterialIds = cell(1, nObjectMaterials);
    for mm = 1:nObjectMaterials
        objectMaterialIds{mm} = [idPrefix objectMetadata.materialIds{mm}];
    end
    allMaterialIds = cat(2, allMaterialIds, objectMaterialIds);
    allSceneMatteMaterials = cat(2, allSceneMatteMaterials, objectMatteMaterialSets{oo});
    allSceneWardMaterials = cat(2, allSceneWardMaterials, objectWardMaterialSets{oo});
end

% choose a reflectance band to use for each material in the mask conditions
nMaterials = numel(allSceneMatteMaterials);
nBands = 31;
allBands = 1 + mod((1:nMaterials)-1, nBands);

% choose single-band reflectances starting at 400nm
wls = 300:10:800;
wlsOffset = 10;
background = 0;
inBand = 1;
allMaskMaterials = cell(1, nMaterials);
for ii = 1:nMaterials
    reflectance = GetSingleBandReflectance(wls, wlsOffset+allBands(ii), background, inBand);
    singleBandMatte = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        reflectance, ...
        {'spectrum'});
    allMaskMaterials{ii} = singleBandMatte;
end

% split up materials to render them in spectrum-sized batches
%   use all-black placeholder to prevent double-listing materials
nPages = ceil(nMaterials / nBands);
allBandPages = zeros(nPages, nMaterials);
allMaskMaterialPages = cell(nPages, nMaterials);
blackMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    '300:0 800:0', ...
    {'spectrum'});
[allMaskMaterialPages{:}] = deal(blackMatte);
for ii = 1:nPages
    low = 1 + nBands*(ii-1);
    high = min(nBands + nBands*(ii-1), nMaterials);
    allBandPages(ii, low:high) = allBands(low:high);
    allMaskMaterialPages(ii, low:high) = allMaskMaterials(low:high);
end

% write out mappings with actual scene materials
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    allMaterialIds, allSceneMatteMaterials, [], 'Generic matte');
AppendMaterialMappings(mappingsFile, mappingsFile, ...
    allMaterialIds, allSceneWardMaterials, [], 'Generic ward');

% write out pages of mappings with mask condition materials
maskNames = cell(1, nPages);
for ii = 1:nPages
    maskNames{ii} = sprintf('mask-%d', ii);
    blockName = ['Generic ' maskNames{ii}];
    AppendMaterialMappings(mappingsFile, mappingsFile, ...
        allMaterialIds, allMaskMaterialPages(ii,:), [], blockName);
end

%% Write conditions for inserted objects.

% basic conditions file columns
allNames = {'imageName', 'groupName', 'camera-flash'};
sceneValues = { ...
    'matte', 'matte', 'none'; ...
    'ward', 'ward', 'none'};
flashValues = repmat({flashMetadata.relativePath}, nPages, 1);
maskValues = cat(2, maskNames', maskNames', flashValues);
allValues = cat(1, sceneValues, maskValues);

% append columns for each inserted object
nInserted = numel(insertedObjects);
for oo = 1:nInserted
    objectMetadata = ReadMetadata(insertedObjects{oo});
    objectColumn = sprintf('object-%d', oo);
    positionColumn = sprintf('position-%d', oo);
    objectModelPath = objectMetadata.relativePath;
    objectPosition = objectPositions{oo};
    
    varNames = {objectColumn, positionColumn};
    allNames = cat(2, allNames, varNames);
    
    varValues = {objectModelPath, objectPosition};
    allValues = cat(2, allValues, repmat(varValues, nPages+2, 1));
end

% write out the conditions file
WriteConditionsFile(conditionsFile, allNames, allValues);

%% Pack it all up in a recipe.
toneMapFactor = 100;
isScale = true;
pixelThreshold = 0.01;
filterWidth = 7;
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeObjectMasks(recipe, pixelThreshold, toneMapFactor, isScale, sceneName), ...
    @(recipe)MakeRecipeIlluminationImage(recipe, filterWidth, toneMapFactor, isScale, sceneName)};

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% remember how materials were assigned
recipe.processing.allMaterialIds = allMaterialIds;
recipe.processing.allSceneMaterials = allSceneMatteMaterials;
recipe.processing.allMaskMaterials = allMaskMaterials;
recipe.processing.allMaskMaterialPages = allMaskMaterialPages;
