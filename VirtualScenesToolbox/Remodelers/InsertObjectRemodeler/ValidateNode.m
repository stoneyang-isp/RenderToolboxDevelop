%% Should we insert the given node element from a Collada file?
%   objectIdMap for a Collada file, as from ReadSceneDOM
%   nodeId for one of the Collada <node> elements
function [shouldInsert, geometryId] = ValidateNode(objectIdMap, nodeId)

% is this a valid id?
if ~objectIdMap.isKey(nodeId)
    shouldInsert = false;
    geometryId = [];
    return;
end

% is this a top-level node?
element = objectIdMap(nodeId);
elementName = char(element.getNodeName);
if ~strcmp(elementName, 'node')
    shouldInsert = false;
    geometryId = [];
    return;
end

% is this a geometry node?
geometryPath = [nodeId ':instance_geometry.url'];
geometryId = GetSceneValue(objectIdMap, geometryPath);
if isempty(geometryId)
    shouldInsert = false;
    geometryId = [];
    return;
end
geometryId = geometryId(geometryId ~= '#');

% does the geometry's polylist have enough stuff in it?
polylistPath = [geometryId ':mesh:polylist.count'];
polylistCount = GetSceneValue(objectIdMap, polylistPath);
if isempty(polylistCount) || StringToVector(polylistCount) < 10
    shouldInsert = false;
    return;
end

% this node checks out
shouldInsert = true;