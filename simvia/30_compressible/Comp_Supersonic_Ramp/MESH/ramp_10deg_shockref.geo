// Supersonic compression ramp, 10 degrees, Mach 2 tutorial.
// Variant with LOCAL REFINEMENT along the theoretical oblique shock:
// the shock position is known analytically (beta = 39.31 deg from the
// corner at x = 0.8), so a gmsh size field concentrates the resolution
// in a band around that ray (cell size 2.5 mm in the band, 10 mm far away).
// Unstructured quads (recombined), extruded one layer in z.
//
// Generate with:  gmsh -3 -format msh2 -o ramp_10deg_shockref.msh ramp_10deg_shockref.geo

SetFactory("OpenCASCADE");

L_inlet  = 0.8;
L_ramp   = 1.0;
alpha    = 10*Pi/180;
H        = 1.0;
L_total  = L_inlet + L_ramp;
depth    = 0.1;

lc_bg    = 0.010;   // background cell size
lc_shock = 0.0025;  // cell size in the shock band
beta     = 0.6861;  // theoretical shock angle [rad] (39.31 deg)

// Points
Point(1) = {0.0,      0.0,               0, lc_bg};
Point(2) = {L_inlet,  0.0,               0, lc_bg};
Point(3) = {L_total,  L_ramp*Tan(alpha), 0, lc_bg};
Point(4) = {L_total,  H,                 0, lc_bg};
Point(5) = {0.0,      H,                 0, lc_bg};
Point(6) = {L_inlet,  H,                 0, lc_bg};

// Lines
Line(1) = {1,2};    // upstream plate
Line(2) = {2,3};    // 10 deg ramp
Line(3) = {3,4};    // outlet
Line(5) = {5,1};    // inlet
Line(6) = {2,6};    // vertical interface at the corner
Line(7) = {6,5};    // top, above the plate
Line(8) = {4,6};    // top, above the ramp

Line Loop(10) = {1, 6, 7, 5};   Plane Surface(11) = {10};
Line Loop(20) = {2, 3, 8, -6};  Plane Surface(21) = {20};

// Size field: distance to the theoretical shock RAY from the corner
// (normal distance to the line for points past the corner, distance to
// the corner itself upstream of it), linear growth back to lc_bg.
Field[1] = MathEval;
Field[1].F = "min(0.010, 0.0025 + 0.075*sqrt((sin(0.6861)*(x-0.8) - cos(0.6861)*y)^2 + (min(cos(0.6861)*(x-0.8) + sin(0.6861)*y, 0))^2))";
Background Field = 1;

Mesh.MeshSizeExtendFromBoundary = 0;
Mesh.MeshSizeFromPoints = 0;
Mesh.Algorithm = 6;          // Frontal-Delaunay
Mesh.RecombineAll = 1;
Mesh.RecombinationAlgorithm = 1;  // Blossom

// Extrusion (one layer in z)
out[] = Extrude {0, 0, depth} {
  Surface{11,21};
  Layers{1};
  Recombine;
};

Physical Volume("FLUID", 1)        = {out[1], out[7]};
Physical Surface("INLET", 100)     = {out[5]};
Physical Surface("OUTLET", 200)    = {out[9]};
Physical Surface("WALL", 500)      = {out[2], out[8]};
Physical Surface("UP", 300)        = {out[4], out[10]};
Physical Surface("SYM_Z0", 600)    = {11, 21};
Physical Surface("SYM_Z1", 601)    = {out[0], out[6]};

Mesh 3;
