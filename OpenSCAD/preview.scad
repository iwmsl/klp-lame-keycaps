// Preview: one column of the finished set (Corne v4 Mini, 19 mm pitch).
// The tilted rows meet the home row at the same height.
dir = "STL/MX Stem + MX Size/";
p   = "MX_Stem_MX_Size_Angular_";
for (i=[-1:1]) {
  translate([i*19,  19, 0]) import(str(dir,p,"Normal_Tilted.stl"));
  translate([i*19,   0, 0]) import(str(dir,p, i==0 ? "Normal_Homing.stl" : "Normal.stl"));
  translate([i*19, -19, 0]) rotate([0,0,180]) import(str(dir,p,"Normal_Tilted.stl"));
}
translate([9.5, -40, 0]) import(str(dir,p,"1.5U_Normal.stl"));
translate([-19, -40, 0]) import(str(dir,p,"Normal.stl"));
