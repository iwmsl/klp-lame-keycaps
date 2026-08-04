// =============================================================
// KLP Lamé Angular — low-profile faceted remix of KLP Lamé
// -------------------------------------------------------------
// Angular keycaps with flat, crisp trapezoid sides that keep the
// signature dished top of KLP Lamé (concave scoop rising toward
// all four edges, rolling off over the front/back walls), at a
// slightly reduced overall height. Stem and cavity dimensions are
// taken from the original KLP Lamé STLs, so switch fit is identical
// to the proven originals; where the inside is shaped for printing
// instead, it is only ever in the direction that adds clearance.
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
size_type = "choc"; // [choc, mx, mx_tight]
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
// Tilt angle for tilted variants. Enough rake that the row above and
// below the home row meet the fingertip square-on rather than reading
// as a slightly canted flat cap. Every degree here also raises the
// cap's rear edge by cap_d * sin(tilt) — at 15 deg on an 18.5 mm cap
// the rear crown lands 4.8 mm above the front one.
tilt_angle = 15;
// Crown height at the front footprint edge for tilted variants. Setting
// this to crown_height makes the tilted cap's near edge meet the home
// row at the same height — a seamless bowl across the three rows.
tilt_front_height = 5.0;

/* [Shell] */
// How much the cavity flares out per side between the rim and the
// ceiling, i.e. how much thinner the wall is where it meets the roof.
//
// The cavity used to narrow going up, which left its walls leaning
// 30 deg in over the void — tipped for printing, an 80 deg overhang
// across 32 mm2, by a wide margin the worst surface on the cap. Flaring
// it the other way tips those same walls away from the void, so they
// print as self-supporting faces instead. It costs nothing in fit: the
// switch housing narrows as it rises, so a cavity that widens on the way
// up only ever gains clearance.
cavity_flare = 0.25;
// Wall the flare must leave where the cavity meets the roof. The flare
// is taken out of whatever the wall can spare above this and no more, so
// a footprint with a thin rim simply ends up with a straight cavity
// rather than a wall the nozzle cannot lay down.
wall_min = 0.6;

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
// Footprints. The first two are measured from the original STLs; the
// third is those caps closed up onto the 19.05 mm pitch a Corne v4 Mini
// actually uses, which is where its half millimetre goes.
//   choc     : 17.5 x 16.5 on 18/17 mm pitch  (0.5 mm gap at the rim)
//   mx       : 18   x 18   on 19    mm pitch  (1.0 mm gap)
//   mx_tight : 18.5 x 18.5 on 19.05 mm pitch  (0.55 mm gap)
// Wider caps grow by whole pitches along X, so a 1.5U choc cap comes out
// 26.5 mm as in the original 1.5U models, and the stem stays centered.
base_w = size_type == "choc" ? 17.5 : size_type == "mx_tight" ? 18.5 : 18.0;
base_d = size_type == "choc" ? 16.5 : size_type == "mx_tight" ? 18.5 : 18.0;
pitch_x = size_type == "choc" ? 18.0 : size_type == "mx_tight" ? 19.05 : 19.0;
pitch_y = size_type == "choc" ? 17.0 : size_type == "mx_tight" ? 19.05 : 19.0;
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

// Top face: the same inset on all four sides. Standing the rear wall up
// on its own was tried as a print fix and dropped — it left the cap
// front/back asymmetric for a gain the tip angle gives for free.
top_w = cap_w - 2 * side_inset;
top_d = cap_d - 2 * side_inset;

// Wall at the rim. The cavity has to clear the same switch whatever the
// footprint, so mx_tight spends its extra 0.5 mm on the rim rather than
// on a wider cavity: 1.25 mm of wall leaves the same 16.0 mm mouth the
// 18 mm mx cap has, and the original 1.0 mm elsewhere.
wall_bottom = size_type == "mx_tight" ? 1.25 : 1.0;

