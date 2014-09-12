%% Move the given node to a new position.
%   objectIdMap for a Collada file, as from ReadSceneDOM
%   nodeId for one of the Collada <node> elements
%   position for the node: [xyz], or the id of another node to move to
function RepositionNode(objectIdMap, nodeId, position)

if isnumeric(position) || ~objectIdMap.isKey(position)
    % just increment translation with the given position
    translatePath = [nodeId ':translate|sid=location'];
    SetSceneValue(objectIdMap, translatePath, position, true, '+=');
    return
end

% get all the transformations from another node
translatePath = [position ':translate|sid=location'];
rotateXPath = [position ':rotate|sid=rotationX'];
rotateYPath = [position ':rotate|sid=rotationY'];
rotateZPath = [position ':rotate|sid=rotationZ'];
scalePath = [position ':scale|sid=scale'];

translate = GetSceneValue(objectIdMap, translatePath);
rotateX = GetSceneValue(objectIdMap, rotateXPath);
rotateY = GetSceneValue(objectIdMap, rotateYPath);
rotateZ = GetSceneValue(objectIdMap, rotateZPath);
scale = GetSceneValue(objectIdMap, scalePath);

% set all the transformations on the target node
translatePath = [nodeId ':translate|sid=location'];
rotateXPath = [nodeId ':rotate|sid=rotationX'];
rotateYPath = [nodeId ':rotate|sid=rotationY'];
rotateZPath = [nodeId ':rotate|sid=rotationZ'];
scalePath = [nodeId ':scale|sid=scale'];

SetSceneValue(objectIdMap, translatePath, translate, true);
SetSceneValue(objectIdMap, rotateXPath, rotateX, true);
SetSceneValue(objectIdMap, rotateYPath, rotateY, true);
SetSceneValue(objectIdMap, rotateZPath, rotateZ, true);
SetSceneValue(objectIdMap, scalePath, scale, true);
