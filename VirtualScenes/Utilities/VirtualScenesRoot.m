%% Get root folder of teh VirtualScenes prokect.
% which is the parent folder of the Utilities folder
function rootPath = VirtualScenesRoot()
filePath = mfilename('fullpath');
lastSeps = find(filesep() == filePath, 2, 'last');
rootPath = filePath(1:(lastSeps(1) - 1));
