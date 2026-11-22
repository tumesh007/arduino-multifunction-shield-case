// =============================================================================
// battery_holder.scad
// Battery compartment with divider, retaining walls, wire channels, and
// cable pass-through. Supports the battery holder from below and prevents
// lateral movement.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Battery compartment floor — raised platform for the battery holder
// ---------------------------------------------------------------------------
module battery_compartment_floor() {
    translate([
        battery_compartment_position_x,
        battery_compartment_position_y,
        battery_compartment_position_z
    ])
        cube([
            battery_compartment_inner_length,
            battery_compartment_inner_width,
            bottom_thickness
        ]);
}

// ---------------------------------------------------------------------------
// Battery divider wall — separates the Arduino bay from the battery bay
// ---------------------------------------------------------------------------
module battery_divider_wall() {
    translate([
        battery_compartment_position_x - battery_divider_wall_thickness,
        battery_compartment_position_y - internal_side_clearance,
        bottom_thickness
    ])
        cube([
            battery_divider_wall_thickness,
            battery_compartment_inner_width + internal_side_clearance * 2,
            battery_divider_wall_height
        ]);
}

// ---------------------------------------------------------------------------
// Battery retaining walls — short lips to prevent the holder from sliding out
// ---------------------------------------------------------------------------
module battery_retainer_walls() {
    // Front and rear retainers (along Y axis)
    for (y_offset = [0, battery_compartment_inner_width - battery_retainer_wall_thickness]) {
        translate([
            battery_compartment_position_x + battery_retainer_clearance,
            battery_compartment_position_y + y_offset,
            bottom_thickness + battery_compartment_inner_height - battery_retainer_wall_height
        ])
            cube([
                battery_compartment_inner_length - battery_retainer_clearance * 2,
                battery_retainer_wall_thickness,
                battery_retainer_wall_height
            ]);
    }

    // Side retainers (along X axis) — only at the outer wall side
    translate([
        battery_compartment_position_x + battery_compartment_inner_length - battery_retainer_wall_thickness,
        battery_compartment_position_y + battery_retainer_clearance,
        bottom_thickness + battery_compartment_inner_height - battery_retainer_wall_height
    ])
        cube([
            battery_retainer_wall_thickness,
            battery_compartment_inner_width - battery_retainer_clearance * 2,
            battery_retainer_wall_height
        ]);
}

// ---------------------------------------------------------------------------
// Battery cable passage — opening in the divider for battery wiring
// ---------------------------------------------------------------------------
module battery_cable_passage() {
    translate([
        battery_compartment_position_x - battery_divider_wall_thickness - 0.01,
        battery_compartment_position_y + battery_compartment_inner_width / 2 - battery_cable_passage_width / 2,
        battery_cable_passage_floor_offset
    ])
        rounded_cube(
            [battery_divider_wall_thickness + 0.02, battery_cable_passage_width, battery_cable_passage_height],
            battery_cable_passage_radius
        );
}

// ---------------------------------------------------------------------------
// Battery cable channel — recessed channel on the floor for wire routing
// ---------------------------------------------------------------------------
module battery_cable_channel() {
    translate([
        arduino_position_x + arduino_enclosure_length / 2,
        battery_compartment_position_y + battery_compartment_inner_width / 2 - battery_cable_channel_width / 2,
        bottom_thickness - battery_cable_channel_depth
    ])
        rounded_cube(
            [battery_compartment_position_x - arduino_position_x - arduino_enclosure_length / 2,
             battery_cable_channel_width,
             battery_cable_channel_depth + 0.01],
            battery_cable_channel_radius
        );
}

// ---------------------------------------------------------------------------
// Battery stop — small bump at the rear to prevent backward sliding
// ---------------------------------------------------------------------------
module battery_stop() {
    translate([
        battery_compartment_position_x + battery_compartment_inner_length - 2,
        battery_compartment_position_y + battery_compartment_inner_width / 2 - 3,
        bottom_thickness
    ])
        cube([2, 6, 2]);
}

// ---------------------------------------------------------------------------
// Full battery compartment assembly (positive geometry)
// ---------------------------------------------------------------------------
module battery_compartment() {
    battery_compartment_floor();
    battery_divider_wall();
    battery_retainer_walls();
    battery_stop();
}

// ---------------------------------------------------------------------------
// Battery compartment cavity — negative space for the internal void
// ---------------------------------------------------------------------------
// This is subtracted from the base shell to create the battery pocket.
module battery_compartment_cavity() {
    translate([
        battery_compartment_position_x - 0.01,
        battery_compartment_position_y - 0.01,
        bottom_thickness
    ])
        cube([
            battery_compartment_inner_length + 0.02,
            battery_compartment_inner_width + 0.02,
            required_internal_height + 0.01
        ]);
}