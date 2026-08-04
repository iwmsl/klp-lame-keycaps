// =============================================================
// KLP Lamé Angular — low-profile faceted remix of KLP Lamé
// -------------------------------------------------------------
// Angular keycaps with flat, crisp trapezoid sides that keep the
// signature dished top of KLP Lamé (concave scoop rising toward
// all four edges, rolling off over the front/back walls), at a
// slightly reduced overall height. Stem and cavity dimensions are
// taken from the original KLP Lamé STLs, so switch fit is identical
// to the proven originals.
//
// Designed for FDM printing (tested target: Bambu Lab A1 mini,
// 0.4 mm nozzle) and resin printing.
//
// Original KLP Lamé by braindefender:
//   https://github.com/braindefender/KLP-Lame-Keycaps
// License: same as the original repository (see /LICENSE).
// =============================================================

/* [Main] */
// Switch stem type
stem_type = "choc"; // [choc, mx]
// Keycap footprint size
size_type = "choc"; // [choc, mx]
// Key width in units (1.5U is stretched horizontally, stem centered)
key_units = 1; // [1:0.25:2]
// Key depth in units (stretched front-to-back, stem centered)
key_units_y = 1; // [1:0.25:2]
// Top profile variant. normal = dished flat cap; tilted = the same cap
// tilted up toward the back for the rows above/below the home row.
variant = "normal"; // [normal, tilted]
// Homing feature on the touch surface
homing = "none"; // [none, bar, dots]

/* [Body] */
// Sidewall style — how the cap goes from its full-size bottom rim up
// to the touch surface. Drives how big the visible gap between caps is.
//   wide    : straight taper, classic sculpted look (biggest gap)
//   chiclet : near-vertical walls, large top, LAK/laptop-like (tightest)
//   skirt   : vertical skirt at the bottom, then taper above
side_style = "chiclet"; // [chiclet, wide, skirt]
// Height of the crown (top edge of the cap) above the bottom rim
crown_height = 5.0;
// wide: how much each side face leans in from bottom to top (per side)
top_inset = 2.0;
// chiclet: side inset per side (small = walls almost vertical)
chiclet_inset = 0.75;
// chiclet: rounding of the top perimeter edge (larger, softer bevel)
chiclet_edge_round = 1.3;
// skirt: height of the vertical full-size skirt at the bottom
skirt_height = 1.5;
// skirt: side inset per side above the skirt
skirt_inset = 1.5;
// Inset of the rear top edge (mm). Negative keeps it equal to the side
// inset, i.e. a front/back symmetric cap — the default. Setting it to 0
// stands the rear wall vertical, which was tried as a print fix but
// barely helps: the top rounding and corner radii still flare, so a
// rear-down cap keeps ~243 mm2 of outward-leaning surface spread over
// its whole height (vs ~258 mm2 symmetric). Print upright instead.
rear_inset = -1;
// Shape of the four vertical corners. "round" is a true radius, whose
// tangent runs ~90 deg where it meets a wall — printed on that wall it
// flares almost horizontally out of the first layers and curls into
// the nozzle. "chamfer" cuts the same corner at 45 deg, so nothing on
// the cap ever overhangs by more than 45 deg.
corner_style = "chamfer"; // [chamfer, round]
// Corner radius / chamfer of the bottom footprint (vertical corners)
corner_radius = 1.9;
// Corner radius of the top face (vertical corners)
top_corner_radius = 1.9;
// Rounding of the top perimeter edge (top face -> side wall)
top_edge_round = 1.0;
// Chamfer of the bottom perimeter edge (side wall -> rim). Zero by
// default: the chamfer only ever relieved elephant foot for a
// bottom-down print, and it is actively harmful for the tipped print
// the set is meant for — a 45 deg chamfer tipped ~45 deg turns into a
// dead-horizontal 8.8 mm2 shelf on the outside of the cap.
bottom_edge_round = 0;

/* [Top surface] */
// Depth of the dished scoop at the cap center, below the crown
dish_depth = 1.15;
// Radius of the spherical dish (smaller = deeper/rounder scoop)
dish_radius = 28;
// Tilt angle for tilted variants. Gentle enough that the tilted rows
// read as a continuation of the home row, but with a clear rake. With
// the vertical rear wall, any tilt >= 0 also means the crown faces
// upward when the cap is printed rear-face-down.
tilt_angle = 10;
// Crown height at the front footprint edge for tilted variants. Setting
// this to crown_height makes the tilted cap's near edge meet the home
// row at the same height — a seamless bowl across the three rows.
tilt_front_height = 5.0;

/* [Shell] */
// Wall thickness at the bottom rim
wall_bottom = 1.0;
// Cavity inset per side at the ceiling (controls wall taper)
cavity_top_inset = 1.7;
// Chamfer along the inner bottom edge (print stability, as in v1.1)
inner_chamfer = 0.5;

