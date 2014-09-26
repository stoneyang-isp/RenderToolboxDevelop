%% Scan for the ids of materials in the given Collada file.
%   colladaFile Collada parent scene .dae or .xml file
%   materialPattern expression to match material names, like '\w+-material$'
function materialIds = GetSceneMaterialIds(colladaFile, materialPattern)

if nargin < 2 || isempty(materialPattern)
    materialPattern = '\w+-material$';
end

[docNode, idMap] = ReadSceneDOM(colladaFile);
allIds = idMap.keys();
nIds = numel(allIds);
isMaterial = false(1, numel(nIds));
for ii = 1:nIds
    isMaterial(ii) = ~isempty(regexp(allIds{ii}, materialPattern));
end
materialIds = allIds(isMaterial);
