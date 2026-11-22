// ============================================================================
// File: cutouts.scad (Rear Panel USB, SPST Switch, Internal DC Jack & Top Windows)
// ============================================================================
include <config.scad>

module bottom_housing_cutouts() {
    usb_z = uno_z_top - 0.5;
    translate([uno_x0 + uno_usb_x - (uno_usb_w + 1.4)/2, encl_y - wall_t - EPS, usb_z])
        cube([uno_usb_w + 1.4, wall_t + 2*EPS, uno_usb_h + 1.2]);

    spst_x = bat_x0 + 13.0;
    spst_z = 21.0;
    translate([spst_x - spst_cutout_l/2, encl_y - wall_t - EPS, spst_z - spst_cutout_w/2])
        cube([spst_cutout_l, wall_t + 2*EPS, spst_cutout_w]);

    dc_x = bat_x0 + 33.0;
    dc_z = 21.0;
    translate([dc_x, encl_y - wall_t/2, dc_z])
        rotate([90, 0, 0])
            cylinder(d = dc_panel_hole_d, h = wall_t + 2*EPS, center = true);
}

module top_plate_windows() {
    translate([uno_x0 + mfs_disp_x - 0.4, uno_y0 + mfs_disp_y - 0.4, -EPS])
        cube([mfs_disp_w + 0.8, mfs_disp_h + 0.8, top_plate_t + 2*EPS]);

    for (dx = [-3.0, 0, 3.0], dy = [-3.0, 0, 3.0]) {
        translate([uno_x0 + mfs_buzzer_x + dx, uno_y0 + mfs_buzzer_y + dy, -EPS])
            cylinder(d = 1.6, h = top_plate_t + 2*EPS);
    }

    translate([uno_x0 + mfs_pot_x, uno_y0 + mfs_pot_y, -EPS])
        cylinder(d = 6.0, h = top_plate_t + 2*EPS);

    for (c = corner_boss_coords) {
        translate([c[0], c[1], -EPS])
            cylinder(d = boss_clear_d, h = top_plate_t + 2*EPS);
        translate([c[0], c[1], top_plate_t - boss_head_depth])
            cylinder(d1 = boss_clear_d, d2 = boss_head_d, h = boss_head_depth + EPS);
    }
}
