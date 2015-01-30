%% Invoke an RGB version of Mitsuba to extract non-radiance scene factoids.
%   @param sceneFile a Mitsuba XML scene file
%   @param integratorId string id of the <integrator> scene element
%   @param filmId string id of the <film> scene element
%   @param factoids cell array of names of factoids to extract
%   @param hints struct of RenderToolbox3 options, see GetDefaultHints()
%   @param mitsuba struct of Mitsuba configuration, see getpref('Mitsuba')
%
% @details
% Modifies a copy of the given Mitsuba @a sceneFile to instruct Mitsuba to
% instruct scene "factoids" instead of rendering radiance data.  The
% factoids represent "ground truth" about the scene rather than ray tracing
% samples.
%
% @details
% @a integratorId and @a filmId must be the string "id" attributes for the
% <integrator> and <film> elements of the given @a sceneFile.  These
% are required when modifying the scene to produce factoids instead of
% radiance data.  The default @a integratorId is 'integrator'.  The default
% @a filmId is 'Camera-camera_film'.
%
% @details
% Mitsuba supports a few different ground-truth factoids. @a factiods must
% be a cell array containing some or all of the following factoid names:
%   - @b 'position' - absolute position of the object under each pixel
%   - @b 'relPosition' - camera-relative position of the object under each pixel
%   - @b 'distance' - distance to camera of the object under each pixel
%   - @b 'geoNormal' - surface normal at the surface under each pixel
%   - @b 'shNormal' - surface normal at the surface under each pixel, interpolated for shading
%   - @b 'uv' - texture mapping UV coordinates at the surface under each pixel
%   - @b 'albedo' - diffuse reflectance of the object under each pixel
%   - @b 'shapeIndex' - integer identifier for the object under each pixel
%   - @b 'primIndex' - integer identifier for the triangle or other primitive under each pixel
%
% @details
% @a hints may be a struct with RenderToolbox3 as returned from
% GetDefaultHints().  If @a hints is omitted, default options are used.
%
% @details
% @a mitsuba may be a struct with options for invoking Mitsuba, as returned
% from getpref('Mitsuba').  Some Mitsuba factoids only work when Mitsuba
% was build in 3-channel RGB mode.  So @a mitsuba should point to an RGB
% build of the renderer.
%
% @details
% Returns the status code and command line result from invoking Mitsuba.
% Also returns the file name of the modified copy of the given @a
% sceneFile.  Also returns the file name of the OpenEXR data returned from
% Mitsuba.  Finally, returns a struct of factoid data, with one field per
% factoid name specified in @a factoids.
%
% @details
% Usage:
%   [status, result, newScene, exrOutput, factoidOutput] = RenderMitsubaFactoids(sceneFile, integratorId, filmId, factoids, hints, mitsuba)
%
% @ingroup VirtualScenes
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

