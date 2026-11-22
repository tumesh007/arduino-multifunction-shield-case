// ============================================================================
// ARDUINO UNO R3 + HW-262 MULTIFUNCTION SHIELD — INTEGRATED BATTERY ENCLOSURE (v4.2)
// File: config.scad (Central Parametric Configuration & Geometric Assertions)
// Target Printer: Bambu Lab A1 Mini (180 x 180 x 180 mm, 0.4 mm nozzle, 0.2 mm layer)
// ============================================================================

$fn = 64;
EPS = 0.02;

// --- FDM MANUFACTURING & TOLERANCE PARAMETERS ---
nozzle_d              = 0.40;
layer_h               = 0.20;
fit_clearance         = 0.25;   // Mating & PCB clearance
loose_clearance       = 0.40;   // Battery & wiring clearance
wall_t                = 2.40;   // 6 perimeters @ 0.4 mm nozzle
floor_t               = 2.00;   // 10 layers @ 0.2 mm
top_plate_t           = 2.20;   // Front/Top plate nominal thickness
corner_r              = 4.00;   // Outer enclosure corner radius

// --- VERIFIED HARDWARE DIMENSIONS ---
// 1. Arduino Uno R3 PCB (Oriented with USB/DC edge at Y = max, Front UI edge at Y = 0)
uno_len               = 53.40;  // X-axis width in upright reading orientation
uno_wid               = 68.60;  // Y-axis length (USB/DC jacks at Y = uno_wid)
uno_pcb_t             = 1.60;
uno_usb_w             = 12.20;  // USB Type-B width
uno_usb_h             = 11.00;  // USB Type-B height above PCB
uno_usb_x             = 38.10;  // USB centerline from left X=0 edge (verified Uno R3)
uno_dc_d              = 9.20;   // Onboard Uno DC jack width
uno_dc_h              = 11.00;
uno_dc_x              = 7.60;   // Onboard DC jack centerline from left X=0 edge

// Standard Arduino Uno R3 Mounting Holes (mapped to upright X=[0..53.4], Y=[0..68.6])
uno_mount_holes = [
    [ 2.5, 14.0],
    [50.7, 15.3],
    [ 7.6, 66.1],
    [35.5, 66.1]
];
standoff_h            = 5.00;   // Bottom clearance under Uno PCB
standoff_od           = 6.40;
standoff_id           = 2.75;   // Self-tapping M3 / M2.5 pilot hole

// 2. HW-262 Multifunction Shield Stack Geometry
mfs_stack_pitch       = 11.20;  // [CONFIGURABLE] Top of Uno PCB to bottom of MFS PCB
mfs_pcb_t             = 1.60;

// 3. Battery Pack (VERIFIED from User's Previous Design Discussion)
bat_wid               = 43.60;  // X-axis width
bat_len               = 58.60;  // Y-axis length
bat_h                 = 29.90;  // Z-axis height
bat_bay_x             = bat_wid + 2 * loose_clearance; // 44.40 mm
bat_bay_y             = bat_len + 2 * loose_clearance; // 59.40 mm

// 4. Panel-Mount SPST Switch (VERIFIED Body Dimensions)
spst_body_l           = 21.00;  // Along rear panel X
spst_body_w           = 15.00;  // Along rear panel Z
spst_body_d           = 15.00;  // Depth into rear service bay
spst_cutout_l         = 19.40;  // [CONFIGURABLE] Snap-in bezel cutout length
spst_cutout_w         = 13.20;  // [CONFIGURABLE] Snap-in bezel cutout width

// 5. Panel-Mount DC Barrel Jack 5.5 x 2.1 mm (VERIFIED Body Length, Wired Internally)
dc_panel_body_l       = 33.00;  // Recorded body length (~33 mm)
dc_panel_hole_d       = 8.20;   // [CONFIGURABLE] Panel mounting thread hole
dc_panel_nut_d        = 13.00;  // Clearance zone for internal retaining nut & solder lugs

// --- ENCLOSURE LAYOUT & INTERNAL DATUM COORDINATES ---
// Origin [0, 0, 0] = Bottom-Left-Outer corner of Bottom Housing
// X-axis: Left (Arduino + HW-262 Shield) -> Structural Divider -> Right (Battery Bay)
// Y-axis: Front (S1-S3 Buttons at Y=0 edge) -> Rear (USB, SPST Switch & Internal DC Jack Cavity)
// Z-axis: Bottom outer face (Z=0) -> Internal Top Plate Datum (Z=39.80) -> Outer Face (Z=42.00)

service_bay_y         = 24.00;  // Rear cavity depth (>= 22 mm to clear internal DC barrel plug + 33mm jack)
divider_t             = 2.00;   // Internal structural wall separating Arduino and Battery

uno_x0                = wall_t + fit_clearance;                    // 2.65 mm
uno_y0                = wall_t + fit_clearance;                    // 2.65 mm
uno_z_bottom          = floor_t + standoff_h;                      // 7.00 mm
uno_z_top             = uno_z_bottom + uno_pcb_t;                  // 8.60 mm
mfs_z_bottom          = uno_z_top + mfs_stack_pitch;               // 19.80 mm
mfs_z_top             = mfs_z_bottom + mfs_pcb_t;                  // 21.40 mm

bat_x0                = uno_x0 + uno_len + fit_clearance + divider_t; // 58.30 mm
bat_y0                = wall_t;                                       // 2.40 mm

encl_x                = bat_x0 + bat_bay_x + wall_t;               // 105.10 mm
encl_y                = max(uno_y0 + uno_wid + service_bay_y, bat_y0 + bat_bay_y) + wall_t; // 97.65 mm

