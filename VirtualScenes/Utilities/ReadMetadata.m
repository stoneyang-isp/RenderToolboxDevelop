%% Read metadata about a base scene or object.
% metadata stored in BaseScenes/ or Objects/ subfolder
function metadata = ReadMetadata(modelName)
metadata = [];

% locate the metadata file
metadataFile = [modelName '.mat'];
rootFolder = VirtualScenesRoot();
fileInfo = ResolveFilePath(metadataFile, rootFolder);

if ~fileInfo.isRootFolderMatch
    warning('VirtualScenes:NoSuchMetadata', ...
        'Could not find metadata for model named "%s" in %s', modelName, rootFolder);
    return;
end

metadataFullPath = fileInfo.absolutePath;
fprintf('\nFound model metadata:\n  %s\n', metadataFullPath);

fileData = load(fileInfo.absolutePath);

if ~isfield(fileData, 'metadata')
        warning('VirtualScenes:BadMetadata', ...
        'Metadata is missing from data file %s', metadataFullPath);
    return;
end

metadata = fileData.metadata;
