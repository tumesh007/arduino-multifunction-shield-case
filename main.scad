// ============================================================================
// File: main.scad (Top-Level Assembly & STL Export Entrypoint — v4.2)
// ============================================================================
include <config.scad>
use <utilities.scad>
use <internals.scad>
use <cutouts.scad>
use <buttons.scad>

part = "assembly"; // "assembly" | "base" | "cover_print" | "section_buttons"

module bottom_housing() {
    difference() {
        rounded_box(encl_x, encl_y, base_wall_h, corner_r);
        translate([wall_t, wall_t, floor_t])
            rounded_box(encl_x - 2*wall_t, encl_y - 2*wall_t, base_wall_h, max(1.0, corner_r - wall_t));
        translate([wall_t - lip_t, wall_t - lip_t, base_wall_h - lip_h])
            rounded_box(encl_x - 2*(wall_t - lip_t), encl_y - 2*(wall_t - lip_t), lip_h + EPS, max(1.5, corner_r - wall_t + lip_t));
        bottom_housing_cutouts();
    }
    uno_standoffs();
    internal_divider_and_battery_bay();
    corner_screw_bosses();
}

module top_plate_local() {
    difference() {
        union() {
            rounded_box(encl_x, encl_y, top_plate_t, corner_r);
            translate([wall_t - lip_t + fit_clearance/2, wall_t - lip_t + fit_clearance/2, -lip_h + EPS])
                difference() {
                    rounded_box(
                        encl_x - 2*(wall_t - lip_t + fit_clearance/2),
                        encl_y - 2*(wall_t - lip_t + fit_clearance/2),
                        lip_h,
                        max(1.5, corner_r - wall_t + lip_t)
                    );
                    translate([lip_t, lip_t, -EPS])
                        rounded_box(
                            encl_x - 2*(wall_t + fit_clearance/2),
                            encl_y - 2*(wall_t + fit_clearance/2),
                            lip_h + 2*EPS,
                            max(1.0, corner_r - wall_t)
                        );
                }
        }
        top_plate_windows();
        for (b = mfs_buttons) {
            integrated_button_cutout(uno_x0 + b[1], uno_y0 + b[2]);
        }
    }
    for (b = mfs_buttons) {
        integrated_button_solid(uno_x0 + b[1], uno_y0 + b[2], b[3]);
    }
}

module hardware_mockup() {
    color("SteelBlue", 0.7)
        translate([bat_x0 + loose_clearance, bat_y0 + loose_clearance, floor_t])
            cube([bat_wid, bat_len, bat_h]);
    color("DarkGreen", 0.85)
        translate([uno_x0, uno_y0, uno_z_bottom])
            cube([uno_len, uno_wid, uno_pcb_t]);
    color("Crimson", 0.85)
        translate([uno_x0, uno_y0, mfs_z_bottom])
            cube([uno_len, uno_wid, mfs_pcb_t]);
    color("DimGray")
        translate([uno_x0 + mfs_disp_x, uno_y0 + mfs_disp_y, mfs_z_top])
            cube([mfs_disp_w, mfs_disp_h, mfs_disp_top_h]);
    for (b = mfs_buttons) {
        translate([uno_x0 + b[1], uno_y0 + b[2], mfs_z_top]) {
            color("Silver") translate([-3, -3, 0]) cube([6, 6, 3.5]);
            color("Black") cylinder(d = 3.5, h = b[3]);
        }
    }
}

if (part == "base") {
    bottom_housing();
} else if (part == "cover_print") {
    translate([0, encl_y, top_plate_t])
        rotate([180, 0, 0])
            top_plate_local();
} else if (part == "section_buttons") {
    difference() {
        union() {
            bottom_housing();
            translate([0, 0, z_plate_inner]) top_plate_local();
            hardware_mockup();
        }
        translate([-5, -5, -5])
            cube([encl_x + 10, uno_y0 + s1_y + 5, encl_total_h + 15]);
    }
} else {
    color("SlateGray") bottom_housing();
    color("LightSteelBlue", 0.92) translate([0, 0, z_plate_inner]) top_plate_local();
    hardware_mockup();
}
