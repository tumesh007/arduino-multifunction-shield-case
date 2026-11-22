// =============================================================================
// base.scad
// Complete base assembly: outer shell, inner cavity, Arduino mount, battery
// compartment, screw bosses, vents, panel openings, wire routing, rubber feet.
// Depends on: config.scad, utilities.scad, arduino_mount.scad, screw_posts.scad,
//             battery_holder.scad, vents.scad, cable_management.scad, rocker_switch.scad
// =============================================================================

include <config.scad>
use <utilities.scad>
use <arduino_mount.scad>
use <screw_posts.scad>
use <battery_holder.scad>
use <vents.scad>
use <cable_management.scad>
use <rocker_switch.scad>

// ---------------------------------------------------------------------------
// Base outer shell — rounded exterior with flat bottom
// ---------------------------------------------------------------------------
module base_outer_shell() {
    rounded_cube([external_length, external_width, external_height], outer_corner_radius);
}

// ---------------------------------------------------------------------------
// Base inner cavity — hollowed interior with rounded corners
// ---------------------------------------------------------------------------
module base_inner_cavity() {
    translate([wall_thickness, wall_thickness, bottom_thickness])
        rounded_cube([internal_length, internal_width, required_internal_height + 0.01], inner_corner_radius);
}

// ---------------------------------------------------------------------------
// USB opening — rectangular cutout for the Arduino USB connector
// ---------------------------------------------------------------------------
module usb_opening() {
    translate([usb_opening_position_x - usb_opening_width / 2, -0.01, usb_opening_position_z - usb_opening_height / 2])
        rounded_cube([usb_opening_width, wall_thickness + 0.02, usb_opening_height], usb_opening_height / 4);
}

// ---------------------------------------------------------------------------
// DC barrel opening — circular hole for the power jack
// ---------------------------------------------------------------------------
module dc_barrel_opening() {
    translate([dc_barrel_position_x, external_width + 0.01, dc_barrel_position_z])
        rotate([90, 0, 0])
            cylinder(d = dc_barrel_opening_diameter, h = wall_thickness + 0.02, $fn = $fn);
}

// ---------------------------------------------------------------------------
// Rubber foot recess — shallow pocket for adhesive rubber feet
// ---------------------------------------------------------------------------
module rubber_foot_recess(position) {
    translate([position[0], position[1], -0.01])
        cylinder(d = rubber_foot_recess_diameter, h = rubber_foot_recess_depth + 0.01, $fn = $fn);
}

// ---------------------------------------------------------------------------
// All rubber foot recesses
// ---------------------------------------------------------------------------
module rubber_foot_recesses() {
    positions = [
        [rubber_foot_corner_offset, rubber_foot_corner_offset],
        [external_length - rubber_foot_corner_offset, rubber_foot_corner_offset],
        [rubber_foot_corner_offset, external_width - rubber_foot_corner_offset],
        [external_length - rubber_foot_corner_offset, external_width - rubber_foot_corner_offset]
    ];
    for (pos = positions) {
        rubber_foot_recess(pos);
    }
}

// ---------------------------------------------------------------------------
// Future expansion panel knockout — thin wall section for optional breakout
// ---------------------------------------------------------------------------
module expansion_knockout() {
    if (expansion_knockout_enabled) {
        translate([future_expansion_panel_position_x - expansion_knockout_length / 2, -0.01, future_expansion_panel_position_z - expansion_knockout_width / 2])
            cube([expansion_knockout_length, wall_thickness * expansion_knockout_wall_thickness + 0.02, expansion_knockout_width]);
    }
}

// ---------------------------------------------------------------------------
// Internal support ribs — floor ribs for print stability and rigidity
// ---------------------------------------------------------------------------
module internal_support_ribs() {
    rib_count_x = floor(internal_length / internal_rib_spacing);
    for (i = [0 : rib_count_x - 1]) {
        x = wall_thickness + internal_rib_end_clearance + i * internal_rib_spacing;
        if (x < external_length - wall_thickness - internal_rib_end_clearance) {
            translate([x, wall_thickness, bottom_thickness])
                cube([internal_rib_thickness, internal_width, internal_rib_height]);
        }
    }
}

// ---------------------------------------------------------------------------
// Complete base assembly
// ---------------------------------------------------------------------------
module base() {
    difference() {
        union() {
            // Main shell only — internal features added after hollowing
            base_outer_shell();
        }

        // Subtractive features
        base_inner_cavity();
        usb_opening();
        dc_barrel_opening();
        rocker_switch_cutout();
        side_vents();
        main_cable_channel();
        battery_cable_passage();
        battery_cable_channel();
        rubber_foot_recesses();
        expansion_knockout();
        cable_tie_slots();
    }

    // Internal features added after the shell is hollowed
    arduino_mount();
    battery_compartment();
    screw_posts();
    internal_support_ribs();
    vent_reinforcement_ribs();
}