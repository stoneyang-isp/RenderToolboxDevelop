%% Import a scene node a Collada source document to a destination document
%   sourceIdMap for a Collada source document, as from ReadSceneDOM
%   destinationIdMap for a Collada destination document
%   nodeId for the scene node element to import
%   idPrefix to use for the imported node in the destination
function newId = TransferSceneNode(sourceIdMap, destinationIdMap, nodeId, idPrefix)

% document and element that will reveice the new scene node
docNode = destinationIdMap('document');
visualScenePath = 'document:COLLADA:library_visual_scenes:visual_scene';
visualScene = SearchScene(destinationIdMap, visualScenePath);

% copy scene node to destination and rename it
element = sourceIdMap(nodeId);
newId = [idPrefix '-' nodeId];
if ~destinationIdMap.isKey(newId)
    nodeClone = docNode.importNode(element, true);
    visualScene.appendChild(nodeClone);
    destinationIdMap(newId) = nodeClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
