# Print plates — KLP Lamé Angular (Bambu Lab A1 mini)

Ready-to-slice plates for the angular remix, pre-arranged to fit the
A1 mini's 180 × 180 mm bed. Start with the four-cap trial plate, then
print the whole set with `Plate_A1mini_Corne36_Tipped.stl`.

Caps used: **MX Stem + MX Tight Size** (18.5 × 18.5 mm footprint,
chiclet sidewalls, for the 19.05 mm pitch — 0.55 mm between caps at the
rim, 2.05 mm between their top faces).

## Corne set — `Plate_A1mini_Corne36_Tipped.stl` (recommended, support-free)

The 36 caps **tipped 48° from upright**, printed with **no support**.

Tipping plays the cap's horizontal faces off against its vertical ones.
The rim underside and the cavity ceiling — about 340 mm² between them —
end up at 90° minus the tip angle; the cross recess inside the stem boss
ends up at the tip angle itself. The two always sum to 90°, so one of
them is at 45° or worse whatever angle is picked, and the margin belongs
to the large exposed faces rather than a 1.2 mm slot buried in the boss.
That leaves a window between two cliffs, and the visible shell is
flattest across the middle of it:

| Tip | Outer worst | Outer over 45° | Inner over 45° | |
| --: | ----------: | -------------: | -------------: | :-- |
| 45° | 45.0° |  65.9 mm² | 157.1 mm² | horizontals go over |
| 46° | 44.0° |   0.0 mm² |  15.1 mm² | |
| **48°** | **42.0°** | **0.0 mm²** | **15.9 mm²** | |
| 50° | 43.0° |   0.0 mm² |  17.2 mm² | |
| 52° | 45.0° | 130.3 mm² |  20.3 mm² | tilted rear wall goes over |

Nothing on the outside of any cap in the set — 1U, 1.5U, tilted or not —
passes **42°** at 48°, so the plate prints with no support at all and
with three degrees in hand at both ends of the window. The upper cliff
is the tilted cap: its rear wall stands only 7° off vertical, against
11.5° on a flat cap, because the tilt raises the crown without moving
the rim.

- Size: approximately **164.2 × 114.0 × 16.0 mm** — fits the bed
- **Supports off.** Use a **3 mm brim**: the caps balance on an edge,
  and at 3 mm apart a wider brim fuses all 36 into one sheet
- The layers cross the dish steeply, so the touch surface comes out free
  of the concentric terraces an upright print leaves
- What is *not* solved: 15.9 mm² inside the stem boss, the walls of the
  1.2 mm cross recess, sitting at exactly the tip angle. It is hidden
  inside the switch and bridges to its own opposite wall, but the socket
  may droop enough to tighten the fit. Trim it with X-Y hole
  compensation if so.
- Re-check any change with `python3 overhang.py --tip=48 "../STL/MX Stem
  + MX Tight Size/"*.stl`, or `--sweep` for the table above. Set
  `TIP_ANGLE_DEG` in `make_plate.py` to try another angle.

This depends on `bottom_edge_round = 0` in the .scad. That 45° chamfer
existed only to relieve elephant foot on a bottom-down print, and
tipped ~45° it becomes a dead-horizontal shelf on the outside of the
cap — the single worst overhang on the whole model.

## Corne set — `Plate_A1mini_Corne36_BottomDown.stl` (needs support)

All 36 caps **upright**, bottom/stem toward the bed. The alternative if
edge-balanced caps are a problem on your machine: an upright cap tapers
inward as it rises, so nothing above the first 3 mm can curl into the
nozzle at all.

- Size: approximately **152.1 × 169.0 × 10.6 mm** — fits the bed
- The cap rests on the Ø5.5 stem boss with the rim 1.3 mm clear, so it
  **needs support** under the rim and inside the cavity, plus a brim
- Cost: the dish prints as stacked layers, leaving faint concentric
  terraces on the touch surface. At 0.08 mm layers the steps are
  ~0.27 mm wide at the dish edge and wider toward the centre.

## Trial plate — all variants

`Plate_A1mini_Test_OneEach_RearSideDown.stl` contains one of every
variant (four caps total), each laid on its **rear outer side face** —
the upper side in the model's top view. Inner cavity walls and tiny
rounded/chamfer faces are excluded, so the choice is a real supporting
face rather than an unstable edge or point. After the contact face is
chosen, every cap is rotated only within the build-plate plane so all
stem axes point the same way. This final rotation does not change
contact area or stability.

- Size: approximately **32.4 × 49.5 × 18.4 mm**
- Actual contact area per cap: **58.8–130.6 mm²**
- Layout, viewed from above:

| Row | Left | Middle | Right |
| :-- | :--- | :----- | :---- |
| 1 | Normal | Normal Homing | Normal Tilted |
| 2 | 1.5U Normal | | |

Use tree supports and an **8 mm brim** for the first print.

## Quality-tuned Bambu project — PLA

`KLP_Lame_4Cap_A1mini_PLA_Quality.3mf` packages the same four trial caps
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
| Normal (home row 8 + 1U thumbs 4) | 12 |
| Normal Homing (index home keys) | 2 |
| 1.5U Normal (one thumb per hand) | 2 |
| **Total** | **36** |

## Slicing (Bambu Studio, A1 mini)

- Nozzle 0.4 mm, layer height 0.08–0.12 mm, walls ≥ 4, infill 100 %.
- **Supports: off** for the Tipped plate — that is the point of 48°.
  BottomDown does need support, under the rim and inside the cavity.
- Material: PLA or PETG.
- Brim: **3 mm** on the Tipped plate (caps are only 3 mm apart, so a
  wider brim fuses them all into one sheet and is a chore to remove).
  8 mm is fine on the four-cap trial plate, where there is room.
- If the switch fit is tight/loose, tune Bambu Studio's *X-Y hole
  compensation* by ±0.05 mm, or edit the stem params in the `.scad`.

## Regenerating

Plates are generated from the built STLs:

```sh
./build.sh                          # build caps, every plate and the overhang check
python3 make_plate.py Plates test   # trial plate only
python3 make_plate.py Plates full   # the two full-set plates
python3 make_plate.py Plates        # all of them
```

Edit `BOM` in `make_plate.py` to change counts. Edit `TEST_VARIANTS` to
change the trial set.

Regenerate the quality-tuned 3MF and its standalone preset from the
repository root:

```sh
python3 OpenSCAD/make_quality_3mf.py \
  --repo-root . \
  --output OpenSCAD/Plates/KLP_Lame_4Cap_A1mini_PLA_Quality.3mf \
  --preset-output OpenSCAD/Plates/KLP_Lame_A1mini_PLA_Quality_Process.json
```
