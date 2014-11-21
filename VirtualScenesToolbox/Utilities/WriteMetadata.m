%% Write metadata for a base scene or object.
% metadata stored in BaseScenes/ or Objects/ subfolder
%   modelName should be "RingToy" for Objects/Models/RingToy.dae
%   objectBox should be [minX maxX; minY maxY; minZ, maxZ]
%   lightBox should be [minX maxX; minY maxY; minZ, maxZ]
%   lightExcludeBox should be [minX maxX; minY maxY; minZ, maxZ]
%   materialIds should be {'Floor-material', 'Material1-material', ...}
%   lightIds should be {'CeilingLight-mesh', 'WindowLight-mesh', ...}
function metadata = WriteMetadata(modelName, objectBox, lightBox, ...
    lightExcludeBox, materialIds, lightIds)
metadata = [];

% check the bounding volumes
if nargin < 2 || ~isnumeric(objectBox) || ~isequal([3 2], size(objectBox))
    defaultVolume = '[-1 1; -1 1; -1 1]';
    warning('VirtualScenes:BadObjectBox', ...
        '\nUsing default objectBox, %s', defaultVolume);
    objectBox = eval(defaultVolume);
end

if nargin < 3 || ~isnumeric(lightBox) || ~isequal([3 2], size(lightBox))
    defaultVolume = '[-10 10; -10 10; -10 10]';
    warning('VirtualScenes:BadLightBox', ...
        '\nUsing default lightBox, %s', defaultVolume);
    lightBox = eval(defaultVolume);
end

if nargin < 4 || ~isnumeric(lightExcludeBox) || ~isequal([3 2], size(lightExcludeBox))
    defaultVolume = '[-1 1; -1 1; -1 1]';
    warning('VirtualScenes:BadLightExcludeBox', ...
        '\nUsing default lightExcludeBox, %s', defaultVolume);
    lightExcludeBox = eval(defaultVolume);
end

% check for known material ids
if nargin < 5 || ~iscell(materialIds) || isempty(materialIds)
    warning('VirtualScenes:NoMaterialIds', ...
        '\nUsing default material Ids, %s', ...
        '{''Material01-material'', ..., ''Material10-material''}');
    materialIds = cell(1, 10);
    for ii = 1:numel(materialIds)
        materialIds{ii} = sprintf('Material%02d-material', ii);
    end
end

% check for known light ids
if nargin < 6
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
    'objectBox', {objectBox}, ...
    'lightBox', {lightBox}, ...
    'lightExcludeBox', {lightExcludeBox}, ...
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
