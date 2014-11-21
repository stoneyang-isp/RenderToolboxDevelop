%% Import a material from a Collada source document to a destination document
%   sourceIdMap for a Collada source document, as from ReadSceneDOM
%   destinationIdMap for a Collada destination document
%   materialId for the material to import
%   idPrefix to use for the imported element in the destination
%   nodeId for previously transferred scene node
%   geometryId for previously transferred geometry node
function newId = TransferMaterial(sourceIdMap, destinationIdMap, materialId, idPrefix, nodeId, geometryId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryMaterialsPath = 'document:COLLADA:library_materials';
libraryMaterials = SearchScene(destinationIdMap, libraryMaterialsPath);

% copy material to destination and rename it
newId = [idPrefix '-' materialId];
if ~destinationIdMap.isKey(newId)
    materialClone = docNode.importNode(sourceIdMap(materialId), true);
    libraryMaterials.appendChild(materialClone);
    destinationIdMap(newId) = materialClone;
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);

namePath = [newId '.name'];
materialName = GetSceneValue(destinationIdMap, namePath);
newMaterialName = [idPrefix '-' materialName];
SetSceneValue(destinationIdMap, namePath, newMaterialName, true);

% patch up multiple references to the material
refPath = [nodeId ':instance_geometry:bind_material:technique_common:instance_material.symbol'];
SetSceneValue(destinationIdMap, refPath, newId, true);
refPath = [nodeId ':instance_geometry:bind_material:technique_common:instance_material.target'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
refPath = [geometryId ':mesh:polylist.material'];
SetSceneValue(destinationIdMap, refPath, newId, true);
