// =============================================================================
// cable_management.scad
// Wire channels, zip tie slots, rounded exits, and strain relief features.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Wire channel — recessed channel on the base floor for cable routing
// ---------------------------------------------------------------------------
// start: [x, y, z] start point
// end: [x, y, z] end point
// width: channel width
// depth: channel depth
module wire_channel(start, end, width, depth) {
    length = norm([end[0] - start[0], end[1] - start[1]]);
    angle = atan2(end[1] - start[1], end[0] - start[0]);

    translate([start[0], start[1], start[2] - depth])
        rotate([0, 0, angle])
            rounded_cube([length, width, depth + 0.01], width / 2);
}

// ---------------------------------------------------------------------------
// Zip tie slot — through-slot for cable management ties
// ---------------------------------------------------------------------------
// position: [x, y, z] center position
// orientation: 0 = along X, 90 = along Y
module zip_tie_slot(position, orientation = 0) {
    translate([position[0], position[1], position[2] - 0.01])
        rotate([0, 0, orientation])
            rounded_cube([tie_slot_length, tie_slot_width, wall_thickness + 0.02], tie_slot_end_radius);
}

// ---------------------------------------------------------------------------
// Cable exit — rounded opening for cables leaving the enclosure
// ---------------------------------------------------------------------------
// position: [x, y, z] center of the exit
// direction: "x", "y", or "z" — axis normal to the exit face
module cable_exit(position, direction = "x") {
    if (direction == "x") {
        translate([position[0] - 0.01, position[1] - cable_exit_width / 2, position[2] - cable_exit_height / 2])
            rounded_cube([wall_thickness + 0.02, cable_exit_width, cable_exit_height], cable_exit_corner_radius);
    } else if (direction == "y") {
        translate([position[0] - cable_exit_width / 2, position[1] - 0.01, position[2] - cable_exit_height / 2])
            rounded_cube([cable_exit_width, wall_thickness + 0.02, cable_exit_height], cable_exit_corner_radius);
    } else {
        translate([position[0] - cable_exit_width / 2, position[1] - cable_exit_width / 2, position[2] - 0.01])
            rounded_cube([cable_exit_width, cable_exit_width, wall_thickness + 0.02], cable_exit_corner_radius);
    }
}

// ---------------------------------------------------------------------------
// Strain relief bump — small protrusion to grip cables
// ---------------------------------------------------------------------------
// position: [x, y, z] location
module strain_relief_bump(position) {
    translate(position)
        sphere(d = cable_exit_strain_relief_depth * 2, $fn = $fn);
}

// ---------------------------------------------------------------------------
// Main cable channel run — from Arduino to battery to panel
// ---------------------------------------------------------------------------
module main_cable_channel() {
    // Channel from Arduino USB area to battery compartment
    wire_channel(
        [arduino_position_x + arduino_enclosure_width / 2, arduino_position_y + arduino_enclosure_length, bottom_thickness],
        [battery_compartment_position_x, battery_compartment_position_y + battery_compartment_inner_width / 2, bottom_thickness],
        cable_channel_width,
        cable_channel_depth
    );

    // Channel from battery to DC barrel connector
    wire_channel(
        [battery_compartment_position_x + battery_compartment_inner_length / 2, battery_compartment_position_y + battery_compartment_inner_width / 2, bottom_thickness],
        [dc_barrel_position_x, dc_barrel_position_z, bottom_thickness],
        battery_cable_channel_width,
        battery_cable_channel_depth
    );
}

// ---------------------------------------------------------------------------
// Zip tie slots along the cable channel
// ---------------------------------------------------------------------------
module cable_tie_slots() {
    // Tie slot near Arduino
    zip_tie_slot([arduino_position_x + arduino_enclosure_width / 2, arduino_position_y + arduino_enclosure_length + tie_slot_spacing, bottom_thickness], 0);

    // Tie slot near battery
    zip_tie_slot([battery_compartment_position_x, battery_compartment_position_y + battery_compartment_inner_width / 2 + tie_slot_spacing, bottom_thickness], 90);
}