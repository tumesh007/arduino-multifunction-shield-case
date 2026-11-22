// =============================================================================
// buttons.scad
// Three button plungers with extended shafts, guide ribs, and travel stops
// for the Arduino Multifunction Shield pushbuttons.
// 
// The plungers extend from the lid top down to the tactile switches on the
// shield PCB. Support ribs prevent sagging and tilting during print and use.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Derived button geometry (do not modify — calculated from config.scad)
// ---------------------------------------------------------------------------

// Estimated height of SMD tactile switch button above shield PCB
button_switch_height_above_pcb = 5.0;

// Z position of the shield PCB (top of Arduino headers)
button_pcb_z = arduino_position_z + arduino_enclosure_height;

// Z position of the tactile switch button top
button_top_z = button_pcb_z + button_switch_height_above_pcb;

// Z position of the lid underside
lid_bottom_z = bottom_thickness + required_internal_height;

// Z position of the lid top surface
lid_top_z = lid_bottom_z + lid_thickness;

// Plunger tip position at rest (just above button, with pretravel gap)
plunger_tip_rest_z = button_top_z - button_pretravel;

// Total plunger length from lid top to tip
plunger_total_length = lid_top_z - plunger_tip_rest_z;

// Plunger shaft length (below lid)
plunger_shaft_length = plunger_total_length - button_plunger_height;

// Plunger shaft diameter (with clearance)
plunger_shaft_diameter = button_plunger_diameter - (button_plunger_clearance * 2);

// Support rib height (extends from lid underside to just above button)
support_rib_height = lid_bottom_z - (button_top_z + 1.0);

// Support rib thickness
support_rib_thickness = 0.8;

// Support rib width
support_rib_width = 2.0;

// Guide channel inner size (slightly larger than plunger head)
guide_channel_size = button_recess_diameter + 0.2;

// ---------------------------------------------------------------------------
// Button plunger — extended shaft with rounded tip
// ---------------------------------------------------------------------------
// The plunger is a two-part cylinder: a head (above lid) and a shaft (below lid).
// The shaft extends down to the tactile switch with a rounded tip.
// position: [x, y] relative to the Arduino feature origin
module button_plunger(position) {
    // Plunger head (the part the user presses, above lid surface)
    translate([position[0], position[1], lid_thickness - button_plunger_height])
        cylinder(d = button_plunger_diameter, h = button_plunger_height + 0.01, $fn = $fn);

    // Plunger shaft (extends below lid to reach the button)
    translate([position[0], position[1], -plunger_shaft_length])
        cylinder(d = plunger_shaft_diameter, h = plunger_shaft_length + 0.01, $fn = $fn);

    // Rounded tip at the bottom of the shaft
    translate([position[0], position[1], -plunger_shaft_length])
        sphere(d = button_plunger_tip_radius * 2, $fn = $fn);

    // Anti-tilt flange (wider disk near the top of the shaft, inside the guide)
    translate([position[0], position[1], -support_rib_height + 1.0])
        cylinder(d = button_plunger_diameter, h = button_plunger_wall, $fn = $fn);
}

// ---------------------------------------------------------------------------
// Button guide bore — through-hole in the lid for the plunger head
// ---------------------------------------------------------------------------
module button_guide_bore(position) {
    translate([position[0], position[1], -0.01])
        cylinder(d = button_recess_diameter, h = lid_thickness + 0.02, $fn = $fn);
}

// ---------------------------------------------------------------------------
// Button bezel ring — cosmetic ring around the guide bore
// ---------------------------------------------------------------------------
module button_bezel(position) {
    translate([position[0], position[1], lid_thickness - button_bezel_height])
        difference() {
            cylinder(d = button_bezel_outer_diameter, h = button_bezel_height + 0.01, $fn = $fn);
            translate([0, 0, -0.01])
                cylinder(d = button_recess_diameter, h = button_bezel_height + 0.02, $fn = $fn);
        }
}

// ---------------------------------------------------------------------------
// Button support ribs — four ribs forming a guide channel for the plunger
// ---------------------------------------------------------------------------
// The ribs extend from the lid underside down to near the plunger tip,
// preventing the plunger from tilting or sagging.
module button_support_ribs(position) {
    // Four ribs arranged in a square around the plunger
    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
            translate([
                position[0] + guide_channel_size / 2,
                position[1] - support_rib_width / 2,
                -support_rib_height
            ])
                cube([support_rib_thickness, support_rib_width, support_rib_height]);
    }
}

// ---------------------------------------------------------------------------
// Button travel stop — ring at the bottom of the guide channel
// ---------------------------------------------------------------------------
// Prevents the plunger from falling out and limits overtravel.
module button_travel_stop(position) {
    // Ring at the bottom of the support ribs
    translate([position[0], position[1], -support_rib_height - 0.5])
        difference() {
            cylinder(d = guide_channel_size + support_rib_thickness * 2, h = 1.0, $fn = $fn);
            translate([0, 0, -0.01])
                cylinder(d = plunger_shaft_diameter + button_plunger_clearance, h = 1.02, $fn = $fn);
        }
}

// ---------------------------------------------------------------------------
// Button guide channel top ring — reinforces the guide at the lid underside
// ---------------------------------------------------------------------------
module button_guide_top_ring(position) {
    translate([position[0], position[1], -0.5])
        difference() {
            cylinder(d = guide_channel_size + support_rib_thickness * 2, h = 0.5, $fn = $fn);
            translate([0, 0, -0.01])
                cylinder(d = button_recess_diameter, h = 0.52, $fn = $fn);
        }
}

// ---------------------------------------------------------------------------
// All button plungers (for the lid assembly)
// ---------------------------------------------------------------------------
module button_plungers() {
    for (pos = button_positions) {
        button_plunger(pos);
    }
}

// ---------------------------------------------------------------------------
// All button guide bores (subtractive, for the lid)
// ---------------------------------------------------------------------------
module button_guide_bores() {
    for (pos = button_positions) {
        button_guide_bore(pos);
    }
}

// ---------------------------------------------------------------------------
// All button bezels (positive, for the lid)
// ---------------------------------------------------------------------------
module button_bezels() {
    for (pos = button_positions) {
        button_bezel(pos);
    }
}

// ---------------------------------------------------------------------------
// All button support ribs (positive, for the lid underside)
// ---------------------------------------------------------------------------
module button_support_ribs_all() {
    for (pos = button_positions) {
        button_support_ribs(pos);
    }
}

// ---------------------------------------------------------------------------
// All button travel stops (positive, for the lid underside)
// ---------------------------------------------------------------------------
module button_travel_stops() {
    for (pos = button_positions) {
        button_travel_stop(pos);
    }
}

// ---------------------------------------------------------------------------
// All button guide top rings (positive, for the lid underside)
// ---------------------------------------------------------------------------
module button_guide_top_rings() {
    for (pos = button_positions) {
        button_guide_top_ring(pos);
    }
}