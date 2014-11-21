%% Scan for the ids of elements in the given Collada file.
%   colladaFile Collada parent scene .dae or .xml file
%   materialPattern expression to match material names, like '\w+-material$'
function ids = GetSceneMaterialIds(colladaFile, idPattern)

if nargin < 2 || isempty(idPattern)
    idPattern = '\w+-material$';
end

[docNode, idMap] = ReadSceneDOM(colladaFile);
allIds = idMap.keys();
nIds = numel(allIds);
isMaterial = false(1, numel(nIds));
for ii = 1:nIds
    isMaterial(ii) = ~isempty(regexp(allIds{ii}, idPattern));
end
ids = allIds(isMaterial);