encl_total_h          = 42.00;
base_wall_h           = encl_total_h - top_plate_t;                // 39.80 mm
lip_h                 = 2.40;
lip_t                 = 1.10;

z_plate_inner         = encl_total_h - top_plate_t;                // 39.80 mm (Mechanical Datum)
z_plate_outer         = encl_total_h;                              // 42.00 mm

// --- VERIFIED HW-262 MULTIFUNCTION SHIELD UI & BUTTON COORDINATES ---
// Relative to Uno origin [0, 0] in upright orientation (53.4 mm wide x 68.6 mm tall)
mfs_disp_x            = 12.00;  // 4-Digit 7-Segment Display left edge
mfs_disp_y            = 48.50;  // 4-Digit 7-Segment Display bottom edge
mfs_disp_w            = 30.40;
mfs_disp_h            = 14.20;
mfs_disp_top_h        = 7.20;   // Height above MFS PCB top

mfs_buzzer_x          = 22.50;  // Piezo buzzer center (LS1)
mfs_buzzer_y          = 30.50;
mfs_buzzer_d          = 12.00;

mfs_pot_x             = 11.50;  // Blue trimpot center
mfs_pot_y             = 25.00;
mfs_pot_d             = 10.00;

// Verified 9.2 mm Button Pitch for S1, S2, S3 along front edge + RESET shifted +3.0 mm up!
btn_pitch             = 9.20;   // VERIFIED by user measurement
s1_x                  = 13.00;  // [CONFIGURABLE] S1 center X from left PCB edge
s1_y                  = 7.00;   // [CONFIGURABLE] S1-S3 row Y from front PCB edge
rst_x                 = 47.20;  // [CONFIGURABLE] RESET center X (right of 7-segment display)
rst_y                 = 58.50;  // UPDATED (+3.00 mm above previous 55.50 mm position)

// Button Array: [Name, Rel_X_on_Uno, Rel_Y_on_Uno, Tactile_Switch_Height_above_MFS_PCB]
mfs_buttons = [
    ["S1_A1", s1_x,                 s1_y,  5.00],
    ["S2_A2", s1_x + btn_pitch,     s1_y,  5.00],
    ["S3_A3", s1_x + 2 * btn_pitch, s1_y,  5.00],
    ["RST",   rst_x,                rst_y, 5.00]
];

// --- CRITICAL INTEGRATED BUTTON PARAMETERS (Tuned for 9.2 mm Pitch) ---
btn_cap_d             = 6.40;   // Sized cleanly so adjacent 9.2 mm pitch bores never overlap
btn_cap_h             = 1.40;
btn_plunger_d         = 4.20;   // Internal plunger stem diameter
btn_travel            = 0.65;   // Free air gap between plunger tip and switch actuator
btn_radial_clear      = 0.45;   // Annular slot clearance around cap & flexure
btn_flexure_t         = 0.60;   // 3 layers @ 0.2 mm — living hinge printed flush on bed
btn_flexure_w         = 1.10;   // Width of dual serpentine flexure arms
btn_sacrificial_tie   = 0.40;   // Single-extrusion breakaway stabilizer tie
btn_use_sacrificial   = true;

btn_bore_rx           = 4.05;   // 2 * 4.05 = 8.10 mm < 9.20 mm pitch -> 1.10 mm solid rib between buttons
btn_bore_ry           = 5.10;   // Elliptical/stadium flexure pocket along Y gives full flexure compliance

function calc_plunger_length(sw_h) =
    (z_plate_inner - (mfs_z_top + sw_h)) - btn_travel;

// --- CORNER SCREW BOSSES ---
boss_d                = 7.20;
boss_hole_d           = 2.75;
boss_clear_d          = 3.40;
boss_head_d           = 6.00;
boss_head_depth       = 1.20;
corner_boss_coords = [
    [wall_t + boss_d/2 + 0.4,          wall_t + boss_d/2 + 0.4],
    [encl_x - wall_t - boss_d/2 - 0.4, wall_t + boss_d/2 + 0.4],
    [wall_t + boss_d/2 + 0.4,          encl_y - wall_t - boss_d/2 - 0.4],
    [encl_x - wall_t - boss_d/2 - 0.4, encl_y - wall_t - boss_d/2 - 0.4]
];

// --- BATTERY CANTILEVER SNAP-ARM ---
snap_arm_t            = 1.60;
snap_arm_w            = 10.00;
snap_hook_overhang    = 1.40;
snap_z_top            = floor_t + bat_h + loose_clearance; // 32.30 mm

// --- BULLETPROOF GEOMETRIC ASSERTIONS ---
assert(encl_x <= 180 && encl_y <= 180 && encl_total_h <= 180, "ERROR: Exceeds Bambu A1 Mini 180mm build volume!");
assert(2 * btn_bore_rx + 0.80 <= btn_pitch, "ERROR: Adjacent button flexure bores overlap at 9.2mm pitch!");
assert(snap_z_top < z_plate_inner - 1.0, "ERROR: Battery interferes with Top Plate!");
assert(mfs_z_top + mfs_disp_top_h < z_plate_inner, "ERROR: 7-Segment Display collides with Top Plate!");
assert(service_bay_y >= 22.0, "ERROR: Rear service bay < 22mm; insufficient room for internal DC plug + 33mm jack!");
for (b = mfs_buttons) {
    let(plen = calc_plunger_length(b[3])) {
        assert(plen > 2.0, str("ERROR: Plunger ", b[0], " length invalid (", plen, " mm)!"));
    }
}
