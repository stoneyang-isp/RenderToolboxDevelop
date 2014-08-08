%% Write a block of formatted mappings text to the given file.
%   fid must be a fid from fopen()
%   comment can by any comment to write before the formatted text
%   blockName must be Generic, Mitsuba, etc.
%   elementInfo must be a struct array with fields:
%       - id - the id of an object, like CeilingLight-mesh
%       - categoty - the category of the object, like light
%       - type - the specific object type, like area
%       - properties - struct array of properties with fields:
%           - propertyName - a property of the object, like intensity
%           - propertyValue - a value for the property, like 300:1 800:1
%           - valueType - the data type of the value, like spectrum
%
% Writes formatted text for each element of the elementInfo array, like
%   CeilingLight-mesh:light:area
%   CeilingLight-mesh:intensity.spectrum = 300:1 800:1
function WriteMappingsBlock(fid, comment, blockName, elementInfo)
fprintf(fid, '\n\n%% %s\n', comment);
fprintf(fid, '%s {\n', blockName);
for ii = 1:numel(elementInfo)
    fprintf(fid, '\t%s:%s:%s\n', elementInfo(ii).id, ...
        elementInfo(ii).category, elementInfo(ii).type);
    for jj = 1:numel(elementInfo(ii).properties)
        prop = elementInfo(ii).properties(jj);
        fprintf(fid, '\t%s:%s.%s = %s\n\n', elementInfo(ii).id, ...
            prop.propertyName, prop.valueType, prop.propertyValue);
    end
end
fprintf(fid, '}\n');
