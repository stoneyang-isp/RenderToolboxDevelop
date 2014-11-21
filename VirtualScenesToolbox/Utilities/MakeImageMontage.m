%% Make an m x n montage from RGB image files.
%   fileName file name for the new montage
%   images m x n cell array of image file names
%   names m x n cell array of image labels
%   scaleFactor how much to scale the montage (might be large)
%   scaleMethod how exactly to scale the montage
function fileName = MakeImageMontage(fileName, images, names, scaleFactor, scaleMethod)

if nargin < 1 || isempty(fileName)
    fileName = 'montage.png';
end

if nargin < 3 || isempty(names)
    names = cell(size(images));
end

if nargin < 4 || isempty(scaleFactor)
    scaleFactor = [];
end

if nargin < 5 || isempty(scaleMethod)
    scaleMethod = 'lanczos3';
end

bigMontage = [];
rows = size(images, 1);
columns = size(images, 2);
for ii = 1:rows
    for jj = 1:columns
        panelFile = images{ii,jj};
        if ~ischar(panelFile) || ~exist(panelFile, 'file')
            continue;
        end
        
        % load the next panel
        panel = imread(panelFile);
        panelDepth = size(panel, 3);
        panelWidth = size(panel, 2);
        panelHeight = size(panel, 1);
        
        % grayscale to RGB
        if 1 == panelDepth
            panel = repmat(panel, [1, 1, 3]);
        end
        
        % first time, initialize the whole montage image
        if isempty(bigMontage)
            gridWidth = panelWidth;
            gridHeight = panelHeight;
            montageHeight = rows * panelHeight;
            montageWidth = columns * panelWidth;
            bigMontage = zeros(montageHeight, montageWidth, 3, 'uint8');
        end
        
        % copy in the panel
        xOffset = (jj-1) * gridWidth;
        yOffset = (ii-1) * gridHeight;
        xRange = xOffset + (1:panelWidth);
        yRange = yOffset + (1:panelHeight);
        bigMontage(yRange, xRange, :) = panel;
        
        panelName = names{ii,jj};
        if ~ischar(panelName)
            continue;
        end
        
        % write a name for this panel
        bigMontage = insertText( ...
            bigMontage, [xOffset, yOffset] + 1, panelName);
    end
end

% scale the big montage?
if ~isempty(scaleFactor) || 1 ~= scaleFactor
    bigMontage = imresize(bigMontage, scaleFactor, scaleMethod);
end

% finally out to disk
imwrite(bigMontage, fileName);
