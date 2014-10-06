%% Load an IlluminationImage recipe and look at output image details.
function ShowDetail(recipe)

%% Choose analysis images to detail.
rgbFiles = { ...
    recipe.processing.maskCoverageFile, ...
    recipe.processing.maskSrgbFile{1}, ...
    recipe.processing.sceneSrgbFile, ...
    recipe.processing.rawReflectanceImage, ...
    recipe.processing.rawIlluminationImage, ...
    recipe.processing.smoothReflectanceImage, ...
    };

%% Where is the detail?
detailY = 250;
detailX = 585;
detailWidth = 50;

detailSpan = (1:detailWidth) - floor(detailWidth/2);
detailSpanX = detailSpan + detailX;
detailSpanY = detailSpan + detailY;

%% Get the mask coverage image in particular.
maskCoverage = imread(recipe.processing.maskCoverageFile);
maskDetail = maskCoverage(detailSpanY, detailSpanX, :);
gapSelector = maskDetail == 0;
fatGapSelector = repmat(gapSelector, [1 1 3]);

%% Show a detail for each image.
f = figure(1);
clf(f)
colormap('gray')

nImages = numel(rgbFiles);
nRows = floor(sqrt(nImages));
nCols = ceil(nImages / nRows);
for ii = 1:nImages
    % pull out a detail and black out the gaps
    rgbImage = imread(rgbFiles{ii});
    rgbDetail = rgbImage(detailSpanY, detailSpanX, :);
    if size(rgbDetail, 3) == 1
        rgbDetail(gapSelector) = 0;
    else
        rgbDetail(fatGapSelector) = 0;
    end
    
    % plot the detail
    subplot(nRows, nCols, ii);
    image(rgbDetail);
    set(gca, ...
        'XTick', [], ...
        'YTick', [], ...
        'Box', 'on', ...
        'DataAspectRatio', [1 1 1]);
    
    % choose a title for this image
    [imagePath, imageBase, imageExt] = fileparts(rgbFiles{ii});
    title(imageBase);
end