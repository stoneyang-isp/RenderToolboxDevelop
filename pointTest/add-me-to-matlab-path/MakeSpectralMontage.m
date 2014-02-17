% Utility for Optics test scenes to make a montage at spectrum slices.
function [outFiles, montageFile] = MakeSpectralMontage(pbrtFile, bands, hints)

% render the scene with pbrt
[scenePath, scene] = fileparts(pbrtFile);
[status, commandResult, output] = RunPBRT_Optics(pbrtFile, hints);

% will save mat-files in the style of BatchRender().
radiometricScaleFactor = getpref(hints.renderer, 'radiometricScaleFactor');
versionInfo = feval(GetRendererAPIFunction('VersionInfo', hints.renderer));
S = getpref(hints.renderer, 'S');
hints.outputSubfolder = scene;
outPath = fullfile(GetOutputPath('outputDataFolder', hints), hints.renderer);
if ~exist(outPath, 'dir')
    mkdir(outPath)
end

% locate spectrum bands
bandIndices = zeros(size(bands));
wls = MakeItWls(S);
for ii = 1:numel(bands);
    [lowVal, bandIndices(ii)] = min(abs(bands(ii) - wls));
end

% save a mat file for each spectrum band
%   copy band data across whole spectrum to avoid sRGB conversion-confusion
outFiles = cell(1, numel(bands));
multispectralData = ReadDAT(output);
dataSize = size(multispectralData);
for ii = 1:numel(bands)
    bandIndex = bandIndices(ii);
    sliceImage = multispectralData(:, :, bandIndex);
    sliceImage = sliceImage ./ max(sliceImage(:));
    multispectralImage = repmat(sliceImage, [1, 1, dataSize(3)]);
    
    outFiles{ii} = fullfile(outPath, [scene '-' num2str(bands(ii)) 'nm.mat']);
    save(outFiles{ii}, 'multispectralImage', 'S', 'radiometricScaleFactor', ...
        'hints', 'scene', 'versionInfo', 'commandResult');
end

% make a montage with spectrum bands
toneMapFactor = 100;
isScaleGamma = true;
montageName = sprintf('%s (%s)', hints.outputSubfolder, hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(outFiles, montageFile, toneMapFactor, isScaleGamma, hints);

% display the sRGB montage
ShowXYZAndSRGB([], SRGBMontage, montageName);
