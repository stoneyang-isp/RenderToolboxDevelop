# Script to generate blobby object
# 
# 6/24/2014  npc  Wrote it. 
# 10/31/2014 bsh  Isolated the blobbie, broke out command line args
# 11/7/2014  bsh  broke out more command line args

def generateScene(sceneParams):
    # Basic imports
    import sys
    import imp
    import bpy
    from math import floor, cos, sin, sqrt, atan2, pow
    from mathutils import Vector

    # Append the path to my custom Python scene toolbox to the Blender path
    sys.path.append(sceneParams.toolboxDirectory);
 
    # Import the custom scene toolbox module
    import SceneUtilsV1;
    imp.reload(SceneUtilsV1);
 
    # Initialize a sceneManager
    params = { 'name'               : sceneParams.sceneName,     # name of new scene
               'erasePreviousScene' : True,                      # erase old scene
               'sceneWidthInPixels' : 640,                       # pixels along the horizontal-dimension
               'sceneHeightInPixels': 480,                       # pixels along the vertical-dimension
               'sceneUnitScale'     : 1.0,                       # no particular unit scale
               'sceneGridSpacing'   : 1.0,                       # 1 unit between grid lines
               'sceneGridLinesNum'  : 20,                        # display 20 grid lines
              };
    scene = SceneUtilsV1.sceneManager(params);

    # Generate the blobbie material
    params = { 'name'              : sceneParams.objectName,
               'diffuse_shader'    : 'LAMBERT',
               'diffuse_intensity' : 0.5,
               'diffuse_color'     : Vector((0.7, 0.0, 0.1)),
               'specular_shader'   : 'WARDISO',
               'specular_intensity': 0.0,
               'specular_color'    : Vector((0.7, 0.0, 0.1)),
               'alpha'             : 1.0
             }; 
    blobbieMaterialType = scene.generateMaterialType(params);

    # Generate the blobbie
    print('Generating Blobbie. This may take a while ...')
    
    # Start with a sphere
    params = {'name'         : sceneParams.objectName,
              'scaling'      : Vector((1, 1, 1)),
              'rotation'     : Vector((0, 0, 0)),
              'location'     : Vector((0, 0, 0)),
              'subdivisions' : sceneParams.blobbieSubdivisions,
              'material'     : blobbieMaterialType,
              'flipNormal'   : False,
            };
    blobbieObject = scene.addSphere(params);
    blobbieObject.data.name = sceneParams.objectName;
	
	# Modify vertices to introduce bumps
    aX = cos(sceneParams.angleX) * sceneParams.frequencyX;
    bX = sin(sceneParams.angleX) * sceneParams.frequencyX;
    aY = cos(sceneParams.angleY) * sceneParams.frequencyY;
    bY = sin(sceneParams.angleY) * sceneParams.frequencyY;
    aZ = cos(sceneParams.angleZ) * sceneParams.frequencyZ;
    bZ = sin(sceneParams.angleZ) * sceneParams.frequencyZ;

    for f in blobbieObject.data.polygons:
        for idx in f.vertices:
        	oldX = blobbieObject.data.vertices[idx].co.x;
        	oldY = blobbieObject.data.vertices[idx].co.y;
        	oldZ = blobbieObject.data.vertices[idx].co.z;
        	blobbieObject.data.vertices[idx].co.x = oldX + sceneParams.gainX * sin(aX*oldY + bX*oldZ);
        	blobbieObject.data.vertices[idx].co.y = oldY + sceneParams.gainY * sin(aY*oldX + bY*oldZ);
        	blobbieObject.data.vertices[idx].co.z = oldZ + sceneParams.gainZ * sin(aZ*oldX + bZ*oldY);

    # Finally, export collada file
    scene.exportToColladaFile(sceneParams.exportsDirectory);

    print('All done !')

# ------- main() ------

import os
import sys
import argparse
from math import pi

# Parse args from the command line

# Get Python args from the command line.
# These should come after Blender arguments, separated with ' -- '
# For example, blender --background --python IsolatedBlobbie.py -- --sceneName myScene --objectName thing1
commandLine = ' '.join(sys.argv)
commandParts = commandLine.split(' -- ')
pythonArgs = '';
if len(commandParts) > 1:
    pythonArgs = commandParts[1].split(' ')

# Parse Blobbie arguments
parser = argparse.ArgumentParser()
parser.add_argument('--sceneName', default='IsolatedBlobbie');
parser.add_argument('--objectName', default='Blobbie');
parser.add_argument('--exportsDirectory', default=os.getcwd());
parser.add_argument('--toolboxDirectory', default=os.getcwd());
parser.add_argument('--blobbieSubdivisions', type=int, default=4);
parser.add_argument('--angleX', type=float, default=pi/3);
parser.add_argument('--angleY', type=float, default=-pi/5-pi/2);
parser.add_argument('--angleZ', type=float, default=-pi/6+pi/2);
parser.add_argument('--frequencyX', type=float, default=9);
parser.add_argument('--frequencyY', type=float, default=11);
parser.add_argument('--frequencyZ', type=float, default=-8);
parser.add_argument('--gainX', type=float, default=-9/1000);
parser.add_argument('--gainY', type=float, default=-8/1000);
parser.add_argument('--gainZ', type=float, default=-15/1000);

args = parser.parse_args(pythonArgs);

generateScene(args);
