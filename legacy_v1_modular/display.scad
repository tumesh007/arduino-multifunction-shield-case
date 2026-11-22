// =============================================================================
// display.scad
// LCD display window, recessed bezel, support ribs, and viewing aperture.
// Coordinates are relative to the Arduino feature origin.
// Depends on: config.scad, utilities.scad
// =============================================================================

include <config.scad>
use <utilities.scad>

// ---------------------------------------------------------------------------
// Display window opening — the visible aperture through the lid
// ---------------------------------------------------------------------------
module display_window() {
    translate([
        display_window_top_left_x - display_recess_clearance,
        display_window_top_left_y - display_recess_clearance,
        -0.01
    ])
        rounded_cube(
            [display_opening_length, display_opening_width, lid_thickness + 0.02],
            display_window_corner_radius
        );
}

// ---------------------------------------------------------------------------
// Display bezel recess — pocket for the display glass to sit in
// ---------------------------------------------------------------------------
module display_bezel_recess() {
    translate([
        display_center_x - display_bezel_outer_length / 2,
        display_center_y - display_bezel_outer_width / 2,
        lid_thickness - display_bezel_recess_depth
    ])
        rounded_cube(
            [display_bezel_outer_length, display_bezel_outer_width, display_bezel_recess_depth + 0.01],
            display_bezel_corner_radius
        );
}

// ---------------------------------------------------------------------------
// Display bezel frame — raised border around the window
// ---------------------------------------------------------------------------
module display_bezel_frame() {
    difference() {
        display_bezel_recess();
        translate([
            display_window_top_left_x - display_recess_clearance - 0.01,
            display_window_top_left_y - display_recess_clearance - 0.01,
            lid_thickness - display_bezel_recess_depth - 0.01
        ])
            rounded_cube(
                [display_opening_length + 0.02, display_opening_width + 0.02, display_bezel_recess_depth + 0.02],
                display_window_corner_radius
            );
    }
}

// ---------------------------------------------------------------------------
// Display support ribs — thin ribs under the display area for rigidity
// ---------------------------------------------------------------------------
module display_support_ribs() {
    lid_rib_height = min(internal_rib_height, lid_thickness - display_bezel_recess_depth);
    rib_count = floor(display_visible_length / internal_rib_spacing);
    for (i = [0 : rib_count - 1]) {
        x_pos = display_window_top_left_x + internal_rib_end_clearance + i * internal_rib_spacing;
        if (x_pos < display_window_bottom_right_x - internal_rib_end_clearance) {
            translate([
                x_pos,
                display_window_top_left_y - display_recess_clearance,
                0
            ])
                cube([
                    internal_rib_thickness,
                    display_opening_width,
                    lid_rib_height
                ]);
        }
    }
}

// ---------------------------------------------------------------------------
// Full display module — combines all display features for the lid
// ---------------------------------------------------------------------------
// This is a subtractive module; use difference() with the lid body.
module display_cutout() {
    display_window();
    display_bezel_recess();
}

// ---------------------------------------------------------------------------
// Display positive features (bezel frame and ribs)
// ---------------------------------------------------------------------------
module display_positive() {
    display_bezel_frame();
    display_support_ribs();
}