#!/usr/bin/env python3
"""Arrange a keycap set onto print plates for the Bambu Lab A1 mini.

Reads the built angular STLs and writes two combined plates:
  - <out>_BottomDown.stl : caps upright (bottom/stem toward the bed)
  - <out>_SideDown.stl   : caps laid on a side wall (best top surface)

Both are laid out to fit the A1 mini's 180 x 180 mm bed. Import a plate
into Bambu Studio, add supports (tree, for the overhangs), and slice.
"""
import struct, math, sys, os

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


if __name__ == "__main__":
    out_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    os.makedirs(out_dir, exist_ok=True)
    build(False, os.path.join(out_dir, "Plate_A1mini_BottomDown.stl"))
    build(True, os.path.join(out_dir, "Plate_A1mini_SideDown.stl"))
