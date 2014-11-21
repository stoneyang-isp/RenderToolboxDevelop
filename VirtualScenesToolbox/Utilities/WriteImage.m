%% Simple utility for writing out image files.
%   fileName should be the name or full path to write out.
%   imageData should be an image matrix to pass to imwrite.
% Creates the output path if needed and writes out the given imageData.
% Also returns the given file name, which can help reduce boilerplate code
% and typos in the calling function.
function fileName = WriteImage(fileName, imageData)
[filePath, fileBase, fileExt] = fileparts(fileName);
if ~isempty(filePath) && ~exist(filePath, 'dir')
    mkdir(filePath);
end
imwrite(imageData, fileName);
