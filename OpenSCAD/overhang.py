#!/usr/bin/env python3
"""Measure the overhang a keycap presents at a given print orientation.

An FDM print fails where a face leans further past the layer below it
than the melt can bridge — the perimeter droops, curls up and is struck
by the nozzle. The angle that matters is measured from vertical: 0 deg
is a wall (perfectly supported), 90 deg a ceiling (nothing under it).
45 deg is the usual safe limit.

The cap is split into two shells, because they do not carry the same
risk:

  outer  the visible shell — walls, bottom rim, dish. A curl here
         wrecks the print and is what past attempts kept hitting.
  inner  the cavity, its ceiling and the stem. All of it disappears
         inside the switch, and a droop there costs stem fit, not the
         print. Reported separately rather than ignored.

Run it over the built caps to check a tip angle, or with `--sweep` to
print the table the angle was chosen from:

    python3 overhang.py --tip=48 STL/MX\\ Stem\\ +\\ MX\\ Tight\\ Size/*.stl
    python3 overhang.py --sweep STL/.../MX_Stem_MX_Tight_Size_Angular_Normal.stl

Tipping trades two faces against each other and cannot satisfy both. The
cap's horizontal faces — the rim underside and the cavity ceiling, some
340 mm2 between them — sit at 90 minus the tip angle, and its vertical
ones sit at the tip angle itself. Their sum is 90, so one of the two is
always at 45 or worse. The margin belongs to the large exposed faces.
"""
from __future__ import annotations

import math
import os
import re
import struct
import sys

# Faces steeper than this need support on a 0.4 mm nozzle.
LIMIT_DEG = 45.0

# How far inside the cap's footprint every vertex of a face must sit
# before the face counts as hidden. Only needs to separate "touches the
# footprint edge" from "starts at the cavity mouth", so it is half the
# rim lip left between the two.
INNER_INSET = 0.25

# A hull between two extruded outlines leaves a hairline of dead-vertical
# wall the thickness of the extrusion. Faces this small are seams in the
# model, not surfaces the nozzle ever traces — one is an order of
# magnitude shorter than a layer — so they are left out of the totals.
SEAM_SPAN = 0.05
SEAM_AREA = 0.5

# The angle the print plates use, and the angles --sweep reports.
DEFAULT_TIP = 48.0
TIP_SWEEP = (42.0, 44.0, 45.0, 46.0, 47.0, 48.0, 50.0, 55.0)


# ------------------------------------------------------------------
# Mesh basics
# ------------------------------------------------------------------
def load(path):
    """Read a binary or ASCII STL into a list of triangles."""
    with open(path, "rb") as f:
        head = f.read(80)
        data = f.read()
    if head[:5] == b"solid":  # ASCII STL (OpenSCAD default)
        txt = (head + data).decode("ascii", errors="ignore")
        v = re.findall(
            r"vertex\s+([-\d.eE+]+)\s+([-\d.eE+]+)\s+([-\d.eE+]+)", txt)
        pts = [(float(a), float(b), float(c)) for a, b, c in v]
        if len(pts) >= 3 and len(pts) % 3 == 0:
            return [pts[i:i + 3] for i in range(0, len(pts), 3)]
    n = struct.unpack("<I", data[:4])[0]
    tris, off = [], 4
    for _ in range(n):
        v = struct.unpack("<12f", data[off:off + 48])
        tris.append([(v[3], v[4], v[5]), (v[6], v[7], v[8]),
                     (v[9], v[10], v[11])])
        off += 50
    return tris


def tri_normal(a, b, c):
    ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    length = math.sqrt(nx * nx + ny * ny + nz * nz) or 1.0
    return nx / length, ny / length, nz / length


def tri_area(a, b, c):
    ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    return math.sqrt(nx * nx + ny * ny + nz * nz) / 2


def centroid(tri):
    return tuple(sum(p[i] for p in tri) / 3 for i in range(3))


def bounds(tris):
    xs = [p[0] for tri in tris for p in tri]
    ys = [p[1] for tri in tris for p in tri]
    zs = [p[2] for tri in tris for p in tri]
    return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


