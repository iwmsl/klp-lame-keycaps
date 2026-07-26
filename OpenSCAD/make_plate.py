#!/usr/bin/env python3
"""Arrange KLP Lamé Angular keycaps for the Bambu Lab A1 mini.

Reads the built angular STLs and writes:
  - <out>_BottomDown.stl : caps upright (bottom/stem toward the bed)
  - <out>_SideDown.stl   : caps laid on a side wall (best top surface)
  - <out>_Test_OneEach_MinContact.stl : one of every selected trial
    variant, with
    each cap resting on its smallest usable outer side face, except
    thumb variants which use the opposite rear face for stability

Both are laid out to fit the A1 mini's 180 x 180 mm bed. Import a plate
into Bambu Studio, add supports (tree, for the overhangs), and slice.
"""
import math
import os
import struct
import sys

BED = 180.0
MARGIN = 6.0
GAP = 3.0
# Lay the (drafted) side wall flat: the wall leans ~29 deg from
# vertical, so tip the cap 90+29 deg about Y to seat the wall.
SIDE_ROT_Y = 119.0

STL_DIR = os.path.join(os.path.dirname(__file__), "STL", "MX Stem + Choc Size")
PREFIX = "MX_Stem_Choc_Size_Angular_"

# Corne v4 Mini, both hands (36 caps).
BOM = [
    ("Normal_Tilted", 20),      # top + bottom rows
    ("Normal", 8),              # home row
    ("Normal_Homing", 2),       # index home keys
    ("Thumb", 4),               # thumbs: two 1U per hand
    ("1.5U_Thumb_Slope", 2),    # thumbs: one 1.5U per hand
]

# Selected first-print variants. Saddle profiles remain available as
# individual STLs but are intentionally omitted from this trial plate.
# Order is the documented 3 x 2 layout, read left-to-right and
# top-to-bottom.
TEST_VARIANTS = [
    "Normal",
    "Normal_Homing",
    "Normal_Tilted",
    "Thumb",
    "1.5U_Normal",
    "1.5U_Thumb_Slope",
]

# The smallest face on the two thumb profiles is the low front wall,
# but it is too narrow for a stable first print. Flip them front-to-rear
# and use the larger rear wall instead.
TEST_SIDE_OVERRIDES = {
    "Thumb": "rear",
    "1.5U_Thumb_Slope": "rear",
}

# In-plane direction of the original +Z stem axis after a cap has been
# laid down. 180 degrees matches the Normal key orientation. Rotating
# around the build-plate Z axis does not change the selected contact face.
TEST_STEM_ANGLE_DEG = 180.0

SIDE_PRIORITY = {"left": 0, "right": 1, "front": 2, "rear": 3}
MIN_MAIN_SIDE_AREA = 10.0
BED_CONTACT_TOL = 0.03


def load(path):
    with open(path, "rb") as f:
        head = f.read(80)
        data = f.read()
    if head[:5] == b"solid":  # ASCII STL (OpenSCAD default)
        import re
        txt = (head + data).decode("ascii", errors="ignore")
        v = re.findall(r"vertex\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)", txt)
        pts = [(float(a), float(b), float(c)) for a, b, c in v]
        if len(pts) >= 3 and len(pts) % 3 == 0:
            return [pts[i:i + 3] for i in range(0, len(pts), 3)]
    n = struct.unpack("<I", data[:4])[0]
    tris, off = [], 4
    for _ in range(n):
        v = struct.unpack("<12f", data[off:off + 48])
        tris.append([(v[3], v[4], v[5]), (v[6], v[7], v[8]), (v[9], v[10], v[11])])
        off += 50
    return tris


