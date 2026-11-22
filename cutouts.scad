// ============================================================================
// File: cutouts.scad (Rear Panel USB & SPST Switch + Top UI Windows — v4.6)
// ============================================================================
include <config.scad>

module bottom_housing_cutouts() {
    // 1. Arduino USB Type-B Reprogramming Port Cutout on Rear Wall
    usb_z = uno_z_top - 0.5;
    translate([uno_x0 + uno_usb_x - (uno_usb_w + 1.4)/2, encl_y - wall_t - EPS, usb_z])
        cube([uno_usb_w + 1.4, wall_t + 2*EPS, uno_usb_h + 1.2]);

    // 2. Panel-Mount SPST Rocker On/Off Switch Cutout on Rear Wall
    spst_x = bat_x0 + 13.0;
    spst_z = 21.0;
    translate([spst_x - spst_cutout_l/2, encl_y - wall_t - EPS, spst_z - spst_cutout_w/2])
        cube([spst_cutout_l, wall_t + 2*EPS, spst_cutout_w]);
}

module top_plate_windows() {
    // 1. 4-Digit 7-Segment Display Bezel Window
    translate([uno_x0 + mfs_disp_x - 0.4, uno_y0 + mfs_disp_y - 0.4, -EPS])
        cube([mfs_disp_w + 0.8, mfs_disp_h + 0.8, top_plate_t + 2*EPS]);

    // 2. Piezo Buzzer Acoustic Vent Pattern
    for (dx = [-3.0, 0, 3.0], dy = [-3.0, 0, 3.0]) {
        translate([uno_x0 + mfs_buzzer_x + dx, uno_y0 + mfs_buzzer_y + dy, -EPS])
            cylinder(d = 1.6, h = top_plate_t + 2*EPS);
    }

    // 3. 4-LED (D1-D4) Vertical Status Viewing Window
    translate([uno_x0 + mfs_leds_x, uno_y0 + mfs_leds_y, -EPS])
        cube([mfs_leds_w, mfs_leds_h, top_plate_t + 2*EPS]);

    // 4. Trimpot Access Hole (W103)
    translate([uno_x0 + mfs_pot_x, uno_y0 + mfs_pot_y, -EPS])
        cylinder(d = mfs_pot_d, h = top_plate_t + 2*EPS);

    // 5. Corner M3 Mounting Holes + Countersink
    for (c = corner_boss_coords) {
        translate([c[0], c[1], -EPS])
            cylinder(d = boss_clear_d, h = top_plate_t + 2*EPS);
        translate([c[0], c[1], top_plate_t - boss_head_depth])
            cylinder(d1 = boss_clear_d, d2 = boss_head_d, h = boss_head_depth + EPS);
    }
}
