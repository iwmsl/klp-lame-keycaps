// Preview assembly for KLP Lamé Angular.
// Imports the built Choc Stem + Choc Size STLs (run build.sh first)
// and lays them out roughly like the reference photos.

pitch = 20;
dir = "STL/Choc Stem + Choc Size/";
prefix = "Choc_Stem_Choc_Size_Angular_";

back = ["Normal", "Thumb", "Saddle", "Normal_Tilted"];
front = ["Normal_Homing", "Saddle_Homing", "Saddle_Tilted"];

for (i = [0 : len(back) - 1])
    translate([(i - (len(back) - 1) / 2) * pitch, pitch / 2, 0])
        import(str(dir, prefix, back[i], ".stl"));

for (i = [0 : len(front) - 1])
    translate([(i - (len(front) - 1) / 2) * pitch, -pitch / 2, 0])
        import(str(dir, prefix, front[i], ".stl"));