/* [Homing] */
// Raised bar: length
bar_length = 5.2;
// Raised bar: width
bar_width = 0.9;
// Raised bar / dots: height proud of the surface
homing_height = 0.3;
// Homing feature position, forward of center
homing_offset = 2.3;
// Dots: radius
dot_radius = 0.45;
// Dots: spacing from center
dot_spacing = 2.2;

/* [Hidden] */
$fa = 2;
$fs = 0.3;
eps = 0.01;

// ------------------------------------------------------------------
// Derived dimensions
// ------------------------------------------------------------------
// Footprints measured from the original STLs:
//   choc size: 17.5 x 16.5 mm, mx size: 18 x 18 mm
//   1.5U choc: 26.5 x 16.5 mm (= 17.5 + 0.5 * 18 mm pitch), as in the
//   original 1.5U models. Wider caps grow along X, stem stays centered.
// choc size: 17.5 x 16.5 on 18/17 mm pitch
// mx size  : 18 x 18 on 19 mm pitch (1 mm gap between caps at the rim)
base_w = size_type == "choc" ? 17.5 : 18.0;
base_d = size_type == "choc" ? 16.5 : 18.0;
pitch_x = size_type == "choc" ? 18.0 : 19.0;
pitch_y = size_type == "choc" ? 17.0 : 19.0;
cap_w = base_w + (key_units   - 1) * pitch_x;
cap_d = base_d + (key_units_y - 1) * pitch_y;

// The dish is stretched with the cap so bigger caps keep the same
// scoop character (matches the original 1.5U models).
dish_sx = cap_w / base_w;
dish_sy = cap_d / base_d;

// Cavity depth (bottom rim -> ceiling), from the originals:
//   choc stem: 2.05 mm, mx stem: 2.0 mm
cavity_depth = stem_type == "choc" ? 2.05 : 2.0;

is_tilted = variant == "tilted";

// Effective sidewall inset and top edge rounding for the chosen style
side_inset = side_style == "chiclet" ? chiclet_inset
           : side_style == "skirt"   ? skirt_inset
           :                           top_inset;
top_edge_r = side_style == "chiclet" ? chiclet_edge_round : top_edge_round;

// Top face: symmetric side insets, but an independent (default zero)
// rear inset, so the rear wall stands vertical for printing. The face
// centre shifts rearward by top_off_y; the dish and homing features
// follow it so the top still reads as centred.
rear_in = rear_inset < 0 ? side_inset : rear_inset;
top_w = cap_w - 2 * side_inset;
top_d = cap_d - side_inset - rear_in;
top_off_y = (side_inset - rear_in) / 2;

// Sagitta of a circle: rise of the arc at horizontal offset w from apex
function sag(r, w) = r - sqrt(r * r - w * w);

// Local top-surface height (z below the crown, negative) on the cap
// centerline at local y. Used to seat homing features.
function surf_z(y) = -(dish_depth - sag(dish_radius, y));

// ------------------------------------------------------------------
// 2D / plate helpers
// ------------------------------------------------------------------
module rrect(w, d, r) {
    rr = max(min(r, w / 2 - eps, d / 2 - eps), 0.05);
    if (corner_style == "chamfer")
        offset(delta = rr, chamfer = true)
            square([w - 2 * rr, d - 2 * rr], center = true);
    else
        offset(r = rr) square([w - 2 * rr, d - 2 * rr], center = true);
}

module plate(w, d, r) {
    linear_extrude(eps) rrect(w, d, r);
}

tilt_front_h = tilt_front_height;
crown_h = crown_height;

// Places children from top-plane local coordinates (origin at cap
// center projected on the crown, z = 0 at the crown) into global
// coordinates. Tilted variants hinge about the front footprint edge.
module top_frame() {
    if (is_tilted)
        translate([0, -cap_d / 2, tilt_front_h])
            rotate([tilt_angle, 0, 0])
                translate([0, cap_d / 2, 0])
                    children();
    else
        translate([0, 0, crown_h]) children();
}

// ------------------------------------------------------------------
// Cap body — a rounded box: flat tapered sides, rounded vertical
// corners, softly rounded top and bottom perimeter edges.
// ------------------------------------------------------------------
module cap_body() {
    hull() {
        // rounded bottom edge
        plate(cap_w - 2 * bottom_edge_round, cap_d - 2 * bottom_edge_round,
              max(corner_radius - bottom_edge_round, 0.1));
        translate([0, 0, bottom_edge_round])
            plate(cap_w, cap_d, corner_radius);
        // vertical full-size skirt before the taper starts
        if (side_style == "skirt")
            translate([0, 0, skirt_height])
                plate(cap_w, cap_d, corner_radius);
        // flat tapered sides up to just below the crown, then rounded
        // top edge into the (inset) crown face
        top_frame() translate([0, top_off_y, -top_edge_r])
            plate(top_w, top_d, top_corner_radius);
        top_frame() translate([0, top_off_y, 0])
            plate(top_w - 2 * top_edge_r, top_d - 2 * top_edge_r,
                  max(top_corner_radius - top_edge_r, 0.1));
    }
}

