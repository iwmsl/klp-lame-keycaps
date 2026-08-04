# Print plates — KLP Lamé Angular (Bambu Lab A1 mini)

Ready-to-slice plates for the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Start with the four-cap trial plate, then
print the whole set with `Plate_A1mini_Corne36_Tipped.stl`.

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

## Corne set — `Plate_A1mini_Corne36_BottomDown.stl` (recommended)

All 36 caps **upright**, bottom/stem toward the bed. An upright cap
tapers inward as it rises, so every outward-leaning surface it has —
the bottom rim, its chamfer and the cavity underside, 174.5 mm² in
total — sits in the **bottom 3 mm**, over support, on faces that end up
hidden inside the switch. Above 3 mm there is none at all, so no
perimeter can curl up into the nozzle.

- Size: approximately **149.5 × 165.0 × 9.1 mm** — fits the bed
- The cap rests on the Ø5.5 stem boss with the rim 1.3 mm clear, so it
  needs support under the rim and inside the cavity, plus a brim
- Cost: the dish prints as stacked layers, leaving faint concentric
  terraces on the touch surface. At 0.08 mm layers the steps are
  ~0.27 mm wide at the dish edge and wider toward the centre.

## Corne set — `Plate_A1mini_Corne36_Tipped.stl` (smooth dish)

The same 36 caps **tipped 70° from upright** rather than laid flat on a
wall. Laying a cap flat sounds ideal but is the worst of both worlds:
the silhouette still has to grow from the small contact patch out to
the cap's full width, only now it does so within the first millimetre
or two, so the typical overhang runs ~66° and the outer perimeter
curls up into the nozzle. Tipping part-way spreads that same growth
over far more height.

Measured typical (p90) overhang per 0.2 mm layer:

| Tip from upright | Height | Typical overhang |
| ---------------: | -----: | ---------------: |
| 0° (upright) | 6.3 mm | 88° |
| 45° | 14.5 mm | 55° |
| **70°** | **17.3 mm** | **~47°** |
| 90° (flat on a wall) | 18.0 mm | 66° |

The optimum is broad and sits between 65° and 75° — the same range the
original KLP Lamé recommends. At 70° the layers still cross the dish
steeply, so the touch surface keeps the smooth finish that an upright
print cannot give.

- Size: approximately **152.5 × 90.5 × 17.3 mm** — fits the bed
- Each cap balances on an edge rather than a face, so this plate needs
  supports and a brim more than the upright one does
- Set `TIP_ANGLE_DEG` in `make_plate.py` to try another angle

## Full 36-key Corne set

| Bill of materials | Qty |
| :---------------- | --: |
| Normal Tilted (top & bottom rows) | 20 |
| Normal (home row 8 + 1U thumbs 4) | 12 |
| Normal Homing (index home keys) | 2 |
| 1.5U Normal (one thumb per hand) | 2 |
| **Total** | **36** |

## Slicing (Bambu Studio, A1 mini)

- Nozzle 0.4 mm, layer height 0.08–0.12 mm, walls ≥ 4, infill 100 %.
- **Supports: on, type Tree (auto).** All orientations have overhangs
  (the hollow underside / stem). BottomDown needs support under the
  rim and inside the cavity; Tipped under the whole overhanging side.
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
