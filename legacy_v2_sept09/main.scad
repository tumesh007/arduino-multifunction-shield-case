// main.scad — Complete assembly preview
// NOT a printable part.
use <config.scad>
include <config.scad>
use <base.scad>
use <top_plate.scad>

$fn = 60;

base_h = enc_h - top_t;
tp_ox  = lip_inset + general_clr;
tp_oy  = lip_inset + general_clr;

// ═══════════════════════════════════════════
// COMPONENT MOCKUPS
// ═══════════════════════════════════════════

module arduino_mockup() {
    color("ForestGreen", 0.8)
        translate([arduino_x, arduino_y, arduino_z])
            cube([arduino_w, arduino_l, arduino_h]);
}

module shield_mockup() {
    color("RoyalBlue", 0.7)
        translate([arduino_x, arduino_y, arduino_z + arduino_h])
            cube([arduino_w, arduino_l, shield_h]);
}

module battery_mockup() {
    color("DimGray", 0.85)
        translate([batt_x, batt_y, batt_z])
            cube([batt_w, batt_l, batt_h]);
}

// SPST on right side wall
module spst_mockup() {
    color("DarkRed", 0.9) {
        // Toggle protruding outside right wall
        translate([enc_w,
                   spst_panel_cy - spst_cutout_w/2,
                   spst_panel_cz - spst_cutout_h/2])
            cube([2, spst_cutout_w, spst_cutout_h]);

        // Rear body inside enclosure (extends -X from right wall)
        translate([enc_w - wall - spst_rear_depth,
                   spst_panel_cy - spst_body_w/2,
                   spst_panel_cz - spst_body_h/2])
            cube([spst_rear_depth, spst_body_w, spst_body_h]);

        // Terminal pins
        pw = 1.0; pd = 5.0;
        for (zo = [-4, 0, 4])
            translate([enc_w - wall - spst_rear_depth - pd,
                       spst_panel_cy - 1,
                       spst_panel_cz + zo - pw/2])
                cube([pd, 2, pw]);
    }
}

// DC on rear wall
module dc_mockup() {
    color("Silver", 0.9) {
        // Flange on outer rear wall
        translate([dc_panel_cx, enc_d, dc_panel_cz])
            rotate([-90, 0, 0])
                cylinder(d = dc_mount_dia, h = 3);

        // Body extending into enclosure from rear wall
        translate([dc_panel_cx, enc_d - wall, dc_panel_cz])
            rotate([90, 0, 0])
                cylinder(d = dc_dia + 2, h = dc_body_len);

        // Connector tip outside
        translate([dc_panel_cx, enc_d, dc_panel_cz])
            rotate([-90, 0, 0])
                cylinder(d = dc_dia, h = 8);
    }
}

module button_plungers() {
    color("White", 0.95)
        for (bpos = [[btn1_x, btn1_y],
                     [btn2_x, btn2_y],
                     [btn3_x, btn3_y]]) {
            bx = shield_to_enc_x(bpos[0]);
            by = shield_to_enc_y(bpos[1]);
            pz = shield_top_z;
            translate([bx, by, pz]) {
                cylinder(d = btn_dia, h = btn_h);
                translate([0, 0, btn_h])
                    sphere(d = btn_dia);
            }
        }
}

module display_mockup() {
    color("DarkSlateGray", 0.9)
        translate([shield_to_enc_x(disp_tl_x),
                   shield_to_enc_y(disp_tl_y),
                   shield_top_z])
            cube([disp_w, disp_h, 2]);
    color("LimeGreen", 0.8)
        translate([shield_to_enc_x(disp_tl_x) + 1,
                   shield_to_enc_y(disp_tl_y) + 1,
                   shield_top_z + 2.01])
            cube([disp_w - 2, disp_h - 2, 0.5]);
}

module buzzer_mockup() {
    color("Black", 0.85)
        translate([shield_to_enc_x(buzz_cx),
                   shield_to_enc_y(buzz_cy),
                   shield_top_z - buzz_h])
            cylinder(d = buzz_dia, h = buzz_h);
}

// ═══════════════════════════════════════════
// ASSEMBLY
// ═══════════════════════════════════════════

color("WhiteSmoke", 0.35)
    base_part();

z_shift = 3.0 - (lip_h - 0.3);
z_offset = z_shift > 0 ? z_shift : 0;
color("LightSteelBlue", 0.45)
    translate([tp_ox, tp_oy, base_h - z_offset])
        top_plate_part();

arduino_mockup();
shield_mockup();
battery_mockup();
spst_mockup();
dc_mockup();
button_plungers();
display_mockup();
buzzer_mockup();
