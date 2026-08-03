# Print plates — KLP Lamé Angular (Bambu Lab A1 mini)

Ready-to-slice plates for the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Start with the four-cap trial plate, then
print the whole set with `Plate_A1mini_Corne36_RearDown.stl`.

Caps used: **MX Stem + MX Size** (18 × 18 mm footprint, chiclet
sidewalls, for a 19 mm pitch).

## Trial plate — all variants

`Plate_A1mini_Test_OneEach_RearSideDown.stl` contains one of every
variant (four caps total). Normal and Normal Tilted are placed on the
**rear outer side face**—the upper side in the model's top view. Normal
Homing and 1.5U Normal use their automatically selected side face, which
needs less support material. Inner cavity walls and tiny rounded/chamfer
faces are excluded, so the choice is a real supporting face rather than
an unstable edge or point. After the contact face is chosen, every cap is
rotated only within the build-plate plane so all stem axes point in the
same direction as Normal. This final rotation does not change contact
area or stability.

- Size: approximately **32.7 × 39.0 × 26.8 mm**
- Actual contact area per cap: approximately **47.7–81.1 mm²**
- Layout, viewed from above:

| Row | Left | Right |
| :-- | :--- | :---- |
| 1 | Normal | Normal Homing |
| 2 | Normal Tilted | 1.5U Normal |

Use tree supports and an **8 mm brim** for the first print.

## Quality-tuned Bambu project — PLA

`KLP_Lame_4Cap_A1mini_PLA_Quality.3mf` packages the same four trial caps
as separately selectable objects and embeds a conservative A1 mini /
0.4 mm nozzle / PLA process configuration. The matching importable
process preset is `KLP_Lame_A1mini_PLA_Quality_Process.json`.

The three 1U variants (Normal, Normal Homing and Normal Tilted) are
placed with the **rear outer side face**—the upper side in the model's
top view—toward the build plate. This keeps them side-down rather than
putting the touch surface on the bed. 1.5U Normal keeps its
minimum-contact side orientation.

The embedded profile uses 0.12 mm layers, slower first-layer and wall
speeds, an 8 mm outer brim, and dense Normal/Snug support interfaces. It
is intended to diagnose and improve the rough support-facing surfaces
near the build plate. This profile prioritizes underside quality rather
than minimum support material. For a support-minimized print, disable
automatic supports and paint Tree supports only beneath the stem boss
and the first floating edges.

## Corne set, one plate — `Plate_A1mini_Corne36_RearDown.stl`

All 36 caps laid on their **rear wall** (the taller, +Y side in the
model's top view). The rear wall is vertical by design (`rear_inset =
0`), so once a cap is tipped onto it every outer surface is either
vertical or facing up — **no outward-leaning outer surface anywhere**.
That removes the perimeter curl that made side-down prints collide
with the nozzle: each layer's outer perimeter now sits directly on the
one below instead of hanging past it.

- Size: approximately **155.3 × 69.5 × 18.0 mm** — fits the bed
- Bed contact: Normal / Homing 46.5 mm², Tilted 90.7 mm²,
  1.5U Normal 77.9 mm²
- All 36 stems point the same way, so support, seam and cooling behave
  identically on every cap
- Caps stand 18 mm tall on a modest footprint: tree supports and an
  **8 mm brim** are still recommended

## Full 36-key Corne set

| Bill of materials | Qty |
| :---------------- | --: |
| Normal Tilted (top & bottom rows) | 20 |
| Normal (home row 8 + 1U thumbs 4) | 12 |
| Normal Homing (index home keys) | 2 |
| 1.5U Normal (one thumb per hand) | 2 |
| **Total** | **36** |

| File | Orientation | Notes |
| :--- | :--- | :--- |
| `Plate_A1mini_BottomDown.stl` | **底面を下** — cap upright, stem/bottom toward the bed | Simplest layout, top faces up. The top prints as stacked layers (visible rings / slight tactile bumps). Rests on the Ø5.5 MX stem boss + skirt; use supports + a brim. |

- BottomDown: ~150 × 165 mm, 8.5 mm tall (5 cols)

## Slicing (Bambu Studio, A1 mini)

- Nozzle 0.4 mm, layer height 0.08–0.12 mm, walls ≥ 4, infill 100 %.
- **Supports: on, type Tree (auto).** All orientations have overhangs
  (the hollow underside / stem). SideDown needs support under the
  floating body; BottomDown under the flaring skirt. The trial plate
  also needs support under each floating body and stem boss.
- Material: PLA or PETG.
- Brim: **8 mm for the minimum-contact trial plate**; 5 mm is normally
  enough for the two full-set plates.
- If the switch fit is tight/loose, tune Bambu Studio's *X-Y hole
  compensation* by ±0.05 mm, or edit the stem params in the `.scad`.

## Regenerating

Plates are generated from the built STLs:

```sh
./build.sh                          # build caps and every plate
python3 make_plate.py Plates test   # trial plate only
python3 make_plate.py Plates full   # the two full-set plates
python3 make_plate.py Plates        # all of them
```

Edit `BOM` in `make_plate.py` to change counts. Edit `TEST_VARIANTS` to
change the trial set; its minimum-contact orientation is recalculated
from each STL automatically.

Regenerate the quality-tuned 3MF and its standalone preset from the
repository root:

```sh
python3 OpenSCAD/make_quality_3mf.py \
  --repo-root . \
  --output OpenSCAD/Plates/KLP_Lame_4Cap_A1mini_PLA_Quality.3mf \
  --preset-output OpenSCAD/Plates/KLP_Lame_A1mini_PLA_Quality_Process.json
```
