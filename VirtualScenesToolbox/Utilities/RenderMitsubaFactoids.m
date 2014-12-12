%% Invoke an RGB version of Mitsuba to extract non-radiant scene factoids.
%   sceneFile a Mitsuba xml scene file
%   integratorId id attribute of the <integrator> scene element
%   filmId id attribute of the <film> scene element
%   factoids subset of {'position', 'relPosition', 'distance', ...
%       'geoNormal', 'shNormal', 'uv', 'albedo', 'shapeIndex', 'primIndex'}
%   hints struct of RenderToolbox3 options, see GetDefaultHints()
%   mitsuba struct of mitsuba config., see getpref("Mitsuba")
function [status, result, newScene, exrOutput, factoidOutput] = ...
    RenderMitsubaFactoids( ...
    sceneFile, integratorId, filmId, factoids, hints, mitsuba)

status = [];
result = [];
exrOutput = [];

if nargin < 2 || isempty(integratorId)
    integratorId = 'integrator';
end

if nargin < 3 || isempty(filmId)
    filmId = 'Camera-camera_film';
end

if nargin < 4 || isempty(factoids)
    factoids = {'position', 'relPosition', 'distance', 'geoNormal', ...
        'shNormal', 'uv', 'albedo', 'shapeIndex', 'primIndex'};
end

if nargin < 5 || isempty(hints)
    hints = GetDefaultHints();
else
    hints = GetDefaultHints(hints);
end

if nargin < 6 || isempty(mitsuba)
    mitsuba = getpref('Mitsuba');
    mitsuba.app = getpref('VirtualScenes', 'rgbMitsubaApp');
end

%% Modify the input file.
[docNode, idMap] = ReadSceneDOM(sceneFile);

% change the integrator into a "multichannel" composite integrator
integratorTypePath = {integratorId, '.type'};
SetSceneValue(idMap, integratorTypePath, 'multichannel', true);

% change the film to hdr type and openexr format
filmTypePath = {filmId, '.type'};
SetSceneValue(idMap, filmTypePath, 'hdrfilm', true);
filmFormatPath = {filmId, ':string|name=fileFormat', '.value'};
SetSceneValue(idMap, filmFormatPath, 'openexr', true);

% add a nested integrator for each factoid
% use "factoid" attributes to distinguish different integrators
formatList = '';
nameList = '';
for ii = 1:numel(factoids)
    factoid = factoids{ii};
    
    % nested integrator
    integratorTypePath = {integratorId, ...
        [':integrator|name=' factoid], '.type'};
    SetSceneValue(idMap, integratorTypePath, 'field', true);
    integratorPath = {integratorId, ...
        [':integrator|name=' factoid], ':string|name=field', '.value'};
    SetSceneValue(idMap, integratorPath, factoid, true);
    
    % build up lists of factoid channel info
    formatList = [formatList 'rgb, '];
    nameList = [nameList factoid ', '];
end
% output channel format
channelFormatPath = {filmId, ':string|name=pixelFormat', '.value'};
SetSceneValue(idMap, channelFormatPath, formatList(1:end-2), true);

% output channel name
channelNamePath = {filmId, ':string|name=channelNames', '.value'};
SetSceneValue(idMap, channelNamePath, nameList(1:end-2), true);

% write a new scene file
[scenePath, sceneBase, sceneExt] = fileparts(sceneFile);
newScene = fullfile(scenePath, [sceneBase '-factoids' sceneExt]);
WriteSceneDOM(newScene, docNode);

%% Render the factoid scene.
[status, result, exrOutput] = RunMitsuba(newScene, hints, mitsuba);

%% Get the factoid output
[sliceInfo, data] = ReadMultichannelEXR(exrOutput);

% identify factoid and RGB channel for each image slice
factoidOutput = struct();
factoidSize = size(data);
factoidSize(3) = 3;
channelNames = 'RGB';
for ii = 1:numel(sliceInfo)
    split = find(sliceInfo(ii).name == '.');
    factoid = sliceInfo(ii).name(1:split-1);
    channelName = sliceInfo(ii).name(split+1:end);
    channel = channelName == channelNames;
    
    if ~isfield(factoidOutput, factoid)
        factoidOutput.(factoid) = zeros(factoidSize);
    end
    
    slice = data(:,:,ii);
    factoidOutput.(factoid)(:, :, channel) = slice;
end

