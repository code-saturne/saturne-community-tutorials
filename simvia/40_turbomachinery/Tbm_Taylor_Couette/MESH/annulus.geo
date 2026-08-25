// Taylor-Couette annulus: inner radius 50 mm, outer radius 100 mm.
// Structured quadrangles, one layer extruded in z. No periodicity and no
// joining: the domain has exactly two lateral boundaries.
//
// Generate with:  gmsh -3 -format msh2 -o annulus.msh annulus.geo

R1 = 0.05;      // inner radius
R2 = 0.10;      // outer radius
depth = 0.01;   // spanwise thickness (one cell)

nr = 120;       // cells across the gap
nt = 60;        // cells per quadrant, so 240 around

Point(1) = { 0,   0, 0};
Point(2) = { R1,  0, 0};  Point(3) = {  0, R1, 0};
Point(4) = {-R1,  0, 0};  Point(5) = {  0,-R1, 0};
Point(6) = { R2,  0, 0};  Point(7) = {  0, R2, 0};
Point(8) = {-R2,  0, 0};  Point(9) = {  0,-R2, 0};

Circle(1) = {2,1,3};  Circle(2) = {3,1,4};
Circle(3) = {4,1,5};  Circle(4) = {5,1,2};
Circle(5) = {6,1,7};  Circle(6) = {7,1,8};
Circle(7) = {8,1,9};  Circle(8) = {9,1,6};

Line(9)  = {2,6};  Line(10) = {3,7};
Line(11) = {4,8};  Line(12) = {5,9};

Line Loop(21) = { 9, 5,-10,-1};  Plane Surface(31) = {21};
Line Loop(22) = {10, 6,-11,-2};  Plane Surface(32) = {22};
Line Loop(23) = {11, 7,-12,-3};  Plane Surface(33) = {23};
Line Loop(24) = {12, 8, -9,-4};  Plane Surface(34) = {24};

Transfinite Line {1,2,3,4,5,6,7,8} = nt+1;
Transfinite Line {9,10,11,12}      = nr+1;
Transfinite Surface {31,32,33,34};
Recombine Surface {31,32,33,34};

out[] = Extrude {0,0,depth} { Surface{31,32,33,34}; Layers{1}; Recombine; };

// Per extruded surface: [0] top, [1] volume, [2..] laterals in curve-loop order.
Physical Volume ("FLUID",  1)   = {out[1],  out[7],  out[13], out[19]};
Physical Surface("OUTER",  200) = {out[3],  out[9],  out[15], out[21]};
Physical Surface("INNER",  100) = {out[5],  out[11], out[17], out[23]};
Physical Surface("SYM_Z0", 600) = {31, 32, 33, 34};
Physical Surface("SYM_Z1", 601) = {out[0],  out[6],  out[12], out[18]};

Mesh 3;
