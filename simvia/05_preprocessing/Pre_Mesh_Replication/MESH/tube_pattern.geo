// Pre_Mesh_Replication - ONE pattern: a tube crossing a channel segment.
// gmsh tube_pattern.geo -3 -format msh41 -o tube_pattern.msh
//
// The pattern is meshed once; the case reads it three times with
// translations of 0.1 m (cs_user_mesh_input) to build a 3-tube bank.

W  = 0.1;     // pattern width (x)
H  = 0.1;     // channel height (y)
D  = 0.03;    // tube diameter
lc  = 0.003;  // cell size, far field
lct = 0.0015; // cell size, on the tube
th = 0.005;   // spanwise thickness, one cell

Point(1) = {0, 0, 0, lc};
Point(2) = {W, 0, 0, lc};
Point(3) = {W, H, 0, lc};
Point(4) = {0, H, 0, lc};
Line(1) = {1, 2};   // bottom wall
Line(2) = {2, 3};   // right
Line(3) = {3, 4};   // top wall
Line(4) = {4, 1};   // left

// tube at the pattern centre
Point(5) = {W/2,       H/2,       0, lct};
Point(6) = {W/2 + D/2, H/2,       0, lct};
Point(7) = {W/2,       H/2 + D/2, 0, lct};
Point(8) = {W/2 - D/2, H/2,       0, lct};
Point(9) = {W/2,       H/2 - D/2, 0, lct};
Circle(5) = {6, 5, 7};
Circle(6) = {7, 5, 8};
Circle(7) = {8, 5, 9};
Circle(8) = {9, 5, 6};

Curve Loop(1) = {1, 2, 3, 4};
Curve Loop(2) = {5, 6, 7, 8};
Plane Surface(1) = {1, 2};
Recombine Surface {1};

o[] = Extrude {0, 0, th} { Surface{1}; Layers{1}; Recombine; };

// o[]: top, volume, then one side per loop curve (outer 4, then tube 4)
Physical Surface("Left")  = {o[5]};
Physical Surface("Right") = {o[3]};
Physical Surface("Walls") = {o[2], o[4]};
Physical Surface("Tube")  = {o[6], o[7], o[8], o[9]};
Physical Surface("Sym")   = {1, o[0]};
Physical Volume("Fluid")  = {o[1]};
