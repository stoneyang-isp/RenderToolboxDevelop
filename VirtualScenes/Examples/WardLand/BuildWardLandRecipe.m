%% Build a recipe for a virutal scene.
%   defaultMappings should be 'DefaultMappings.txt', etc.
%   choices should be struct from GetWardLandChoices()
%   hints should be struct of RenderToolbox3 options
function recipe = BuildWardLandRecipe(defaultMappings, choices, hints)

if nargin < 3
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

%% Augment batch renderer options.
hints.remodeler = 'InsertObjectRemodeler';
ChangeToWorkingFolder(hints);
mappingsFile = [hints.recipeName '-Mappings.txt'];
conditionsFile = [hints.recipeName '-Conditions.txt'];
sceneMetadata = ReadMetadata(choices.baseSceneName);
parentSceneFile = GetVirtualScenesPath(sceneMetadata.relativePath);

%% Set up renderer config.
congigRenderer = hints.renderer;
configIntegratorId = 'integrator';
configSamplerId = 'Camera-camera_sampler';
configIds = {configIntegratorId, configSamplerId};

fullIntegrator = BuildDesription('integrator', 'path', ...
    {'maxDepth'}, ...
    {'10'}, ...
    {'integer'});
fullSampler = BuildDesription('sampler', 'ldsampler', ...
    {'sampleCount'}, ...
    {'128'}, ...
    {'integer'});
fullConfig = {fullIntegrator, fullSampler};

quickIntegrator = BuildDesription('integrator', 'direct', ...
    {'shadingSamples'}, ...
    {'32'}, ...
    {'integer'});
quickSampler = BuildDesription('sampler', 'ldsampler', ...
    {'sampleCount'}, ...
    {'32'}, ...
    {'integer'});
quickConfig = {quickIntegrator, quickSampler};

%% Set up the base scene lights.
% set base scene lights turn off base scene lights when making pixel masks
blackArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:0 800:0'}, ...
    {'spectrum'});
maskBaseSceneLightSet = cell(1, numel(sceneMetadata.lightIds));
[maskBaseSceneLightSet{:}] = deal(blackArea);

%% Set up the "flash" light for making object pixel masks.
% use a uniform spectrum for the "flash"
flashMetadata = ReadMetadata('CameraFlash');
whiteArea = BuildDesription('light', 'area', ...
    {'intensity'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
flashLightId = ['camera-flash-' flashMetadata.lightIds{1}];

% use a uniform reflectance for the "flash"
whiteMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:1 800:1'}, ...
    {'spectrum'});
flashMaterialId = ['camera-flash-' flashMetadata.materialIds{1}];

%% Set up materials for the full "matte" and "ward" renderings.

% build a grand list of material ids, matte, and ward materials
%   inserted object material ids get prefixed with the object name
allMaterialIds = sceneMetadata.materialIds;
allSceneMatteMaterials = choices.baseSceneMatteMaterials;
allSceneWardMaterials = choices.baseSceneWardMaterials;
nInserted = numel(choices.insertedObjects.names);
for oo = 1:nInserted
    idPrefix = sprintf('object-%d-', oo);
    objectMetadata = ReadMetadata(choices.insertedObjects.names{oo});
    nObjectMaterials = numel(objectMetadata.materialIds);
    objectMaterialIds = cell(1, nObjectMaterials);
    for mm = 1:nObjectMaterials
        objectMaterialIds{mm} = [idPrefix objectMetadata.materialIds{mm}];
    end
    allMaterialIds = cat(2, allMaterialIds, objectMaterialIds);
    allSceneMatteMaterials = cat(2, allSceneMatteMaterials, ...
        choices.insertedObjects.matteMaterialSets{oo});
    allSceneWardMaterials = cat(2, allSceneWardMaterials, ...
        choices.insertedObjects.wardMaterialSets{oo});
end

%% Set up materials for the "boring" rendering.
boringMatte = BuildDesription('material', 'matte', ...
    {'diffuseReflectance'}, ...
    {'300:0.5 800:0.5'}, ...
    {'spectrum'});
allSceneBoringMaterials = cell(size(allSceneWardMaterials));
[allSceneBoringMaterials{:}] = deal(boringMatte);

%% Set up materials for the "mask" renderings.
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

%% Write out config, materials, and lights to a big mappings file.

% full "ward" rendering
AppendMappings(defaultMappings, mappingsFile, ...
    configIds, fullConfig, [congigRenderer ' ward'], 'config');
AppendMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, choices.baseSceneLights, 'Generic ward', 'lights');
AppendMappings(mappingsFile, mappingsFile, ...
    allMaterialIds, allSceneWardMaterials, 'Generic ward', 'materials');

% full "matte" rendering
AppendMappings(mappingsFile, mappingsFile, ...
    configIds, fullConfig, [congigRenderer ' matte'], 'config');
AppendMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, choices.baseSceneLights, 'Generic matte', 'lights');
AppendMappings(mappingsFile, mappingsFile, ...
    allMaterialIds, allSceneMatteMaterials, 'Generic matte', 'materials');

