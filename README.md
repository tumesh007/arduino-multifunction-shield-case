# Arduino Multifunction Shield Enclosure with Integrated Battery

[![Bambu Lab A1 Mini](https://img.shields.io/badge/3D_Printer-Bambu_Lab_A1_Mini-orange?logo=bambulab)](https://bambulab.com)
[![OpenSCAD](https://img.shields.io/badge/CAD-OpenSCAD-blue.svg)](https://openscad.org)
[![FreeCAD Audit](https://img.shields.io/badge/FreeCAD_Audit-28%2F28_PASS-brightgreen.svg)](https://freecad.org)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-lightgrey.svg)](LICENSE)

A production-quality, FDM-printable two-piece enclosure designed to house an **Arduino Uno R3**, a standard **Arduino Multifunction Shield**, and an **onboard battery pack**, engineered specifically for the 180 × 180 × 180 mm build plate of the Bambu Lab A1 Mini.

Verified and validated via OpenSCAD CGAL mesh audits and FreeCAD 1.1.3 manifold integrity checks (28/28 constraints passed).

---

## 1. Specifications & Geometry

| Component | Dimensions (L × W × H) | Notes |
|---|---|---|
| **Base Enclosure** | 117.60 × 98.40 × 43.60 mm | Independently printable; bottom-face down |
| **Top Plate (Lid)** | 114.00 × 94.80 × 6.00 mm | Anchored at Z = 0.00 mm for flat bed adhesion |
| **Total Assembled** | 117.60 × 98.40 × 46.60 mm | Fits comfortably within 180 × 180 mm bed |
| **Wall Thickness** | 2.4 mm nominal | Robust FDM shell with stepped mating lip |

---

## 2. Integrated Hardware & Interfaces

- **Microcontroller:** Arduino Uno R3 mounted on floor locating rails with 1.0 mm service margin.
- **Multifunction Shield:** Full UI integration:
  - Window aperture for 4-digit 7-segment LED display.
  - Three integrated guide tubes and plungers for tactile switches (S1, S2, S3).
  - Acoustic port for onboard piezo buzzer (widenable to 15 mm).
  - Analog trim potentiometer and header clearance.
- **Battery Compartment:** Dedicated positive retention pocket measuring **58.6 × 43.6 × 29.9 mm** located alongside the Arduino stack.
- **Power Switch:** Cutout for standard 22 mm rectangular SPST rocker switch (**19.9 × 12.0 mm**), with 7.0 mm added depth clearance avoiding rear-right screw boss collision and providing ≥20 mm terminal wiring service depth.
- **DC Input:** Panel-mount 5.5×2.1 mm DC barrel jack (33 mm body clearance) positioned in the battery partition zone above the battery top.

---

## 3. Slicing & 3D Printing Recommendations

- **Target Machine:** Bambu Lab A1 Mini (WOL3D Gold Textured PEI Plate).
- **Material:** PLA or PETG.
- **Nozzle:** 0.4 mm.
- **Layer Height:** 0.20 mm Standard.
- **Infill:** 15–20% (Gyroid or Grid).
- **Supports:** **None required.** Bridge spans and wall draft angles are designed to be self-supporting.
- **Adhesion:** Clean textured PEI sheet with dish soap and warm water; brim optional.

---

## 4. Repository Structure

```
.
├── config.scad            # Single source of truth for all parametric dimensions
├── base.scad              # Lower enclosure body with internal partition and mounts
├── top_plate.scad         # Upper bezel lid with button guides and display aperture
├── main.scad              # Complete assembly preview including hardware mockups
├── stl/
│   ├── base.stl           # Exported clean STL for lower enclosure (manifold)
│   ├── top_plate.stl      # Exported clean STL for top plate (manifold)
│   └── base.3mf           # Bambu Studio / OrcaSlicer project file
├── tools/                 # Validation and auditing test suite
│   ├── build_enclosure.py
│   ├── check_collision.py
│   ├── freecad_independent_audit.py
│   ├── full_engineering_audit.py
│   ├── validation_report.txt
│   └── patches_and_tests/ # Historical geometric clearance test scripts
├── docs/
│   ├── MASTER_PROMPT_REV_5.md # Full design engineering constraint specification
│   └── HANDOFF.txt            # Engineering handoff notes & dimension log
├── blender/
│   └── project.blend      # 3D mockup assembly in Blender
└── legacy_v1_modular/     # Earlier 15-file modular SCAD architecture (July 2026)
```

---

## 5. Verification & Audit Results

Validation confirmed through independent FreeCAD mesh analysis:
- **Base Manifoldness:** 0 non-manifold edges; `Mesh.isSolid() == True`.
- **Top Plate Manifoldness:** 0 non-manifold edges; clean CGAL single solid.
- **SPST Clearance:** Switch body front Y 65.60 mm vs battery rear Y 63.60 mm (>2.0 mm physical gap + unobstructed wiring region).
- **DC Jack Clearance:** Jack bottom Z 33.30 mm vs battery top Z 32.90 mm (positive clearance).

---

## 6. License

Licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](LICENSE).
