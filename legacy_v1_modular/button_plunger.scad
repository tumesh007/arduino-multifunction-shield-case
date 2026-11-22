// =============================================================================
// button_plunger.scad
// Snap-in removable button plunger for Arduino Multifunction Shield.
// 
// Each plunger is a separate printed part that inserts from the INSIDE of the
// lid, snaps into place, and remains captive. No springs, no glue, no screws.
//
// Design: circular cap (8 mm) + guide shaft (4.8 mm) + snap collar + rounded tip
// The plunger relies on gravity and the tactile switch return force.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Derived plunger geometry (calculated from config.scad)
// ---------------------------------------------------------------------------

// Z position of shield PCB (top of Arduino headers)
button_pcb_z = arduino_position_z + arduino_enclosure_height;

// Z position of tactile switch button top
button_top_z = button_pcb_z + 5.0;  // typical SMD tactile switch height

// Z position of lid top surface
lid_top_z = bottom_thickness + required_internal_height + lid_thickness;

// Z position of lid underside
lid_bottom_z = bottom_thickness + required_internal_height;

// Z position of plunger tip center when at rest (above button by free travel)
plunger_tip_center_z = button_top_z + plunger_free_travel + plunger_tip_diameter / 2;

// Total shaft length from cap bottom to tip center
plunger_shaft_length = lid_top_z - plunger_tip_center_z;

// Length of shaft above the snap collar (from cap bottom to collar top)
plunger_upper_shaft = 1.0;

// Length of shaft below the snap collar (from collar bottom to tip center)
plunger_lower_shaft = plunger_shaft_length - plunger_upper_shaft - snap_collar_height;

// Z position of snap collar center when assembled
snap_collar_center_z = lid_top_z - plunger_upper_shaft - snap_collar_height / 2;

// Z position of guide tube bottom
 guide_tube_bottom_z = lid_bottom_z - guide_length;

// ---------------------------------------------------------------------------
// Single snap-in plunger — removable push button
// ---------------------------------------------------------------------------
// position: [x, y] relative to the Arduino feature origin
// This module creates the plunger as a positive geometry part.
// ---------------------------------------------------------------------------
module snap_in_plunger(position) {
    translate([position[0], position[1], 0]) {

        // --- 1. External finger cap ---
        // Circular, slightly concave top, rounded edge
        translate([0, 0, lid_top_z])
            difference() {
                // Main cap body
                cylinder(d = plunger_cap_diameter, h = 1.5, $fn = $fn);
                // Concave top (subtle dish for finger comfort)
                translate([0, 0, 1.0])
                    sphere(d = plunger_cap_diameter * 3, $fn = $fn);
            }

        // Rounded edge on cap (fillet)
        translate([0, 0, lid_top_z + 1.5])
            rotate_extrude($fn = $fn)
                translate([plunger_cap_diameter / 2 - 0.8, 0])
                    circle(r = 0.8, $fn = $fn);

        // --- 2. Guide shaft (upper, above collar) ---
        translate([0, 0, lid_top_z - plunger_upper_shaft])
            cylinder(d = plunger_shaft_diameter, h = plunger_upper_shaft + 0.01, $fn = $fn);

        // --- 3. Snap collar ---
        // Flexible retaining collar with lead-in chamfer
        translate([0, 0, lid_top_z - plunger_upper_shaft - snap_collar_height])
            union() {
                // Main collar body
                cylinder(d = snap_collar_diameter, h = snap_collar_height, $fn = $fn);

                // Lead-in chamfer (top) for insertion from inside
                translate([0, 0, snap_collar_height - 0.01])
                    cylinder(
                        d1 = plunger_shaft_diameter,
                        d2 = snap_collar_diameter,
                        h = 0.4,
                        $fn = $fn
                    );

                // Lead-in chamfer (bottom) for removal
                translate([0, 0, -0.39])
                    cylinder(
                        d1 = snap_collar_diameter,
                        d2 = plunger_shaft_diameter,
                        h = 0.4,
                        $fn = $fn
                    );
            }

        // --- 4. Guide shaft (lower, below collar) ---
        translate([0, 0, plunger_tip_center_z])
            cylinder(d = plunger_shaft_diameter, h = plunger_lower_shaft + 0.01, $fn = $fn);

        // --- 5. Contact tip ---
        // Rounded hemisphere for smooth button contact
        translate([0, 0, plunger_tip_center_z])
            sphere(d = plunger_tip_diameter, $fn = $fn);

        // --- 6. Travel stop shoulder ---
        // Prevents plunger from escaping when pressed
        // Located so that at maximum travel, it hits the guide tube bottom
        shoulder_z = guide_tube_bottom_z + 0.5;
        translate([0, 0, shoulder_z])
            cylinder(
                d = plunger_shaft_diameter + 1.0,
                h = 0.8,
                $fn = $fn
            );
    }
}

