%% Import an effect from a Collada source document and make it Matte
%   sourceIdMap for a Collada source document, as from ReadSceneDOM
%   destinationIdMap for a Collada destination document
%   effectId for the effect to import
%   idPrefix to use for the imported element in the destination
%   materialId for previously transferred material
function newId = TransferEffectAsMatte(sourceIdMap, destinationIdMap, effectId, idPrefix, materialId)

% document and element that will reveice the geometry
docNode = destinationIdMap('document');
libraryEffectsPath = 'document:COLLADA:library_effects';
libraryEffects = SearchScene(destinationIdMap, libraryEffectsPath);

% copy effect to destination and rename it
newId = [idPrefix '-' effectId];
if ~destinationIdMap.isKey(newId)
    effectClone = docNode.importNode(sourceIdMap(effectId), false);
    libraryEffects.appendChild(effectClone);
    destinationIdMap(newId) = effectClone;
    
    % make it a basic Lambertian/matte effect
    profile = CreateElementChild(effectClone, 'profile_COMMON');
    technique = CreateElementChild(profile, 'technique');
    technique.setAttribute('sid', 'common');
    lambert = CreateElementChild(technique, 'lambert');
    diffuse = CreateElementChild(lambert, 'diffuse');
    colorElement = CreateElementChild(diffuse, 'color');
    colorElement.setAttribute('sid', 'diffuse');
    colorElement.setTextContent('1 0 0');
end
idPath = [newId '.id'];
SetSceneValue(destinationIdMap, idPath, newId, true);
refPath = [materialId ':instance_effect.url'];
SetSceneValue(destinationIdMap, refPath, ['#' newId], true);