# ------------------------------------------------------------------
# Splitting the cap into its visible and hidden shells
# ------------------------------------------------------------------
def inner_mask(tris):
    """Flag the triangles that end up hidden inside the switch.

    Everything hidden — cavity walls, cavity ceiling, stem — sits inside
    the footprint by at least a wall thickness and no higher than the
    cavity ceiling. Nothing on the visible shell does: the rim's
    underside reaches only half a wall in, and the dish sits well above
    the ceiling. So the two shells separate on those two tests alone,
    with the ceiling height read back off the mesh.
    """
    (mnx, mny, _), (mxx, mxy, _) = bounds(tris)
    x0, x1 = mnx + INNER_INSET, mxx - INNER_INSET
    y0, y1 = mny + INNER_INSET, mxy - INNER_INSET

    def inside(tri):
        return all(x0 <= p[0] <= x1 and y0 <= p[1] <= y1 for p in tri)

    # The cavity ceiling is the highest near-horizontal downward face
    # within the column; nothing hidden reaches above it.
    ceiling = max(
        (max(p[2] for p in tri) for tri in tris
         if inside(tri) and tri_normal(*tri)[2] < -0.5),
        default=float("-inf"),
    )
    return [inside(tri) and max(p[2] for p in tri) <= ceiling + 1e-6
            for tri in tris]


def overhang_deg(normal_z):
    """Overhang of a face, in degrees from vertical. 0 for anything
    that faces upward and so rests on the layer below."""
    if normal_z >= 0:
        return 0.0
    return math.degrees(math.asin(min(1.0, -normal_z)))


# ------------------------------------------------------------------
# Orientation
# ------------------------------------------------------------------
def rot_x(tris, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [[(x, y * c - z * s, y * s + z * c) for (x, y, z) in tri]
            for tri in tris]


def rot_z(tris, deg):
    a = math.radians(deg)
    c, s = math.cos(a), math.sin(a)
    return [[(x * c - y * s, x * s + y * c, z) for (x, y, z) in tri]
            for tri in tris]


def orient(tris, spin, tip):
    """Spin the cap in plan, then tip it that far away from upright."""
    return rot_x(rot_z(tris, spin), -tip)


def is_seam(tri):
    return (max(p[2] for p in tri) - min(p[2] for p in tri) < SEAM_SPAN
            and tri_area(*tri) < SEAM_AREA)


def stats(tris, mask=None):
    """Worst overhang and area past the limit, per shell."""
    if mask is None:
        mask = inner_mask(tris)
    out = {"outer": {"worst": 0.0, "over": 0.0, "area": 0.0},
           "inner": {"worst": 0.0, "over": 0.0, "area": 0.0}}
    for tri, is_inner in zip(tris, mask):
        shell = out["inner" if is_inner else "outer"]
        angle = overhang_deg(tri_normal(*tri)[2])
        area = tri_area(*tri)
        shell["area"] += area
        if is_seam(tri):
            continue
        shell["worst"] = max(shell["worst"], angle)
        if angle > LIMIT_DEG:
            shell["over"] += area
    return out


# ------------------------------------------------------------------
# Report
# ------------------------------------------------------------------
def report(path, spin, tip):
    s = stats(orient(load(path), spin, tip))
    print(f"{os.path.basename(path)}  spin {spin:.0f} / tip {tip:.1f} deg")
    for shell in ("outer", "inner"):
        d = s[shell]
        print(f"  {shell:5s} over {LIMIT_DEG:.0f} deg: {d['over']:6.2f} mm2"
              f" of {d['area']:7.1f} mm2   worst {d['worst']:5.1f} deg")
    return s


def sweep(path, spin):
    tris = load(path)
    mask = inner_mask(tris)
    print(f"{os.path.basename(path)}  spin {spin:.0f} deg")
    print("   tip |   outer over 45   worst |   inner over 45   worst")
    for tip in TIP_SWEEP:
        s = stats(orient(tris, spin, tip), mask)
        cells = []
        for shell in ("outer", "inner"):
            d = s[shell]
            cells.append(f"{d['over']:8.2f} mm2   {d['worst']:5.1f}")
        print(f"  {tip:4.1f} | {cells[0]} | {cells[1]}")


def main(argv):
    spin, tip, do_sweep = 0.0, DEFAULT_TIP, False
    paths = []
    for arg in argv:
        if arg == "--sweep":
            do_sweep = True
        elif arg.startswith("--tip="):
            tip = float(arg.split("=", 1)[1])
        elif arg.startswith("--spin="):
            spin = float(arg.split("=", 1)[1])
        else:
            paths.append(arg)
    if not paths:
        raise SystemExit(__doc__)
    for path in paths:
        sweep(path, spin) if do_sweep else report(path, spin, tip)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
