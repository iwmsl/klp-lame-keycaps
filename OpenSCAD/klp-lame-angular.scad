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
// Key depth in units (stretched front-to-back, stem centered). Used
// for the deep thumb variants.
key_units_y = 1; // [1:0.25:2]
// Top profile variant. thumb = 1U dome waterfall; thumb_slope spreads
// that slope over the whole (deep) cap; thumb_flat keeps a flat back
// plateau and drops the same slope only at the front.
variant = "normal"; // [normal, tilted, thumb, thumb_slope, thumb_flat, saddle, saddle_tilted]
// Homing feature on the touch surface
homing = "none"; // [none, bar, dots]

/* [Body] */
// Height of the crown (top edge of the cap) above the bottom rim
crown_height = 5.0;
// How much each side face leans in from bottom to top (per side)
top_inset = 2.0;
// Corner radius of the bottom footprint (vertical corners)
corner_radius = 1.9;
// Corner radius of the top face (vertical corners)
top_corner_radius = 1.9;
// Rounding of the top perimeter edge (top face -> side wall)
top_edge_round = 1.0;
// Rounding / chamfer of the bottom perimeter edge (side wall -> rim)
bottom_edge_round = 0.4;

/* [Top surface] */
// Depth of the dished scoop at the cap center, below the crown
dish_depth = 1.15;
// Radius of the spherical dish (smaller = deeper/rounder scoop)
dish_radius = 28;
// Tilt angle for tilted variants (matches original 15)
tilt_angle = 15;
// Crown height at the front footprint edge for tilted variants
// (kept high enough that the low front edge keeps a printable roof)
tilt_front_height = 4.0;
// Saddle: front/back cylindrical valley depth at center, below crown
saddle_depth = 1.5;
// Saddle: radius of the front/back valley cylinder (axis left-right)
saddle_radius = 20;
// Thumb: radius of the convex waterfall (bigger = straighter ramp)
thumb_dome_radius = 38;
// Thumb: horizontal stretch of the dome (softens left-right falloff)
thumb_dome_sx = 1.5;
// Thumb: crest height below the (raised) crown
thumb_crest_drop = 0.2;
// Thumb: extra body height at the back, tilted-style, so the surface
// falls from a high back edge down to a low front
thumb_back_rise = 0.8;
// thumb_flat: length of the front waterfall (mm); the rest of the top
// stays a flat plateau at the crown
thumb_flat_run = 11;
// thumb_flat: radius of the front waterfall roll (smaller = steeper)
thumb_flat_radius = 24;

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
base_w = size_type == "choc" ? 17.5 : 18.0;
base_d = size_type == "choc" ? 16.5 : 18.0;
pitch_x = size_type == "choc" ? 18.0 : 19.05;
pitch_y = size_type == "choc" ? 17.0 : 19.05;
cap_w = base_w + (key_units   - 1) * pitch_x;
cap_d = base_d + (key_units_y - 1) * pitch_y;

// The dish/dome is stretched with the cap so bigger caps keep the same
// scoop/slope character (matches the original 1.5U models).
dish_sx = cap_w / base_w;
dish_sy = cap_d / base_d;

// Cavity depth (bottom rim -> ceiling), from the originals:
//   choc stem: 2.05 mm, mx stem: 2.0 mm
cavity_depth = stem_type == "choc" ? 2.05 : 2.0;

is_tilted = variant == "tilted" || variant == "saddle_tilted";
is_saddle = variant == "saddle" || variant == "saddle_tilted";
// dome-shaped thumbs (convex crest + waterfall)
is_thumb_dome = variant == "thumb" || variant == "thumb_slope";
is_thumb = is_thumb_dome || variant == "thumb_flat";

top_w = cap_w - 2 * top_inset;
top_d = cap_d - 2 * top_inset;

// Sagitta of a circle: rise of the arc at horizontal offset w from apex
function sag(r, w) = r - sqrt(r * r - w * w);

// Local top-surface height (z below the crown, negative) on the cap
// centerline at local y, per variant. Used to seat homing features.
function surf_z(y) =
    is_saddle
        ? -(saddle_depth - sag(saddle_radius, y))
        : -(dish_depth   - sag(dish_radius,   y));

// ------------------------------------------------------------------
// 2D / plate helpers
// ------------------------------------------------------------------
module rrect(w, d, r) {
    rr = max(min(r, w / 2 - eps, d / 2 - eps), 0.05);
    offset(r = rr) square([w - 2 * rr, d - 2 * rr], center = true);
}

module plate(w, d, r) {
    linear_extrude(eps) rrect(w, d, r);
}

// Front crown height for tilted variants. Saddle digs deeper, so its
// tilted form starts a touch higher to keep the front skirt printable.
tilt_front_h = tilt_front_height + (variant == "saddle_tilted" ? 0.3 : 0);

// Effective crown height: the thumb body is a little taller so its
// waterfall / plateau sits at a tilted-like high back edge.
crown_h = crown_height + (is_thumb ? thumb_back_rise : 0);

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
        // flat tapered sides up to just below the crown, then rounded
        // top edge into the (inset) crown face
        top_frame() translate([0, 0, -top_edge_round])
            plate(top_w, top_d, top_corner_radius);
        top_frame()
            plate(top_w - 2 * top_edge_round, top_d - 2 * top_edge_round,
                  max(top_corner_radius - top_edge_round, 0.1));
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

// Saddle cutter: cylinder along the left-right axis, giving a
// front/back valley (concave front-back, straight left-right).
module saddle_dish() {
    top_frame()
        translate([0, 0, saddle_radius - saddle_depth])
            rotate([0, 90, 0])
                cylinder(r = saddle_radius, h = 60, center = true);
}

// Dome thumb keep-region: a single convex ellipsoid — no dish at all.
// The crest sits on the raised back edge of the top face and the
// surface waterfalls monotonically down to a low front, with a gentle
// left-right barrel. One surface, no creases. For deep (thumb_slope)
// caps the dome is stretched front-to-back (sy) so the same slope is
// spread — "distributed" — over the whole length.
module thumb_dome_keep() {
    sy = variant == "thumb_slope" ? dish_sy : 1;
    top_frame()
        translate([0, top_d / 2, -thumb_crest_drop - thumb_dome_radius])
            scale([thumb_dome_sx, sy, 1])
                sphere(r = thumb_dome_radius);
}

// Flat thumb keep-region: the back stays a flat plateau at the crown;
// only the front `thumb_flat_run` mm waterfalls off, over a convex
// cylinder tangent to the plateau — so the drop keeps the 1U thumb's
// slope while the added length is flat.
module thumb_flat_keep() {
    hinge = -cap_d / 2 + thumb_flat_run;
    top_frame() {
        // flat plateau: everything behind the hinge (cap_body caps the top)
        translate([0, hinge + 50, 0])
            cube([2 * cap_w + 40, 100, 200], center = true);
        // front roll-off: cylinder tangent to the crown at the hinge
        translate([0, hinge, -thumb_flat_radius])
            rotate([0, 90, 0])
                cylinder(r = thumb_flat_radius, h = 2 * cap_w + 40, center = true);
    }
}

module cap_top() {
    difference() {
        intersection() {
            cap_body();
            if (is_thumb_dome) thumb_dome_keep();
            if (variant == "thumb_flat") thumb_flat_keep();
        }
        if (!is_thumb) {
            if (is_saddle) saddle_dish(); else dish_sphere();
        }
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
