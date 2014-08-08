%% Write metadata for a base scene or object.
% metadata stored in BaseScenes/ or Objects/ subfolder
%   modelName should be "RingToy" for Objects/Models/RingToy.dae
%   boundingVolume should be [minX maxX; minY maxY; minZ, maxZ]
%   materialIds should be {'Floor-material', 'Material1-material', ...}
%   lightIds should be {'CeilingLight-mesh', 'WindowLight-mesh', ...}
function metadata = WriteMetadata(modelName, boundingVolume, materialIds, lightIds)
metadata = [];

% check the bounding volume
if nargin < 2 || ~isnumeric(boundingVolume) || ~isequal([3 2], size(boundingVolume))
    defaultVolume = '[-1 1; -1 1; -1 1]';
    warning('VirtualScenes:BadBoundingVolume', ...
        '\nUsing default bounding volume, %s', defaultVolume);
    boundingVolume = eval(defaultVolume);
end

% check for known material ids
if nargin < 3 || ~iscell(materialIds) || isempty(materialIds)
    warning('VirtualScenes:NoMaterialIds', ...
        '\nUsing default material Ids, %s', ...
        '{''Material01-material'', ..., ''Material10-material''}');
    materialIds = cell(1, 10);
    for ii = 1:numel(materialIds)
        materialIds{ii} = sprintf('Material%02d-material', ii);
    end
end

% check for known light ids
if nargin < 4
    lightIds = {};
end

% locate the model file
colladaFile = [modelName '.dae'];
rootFolder = VirtualScenesRoot();
fileInfo = ResolveFilePath(colladaFile, rootFolder);

if ~fileInfo.isRootFolderMatch
    warning('VirtualScenes:NoSuchModel', ...
        'Could not find model named "%s" in %s', modelName, rootFolder);
    return;
end

fprintf('\nFound model:\n  %s\n', fileInfo.absolutePath);

% pack up the metadata
metadata = struct( ...
    'name', {modelName}, ...
    'relativePath', {fileInfo.resolvedPath}, ...
    'boundingVolume', {boundingVolume}, ...
    'materialIds', {materialIds}, ...
    'lightIds', {lightIds});

% choose where to write the metadata
if IsPathPrefix('BaseScenes', metadata.relativePath)
    metadataPath = fullfile(VirtualScenesRoot(), 'BaseScenes');
else
    metadataPath = fullfile(VirtualScenesRoot(), 'Objects');
end
metadataFile = fullfile(metadataPath, [modelName '.mat']);

fprintf('\nWriting metadata:\n  %s\n', metadataFile);
save(metadataFile, 'metadata');
