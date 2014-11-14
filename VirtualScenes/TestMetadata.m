%% Test writing and reading metadata for a few models.

clear
clc

%% IndoorPlant base scene
modelName = 'IndoorPlant';
objectBox = [-6 2; -2 2; 0 6];
lightBox = [-6 15; -15 2; 0 15];
lightExcludeBox = [-6 6; -12 2; 0 7];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'IndoorPlant.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'CeilingLight-mesh', ...
    'HighRearLight-mesh', ...
    'LowRearLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Warehouse base scene
modelName = 'Warehouse';
objectBox = [-12 -2; -3 6; 0 3];
lightBox = [-20 20; -20 20; 0 20];
lightExcludeBox = [-13 4; -7 7; 0 7];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'Warehouse.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'Sun-mesh', ...
    'Sky-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% CheckerBoard base scene
modelName = 'CheckerBoard';
objectBox = [-3 3; -3 3; 1 3];
lightBox = [-20 20; -20 20; 0 20];
lightExcludeBox = [-10 10; -10 10; 0 12];
modelPath = fullfile(VirtualScenesRoot(), 'BaseScenes', 'Models', 'CheckerBoard.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = { ...
    'TopLeftLight-mesh', ...
    'RightLight-mesh', ...
    'BottomLight-mesh', ...
    };
metadata = WriteMetadata(modelName, objectBox, lightBox, lightExcludeBox, materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Barrel object
modelName = 'Barrel';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Barrel.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% ChampagneBottle object
modelName = 'ChampagneBottle';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'ChampagneBottle.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% RingToy object
modelName = 'RingToy';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'RingToy.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Xylophone object
modelName = 'Xylophone';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Xylophone.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
metadata = WriteMetadata(modelName, [], [], [], materialIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Camera Flash object
modelName = 'CameraFlash';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'CameraFlash.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Big Ball light
modelName = 'BigBall';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'BigBall.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Snmall Ball light
modelName = 'SmallBall';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'SmallBall.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))

%% Panel light
modelName = 'Panel';
modelPath = fullfile(VirtualScenesRoot(), 'Objects', 'Models', 'Panel.dae');
materialIds = GetSceneElementIds(modelPath, '\w+-material$');
lightIds = GetSceneElementIds(modelPath, '\w+-mesh$');
metadata = WriteMetadata(modelName, [], [], [], materialIds, lightIds);
readMetadata = ReadMetadata(modelName);
assert(isequal(metadata, readMetadata))
