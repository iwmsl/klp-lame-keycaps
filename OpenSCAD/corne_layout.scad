// Corne v4 Mini (3x5+3 split) — keycap arrangement preview.
// Keycaps only, laid out as they'd sit on the board. Requires the
// MX Stem + Choc Size angular STLs (run build.sh first).

dir    = "STL/MX Stem + Choc Size/";
prefix = "MX_Stem_Choc_Size_Angular_";

pitch_x = 18;   // choc-size horizontal spacing
pitch_y = 17;   // choc-size vertical spacing
gap     = 40;   // gap between the two halves (inner column to inner column)

// Columns from inner-index (0, nearest center) out to pinky (4).
// Downward stagger of each column (mm), classic Corne finger stagger.
stagger = [9, 4, 0, 1, 5];

module cap(name) import(str(dir, prefix, name, ".stl"));

// One hand: inner-index column at local x = 0, columns march left,
// thumb cluster fanning below toward the center.
module hand() {
    for (j = [0 : 4]) {
        x = -j * pitch_x;
        s = stagger[j];
        // top & bottom rows: tilted (bottom rotated 180 to slope forward)
        translate([x, pitch_y - s, 0]) cap("Normal_Tilted");
        translate([x, -pitch_y - s, 0]) rotate([0, 0, 180]) cap("Normal_Tilted");
        // home row: normal, homing bump on the index home key
        translate([x, -s, 0]) cap(j == 1 ? "Normal_Homing" : "Normal");
    }
    // thumb cluster: 3 keys fanning down from below the inner columns
    thumbs = [[3, -34, 12], [-14, -40, 27], [-30, -48, 42]];
    for (t = thumbs)
        translate([t[0], t[1], 0]) rotate([0, 0, t[2]]) cap("Thumb");
}

// Left half (extends left of center) + right half (mirrored).
translate([-gap / 2, 0, 0]) hand();
translate([ gap / 2, 0, 0]) mirror([1, 0, 0]) hand();
