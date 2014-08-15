%% Append material mappings file.
%   materialIds should be {'Material01-material', 'Floor-material', ...}
%   materialDescriptions should should be {material1, material2, ...}
%   idPrefix can be a string to prepend to all each materialId
%   blockName can be a mappings block name: "Generic", "Generic foo", etc.
% Each material1, material2, etc. must be a descriptsion returned from
% BuildDescription()
%
% Writes formatted text for each material, like
%	BaseBoard-material:material:anisoward
%	BaseBoard-material:diffuseReflectance.spectrum = 300:1 800:1
%	BaseBoard-material:specularReflectance.spectrum = 300:1 800:1
%
%	BaseBoard-material:material:matte
%	BaseBoard-material:diffuseReflectance.spectrum = 300:1 800:1
%
%   etc.
function mappingsFileOut = AppendMaterialMappings(mappingsFileIn, mappingsFileOut, materialIds, materialDescriptions, idPrefix, blockName)

if nargin < 2 || isempty(mappingsFileOut)
    mappingsFileOut = mappingsFileIn;
end

if nargin < 3 || ~iscell(materialIds) || isempty(materialIds)
    warning('VirtualScenes:NoMaterialIds', 'No MaterialIds provided, aborting.');
end

nMaterials = numel(materialIds);

if nargin < 4 || ~iscell(materialDescriptions) || isempty(materialDescriptions)
    warning('VirtualScenes:NoMaterialDescriptions', ...
        '\nUsing default matte material');
    defaultDescription = BuildDesription('material', 'matte', ...
        {'diffuseReflectance'}, ...
        {'300:1 800:1'}, ...
        {'spectrum'});
    materialDescriptions = cell(1, nMaterials);
    for ii = 1:nMaterials
        materialDescriptions{ii} = defaultDescription;
    end
end

if nargin < 5 || isempty(idPrefix)
    idPrefix = '';
end

if nargin < 6 || isempty(blockName)
    blockName = 'Generic';
end

% append a prefix to each id?
if ~isempty(idPrefix)
    for ii = 1:nMaterials
        materialIds{ii} = [idPrefix materialIds{ii}];
    end
end

% pack up mappings data to write as formatted text
elementInfo = [materialDescriptions{:}];
for ii = 1:nMaterials
    elementInfo(ii).id = materialIds{ii};
end


fprintf('\nAppending materials to mappings file:\n  %s\n', mappingsFileOut);

% copy over the original file
if exist(mappingsFileIn, 'file') && ~strcmp(mappingsFileIn, mappingsFileOut)
    copyfile(mappingsFileIn, mappingsFileOut);
end

% append mappings text to the output file
try
    fid = fopen(mappingsFileOut, 'a');
    WriteMappingsBlock(fid, [idPrefix 'materials'], blockName, elementInfo);
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end
