%% Simple utility for writing out image files.
%   @param fileName the name of the image file to write
%   @param imageData image matrix to pass to imwrite()
%
% @details
% This is a simple wrapper for the built-in imwrite() function.  In case
% @a fileName contains a path that doesn't exist yet, this function creates
% the path.
%
% @details
% Returns the given file name, which can be handy and reduce typing in the
% calling function.
%
% @details
% Usage:
%   fileName = WriteImage(fileName, imageData)
%
% @ingroup VirtualScenes
function fileName = WriteImage(fileName, imageData)
[filePath, fileBase, fileExt] = fileparts(fileName);
if ~isempty(filePath) && ~exist(filePath, 'dir')
    mkdir(filePath);
end
imwrite(imageData, fileName);
