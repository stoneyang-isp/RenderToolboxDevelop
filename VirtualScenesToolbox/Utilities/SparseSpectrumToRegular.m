%% Convert a sparse spectrum string to an evenly spaced spectrum.
% For example, '1:0 7:1 10:0' is sparse because it skips wavelengths
% unevenly.  So convert it to a regular equivalent by filling in missing
% wavelengths:
%   1:0 2:0 3:0 4:0 5:0 6:0 7:1 8:0 9:0 10:0
%
% Fills in all wavelengths at given spacing, between the min and max.
% Fills reads values from left to right.  This guarantees that wavelengths
% come out evenly spaces, which allows resampling with Psychtoolox
% functions like SplineRaw(), etc.
function [denseWls, denseMags] = SparseSpectrumToRegular(sparse, spacing)

if nargin < 2 || isempty(spacing)
    spacing = 1;
end

[sparseWls, sparseMags] = ReadSpectrum(sparse);
denseWls = sparseWls(1):spacing:sparseWls(end);
denseMags = zeros(size(denseWls));
jj = 1;
currentMag = 0;
for ii = 1:numel(denseWls)
    if denseWls(ii) >= sparseWls(jj)
        currentMag = sparseMags(jj);
        jj = jj + 1;
    end
    denseMags(ii) = currentMag;
end
