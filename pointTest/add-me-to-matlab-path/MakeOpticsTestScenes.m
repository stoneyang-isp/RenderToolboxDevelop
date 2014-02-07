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
[outFiles, montageFile] = MakeSpectralMontage(pbrtFile, bands, hints);


%% Render the "realistic lens" test scene.
pbrtFile = fullfile(localPath, '..', 'realisticLens', 'realisticPointTest.pbrt');
[outFiles, montageFile] = MakeSpectralMontage(pbrtFile, bands, hints);