// Gmsh project created on Fri Nov 07 07:04:52 2020
SetFactory("OpenCASCADE");

Mesh.CharacteristicLengthExtendFromBoundary = 0;
Mesh.CharacteristicLengthFromPoints = 0;
Mesh.CharacteristicLengthFromCurvature = 0;

//////////////////////
///// Parameters /////
//////////////////////

// 0.1 m = 10 cm
lx = 0.1; // Object Length
ly = 0.1; // Object Width
lz = 0.1; // Object Height

// 0.3 m = 30 cm
Lx = 0.3; // Domain Length
Ly = 0.3; // Domain Width
Lz = 0.3; // Domain Height

/////////////////////
///// Variables /////
/////////////////////

// Object Half-Sizes
ox = 0.5 * lx;
oy = 0.5 * ly;
oz = 0.5 * lz;

// Domain Half-Sizes
dx = 0.5 * Lx;
dy = 0.5 * Ly;
dz = 0.5 * Lz;

i = 1; // Element Counter
j = 1; // Field Counter

infinite = 1e24;

//////////////////////
////// Elements //////
//////////////////////

Box(i) = {-dx, -dy, -dz, Lx, Ly, Lz}; i += 1; // External Cube = Domain
Box(i) = {-ox, -oy, -oz, lx, ly, lz}; i += 1; // Internal Cube = Object

// The external domain is the difference between the cubes
// Also deletes the external cube
BooleanDifference(i) = { Volume{i - 2}; Delete; }{ Volume{i - 1}; }; i += 1;

// Defines the physical entity so it only saves the 3D elements
Physical Volume (i) = {i - 1, i - 2} ; i += 1;

/////////////////////
///// Mesh Size /////
/////////////////////

Field[j] = Box;
Field[j].VIn = infinite;
Field[j].VOut = infinite;
Field[j].XMin = -ox;
Field[j].XMax = ox;
Field[j].YMin = -oy;
Field[j].YMax = oy;
Field[j].ZMin = -oz;
Field[j].ZMax = oz;
Background Field = j; j += 1;
