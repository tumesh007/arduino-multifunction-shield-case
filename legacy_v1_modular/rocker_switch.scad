// =============================================================================
// rocker_switch.scad
// SPST rocker switch panel cutout with clearance, wall penetration, and
// collision avoidance assertions.
//
// NOTE: Switch is located on the FRONT wall (Y = 0), opposite the battery
// compartment. This keeps the switch actuator accessible while moving the
// internal switch body away from the battery bay.
//
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Rocker switch cutout dimensions (nominal + configured clearance)
// ---------------------------------------------------------------------------
// The opening is sized to the switch nominal dimensions plus 2× clearance
// on each axis to ensure free fit.
rocker_switch_cutout_length = rocker_switch_opening_length + 2 * rocker_switch_clearance;
rocker_switch_cutout_width  = rocker_switch_opening_width  + 2 * rocker_switch_clearance;

// ---------------------------------------------------------------------------
// Rocker switch cutout — rectangular opening through the FRONT enclosure wall
// ---------------------------------------------------------------------------
// The cutout is positioned on the front wall at Y = 0 (opposite the battery
// compartment). It is centered in X over the battery bay using the existing
// switch position variable, and centered in Z over the available internal height.
//
// The cutout uses a plain cube (not rounded_cube) to guarantee clean wall
// penetration without offset() interference from the cavity geometry.
// ---------------------------------------------------------------------------
module rocker_switch_cutout() {
    // --- Wall face coordinates (FRONT wall at Y = 0) ---
    // Inner face of the wall (cavity side)
    wall_inner_y = wall_thickness;
    // Outer face of the wall (exterior)
    wall_outer_y = 0;
    // Total wall thickness in Y
    wall_depth   = wall_inner_y - wall_outer_y;

    // --- Cutout position ---
    // X: centered over battery compartment using config variable
    cutout_center_x = rocker_switch_position_x;
    // Z: centered using config variable
    cutout_center_z = rocker_switch_position_z;
    // Y: starts just outside the wall outer face and protrudes past inner face
    cutout_start_y  = wall_outer_y - 0.5;   // 0.5 mm margin outside for clean subtraction
    cutout_depth_y  = wall_depth + 1.0;      // protrudes 0.5 mm past each face

    // --- Assertion: wall thickness must equal the configured wall_thickness ---
    assert(abs(wall_depth - wall_thickness) < 0.001,
        str("Rocker switch wall depth mismatch: expected ", wall_thickness,
            " mm, calculated ", wall_depth, " mm."));

    // --- Assertion: cutout must lie completely within the wall X boundaries ---
    assert(cutout_center_x - rocker_switch_cutout_length / 2 >= wall_thickness,
        "Rocker switch cutout left edge violates wall X boundary.");
    assert(cutout_center_x + rocker_switch_cutout_length / 2 <= external_length - wall_thickness,
        "Rocker switch cutout right edge violates wall X boundary.");

    // --- Assertion: cutout must lie completely within the wall Z boundaries ---
    assert(cutout_center_z - rocker_switch_cutout_width / 2 >= bottom_thickness,
        "Rocker switch cutout bottom edge violates wall Z boundary.");
    assert(cutout_center_z + rocker_switch_cutout_width / 2 <= external_height - wall_thickness,
        "Rocker switch cutout top edge violates wall Z boundary.");

    // --- Pre-calculate cutout envelope for collision checks ---
    cutout_left   = cutout_center_x - rocker_switch_cutout_length / 2;
    cutout_right  = cutout_center_x + rocker_switch_cutout_length / 2;
    cutout_bottom = cutout_center_z - rocker_switch_cutout_width / 2;
    cutout_top    = cutout_center_z + rocker_switch_cutout_width / 2;

    // --- Assertion: cutout must not intersect the USB opening ---
    // NOTE: Both USB and switch are now on the Y=0 wall. Verify XZ separation.
    usb_left   = usb_opening_position_x - usb_opening_width / 2 - usb_opening_clearance;
    usb_right  = usb_opening_position_x + usb_opening_width / 2 + usb_opening_clearance;
    usb_bottom = usb_opening_position_z - usb_opening_height / 2 - usb_opening_clearance;
    usb_top    = usb_opening_position_z + usb_opening_height / 2 + usb_opening_clearance;

    assert(cutout_right < usb_left || cutout_left > usb_right ||
           cutout_top < usb_bottom || cutout_bottom > usb_top,
        "Rocker switch cutout intersects USB opening.");

    // --- Assertion: cutout must not intersect the DC barrel opening ---
    dc_left   = dc_barrel_position_x - dc_barrel_outer_bezel / 2 - dc_barrel_clearance;
    dc_right  = dc_barrel_position_x + dc_barrel_outer_bezel / 2 + dc_barrel_clearance;
    dc_bottom = dc_barrel_position_z - dc_barrel_outer_bezel / 2 - dc_barrel_clearance;
    dc_top    = dc_barrel_position_z + dc_barrel_outer_bezel / 2 + dc_barrel_clearance;

    assert(cutout_right < dc_left || cutout_left > dc_right ||
           cutout_top < dc_bottom || cutout_bottom > dc_top,
        "Rocker switch cutout intersects DC barrel opening.");

    // --- Assertion: cutout must not intersect screw bosses in XZ projection ---
    post_positions = [
        [screw_post_corner_offset, screw_post_corner_offset],
        [external_length - screw_post_corner_offset, screw_post_corner_offset],
        [screw_post_corner_offset, external_width - screw_post_corner_offset],
        [external_length - screw_post_corner_offset, external_width - screw_post_corner_offset]
    ];
    for (pos = post_positions) {
        post_x_min = pos[0] - screw_post_outer_diameter / 2;
        post_x_max = pos[0] + screw_post_outer_diameter / 2;
        post_z_min = bottom_thickness;
        post_z_max = bottom_thickness + screw_post_height;
        assert(cutout_right < post_x_min || cutout_left > post_x_max ||
               cutout_top < post_z_min || cutout_bottom > post_z_max,
            str("Rocker switch cutout intersects screw boss at [", pos[0], ", ", pos[1], "]."));
    }

    // --- Assertion: cutout must not intersect the battery divider wall ---
    // Divider is at X = battery_compartment_position_x - battery_divider_wall_thickness
    divider_x = battery_compartment_position_x - battery_divider_wall_thickness;
    assert(cutout_right < divider_x || cutout_left > divider_x + battery_divider_wall_thickness,
        "Rocker switch cutout intersects battery divider wall.");

    // --- Assertion: cutout must not intersect Arduino rails ---
    arduino_rail_left_x  = arduino_position_x - arduino_rail_clearance - arduino_rail_thickness;
    arduino_rail_right_x = arduino_position_x + arduino_enclosure_width + arduino_rail_clearance + arduino_rail_thickness;
    assert(cutout_left > arduino_rail_right_x || cutout_right < arduino_rail_left_x,
        "Rocker switch cutout intersects Arduino mounting rails.");

    // --- Geometry: plain cube cutout through front wall ---
    translate([
        cutout_center_x - rocker_switch_cutout_length / 2,
        cutout_start_y,
        cutout_center_z - rocker_switch_cutout_width / 2
    ])
        cube([
            rocker_switch_cutout_length,
            cutout_depth_y,
            rocker_switch_cutout_width
        ]);
}