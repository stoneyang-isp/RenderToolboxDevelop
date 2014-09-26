%% Here are some guidelines for taming wild Blender scenes.
%
% The overall goal is to clean up Blender files and export Collada files
% that are easy to work with in RenderToolbox3.
%
% Part one is remove Blender things that don't make sense for
% RenderToolbox3.  These are things like animations, constraints, and
% modifiers that can't survive the Collada export process or have no
% meaning for physycally based renderers.
%
% Part two is remodel things into a "tame" form so that our scripts know
% what to expect and how to modify scenes automatically.
%
% Part three is making a metadata "manifest" that our VirtualScenes scripts
% can find.
%
% The Blender work includes:
%   - All objects, meshes, and materials should use plain ASCII names.  Our
%   Collada parsing tools and renderers can't handle extended characters.
%   - All objects, meshes, and materials should use CamelCase names without
%   punctuation.  Names can have numbers at the end like MyThing01,
%   MyThing02.
%   - Each object should contain exactly one mesh.  The object and mesh
%   should have the same name.
%   - Each mesh should have exactly one material assigned.  The material
%   can have a different name from the mesh, so that materials can be
%   shared.
%   - Each "whole object" should have its own material assigned, to
%   facilitate analysis.  For example, two distinct objects that make up
%   one whole table should have the same material assigned.  But two
%   identical soda bottles located in different places should have distinct
%   materials assigned.
%   - All lights should be converted to meshes, which will later be
%   "blessed" as area lights.  Make sure the mesh normals face outwards,
%   towards the objects in the scene.
%   - Objects should not have Blender constraints on them.
%   - Objects should not have Blender modifiers on them.  These should be
%   removed, or "applied" to make the modifications part of the mesh data.
%   - Objects can't use Blender curves or Blender text.  Only meshes will
%   get exported properly.
%   - The camera object should be named "Camera"
%   - The camera object's Transform must have Scale = [1 1 1]
%   - The Blender file should not "pack" any external data like textures.
%   External data should be unpacked into separate files, and will be
%   ignored.
%
% Finally, export the Blender scene to a Collada (.dae) file.  In the lower
% left of the export dialog, choose Collada Options: Transformation Type
% TransRotLoc.  "TransRotLoc" gives RenderToolbox3 separate translation,
% rotation, and scale transformations to work with, instead of one combined
% 4x4 matrix.  Save the Blender and Collada files in the VitualScenes
% repository.
%
% The Metadata work includes:
%   - Determine the list of all material ids used in the Collada scene.
%   These should be the same as the names used in Blender, plus the suffix
%   "-material".
%   - Determine the list of all light ids used in the Collada scene.  These
%   should be the same as the names used in Blender, plus the suffix
%   "-mesh" (remember, all lights muse be modeled are meshes to be blessed
%   as area lights).
%   - Determine an approximate bounding volume where it makes sense to
%   insert objects into the scene.  This should be a
%   coordinate-axis-aligned box like [minX maxX minY maxY minZ maxZ]
%   - Write a metadata file for the new scene using WriteMetadata().  See
%   TestMetadata.m for examples.
%
