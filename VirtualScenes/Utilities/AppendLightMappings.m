%% Append light spectra to a mappings file.
%   lightIds should be {'CeilingLight-mesh', 'WindowLight-mesh', ...}
%   lightDescriptions should should be {light1, light2, ...}
%   blockName can be a mappings block name: "Generic", "Generic foo", etc.
% Each light1, light2, etc. must be a descriptsion returned from
% BuildDescription()
function mappingsFileOut = AppendLightMappings(mappingsFileIn, mappingsFileOut, lightIds, lightDescriptions, blockName)

if nargin < 2 || isempty(mappingsFileOut)
    mappingsFileOut = mappingsFileIn;
end

if nargin < 3 || ~iscell(lightIds) || isempty(lightIds)
    warning('VirtualScenes:NoLightIds', 'No LightIds provided, aborting.');
end

nLights = numel(lightIds);

if nargin < 4 || ~iscell(lightDescriptions) || isempty(lightDescriptions)
    warning('VirtualScenes:NoLightTypes', ...
        '\nUsing default area lights');
    defaultDescription = BuildDesription('light', 'area', ...
        {'intensity'}, ...
        {'300:1 800:1'}, ...
        {'spectrum'});    
    lightDescriptions = cell(1, nLights);
    for ii = 1:nLights
        lightDescriptions{ii} = defaultDescription;
    end
end

if nargin < 5 || isempty(blockName)
    blockName = 'Generic';
end

% pack up mappings data to write as formatted text
elementInfo = [lightDescriptions{:}];
for ii = 1:nLights
    elementInfo(ii).id = lightIds{ii};
end

fprintf('\nAppending light spectra to mappings file:\n  %s\n', mappingsFileOut);

% copy over the original file
if exist(mappingsFileIn, 'file') && ~strcmp(mappingsFileIn, mappingsFileOut)
    copyfile(mappingsFileIn, mappingsFileOut);
end

% append mappings text to the output file
try
    fid = fopen(mappingsFileOut, 'a');
    WriteMappingsBlock(fid, 'lights', blockName, elementInfo);
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end
