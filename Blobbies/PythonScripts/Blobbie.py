# Script to generate blobby object
# 
# 6/24/2014  npc  Wrote it. 

def generateScene(sceneParams): 
    # Basic imports
    import sys
    import imp
    import bpy
    from math import pi, floor, cos, sin, sqrt, atan2, pow
    from mathutils import Vector


    # Append the path to my custom Python scene toolbox to the Blender path
    sys.path.append(sceneParams['toolboxDirectory']);
 
    # Import the custom scene toolbox module
    import SceneUtilsV1;
    imp.reload(SceneUtilsV1);
 
    # Initialize a sceneManager
    params = { 'name'               : sceneParams['sceneName'],  # name of new scene
               'erasePreviousScene' : True,                      # erase old scene
               'sceneWidthInPixels' : 1024,                      # 1920 pixels along the horizontal-dimension
               'sceneHeightInPixels': 768,                       # 1200 pixels along the vertical-dimension
               'sceneUnitScale'     : 1.0/100.0,                 # set unit scale to 1.0 cm
               'sceneGridSpacing'   : 10.0/100.0,                # set the spacing between grid lines to 10 cm
               'sceneGridLinesNum'  : 20,                        # display 20 grid lines
              };

    scene = SceneUtilsV1.sceneManager(params);

    # Generate the materials
    # -the cylinder material
    params = { 'name'              : 'cylinderMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.5,
               'diffuse_color'     : Vector((0.0, 1.0, 0.0)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.1,
               'specular_color'    : Vector((0.0, 1.0, 0.0)),
               'alpha'             : 1.0
             }; 
    cylinderMaterialType = scene.generateMaterialType(params);

    # -the room material
    params = { 'name'              : 'roomMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.5,
               'diffuse_color'     : Vector((0.6, 0.6, 0.6)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((1.0, 1.0, 1.0)),
               'alpha'             : 1.0
             }; 
    roomMaterialType = scene.generateMaterialType(params);

    # -the backwall material
    params = { 'name'              : 'backWallMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.5,
               'diffuse_color'     : Vector((0.6, 0.6, 0.6)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((1.0, 1.0, 1.0)),
               'alpha'             : 1.0
             }; 
    backWallMaterialType = scene.generateMaterialType(params);

    # -the blobbie material
    params = { 'name'              : 'blobbieMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.5,
               'diffuse_color'     : Vector((0.7, 0.0, 0.1)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((0.7, 0.0, 0.1)),
               'alpha'             : 1.0
             }; 
    blobbieMaterialType = scene.generateMaterialType(params);

    # -the dark check material
    params = { 'name'              : 'darkCheckMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.1,
               'diffuse_color'     : Vector((0.5, 0.5, 0.5)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((0.5, 0.5, 0.5)),
               'alpha'             : 1.0
             }; 
    darkCheckMaterialType = scene.generateMaterialType(params);


    # -the light check material
    params = { 'name'              : 'lightCheckMaterial',
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.7,
               'diffuse_color'     : Vector((0.55, 0.55, 0.40)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((0.5, 0.5, 0.5)),
               'alpha'             : 1.0
             }; 
    lightCheckMaterialType = scene.generateMaterialType(params);

    checkBoardMaterialsList = [lightCheckMaterialType, darkCheckMaterialType];


    # Generate the area lamp model
    params = {'name'  : 'areaLampModel', 
              'color' : Vector((1,1,1)), 
              'fallOffDistance': 120,
              'width1': sceneParams['areaLampSize'],
              'width2': sceneParams['areaLampSize']
              }
    brightLight100 = scene.generateAreaLampType(params);
 
    # - Add the FRONT left area lamp
    lightElevation = 85;
    lightDistance = -15;   # negative distance is towards us, positive is away from us
    lightRotationInDeg = 90;
    theta  = lightRotationInDeg * (pi/180);
    lightHorizPosition = lightDistance * sin(theta);
    lightDepthPosition = lightDistance * cos(theta)+13;  # was -20

    leftAreaLampPosition = Vector((
                            lightHorizPosition,      # horizontal position (x-coord)
                            lightDepthPosition,      # depth position (y-coord)
                            lightElevation       	 # elevation (z-coord)
                           ));
    leftAreaLampLooksAt = Vector((
                             lightHorizPosition,      # horizontal position (x-coord)
                             lightDepthPosition,      # depth position (y-coord)
                             0       # elevation (z-coord)
                           ));

    params = {'name'     : 'frontLeftAreaLamp', 
              'model'    : brightLight100, 
              'showName' : True, 
              'location' : leftAreaLampPosition, 
              'lookAt'   : leftAreaLampLooksAt
          };
    frontLeftAreaLamp = scene.addLampObject(params);

    lightElevation = 85;
    lightDistance = -15;  # negative distance is towards us, positive is away from us
    lightRotationInDeg = 270;
    theta  = lightRotationInDeg * (pi/180)
    lightHorizPosition = lightDistance * sin(theta);
    lightDepthPosition = lightDistance * cos(theta)+13;

    # - Add the FRONT right area lamp
    rightAreaLampPosition = Vector((
                            lightHorizPosition,      # horizontal position (x-coord)
                            lightDepthPosition,      # depth position (y-coord)
                            lightElevation       	 # elevation (z-coord)
                           ));
    rightAreaLampLooksAt = Vector((
                              lightHorizPosition,      # horizontal position (x-coord)
                              lightDepthPosition,      # depth position (y-coord)
                              0       # elevation (z-coord)
                           ));

    params = {'name'     : 'frontRightAreaLamp', 
              'model'    : brightLight100, 
              'showName' : True, 
              'location' : rightAreaLampPosition, 
              'lookAt'   : rightAreaLampLooksAt
          };
    frontRightAreaLamp = scene.addLampObject(params);


    # - Add the REAR left area lamp
    lightElevation = 85;
    lightDistance = -55;   # negative distance is towards us, positive is away from us
    lightRotationInDeg = 90;
    theta  = lightRotationInDeg * (pi/180);
    lightHorizPosition = lightDistance * sin(theta);
    lightDepthPosition = lightDistance * cos(theta)-70;

    leftAreaLampPosition = Vector((
                            lightHorizPosition,      # horizontal position (x-coord)
                            lightDepthPosition,      # depth position (y-coord)
                            lightElevation         # elevation (z-coord)
                           ));
    leftAreaLampLooksAt = Vector((
                             lightHorizPosition,      # horizontal position (x-coord)
                             -90,      # depth position (y-coord)
                             0       # elevation (z-coord)
                           ));

    params = {'name'     : 'rearLeftAreaLamp', 
              'model'    : brightLight100, 
              'showName' : True, 
              'location' : leftAreaLampPosition, 
              'lookAt'   : leftAreaLampLooksAt
          };
    rearLeftAreaLamp = scene.addLampObject(params);

    lightElevation = 85;
    lightDistance = -55;  # negative distance is towards us, positive is away from us
    lightRotationInDeg = 270;
    theta  = lightRotationInDeg * (pi/180)
    lightHorizPosition = lightDistance * sin(theta);
    lightDepthPosition = lightDistance * cos(theta)-70;

    # - Add the REAR right area lamp
    rightAreaLampPosition = Vector((
                            lightHorizPosition,      # horizontal position (x-coord)
                            lightDepthPosition,      # depth position (y-coord)
                            lightElevation         # elevation (z-coord)
                           ));
    rightAreaLampLooksAt = Vector((
                              lightHorizPosition,      # horizontal position (x-coord)
                               -90,      # depth position (y-coord)
                              0       # elevation (z-coord)
                           ));

    params = {'name'     : 'rearRightAreaLamp', 
              'model'    : brightLight100, 
              'showName' : True, 
              'location' : rightAreaLampPosition, 
              'lookAt'   : rightAreaLampLooksAt
          };
    rearRightAreaLamp = scene.addLampObject(params);




    # Define our camera
    nearClipDistance = 0.1;
    farClipDistance  = 300;
    params = {'clipRange'            : Vector((nearClipDistance ,  farClipDistance)),
              'fieldOfViewInDegrees' : 36,   # horizontal FOV
              'drawSize'             : 2,    # camera wireframe size
             };
    cameraType = scene.generateCameraType(params);
 
    # Add the camera
    cameraElevation = 60;
    cameraDistance = -89;  # negative distance is towards us, positive is away from us
    cameraRotationInDeg = 0;
    theta  = cameraRotationInDeg * (pi/180)
    cameraHorizPosition = cameraDistance * sin(theta);
    cameraDepthPosition = cameraDistance * cos(theta);

    params = {  'name'          :'Camera', 
                'cameraType'    : cameraType,
                'location'      : Vector((cameraHorizPosition, cameraDepthPosition, cameraElevation)),     
                'lookAt'        : Vector((0, 0, 25)),
                'showName'      : True,
          };          
    mainCamera = scene.addCameraObject(params);


    # Define the checkerboard geometry
    boardThickness    = 2.5;
    boardHalfWidth    = 90;
    tilesAlongEachDim = 9;  # this must be odd number
    boardIsDimpled    = False;

    # compute checker size
    N                 = floor((tilesAlongEachDim-1)/2);
    deltaX            = boardHalfWidth/N;
    deltaY            = deltaX;

    # Add the checks of the checkerboard
    tileParams = {'name'    : '',
                  'scaling' : Vector((deltaX/2, deltaY/2, boardThickness/2)),
                  'rotation': Vector((0,0,0)), 
                  'location': Vector((0,0,0)),
                  'material': checkBoardMaterialsList[0]
                  };
 
    # Modify the checks if the board is dimpled
    if boardIsDimpled:
        sphereParams = { 'name'     : 'theSphere',
                         'scaling'  : Vector((1.0, 1.0, 1.0))*deltaX/2, 
                         'location' : Vector((0,0,0)),
                         'material' : checkBoardMaterialsList[0],
               };
        indentation = 0.09;

    print('Generating floor ...')
    for ix in list(range(-N,N+1)):
       for iy in list(range(-N,N+1)): 
            tileParams['name']     = 'floorTileAt({0:1d},{1:2d})'.format(ix,iy);
            tileParams['location'] =  Vector((ix*deltaX, iy*deltaY, boardThickness*0.5));
            tileParams['material'] =  checkBoardMaterialsList[(ix+iy)%2];
            theTile = scene.addCube(tileParams);
            if boardIsDimpled:
                theSphere          = scene.addSphere(sphereParams);
                theSphere.location = theTile.location + Vector((0,0,deltaX/2*(1-indentation)));
                scene.boreOut(theTile, theSphere, True);


    print('Generating enclosing room...')
    # Add the enclosing room
    roomLocation = Vector((0,0,0));
    params = {  'floorName'             : 'floor',
                'backWallName'          : 'backWall',
                'frontWallName'         : 'frontWall',
                'leftWallName'          : 'leftWall',
                'rightWallName'         : 'rightWall',
                'ceilingName'           : 'ceiling',
                'floorMaterialType'     : roomMaterialType,
                'backWallMaterialType'  : backWallMaterialType,
                'frontWallMaterialType' : roomMaterialType,
                'leftWallMaterialType'  : roomMaterialType,
                'rightWallMaterialType' : roomMaterialType,
                'ceilingMaterialType'   : roomMaterialType,
                'roomWidth'     : 180,
                'roomDepth'     : 180,
                'roomHeight'    : 100,
                'roomLocation'  : roomLocation
              }
    roomBox = scene.addRoom(params);

    print('Generating pedestal ...')
    # add pedestal (cylinder or cube)
    cylinderWidth  = 20.0;
    cylinderHeight = 2.0;
    params = { 'name'    : 'cylinderBase',
               'scaling' : Vector((cylinderWidth, cylinderWidth, cylinderHeight)),
               'rotation': Vector((0,0,0)), 
               'location': Vector((0, 20, cylinderHeight/2+boardThickness)),
               'material': cylinderMaterialType,
    }; 
    #theCylinder = scene.addCylinder(params);
    cylinderBase  = scene.addCube(params);

    print('Generating Blobbie. This may take a while ...')
    # make blobbie
    # start with a sphere
    params = {'name'         : 'blobbieObject',
              'scaling'      : Vector((16,16,16)),
              'rotation'     : Vector((0, 0, 0)),
              'location'     : Vector((0, 20, 18+cylinderHeight)) + roomLocation,
              'subdivisions' : sceneParams['blobbieSubdivisions'],
              'material'     : blobbieMaterialType,
              'flipNormal'   : False,
            };
    blobbieObject = scene.addSphere(params);
	
	  # modify vertices to introduce bumps
    angleX =  pi/3;
    angleY = -pi/5-pi/2;
    angleZ = -pi/6+pi/2;
    frequencyX = 9;
    frequencyY = 11;
    frequencyZ = -8;

    aX = cos(angleX) * frequencyX;
    bX = sin(angleX) * frequencyX;
    aY = cos(angleY) * frequencyY;
    bY = sin(angleY) * frequencyY;
    aZ = cos(angleZ) * frequencyZ;
    bZ = sin(angleZ) * frequencyZ;
    gainX = 9/1000;
    gainY =  8/1000;
    gainZ = 15/1000;

    for f in blobbieObject.data.polygons:
        for idx in f.vertices:
        	oldX = blobbieObject.data.vertices[idx].co.x;
        	oldY = blobbieObject.data.vertices[idx].co.y;
        	oldZ = blobbieObject.data.vertices[idx].co.z;
        	blobbieObject.data.vertices[idx].co.x = oldX + gainX * sin(aX*oldY + bX*oldZ);
        	blobbieObject.data.vertices[idx].co.y = oldY + gainY * sin(aY*oldX + bY*oldZ);
        	blobbieObject.data.vertices[idx].co.z = oldZ + gainZ * sin(aZ*oldX + bZ*oldY);

    # Rotate blobbie and its base
    zRotation = sceneParams['blobbieRotationDeg']/180*pi;
    blobbieObject.rotation_euler = [0,0, zRotation];
    cylinderBase.rotation_euler  = [0,0, zRotation];

    # Finally, export collada file
    scene.exportToColladaFile(sceneParams['exportsDirectory']);

    print('All done !')

# ------- main() ------

rootDirectory    = '/Users/Shared/Matlab/Toolboxes/RenderToolboxDevelop/Blobbies';
exportsDirectory = '{}/ColladaExports'.format(rootDirectory);
toolboxDirectory = '/Users/Shared/Matlab/Toolboxes/RenderToolbox3/Utilities/BlenderPython';

sceneParams = { 'sceneName'           : 'Blobbie_LargeAreaLamps',
                'exportsDirectory'    : exportsDirectory,
                'toolboxDirectory'    : toolboxDirectory,
                'blobbieSubdivisions' : 9,      # higher = better the quality / longer rendering time
                'blobbieRotationDeg'  : 45,     # rotate Blobbie by 33 degrees around the vertical axis
                'areaLampSize'        : 15      # 15 for large, 3 for small
             };

generateScene(sceneParams);
