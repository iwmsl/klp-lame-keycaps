// =============================================================
// KLP Lamé Angular — low-profile faceted remix of KLP Lamé
// -------------------------------------------------------------
// Angular (flat-sided, crisp-edged) keycaps that keep the
// signature front/back sloped & dished top of KLP Lamé, with a
// slightly reduced overall height. Stem and cavity dimensions
// are taken from the original KLP Lamé STLs, so switch fit is
// identical to the proven originals.
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
// Top profile variant
variant = "normal"; // [normal, tilted, thumb, saddle, saddle_tilted]
// Homing feature on the touch surface
homing = "none"; // [none, bar, dots]

/* [Body] */
// Corner radius of the bottom footprint (small = more angular)
corner_radius = 1.2;
// Corner radius of the top face
top_corner_radius = 1.0;
// How much each side face leans in from bottom to top (per side)
top_inset = 1.6;
// Height of the top plane (at its corners) above the bottom rim, non-tilted
cap_height = 3.9;
// Chamfer against elephant foot at the outer bottom edge
foot_chamfer = 0.2;

/* [Top surface] */
// Depth of the main dish across the front/back direction
dish_depth = 0.75;
// Radius of the main dish cylinder (axis left-right)
dish_radius = 30;
// Depth of the cross dish (left-right direction)
cross_dish_depth = 0.3;
// Radius of the cross dish cylinder (axis front-back)
cross_dish_radius = 55;
// Tilt angle for tilted variants (matches original 15)
tilt_angle = 15;
// Height of the top plane at the front footprint edge for tilted variants
tilt_front_height = 3.0;
// Saddle: how far the convex roll-off apex sits below the top plane
saddle_center_drop = 0.2;
// Saddle: radius of the convex front/back roll-off
saddle_radius = 26;
// Saddle: deeper cross dish so the sides stay proud of the center
saddle_cross_depth = 0.5;
// Thumb: angle of the front bevel cut
thumb_bevel_angle = 12;
// Thumb: bevel starts this far in front of the cap center
thumb_bevel_start = 2.0;

/* [Shell] */
// Wall thickness at the bottom rim
wall_bottom = 1.0;
// Cavity inset per side at the ceiling (controls wall taper)
cavity_top_inset = 1.7;
// Chamfer along the inner bottom edge (print stability, as in v1.1)
inner_chamfer = 0.5;
// Minimum roof thickness above the cavity ceiling is cap_height
// minus dish depths minus cavity depth; defaults give ~1.2 mm.

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
$fs = 0.25;
eps = 0.01;

// ------------------------------------------------------------------
// Derived dimensions
// ------------------------------------------------------------------
// Footprints measured from the original STLs:
//   choc size: 17.5 x 16.5 mm, mx size: 18 x 18 mm
cap_w = size_type == "choc" ? 17.5 : 18.0;
cap_d = size_type == "choc" ? 16.5 : 18.0;

// Cavity depth (bottom rim -> ceiling), from the originals:
//   choc stem: 2.05 mm, mx stem: 2.0 mm
cavity_depth = stem_type == "choc" ? 2.05 : 2.0;

is_tilted = variant == "tilted" || variant == "saddle_tilted";
is_saddle = variant == "saddle" || variant == "saddle_tilted";

top_w = cap_w - 2 * top_inset;
top_d = cap_d - 2 * top_inset;

// Sagitta of a circle: how much a chord at half-width w rises above the apex
function sag(r, w) = r - sqrt(r * r - w * w);

// Effective cross dish depth for the current variant
function cross_d() = is_saddle ? saddle_cross_depth : cross_dish_depth;

// Local top-surface height (z, negative = below top plane) on the cap
// centerline at local y, per variant. The surface is the lowest of the
// independent cuts, not their sum. Used to seat homing features.
function surf_z(y) =
    is_saddle
        ? -max(saddle_center_drop + sag(saddle_radius, y), cross_d())
        : -max(dish_depth - sag(dish_radius, y), cross_d());

// ------------------------------------------------------------------
// 2D / plate helpers
// ------------------------------------------------------------------
module rrect(w, d, r) {
    offset(r = r) square([w - 2 * r, d - 2 * r], center = true);
}

module plate(w, d, r) {
    linear_extrude(eps) rrect(w, d, r);
}

// Places children from top-plane local coordinates (origin at cap
// center projected on the top plane, z = 0 on the plane) into global
// coordinates. Tilted variants hinge about the front footprint edge.
module top_frame() {
    if (is_tilted)
        translate([0, -cap_d / 2, tilt_front_height])
            rotate([tilt_angle, 0, 0])
                translate([0, cap_d / 2, 0])
                    children();
    else
        translate([0, 0, cap_height]) children();
}

// ------------------------------------------------------------------
// Cap body
// ------------------------------------------------------------------
module cap_body() {
    hull() {
        plate(cap_w - 2 * foot_chamfer, cap_d - 2 * foot_chamfer, corner_radius);
        translate([0, 0, foot_chamfer])
            plate(cap_w, cap_d, corner_radius);
        top_frame() plate(top_w, top_d, top_corner_radius);
    }
}

// Concave dish cutter: cylinder lying along axis, its lowest surface
// point dipping `depth` below the top plane.
module dish_cut(depth, radius, along_x = true) {
    top_frame()
        translate([0, 0, radius - depth])
            rotate(along_x ? [0, 90, 0] : [90, 0, 0])
                cylinder(r = radius, h = 60, center = true);
}

// Convex saddle keep-region: everything below a cylinder bulging up
// along the left-right axis. Used with intersection().
module saddle_keep() {
    top_frame()
        translate([0, 0, -saddle_center_drop - saddle_radius])
            rotate([0, 90, 0])
                cylinder(r = saddle_radius, h = 60, center = true);
}

// Thumb: crisp bevel plane cutting the front of the top down.
// Positive rotation about X drops the plane for y below the hinge.
module thumb_cut() {
    top_frame()
        translate([0, -thumb_bevel_start, 0])
            rotate([thumb_bevel_angle, 0, 0])
                translate([0, 0, 50])
                    cube([60, 60, 100], center = true);
}

module cap_top() {
    difference() {
        intersection() {
            cap_body();
            if (is_saddle) saddle_keep();
        }
        if (!is_saddle)
            dish_cut(dish_depth, dish_radius, along_x = true);
        dish_cut(cross_d(), cross_dish_radius, along_x = false);
        if (variant == "thumb") thumb_cut();
    }
}

// ------------------------------------------------------------------
// Homing features
// ------------------------------------------------------------------
module homing_features() {
    if (homing == "bar")
        top_frame()
            translate([0, -homing_offset, surf_z(-homing_offset) + homing_height - 1])
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
