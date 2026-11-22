// =============================================================================
// arduino_mount.scad
// Arduino Uno / Multifunction Shield locating rails and retention system.
// The Arduino slides into rails from the front; retaining ribs prevent lift.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Arduino locating rail — runs along the long side of the enclosure
// ---------------------------------------------------------------------------
// Provides a sliding channel for the Arduino PCB edges.
// Positioned at the left and right sides of the Arduino bay.
module arduino_rail(length, height, thickness) {
    // Main rail body
    cube([thickness, length, height]);
    // Lead-in chamfer at the front (insertion end)
    translate([0, 0, height])
        rotate([arduino_rail_lead_in_angle, 0, 0])
            cube([thickness, arduino_rail_lead_in_length, thickness]);
}

// ---------------------------------------------------------------------------
// Arduino rail pair — left and right rails with correct spacing
// ---------------------------------------------------------------------------
module arduino_rail_pair() {
    rail_y_start = arduino_position_y - arduino_end_clearance;
    rail_y_length = arduino_enclosure_length + arduino_end_clearance * 2;

    // Left rail (at X = arduino_position_x - clearance - thickness)
    translate([
        arduino_position_x - arduino_rail_clearance - arduino_rail_thickness,
        rail_y_start,
        arduino_position_z
    ])
        arduino_rail(rail_y_length, arduino_rail_height, arduino_rail_thickness);

    // Right rail (at X = arduino_position_x + enclosure_width + clearance)
    translate([
        arduino_position_x + arduino_enclosure_width + arduino_rail_clearance,
        rail_y_start,
        arduino_position_z
    ])
        arduino_rail(rail_y_length, arduino_rail_height, arduino_rail_thickness);
}

// ---------------------------------------------------------------------------
// Arduino retainer wall — prevents the Arduino from lifting vertically
// ---------------------------------------------------------------------------
// Short wall segments at the rear of the Arduino bay with a notch for cables.
module arduino_retainer_wall() {
    wall_length = arduino_enclosure_width + arduino_retainer_wall_clearance * 2;

    // Main retainer wall (with center notch for USB/power cable exit)
    difference() {
        translate([
            arduino_position_x - arduino_retainer_wall_clearance,
            arduino_position_y + arduino_enclosure_length - arduino_retainer_wall_thickness,
            arduino_position_z + arduino_rail_height
        ])
            cube([
                wall_length,
                arduino_retainer_wall_thickness,
                arduino_retainer_wall_height
            ]);

        // Cable exit notch
        translate([
            arduino_position_x + arduino_enclosure_width / 2 - arduino_retainer_notch_width / 2,
            arduino_position_y + arduino_enclosure_length - arduino_retainer_wall_thickness - 0.01,
            arduino_position_z + arduino_rail_height
        ])
            cube([
                arduino_retainer_notch_width,
                arduino_retainer_wall_thickness + 0.02,
                arduino_retainer_wall_height + 0.01
            ]);
    }
}

// ---------------------------------------------------------------------------
// Arduino insertion path clearance — ensures no interference during sliding
// ---------------------------------------------------------------------------
// This is a negative-space module; subtract from base if needed.
module arduino_insertion_path() {
    translate([
        arduino_position_x - arduino_rail_clearance - 0.5,
        arduino_position_y - arduino_end_clearance - 0.5,
        arduino_position_z + arduino_rail_height - 0.5
    ])
        cube([
            arduino_enclosure_width + arduino_rail_clearance * 2 + arduino_rail_thickness * 2 + 1,
            arduino_enclosure_length + arduino_end_clearance * 2 + 1,
            arduino_enclosure_height + arduino_top_clearance + 1
        ]);
}

// ---------------------------------------------------------------------------
// Arduino support rib — floor rib beneath the Arduino for stability
// ---------------------------------------------------------------------------
module arduino_support_rib() {
    rib_count = floor(arduino_enclosure_length / internal_rib_spacing);
    for (i = [0 : rib_count - 1]) {
        translate([
            arduino_position_x - arduino_side_clearance,
            arduino_position_y + internal_rib_end_clearance + i * internal_rib_spacing,
            bottom_thickness
        ])
            cube([
                arduino_enclosure_width + arduino_side_clearance * 2,
                internal_rib_thickness,
                internal_rib_height
            ]);
    }
}

// ---------------------------------------------------------------------------
// Full Arduino mount assembly
// ---------------------------------------------------------------------------
module arduino_mount() {
    arduino_rail_pair();
    arduino_retainer_wall();
    arduino_support_rib();
}