%% Inputs:
% - list of base scene metadatas (.dat path, bounding volume, ids?)
% - list of inserted object metadatas (same stuff?)
% - number of objects to insert per base scene
% - list of reflectances and materials to apply to objects (text? struct?)
% - list of illuminants to apply to scene lights

%% Outputs:
% - multiple recipes:
%   - mappings file specifies reflectance and material for each inserted
%   object, base scene object, spectrum for each illuminant
%   - conditions file specifies .dat path and position of each object
%   - pixel mask with 0 for base scene and i for ith inserted object
%   - sRGB image
% - struct of handy metadata to describe each recipe:
%   - chosen base scene metadata
%   - material, reflectance, illuminant for each base scene object
%   - chosen object metadatas
%   - material, reflectance for each chosen object
%   - inserted coordinates for each chosen object
%   - pixel mask for each chosen object


%% Utilities:
% - read and write scene/object metadata
% - generate mappings text for base scene and inserted and objects
% - generate mappings text for base scene illuminants
% - generate conditions text for objects

%% For each recipe:
% - conditions file just communicates with remodeler: files and positions
% - mappings file is hard-coded with materials, reflectances, illuminants
% - additional handy outputs in renderings or imgaes folder
