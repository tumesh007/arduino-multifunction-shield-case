# Bambu Lab A1 Mini Slicing & Print Guide (v4.4 Enclosure)

Target Machine: **Bambu Lab A1 Mini**  
Build Volume: **180 × 180 × 180 mm**  
Build Plate: **WOL3D Gold Textured PEI Plate**  
Slicer: **Bambu Studio** or **OrcaSlicer**  

---

## 1. Quick Profile Checklist

| Slicer Parameter | Value | Critical Notes |
|---|---|---|
| **Layer Height** | **0.20 mm** | **MANDATORY.** Living hinge = 0.60 mm (exactly 3 layers). Breakaway tie = 0.40 mm (2 layers). Slicing at 0.16 or 0.24 mm breaks hinge compliance. |
| **First Layer Height** | **0.20 mm** | Ensures clean layer boundary on PEI plate. |
| **Wall Loops** | **6** | 6 × 0.40 mm = 2.40 mm solid walls. Eliminates weak infill voids in outer shell. |
| **Top Shell Layers** | **5** (1.0 mm) | Solid ceiling over battery compartment and service bay. |
| **Bottom Shell Layers** | **5** (1.0 mm) | Solid floor for rigid Uno R3 standoffs. |
| **Infill Density** | **20%** | Gyroid pattern recommended. |
| **Supports** | **DISABLED** | 0 supports required. Chamfers and bridges self-support. |
| **Brim** | **Base: 5 mm Outer** / **Lid: None** | Prevents sharp corner lifting of deep base box on textured PEI. |
| **Elephant Foot Compensation**| **0.15 mm** | Prevents dimensional flare on mating lip and button clearances. |

---

## 2. Material Selection & Temperature Profiles

### Recommended: PETG (for Lid & Living Hinge)
- **Why:** Living-hinge serpentine flexures undergo repeated bending strain. PETG elongation at break (~10–15%) prevents micro-fracturing and fatigue failure.
- **Nozzle Temperature:** 245°C (First Layer: 250°C)
- **Bed Temperature:** 70°C–75°C on WOL3D Textured PEI
- **Cooling Fan:** 20%–40% (keep cooling low to maintain inter-layer tensile strength on the battery cantilever arm).

### Alternative: Tough PLA / PLA Pro
- Acceptable for Base Housing.
- If used for Lid, expect hinge fatigue failure after ~50–100 button presses. Standard PLA is too brittle for living-hinge mechanisms.
- **Nozzle Temperature:** 215°C–220°C
- **Bed Temperature:** 60°C–65°C on WOL3D Textured PEI

---

## 3. Plate Layout & Print Orientations

### Part 1: Bottom Housing (`stl/bottom_housing.stl`)
- **Orientation:** Floor flat on plate (Z = 0 at bottom outer face).
- **Standoffs & Cantilever:** Pointing upward into +Z.
- **Brim:** Add 5 mm outer brim.
- **Print Time:** ~2 hr 45 min on Bambu A1 Mini Standard Speed.

### Part 2: Front Plate Lid (`stl/front_plate_integrated_buttons.stl`)
- **Orientation:** Exterior cosmetic face flat on plate (Z = 0 at top outer face).
- **Plungers:** Pointing upward into +Z.
- **Brim:** None needed (large contact surface).
- **First Layer Speed:** Cap first layer at 30 mm/s for clean extrusion around button slot perimeters.
- **Print Time:** ~1 hr 15 min on Bambu A1 Mini Standard Speed.

---

## 4. Post-Print Living Hinge Activation

1. Remove Front Plate from PEI plate after cooling below 35°C.
2. Inspect the 4 button caps (S1, S2, S3, RST). Each button is stabilized during printing by two 0.40 mm sacrificial breakaway ties along the X-axis (`btn_sacrificial_tie`).
3. Using an X-Acto knife or sharp razor, make two vertical cuts through these breakaway ties on each button cap.
4. Gently depress each button 2–3 times with your thumb. The serpentine flexures will seat into their operational travel (0.65 mm stroke).
