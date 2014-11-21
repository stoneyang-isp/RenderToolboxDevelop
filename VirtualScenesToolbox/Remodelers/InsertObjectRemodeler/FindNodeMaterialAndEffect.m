%% Look for the material and effect references from a Collada node
%   objectIdMap for a Collada file, as from ReadSceneDOM
%   nodeId for one of the Collada <node> elements
function [materialId, effectId] = FindNodeMaterialAndEffect(objectIdMap, nodeId)

% find node materials
materialsPath = [nodeId ':instance_geometry:bind_material:technique_common'];
materialsElement = SearchScene(objectIdMap, materialsPath);
materialReferences = GetElementChildren(materialsElement, 'instance_material');
if isempty(materialReferences)
    materialId = [];
    effectId = [];
    return;
end

% take the first material found
firstMaterial = materialReferences{1};
materialAttribute = GetElementAttributes(firstMaterial, 'target');
materialId = char(materialAttribute.getTextContent());
materialId = materialId(materialId ~= '#');

% get the effect referenced by the material
effectPath = [materialId ':instance_effect.url'];
effectId = GetSceneValue(objectIdMap, effectPath);
if (isempty(effectId))
    materialId = [];
    effectId = [];
    return;
end
effectId = effectId(effectId ~= '#');
