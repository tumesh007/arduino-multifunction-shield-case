// top_plate.scad — Removable top plate / lid
// Independently printable. Print top-face down (inner face up).
use <config.scad>
include <config.scad>

$fn = 60;

module rounded_rect_2d(w, d, r) {
    hull() {
        translate([r, r]) circle(r);
        translate([w - r, r]) circle(r);
        translate([r, d - r]) circle(r);
        translate([w - r, d - r]) circle(r);
    }
}

base_h = enc_h - top_t;

// Top plate dimensions: fits into lip rebate with clearance
tp_w = enc_w - 2*lip_inset - 2*general_clr;
tp_d = enc_d - 2*lip_inset - 2*general_clr;
tp_r = max(corner_r - lip_inset - general_clr, 0.5);
skirt_h = lip_h - 0.3;

tp_ox = lip_inset + general_clr;
tp_oy = lip_inset + general_clr;

function shield_to_tp_x(sx) = arduino_x + sx - tp_ox;
function shield_to_tp_y(sy) = arduino_y + sy - tp_oy;

module plate_body() {
    union() {
        translate([0, 0, skirt_h])
            linear_extrude(top_t)
                rounded_rect_2d(tp_w, tp_d, tp_r);
        difference() {
            linear_extrude(skirt_h + 0.1)
                rounded_rect_2d(tp_w, tp_d, tp_r);
            skirt_wall = wall - lip_inset;
            sw = max(skirt_wall, 0.8);
            translate([sw, sw, -0.1])
                linear_extrude(skirt_h + 0.3)
                    rounded_rect_2d(tp_w - 2*sw, tp_d - 2*sw, max(tp_r - sw, 0.5));
        }
    }
}


module display_opening() {
    dx = shield_to_tp_x(disp_tl_x) - disp_clr;
    dy = shield_to_tp_y(disp_tl_y) - disp_clr;
    dw = disp_w + 2*disp_clr;
    dh = disp_h + 2*disp_clr;

    translate([dx, dy, -1])
        cube([dw, dh, top_t + skirt_h + 2]);

    translate([dx - bezel_width, dy - bezel_width,
               skirt_h + top_t - bezel_depth])
        cube([dw + 2*bezel_width, dh + 2*bezel_width,
              bezel_depth + 1]);
}

module buzzer_grille() {
    cx = shield_to_tp_x(buzz_cx);
    cy = shield_to_tp_y(buzz_cy);
    grille_r = buzz_dia/2 - 1.0;

    translate([cx, cy, 0]) {
        for (ring = [1:grille_rings]) {
            ri = ring * grille_r / (grille_rings + 0.5) - grille_slot_w/2;
            ro = ring * grille_r / (grille_rings + 0.5) + grille_slot_w/2;
            if (ri > 0)
                translate([0, 0, -1])
                    difference() {
                        cylinder(r = ro, h = top_t + skirt_h + 2);
                        translate([0, 0, -0.1])
                            cylinder(r = ri, h = top_t + skirt_h + 2.2);
                        for (a = [0:60:359])
                            rotate([0, 0, a])
                                translate([-grille_spoke_w/2, -ro - 1, -0.2])
                                    cube([grille_spoke_w, 2*(ro + 1), top_t + skirt_h + 3]);
                    }
        }
        translate([0, 0, -1])
            cylinder(d = grille_slot_w * 2, h = top_t + skirt_h + 2);
    }
}

module screw_holes() {
    for (p = screw_positions) {
        sx = p[0] - tp_ox;
        sy = p[1] - tp_oy;

        translate([sx, sy, 0]) {
            translate([0, 0, -1])
                cylinder(d = screw_clr_dia, h = top_t + skirt_h + 2);
            translate([0, 0, skirt_h + top_t - screw_cb_depth])
                cylinder(d = screw_cb_dia, h = screw_cb_depth + 1);
        }
    }
}

// ═══════ CALLABLE MODULE ═══════
module button_cutouts() {
    hole_d = btn_dia + 2*btn_clr;
    for (bpos = [[btn1_x, btn1_y], [btn2_x, btn2_y], [btn3_x, btn3_y]]) {
        bx = shield_to_tp_x(bpos[0]);
        by = shield_to_tp_y(bpos[1]);
        translate([bx, by, -1])
            cylinder(d = hole_d, h = top_t + skirt_h + 2);
    }
}

module button_guides() {
    hole_d = btn_dia + 2*btn_clr;
    guide_d = hole_d + 2.0;
    guide_h = 3.0;
    for (bpos = [[btn1_x, btn1_y], [btn2_x, btn2_y], [btn3_x, btn3_y]]) {
        bx = shield_to_tp_x(bpos[0]);
        by = shield_to_tp_y(bpos[1]);
        translate([bx, by, skirt_h - guide_h])
            difference() {
                cylinder(d = guide_d, h = guide_h + 0.1);
                translate([0, 0, -0.1])
                    cylinder(d = hole_d, h = guide_h + 0.3);
            }
    }
}

module top_plate_part() {
    // guide_h = 3.0, skirt_h = lip_h - 0.3 = 1.7. lowest point is skirt_h - guide_h = -1.3
    z_shift = 3.0 - (lip_h - 0.3);
    translate([0, 0, z_shift > 0 ? z_shift : 0])
    union() {
        difference() {
            plate_body();
            button_cutouts();
            display_opening();
            buzzer_grille();
            screw_holes();
        }
        button_guides();
    }
}

// Standalone rendering
top_plate_part();
