%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
%% Render a test card at several distances and focuses.

%% Choose example files, make sure they're on the Matlab path.
clear
AddWorkingPath(mfilename('fullpath'));
parentSceneFile = 'TestCard.dae';
mappingsFile = 'TestCardMappings.txt';
conditionsFile = 'TestCardConditionsRealistic.txt';

%% Choose batch renderer options.
hints.imageWidth = 200;
hints.imageHeight = 200;
hints.outputSubfolder = mfilename();
hints.isCaptureCommandResults = false;

%% Render with Mitsuba and PBRT.
toneMapFactor = 100;
isScale = true;
hints.renderer = 'PBRT_Optics';
nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
radianceDataFiles = BatchRender(nativeSceneFiles, hints);
montageName = sprintf('Test Card (%s)', hints.renderer);
montageFile = [montageName '.png'];
[SRGBMontage, XYZMontage] = ...
    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
ShowXYZAndSRGB([], SRGBMontage, montageName);

%% Choose some spectral bands to slice the renderings.
bands = [400 550 700];
bandIndices = zeros(size(bands));
S = getpref('PBRT_Optics', 'S');
wls = MakeItWls(S);
for ii = 1:numel(bands);
    [lowVal, bandIndices(ii)] = min(abs(bands(ii) - wls));
end


%% Make a montage at each spectral band.
for ii = 1:numel(bands)
    bandIndex = bandIndices(ii);
    bandName = ['-' num2str(bands(ii)) 'nm'];
    sliceDataFiles = cell(size(radianceDataFiles));
    
    for jj = 1:numel(radianceDataFiles)
        data = load(radianceDataFiles{jj});
        dataSize = size(data.multispectralImage);
        sliceImage = data.multispectralImage(:, :, bandIndex);
        sliceImage = sliceImage ./ max(sliceImage(:));
        data.multispectralImage = repmat(sliceImage, [1, 1, dataSize(3)]);
        
        [dataPath, dataName, dataExt] = fileparts(radianceDataFiles{jj});
        sliceFile = fullfile(dataPath, [dataName bandName dataExt]);
        save(sliceFile, '-struct', 'data');
        sliceDataFiles{jj} = sliceFile;
    end
    
    montageName = sprintf('Test Card (%s)%s', hints.renderer, bandName);
    montageFile = [montageName '.png'];
    [SRGBMontage, XYZMontage] = ...
        MakeMontage(sliceDataFiles, montageFile, toneMapFactor, isScale, hints);
    ShowXYZAndSRGB([], SRGBMontage, montageName);
end