// Spherical dish cutter: lowest point sits `dish_depth` below the
// crown. Stretched along X for wide (1.5U+) caps.
module dish_sphere() {
    top_frame()
        translate([0, top_off_y, 0])
            scale([dish_sx, 1, 1])
                translate([0, 0, dish_radius - dish_depth])
                    sphere(r = dish_radius);
}

module cap_top() {
    difference() {
        cap_body();
        dish_sphere();
    }
}

// ------------------------------------------------------------------
// Homing features
// ------------------------------------------------------------------
module homing_features() {
    if (homing == "bar")
        top_frame()
            translate([0, top_off_y - homing_offset,
                       surf_z(-homing_offset) + homing_height - 1])
                linear_extrude(1)
                    rrect(bar_length, bar_width, bar_width / 2 - eps);
    if (homing == "dots")
        top_frame()
            for (dx = [-dot_spacing, 0, dot_spacing])
                translate([dx, top_off_y - homing_offset,
                           surf_z(-homing_offset) + homing_height - dot_radius])
                    sphere(r = dot_radius);
}

// ------------------------------------------------------------------
// Cavity
// ------------------------------------------------------------------
module cavity() {
    hull() {
        translate([0, 0, -eps])
            plate(cap_w - 2 * (wall_bottom - inner_chamfer),
                  cap_d - 2 * (wall_bottom - inner_chamfer), corner_radius);
        translate([0, 0, inner_chamfer])
            plate(cap_w - 2 * wall_bottom,
                  cap_d - 2 * wall_bottom, corner_radius);
        translate([0, 0, cavity_depth])
            plate(cap_w - 2 * cavity_top_inset,
                  cap_d - 2 * cavity_top_inset, corner_radius);
    }
}

// ------------------------------------------------------------------
// Stems (dimensions measured from the original KLP Lamé STLs)
// ------------------------------------------------------------------
// Choc: two legs 1.15 x 2.95 mm at x = +/-2.85, reaching 1.75 mm
// below the bottom rim, chamfered at the tip.
choc_leg_w = 1.15;
choc_leg_d = 2.95;
choc_leg_x = 2.85;
choc_leg_below = 1.75;
choc_tip_chamfer = 0.3;

module choc_stem() {
    for (sx = [-1, 1])
        translate([sx * choc_leg_x, 0, 0])
            hull() {
                translate([0, 0, -choc_leg_below])
                    plate(choc_leg_w - 2 * choc_tip_chamfer,
                          choc_leg_d - 2 * choc_tip_chamfer, 0.1);
                translate([0, 0, -choc_leg_below + choc_tip_chamfer])
                    plate(choc_leg_w, choc_leg_d, 0.1);
                // extend into the roof so the union is watertight
                translate([0, 0, cavity_depth + 0.6])
                    plate(choc_leg_w, choc_leg_d, 0.1);
            }
}

// MX: 5.5 mm boss reaching 1.3 mm below the rim, cross recess
// 4.10 x 1.30 (horizontal) / 1.20 x 4.10 (vertical), flush with the
// cavity ceiling, with an entry flare at the bottom.
mx_boss_d = 5.5;
mx_boss_below = 1.3;
mx_cross_len = 4.10;
mx_slot_h = 1.30;  // horizontal arm thickness (y)
mx_slot_v = 1.20;  // vertical arm thickness (x)
mx_flare = 0.35;

module mx_cross(extra) {
    square([mx_cross_len + 2 * extra, mx_slot_h + 2 * extra], center = true);
    square([mx_slot_v + 2 * extra, mx_cross_len + 2 * extra], center = true);
}

module mx_stem() {
    difference() {
        // extend into the roof so the union is watertight; the cross
        // recess still stops flush with the cavity ceiling as in the
        // original models
        translate([0, 0, -mx_boss_below])
            cylinder(d = mx_boss_d, h = mx_boss_below + cavity_depth + 0.6);
        // cross recess
        translate([0, 0, -mx_boss_below - eps])
            linear_extrude(mx_boss_below + cavity_depth + 2 * eps)
                mx_cross(0);
        // entry flare
        hull() {
            translate([0, 0, -mx_boss_below - eps])
                linear_extrude(eps) mx_cross(mx_flare);
            translate([0, 0, -mx_boss_below + 0.5])
                linear_extrude(eps) mx_cross(0);
        }
    }
}

// ------------------------------------------------------------------
// Assembly
// ------------------------------------------------------------------
module keycap() {
    union() {
        difference() {
            cap_top();
            cavity();
        }
        if (stem_type == "choc") choc_stem();
        if (stem_type == "mx") mx_stem();
        homing_features();
    }
}

keycap();
