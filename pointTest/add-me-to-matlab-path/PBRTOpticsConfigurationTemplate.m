%%% RenderToolbox3 Copyright (c) 2012-2013 The RenderToolbox3 Team.
%%% About Us://github.com/DavidBrainard/RenderToolbox3/wiki/About-Us
%%% RenderToolbox3 is released under the MIT License.  See LICENSE.txt.
%
% Set up machine-specific RenderToolbox3 configuration, like where to write
% output files and renderer configuration.
%
% This script sets up RenderToolbox3 to work with 3 renderers:
%   - Mitsuba (as usual)
%   - pbrt-v2-spectral (as usual)
%   - pbrt-v2-optics (new, from Andy Lai Lin)
%

%% Start with RenderToolbox3 "fresh out of the box" configuration.
InitializeRenderToolbox(true);

%% Tell RenderToolbox3 where to save outputs.
% choose Matlab's default "user folder"
myFolder = fullfile(GetUserFolder(), 'render-toolbox');

% or choose any folder that you want RenderToolbox3 to write to
%myFolder = 'choose/your/output/folder';

% set folders for temp, data, and image outputs
setpref('RenderToolbox3', 'tempFolder', fullfile(myFolder, 'temp'));
setpref('RenderToolbox3', 'outputDataFolder', fullfile(myFolder, 'data'));
setpref('RenderToolbox3', 'outputImageFolder', fullfile(myFolder, 'images'));
setpref('RenderToolbox3', 'resourcesFolder', fullfile(myFolder, 'resources'));


%% Set Up Mitsuba Preferences.
if ispref('Mitsuba')
    % delete any stale preferences
    rmpref('Mitsuba');
end

% choose the file with default adjustments
adjustmentsFile = fullfile(RenderToolboxRoot(), ...
    'RendererPlugins', 'Mitsuba', 'MitsubaDefaultAdjustments.xml');

% choose the default scale factor for radiance units
radiometricScaleFactor = 0.0795827427;

if ismac()
    % on OS X, Mitsuba is an "app bundle"
    
    % use the default app bundle path
    myMistubaApp = '/Applications/Mitsuba.app';
    
    % or choose where you installed Mitsuba
    %myMistubaApp = '/my/path/for/Mitsuba.app';
    
    % don't change these--
    %   they tell RenderToolbox3 where to look inside the app bundle
    myMistubaExecutable = 'Contents/MacOS/mitsuba';
    myMistubaImporter = 'Contents/MacOS/mtsimport';
    
else
    % on Linux and Windows, Mitsuba has separate executable files
    
    % use the default executable paths
    myMistubaExecutable = '/usr/local/bin/mitsuba';
    myMistubaImporter = '/usr/local/bin/mtsimport';
    
    % or choose where you installed Mitsuba
    %myMistubaExecutable = '/my/path/for/mitsuba';
    %myMistubaImporter = '/my/path/for/mtsimport';
    
    % don't change this--
    %   the "app" path is only meaningful for OS X
    myMistubaApp = '';
end

% save preferences for Mitsuba
setpref('Mitsuba', 'adjustments', adjustmentsFile);
setpref('Mitsuba', 'radiometricScaleFactor', radiometricScaleFactor);
setpref('Mitsuba', 'app', myMistubaApp);
setpref('Mitsuba', 'executable', myMistubaExecutable);
setpref('Mitsuba', 'importer', myMistubaImporter);


%% Set Up Usual PBRT Preferences.
if ispref('PBRT')
    % delete any stale preferences
    rmpref('PBRT');
end

% choose the file with default adjustments
adjustmentsFile = fullfile(RenderToolboxRoot(), ...
    'RendererPlugins', 'PBRT', 'PBRTDefaultAdjustments.xml');

% choose the default scale factor for radiance units
radiometricScaleFactor = 0.0063831432;

% choose spectral sampling
%   which was sepcified at PBRT compile time
S = [400 10 31];

% use the default path for PBRT
myPBRT = '/usr/local/bin/pbrt';

% or choose where you installed PBRT
%myPBRT = '/my/path/for/pbrt';

% save preferences for Mitsuba
setpref('PBRT', 'adjustments', adjustmentsFile);
setpref('PBRT', 'radiometricScaleFactor', radiometricScaleFactor);
setpref('PBRT', 'S', S);
setpref('PBRT', 'executable', myPBRT);

%% Set Up PBRT_Optics Preferences.
% PBRT_Optics is an alternate version of PBRT, simiar to the usual
% pbrt-v2-spectral used above.  But it's modified by Andy Lai Lin to
% simulate lens optics in a physically based, spectrally correct way.  It
% samples the spectrum with 32 bands instead of 31, and it requires 32
% times more pixel samples than usual.

if ispref('PBRT_Optics')
    % delete any stale preferences
    rmpref('PBRT_Optics');
end

% choose file paths relative to this file
localPath = fileparts(mfilename('fullpath'));

% choose spectral sampling
%   which was sepcified at PBRT compile time
S = [400 10 32];

% choose the default scale factor for radiance units
radiometricScaleFactor = 0.00631706035944380219;

% choose the file with default adjustments
adjustmentsFile = fullfile(localPath, ...
    'PBRT_Optics_Plugin', 'PBRT_OpticsDefaultAdjustments.xml');

% use special PBRT located relative to this script
[localPath, mFile] = fileparts(mfilename('fullpath'));
myPBRT = fullfile(localPath, 'bin', 'pbrt');

% save preferences for Mitsuba
setpref('PBRT_Optics', 'adjustments', adjustmentsFile);
setpref('PBRT_Optics', 'radiometricScaleFactor', radiometricScaleFactor);
setpref('PBRT_Optics', 'S', S);
setpref('PBRT_Optics', 'executable', myPBRT);