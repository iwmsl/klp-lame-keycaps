// Corne v4 Mini (3x5+3 split) — keycap arrangement preview.
// Keycaps only, laid out roughly as they'd sit on the board: a sketch
// for judging how the caps read together, not the board's placement
// data. Requires the MX Stem + MX Tight Size STLs (run build.sh first).

dir    = "STL/MX Stem + MX Tight Size/";
prefix = "MX_Stem_MX_Tight_Size_Angular_";

pitch = 19.05; // c4mtb key spacing, both axes
gap   = 40;    // between the two halves (inner column to inner column)

// Columns from inner-index (0, nearest center) out to pinky (4).
// Downward stagger of each column (mm), classic Corne finger stagger.
stagger = [9, 4, 0, 1, 5];

module cap(name) import(str(dir, prefix, name, ".stl"));

// One hand: inner-index column at local x = 0, columns march left,
// thumb cluster fanning below toward the center.
module hand() {
    for (j = [0 : 4]) {
        x = -j * pitch;
        s = stagger[j];
        // top & bottom rows: tilted, the bottom one turned around so
        // both rake away from the home row
        translate([x, pitch - s, 0]) cap("Normal_Tilted");
        translate([x, -pitch - s, 0]) rotate([0, 0, 180]) cap("Normal_Tilted");
        // home row: normal, homing bump on the index home key
        translate([x, -s, 0]) cap(j == 1 ? "Normal_Homing" : "Normal");
    }
    // thumb cluster: 1.5U innermost, then two 1U keys fanning outward
    translate([3, -34, 0]) rotate([0, 0, 12]) cap("1.5U_Normal");
    translate([-16, -40, 0]) rotate([0, 0, 27]) cap("Normal");
    translate([-33, -48, 0]) rotate([0, 0, 42]) cap("Normal");
}

// Left half (extends left of center) + right half (mirrored).
translate([-gap / 2, 0, 0]) hand();
translate([ gap / 2, 0, 0]) mirror([1, 0, 0]) hand();
