%% Move the given node to a new position.
%   objectIdMap for a Collada file, as from ReadSceneDOM
%   nodeId for one of the Collada <node> elements
%   position for the node: [x y z], or the id of another node to mimic
%   rotation for the node: [ax ay az], or the id of another node to mimic
%   scale for the node: [x y z], or the id of another node to mimic

function RepositionNode(objectIdMap, nodeId, position, rotation, scale)

if isnumeric(position) || ~objectIdMap.isKey(position)
    %% Apply given transformations.
    
    % increment position
    translatePath = [nodeId ':translate|sid=location'];
    SetSceneValue(objectIdMap, translatePath, position, true, '+=');
    
    % set absolute rotation
    rotation = StringToVector(rotation);
    aX = VectorToString([1 0 0 rotation(1)]);
    aY = VectorToString([0 1 0 rotation(2)]);
    aZ = VectorToString([0 0 1 rotation(3)]);
    rotatePath = [nodeId ':rotate|sid=rotationX'];
    SetSceneValue(objectIdMap, rotatePath, aX, true, '=');
    rotatePath = [nodeId ':rotate|sid=rotationY'];
    SetSceneValue(objectIdMap, rotatePath, aY, true, '=');
    rotatePath = [nodeId ':rotate|sid=rotationZ'];
    SetSceneValue(objectIdMap, rotatePath, aZ, true, '=');
    
    % set absolute scale
    scalePath = [nodeId ':scale|sid=scale'];
    SetSceneValue(objectIdMap, scalePath, scale, true, '=');
    return
end

% get all the transformations from another node
translatePath = [position ':translate|sid=location'];
rotatePath = [position ':rotate|sid=rotationX'];
rotateYPath = [position ':rotate|sid=rotationY'];
rotateZPath = [position ':rotate|sid=rotationZ'];
scalePath = [position ':scale|sid=scale'];

translate = GetSceneValue(objectIdMap, translatePath);
rotateX = GetSceneValue(objectIdMap, rotatePath);
rotateY = GetSceneValue(objectIdMap, rotateYPath);
rotateZ = GetSceneValue(objectIdMap, rotateZPath);
scale = GetSceneValue(objectIdMap, scalePath);

% set all the transformations on the target node
translatePath = [nodeId ':translate|sid=location'];
rotatePath = [nodeId ':rotate|sid=rotationX'];
rotateYPath = [nodeId ':rotate|sid=rotationY'];
rotateZPath = [nodeId ':rotate|sid=rotationZ'];
scalePath = [nodeId ':scale|sid=scale'];

SetSceneValue(objectIdMap, translatePath, translate, true);
SetSceneValue(objectIdMap, rotatePath, rotateX, true);
SetSceneValue(objectIdMap, rotateYPath, rotateY, true);
SetSceneValue(objectIdMap, rotateZPath, rotateZ, true);
SetSceneValue(objectIdMap, scalePath, scale, true);
