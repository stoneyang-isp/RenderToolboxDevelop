% Smooth out the gaps in an image with a sliding average.
%   rawImage some m x n x p image
%   gapMask some m x n mask with zeros indicating gaps
%   filterWidth width of sliding filter used to smooth out gaps
function smoothImage = SmoothOutGaps(rawImage, gapMask, filterWidth)
imageSize = size(rawImage);
height = imageSize(1);
width = imageSize(2);

isGap = gapMask == 0;
windowMask = zeros(height, width);

% compute smooth image with sliding window
halfWindow = ceil(filterWidth/2);
smoothImage = rawImage;
for ii = 1:height
    for jj = 1:width
        if gapMask(ii,jj) > 0
            % no gap here
            continue;
        end
        
        % choose window area
        windowYMin = max(ii - halfWindow, 1);
        windowYMax = min(ii + halfWindow, height);
        windowXMin = max(jj - halfWindow, 1);
        windowXMax = min(jj + halfWindow, width);
        
        % make a mask to average over
        windowMask(:) = 0;
        windowMask(windowYMin:windowYMax, windowXMin:windowXMax) = 1;
        windowMask(isGap) = 0;

        % get the mean under the mask
        [maskMean, maskMedian] = MeanUnderMask(rawImage, windowMask);
        
        % smooth out that gap!
        smoothImage(ii, jj, :) = maskMedian;
    end
end
