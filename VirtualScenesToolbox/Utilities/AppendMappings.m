%% Append mappings blocks to a mappings file.
%   mappingsFileIn is the file to start with
%   mappingsFileOut is the file to write, which may be different
%   ids should be cell array of element ids as from ReadSceneDom()
%   descriptions should should be cell array of descriptions from
%   BuildDesription()
%   blockName can be a mappings block name: "Generic", "Generic foo", etc.
%   comment can be any comment to write before the appended mappings
function mappingsFileOut = AppendMappings(mappingsFileIn, mappingsFileOut, ids, descriptions, blockName, comment)

if nargin < 2 || isempty(mappingsFileOut)
    mappingsFileOut = mappingsFileIn;
end

if nargin < 3 || ~iscell(ids) || isempty(ids)
    warning('VirtualScenes:NoIds', 'No element ids provided, aborting.');
    return;
end
nElements = numel(ids);

if nargin < 4 || ~iscell(descriptions) || isempty(descriptions)
    warning('VirtualScenes:NoDescriptions', 'No element descriptions provided, aborting.');
    return;
end

if nargin < 5 || isempty(blockName)
    blockName = 'Generic';
end

if nargin < 6 || isempty(comment)
    comment = '';
end

% pack up mappings data to write as formatted text
elementInfo = [descriptions{:}];
for ii = 1:nElements
    elementInfo(ii).id = ids{ii};
end

% copy over the original file
if exist(mappingsFileIn, 'file') && ~strcmp(mappingsFileIn, mappingsFileOut)
    copyfile(mappingsFileIn, mappingsFileOut);
end

% append mappings text to the output file
try
    fid = fopen(mappingsFileOut, 'a');
    WriteMappingsBlock(fid, comment, blockName, elementInfo);
    fclose(fid);
    
catch err
    fclose(fid);
    rethrow(err);
end
