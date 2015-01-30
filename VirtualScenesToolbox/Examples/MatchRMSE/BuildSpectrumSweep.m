%% Build a parameter sweep with interpolated spd-files.
%   sweepName name for spectrum files and output images
%   spectrumA starting spd-file or other spectrum specifier
%   spectrumB ending spd-file or other spectrum specifier
%   nSteps how many steps in the sweep
%   outputFolder where to write new interpolated spd-files
%   scaleB optional scale factor to apply to spectrumB
function [spdFiles, imageNames, lambdas] = BuildSpectrumSweep(sweepName, spectrumA, spectrumB, nSteps, outputFolder, scaleB)

if nargin < 6 || isempty(scaleB)
    scaleB = 1;
end

% read in the original spectra
[wlsA, magsA] = ReadSpectrum(spectrumA);
[elsB, magsB] = ReadSpectrum(spectrumB);

% scale the second spectrum
magsB = magsB .* scaleB;

% write out several interpolated spectra
lambdas = linspace(0, 1, nSteps);
spdFiles = cell(nSteps, 1);
imageNames = cell(nSteps, 1);
for ii = 1:nSteps
    imageNames{ii} = sprintf('%s-%02d', sweepName, ii);
    spdFiles{ii} = sprintf('%s.spd', imageNames{ii});
    intermMags = lambdas(ii) .* magsB + (1-lambdas(ii)) .* magsA;
    WriteSpectrumFile(wlsA, intermMags, fullfile(outputFolder, spdFiles{ii}));
end