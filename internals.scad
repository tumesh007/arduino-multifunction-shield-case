// ============================================================================
// File: internals.scad (Standoffs, Divider Wall, Cantilever Battery Snap-Arm)
// ============================================================================
include <config.scad>

module uno_standoffs() {
    for (pt = uno_mount_holes) {
        translate([uno_x0 + pt[0], uno_y0 + pt[1], floor_t - EPS]) {
            difference() {
                union() {
                    cylinder(d = standoff_od, h = standoff_h + EPS);
                    cylinder(d1 = standoff_od + 2.0, d2 = standoff_od, h = 1.4);
                }
                translate([0, 0, 0.8])
                    cylinder(d = standoff_id, h = standoff_h + 1.0);
            }
        }
    }
}

module internal_divider_and_battery_bay() {
    div_x = uno_x0 + uno_len + fit_clearance;
    div_h = snap_z_top;

    div_y_len = bat_bay_y + wall_t;
    translate([div_x, wall_t - EPS, floor_t - EPS])
        cube([divider_t, div_y_len, div_h - floor_t + EPS]);

    arm_x = bat_x0 + (bat_bay_x - snap_arm_w) / 2;
    arm_y = bat_y0 + bat_bay_y;

    translate([bat_x0, arm_y, floor_t - EPS])
        cube([(bat_bay_x - snap_arm_w)/2 - 1.2, divider_t, 14.0]);
    translate([arm_x + snap_arm_w + 1.2, arm_y, floor_t - EPS])
        cube([(bat_bay_x - snap_arm_w)/2 - 1.2, divider_t, 14.0]);

    translate([arm_x, arm_y, floor_t - EPS]) {
        cube([snap_arm_w, snap_arm_t, snap_z_top - floor_t + 1.6]);
        translate([0, -snap_hook_overhang, snap_z_top - floor_t])
            hull() {
                cube([snap_arm_w, snap_hook_overhang + snap_arm_t, 1.4]);
                translate([0, snap_hook_overhang, 1.6])
                    cube([snap_arm_w, snap_arm_t, 0.2]);
            }
    }
}

module corner_screw_bosses() {
    for (c = corner_boss_coords) {
        translate([c[0], c[1], floor_t - EPS]) {
            difference() {
                cylinder(d = boss_d, h = base_wall_h - floor_t - lip_h + EPS);
                translate([0, 0, base_wall_h - floor_t - lip_h - 10.0])
                    cylinder(d = boss_hole_d, h = 11.0);
            }
        }
    }
}
