# Print plates — KLP Lamé Angular (Bambu Lab A1 mini)

Ready-to-slice plates for the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Start with the nine-cap trial plate before
committing to a full 36-key Corne v4 Mini set.

Caps used: **MX Stem + Choc Size**.

## Trial plate — one of each variant

`Plate_A1mini_Test_OneEach_MinContact.stl` contains one of every variant
currently built by `build.sh` (nine caps total). Each mesh is inspected
individually and placed on the **smallest usable flat outer side face**.
Inner cavity walls and tiny rounded/chamfer faces are excluded, so the
choice is a real supporting face rather than an unstable edge or point.

- Size: approximately **56.6 × 55.5 × 23.2 mm**
- Actual contact area per cap: approximately **32.7–46.7 mm²**
- Layout, viewed from above:

| Row | Left | Centre | Right |
| :-- | :--- | :----- | :---- |
| 1 | Normal | Normal Homing | Normal Tilted |
| 2 | Thumb | Saddle | Saddle Homing |
| 3 | Saddle Tilted | 1.5U Normal | 1.5U Thumb Slope |

The selected face is left for Normal, Normal Homing, Normal Tilted,
Saddle, Saddle Homing, Saddle Tilted and 1.5U Normal. Thumb and 1.5U
Thumb Slope use the front face because it is smaller.

This orientation intentionally trades adhesion for a smaller contact
mark. Use tree supports and an **8 mm brim** for the first print.

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
