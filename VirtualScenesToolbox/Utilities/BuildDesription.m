%% Get a formatted struct describing a light, material, etc.
%   category should be 'light', 'material', etc.
%   type should be 'area', 'matte', etc.
%   propertyNames should should be {'intensity', 'diffuseReflectance', ...}
%   propertyValues should should be {'D65.spd, '255 0 0', ...}
%   valueTypes should be {'spectrum', 'rgb', ...}
function description = BuildDescription(category, type, propertyNames, propertyValues, valueTypes)
properties = struct( ...
    'propertyName', propertyNames, ...
    'propertyValue', propertyValues, ...
    'valueType', valueTypes);

description = struct( ...
    'category', category, ...
    'type', type, ...
    'properties', properties);