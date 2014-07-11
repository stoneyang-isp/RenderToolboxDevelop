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
objectFileNames = varValues(isObjectFile);
for ii = 1:nObjects
    [objectDocNode, objectIdMap] = ReadSceneDOM(objectFileNames{ii});
    
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
        
        % copy the whole top-level node
        nodeClone = docNode.importNode(element, true);
        visualScene.appendChild(nodeClone);
        
        % copy the whole geometry
        geometryClone = docNode.importNode(objectIdMap(geometryId), true);
        libraryGeometries.appendChild(geometryClone);
        
        % copy each whole material
        materialsPath = [nodeId ':instance_geometry:bind_material:technique_common'];
        materialsElement = SearchScene(objectIdMap, materialsPath);
        children = GetElementChildren(materialsElement, 'instance_material');
        for kk = 1:numel(children)
            materialAttribute = GetElementAttributes(children{kk}, 'target');
            materialId = char(materialAttribute.getTextContent());
            materialId = materialId(materialId ~= '#');
            if (idMap.isKey(materialId))
                continue;
            end
            materialClone = docNode.importNode(objectIdMap(materialId), true);
            libraryMaterials.appendChild(materialClone);
            idMap(materialId) = materialClone;
            
            % shallow copy each effect
            effectPath = [materialId ':instance_effect.url'];
            effectId = GetSceneValue(objectIdMap, effectPath);
            if (isempty(effectId))
                continue;
            end
            effectId = effectId(effectId ~= '#');
            if (idMap.isKey(effectId))
                continue;
            end
            effectClone = docNode.importNode(objectIdMap(effectId), false);
            libraryEffects.appendChild(effectClone);
            idMap(effectId) = effectClone;
            
            % fill in a basic Lambertian (matte) effect
            profile = CreateElementChild(effectClone, 'profile_COMMON');
            technique = CreateElementChild(profile, 'technique');
            technique.setAttribute('sid', 'common');
            lambert = CreateElementChild(technique, 'lambert');
            diffuse = CreateElementChild(lambert, 'diffuse');
            colorElement = CreateElementChild(diffuse, 'color');
            colorElement.setAttribute('sid', 'diffuse');
            colorElement.setTextContent('1 0 0');
        end
    end
end
