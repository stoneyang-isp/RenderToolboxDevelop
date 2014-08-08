%% Test writing and reading metadata for a few models.

clear
clc

%% IndoorPlant base scene
modelName = 'IndoorPlant';
boundingVolume = [-6 2; -2 2; 0 6];
materialIds = { ...
    'BaseBoard-material', ...
    'Floor-material', ...
    'Leaves-material', ...
    'Lights-material', ...
    'Pot-material', ...
    'Rocks-material', ...
    'Wall-material', ...
    };
lightIds = { ...
    'CeilingLight-mesh', ...
    'HighRearLight-mesh', ...
    'LowRearLight-mesh', ...
    };
metadata = WriteMetadata(modelName, boundingVolume, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Barrel object
modelName = 'Barrel';
metadata = WriteMetadata(modelName);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% ChampagneBottle object
modelName = 'ChampagneBottle';
metadata = WriteMetadata(modelName);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% RingToy object
modelName = 'RingToy';
metadata = WriteMetadata(modelName);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Xylophone object
modelName = 'Xylophone';
metadata = WriteMetadata(modelName);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))