% analysis "boring" rendering
AppendMappings(mappingsFile, mappingsFile, ...
    configIds, fullConfig, [congigRenderer ' boring'], 'config');
AppendMappings(mappingsFile, mappingsFile, ...
    sceneMetadata.lightIds, choices.baseSceneLights, 'Generic boring', 'lights');
AppendMappings(mappingsFile, mappingsFile, ...
    allMaterialIds, allSceneBoringMaterials, 'Generic boring', 'materials');

% analysis "mask" renderings
maskNames = cell(1, nPages);
for ii = 1:nPages
    maskNames{ii} = sprintf('mask-%d', ii);
    blockName = ['Generic ' maskNames{ii}];
    
    % config
    AppendMappings(mappingsFile, mappingsFile, ...
        configIds, quickConfig, [congigRenderer ' ' maskNames{ii}], 'config');
    
    % the scene itself
    AppendMappings(mappingsFile, mappingsFile, ...
        allMaterialIds, allMaskMaterialPages(ii,:), blockName, 'lights');
    AppendMappings(mappingsFile, mappingsFile, ...
        sceneMetadata.lightIds, maskBaseSceneLightSet, blockName, 'materials');
    
    % the special "flash" light
    AppendMappings(mappingsFile, mappingsFile, ...
        {flashLightId}, {whiteArea}, blockName, 'flash light');
    AppendMappings(mappingsFile, mappingsFile, ...
        {flashMaterialId}, {whiteMatte}, blockName, 'flash material');
end


%% Write conditions for inserted objects.

% basic conditions file columns
allNames = {'imageName', 'groupName', 'camera-flash'};
sceneValues = { ...
    'matte', 'matte', 'none'; ...
    'ward', 'ward', 'none'; ...
    'boring', 'boring', 'none'};
flashValues = repmat({flashMetadata.relativePath}, nPages, 1);
maskValues = cat(2, maskNames', maskNames', flashValues);
allValues = cat(1, sceneValues, maskValues);

% append columns for each inserted object
nInserted = numel(choices.insertedObjects.names);
for oo = 1:nInserted
    objectMetadata = ReadMetadata(choices.insertedObjects.names{oo});
    objectColumn = sprintf('object-%d', oo);
    positionColumn = sprintf('position-%d', oo);
    rotationColumn = sprintf('rotation-%d', oo);
    scaleColumn = sprintf('scale-%d', oo);
    
    varNames = {objectColumn, positionColumn, rotationColumn, scaleColumn};
    allNames = cat(2, allNames, varNames);
    
    varValues = {objectMetadata.relativePath, ...
        choices.insertedObjects.positions{oo}, ...
        choices.insertedObjects.rotations{oo}, ...
        choices.insertedObjects.scales{oo}};
    allValues = cat(2, allValues, repmat(varValues, nPages+3, 1));
end

% write out the conditions file
WriteConditionsFile(conditionsFile, allNames, allValues);

%% Pack it all up in a recipe.
prefName = 'VirtualScenes';
toneMapFactor = getpref(prefName, 'toneMapFactor');
isScale = getpref(prefName, 'toneMapScale');
pixelThreshold = getpref(prefName, 'pixelThreshold');
filterWidth = getpref(prefName, 'filterWidth');
lmsSensitivities = getpref(prefName, 'lmsSensitivities');
dklSensitivities = getpref(prefName, 'dklSensitivities');
montageScaleFactor = getpref(prefName, 'montageScaleFactor');
montageScaleMethod = getpref(prefName, 'montageScaleMethod');
executive = { ...
    @MakeRecipeSceneFiles, ...
    @MakeRecipeRenderings, ...
    @(recipe)MakeRecipeObjectMasks(recipe, pixelThreshold, toneMapFactor, isScale), ...
    @(recipe)MakeRecipeIlluminationImage(recipe, filterWidth, toneMapFactor, isScale), ...
    @(recipe)MakeRecipeBoringComparison(recipe, toneMapFactor, isScale), ...
    @(recipe)MakeRecipeLMSImages(recipe, lmsSensitivities), ...
    @(recipe)MakeRecipeDKLImages(recipe, lmsSensitivities, dklSensitivities), ...
    @(recipe)MakeRecipeImageMontage(recipe, montageScaleFactor, montageScaleMethod)};

recipe = NewRecipe([], executive, parentSceneFile, ...
    conditionsFile, mappingsFile, hints);

% remember how materials were assigned
recipe.processing.allMaterialIds = allMaterialIds;
recipe.processing.allSceneMatteMaterials = allSceneMatteMaterials;
recipe.processing.allSceneWardMaterials = allSceneWardMaterials;
recipe.processing.allSceneBoringMaterials = allSceneBoringMaterials;
recipe.processing.allMaskMaterials = allMaskMaterials;
recipe.processing.allMaskMaterialPages = allMaskMaterialPages;