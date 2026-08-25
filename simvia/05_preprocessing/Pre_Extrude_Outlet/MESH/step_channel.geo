// Pre_Extrude_Outlet - backward-facing step, SHORT outlet section.
// gmsh step_channel.geo -3 -format msh41 -o step_channel.msh
//
// Inlet channel: -0.1 < x < 0, 0.05 < y < 0.1 (height h = 0.05)
// Step at x = 0 (height 0.05); downstream: 0 < x < 0.2 (only 4 step heights)

h  = 0.05;   // step height and inlet channel height
lc = 0.0025; // uniform cell size
th = 0.01;   // spanwise thickness, one cell

Point(1) = {-0.1, h,   0};
Point(2) = {0,    h,   0};
Point(3) = {0,    0,   0};
Point(4) = {0.2,  0,   0};
Point(5) = {0.2,  h,   0};
Point(6) = {0.2,  2*h, 0};
Point(7) = {0,    2*h, 0};
Point(8) = {-0.1, 2*h, 0};

Line(1)  = {1, 2};  // inlet-channel bottom wall (top of the step)
Line(2)  = {2, 7};  // x = 0, upper part (internal)
Line(3)  = {7, 8};  // top wall, upstream
Line(4)  = {8, 1};  // inlet
Line(5)  = {2, 3};  // step face (wall)
Line(6)  = {3, 4};  // bottom wall
Line(7)  = {4, 5};  // outlet, lower half
Line(8)  = {5, 2};  // y = h, downstream (internal)
Line(9)  = {5, 6};  // outlet, upper half
Line(10) = {6, 7};  // top wall, downstream

Curve Loop(1) = {1, 2, 3, 4};      Plane Surface(1) = {1};
Curve Loop(2) = {6, 7, 8, 5};      Plane Surface(2) = {2};
Curve Loop(3) = {-8, 9, 10, -2};   Plane Surface(3) = {3};

Transfinite Curve {1, 3}      = 0.1/lc + 1;
Transfinite Curve {6, 10, 8}  = 0.2/lc + 1;
Transfinite Curve {2, 4, 5, 7, 9} = h/lc + 1;
Transfinite Surface {1, 2, 3};
Recombine Surface {1, 2, 3};

o[] = Extrude {0, 0, th} { Surface{1, 2, 3}; Layers{1}; Recombine; };

// o[]: per input surface: top, volume, then one side per loop curve
// S1: o[0..5]; S2: o[6..11]; S3: o[12..17]
Physical Surface("Inlet")  = {o[5]};
Physical Surface("Outlet") = {o[9], o[15]};
Physical Surface("Wall")   = {o[2], o[4], o[8], o[11], o[16]};
Physical Surface("Sym")    = {1, 2, 3, o[0], o[6], o[12]};
Physical Volume("Fluid")   = {o[1], o[7], o[13]};