// ---------------------------------------------------------------------------
// Plunger guide bore — through-hole in lid with snap groove
// ---------------------------------------------------------------------------
// Creates the hole and groove that the plunger snaps into.
// Subtractive module: use with difference().
// ---------------------------------------------------------------------------
module plunger_guide_bore(position) {
    translate([position[0], position[1], -0.01]) {

        // Main bore through lid
        cylinder(d = plunger_guide_bore_diameter, h = lid_thickness + 0.02, $fn = $fn);

        // Snap groove — circular recess for the collar
        translate([0, 0, lid_thickness + plunger_snap_groove_offset - snap_collar_height / 2])
            rotate_extrude($fn = $fn)
                translate([plunger_guide_bore_diameter / 2 - 0.01, 0])
                    polygon([
                        [0, 0],
                        [plunger_snap_groove_depth + 0.02, 0],
                        [plunger_snap_groove_depth + 0.02, snap_collar_height],
                        [0, snap_collar_height]
                    ]);

        // Chamfer at top of bore (for easy insertion from inside)
        translate([0, 0, lid_thickness - 0.5])
            cylinder(d1 = plunger_guide_bore_diameter, d2 = plunger_guide_bore_diameter + 1.0, h = 0.52, $fn = $fn);
    }
}

// ---------------------------------------------------------------------------
// Plunger guide tube — extends below lid to minimize wobble
// ---------------------------------------------------------------------------
// Positive module: adds material to the lid underside.
// ---------------------------------------------------------------------------
module plunger_guide_tube(position) {
    translate([position[0], position[1], -guide_length]) {
        difference() {
            // Outer tube
            cylinder(d = guide_outer_diameter, h = guide_length + 0.01, $fn = $fn);
            // Inner bore
            translate([0, 0, -0.01])
                cylinder(d = guide_inner_diameter, h = guide_length + 0.02, $fn = $fn);
        }
    }
}

// ---------------------------------------------------------------------------
// Plunger retaining shoulder — at bottom of guide tube
// ---------------------------------------------------------------------------
// Prevents the plunger from falling out through the bottom.
// Positive module: adds a ring at the guide tube bottom.
// ---------------------------------------------------------------------------
module plunger_retaining_shoulder(position) {
    translate([position[0], position[1], -guide_length - 0.01]) {
        difference() {
            cylinder(d = guide_outer_diameter, h = 0.8, $fn = $fn);
            translate([0, 0, -0.01])
                cylinder(d = plunger_shaft_diameter + plunger_clearance * 2, h = 0.82, $fn = $fn);
        }
    }
}

// ---------------------------------------------------------------------------
// All plungers (for assembly preview)
// ---------------------------------------------------------------------------
module all_plungers() {
    for (pos = button_positions) {
        snap_in_plunger(pos);
    }
}

// ---------------------------------------------------------------------------
// All guide bores (subtractive, for the lid)
// ---------------------------------------------------------------------------
module all_plunger_guide_bores() {
    for (pos = button_positions) {
        plunger_guide_bore(pos);
    }
}

// ---------------------------------------------------------------------------
// All guide tubes (positive, for the lid underside)
// ---------------------------------------------------------------------------
module all_plunger_guide_tubes() {
    for (pos = button_positions) {
        plunger_guide_tube(pos);
    }
}

// ---------------------------------------------------------------------------
// All retaining shoulders (positive, for the lid underside)
// ---------------------------------------------------------------------------
module all_plunger_retaining_shoulders() {
    for (pos = button_positions) {
        plunger_retaining_shoulder(pos);
    }
}