# Print plates — KLP Lamé Angular (Bambu Lab A1 mini)

Ready-to-slice plates for the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Start with the six-cap trial plate before
committing to a full 36-key Corne v4 Mini set.

Caps used: **MX Stem + Choc Size**.

## Trial plate — six selected variants

`Plate_A1mini_Test_OneEach_MinContact.stl` contains one of each selected
first-print variant (six caps total). Saddle, Saddle Homing and Saddle
Tilted remain available as individual STLs but are omitted from this
trial plate. Each included mesh is inspected
individually and placed on the **smallest usable flat outer side face**.
The two Thumb variants are deliberately flipped to the opposite rear
face because their smallest front wall is too narrow for a stable print.
Inner cavity walls and tiny rounded/chamfer faces are excluded, so the
choice is a real supporting face rather than an unstable edge or point.
After the contact face is chosen, every cap is rotated only within the
build-plate plane so all stem axes point in the same direction as Normal.
This final rotation does not change contact area or stability.

- Size: approximately **45.0 × 37.0 × 23.2 mm**
- Actual contact area per cap: approximately **42.6–59.6 mm²**
- Layout, viewed from above:

| Row | Left | Centre | Right |
| :-- | :--- | :----- | :---- |
| 1 | Normal | Normal Homing | Normal Tilted |
| 2 | Thumb | 1.5U Normal | 1.5U Thumb Slope |

The selected face is left for Normal, Normal Homing, Normal Tilted and
1.5U Normal. Thumb and 1.5U Thumb Slope use the opposite rear face for
better stability.

This orientation still keeps contact marks small while giving both thumb
profiles a more secure base. Use tree supports and an **8 mm brim** for
the first print.

## Quality-tuned Bambu project — PLA

`KLP_Lame_6Cap_A1mini_PLA_Quality.3mf` packages the same six trial caps
as separately selectable objects and embeds a conservative A1 mini /
0.4 mm nozzle / PLA process configuration. The matching importable
process preset is `KLP_Lame_A1mini_PLA_Quality_Process.json`.

The embedded profile uses 0.12 mm layers, slower first-layer and wall
speeds, an 8 mm outer brim, and dense Normal/Snug support interfaces. It
is intended to diagnose and improve the rough support-facing surfaces
near the build plate. This profile prioritizes underside quality rather
than minimum support material. For a support-minimized print, disable
automatic supports and paint Tree supports only beneath the stem boss
and the first floating edges.

## Full 36-key Corne set

| Bill of materials | Qty |
| :---------------- | --: |
| Normal Tilted (top & bottom rows) | 20 |
| Normal (home row) | 8 |
| Normal Homing (index home keys) | 2 |
| Thumb (1U, two per hand) | 4 |
| 1.5U Thumb Slope (one per hand) | 2 |
| **Total** | **36** |

| File | Orientation | Notes |
| :--- | :--- | :--- |
| `Plate_A1mini_SideDown.stl` | **側面を下** — cap laid on a side wall | Layer lines run across the top, so **no tactile layer bumps on the touch surface** (best feel). Needs supports for the overhangs; the drafted side wall gives a flat, stable base. Recommended. |
| `Plate_A1mini_BottomDown.stl` | **底面を下** — cap upright, stem/bottom toward the bed | Simplest layout, top faces up. The top prints as stacked layers (visible rings / slight tactile bumps). Rests on the Ø5.5 MX stem boss + skirt; use supports + a brim. |

Both plates fit the bed:

- SideDown : ~159 × 84 mm, 16.4 mm tall (10 cols)
- BottomDown: ~161 × 103 mm, 8.7 mm tall (8 cols)

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
./build.sh                         # build caps and all three plates
python3 make_plate.py Plates test  # trial plate only
python3 make_plate.py Plates full  # two 36-key plates only
python3 make_plate.py Plates       # all three plates
```

Edit the `BOM` list in `make_plate.py` to change counts (e.g. if your
thumb layout uses the 1.5U `Thumb_Slope`). Edit `TEST_VARIANTS` to
change the trial set; its minimum-contact orientation is recalculated
from each STL automatically.

Regenerate the quality-tuned 3MF and its standalone preset from the
repository root:

```sh
python3 OpenSCAD/make_quality_3mf.py \
  --repo-root . \
  --output OpenSCAD/Plates/KLP_Lame_6Cap_A1mini_PLA_Quality.3mf \
  --preset-output OpenSCAD/Plates/KLP_Lame_A1mini_PLA_Quality_Process.json
```