// The outer wall leans in as it rises, so it eats into the wall by the
// time the cavity reaches its ceiling all on its own. Whatever is left
// above wall_min, up to cavity_flare, is what the cavity may flare by —
// which on the thin-rimmed footprints comes out at zero, leaving them a
// straight cavity instead of an unprintable wall.
outer_thin = side_inset * cavity_depth / (crown_height - top_edge_r);
flare = min(cavity_flare, max(0, wall_bottom - outer_thin - wall_min));
wall_top = wall_bottom - flare;

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
        // Rounded bottom edge. Skipped when the chamfer is off, so the
        // rim is a single sharp edge: two coincident slabs would leave a
        // hairline of dead-vertical wall there, and tipped for printing
        // a vertical face is the worst angle on the outer shell.
        if (bottom_edge_round > 0)
            plate(cap_w - 2 * bottom_edge_round,
                  cap_d - 2 * bottom_edge_round,
                  max(corner_radius - bottom_edge_round, 0.1));
        translate([0, 0, bottom_edge_round])
            plate(cap_w, cap_d, corner_radius);
        // vertical full-size skirt before the taper starts
        if (side_style == "skirt")
            translate([0, 0, skirt_height])
                plate(cap_w, cap_d, corner_radius);
        // flat tapered sides up to just below the crown, then rounded
        // top edge into the (inset) crown face
        top_frame() translate([0, 0, -top_edge_r])
            plate(top_w, top_d, top_corner_radius);
        top_frame()
            plate(top_w - 2 * top_edge_r, top_d - 2 * top_edge_r,
                  max(top_corner_radius - top_edge_r, 0.1));
    }
}

// Spherical dish cutter: lowest point sits `dish_depth` below the
// crown. Stretched along X for wide (1.5U+) caps.
module dish_sphere() {
    top_frame()
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
            translate([0, -homing_offset,
                       surf_z(-homing_offset) + homing_height - 1])
                linear_extrude(1)
                    rrect(bar_length, bar_width, bar_width / 2 - eps);
    if (homing == "dots")
        top_frame()
            for (dx = [-dot_spacing, 0, dot_spacing])
                translate([dx, -homing_offset,
                           surf_z(-homing_offset) + homing_height - dot_radius])
                    sphere(r = dot_radius);
}

// ------------------------------------------------------------------
// Cavity
// ------------------------------------------------------------------
// A single frustum flaring from the mouth to the ceiling. The old shape
// carried a chamfer at the inner bottom edge as well, but a hull can
// only ever be convex: put a chamfer under a flare and the hull spans
// straight past it. The flare is that chamfer, run the full height.
module cavity() {
    hull() {
        translate([0, 0, -eps])
            plate(cap_w - 2 * wall_bottom,
                  cap_d - 2 * wall_bottom, corner_radius);
        translate([0, 0, cavity_depth])
            plate(cap_w - 2 * wall_top,
                  cap_d - 2 * wall_top, corner_radius);
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
// Entry lead-in: the first mx_flare_depth of the recess is opened out
// by mx_flare on every side, as a straight counterbore. A cone would be
// the kinder lead-in for the switch stem, but its walls lean in over the
// void from all four sides at once, so tipped for printing it is the
// steepest thing on the cap — 80 deg where a straight bore is 48. An MX
// stem's tip is chamfered already and finds a 0.35 mm step on its own.
mx_flare = 0.35;
mx_flare_depth = 0.5;
// Diameter the boss loses between the rim and the roof. Only the part
// below the rim goes into the switch, so everything above it is free to
// draft, and a drafted pillar prints a few degrees shallower than a
// straight one when the cap is tipped.
mx_boss_taper = 0.45;

module mx_cross(extra) {
    square([mx_cross_len + 2 * extra, mx_slot_h + 2 * extra], center = true);
    square([mx_slot_v + 2 * extra, mx_cross_len + 2 * extra], center = true);
}

module mx_stem() {
    boss_up = cavity_depth + 0.6;
    difference() {
        union() {
            // full diameter where it enters the switch
            translate([0, 0, -mx_boss_below])
                cylinder(d = mx_boss_d, h = mx_boss_below);
            // drafted above the rim, extended into the roof so the
            // union is watertight; the cross recess still stops flush
            // with the cavity ceiling as in the original models
            cylinder(d1 = mx_boss_d, d2 = mx_boss_d - mx_boss_taper,
                     h = boss_up);
        }
        // cross recess
        translate([0, 0, -mx_boss_below - eps])
            linear_extrude(mx_boss_below + cavity_depth + 2 * eps)
                mx_cross(0);
        // entry counterbore
        translate([0, 0, -mx_boss_below - eps])
            linear_extrude(mx_flare_depth + eps) mx_cross(mx_flare);
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
