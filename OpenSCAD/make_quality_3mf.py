#!/usr/bin/env python3
"""Create a Bambu Studio-friendly 3MF for the six-cap KLP Lamé trial.

The geometry is regenerated from the individual STL files through the
repository's make_plate.py so each keycap remains a separately selectable
3MF object. A conservative A1 mini / 0.4 mm / PLA process configuration is
embedded as Metadata/project_settings.config.
"""

from __future__ import annotations

import argparse
import importlib.util
import json
import math
from pathlib import Path
import zipfile


VARIANTS = [
    "Normal",
    "Normal_Homing",
    "Normal_Tilted",
    "1.5U_Normal",
]

REAR_SIDE_DOWN_VARIANTS = {
    "Normal",
    "Normal_Homing",
    "Normal_Tilted",
}

DISPLAY_NAMES = {
    "Normal": "Normal",
    "Normal_Homing": "Normal Homing",
    "Normal_Tilted": "Normal Tilted",
    "1.5U_Normal": "1.5U Normal",
}


def load_plate_module(repo_root: Path):
    module_path = repo_root / "OpenSCAD" / "make_plate.py"
    spec = importlib.util.spec_from_file_location("klp_make_plate", module_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {module_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def arrange_caps(plate):
    caps = []
    for name in VARIANTS:
        source = Path(plate.STL_DIR) / f"{plate.PREFIX}{name}.stl"
        tris = plate.load(source)
        if name in REAR_SIDE_DOWN_VARIANTS:
            preferred_side = "rear"
        else:
            preferred_side = plate.TEST_SIDE_OVERRIDES.get(name)
        oriented, info = plate.prep_min_contact(
            tris, preferred_side=preferred_side
        )
        (mnx, mny, _), (mxx, mxy, _) = plate.bounds(oriented)
        caps.append(
            {
                "name": name,
                "display_name": DISPLAY_NAMES[name],
                "tris": oriented,
                "width": mxx - mnx,
                "depth": mxy - mny,
                "contact_area": info["contact_area"],
                "orientation": f"{info['side']} side down",
            }
        )

    cols = 3
    rows = [caps[i : i + cols] for i in range(0, len(caps), cols)]
    col_widths = [
        max(row[col]["width"] for row in rows if col < len(row))
        for col in range(cols)
    ]
    row_depths = [max(cap["depth"] for cap in row) for row in rows]
    total_width = sum(col_widths) + plate.GAP * (cols - 1)
    total_depth = sum(row_depths) + plate.GAP * (len(rows) - 1)

    x_centers = []
    x = -total_width / 2
    for width in col_widths:
        x_centers.append(x + width / 2)
        x += width + plate.GAP

    y = total_depth / 2
    arranged = []
    for row, depth in zip(rows, row_depths):
        cy = y - depth / 2
        for col, cap in enumerate(row):
            cap = dict(cap)
            cap["tris"] = plate.translate(cap["tris"], x_centers[col], cy, 0)
            arranged.append(cap)
        y -= depth + plate.GAP
    return arranged


def deduplicate_mesh(tris):
    vertices = []
    vertex_ids = {}
    triangles = []
    for tri in tris:
        ids = []
        for point in tri:
            # Values originate in 32-bit STL coordinates. Normalizing signed
            # zero makes exact tuple de-duplication deterministic.
            key = tuple(0.0 if value == 0 else float(value) for value in point)
            idx = vertex_ids.get(key)
            if idx is None:
                idx = len(vertices)
                vertex_ids[key] = idx
                vertices.append(key)
            ids.append(idx)
        triangles.append(tuple(ids))
    return vertices, triangles


def fmt(value: float) -> str:
    if abs(value) < 5e-10:
        value = 0.0
    return f"{value:.9g}"


def xml_escape(value: str) -> str:
    return (
        value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def model_xml(caps):
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<model unit="millimeter" xml:lang="ja-JP" '
        'xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">',
        "  <metadata name=\"Title\">KLP Lamé six-cap quality trial</metadata>",
        "  <metadata name=\"Designer\">KLP Lamé contributors</metadata>",
        "  <metadata name=\"Description\">A1 mini PLA quality-tuning plate; "
        "Saddle variants omitted.</metadata>",
        "  <metadata name=\"Application\">KLP quality 3MF packager</metadata>",
        "  <resources>",
    ]

    object_ids = []
    for object_id, cap in enumerate(caps, start=1):
        object_ids.append(object_id)
        vertices, triangles = deduplicate_mesh(cap["tris"])
        name = xml_escape(cap["display_name"])
        lines.append(f'    <object id="{object_id}" type="model" name="{name}">')
        lines.append(f'      <metadata name="name">{name}</metadata>')
        lines.append("      <mesh>")
        lines.append("        <vertices>")
        lines.extend(
            f'          <vertex x="{fmt(x)}" y="{fmt(y)}" z="{fmt(z)}"/>'
            for x, y, z in vertices
        )
        lines.append("        </vertices>")
        lines.append("        <triangles>")
        lines.extend(
            f'          <triangle v1="{a}" v2="{b}" v3="{c}"/>'
            for a, b, c in triangles
        )
        lines.append("        </triangles>")
        lines.append("      </mesh>")
        lines.append("    </object>")

    lines.append("  </resources>")
    lines.append("  <build>")
    # Put the already-arranged, origin-centred plate at the centre of the
    # A1 mini's 180 x 180 mm bed.
    transform = "1 0 0 0 1 0 0 0 1 90 90 0"
    lines.extend(
        f'    <item objectid="{object_id}" transform="{transform}" '
        'printable="true"/>'
        for object_id in object_ids
    )
    lines.append("  </build>")
    lines.append("</model>")
    return "\n".join(lines) + "\n"


def project_settings():
    # The three dominant changes are deliberately isolated: slower small-part
    # motion, a dense one-layer support interface gap, and stronger adhesion.
    return {
        "version": "02.07.01.57",
        "name": "project_settings",
        "from": "project",
        "printer_settings_id": "Bambu Lab A1 mini 0.4 nozzle",
        "print_settings_id": "KLP Lame 0.12 Quality - A1 mini PLA",
        "layer_height": "0.12",
        "initial_layer_print_height": "0.2",
        "line_width": "0.42",
        "initial_layer_line_width": "0.5",
        "outer_wall_line_width": "0.42",
        "inner_wall_line_width": "0.45",
        "wall_loops": "4",
        "top_shell_layers": "7",
        "top_shell_thickness": "0.8",
        "bottom_shell_layers": "6",
        "bottom_shell_thickness": "0",
        "sparse_infill_density": "50%",
        "sparse_infill_pattern": "crosshatch",
        "infill_wall_overlap": "15%",
        "initial_layer_speed": ["20"],
        "initial_layer_infill_speed": ["30"],
        "outer_wall_speed": ["40"],
        "inner_wall_speed": ["70"],
        "top_surface_speed": ["35"],
        "sparse_infill_speed": ["80"],
        "internal_solid_infill_speed": ["60"],
        "gap_infill_speed": ["50"],
        "bridge_speed": ["25"],
        "travel_speed": ["400"],
        "default_acceleration": ["2000"],
        "initial_layer_acceleration": ["500"],
        "initial_layer_travel_acceleration": ["3000"],
        "outer_wall_acceleration": ["800"],
        "inner_wall_acceleration": ["1500"],
        "top_surface_acceleration": ["800"],
        "travel_acceleration": ["5000"],
        "enable_overhang_speed": "1",
        "overhang_1_4_speed": ["30"],
        "overhang_2_4_speed": ["20"],
        "overhang_3_4_speed": ["15"],
        "overhang_4_4_speed": ["10"],
        "overhang_totally_speed": ["10"],
        "enable_support": "1",
        "support_type": "normal(auto)",
        "support_style": "snug",
        "support_on_build_plate_only": "1",
        "support_threshold_angle": "20",
        "support_top_z_distance": "0.12",
        "support_bottom_z_distance": "0.12",
        "support_object_xy_distance": "0.25",
        "support_interface_top_layers": "4",
        "support_interface_bottom_layers": "2",
        "support_interface_spacing": "0.2",
        "support_interface_pattern": "auto",
        "support_base_pattern": "rectilinear",
        "support_base_pattern_spacing": "2",
        "support_speed": ["50"],
        "support_interface_speed": ["25"],
        "brim_type": "outer_only",
        "brim_width": "8",
        "brim_object_gap": "0.05",
        "seam_position": "aligned",
        "override_filament_scarf_seam_setting": "1",
        "seam_slope_type": "none",
        "enable_prime_tower": "0",
        "resolution": "0.012",
        "enable_arc_fitting": "1",
        "elefant_foot_compensation": "0",
    }


def process_preset(settings):
    preset = dict(settings)
    preset.update(
        {
            "type": "process",
            "name": "KLP Lame 0.12 Quality - A1 mini PLA",
            "from": "user",
            "inherits": "0.12mm Fine @BBL A1M",
            "instantiation": "true",
            "compatible_printers": ["Bambu Lab A1 mini 0.4 nozzle"],
        }
    )
    preset.pop("printer_settings_id", None)
    preset.pop("print_settings_id", None)
    return preset


def content_types_xml():
    return """<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>
</Types>
"""


def relationships_xml():
    return """<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Target="/3D/3dmodel.model" Id="rel-1" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>
</Relationships>
"""


def bounds(caps):
    points = [point for cap in caps for tri in cap["tris"] for point in tri]
    mins = tuple(min(point[i] for point in points) for i in range(3))
    maxs = tuple(max(point[i] for point in points) for i in range(3))
    return mins, maxs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--preset-output", type=Path)
    args = parser.parse_args()

    plate = load_plate_module(args.repo_root.resolve())
    caps = arrange_caps(plate)
    settings = project_settings()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(
        args.output, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9
    ) as archive:
        archive.writestr("[Content_Types].xml", content_types_xml())
        archive.writestr("_rels/.rels", relationships_xml())
        archive.writestr("3D/3dmodel.model", model_xml(caps))
        archive.writestr(
            "Metadata/project_settings.config",
            json.dumps(settings, ensure_ascii=False, indent=4) + "\n",
        )

    if args.preset_output:
        args.preset_output.parent.mkdir(parents=True, exist_ok=True)
        args.preset_output.write_text(
            json.dumps(process_preset(settings), ensure_ascii=False, indent=4)
            + "\n",
            encoding="utf-8",
        )

    (mnx, mny, mnz), (mxx, mxy, mxz) = bounds(caps)
    triangle_count = sum(len(cap["tris"]) for cap in caps)
    print(f"Created: {args.output}")
    print(f"Objects: {len(caps)}, triangles: {triangle_count}")
    print(
        "Bounds before bed-centre transform: "
        f"{mxx - mnx:.3f} x {mxy - mny:.3f} x {mxz - mnz:.3f} mm"
    )
    for cap in caps:
        print(
            f"  {cap['display_name']}: "
            f"{len(cap['tris'])} triangles, "
            f"{cap['orientation']}, "
            f"{cap['contact_area']:.1f} mm^2 contact"
        )


if __name__ == "__main__":
    main()
