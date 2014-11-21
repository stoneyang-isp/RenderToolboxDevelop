%% Choose sets of materials, lights, etc. for an instance of Ward Land.
%   baseSceneName name of a BaseScene
%   objectNames cell arrray of Objects to insert
%   nInsertedObjects number of Objects to choose for insertion
%   lightNames cell arrray of Lights to insert
%   nInsertedLights number of Lights to choose for insertion
%   scaleMin, scaleMax range of random object scaling
%   rotMin, rotMax range of random object and light rotations
%   matteMaterials cell array of matte material descriptions
%   wardMaterials cell array of Ward model material descriptions
%   lightSpectra cell array of lighting spectra
function choices = GetWardLandChoices(baseSceneName, ...
    objectNames, nInsertedObjects, lightNames, nInsertedLights, ...
    scaleMin, scaleMax, rotMin, rotMax, ...
    matteMaterials, wardMaterials, lightingSpectra)

choices.baseSceneName = baseSceneName;

% choose materials for the base scene
baseSceneMetadata = ReadMetadata(baseSceneName);
nMaterials = numel(baseSceneMetadata.materialIds);
whichMaterials = randi(numel(matteMaterials), [1, nMaterials]);
choices.baseSceneMatteMaterials = matteMaterials(whichMaterials);
choices.baseSceneWardMaterials = wardMaterials(whichMaterials);

% choose lights for the base scene
nLights = numel(baseSceneMetadata.lightIds);
choices.baseSceneLights = ...
    lightingSpectra(randi(numel(lightingSpectra), [1, nLights]));

% choose which objects to insert
innerBox = [0 0; 0 0; 0 0];
outerBox = baseSceneMetadata.objectBox;
choices.insertedObjects = pickObjects(objectNames, nInsertedObjects, ...
    innerBox, outerBox, scaleMin, scaleMax, rotMin, rotMax);

% choose a set of materials for each inserted object
choices.insertedObjects = pickObjectMaterials(choices.insertedObjects, ...
    matteMaterials, wardMaterials);

% choose which lights to insert
innerBox = baseSceneMetadata.lightExcludeBox;
outerBox = baseSceneMetadata.lightBox;
choices.insertedLights = pickObjects(lightNames, nInsertedLights, ...
    innerBox, outerBox, 1, 1, rotMin, rotMax);

% choose a set of materials for each inserted light
choices.insertedLights = pickObjectMaterials(choices.insertedLights, ...
    matteMaterials, wardMaterials);

% pick the spectrum for each inserted light
choices.insertedLights.lightSpectra = ...
    lightingSpectra(randi(numel(lightingSpectra), [1 nInsertedLights]));

%% Pick from given objects and assign position, rotation, scale.
function picks = pickObjects(names, nInserted, innerBox, outerBox, ...
    scaleMin, scaleMax, rotMin, rotMax)

if isempty(names) || 0 == nInserted
    picks.names = {};
    return;
end

picks.names = names(randi(numel(names), [1, nInserted]));
picks.positions = cell(1, nInserted);
picks.rotations = cell(1, nInserted);
picks.scales = cell(1, nInserted);
for oo = 1:nInserted
    % random position between inner and outer bounding volume
    picks.positions{oo} = GetRandomPosition(innerBox, outerBox);
    
    % random rotation between min and max
    picks.rotations{oo} = round(rotMin + (rotMin - rotMax) * rand(1,3));
    
    % random scaling between min and max
    picks.scales{oo} = scaleMin + (scaleMax - scaleMin) * rand(1,3);
end

%% Pick from given matte and ward materials.
function picks = pickObjectMaterials(picks, matteMaterials, wardMaterials)

if isempty(picks)
    return;
end

nObjects = numel(picks.names);
for oo = 1:nObjects
    objectMetadata = ReadMetadata(picks.names{oo});
    nMaterials = numel(objectMetadata.materialIds);
    whichMaterials = randi(numel(matteMaterials), [1 nMaterials]);
    picks.matteMaterialSets{oo} = matteMaterials(whichMaterials);
    picks.wardMaterialSets{oo} = wardMaterials(whichMaterials);
end
