# Print plates — Corne v4 Mini set (Bambu Lab A1 mini)

Ready-to-slice plates holding a **full Corne v4 Mini keycap set**
(both hands, 36 caps) of the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Import a plate into Bambu Studio, add
supports, and slice.

Caps used: **MX Stem + Choc Size**.

| Bill of materials | Qty |
| :---------------- | --: |
| Normal Tilted (top & bottom rows) | 20 |
| Normal (home row) | 8 |
| Normal Homing (index home keys) | 2 |
| 1.5U Thumb Slope (thumbs, 1.5U each) | 6 |
| **Total** | **36** |

## Two print orientations

| File | Orientation | Notes |
| :--- | :--- | :--- |
| `Plate_A1mini_SideDown.stl` | **側面を下** — cap laid on a side wall | Layer lines run across the top, so **no tactile layer bumps on the touch surface** (best feel). Needs supports for the overhangs; the drafted side wall gives a flat, stable base. Recommended. |
| `Plate_A1mini_BottomDown.stl` | **底面を下** — cap upright, stem/bottom toward the bed | Simplest layout, top faces up. The top prints as stacked layers (visible rings / slight tactile bumps). Rests on the Ø5.5 MX stem boss + skirt; use supports + a brim. |

Both plates fit the bed:

- SideDown : ~159 × 84 mm, 16.4 mm tall (10 cols)
- BottomDown: ~161 × 112 mm, 8.7 mm tall (8 cols)

## Slicing (Bambu Studio, A1 mini)

- Nozzle 0.4 mm, layer height 0.08–0.12 mm, walls ≥ 4, infill 100 %.
- **Supports: on, type Tree (auto).** Both orientations have overhangs
  (the hollow underside / stem). SideDown needs support under the
  floating body; BottomDown under the flaring skirt.
- Material: PLA or PETG. A brim (5 mm) helps adhesion, especially for
  the tall SideDown caps.
- If the switch fit is tight/loose, tune Bambu Studio's *X-Y hole
  compensation* by ±0.05 mm, or edit the stem params in the `.scad`.

## Regenerating

Plates are generated from the built STLs:

```sh
./build.sh                 # build all individual caps first
python3 make_plate.py Plates   # writes both plates here
```

Edit the `BOM` list in `make_plate.py` to change counts (e.g. if your
thumb layout uses the 1.5U `Thumb_Slope`), or `SIDE_ROT_Y` to change
the on-side tilt.
