// Pre_Face_Joining - upstream block: 0 < x < 0.5, 130 cells across the height.
// gmsh channel_upstream.geo -3 -format msh41 -o channel_upstream.msh

H = 0.1;    // channel height [m]
L = 0.5;    // block length [m]
nx = 65;    // axial cells
ny = 130;   // cells across the height (downstream block: 200)
th = 0.01;  // spanwise thickness, one cell

Point(1) = {0, 0, 0};
Point(2) = {L, 0, 0};
Point(3) = {L, H, 0};
Point(4) = {0, H, 0};
Line(1) = {1, 2};   // bottom
Line(2) = {2, 3};   // right (joining interface)
Line(3) = {3, 4};   // top
Line(4) = {4, 1};   // left (inlet)
Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};
Transfinite Curve {1, 3} = nx + 1;
Transfinite Curve {2, 4} = ny + 1;
Transfinite Surface {1};
Recombine Surface {1};

out[] = Extrude {0, 0, th} { Surface{1}; Layers{1}; Recombine; };

Physical Surface("Wall")   = {out[2], out[4]};
Physical Surface("JoinA")  = {out[3]};
Physical Surface("Inlet")  = {out[5]};
Physical Surface("Sym")    = {1, out[0]};
Physical Volume("Fluid")   = {out[1]};
