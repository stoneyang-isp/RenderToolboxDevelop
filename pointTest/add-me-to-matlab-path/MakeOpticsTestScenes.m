% Render some test scenes from Andy Lai Lin.
%
% These use Andy's optics version of his pbrt-v2-spectral renderer.  The
% PBRT_Optics renderer plugin encapsulates this version of of
% pbrt-v2-spectral in RenderToolbox3 style.
%

%% Set up.
clear;
PBRTOpticsConfigurationTemplate;

% locate scene files relative to this file
localPath = fileparts(mfilename('fullpath'));
if isempty(localPath)
    localPath = pwd();
end

% some hints ignored when calling RunPBRT_Optics directly
hints.isPlot = false;
hints.isCaptureCommandResults = false;
hints.renderer = 'PBRT_Optics';

% will isolate a few spectrum bands
bands = [400 500 600 700];

%% Render the "ideal lens" test scene and make a spectral montage.
pbrtFile = fullfile(localPath, '..', 'idealLens', 'pointTest.pbrt');
[idealData, idealMontage] = MakeSpectralMontage(pbrtFile, bands, hints);


%% Render the "realistic lens" test scene.
pbrtFile = fullfile(localPath, '..', 'realisticLens', 'realisticPointTest.pbrt');
[realisticData, realisticMontage] = MakeSpectralMontage(pbrtFile, bands, hints);

%% Histogram the spectral slices -- want to see chromatic spread.
falseColors = {[0 0 1], [0 0.75, 0.75], [0.75 0.75 0], [1 0 0]};
lineWidth = 2;

figure()

subplot(2,1,1);
title('idealLens')
for ii = numel(idealData):-1:1
    sliceData = load(idealData{ii});
    sliceCollapsed = sum(sum(sliceData.multispectralImage, 3));
    sliceCollapsed = sliceCollapsed ./ max(sliceCollapsed);
    line(1:numel(sliceCollapsed), sliceCollapsed, ...
        'Color', falseColors{ii}, ...
        'Marker', 'none', ...
        'LineStyle', '-', ...
        'LineWidth', lineWidth);
end

subplot(2,1,2);
title('realisticLens')
for ii = numel(realisticData):-1:1
    sliceData = load(realisticData{ii});
    sliceCollapsed = sum(sum(sliceData.multispectralImage, 3));
    sliceCollapsed = sliceCollapsed ./ max(sliceCollapsed);
    line(1:numel(sliceCollapsed), sliceCollapsed, ...
        'Color', falseColors{ii}, ...
        'Marker', 'none', ...
        'LineStyle', '-', ...
        'LineWidth', lineWidth);
end
