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
function docNode = RTB_BeforeCondition_SampleRemodeler(docNode, mappings, varNames, varValues, conditionNumber, hints)

% find object files
numVars = numel(varNames);
isObjectFile = false(1, numVars);
for ii = 1:numel(varNames)
    isObjectFile(ii) = ~isempty(strfind(varNames{ii}, 'object'));
end

nObjects = sum(isObjectFile);
if (0 == nObjects)
    return;
end

% find object positions
isPosition = false(1, numVars);
for ii = 1:numel(varNames)
    isPosition(ii) = ~isempty(strfind(varNames{ii}, 'position'));
end

nPositions = sum(isPosition);
if (nPositions ~= nObjects)
    return;
end

% get the parent elements to receive inserted element from object document
idMap = GenerateSceneIDMap(docNode);
visualScenePath = 'document:COLLADA:library_visual_scenes:visual_scene';
visualScene = SearchScene(idMap, visualScenePath);
libraryGeometriesPath = 'document:COLLADA:library_geometries';
libraryGeometries = SearchScene(idMap, libraryGeometriesPath);
libraryMaterialsPath = 'document:COLLADA:library_materials';
libraryMaterials = SearchScene(idMap, libraryMaterialsPath);
libraryEffectsPath = 'document:COLLADA:library_effects';
libraryEffects = SearchScene(idMap, libraryEffectsPath);

% read object files
objectNames = varNames(isObjectFile);
objectFileNames = varValues(isObjectFile);
objectPositions = varValues(isPosition);
for ii = 1:nObjects
    objectName = objectNames{ii};
    objectFullPath = GetVirtualScenesPath(objectFileNames{ii});
    [objectDocNode, objectIdMap] = ReadSceneDOM(objectFullPath);
    objectPosition = objectPositions{ii};
    
    % find new geometries to copy into the document
    objectIds = objectIdMap.keys();
    for jj = 1:numel(objectIds)
        nodeId = objectIds{jj};
        element = objectIdMap(nodeId);
        
        % is this a top-level node?
        elementName = char(element.getNodeName);
        if ~strcmp(elementName, 'node')
            continue;
        end
        
        % is this a geometry node?
        geometryPath = [nodeId ':instance_geometry.url'];
        geometryId = GetSceneValue(objectIdMap, geometryPath);
        if isempty(geometryId)
            continue;
        end
        geometryId = geometryId(geometryId ~= '#');
        
        % does the geometry's polylist have enough stuff in it?
        polylistPath = [geometryId ':mesh:polylist.count'];
        polylistCount = GetSceneValue(objectIdMap, polylistPath);
        if isempty(polylistCount) || StringToVector(polylistCount) < 10
            continue;
        end
        
        % increment the object translation by the given position
        translatePath = [nodeId ':translate|sid=location'];
        SetSceneValue(objectIdMap, translatePath, objectPosition, true, '+=');
        
        % find node materials
        materialsPath = [nodeId ':instance_geometry:bind_material:technique_common'];
        materialsElement = SearchScene(objectIdMap, materialsPath);
        materialReferences = GetElementChildren(materialsElement, 'instance_material');
        if isempty(materialReferences)
            continue;
        end
        
        % take one material per node
        firstMaterial = materialReferences{1};
        materialAttribute = GetElementAttributes(firstMaterial, 'target');
        materialId = char(materialAttribute.getTextContent());
        materialId = materialId(materialId ~= '#');
        
        % shallow copy the material's effect
        effectPath = [materialId ':instance_effect.url'];
        effectId = GetSceneValue(objectIdMap, effectPath);
        if (isempty(effectId))
            continue;
        end
        effectId = effectId(effectId ~= '#');
        
        % copy node to working document and rename it
        newNodeId = [objectName '-' nodeId];
        if ~idMap.isKey(newNodeId)
            nodeClone = docNode.importNode(element, true);
            visualScene.appendChild(nodeClone);
            idMap(newNodeId) = nodeClone;
        end
        idPath = [newNodeId '.id'];
        SetSceneValue(idMap, idPath, newNodeId, true);
        
        % copy geometry to working document
        newGeometryId = [objectName '-' geometryId];
        if ~idMap.isKey(newGeometryId)
            geometryClone = docNode.importNode(objectIdMap(geometryId), true);
            libraryGeometries.appendChild(geometryClone);
            idMap(newGeometryId) = geometryClone;
        end
        idPath = [newGeometryId '.id'];
        SetSceneValue(idMap, idPath, newGeometryId, true);
        refPath = [newNodeId ':instance_geometry.url'];
        SetSceneValue(idMap, refPath, ['#' newGeometryId], true);
        
        % copy material to working document and rename
        newMaterialId = [objectName '-' materialId];
        if ~idMap.isKey(newMaterialId)
            materialClone = docNode.importNode(objectIdMap(materialId), true);
            libraryMaterials.appendChild(materialClone);
            idMap(newMaterialId) = materialClone;
        end
        idPath = [newMaterialId '.id'];
        SetSceneValue(idMap, idPath, newMaterialId, true);
        namePath = [newMaterialId '.name'];
        materialName = GetSceneValue(idMap, namePath);
        newMaterialName = [objectName '-' materialName];
        SetSceneValue(idMap, namePath, newMaterialName, true);
        refPath = [newNodeId ':instance_geometry:bind_material:technique_common:instance_material.symbol'];
        SetSceneValue(idMap, refPath, newMaterialId, true);
        refPath = [newNodeId ':instance_geometry:bind_material:technique_common:instance_material.target'];
        SetSceneValue(idMap, refPath, ['#' newMaterialId], true);
        refPath = [newGeometryId ':mesh:polylist.material'];
        SetSceneValue(idMap, refPath, newMaterialId, true);
        
        
        % copy effect to working document
        % fill in a basic Lambertian/matte effect
        % rename it
        newEffectlId = [objectName '-' effectId];
        if ~idMap.isKey(newEffectlId)
            effectClone = docNode.importNode(objectIdMap(effectId), false);
            libraryEffects.appendChild(effectClone);
            idMap(newEffectlId) = effectClone;
            
            % fill in a basic Lambertian/matte effect
            profile = CreateElementChild(effectClone, 'profile_COMMON');
            technique = CreateElementChild(profile, 'technique');
            technique.setAttribute('sid', 'common');
            lambert = CreateElementChild(technique, 'lambert');
            diffuse = CreateElementChild(lambert, 'diffuse');
            colorElement = CreateElementChild(diffuse, 'color');
            colorElement.setAttribute('sid', 'diffuse');
            colorElement.setTextContent('1 0 0');
        end
        idPath = [newEffectlId '.id'];
        SetSceneValue(idMap, idPath, newEffectlId, true);
        refPath = [newMaterialId ':instance_effect.url'];
        SetSceneValue(idMap, refPath, ['#' newEffectlId], true);
        
    end
end
