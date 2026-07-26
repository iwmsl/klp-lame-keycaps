#!/usr/bin/env bash
# Renders every stem/size/variant combination of the KLP Lamé Angular
# keycap to OpenSCAD/STL/, plus a preview image.
#
# Requirements: openscad (CLI). On headless machines, xvfb-run is used
# automatically for the preview image if a display is not available.
set -euo pipefail
cd "$(dirname "$0")"

SCAD=klp-lame-angular.scad
OUT=STL

# name -> "-D overrides"
declare -A VARIANTS=(
  [Normal]='-D variant="normal"'
  [Normal_Homing]='-D variant="normal" -D homing="bar"'
  [Normal_Tilted]='-D variant="tilted"'
  [1.5U_Normal]='-D variant="normal" -D key_units=1.5'
)

for stem in choc mx; do
  for size in choc mx; do
    Stem=$([ "$stem" = choc ] && echo Choc || echo MX)
    Size=$([ "$size" = choc ] && echo Choc || echo MX)
    dir="$OUT/$Stem Stem + $Size Size"
    mkdir -p "$dir"
    for name in "${!VARIANTS[@]}"; do
      out="$dir/${Stem}_Stem_${Size}_Size_Angular_${name}.stl"
      echo "==> $out"
      # shellcheck disable=SC2086
      openscad -o "$out" \
        -D "stem_type=\"$stem\"" -D "size_type=\"$size\"" \
        ${VARIANTS[$name]} "$SCAD" 2>/dev/null
    done
  done
done

echo "==> A1 mini print plates"
python3 make_plate.py Plates

echo "==> preview image"
RUN=""
if [ -z "${DISPLAY:-}" ] && command -v xvfb-run >/dev/null; then RUN="xvfb-run -a"; fi
$RUN openscad -o ../Assets/KLP-Lame-Angular-Preview.png \
  --imgsize 1600,1100 --projection p \
  --camera 75,-95,85,0,0,0 \
  preview.scad 2>/dev/null || echo "preview render skipped (no GL available)"

echo "done."
