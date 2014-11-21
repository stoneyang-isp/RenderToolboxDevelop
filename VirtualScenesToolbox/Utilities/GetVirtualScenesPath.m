%% Convert a Virutal Scenes relative path to a local absolute path.
%   relativePath should be a metadata.relative path from ReadMetadata()
function absolutePath = GetVirtualScenesPath(relativePath)
absolutePath = fullfile(VirtualScenesRoot(), relativePath);