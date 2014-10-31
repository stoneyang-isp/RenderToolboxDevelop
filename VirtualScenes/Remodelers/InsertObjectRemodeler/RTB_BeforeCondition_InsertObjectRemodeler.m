%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Modify a Collada document once per condition, before applying mappings.
%   @param docNode XML Collada document node Java object
%   @param mappings struct of mappings data from ParseMappings()
%   @param varNames cell array of conditions file variable names
%   @param varValues cell array of variable values for current condition
%   @param conditionNumber the number of the current condition
%   @param hints struct of RenderToolbox3 options
%
% @details
% Insert an object named in the conditions file into the current scene!
% The object must come from a collada file named in a column like
% "object1", "object2", etc.
%
% Usage:
%   docNode = RTB_BeforeCondition_SampleRemodeler(docNode, mappings, varNames, varValues, conditionNumber, hints)
%
% @ingroup RemodelerPlugins
function docNode = RTB_BeforeCondition_InsertObjectRemodeler(docNode, mappings, varNames, varValues, conditionNumber, hints)

%% Find object files.
numVars = numel(varNames);
isObject = false(1, numVars);
for ii = 1:numel(varNames)
    isObject(ii) = ~isempty(strfind(varNames{ii}, 'object'));
end

nObjects = sum(isObject);
if (0 == nObjects)
    return;
end

%% Find object positions.
isPosition = false(1, numVars);
for ii = 1:numel(varNames)
    isPosition(ii) = ~isempty(strfind(varNames{ii}, 'position'));
end

nPositions = sum(isPosition);
if (nPositions ~= nObjects)
    return;
end

%% Find object rotations.
isRotation = false(1, numVars);
for ii = 1:numel(varNames)
    isRotation(ii) = ~isempty(strfind(varNames{ii}, 'rotation'));
end

nRotations = sum(isRotation);
if (nRotations ~= nObjects)
    return;
end

%% Find object scale factors.
isScale = false(1, numVars);
for ii = 1:numel(varNames)
    isScale(ii) = ~isempty(strfind(varNames{ii}, 'scale'));
end

nScales = sum(isScale);
if (nScales ~= nObjects)
    return;
end

%% Find optional camera flash.
isFlash = false(1, numVars);
for ii = 1:numel(varNames)
    isFlash(ii) = ~isempty(strfind(varNames{ii}, 'flash'));
end

%% Choose object documents to insert and where to put them.
% start with regular inserted objects
objectNames = varNames(isObject);
objectFileNames = varValues(isObject);
objectPositions = varValues(isPosition);
objectRotations = varValues(isRotation);
objectScales = varValues(isScale);

% append special camera flash objects
objectNames = cat(2, objectNames, varNames(isFlash));
objectFileNames = cat(2, objectFileNames, varValues(isFlash));

% position camera flash objects at the scene camera
[flashPositions{1:sum(isFlash)}] = deal('Camera');
[flashRotations{1:sum(isFlash)}] = deal('Camera');
[flashScales{1:sum(isFlash)}] = deal('Camera');
objectPositions = cat(2, objectPositions, flashPositions);
objectRotations = cat(2, objectRotations, flashRotations);
objectScales = cat(2, objectScales, flashScales);

%% Transfer data from each object document to the scene document.
sceneIdMap = GenerateSceneIDMap(docNode);
for ii = 1:numel(objectNames)
    objectName = objectNames{ii};
    
    if strcmp(objectName, 'none')
        continue;
    end
    
    objectFullPath = GetVirtualScenesPath(objectFileNames{ii});
    [objectDocNode, objectIdMap] = ReadSceneDOM(objectFullPath);
    if isempty(objectDocNode) || isempty(objectIdMap)
        continue;
    end
    
    % try all node elements in the object document
    objectIds = objectIdMap.keys();
    for jj = 1:numel(objectIds)
        nodeId = objectIds{jj};
        
        % is this a good node to insert?
        [shouldInsert, geometryId] = ValidateNode(objectIdMap, nodeId);
        if ~shouldInsert
            continue;
        end
        
        % do we have a matrial and an effect for this node?
        [materialId, effectId] = FindNodeMaterialAndEffect(objectIdMap, nodeId);
        if isempty(materialId) || isempty(effectId)
            continue;
        end
        
        % transfer the node to the scene document
        newNodeId = TransferSceneNode( ...
            objectIdMap, sceneIdMap, nodeId, objectName);
        
        % transfer geometry to the scene document
        newGeometryId = TransferGeometry( ...
            objectIdMap, sceneIdMap, geometryId, objectName, newNodeId);
        
        % transfer material to the scene document
        newMaterialId = TransferMaterial( ...
            objectIdMap, sceneIdMap, materialId, objectName, newNodeId, newGeometryId);
        
        % transfer a matte effect to the scene document
        newEffectId = TransferEffectAsMatte( ...
            objectIdMap, sceneIdMap, effectId, objectName, newMaterialId);
        
        % move the node to a new position in the scene
        RepositionNode(sceneIdMap, newNodeId, ...
            objectPositions{ii}, objectRotations{ii}, objectScales{ii});
    end
end