def rot_y(t, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [[(x * c + z * s, y, -x * s + z * c) for (x, y, z) in tri] for tri in t]


def rot_z(t, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [[(x * c - y * s, x * s + y * c, z)
             for (x, y, z) in tri] for tri in t]


def bounds(t):
    xs = [p[0] for tri in t for p in tri]
    ys = [p[1] for tri in t for p in tri]
    zs = [p[2] for tri in t for p in tri]
    return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


def translate(t, dx, dy, dz):
    return [[(x + dx, y + dy, z + dz) for (x, y, z) in tri] for tri in t]


def prep(tris, side):
    """Orient a single cap: optional side tip, then drop onto z=0 and
    center its footprint on the origin."""
    if side:
        tris = rot_y(tris, SIDE_ROT_Y)
    (mnx, mny, mnz), (mxx, mxy, mxz) = bounds(tris)
    cx, cy = (mnx + mxx) / 2, (mny + mxy) / 2
    return translate(tris, -cx, -cy, -mnz)


def tri_normal(a, b, c):
    ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    l = math.sqrt(nx * nx + ny * ny + nz * nz) or 1.0
    return nx / l, ny / l, nz / l


def tri_area(a, b, c):
    ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    return math.sqrt(nx * nx + ny * ny + nz * nz) / 2


def normalize(v):
    length = math.sqrt(sum(x * x for x in v)) or 1.0
    return tuple(x / length for x in v)


def main_side_faces(tris):
    """Return the main planar patch for each of the four outer walls.

    The outer drafted walls have an upward-facing normal, whereas the
    inner cavity walls point downward. Grouping equal normals isolates
    each flat wall without accidentally selecting a tiny edge chamfer.
    """
    groups = {}
    for a, b, c in tris:
        nx, ny, nz = tri_normal(a, b, c)
        horizontal = max(abs(nx), abs(ny))
        if not (0.05 < nz < 0.85 and horizontal > 0.60):
            continue
        if abs(nx) >= abs(ny):
            side = "right" if nx > 0 else "left"
        else:
            side = "rear" if ny > 0 else "front"
        key = (side, round(nx, 2), round(ny, 2), round(nz, 2))
        area = tri_area(a, b, c)
        if key not in groups:
            groups[key] = [0.0, 0.0, 0.0, 0.0]
        groups[key][0] += area
        groups[key][1] += nx * area
        groups[key][2] += ny * area
        groups[key][3] += nz * area

    faces = []
    for side in SIDE_PRIORITY:
        side_groups = [(key, value) for key, value in groups.items()
                       if key[0] == side]
        if not side_groups:
            continue
        _, (area, nx, ny, nz) = max(side_groups,
                                     key=lambda item: item[1][0])
        if area >= MIN_MAIN_SIDE_AREA:
            faces.append({
                "side": side,
                "area": area,
                "normal": normalize((nx, ny, nz)),
            })
    return faces


def rotation_to_down(normal):
    """Rodrigues matrix rotating *normal* onto the bed normal (0,0,-1)."""
    ax, ay, az = normalize(normal)
    bx, by, bz = 0.0, 0.0, -1.0
    vx, vy, vz = ay * bz - az * by, az * bx - ax * bz, ax * by - ay * bx
    sine = math.sqrt(vx * vx + vy * vy + vz * vz)
    cosine = ax * bx + ay * by + az * bz
    if sine < 1e-9:
        if cosine > 0:
            return ((1.0, 0.0, 0.0),
                    (0.0, 1.0, 0.0),
                    (0.0, 0.0, 1.0))
        return ((1.0, 0.0, 0.0),
                (0.0, -1.0, 0.0),
                (0.0, 0.0, -1.0))

    kx, ky, kz = vx / sine, vy / sine, vz / sine
    one_minus_cos = 1.0 - cosine
    return (
        (cosine + kx * kx * one_minus_cos,
         kx * ky * one_minus_cos - kz * sine,
         kx * kz * one_minus_cos + ky * sine),
        (ky * kx * one_minus_cos + kz * sine,
         cosine + ky * ky * one_minus_cos,
         ky * kz * one_minus_cos - kx * sine),
        (kz * kx * one_minus_cos - ky * sine,
         kz * ky * one_minus_cos + kx * sine,
         cosine + kz * kz * one_minus_cos),
    )


def rotate_matrix(tris, matrix):
    def rotate_point(point):
        x, y, z = point
        return tuple(row[0] * x + row[1] * y + row[2] * z
                     for row in matrix)

    return [[rotate_point(point) for point in tri] for tri in tris]


def bed_contact_area(tris):
    min_z = min(point[2] for tri in tris for point in tri)
    return sum(
        tri_area(a, b, c)
        for a, b, c in tris
        if max(abs(a[2] - min_z), abs(b[2] - min_z),
               abs(c[2] - min_z)) <= BED_CONTACT_TOL
    )


def prep_min_contact(tris, preferred_side=None):
    """Put a usable outer side face on the build plate.

    The smallest face is selected by default. ``preferred_side`` can
    override it when print stability is more important.
    """
    valid = []
    for face in main_side_faces(tris):
        matrix = rotation_to_down(face["normal"])
        rotated = rotate_matrix(tris, matrix)
        contact = bed_contact_area(rotated)
        # The chosen planar patch must actually be the supporting face,
        # not a face hidden behind a protruding stem or rounded edge.
        if contact >= max(5.0, face["area"] * 0.65):
            valid.append((contact, SIDE_PRIORITY[face["side"]],
                          face, rotated, matrix))
    if not valid:
        raise RuntimeError("No usable outer side face found")

    if preferred_side is not None:
        valid = [item for item in valid
                 if item[2]["side"] == preferred_side]
        if not valid:
            raise RuntimeError(
                f"Requested side is not usable: {preferred_side}")

    contact, _, face, rotated, matrix = min(
        valid, key=lambda item: (item[0], item[1]))

    # Align every projected stem axis with the Normal key. This is only
    # an in-plane rotation, so the chosen supporting face and its area
    # stay exactly the same.
    stem_angle = math.degrees(math.atan2(matrix[1][2], matrix[0][2]))
    in_plane_rotation = TEST_STEM_ANGLE_DEG - stem_angle
    rotated = rot_z(rotated, in_plane_rotation)

    (mnx, mny, mnz), (mxx, mxy, _) = bounds(rotated)
    centered = translate(rotated, -(mnx + mxx) / 2,
                         -(mny + mxy) / 2, -mnz)
    return centered, {
        "side": face["side"],
        "face_area": face["area"],
        "contact_area": contact,
        "stem_angle": TEST_STEM_ANGLE_DEG,
    }


def write_stl(path, tris):
    with open(path, "wb") as f:
        f.write(b"KLP Lame Angular plate" + b"\0" * (80 - 22))
        f.write(struct.pack("<I", len(tris)))
        for a, b, c in tris:
            f.write(struct.pack("<3f", *tri_normal(a, b, c)))
            f.write(struct.pack("<9f", *a, *b, *c))
            f.write(struct.pack("<H", 0))


def cap_cells(side):
    """One prepped cap per BOM entry × count, plus its footprint size."""
    caps = []
    for name, count in BOM:
        tris = load(os.path.join(STL_DIR, PREFIX + name + ".stl"))
        p = prep(tris, side)
        (mnx, mny, _), (mxx, mxy, _) = bounds(p)
        caps += [(p, mxx - mnx, mxy - mny)] * count
    return caps


def build(side, out):
    # Group by footprint so rows stay compact (biggest caps don't
    # inflate every row). Widest cell sets the column pitch.
    caps = sorted(cap_cells(side), key=lambda c: c[2])
    cw = max(c[1] for c in caps) + GAP
    usable = BED - 2 * MARGIN
    cols = max(1, int(usable // cw))
    rows = [caps[i:i + cols] for i in range(0, len(caps), cols)]
    W = cols * cw
    H = sum(max(c[2] for c in r) + GAP for r in rows)
    plate = []
    y = H / 2
    for r in rows:
        rh = max(c[2] for c in r) + GAP
        for col, (tris, _, _) in enumerate(r):
            x = -W / 2 + cw / 2 + col * cw
            plate += translate(tris, x, y - rh / 2, 0)
        y -= rh
    write_stl(out, plate)
    (mnx, mny, mnz), (mxx, mxy, mxz) = bounds(plate)
    print(f"{os.path.basename(out)}: {len(caps)} caps, {cols} cols x {len(rows)} rows, "
          f"bbox {mxx-mnx:.1f} x {mxy-mny:.1f} x {mxz-mnz:.1f} mm "
          f"({'FITS' if max(mxx-mnx, mxy-mny) <= BED else 'TOO BIG'})")


def build_test(out):
    """Build a compact trial plate from TEST_VARIANTS."""
    caps = []
    for name in TEST_VARIANTS:
        tris = load(os.path.join(STL_DIR, PREFIX + name + ".stl"))
        oriented, info = prep_min_contact(
            tris, preferred_side=TEST_SIDE_OVERRIDES.get(name))
        (mnx, mny, _), (mxx, mxy, _) = bounds(oriented)
        caps.append({
            "name": name,
            "tris": oriented,
            "width": mxx - mnx,
            "depth": mxy - mny,
            "info": info,
        })
        print(f"  {name:18s} {info['side']:5s} down, "
              f"contact {info['contact_area']:.1f} mm^2")

    cols = 3
    rows = [caps[i:i + cols] for i in range(0, len(caps), cols)]
    col_widths = [max(row[col]["width"] for row in rows
                      if col < len(row))
                  for col in range(cols)]
    row_depths = [max(cap["depth"] for cap in row) for row in rows]
    total_width = sum(col_widths) + GAP * (cols - 1)
    total_depth = sum(row_depths) + GAP * (len(rows) - 1)

    x_centers = []
    x = -total_width / 2
    for width in col_widths:
        x_centers.append(x + width / 2)
        x += width + GAP

    plate = []
    y = total_depth / 2
    for row, depth in zip(rows, row_depths):
        cy = y - depth / 2
        for col, cap in enumerate(row):
            plate += translate(cap["tris"], x_centers[col], cy, 0)
        y -= depth + GAP

    write_stl(out, plate)
    (mnx, mny, mnz), (mxx, mxy, mxz) = bounds(plate)
    print(f"{os.path.basename(out)}: {len(caps)} caps, "
          f"{cols} cols x {len(rows)} rows, "
          f"bbox {mxx-mnx:.1f} x {mxy-mny:.1f} x {mxz-mnz:.1f} mm "
          f"({'FITS' if max(mxx-mnx, mxy-mny) <= BED else 'TOO BIG'})")


if __name__ == "__main__":
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    mode = sys.argv[2] if len(sys.argv) > 2 else "all"
    if mode not in {"all", "full", "test"}:
        raise SystemExit("mode must be one of: all, full, test")
    os.makedirs(out_dir, exist_ok=True)
    if mode in {"all", "full"}:
        build(False, os.path.join(out_dir, "Plate_A1mini_BottomDown.stl"))
        build(True, os.path.join(out_dir, "Plate_A1mini_SideDown.stl"))
    if mode in {"all", "test"}:
        build_test(os.path.join(
            out_dir, "Plate_A1mini_Test_OneEach_MinContact.stl"))
