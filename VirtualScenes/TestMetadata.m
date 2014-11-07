%% Test writing and reading metadata for a few models.

clear
clc

%% IndoorPlant base scene
modelName = 'IndoorPlant';
objectBox = [-6 2; -2 2; 0 6];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'IndoorPlant.dae');
materialIds = GetSceneMaterialIds(modelPath);
lightIds = { ...
    'CeilingLight-mesh', ...
    'HighRearLight-mesh', ...
    'LowRearLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Warehouse base scene
modelName = 'Warehouse';
objectBox = [-12 -2; -3 6; 0 3];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'Warehouse.dae');
materialIds = GetSceneMaterialIds(modelPath);
lightIds = { ...
    'Sun-mesh', ...
    'Sky-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% CheckerBoard base scene
modelName = 'CheckerBoard';
objectBox = [-3 3; -3 3; 1 3];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'CheckerBoard.dae');
materialIds = GetSceneMaterialIds(modelPath);
lightIds = { ...
    'TopLeftLight-mesh', ...
    'RightLight-mesh', ...
    'BottomLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Barrel object
modelName = 'Barrel';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Barrel.dae');
materialIds = GetSceneMaterialIds(modelPath);
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% ChampagneBottle object
modelName = 'ChampagneBottle';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'ChampagneBottle.dae');
materialIds = GetSceneMaterialIds(modelPath);
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% RingToy object
modelName = 'RingToy';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'RingToy.dae');
materialIds = GetSceneMaterialIds(modelPath);
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Xylophone object
modelName = 'Xylophone';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Xylophone.dae');
materialIds = GetSceneMaterialIds(modelPath);
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Blobbie object
modelName = 'Blobbie';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Blobbie.dae');
materialIds = GetSceneMaterialIds(modelPath);
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Camera Flash object
modelName = 'CameraFlash';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'CameraFlash.dae');
materialIds = GetSceneMaterialIds(modelPath);
lightIds = { ...
    'Flash-mesh', ...
    };
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

