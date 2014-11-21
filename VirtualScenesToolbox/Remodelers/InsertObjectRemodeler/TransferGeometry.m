%% Import geometry from a Collada source document to a destination document
%   sourceIdMap for a Collada source document, as from ReadSceneDOM
%   destinationIdMap for a Collada destination document
%   geometryId for the geometry to import
%   idPrefix to use for the imported element in the destination
%   nodeId for previously transferred scene node
function newId = TransferGeometry(sourceIdMap, destinationIdMap, geometryId, idPrefix, nodeId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryGeometriesPath = 'document:COLLADA:library_geometries';
libraryGeometries = SearchScene(destinationIdMap, libraryGeometriesPath);

% copy geometry to destination and rename it
newId = [idPrefix '-' geometryId];
if ~destinationIdMap.isKey(newId)
    geometryClone = docNode.importNode(sourceIdMap(geometryId), true);
    libraryGeometries.appendChild(geometryClone);
    destinationIdMap(newId) = geometryClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
refPath = [nodeId ':instance_geometry.url'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
