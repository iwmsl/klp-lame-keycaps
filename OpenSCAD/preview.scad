// Preview: one column of the finished set (Corne v4 Mini, 19.05 mm
// pitch). The tilted rows meet the home row at the same height, then
// rake away from it — up at the back on the top row, up at the front on
// the bottom one, so the three rows read as one shallow bowl.
dir = "STL/MX Stem + MX Tight Size/";
p   = "MX_Stem_MX_Tight_Size_Angular_";
pitch = 19.05;
for (i=[-1:1]) {
  translate([i*pitch,  pitch, 0]) import(str(dir,p,"Normal_Tilted.stl"));
  translate([i*pitch,      0, 0]) import(str(dir,p, i==0 ? "Normal_Homing.stl" : "Normal.stl"));
  translate([i*pitch, -pitch, 0]) rotate([0,0,180]) import(str(dir,p,"Normal_Tilted.stl"));
}
translate([9.5, -40, 0]) import(str(dir,p,"1.5U_Normal.stl"));
translate([-pitch, -40, 0]) import(str(dir,p,"Normal.stl"));
