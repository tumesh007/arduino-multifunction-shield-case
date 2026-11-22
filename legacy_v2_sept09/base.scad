// base.scad — Lower enclosure / base
// Independently printable. Print bottom-face down.
use <config.scad>
include <config.scad>

$fn = 60;

module rounded_rect_2d(w, d, r) {
    offset(r) offset(-r) square([w, d]);
}

base_h = enc_h - top_t;

module base_shell() {
    difference() {
        linear_extrude(base_h)
            rounded_rect_2d(enc_w, enc_d, corner_r);
        translate([wall, wall, bottom_t])
            linear_extrude(base_h + 1)
                rounded_rect_2d(enc_w - 2*wall, enc_d - 2*wall,
                               max(corner_r - wall, 0.5));
        translate([lip_inset, lip_inset, base_h - lip_h - 0.01])
            linear_extrude(lip_h + 1)
                rounded_rect_2d(enc_w - 2*lip_inset, enc_d - 2*lip_inset,
                               max(corner_r - lip_inset, 0.5));
    }
}

module arduino_rails() {
    seg = 15;
    ax = arduino_x; ay = arduino_y;
    aw = arduino_w; al = arduino_l;
    ext = 1.5;
    rh = rail_h + ext;
    z0 = arduino_z - ext;

    // Front-left L
    translate([ax - rail_w, ay, z0]) cube([rail_w, seg, rh]);
    translate([ax, ay - rail_w, z0]) cube([seg, rail_w, rh]);
    translate([ax - rail_w, ay - rail_w, z0]) cube([rail_w, rail_w, rh]);

    // Front-right L
    translate([ax + aw, ay, z0]) cube([rail_w, seg, rh]);
    translate([ax + aw - seg, ay - rail_w, z0]) cube([seg, rail_w, rh]);
    translate([ax + aw, ay - rail_w, z0]) cube([rail_w, rail_w, rh]);

    // Rear-left L
    translate([ax - rail_w, ay + al - seg, z0]) cube([rail_w, seg, rh]);
    translate([ax, ay + al, z0]) cube([seg, rail_w, rh]);
    translate([ax - rail_w, ay + al, z0]) cube([rail_w, rail_w, rh]);

    // Rear-right L
    translate([ax + aw, ay + al - seg, z0]) cube([rail_w, seg, rh]);
    translate([ax + aw - seg, ay + al, z0]) cube([seg, rail_w, rh]);
    translate([ax + aw, ay + al, z0]) cube([rail_w, rail_w, rh]);
}

module battery_compartment() {
    ret_h = batt_h * 0.6;
    fg = 20;
    rw = batt_w + 2*batt_clr;
    ext = 1.5;

    translate([batt_x - batt_clr, batt_y - batt_clr, bottom_t - ext])
        cube([rw, batt_wall, ret_h + ext]);

    translate([batt_x - batt_clr,
               batt_y + batt_l + batt_clr - batt_wall,
               bottom_t - ext])
        difference() {
            cube([rw, batt_wall, ret_h + ext]);
            translate([(rw - fg)/2, -0.1, ret_h * 0.5 + ext])
                cube([fg, batt_wall + 0.2, ret_h + 1]);
        }

    tw = 1.5; td = 10; th = 8;
    for (f = [0.25, 0.75])
        translate([batt_x + batt_w + batt_clr - tw,
                   batt_y + batt_l*f - td/2,
                   bottom_t - ext])
            cube([tw, td, th + ext]);
}

module internal_divider() {
    dx = wall + arduino_clr + arduino_w + arduino_clr;
    dd = enc_d - 2*wall;
    ext = 1.5;

    translate([dx, wall, bottom_t - ext])
        difference() {
            cube([divider_t, dd, internal_h + ext]);
            translate([-0.1, (dd - cable_pass_w)/2, 2 + ext])
                cube([divider_t + 0.2, cable_pass_w, cable_pass_h]);
        }
}

module screw_bosses() {
    bh = base_h - bottom_t;
    ext = 1.5;
    for (p = screw_positions)
        translate([p[0], p[1], bottom_t - ext])
            difference() {
                cylinder(d = screw_boss_od, h = bh + ext);
                translate([0, 0, -0.1])
                    cylinder(d = screw_boss_id, h = bh + ext + 0.2);
            }
}

// SPST cutout — now on RIGHT side wall (X = enc_w face)
module spst_cutout() {
    cw = spst_cutout_w + 2*spst_clr;
    ch = spst_cutout_h + 2*spst_clr;
    translate([enc_w - wall - 0.5,
               spst_panel_cy - cw/2,
               spst_panel_cz - ch/2])
        cube([wall + 1, cw, ch]);
}

// DC connector cutout — now on REAR wall (Y = enc_d face)
module dc_cutout() {
    translate([dc_panel_cx, enc_d - wall - 0.5, dc_panel_cz])
        rotate([-90, 0, 0])
            cylinder(d = dc_mount_dia + 2*dc_clr, h = wall + 1);
}

module ventilation() {
    pitch = vent_slot_w + vent_gap;
    span = vent_count * pitch - vent_gap;

    // Left wall
    for (i = [0:vent_count-1])
        translate([-0.5, enc_d/2 - span/2 + i*pitch,
                   bottom_t + vent_z_offset])
            cube([wall + 1, vent_slot_w, vent_slot_h]);

    // Front wall (Arduino section)
    for (i = [0:vent_count-1])
        translate([arduino_x + arduino_w/2 - span/2 + i*pitch,
                   -0.5,
                   bottom_t + vent_z_offset])
            cube([vent_slot_w, wall + 1, vent_slot_h]);
}

module foot_recesses() {
    for (p = [[foot_inset, foot_inset],
              [enc_w - foot_inset, foot_inset],
              [foot_inset, enc_d - foot_inset],
              [enc_w - foot_inset, enc_d - foot_inset]])
        translate([p[0], p[1], -0.5])
            cylinder(d = foot_dia, h = foot_h + 0.5);
}

module cable_guides() {
    rib = 1.2;
    rh = cable_ch_d;
    ext = 1.5;
    // Guide ribs from DC connector area (rear wall, battery side) toward divider
    gx = dc_panel_cx - cable_ch_w/2;
    gy1 = batt_y + batt_l + batt_clr + 2;
    gy2 = enc_d - wall - 5;

    translate([gx,              gy1, bottom_t - ext])
        cube([rib, gy2 - gy1, rh + ext]);
    translate([gx + cable_ch_w, gy1, bottom_t - ext])
        cube([rib, gy2 - gy1, rh + ext]);
}

module base_part() {
    difference() {
        union() {
            base_shell();
            arduino_rails();
            battery_compartment();
            internal_divider();
            screw_bosses();
            cable_guides();
        }
        spst_cutout();
        dc_cutout();
        ventilation();
        foot_recesses();
    }
}

base_part();
