% Smooth out the gaps in an image with a sliding average.
%   rawImage some m x n x p image
%   gapMask some m x n mask with zeros indicating gaps
%   filterWidth width of sliding filter used to smooth out gaps
function smoothImage = SmoothOutGaps(rawImage, gapMask, filterWidth)
imageSize = size(rawImage);
width = imageSize(1);
height = imageSize(2);
depth = imageSize(3);

% make sure raw image has gaps where it's supposed to
isGap = gapMask == 0;
for kk = 1:depth
    imageSlice = rawImage(:,:,kk);
    imageSlice(isGap) = 0;
    rawImage(:,:,kk) = imageSlice;
end

% compute smooth image with sliding window
window = (1:filterWidth) - floor(filterWidth/2);
smoothImage = rawImage;
for ii = 1:width
    for jj = 1:height
        if gapMask(ii,jj) > 0
            % no gap here
            continue;
        end
        
        % choose window area
        iiWindow = min(max(window + ii, 1), width);
        jjWindow = min(max(window + jj, 1), height);
        
        % take average at each depth slice
        for kk = 1:depth
            nSamples = sum(sum(~isGap(iiWindow, jjWindow)));
            windowSelection = rawImage(iiWindow, jjWindow, kk);
            smoothImage(ii,jj,kk) = sum(windowSelection(:)) / nSamples;
        end
    end
end
