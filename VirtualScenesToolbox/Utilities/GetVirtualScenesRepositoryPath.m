%% Convert a Model Repository relative path to a local absolute path.
%   relativePath should be a metadata.relative path from ReadMetadata()
function absolutePath = GetVirtualScenesRepositoryPath(relativePath)
repository = getpref('VirtualScenes', 'modelRepository');
absolutePath = fullfile(repository, relativePath);
